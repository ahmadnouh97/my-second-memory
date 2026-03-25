import uuid
from datetime import datetime

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.ext.asyncio import AsyncSession

from app.database import get_db
from app.repositories.item_repository import ItemRepository
from app.schemas.item import (
    ExtractPreview,
    ExtractRequest,
    ItemCreate,
    ItemResponse,
    ItemUpdate,
    PaginatedItemsResponse,
)
from app.services.ai_service import enrich_metadata
from app.services.embedding_service import embedding_service
from app.services.metadata_extractor import extract_metadata
from app.services.search_service import hybrid_search

router = APIRouter()


@router.post("/extract", response_model=ExtractPreview)
async def extract_url(body: ExtractRequest):
    """Extract metadata from a URL and return an AI-enriched preview (not saved)."""
    raw = extract_metadata(body.url)
    enriched = enrich_metadata(raw)
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
async def create_item(body: ItemCreate, db: AsyncSession = Depends(get_db)):
    """Save a confirmed item to the database."""
    repo = ItemRepository(db)
    emb = await embedding_service.encode_for_item(body.title, body.summary)
    return await repo.create(body, embedding=emb)


@router.get("", response_model=PaginatedItemsResponse)
async def list_items(
    tags: list[str] | None = Query(default=None),
    content_type: str | None = Query(default=None),
    date_from: datetime | None = Query(default=None),
    date_to: datetime | None = Query(default=None),
    page: int = Query(default=1, ge=1),
    limit: int = Query(default=20, ge=1, le=100),
    db: AsyncSession = Depends(get_db),
):
    repo = ItemRepository(db)
    items, total = await repo.list_filtered(tags, content_type, date_from, date_to, page, limit)
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
    db: AsyncSession = Depends(get_db),
):
    repo = ItemRepository(db)
    results = await hybrid_search(repo, q, tags, content_type, limit)
    return [ItemResponse.model_validate(i) for i in results]


@router.get("/{item_id}", response_model=ItemResponse)
async def get_item(item_id: uuid.UUID, db: AsyncSession = Depends(get_db)):
    repo = ItemRepository(db)
    item = await repo.get_by_id(item_id)
    if not item:
        raise HTTPException(status_code=404, detail="Item not found")
    return ItemResponse.model_validate(item)


@router.put("/{item_id}", response_model=ItemResponse)
async def update_item(item_id: uuid.UUID, body: ItemUpdate, db: AsyncSession = Depends(get_db)):
    repo = ItemRepository(db)
    existing = await repo.get_by_id(item_id)
    if not existing:
        raise HTTPException(status_code=404, detail="Item not found")

    # Regenerate embedding if title or summary changed
    new_embedding = None
    new_title = body.title or existing.title
    new_summary = body.summary if body.summary is not None else existing.summary
    if body.title or body.summary is not None:
        new_embedding = await embedding_service.encode_for_item(new_title, new_summary)

    item = await repo.update(item_id, body, embedding=new_embedding)
    return ItemResponse.model_validate(item)


@router.delete("/{item_id}", status_code=204)
async def delete_item(item_id: uuid.UUID, db: AsyncSession = Depends(get_db)):
    repo = ItemRepository(db)
    deleted = await repo.delete(item_id)
    if not deleted:
        raise HTTPException(status_code=404, detail="Item not found")
