import asyncio

import numpy as np
from sqlalchemy import func, select, text
from sqlalchemy.ext.asyncio import AsyncSession

from app.config import settings
from app.models.item import Item
from app.repositories.tag_repository import TagRepository
from app.services.embedding_service import EmbeddingService

_BATCH_SIZE = 50
_BATCH_DELAY_SECS = 0.1


class TagDedupService:
    def __init__(self, tag_repo: TagRepository, embedding_svc: EmbeddingService):
        self._repo = tag_repo
        self._embed = embedding_svc

    async def normalize_tags(
        self,
        tags: list[str],
        threshold: float | None = None,
    ) -> list[str]:
        """
        Normalize a list of tags by snapping each one to an existing canonical tag
        when cosine similarity exceeds the threshold. New tags are upserted into
        tag_embeddings. Returns deduplicated list preserving original order.
        """
        if not tags:
            return []
        if threshold is None:
            threshold = settings.tag_normalize_threshold

        # Check which tags already exist (exact match — skip embedding)
        existing = await self._repo.get_by_tags(tags)
        existing_set = {e.tag for e in existing}

        new_tags = [t for t in tags if t not in existing_set]

        # Embed only genuinely new tags in one batch call
        normalized_map: dict[str, str] = {t: t for t in existing_set}
        if new_tags:
            embeddings = await self._embed.encode_tags(new_tags)
            to_upsert: list[tuple[str, list[float]]] = []
            for tag, emb in zip(new_tags, embeddings):
                nearest = await self._repo.find_nearest(emb, threshold, limit=1)
                if nearest:
                    canonical, _ = nearest[0]
                    normalized_map[tag] = canonical
                else:
                    normalized_map[tag] = tag
                    to_upsert.append((tag, emb))
            if to_upsert:
                await self._repo.upsert_batch(to_upsert)

        # Map and deduplicate while preserving order
        seen: set[str] = set()
        result: list[str] = []
        for tag in tags:
            canonical = normalized_map.get(tag, tag)
            if canonical not in seen:
                seen.add(canonical)
                result.append(canonical)
        return result

    async def backfill_tag_embeddings(self) -> int:
        """
        Embed all tags that exist on items but have no entry in tag_embeddings yet.
        Returns the number of tags backfilled.
        """
        result = await self._repo.db.execute(
            text("SELECT DISTINCT unnest(tags) AS tag FROM items ORDER BY tag")
        )
        all_tags = [row.tag for row in result.all()]

        existing = await self._repo.get_all()
        existing_set = {e.tag for e in existing}

        missing = [t for t in all_tags if t not in existing_set]
        if not missing:
            return 0

        to_upsert: list[tuple[str, list[float]]] = []
        for i in range(0, len(missing), _BATCH_SIZE):
            batch = missing[i : i + _BATCH_SIZE]
            embeddings = await self._embed.encode_tags(batch)
            to_upsert.extend(zip(batch, embeddings))
            if i + _BATCH_SIZE < len(missing):
                await asyncio.sleep(_BATCH_DELAY_SECS)

        await self._repo.upsert_batch(to_upsert)
        return len(to_upsert)

    async def consolidate_tags(
        self,
        threshold: float | None = None,
        dry_run: bool = False,
    ) -> list[dict]:
        """
        Cluster all tags by embedding similarity and merge duplicates.
        Returns a list of merge groups: {"canonical", "merged", "items_affected"}.
        When dry_run=True, no changes are applied.
        """
        if threshold is None:
            threshold = settings.tag_consolidate_threshold

        # Backfill tag_embeddings so save-time normalization stays current.
        await self.backfill_tag_embeddings()

        # Get all distinct tags directly from items for clustering.
        tag_result = await self._repo.db.execute(
            text("SELECT DISTINCT unnest(tags) AS tag FROM items ORDER BY tag")
        )
        tags = [row.tag for row in tag_result.all()]

        if len(tags) < 2:
            return []

        # Embed with SEMANTIC_SIMILARITY — correct task type for symmetric
        # tag-to-tag comparison. Fresh in-memory embeddings; not stored.
        raw_vectors = await self._embed.encode_for_similarity(tags)

        # Numpy cosine similarity matrix (handles non-unit vectors safely).
        matrix = np.array(raw_vectors, dtype=np.float32)
        norms = np.linalg.norm(matrix, axis=1, keepdims=True)
        norms = np.where(norms > 0, norms, 1.0)
        matrix = matrix / norms
        sim_matrix: np.ndarray = matrix @ matrix.T  # shape (n, n)

        n = len(tags)

        # Union-Find
        parent = list(range(n))

        def find(x: int) -> int:
            while parent[x] != x:
                parent[x] = parent[parent[x]]
                x = parent[x]
            return x

        def union(x: int, y: int) -> None:
            parent[find(x)] = find(y)

        for i in range(n):
            for j in range(i + 1, n):
                if float(sim_matrix[i, j]) > threshold:
                    union(i, j)

        # Group by cluster root
        clusters: dict[int, list[int]] = {}
        for i in range(n):
            root = find(i)
            clusters.setdefault(root, []).append(i)

        # Only clusters with >1 tag need merging
        merge_groups = [idxs for idxs in clusters.values() if len(idxs) > 1]
        if not merge_groups:
            return []

        # Determine canonical tag per cluster (most used; tie-break: shortest)
        usage_result = await self._repo.db.execute(
            text(
                "SELECT unnest(tags) AS tag, COUNT(*) AS cnt "
                "FROM items GROUP BY tag"
            )
        )
        usage: dict[str, int] = {row.tag: row.cnt for row in usage_result.all()}

        report: list[dict] = []
        for idxs in merge_groups:
            cluster_tags = [tags[i] for i in idxs]
            canonical = max(
                cluster_tags,
                key=lambda t: (usage.get(t, 0), -len(t)),
            )
            to_merge = [t for t in cluster_tags if t != canonical]

            # Count affected items
            count_result = await self._repo.db.execute(
                select(func.count()).select_from(Item).where(Item.tags.overlap(to_merge))
            )
            items_affected = count_result.scalar_one()

            report.append(
                {
                    "canonical": canonical,
                    "merged": to_merge,
                    "items_affected": items_affected,
                }
            )

            if not dry_run:
                await self._apply_merge(canonical, to_merge)

        if not dry_run:
            await self._repo.prune_orphans()

        return report

    async def apply_plan(self, groups: list[dict]) -> list[dict]:
        """
        Apply a user-edited merge plan directly without re-running embedding or clustering.
        Each group is a dict with 'canonical' (str) and 'merged' (list[str]).
        Returns the same groups enriched with items_affected.
        """
        report: list[dict] = []
        for group in groups:
            canonical = group["canonical"]
            to_merge = group["merged"]
            if not to_merge:
                continue
            count_result = await self._repo.db.execute(
                select(func.count()).select_from(Item).where(Item.tags.overlap(to_merge))
            )
            items_affected = count_result.scalar_one()
            await self._apply_merge(canonical, to_merge)
            report.append({"canonical": canonical, "merged": to_merge, "items_affected": items_affected})
        await self._repo.prune_orphans()
        return report

    async def _apply_merge(self, canonical: str, to_merge: list[str]) -> None:
        """Replace all merged tags with the canonical tag and deduplicate."""
        for old_tag in to_merge:
            # Replace old_tag with canonical, then deduplicate the array in one pass
            await self._repo.db.execute(
                text(
                    "UPDATE items "
                    "SET tags = ARRAY(SELECT DISTINCT unnest(array_replace(tags, :old, :canonical))) "
                    "WHERE :old = ANY(tags)"
                ).bindparams(old=old_tag, canonical=canonical)
            )
        await self._repo.db.commit()
