import pytest

from app.services.whitelist_service import is_email_allowed


@pytest.mark.parametrize(
    "email, patterns, expected",
    [
        # Empty list → deny
        ("alice@example.com", [], False),
        ("alice@example.com", [""], False),
        ("alice@example.com", [" "], False),
        # Universal wildcard
        ("alice@example.com", ["*"], True),
        ("anyone@anywhere.io", ["*"], True),
        # Exact match
        ("alice@example.com", ["alice@example.com"], True),
        ("alice@example.com", ["bob@example.com"], False),
        # Exact match is case-insensitive
        ("ALICE@EXAMPLE.COM", ["alice@example.com"], True),
        ("alice@example.com", ["ALICE@EXAMPLE.COM"], True),
        # Domain wildcard
        ("alice@company.com", ["*@company.com"], True),
        ("bob@company.com", ["*@company.com"], True),
        ("alice@other.com", ["*@company.com"], False),
        # Domain wildcard case-insensitive
        ("ALICE@COMPANY.COM", ["*@company.com"], True),
        ("alice@company.com", ["*@COMPANY.COM"], True),
        # Multiple patterns — first match wins
        ("alice@example.com", ["bob@example.com", "alice@example.com"], True),
        ("carol@other.com", ["*@example.com", "*@other.com"], True),
        # Whitespace around patterns is trimmed
        ("alice@example.com", [" alice@example.com "], True),
        ("alice@example.com", [" *@example.com "], True),
        # Malformed / partial patterns are skipped safely
        ("alice@example.com", ["*@"], False),
        ("alice@example.com", ["@example.com"], False),
    ],
)
def test_is_email_allowed(email: str, patterns: list[str], expected: bool) -> None:
    assert is_email_allowed(email, patterns) is expected
