import uuid
from datetime import datetime

from sqlalchemy import and_, delete, func, select, text, update
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.item import Item
from app.schemas.item import ItemCreate, ItemUpdate


class ItemRepository:
    def __init__(self, db: AsyncSession):
        self.db = db

    async def create(self, data: ItemCreate, embedding: list[float] | None, user_id: uuid.UUID) -> Item:
        item = Item(
            user_id=user_id,
            url=data.url,
            title=data.title,
            summary=data.summary,
            content=data.content,
            content_type=data.content_type,
            tags=data.tags,
            thumbnail_url=data.thumbnail_url,
            source_meta=data.source_meta,
            embedding=embedding,
        )
        self.db.add(item)
        await self.db.commit()
        await self.db.refresh(item)
        return item

    async def get_by_id(self, item_id: uuid.UUID, user_id: uuid.UUID) -> Item | None:
        result = await self.db.execute(
            select(Item).where(Item.id == item_id, Item.user_id == user_id)
        )
        return result.scalar_one_or_none()

    async def get_by_url(self, url: str, user_id: uuid.UUID) -> Item | None:
        result = await self.db.execute(
            select(Item).where(Item.url == url, Item.user_id == user_id)
        )
        return result.scalar_one_or_none()

    async def list_all(self, user_id: uuid.UUID) -> list[Item]:
        result = await self.db.execute(
            select(Item).where(Item.user_id == user_id).order_by(Item.created_at.desc())
        )
        return list(result.scalars().all())

    async def delete_all(self, user_id: uuid.UUID) -> int:
        result = await self.db.execute(delete(Item).where(Item.user_id == user_id))
        await self.db.commit()
        return result.rowcount

    async def list_filtered(
        self,
        user_id: uuid.UUID,
        tags: list[str] | None = None,
        content_type: str | None = None,
        date_from: datetime | None = None,
        date_to: datetime | None = None,
        page: int = 1,
        limit: int = 20,
    ) -> tuple[list[Item], int]:
        conditions = [Item.user_id == user_id]
        if tags:
            conditions.append(Item.tags.overlap(tags))
        if content_type:
            conditions.append(Item.content_type == content_type)
        if date_from:
            conditions.append(Item.created_at >= date_from)
        if date_to:
            conditions.append(Item.created_at <= date_to)

        where_clause = and_(*conditions)

        count_result = await self.db.execute(
            select(func.count()).select_from(Item).where(where_clause)
        )
        total = count_result.scalar_one()

        result = await self.db.execute(
            select(Item)
            .where(where_clause)
            .order_by(Item.created_at.desc())
            .offset((page - 1) * limit)
            .limit(limit)
        )
        return result.scalars().all(), total

    async def update(
        self,
        item_id: uuid.UUID,
        data: ItemUpdate,
        user_id: uuid.UUID,
        embedding: list[float] | None = None,
    ) -> Item | None:
        values = {k: v for k, v in data.model_dump(exclude_none=True).items()}
        if embedding is not None:
            values["embedding"] = embedding

        if not values:
            return await self.get_by_id(item_id, user_id)

        await self.db.execute(
            update(Item).where(Item.id == item_id, Item.user_id == user_id).values(**values)
        )
        await self.db.commit()
        return await self.get_by_id(item_id, user_id)

    async def delete(self, item_id: uuid.UUID, user_id: uuid.UUID) -> bool:
        result = await self.db.execute(
            delete(Item).where(Item.id == item_id, Item.user_id == user_id)
        )
        await self.db.commit()
        return result.rowcount > 0

    async def vector_search(
        self, embedding: list[float], user_id: uuid.UUID, limit: int = 20
    ) -> list[tuple[Item, float]]:
        embedding_str = f"[{','.join(str(v) for v in embedding)}]"
        result = await self.db.execute(
            select(Item, (1 - Item.embedding.cosine_distance(text(f"'{embedding_str}'::vector"))).label("score"))
            .where(Item.embedding.is_not(None), Item.user_id == user_id)
            .order_by(Item.embedding.cosine_distance(text(f"'{embedding_str}'::vector")))
            .limit(limit)
        )
        return result.all()

    async def fulltext_search(
        self, query: str, user_id: uuid.UUID, limit: int = 20
    ) -> list[tuple[Item, float]]:
        result = await self.db.execute(
            select(
                Item,
                func.ts_rank(
                    text("fts_vector"),
                    func.plainto_tsquery("english", query),
                ).label("score"),
            )
            .where(
                text("fts_vector @@ plainto_tsquery('english', :q)").bindparams(q=query),
                Item.user_id == user_id,
            )
            .order_by(text("score DESC"))
            .limit(limit)
        )
        return result.all()
