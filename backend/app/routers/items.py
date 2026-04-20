import uuid
from datetime import datetime

from fastapi import APIRouter, Depends, File, HTTPException, Query, UploadFile
from fastapi.responses import StreamingResponse
from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncSession

from app.auth import get_current_user
from app.database import get_db
from app.models.user import User
from app.repositories.item_repository import ItemRepository
from app.schemas.item import (
    ExtractPreview,
    ExtractRequest,
    ImportResult,
    ItemCreate,
    ItemResponse,
    ItemUpdate,
    PaginatedItemsResponse,
)
from app.services.ai_service import enrich_metadata
from app.services.embedding_service import embedding_service
from app.services.export_service import export_as_csv, export_as_json
from app.services.import_service import parse_csv, parse_json
from app.services.metadata_extractor import extract_metadata
from app.services.search_service import hybrid_search

router = APIRouter()


@router.post("/extract", response_model=ExtractPreview)
async def extract_url(
    body: ExtractRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    raw = extract_metadata(body.url)
    result = await db.execute(
        text("SELECT DISTINCT unnest(tags) AS tag FROM items WHERE user_id = :uid").bindparams(uid=current_user.id)
    )
    existing_tags = [row.tag for row in result.all()]
    enriched = enrich_metadata(raw, existing_tags=existing_tags)
    return ExtractPreview(
        url=raw.url,
        content_type=raw.content_type,
        title=enriched.title,
        summary=enriched.summary,
        tags=enriched.tags,
        thumbnail_url=raw.thumbnail_url,
        content=raw.content,
        source_meta={**raw.extra, "raw_title": raw.raw_title} if raw.extra else {"raw_title": raw.raw_title},
    )


@router.post("", response_model=ItemResponse, status_code=201)
async def create_item(
    body: ItemCreate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    repo = ItemRepository(db)
    emb = await embedding_service.encode_for_item(body.title, body.summary)
    return await repo.create(body, embedding=emb, user_id=current_user.id)


@router.get("", response_model=PaginatedItemsResponse)
async def list_items(
    tags: list[str] | None = Query(default=None),
    content_type: str | None = Query(default=None),
    date_from: datetime | None = Query(default=None),
    date_to: datetime | None = Query(default=None),
    page: int = Query(default=1, ge=1),
    limit: int = Query(default=20, ge=1, le=100),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    repo = ItemRepository(db)
    items, total = await repo.list_filtered(
        current_user.id, tags, content_type, date_from, date_to, page, limit
    )
    return PaginatedItemsResponse(
        items=[ItemResponse.model_validate(i) for i in items],
        total=total,
        page=page,
        limit=limit,
    )


@router.get("/search", response_model=list[ItemResponse])
async def search_items(
    q: str = Query(..., min_length=1),
    tags: list[str] | None = Query(default=None),
    content_type: str | None = Query(default=None),
    limit: int = Query(default=20, ge=1, le=50),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    repo = ItemRepository(db)
    results = await hybrid_search(repo, q, user_id=current_user.id, tags=tags, content_type=content_type, limit=limit)
    return [ItemResponse.model_validate(i) for i in results]


@router.get("/export")
async def export_items(
    format: str = Query(default="json", pattern="^(json|csv)$"),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    repo = ItemRepository(db)
    items = await repo.list_all(current_user.id)

    if format == "csv":
        content = export_as_csv(items)
        media_type = "text/csv"
        filename = "items.csv"
    else:
        content = export_as_json(items)
        media_type = "application/json"
        filename = "items.json"

    return StreamingResponse(
        iter([content]),
        media_type=media_type,
        headers={"Content-Disposition": f'attachment; filename="{filename}"'},
    )


@router.post("/import", response_model=ImportResult)
async def import_items(
    format: str = Query(default="json", pattern="^(json|csv)$"),
    file: UploadFile = File(...),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    content = (await file.read()).decode("utf-8")

    if format == "csv":
        items_to_create, parse_errors = parse_csv(content)
    else:
        items_to_create, parse_errors = parse_json(content)

    repo = ItemRepository(db)
    imported = 0
    skipped = 0
    errors = list(parse_errors)

    for item_data in items_to_create:
        if not item_data.url or not item_data.title:
            errors.append(f"Skipped item with missing url or title: {item_data.url!r}")
            skipped += 1
            continue

        existing = await repo.get_by_url(item_data.url, current_user.id)
        if existing:
            skipped += 1
            continue

        try:
            emb = await embedding_service.encode_for_item(item_data.title, item_data.summary)
            await repo.create(item_data, embedding=emb, user_id=current_user.id)
            imported += 1
        except Exception as e:
            errors.append(f"Failed to save '{item_data.url}': {e}")
            skipped += 1

    return ImportResult(imported=imported, skipped=skipped, errors=errors)


@router.delete("", status_code=200)
async def clear_all_items(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    repo = ItemRepository(db)
    count = await repo.delete_all(current_user.id)
    return {"deleted": count}


@router.get("/{item_id}", response_model=ItemResponse)
async def get_item(
    item_id: uuid.UUID,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    repo = ItemRepository(db)
    item = await repo.get_by_id(item_id, current_user.id)
    if not item:
        raise HTTPException(status_code=404, detail="Item not found")
    return ItemResponse.model_validate(item)


@router.put("/{item_id}", response_model=ItemResponse)
async def update_item(
    item_id: uuid.UUID,
    body: ItemUpdate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    repo = ItemRepository(db)
    existing = await repo.get_by_id(item_id, current_user.id)
    if not existing:
        raise HTTPException(status_code=404, detail="Item not found")

    new_embedding = None
    new_title = body.title or existing.title
    new_summary = body.summary if body.summary is not None else existing.summary
    if body.title or body.summary is not None:
        new_embedding = await embedding_service.encode_for_item(new_title, new_summary)

    item = await repo.update(item_id, body, user_id=current_user.id, embedding=new_embedding)
    return ItemResponse.model_validate(item)


@router.delete("/{item_id}", status_code=204)
async def delete_item(
    item_id: uuid.UUID,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    repo = ItemRepository(db)
    deleted = await repo.delete(item_id, current_user.id)
    if not deleted:
        raise HTTPException(status_code=404, detail="Item not found")
