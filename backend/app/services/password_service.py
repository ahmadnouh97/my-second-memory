import bcrypt

from app.config import settings

# Pre-computed hash used to prevent timing attacks on unknown emails.
# verify_password against this will always return False but takes the same
# time as a real bcrypt check, so callers cannot distinguish "no such user"
# from "wrong password" by timing the response.
DUMMY_HASH = "$2b$12$EixZaYVK1fsbw1ZfbX3OXePaWxn96p36WQoeG6Lruj3vjPGga31lW"


def hash_password(plain: str) -> str:
    if len(plain.encode("utf-8")) > 72:
        raise ValueError("Password exceeds 72 bytes (bcrypt limit)")
    salt = bcrypt.gensalt(rounds=settings.bcrypt_rounds)
    return bcrypt.hashpw(plain.encode("utf-8"), salt).decode("utf-8")


def verify_password(plain: str, hashed: str) -> bool:
    try:
        return bcrypt.checkpw(plain.encode("utf-8"), hashed.encode("utf-8"))
    except Exception:
        return False
