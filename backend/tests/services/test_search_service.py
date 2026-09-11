import asyncio
import uuid
from types import SimpleNamespace
from unittest.mock import AsyncMock

import httpx
import pytest
from sqlalchemy.dialects import postgresql

from app.errors import RateLimitError
from app.repositories.item_repository import ItemRepository
from app.services import search_service


def item(id, content_type="other", tags=()):
    return SimpleNamespace(id=id, content_type=content_type, tags=list(tags))


@pytest.fixture
def encode(monkeypatch):
    mock = AsyncMock(return_value=[0.1, 0.2])
    monkeypatch.setattr(search_service.embedding_service, "encode", mock)
    return mock


def test_rrf_rewards_agreement_and_deduplicates(encode):
    a, b, shared = item("a"), item("b"), item("shared")
    repo = SimpleNamespace(
        vector_search=AsyncMock(return_value=[(a, 0.99), (shared, 0.7)]),
        fulltext_search=AsyncMock(return_value=[(b, 50), (shared, 2)]),
    )
    results = asyncio.run(search_service.hybrid_search(repo, "query", uuid.uuid4()))
    assert [i.id for i in results] == ["shared", "a", "b"]


def test_filters_are_applied_before_candidate_limit(encode):
    rows = [item(str(i), "youtube") for i in range(10)] + [item("match", tags=["ai"])]

    async def retrieve(*args, limit, tags, content_type, user_id):
        filtered = [i for i in rows if i.content_type == content_type and set(i.tags) & set(tags)]
        return [(i, 1.0) for i in filtered[:limit]]

    repo = SimpleNamespace(vector_search=retrieve, fulltext_search=retrieve)
    result = asyncio.run(search_service.hybrid_search(
        repo, "query", uuid.uuid4(), tags=["ai"], content_type="other", limit=2,
    ))
    assert [i.id for i in result] == ["match"]


@pytest.mark.parametrize("error", [
    RateLimitError(service="embedding"),
    httpx.ConnectError("offline"),
    httpx.ReadTimeout("timeout"),
    TimeoutError(),
])
def test_provider_failure_returns_filtered_lexical_results(encode, error):
    encode.side_effect = error
    user_id = uuid.uuid4()
    repo = SimpleNamespace(
        vector_search=AsyncMock(),
        fulltext_search=AsyncMock(return_value=[(item("a"), 1), (item("b"), 0.5)]),
    )
    results = asyncio.run(search_service.hybrid_search(
        repo, "query", user_id, tags=["ai"], content_type="other", limit=1,
    ))
    assert [i.id for i in results] == ["a"]
    repo.vector_search.assert_not_called()
    repo.fulltext_search.assert_awaited_once_with(
        "query", limit=2, user_id=user_id, tags=["ai"], content_type="other",
    )


def test_programming_errors_are_not_hidden_as_provider_outages(encode):
    encode.side_effect = ValueError("bad embedding")
    repo = SimpleNamespace(fulltext_search=AsyncMock(return_value=[]))
    with pytest.raises(ValueError, match="bad embedding"):
        asyncio.run(search_service.hybrid_search(repo, "query", uuid.uuid4()))


def test_empty_library(encode):
    repo = SimpleNamespace(
        vector_search=AsyncMock(return_value=[]),
        fulltext_search=AsyncMock(return_value=[]),
    )
    assert asyncio.run(search_service.hybrid_search(repo, "query", uuid.uuid4())) == []


@pytest.mark.parametrize("method,query", [("vector_search", [0.1, 0.2]), ("fulltext_search", "AI")])
def test_repository_query_contains_ownership_and_filters(method, query):
    # Inspect the SQL actually submitted by the repository, including bound values.
    db = SimpleNamespace(execute=AsyncMock(return_value=SimpleNamespace(all=lambda: [])))
    user_id = uuid.uuid4()
    asyncio.run(getattr(ItemRepository(db), method)(
        query, user_id, limit=6, tags=["ai"], content_type="youtube",
    ))
    statement = db.execute.call_args.args[0]
    compiled = statement.compile(dialect=postgresql.dialect())
    sql = str(compiled)
    assert "items.user_id =" in sql
    assert "items.tags &&" in sql
    assert "items.content_type =" in sql
    assert "LIMIT" in sql
    assert user_id in compiled.params.values()
    assert ["ai"] in compiled.params.values()
    assert "youtube" in compiled.params.values()
    assert 6 in compiled.params.values()
