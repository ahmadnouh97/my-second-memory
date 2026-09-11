"""Tests use dummy configuration and must never contact external services."""
import os
import urllib.request

import httpx
import pytest
import requests

os.environ.update(
    DATABASE_URL="postgresql+asyncpg://test:test@localhost/secondmemory_test",
    GROQ_API_KEY="test-groq-key",
    GOOGLE_API_KEY="test-google-key",
    JWT_SECRET="test-secret-not-for-deployment",
    APP_ENV="test",
)


@pytest.fixture(autouse=True)
def no_network(monkeypatch):
    def blocked(*args, **kwargs):
        raise AssertionError("External network calls are forbidden in unit tests")

    # Windows asyncio needs a loopback socketpair to start its event loop.
    # Block application HTTP transports rather than the loop's internal sockets.
    monkeypatch.setattr(httpx.Client, "send", blocked)
    monkeypatch.setattr(httpx.AsyncClient, "send", blocked)
    monkeypatch.setattr(requests.Session, "request", blocked)
    monkeypatch.setattr(urllib.request, "urlopen", blocked)
