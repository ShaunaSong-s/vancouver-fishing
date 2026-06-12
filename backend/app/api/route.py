from typing import List
from fastapi import APIRouter
from pydantic import BaseModel
from app.services.route_optimizer import RouteOptimizer

router = APIRouter()
optimizer = RouteOptimizer()


class RouteRequest(BaseModel):
    departure_latitude: float
    departure_longitude: float
    engine_hp: int = 150
    fuel_capacity_l: float = 200.0
    cruise_speed_knots: float = 20.0
    wants_fishing: bool = True
    wants_crabbing: bool = False
    wants_prawning: bool = False


class Waypoint(BaseModel):
    name: str
    latitude: float
    longitude: float
    activity: str


class RouteResponse(BaseModel):
    total_distance_nm: float
    estimated_fuel_l: float
    estimated_cost_cad: float
    estimated_time_hours: float
    waypoints: List[Waypoint]


@router.post("/calculate", response_model=RouteResponse)
async def calculate_route(request: RouteRequest):
    """Calculate optimal fishing route based on departure point and activities."""
    result = optimizer.calculate(
        departure=(request.departure_latitude, request.departure_longitude),
        engine_hp=request.engine_hp,
        fuel_capacity_l=request.fuel_capacity_l,
        cruise_speed_knots=request.cruise_speed_knots,
        wants_fishing=request.wants_fishing,
        wants_crabbing=request.wants_crabbing,
        wants_prawning=request.wants_prawning,
    )
    return RouteResponse(**result)
