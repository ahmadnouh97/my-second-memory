from collections.abc import Callable

from app.models.user import User
from app.repositories.user_repository import UserRepository
from app.services.password_service import DUMMY_HASH, hash_password, verify_password


class EmailAlreadyRegisteredError(Exception):
    pass


class InvalidCredentialsError(Exception):
    pass


class InvalidPasswordError(Exception):
    pass


class EmailNotWhitelistedError(Exception):
    pass


class UserService:
    def __init__(self, repo: UserRepository):
        self._repo = repo

    async def register(
        self,
        email: str,
        password: str,
        is_allowed: Callable[[str], bool] | None = None,
    ) -> User:
        normalized = email.lower().strip()
        if is_allowed is not None and not is_allowed(normalized):
            raise EmailNotWhitelistedError("Email not in whitelist")
        if await self._repo.email_exists(normalized):
            raise EmailAlreadyRegisteredError("Email already registered")
        return await self._repo.create(normalized, hash_password(password))

    async def authenticate(self, email: str, password: str) -> User:
        normalized = email.lower().strip()
        user = await self._repo.get_by_email(normalized)
        # Always run bcrypt to prevent timing-based user enumeration
        candidate_hash = user.password_hash if user else DUMMY_HASH
        if not verify_password(password, candidate_hash) or user is None:
            raise InvalidCredentialsError("Invalid credentials")
        return user

    async def update_profile(
        self,
        user: User,
        email: str | None = None,
        current_password: str | None = None,
        new_password: str | None = None,
    ) -> User:
        updates: dict = {}
        if email is not None:
            normalized = email.lower().strip()
            if normalized != user.email:
                if await self._repo.email_exists(normalized):
                    raise EmailAlreadyRegisteredError("Email already in use")
                updates["email"] = normalized
        if new_password is not None:
            if not current_password or not verify_password(current_password, user.password_hash):
                raise InvalidPasswordError("Current password is incorrect")
            updates["password_hash"] = hash_password(new_password)
        if not updates:
            return user
        updated = await self._repo.update(user.id, updates)
        return updated  # type: ignore[return-value]
