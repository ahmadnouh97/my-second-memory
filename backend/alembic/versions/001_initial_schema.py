"""Initial schema with pgvector and full-text search

Revision ID: 001
Revises:
Create Date: 2025-01-01 00:00:00.000000

"""
from typing import Sequence, Union

import sqlalchemy as sa
from alembic import op
from pgvector.sqlalchemy import Vector
from sqlalchemy.dialects.postgresql import ARRAY, JSONB, UUID

revision: str = "001"
down_revision: Union[str, None] = None
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.execute("CREATE EXTENSION IF NOT EXISTS vector")
    op.execute("CREATE EXTENSION IF NOT EXISTS pg_trgm")

    op.create_table(
        "items",
        sa.Column("id", UUID(as_uuid=True), primary_key=True, server_default=sa.text("gen_random_uuid()")),
        sa.Column("url", sa.Text, nullable=False),
        sa.Column("title", sa.Text, nullable=False),
        sa.Column("summary", sa.Text, nullable=True),
        sa.Column("content", sa.Text, nullable=True),
        sa.Column("content_type", sa.String(50), nullable=False),
        sa.Column("tags", ARRAY(sa.Text), server_default="{}"),
        sa.Column("thumbnail_url", sa.Text, nullable=True),
        sa.Column("source_meta", JSONB, nullable=True),
        sa.Column("embedding", Vector(384), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.text("NOW()"), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), server_default=sa.text("NOW()"), nullable=False),
    )

    # Full-text search vector as a generated column
    op.execute("""
        ALTER TABLE items
        ADD COLUMN fts_vector tsvector
        GENERATED ALWAYS AS (
            to_tsvector('english',
                coalesce(title, '') || ' ' ||
                coalesce(summary, '') || ' ' ||
                coalesce(content, '')
            )
        ) STORED
    """)

    # Updated_at trigger
    op.execute("""
        CREATE OR REPLACE FUNCTION update_updated_at()
        RETURNS TRIGGER AS $$
        BEGIN
            NEW.updated_at = NOW();
            RETURN NEW;
        END;
        $$ LANGUAGE plpgsql
    """)
    op.execute("""
        CREATE TRIGGER items_updated_at
        BEFORE UPDATE ON items
        FOR EACH ROW EXECUTE FUNCTION update_updated_at()
    """)

    # Indexes
    op.execute("CREATE INDEX items_fts_idx ON items USING GIN (fts_vector)")
    op.execute("CREATE INDEX items_tags_idx ON items USING GIN (tags)")
    op.execute("CREATE INDEX items_created_at_idx ON items (created_at DESC)")
    # ivfflat index (created after data is loaded; here for fresh setup)
    op.execute(
        "CREATE INDEX items_embedding_idx ON items USING ivfflat (embedding vector_cosine_ops) WITH (lists = 100)"
    )


def downgrade() -> None:
    op.drop_table("items")
    op.execute("DROP FUNCTION IF EXISTS update_updated_at CASCADE")
