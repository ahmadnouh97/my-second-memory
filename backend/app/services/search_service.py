import uuid

from app.models.item import Item
from app.repositories.item_repository import ItemRepository
from app.services.embedding_service import embedding_service

RRF_K = 60


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
    query_embedding = await embedding_service.encode(query)

    vector_results = await repo.vector_search(query_embedding, user_id=user_id, limit=limit * 2)
    fts_results = await repo.fulltext_search(query, user_id=user_id, limit=limit * 2)

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

    results: list[Item] = []
    for item_id in sorted_ids:
        item = all_items[item_id]
        if tags and not any(t in item.tags for t in tags):
            continue
        if content_type and item.content_type != content_type:
            continue
        results.append(item)
        if len(results) >= limit:
            break

    return results
