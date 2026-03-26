from fastapi import APIRouter, Depends
from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncSession

from app.database import get_db
from app.repositories.tag_repository import TagRepository
from app.schemas.tag import ConsolidateRequest, ConsolidateResponse, MergeGroup, TagCount
from app.services.embedding_service import embedding_service
from app.services.tag_dedup_service import TagDedupService

router = APIRouter()


@router.get("", response_model=list[TagCount])
async def list_tags(db: AsyncSession = Depends(get_db)):
    """Return all unique tags across all items with usage counts, sorted by frequency."""
    result = await db.execute(
        text(
            "SELECT unnest(tags) AS tag, COUNT(*) AS count "
            "FROM items GROUP BY tag ORDER BY count DESC"
        )
    )
    return [TagCount(tag=row.tag, count=row.count) for row in result.all()]


@router.post("/consolidate/preview", response_model=ConsolidateResponse)
async def preview_consolidate(
    body: ConsolidateRequest, db: AsyncSession = Depends(get_db)
):
    """Preview tag consolidation without applying any changes."""
    tag_repo = TagRepository(db)
    svc = TagDedupService(tag_repo, embedding_service)

    total_before_result = await db.execute(
        text("SELECT COUNT(DISTINCT tag) FROM (SELECT unnest(tags) AS tag FROM items) t")
    )
    total_before = total_before_result.scalar_one()

    groups = await svc.consolidate_tags(threshold=body.threshold, dry_run=True)
    merged_count = sum(len(g["merged"]) for g in groups)

    return ConsolidateResponse(
        groups=[MergeGroup(**g) for g in groups],
        total_tags_before=total_before,
        total_tags_after=total_before - merged_count,
    )


@router.post("/consolidate", response_model=ConsolidateResponse)
async def apply_consolidate(
    body: ConsolidateRequest, db: AsyncSession = Depends(get_db)
):
    """Apply tag consolidation, merging semantically similar tags across all items."""
    tag_repo = TagRepository(db)
    svc = TagDedupService(tag_repo, embedding_service)

    total_before_result = await db.execute(
        text("SELECT COUNT(DISTINCT tag) FROM (SELECT unnest(tags) AS tag FROM items) t")
    )
    total_before = total_before_result.scalar_one()

    groups = await svc.consolidate_tags(threshold=body.threshold, dry_run=False)
    merged_count = sum(len(g["merged"]) for g in groups)

    return ConsolidateResponse(
        groups=[MergeGroup(**g) for g in groups],
        total_tags_before=total_before,
        total_tags_after=total_before - merged_count,
    )
