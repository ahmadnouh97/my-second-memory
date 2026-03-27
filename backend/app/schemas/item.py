import uuid
from datetime import datetime

from pydantic import BaseModel, HttpUrl


class ItemBase(BaseModel):
    url: str
    title: str
    summary: str | None = None
    content_type: str
    tags: list[str] = []
    thumbnail_url: str | None = None


class ItemCreate(ItemBase):
    content: str | None = None
    source_meta: dict | None = None


class ItemUpdate(BaseModel):
    title: str | None = None
    summary: str | None = None
    tags: list[str] | None = None
    thumbnail_url: str | None = None


class ItemResponse(ItemBase):
    id: uuid.UUID
    content_type: str
    created_at: datetime
    updated_at: datetime

    model_config = {"from_attributes": True}


class ExtractRequest(BaseModel):
    url: str


class ExtractPreview(BaseModel):
    url: str
    content_type: str
    title: str
    summary: str
    tags: list[str]
    thumbnail_url: str | None = None
    content: str | None = None
    source_meta: dict | None = None


class SearchRequest(BaseModel):
    q: str
    tags: list[str] | None = None
    content_type: str | None = None
    date_from: datetime | None = None
    date_to: datetime | None = None


class PaginatedItemsResponse(BaseModel):
    items: list[ItemResponse]
    total: int
    page: int
    limit: int


class ImportResult(BaseModel):
    imported: int
    skipped: int
    errors: list[str]
