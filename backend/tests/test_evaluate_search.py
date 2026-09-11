import io
import json
from urllib.parse import parse_qs, urlparse

import pytest

from scripts import evaluate_search


def test_retrieval_metrics_with_partial_recall_and_second_rank_hit():
    assert evaluate_search.score(["wrong", "right", "right"], ["right", "missing"], 5) == {
        "recall": 0.5, "reciprocal_rank": 0.5,
    }


def test_cutoff_and_no_hits():
    assert evaluate_search.score(["wrong", "right"], ["right"], 1) == {
        "recall": 0.0, "reciprocal_rank": 0.0,
    }


@pytest.mark.parametrize("k,relevant", [(0, ["a"]), (5, [])])
def test_invalid_metric_inputs(k, relevant):
    with pytest.raises(ValueError):
        evaluate_search.score([], relevant, k)


def test_benchmark_uses_authenticated_filtered_get_requests(monkeypatch):
    def response(request, timeout):
        assert request.get_method() == "GET"
        assert request.get_header("Authorization") == "Bearer test-token"
        params = parse_qs(urlparse(request.full_url).query)
        assert params == {"q": ["AI search"], "tags": ["rag", "ai"], "content_type": ["other"], "limit": ["5"]}
        return io.StringIO(json.dumps([{"url": "wrong"}, {"url": "right"}]))

    monkeypatch.setattr(evaluate_search, "urlopen", response)
    report = evaluate_search.evaluate([
        {"id": "example", "query": "AI search", "tags": ["rag", "ai"], "content_type": "other", "relevant_urls": ["right"]},
    ], "http://localhost:8001", "test-token", 5)
    assert report["recall_at_k"] == 1
    assert report["mrr_at_k"] == 0.5
    assert report["query_count"] == 1
