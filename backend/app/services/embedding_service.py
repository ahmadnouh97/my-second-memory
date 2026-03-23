from sentence_transformers import SentenceTransformer


class EmbeddingService:
    _model: SentenceTransformer | None = None
    MODEL_NAME = "all-MiniLM-L6-v2"

    def warmup(self) -> None:
        if self._model is None:
            self._model = SentenceTransformer(self.MODEL_NAME)

    def encode(self, text: str) -> list[float]:
        if self._model is None:
            self.warmup()
        vector = self._model.encode(text, normalize_embeddings=True)
        return vector.tolist()

    def encode_for_item(self, title: str, summary: str | None) -> list[float]:
        text = title
        if summary:
            text = f"{title}. {summary}"
        return self.encode(text)


embedding_service = EmbeddingService()
