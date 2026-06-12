import math
from typing import Tuple


class RouteOptimizer:
    """Calculates optimal fishing routes minimizing fuel consumption.
    
    Uses simple distance-based optimization with activity sequencing.
    In production, this would incorporate current/wind data for more accuracy.
    """

    # Average fuel consumption: liters per nautical mile at cruise speed
    # Approximation: HP * 0.1 gallons/hour, converted based on speed
    FUEL_PRICE_CAD_PER_LITER = 2.20  # Marina diesel price

    # Known fishing/crabbing/prawning spots with coordinates
    FISHING_SPOTS = [
        {"name": "Bowen Island", "lat": 49.3833, "lon": -123.3333, "type": "fishing"},
        {"name": "Point Atkinson", "lat": 49.3306, "lon": -123.2636, "type": "fishing"},
        {"name": "Sand Heads", "lat": 49.1083, "lon": -123.3000, "type": "fishing"},
        {"name": "Thrasher Rock", "lat": 49.0900, "lon": -123.7100, "type": "fishing"},
        {"name": "Five Finger Island", "lat": 49.4500, "lon": -123.3700, "type": "fishing"},
    ]

    CRAB_SPOTS = [
        {"name": "Howe Sound Crab Ground", "lat": 49.4000, "lon": -123.3000, "type": "crabbing"},
        {"name": "Deep Cove Flats", "lat": 49.3300, "lon": -122.9500, "type": "crabbing"},
        {"name": "Burrard Inlet", "lat": 49.3100, "lon": -123.1000, "type": "crabbing"},
    ]

    PRAWN_SPOTS = [
        {"name": "Indian Arm Deep", "lat": 49.3600, "lon": -122.8800, "type": "prawning"},
        {"name": "Howe Sound Deep", "lat": 49.4200, "lon": -123.3200, "type": "prawning"},
    ]

    def calculate(
        self,
        departure: Tuple[float, float],
        engine_hp: int,
        fuel_capacity_l: float,
        cruise_speed_knots: float,
        wants_fishing: bool,
        wants_crabbing: bool,
        wants_prawning: bool,
    ) -> dict:
        """Calculate optimal route."""
        # Gather target spots
        targets = []
        if wants_fishing:
            targets.extend(self.FISHING_SPOTS[:2])  # Pick 2 closest fishing spots
        if wants_crabbing:
            targets.extend(self.CRAB_SPOTS[:1])
        if wants_prawning:
            targets.extend(self.PRAWN_SPOTS[:1])

        if not targets:
            targets = self.FISHING_SPOTS[:1]

        # Sort by distance from departure (greedy nearest neighbor)
        sorted_targets = self._nearest_neighbor_sort(departure, targets)

        # Calculate route metrics
        total_distance = 0.0
        waypoints = []
        current_pos = departure

        for spot in sorted_targets:
            dist = self._haversine_nm(current_pos, (spot["lat"], spot["lon"]))
            total_distance += dist
            current_pos = (spot["lat"], spot["lon"])
            waypoints.append({
                "name": spot["name"],
                "latitude": spot["lat"],
                "longitude": spot["lon"],
                "activity": self._get_activity_label(spot["type"]),
            })

        # Add return trip
        return_dist = self._haversine_nm(current_pos, departure)
        total_distance += return_dist

        # Fuel calculation
        # Rough formula: fuel_rate (L/hr) ≈ HP * 0.1 * 3.785 / cruise_speed * distance
        fuel_rate_lph = engine_hp * 0.06  # L/hour at cruise
        time_hours = total_distance / cruise_speed_knots
        estimated_fuel = fuel_rate_lph * time_hours
        estimated_cost = estimated_fuel * self.FUEL_PRICE_CAD_PER_LITER

        return {
            "total_distance_nm": round(total_distance, 1),
            "estimated_fuel_l": round(estimated_fuel, 1),
            "estimated_cost_cad": round(estimated_cost, 2),
            "estimated_time_hours": round(time_hours + len(sorted_targets) * 1.5, 1),  # Add fishing time
            "waypoints": waypoints,
        }

    def _nearest_neighbor_sort(self, start: Tuple[float, float], spots: list) -> list:
        """Sort spots by nearest neighbor heuristic."""
        remaining = spots.copy()
        sorted_spots = []
        current = start

        while remaining:
            nearest = min(remaining, key=lambda s: self._haversine_nm(current, (s["lat"], s["lon"])))
            sorted_spots.append(nearest)
            current = (nearest["lat"], nearest["lon"])
            remaining.remove(nearest)

        return sorted_spots

    def _haversine_nm(self, pos1: Tuple[float, float], pos2: Tuple[float, float]) -> float:
        """Calculate distance in nautical miles between two lat/lon points."""
        lat1, lon1 = math.radians(pos1[0]), math.radians(pos1[1])
        lat2, lon2 = math.radians(pos2[0]), math.radians(pos2[1])

        dlat = lat2 - lat1
        dlon = lon2 - lon1

        a = math.sin(dlat / 2) ** 2 + math.cos(lat1) * math.cos(lat2) * math.sin(dlon / 2) ** 2
        c = 2 * math.asin(math.sqrt(a))

        # Earth radius in nautical miles
        r = 3440.065
        return r * c

    def _get_activity_label(self, activity_type: str) -> str:
        labels = {
            "fishing": "🎣 钓鱼",
            "crabbing": "🦀 抓蟹",
            "prawning": "🦐 抓虾",
        }
        return labels.get(activity_type, "钓鱼")
