from pydantic import BaseModel, Field


class TagCount(BaseModel):
    tag: str
    count: int


class ConsolidateRequest(BaseModel):
    threshold: float | None = Field(
        default=None,
        ge=0.5,
        le=1.0,
        description="Cosine similarity threshold. Defaults to TAG_CONSOLIDATE_THRESHOLD env var.",
    )


class MergeGroup(BaseModel):
    canonical: str
    merged: list[str]
    items_affected: int


class ConsolidateResponse(BaseModel):
    groups: list[MergeGroup]
    total_tags_before: int
    total_tags_after: int
