"""Add users table and user_id FK on items

Revision ID: 005
Revises: 004
Create Date: 2026-04-20 00:00:00.000000

"""
from typing import Sequence, Union
import uuid as uuid_module

import sqlalchemy as sa
from alembic import op
from sqlalchemy.dialects.postgresql import UUID

revision: str = "005"
down_revision: Union[str, None] = "004"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # Create users table
    op.create_table(
        "users",
        sa.Column("id", UUID(as_uuid=True), primary_key=True, server_default=sa.text("gen_random_uuid()")),
        sa.Column("email", sa.Text, nullable=False, unique=True),
        sa.Column("password_hash", sa.Text, nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.text("NOW()"), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), server_default=sa.text("NOW()"), nullable=False),
    )
    op.execute(
        """
        CREATE TRIGGER users_updated_at
        BEFORE UPDATE ON users
        FOR EACH ROW EXECUTE FUNCTION update_updated_at()
        """
    )

    # Add user_id column to items (nullable first so we can backfill)
    op.add_column("items", sa.Column("user_id", UUID(as_uuid=True), nullable=True))

    # Create a legacy user and backfill all existing items to it
    legacy_id = str(uuid_module.uuid4())
    op.execute(
        f"INSERT INTO users (id, email, password_hash) "
        f"VALUES ('{legacy_id}', 'legacy@local', 'LEGACY_UNUSABLE_HASH')"
    )
    op.execute(f"UPDATE items SET user_id = '{legacy_id}' WHERE user_id IS NULL")

    # Enforce NOT NULL and FK now that all rows have a value
    op.alter_column("items", "user_id", nullable=False)
    op.create_foreign_key(
        "fk_items_user_id",
        "items",
        "users",
        ["user_id"],
        ["id"],
        ondelete="CASCADE",
    )
    op.create_index("items_user_id_created_at_idx", "items", ["user_id"])


def downgrade() -> None:
    op.drop_index("items_user_id_created_at_idx", table_name="items")
    op.drop_constraint("fk_items_user_id", "items", type_="foreignkey")
    op.drop_column("items", "user_id")
    op.execute("DROP TRIGGER IF EXISTS users_updated_at ON users")
    op.drop_table("users")
