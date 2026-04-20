import json
from datetime import datetime, timedelta, timezone

import bcrypt
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from jose import JWTError, jwt

from app.config import settings

_bearer = HTTPBearer(auto_error=False)


def _load_users() -> list[dict]:
    try:
        return json.loads(settings.auth_users)
    except (json.JSONDecodeError, ValueError):
        return []


def authenticate_user(username: str, password: str) -> bool:
    for user in _load_users():
        if user.get("username") == username:
            stored = user.get("password", "")
            try:
                return bcrypt.checkpw(password.encode(), stored.encode())
            except Exception:
                return False
    return False


def create_access_token(username: str) -> str:
    expire = datetime.now(timezone.utc) + timedelta(minutes=settings.jwt_expire_minutes)
    return jwt.encode({"sub": username, "exp": expire}, settings.jwt_secret, algorithm="HS256")


async def get_current_user(
    credentials: HTTPAuthorizationCredentials | None = Depends(_bearer),
) -> str:
    exc = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Invalid or expired token",
        headers={"WWW-Authenticate": "Bearer"},
    )
    if not credentials:
        raise exc
    try:
        payload = jwt.decode(
            credentials.credentials, settings.jwt_secret, algorithms=["HS256"]
        )
        username: str | None = payload.get("sub")
        if not username:
            raise exc
        return username
    except JWTError:
        raise exc
