from langchain_groq import ChatGroq
from pydantic import BaseModel, Field

from app.config import settings
from app.services.metadata_extractor import RawMetadata


class EnrichedMetadata(BaseModel):
    title: str = Field(description="Clear, concise title for the saved item (max 100 chars)")
    summary: str = Field(description="2-3 sentence summary of the content")
    tags: list[str] = Field(description="5-8 relevant keyword tags (lowercase, no spaces, use hyphens)")


_llm: ChatGroq | None = None


def _get_llm() -> ChatGroq:
    global _llm
    if _llm is None:
        _llm = ChatGroq(
            model="qwen/qwen3-32b",
            api_key=settings.groq_api_key,
            temperature=0,
        )
    return _llm


def enrich_metadata(raw: RawMetadata, existing_tags: list[str] | None = None) -> EnrichedMetadata:
    """Use LLM to generate a refined title, summary, and tags from raw metadata."""
    llm = _get_llm()
    structured = llm.with_structured_output(EnrichedMetadata)

    content_snippet = ""
    if raw.content:
        content_snippet = raw.content[:1500]
    elif raw.description:
        content_snippet = raw.description[:1500]

    existing_tags_section = ""
    if existing_tags:
        existing_tags_section = (
            f"\n\nExisting tags in the library: {existing_tags}. "
            "Reuse these tags verbatim when they match the content. "
            "Only introduce a new tag if no existing one fits."
        )

    prompt = f"""You are helping a user organize their personal knowledge library.

URL: {raw.url}
Content type: {raw.content_type}
Raw title: {raw.raw_title or "(none)"}
Content snippet:
{content_snippet or "(no content available)"}

Generate:
1. A clear, descriptive title (fix vague YouTube titles like "vlog #47" by using context)
2. A 2-3 sentence summary of what this content is about
3. 5-8 relevant tags (lowercase, hyphenated if needed, e.g. "machine-learning", "productivity"){existing_tags_section}

Be concise and informative. If the content is in Arabic or another language, keep the title and summary in the same language."""

    return structured.invoke(prompt)
