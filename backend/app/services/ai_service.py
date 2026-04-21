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


def _format_duration(seconds: int | None) -> str | None:
    if not seconds:
        return None
    m, s = divmod(int(seconds), 60)
    h, m = divmod(m, 60)
    return f"{h}h {m}m {s}s" if h else f"{m}m {s}s"


def _format_views(count: int | None) -> str | None:
    if count is None:
        return None
    if count >= 1_000_000:
        return f"{count / 1_000_000:.1f}M views"
    if count >= 1_000:
        return f"{count / 1_000:.1f}K views"
    return f"{count} views"


def _format_date(yyyymmdd: str | None) -> str | None:
    if not yyyymmdd or len(yyyymmdd) != 8:
        return None
    return f"{yyyymmdd[:4]}-{yyyymmdd[4:6]}-{yyyymmdd[6:]}"


def _build_extra_section(extra: dict) -> str:
    lines = []
    if uploader := extra.get("uploader"):
        lines.append(f"Creator/Uploader: {uploader}")
    if duration := _format_duration(extra.get("duration")):
        lines.append(f"Duration: {duration}")
    if views := _format_views(extra.get("view_count")):
        lines.append(f"Views: {views}")
    if date := _format_date(extra.get("upload_date")):
        lines.append(f"Published: {date}")
    if platform_tags := extra.get("tags", []):
        lines.append(f"Platform tags: {', '.join(platform_tags[:10])}")
    if not lines:
        return ""
    return "\nExtra metadata:\n" + "\n".join(lines)


def _normalize_tags(tags: list[str]) -> list[str]:
    seen: set[str] = set()
    result: list[str] = []
    for tag in tags:
        normalized = tag.lower().strip().replace(" ", "-")
        if normalized and normalized not in seen:
            seen.add(normalized)
            result.append(normalized)
        if len(result) == 8:
            break
    return result


def enrich_metadata(raw: RawMetadata, existing_tags: list[str] | None = None) -> EnrichedMetadata:
    """Use LLM to generate a refined title, summary, and tags from raw metadata."""
    llm = _get_llm()
    structured = llm.with_structured_output(EnrichedMetadata)

    content_snippet = ""
    if raw.content:
        content_snippet = raw.content[:1500]
    elif raw.description:
        content_snippet = raw.description[:1500]

    extra_section = _build_extra_section(raw.extra) if raw.extra else ""

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
{extra_section}

## Rules

### Title
If the raw title is vague, clickbait, serial (e.g. "vlog #47", "Episode 12", "My Story"), or non-descriptive, \
generate a descriptive title from the content and metadata. Otherwise keep it with minor cleanup only \
(fix capitalization, strip "| Channel Name" suffixes). Max 100 characters.

### Summary
Be specific — name the creator, topic, technologies, people, or events discussed. \
Never write generic summaries like "This video explains X" or "This article discusses Y." \
2–3 sentences.

### Tags
Categorical, reusable, lowercase-hyphenated. Prefer broader topic categories over ultra-specific phrases. \
5–8 tags total.

## Examples

BAD title:  "I tried this for 30 days"
GOOD title: "30-Day No-Sugar Diet: Results, Challenges, and What Changed"

BAD summary: "This video is about machine learning basics."
GOOD summary: "Andrej Karpathy walks through building a GPT-2 model from scratch in PyTorch, \
covering attention mechanisms, tokenization, and training on a single GPU. \
The video targets practitioners with intermediate Python experience."

BAD tags:  ["video", "youtube", "content", "interesting", "2024"]
GOOD tags: ["machine-learning", "pytorch", "transformers", "deep-learning", "nlp"]
{existing_tags_section}

If the content is in Arabic or another language, keep the title and summary in that same language."""

    enriched = structured.invoke(prompt)
    return EnrichedMetadata(
        title=enriched.title,
        summary=enriched.summary,
        tags=_normalize_tags(enriched.tags),
    )
