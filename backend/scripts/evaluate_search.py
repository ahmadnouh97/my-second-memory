"""Evaluate ranked URLs from a running API. Uses GET requests only; no data changes."""
import argparse
import json
import os
import statistics
import sys
import time
from datetime import datetime, timezone
from pathlib import Path
from urllib.error import HTTPError, URLError
from urllib.parse import urlencode, urlparse
from urllib.request import Request, urlopen


def score(ranked_urls: list[str], relevant_urls: list[str], k: int) -> dict[str, float]:
    if k < 1 or not relevant_urls:
        raise ValueError("k and the relevance set must be nonempty")
    # Duplicate saves must not inflate recall or reciprocal rank.
    ranked = ranked_urls[:k]
    relevant = set(relevant_urls)
    hits = [position for position, url in enumerate(ranked, 1) if url in relevant]
    return {
        "recall": len(set(ranked) & relevant) / len(relevant),
        "reciprocal_rank": 1 / hits[0] if hits else 0.0,
    }


def evaluate(cases: list[dict], base_url: str, token: str, k: int) -> dict:
    if not cases:
        raise ValueError("The evaluation dataset is empty")
    results = []
    for case in cases:
        params = {"q": case["query"], "limit": k}
        params.update({key: case[key] for key in ("tags", "content_type") if key in case})
        request = Request(
            f"{base_url.rstrip('/')}/api/items/search?{urlencode(params, doseq=True)}",
            headers={"Authorization": f"Bearer {token}"},
        )
        start = time.perf_counter()
        with urlopen(request, timeout=60) as response:
            items = json.load(response)
        latency_ms = (time.perf_counter() - start) * 1000
        ranked = [item["url"] for item in items]
        results.append({
            "id": case["id"], "query": case["query"],
            **score(ranked, case["relevant_urls"], k),
            "latency_ms": round(latency_ms, 1), "returned_urls": ranked[:k],
        })
    return {
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "k": k, "query_count": len(results),
        "recall_at_k": statistics.mean(r["recall"] for r in results),
        "mrr_at_k": statistics.mean(r["reciprocal_rank"] for r in results),
        "median_latency_ms": statistics.median(r["latency_ms"] for r in results),
        "results": results,
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--base-url", default="http://localhost:8001")
    parser.add_argument("--dataset", type=Path, default=Path(__file__).resolve().parents[2] / "examples/search-eval.json")
    parser.add_argument("--k", type=int, default=5)
    args = parser.parse_args()
    token = os.environ.get("SECOND_MEMORY_TOKEN")
    if not token:
        parser.error("Set SECOND_MEMORY_TOKEN to a test account's access token")
    if not 1 <= args.k <= 50:
        parser.error("--k must be between 1 and 50")
    address = urlparse(args.base_url)
    if address.scheme not in ("http", "https") or not address.hostname:
        parser.error("--base-url must be an HTTP(S) URL")
    if address.scheme == "http" and address.hostname not in ("localhost", "127.0.0.1", "::1"):
        parser.error("Use HTTPS for a remote API so the access token is encrypted")
    try:
        cases = json.loads(args.dataset.read_text(encoding="utf-8"))
        report = evaluate(cases, args.base_url, token, args.k)
    except HTTPError as exc:
        print(f"Evaluation stopped: API returned HTTP {exc.code}. Check login and API availability.", file=sys.stderr)
        return 1
    except (URLError, OSError, ValueError, KeyError, TypeError) as exc:
        print(f"Evaluation stopped: {type(exc).__name__}. Check API availability and dataset format.", file=sys.stderr)
        return 1
    print(json.dumps(report, indent=2, ensure_ascii=False))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
