# Demo and retrieval evaluation

These eight notes are **synthetic examples**, authored for this project. Their `example.com` URLs identify fixtures and do not point to real articles or videos. Labels in `search-eval.json` are manually assigned expected results, not model-generated judgments.

## Three-minute walkthrough

1. Start the app using the root README and sign in to a dedicated test account.
2. Import `demo-library.json` using the library's JSON import action. Wait for all eight entries to import; this step calls the configured embedding API.
3. Search “Why does fetching a web page freeze my Python API?” and inspect the matching note. Try filtering “cosine similarity database” to GitHub entries.
4. Ask chat “Find my notes about evaluating retrieval.” Inspect the returned item cards, then edit a note's tags and search again.

Use screenshots or a short screen recording of this flow in a portfolio. Describe the fixture as synthetic in captions. Test an unsupported question too: current prompting asks the assistant to acknowledge insufficient evidence, but abstention is not yet enforced or measured by this benchmark.

## Run the benchmark

Use a dedicated account containing only the fixture so unrelated items do not affect the comparison. Obtain that account's `access_token` through `POST /api/auth/login` in the local Swagger UI at `http://localhost:8001/docs`. Keep it out of committed files and recordings.

PowerShell, from the repository root:

```powershell
$env:SECOND_MEMORY_TOKEN = '<test-account-access-token>'
python backend/scripts/evaluate_search.py --base-url http://localhost:8001 --k 5
Remove-Item Env:SECOND_MEMORY_TOKEN
```

Bash:

```bash
export SECOND_MEMORY_TOKEN='<test-account-access-token>'
python3 backend/scripts/evaluate_search.py --base-url http://localhost:8001 --k 5
unset SECOND_MEMORY_TOKEN
```

The runner uses Python's standard library and makes authenticated **GET requests only**. It does not create accounts, import items, or modify the database. Searches call the configured embedding API and may consume quota. For a remote API, use HTTPS.

Output includes per-query returned URLs, Recall@k, reciprocal rank, latency, and aggregate Recall@k, MRR@k, and median latency. API failures stop the run with a nonzero exit code; they are not counted as successful queries. Provider fallback is logged by the server, so record whether fallback occurred when comparing runs.

## Interpret results honestly

- This is a small retrieval smoke benchmark, not a representative accuracy study. It does not measure answer faithfulness, citation support, or unanswerable queries.
- Record the commit, embedding model, database index configuration, corpus, and whether the run was cold or warm. Keep them fixed when comparing code changes.
- Review per-query failures. Expand the labels with realistic questions before making broader claims.
- Unit tests verify the metric calculations with controlled rankings; **no live benchmark score has been published**.

## Resume wording supported by the implementation

Choose the angle that matches the role; add measured scale or improvements only after collecting them.

- **AI Engineer:** Built a self-hosted knowledge-curation application with FastAPI, PostgreSQL/pgvector, and Flutter, integrating structured LLM enrichment, hybrid retrieval, and a tool-using assistant.
- **LLM / RAG Engineer:** Implemented semantic and full-text retrieval with Reciprocal Rank Fusion, query/document embedding task types, provider-failure fallback, and server-validated chat references.
- **Applied ML Engineer:** Added labeled retrieval fixtures and a reproducible Recall@k/MRR evaluation runner, with regression tests for ranking, filtering, and model-provider failure behavior.
