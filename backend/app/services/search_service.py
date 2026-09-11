import logging
import uuid

import httpx
from google.api_core.exceptions import GoogleAPICallError
from google.genai.errors import APIError

from app.errors import RateLimitError
from app.models.item import Item
from app.repositories.item_repository import ItemRepository
from app.services.embedding_service import embedding_service

RRF_K = 60
logger = logging.getLogger(__name__)


async def hybrid_search(
    repo: ItemRepository,
    query: str,
    user_id: uuid.UUID,
    tags: list[str] | None = None,
    content_type: str | None = None,
    limit: int = 20,
) -> list[Item]:
    """
    Combines vector search and full-text search using Reciprocal Rank Fusion (RRF).
    Score = 1/(RRF_K + rank_vector) + 1/(RRF_K + rank_fts)
    """
    filters = {"user_id": user_id, "tags": tags, "content_type": content_type}
    # Keep lexical search available when the embedding provider is unavailable.
    # DB errors still propagate; only the external embedding call is recovered.
    fts_results = await repo.fulltext_search(query, limit=limit * 2, **filters)
    try:
        query_embedding = await embedding_service.encode(query)
    except (RateLimitError, APIError, GoogleAPICallError, httpx.HTTPError, TimeoutError) as exc:
        logger.warning("Search using lexical fallback: %s", type(exc).__name__)
        return [item for item, _ in fts_results[:limit]]

    vector_results = await repo.vector_search(query_embedding, limit=limit * 2, **filters)

    vector_ranks: dict[str, int] = {str(item.id): rank for rank, (item, _) in enumerate(vector_results, 1)}
    fts_ranks: dict[str, int] = {str(item.id): rank for rank, (item, _) in enumerate(fts_results, 1)}

    all_items: dict[str, Item] = {}
    for item, _ in vector_results:
        all_items[str(item.id)] = item
    for item, _ in fts_results:
        all_items[str(item.id)] = item

    def rrf_score(item_id: str) -> float:
        score = 0.0
        if item_id in vector_ranks:
            score += 1.0 / (RRF_K + vector_ranks[item_id])
        if item_id in fts_ranks:
            score += 1.0 / (RRF_K + fts_ranks[item_id])
        return score

    sorted_ids = sorted(all_items.keys(), key=rrf_score, reverse=True)

    return [all_items[item_id] for item_id in sorted_ids[:limit]]
