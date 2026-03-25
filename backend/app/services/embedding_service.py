import asyncio

from google import genai
from google.genai import types

from app.config import settings

EMBEDDING_MODEL = "gemini-embedding-001"
EMBEDDING_DIM = 768


class EmbeddingService:
    def __init__(self) -> None:
        self._client = genai.Client(api_key=settings.google_api_key)

    def warmup(self) -> None:
        """Preflight check — crashes startup early if the API key is invalid."""
        self._client.models.embed_content(
            model=EMBEDDING_MODEL,
            contents="warmup",
            config=types.EmbedContentConfig(
                task_type="RETRIEVAL_QUERY",
                output_dimensionality=EMBEDDING_DIM,
            ),
        )

    async def encode(self, text: str) -> list[float]:
        """Encode a search query. Uses RETRIEVAL_QUERY task type."""
        result = await asyncio.to_thread(
            self._client.models.embed_content,
            model=EMBEDDING_MODEL,
            contents=text,
            config=types.EmbedContentConfig(
                task_type="RETRIEVAL_QUERY",
                output_dimensionality=EMBEDDING_DIM,
            ),
        )
        return result.embeddings[0].values

    async def encode_for_item(self, title: str, summary: str | None) -> list[float]:
        """Encode an item for storage. Uses RETRIEVAL_DOCUMENT task type."""
        text = title if not summary else f"{title}. {summary}"
        result = await asyncio.to_thread(
            self._client.models.embed_content,
            model=EMBEDDING_MODEL,
            contents=text,
            config=types.EmbedContentConfig(
                task_type="RETRIEVAL_DOCUMENT",
                output_dimensionality=EMBEDDING_DIM,
            ),
        )
        return result.embeddings[0].values


embedding_service = EmbeddingService()
