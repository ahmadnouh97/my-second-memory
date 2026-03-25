"""Resize embedding column from vector(384) to vector(768) for Gemini text-embedding-004

Revision ID: 002
Revises: 001
Create Date: 2026-03-26 00:00:00.000000

"""
from typing import Sequence, Union

import sqlalchemy as sa
from alembic import op
from pgvector.sqlalchemy import Vector

revision: str = "002"
down_revision: Union[str, None] = "001"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.execute("DROP INDEX IF EXISTS items_embedding_idx")
    op.drop_column("items", "embedding")
    op.add_column("items", sa.Column("embedding", Vector(768), nullable=True))
    op.execute(
        "CREATE INDEX items_embedding_idx ON items "
        "USING ivfflat (embedding vector_cosine_ops) WITH (lists = 100)"
    )


def downgrade() -> None:
    op.execute("DROP INDEX IF EXISTS items_embedding_idx")
    op.drop_column("items", "embedding")
    op.add_column("items", sa.Column("embedding", Vector(384), nullable=True))
    op.execute(
        "CREATE INDEX items_embedding_idx ON items "
        "USING ivfflat (embedding vector_cosine_ops) WITH (lists = 100)"
    )
