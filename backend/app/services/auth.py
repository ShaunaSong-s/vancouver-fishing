"""Simple token-based auth for admin pages."""

import hashlib
import secrets
import time
from typing import Optional

from fastapi import Cookie, HTTPException, Response

# Admin credentials (in production, store hashed in DB)
ADMIN_USERNAME = "topfishing"
ADMIN_PASSWORD_HASH = hashlib.sha256("19931202".encode()).hexdigest()

# Active sessions: token -> expiry timestamp
_sessions: dict[str, float] = {}

SESSION_DURATION = 8 * 3600  # 8 hours


def verify_login(username: str, password: str) -> Optional[str]:
    """Verify credentials and return session token, or None if invalid."""
    pw_hash = hashlib.sha256(password.encode()).hexdigest()
    if username == ADMIN_USERNAME and pw_hash == ADMIN_PASSWORD_HASH:
        token = secrets.token_hex(32)
        _sessions[token] = time.time() + SESSION_DURATION
        return token
    return None


def verify_session(session_token: Optional[str] = None) -> bool:
    """Check if a session token is valid."""
    if not session_token:
        return False
    expiry = _sessions.get(session_token)
    if not expiry:
        return False
    if time.time() > expiry:
        _sessions.pop(session_token, None)
        return False
    return True


def logout(session_token: str):
    _sessions.pop(session_token, None)
