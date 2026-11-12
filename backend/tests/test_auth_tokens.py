import asyncio
import uuid
from datetime import datetime, timedelta, timezone
from types import SimpleNamespace
from unittest.mock import AsyncMock

import jwt
import pytest
from fastapi import HTTPException
from fastapi.security import HTTPAuthorizationCredentials

from app import auth


def test_existing_hs256_token_and_invalid_tokens(monkeypatch):
    user = SimpleNamespace(id=uuid.uuid4(), email="user@example.com")
    monkeypatch.setattr(auth.settings, "jwt_secret", "test-secret-for-token-verification-123")
    monkeypatch.setattr(auth, "UserRepository", lambda db: SimpleNamespace(get_by_id=AsyncMock(return_value=user)))
    token = auth.create_access_token(user)
    credentials = lambda value: HTTPAuthorizationCredentials(scheme="Bearer", credentials=value)
    assert asyncio.run(auth.get_current_user(credentials(token), None)) is user
    expired = jwt.encode({"sub": str(user.id), "exp": datetime.now(timezone.utc) - timedelta(seconds=1)}, auth.settings.jwt_secret, algorithm="HS256")
    for value in (expired, token + "invalid"):
        with pytest.raises(HTTPException) as exc:
            asyncio.run(auth.get_current_user(credentials(value), None))
        assert exc.value.status_code == 401
