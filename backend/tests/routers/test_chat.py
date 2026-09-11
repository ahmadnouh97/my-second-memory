import asyncio
import json
import uuid
from types import SimpleNamespace
from unittest.mock import AsyncMock

import pytest
from langchain_core.messages import AIMessage, ToolMessage

from app.routers import chat

SAVED_ITEM = {
    "id": "saved-id", "title": "Actual title", "url": "https://example.com/source",
    "content_type": "other", "tags": ["ai"], "summary": "Saved summary",
    "created_at": "2026-01-01T00:00:00Z", "updated_at": "2026-01-01T00:00:00Z",
}


def test_cards_resolve_ids_and_ignore_invented_metadata():
    text = 'Answer. ITEMS_JSON: [{"id":"saved-id","url":"https://invented.invalid"}]'
    assert chat._resolve_item_references(text, {"saved-id": SAVED_ITEM}) == [SAVED_ITEM]


def test_unknown_and_duplicate_references_are_removed():
    text = 'ITEMS_JSON: [{"id":"other-user"},{"id":"saved-id"},{"id":"saved-id"},null,{"id":[]}]'
    assert chat._resolve_item_references(text, {"saved-id": SAVED_ITEM}) == [SAVED_ITEM]


@pytest.mark.parametrize("text", ["No results.", "ITEMS_JSON: broken", "ITEMS_JSON: [oops]", "ITEMS_JSON: []"])
def test_malformed_references_do_not_break_chat(text):
    assert chat._resolve_item_references(text, {}) == []


def test_tool_preamble_does_not_suppress_final_answer(monkeypatch):
    def tools(db, user_id, retrieved):
        retrieved["saved-id"] = SAVED_ITEM
        return []

    class Agent:
        async def astream(self, *args, **kwargs):
            yield {"messages": [AIMessage(content="Let me look.", tool_calls=[
                {"name": "search_items_tool", "args": {"query": "AI"}, "id": "call1"},
            ])]}
            yield {"messages": [ToolMessage(content="results", tool_call_id="call1", name="search_items_tool")]}
            yield {"messages": [AIMessage(content='Here is your source. ITEMS_JSON: [{"id":"saved-id"}]')]}

    monkeypatch.setattr(chat, "ChatGroq", lambda **kwargs: object())
    monkeypatch.setattr(chat, "make_tools", tools)
    monkeypatch.setattr(chat, "create_react_agent", lambda *args: Agent())

    async def collect():
        request = SimpleNamespace(is_disconnected=AsyncMock(return_value=False))
        return [event async for event in chat._stream_agent_response("AI", [], None, uuid.uuid4(), request)]

    events = asyncio.run(collect())
    payloads = [json.loads(e.removeprefix("data: ")) for e in events if "[DONE]" not in e]
    assert [p["type"] for p in payloads] == ["tool_start", "tool_end", "text", "items"]
    assert payloads[2]["content"].startswith("Here is your source.")
    assert payloads[3]["items"] == [SAVED_ITEM]
    assert events[-1] == "data: [DONE]\n\n"
