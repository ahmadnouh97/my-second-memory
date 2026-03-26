from datetime import datetime

from pgvector.sqlalchemy import Vector
from sqlalchemy import DateTime, Index, Text
from sqlalchemy.orm import Mapped, mapped_column
from sqlalchemy.sql import func

from app.database import Base


class TagEmbedding(Base):
    __tablename__ = "tag_embeddings"

    tag: Mapped[str] = mapped_column(Text, primary_key=True)
    embedding: Mapped[list[float]] = mapped_column(Vector(768), nullable=False)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )

    __table_args__ = (
        Index(
            "tag_embeddings_embedding_idx",
            "embedding",
            postgresql_using="ivfflat",
            postgresql_with={"lists": 10},
            postgresql_ops={"embedding": "vector_cosine_ops"},
        ),
    )
