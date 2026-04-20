from fastapi import APIRouter, Depends
from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncSession

from app.auth import get_current_user
from app.database import get_db
from app.models.user import User
from app.schemas.tag import RenameTagRequest, TagCount

router = APIRouter()


@router.get("", response_model=list[TagCount])
async def list_tags(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(
        text(
            "SELECT unnest(tags) AS tag, COUNT(*) AS count "
            "FROM items WHERE user_id = :uid GROUP BY tag ORDER BY count DESC"
        ).bindparams(uid=current_user.id)
    )
    return [TagCount(tag=row.tag, count=row.count) for row in result.all()]


@router.patch("/{tag}", response_model=TagCount)
async def rename_tag(
    tag: str,
    body: RenameTagRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    await db.execute(
        text(
            "UPDATE items SET tags = array_replace(tags, :old, :new) "
            "WHERE :old = ANY(tags) AND user_id = :uid"
        ),
        {"old": tag, "new": body.new_name, "uid": current_user.id},
    )
    await db.commit()
    result = await db.execute(
        text("SELECT COUNT(*) FROM items WHERE :tag = ANY(tags) AND user_id = :uid"),
        {"tag": body.new_name, "uid": current_user.id},
    )
    count = result.scalar_one()
    return TagCount(tag=body.new_name, count=count)


@router.delete("/{tag}", status_code=204)
async def delete_tag(
    tag: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    await db.execute(
        text(
            "UPDATE items SET tags = array_remove(tags, :tag) "
            "WHERE :tag = ANY(tags) AND user_id = :uid"
        ),
        {"tag": tag, "uid": current_user.id},
    )
    await db.commit()
