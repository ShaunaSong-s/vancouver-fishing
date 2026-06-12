from fastapi import APIRouter
import httpx

router = APIRouter()

ENVIRONMENT_CANADA_URL = "https://api.weather.gc.ca/collections/hydrometric-daily-mean/items"


@router.get("")
async def get_weather(lat: float = 49.15, lon: float = -123.75):
    """Get current weather conditions for a location in Georgia Strait."""
    # In production, this calls Environment Canada API
    # For now, return structured mock data
    return {
        "temperature": 12.5,
        "wind_speed": 15.0,
        "wind_direction": "NW",
        "wind_gust": 22.0,
        "wave_height": 0.8,
        "visibility": "Good",
        "description": "多云，西北风15节，浪高0.8米，适合出海",
        "sunrise": "05:45",
        "sunset": "20:30",
        "uv_index": 5,
        "marine_forecast": "Georgia Strait: Wind northwest 15 knots. Seas 0.5 to 1.0 metres."
    }
