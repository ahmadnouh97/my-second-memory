import csv
import io
import json

from app.models.item import Item


def export_as_json(items: list[Item]) -> str:
    """Serialize items to a JSON array string."""
    records = []
    for item in items:
        records.append({
            "id": str(item.id),
            "url": item.url,
            "title": item.title,
            "summary": item.summary,
            "content_type": item.content_type,
            "tags": item.tags,
            "thumbnail_url": item.thumbnail_url,
            "source_meta": item.source_meta,
            "created_at": item.created_at.isoformat(),
            "updated_at": item.updated_at.isoformat(),
        })
    return json.dumps(records, ensure_ascii=False, indent=2)


def export_as_csv(items: list[Item]) -> str:
    """Serialize items to a CSV string. Tags are pipe-separated; source_meta is JSON-encoded."""
    output = io.StringIO()
    fieldnames = [
        "id", "url", "title", "summary", "content_type",
        "tags", "thumbnail_url", "source_meta", "created_at", "updated_at",
    ]
    writer = csv.DictWriter(output, fieldnames=fieldnames)
    writer.writeheader()
    for item in items:
        writer.writerow({
            "id": str(item.id),
            "url": item.url,
            "title": item.title,
            "summary": item.summary or "",
            "content_type": item.content_type,
            "tags": "|".join(item.tags) if item.tags else "",
            "thumbnail_url": item.thumbnail_url or "",
            "source_meta": json.dumps(item.source_meta) if item.source_meta else "",
            "created_at": item.created_at.isoformat(),
            "updated_at": item.updated_at.isoformat(),
        })
    return output.getvalue()
