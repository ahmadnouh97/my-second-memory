from collections.abc import Iterable


def is_email_allowed(email: str, patterns: Iterable[str]) -> bool:
    """Return True if email matches any pattern in the whitelist.

    Patterns:
      "*"           — allow any email
      "*@domain"    — allow any email whose domain matches exactly
      "user@domain" — exact match (case-insensitive)

    Empty patterns → False (fail-closed).
    """
    normalized = email.lower().strip()
    for pattern in patterns:
        p = pattern.lower().strip()
        if not p:
            continue
        if p == "*":
            return True
        if p.startswith("*@"):
            domain = p[2:]
            if normalized.endswith("@" + domain):
                return True
        elif normalized == p:
            return True
    return False
