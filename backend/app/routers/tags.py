from fastapi import APIRouter, Depends
from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncSession

from app.database import get_db
from app.schemas.tag import RenameTagRequest, TagCount

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


@router.patch("/{tag}", response_model=TagCount)
async def rename_tag(tag: str, body: RenameTagRequest, db: AsyncSession = Depends(get_db)):
    """Rename a tag across all items."""
    await db.execute(
        text("UPDATE items SET tags = array_replace(tags, :old, :new) WHERE :old = ANY(tags)"),
        {"old": tag, "new": body.new_name},
    )
    await db.commit()
    result = await db.execute(
        text("SELECT COUNT(*) FROM items WHERE :tag = ANY(tags)"),
        {"tag": body.new_name},
    )
    count = result.scalar_one()
    return TagCount(tag=body.new_name, count=count)


@router.delete("/{tag}", status_code=204)
async def delete_tag(tag: str, db: AsyncSession = Depends(get_db)):
    """Remove a tag from all items."""
    await db.execute(
        text("UPDATE items SET tags = array_remove(tags, :tag) WHERE :tag = ANY(tags)"),
        {"tag": tag},
    )
    await db.commit()
