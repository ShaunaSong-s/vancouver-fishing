from fastapi import APIRouter
import httpx

router = APIRouter()

# DFO Integrated Water Level System API
DFO_TIDES_URL = "https://api-iwls.dfo-mpo.gc.ca/api/v1"

# Key stations for Georgia Strait
STATIONS = {
    "point_atkinson": "7795",
    "vancouver": "7735",
    "tsawwassen": "7590",
    "nanaimo": "7917",
}


@router.get("")
async def get_tides(station: str = "point_atkinson"):
    """Get tide predictions for a station."""
    station_id = STATIONS.get(station, STATIONS["point_atkinson"])
    
    # In production, call DFO API:
    # async with httpx.AsyncClient() as client:
    #     resp = await client.get(f"{DFO_TIDES_URL}/stations/{station_id}/data")
    
    # Mock response for development
    return {
        "station": station,
        "station_id": station_id,
        "predictions": [
            {"time": "03:22", "height": 4.8, "type": "high"},
            {"time": "09:45", "height": 1.2, "type": "low"},
            {"time": "15:58", "height": 4.1, "type": "high"},
            {"time": "22:10", "height": 0.8, "type": "low"},
        ],
        "current_height": 3.2,
        "next_event": {"time": "09:45", "height": 1.2, "type": "low"},
        "tidal_range": "Large (4.0m)",
    }
