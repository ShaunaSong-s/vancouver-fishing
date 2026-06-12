from typing import Optional
from fastapi import APIRouter
from app.models.fishing_spot import FishingSpotModel

router = APIRouter()


@router.get("")
async def get_fishing_spots(species: Optional[str] = None, area: Optional[str] = None):
    """Get fishing spots, optionally filtered by species or DFO area."""
    spots = FishingSpotModel.get_all()
    
    if species:
        spots = [s for s in spots if any(species.lower() in sp.lower() for sp in s["target_species"])]
    if area:
        spots = [s for s in spots if s["dfo_area"] == area]
    
    return spots


@router.get("/{spot_id}")
async def get_fishing_spot(spot_id: str):
    """Get a specific fishing spot by ID."""
    return FishingSpotModel.get_by_id(spot_id)
