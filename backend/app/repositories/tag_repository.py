from sqlalchemy import delete, select, text
from sqlalchemy.dialects.postgresql import insert
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.tag_embedding import TagEmbedding


class TagRepository:
    def __init__(self, db: AsyncSession):
        self.db = db

    async def get_all(self) -> list[TagEmbedding]:
        result = await self.db.execute(select(TagEmbedding))
        return list(result.scalars().all())

    async def get_by_tags(self, tags: list[str]) -> list[TagEmbedding]:
        result = await self.db.execute(
            select(TagEmbedding).where(TagEmbedding.tag.in_(tags))
        )
        return list(result.scalars().all())

    async def upsert(self, tag: str, embedding: list[float]) -> None:
        stmt = insert(TagEmbedding).values(tag=tag, embedding=embedding)
        stmt = stmt.on_conflict_do_update(
            index_elements=["tag"], set_={"embedding": embedding}
        )
        await self.db.execute(stmt)
        await self.db.commit()

    async def upsert_batch(self, entries: list[tuple[str, list[float]]]) -> None:
        if not entries:
            return
        stmt = insert(TagEmbedding).values(
            [{"tag": tag, "embedding": emb} for tag, emb in entries]
        )
        stmt = stmt.on_conflict_do_update(
            index_elements=["tag"], set_={"embedding": stmt.excluded.embedding}
        )
        await self.db.execute(stmt)
        await self.db.commit()

    async def delete(self, tags: list[str]) -> None:
        if not tags:
            return
        await self.db.execute(
            delete(TagEmbedding).where(TagEmbedding.tag.in_(tags))
        )
        await self.db.commit()

    async def prune_orphans(self) -> int:
        """Remove tag embeddings for tags that no longer exist on any item."""
        result = await self.db.execute(
            text(
                "DELETE FROM tag_embeddings "
                "WHERE tag NOT IN (SELECT DISTINCT unnest(tags) FROM items) "
                "RETURNING tag"
            )
        )
        await self.db.commit()
        return result.rowcount

    async def find_nearest(
        self, embedding: list[float], threshold: float, limit: int = 1
    ) -> list[tuple[str, float]]:
        """Return tags with cosine similarity above threshold, ordered by similarity desc."""
        embedding_str = f"[{','.join(str(v) for v in embedding)}]"
        result = await self.db.execute(
            text(
                "SELECT tag, 1 - (embedding <=> CAST(:query_vec AS vector)) AS similarity "
                "FROM tag_embeddings "
                "WHERE 1 - (embedding <=> CAST(:query_vec AS vector)) > :threshold "
                "ORDER BY embedding <=> CAST(:query_vec AS vector) "
                "LIMIT :limit"
            ),
            {"query_vec": embedding_str, "threshold": threshold, "limit": limit},
        )
        return [(row.tag, row.similarity) for row in result.all()]
