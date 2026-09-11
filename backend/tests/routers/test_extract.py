import asyncio
import threading
import uuid
from types import SimpleNamespace
from unittest.mock import AsyncMock

from app.routers import items
from app.schemas.item import ExtractRequest
from app.services.metadata_extractor import RawMetadata


def test_blocking_extraction_and_enrichment_run_off_the_event_loop(monkeypatch):
    event_loop_thread = threading.get_ident()
    worker_threads = []

    def extract(url):
        worker_threads.append(threading.get_ident())
        return RawMetadata(url=url, content_type="other", raw_title="Original")

    def enrich(raw, existing_tags):
        worker_threads.append(threading.get_ident())
        assert existing_tags == ["ai"]
        return SimpleNamespace(title="Refined", summary="Summary", tags=["ai"])

    monkeypatch.setattr(items, "extract_metadata", extract)
    monkeypatch.setattr(items, "enrich_metadata", enrich)
    db = SimpleNamespace(execute=AsyncMock(return_value=SimpleNamespace(
        all=lambda: [SimpleNamespace(tag="ai")],
    )))
    preview = asyncio.run(items.extract_url(
        ExtractRequest(url="https://example.com"), SimpleNamespace(id=uuid.uuid4()), db,
    ))
    assert preview.title == "Refined"
    assert len(worker_threads) == 2
    assert all(thread != event_loop_thread for thread in worker_threads)
