"""Auth API endpoints."""

from fastapi import APIRouter, Cookie, Response
from fastapi.responses import JSONResponse
from pydantic import BaseModel

from app.services.auth import verify_login, logout

router = APIRouter()


class LoginRequest(BaseModel):
    username: str
    password: str


@router.post("/login")
async def login(data: LoginRequest, response: Response):
    token = verify_login(data.username, data.password)
    if not token:
        return JSONResponse(status_code=401, content={"detail": "Invalid credentials"})
    response.set_cookie(key="session_token", value=token, httponly=True, max_age=8*3600)
    return {"status": "ok"}


@router.post("/logout")
async def logout_endpoint(response: Response, session_token: str = Cookie(default=None)):
    if session_token:
        logout(session_token)
    response.delete_cookie("session_token")
    return {"status": "ok"}
