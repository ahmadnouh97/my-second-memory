from typing import Literal

ERROR_TYPE_RATE_LIMIT = "rate_limit"


def extract_groq_retry_after(exc: Exception) -> int | None:
    """Extract retry-after seconds from a Groq rate limit exception."""
    try:
        raw = exc.response.headers.get("retry-after")  # type: ignore[union-attr]
        return int(raw) if raw else None
    except (AttributeError, TypeError, ValueError):
        return None


class RateLimitError(Exception):
    def __init__(
        self,
        *,
        service: Literal["llm", "embedding"],
        retry_after: int | None = None,
        message: str = "Rate limit exceeded",
    ) -> None:
        super().__init__(message)
        self.service = service
        self.retry_after = retry_after
        self.message = message
