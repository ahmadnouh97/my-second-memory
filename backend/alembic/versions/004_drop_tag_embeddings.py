"""Drop tag_embeddings table

Revision ID: 004
Revises: 003
Create Date: 2026-03-27 00:00:00.000000

"""
from typing import Sequence, Union

import sqlalchemy as sa
from alembic import op
from pgvector.sqlalchemy import Vector

revision: str = "004"
down_revision: Union[str, None] = "003"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.execute("DROP INDEX IF EXISTS tag_embeddings_embedding_idx")
    op.drop_table("tag_embeddings")


def downgrade() -> None:
    op.create_table(
        "tag_embeddings",
        sa.Column("tag", sa.Text, primary_key=True),
        sa.Column("embedding", Vector(768), nullable=False),
        sa.Column(
            "created_at",
            sa.DateTime(timezone=True),
            server_default=sa.func.now(),
            nullable=False,
        ),
    )
    op.execute(
        "CREATE INDEX tag_embeddings_embedding_idx ON tag_embeddings "
        "USING ivfflat (embedding vector_cosine_ops) WITH (lists = 10)"
    )
