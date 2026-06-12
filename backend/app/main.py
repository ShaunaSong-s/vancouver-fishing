from fastapi import FastAPI, Cookie
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from fastapi.responses import FileResponse, RedirectResponse
from dotenv import load_dotenv

from app.api import chat, spots, route, weather, tides, admin, invoices, auth

load_dotenv()

app = FastAPI(
    title="Vancouver Fishing Assistant API",
    description="AI-powered fishing assistant for Georgia Strait",
    version="1.0.0"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Configure properly in production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# API Routes
app.include_router(chat.router, prefix="/api/v1/chat", tags=["Chat"])
app.include_router(spots.router, prefix="/api/v1/spots", tags=["Fishing Spots"])
app.include_router(route.router, prefix="/api/v1/route", tags=["Route Planning"])
app.include_router(weather.router, prefix="/api/v1/weather", tags=["Weather"])
app.include_router(tides.router, prefix="/api/v1/tides", tags=["Tides"])
app.include_router(admin.router, prefix="/api/v1/admin", tags=["Admin"])
app.include_router(invoices.router, prefix="/api/v1/admin", tags=["Invoices"])
app.include_router(auth.router, prefix="/api/v1/auth", tags=["Auth"])


@app.get("/health")
async def health_check():
    return {"status": "healthy", "service": "fishing-assistant"}


@app.get("/admin")
async def admin_page(session_token: str = Cookie(default=None)):
    from app.services.auth import verify_session
    if not verify_session(session_token):
        return RedirectResponse(url="/login")
    return FileResponse("app/static/admin.html")


@app.get("/login")
async def login_page():
    return FileResponse("app/static/login.html")


app.mount("/static", StaticFiles(directory="app/static"), name="static")
