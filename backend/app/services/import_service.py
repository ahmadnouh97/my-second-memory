import csv
import io
import json

from app.schemas.item import ItemCreate


def parse_json(content: str) -> tuple[list[ItemCreate], list[str]]:
    """Parse a JSON array of items into ItemCreate objects.

    Returns (valid_items, errors).
    """
    valid: list[ItemCreate] = []
    errors: list[str] = []

    try:
        records = json.loads(content)
    except json.JSONDecodeError as e:
        return [], [f"Invalid JSON: {e}"]

    if not isinstance(records, list):
        return [], ["JSON must be an array of items"]

    for i, record in enumerate(records):
        if not isinstance(record, dict):
            errors.append(f"Row {i + 1}: expected object, got {type(record).__name__}")
            continue
        try:
            item = ItemCreate(
                url=record.get("url", ""),
                title=record.get("title", ""),
                summary=record.get("summary") or None,
                content_type=record.get("content_type", "other"),
                tags=record.get("tags") or [],
                thumbnail_url=record.get("thumbnail_url") or None,
                content=record.get("content") or None,
                source_meta=record.get("source_meta") or None,
            )
            valid.append(item)
        except Exception as e:
            errors.append(f"Row {i + 1}: {e}")

    return valid, errors


def parse_csv(content: str) -> tuple[list[ItemCreate], list[str]]:
    """Parse a CSV string of items into ItemCreate objects.

    Tags are expected to be pipe-separated; source_meta as a JSON string.
    Returns (valid_items, errors).
    """
    valid: list[ItemCreate] = []
    errors: list[str] = []

    reader = csv.DictReader(io.StringIO(content))
    for i, row in enumerate(reader):
        try:
            tags_raw = row.get("tags", "").strip()
            tags = [t.strip() for t in tags_raw.split("|") if t.strip()] if tags_raw else []

            source_meta_raw = row.get("source_meta", "").strip()
            source_meta = json.loads(source_meta_raw) if source_meta_raw else None

            item = ItemCreate(
                url=row.get("url", "").strip(),
                title=row.get("title", "").strip(),
                summary=row.get("summary", "").strip() or None,
                content_type=row.get("content_type", "other").strip() or "other",
                tags=tags,
                thumbnail_url=row.get("thumbnail_url", "").strip() or None,
                content=None,
                source_meta=source_meta,
            )
            valid.append(item)
        except Exception as e:
            errors.append(f"Row {i + 1}: {e}")

    return valid, errors
