"""Re-embed all items using the new Gemini text-embedding-004 model (768 dimensions).

Run this once after migrating the embedding column from vector(384) to vector(768):

    docker compose exec backend uv run python scripts/reembed_all.py

Targets only rows where embedding IS NULL, so it is safe to re-run if interrupted.
"""
import asyncio
import os
import sys

# Ensure the backend root (/app) is on the path when run as a script
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession, async_sessionmaker

from app.database import engine
from app.models.item import Item
from app.services.embedding_service import embedding_service

BATCH_SIZE = 50


async def reembed() -> None:
    async_session = async_sessionmaker(engine, class_=AsyncSession, expire_on_commit=False)

    async with async_session() as session:
        result = await session.execute(
            select(Item).where(Item.embedding.is_(None)).order_by(Item.created_at)
        )
        items = result.scalars().all()

        if not items:
            print("No items need re-embedding.")
            return

        print(f"Re-embedding {len(items)} items...")

        for i, item in enumerate(items):
            item.embedding = await embedding_service.encode_for_item(item.title, item.summary)

            if (i + 1) % BATCH_SIZE == 0:
                await session.commit()
                print(f"  {i + 1}/{len(items)} committed")

        await session.commit()
        print(f"Done. {len(items)} items re-embedded.")


asyncio.run(reembed())
