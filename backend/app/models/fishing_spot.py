from typing import Optional, List


class FishingSpotModel:
    """In-memory fishing spot data. In production, use PostgreSQL."""

    SPOTS = [
        {
            "id": "bowen_island",
            "name": "Bowen Island",
            "latitude": 49.3833,
            "longitude": -123.3333,
            "dfo_area": "28",
            "target_species": ["Chinook Salmon", "Coho Salmon", "Lingcod"],
            "best_conditions": "潮汐转换时段，清晨或傍晚最佳",
            "recommended_gear": "Downrigger, Flasher + Hoochie, 20-60ft深度",
            "is_restricted": False,
            "restriction_note": None,
        },
        {
            "id": "thrasher_rock",
            "name": "Thrasher Rock",
            "latitude": 49.0900,
            "longitude": -123.7100,
            "dfo_area": "29",
            "target_species": ["Chinook Salmon", "Halibut"],
            "best_conditions": "退潮时最佳，需注意海流较强",
            "recommended_gear": "Heavy tackle, 100-200ft深度钓比目鱼",
            "is_restricted": False,
            "restriction_note": None,
        },
        {
            "id": "point_atkinson",
            "name": "Point Atkinson",
            "latitude": 49.3306,
            "longitude": -123.2636,
            "dfo_area": "28",
            "target_species": ["Chinook Salmon", "Coho Salmon"],
            "best_conditions": "涨潮早期，配合bait ball出现",
            "recommended_gear": "Mooching setup, Cut plug herring",
            "is_restricted": False,
            "restriction_note": None,
        },
        {
            "id": "sand_heads",
            "name": "Sand Heads",
            "latitude": 49.1083,
            "longitude": -123.3000,
            "dfo_area": "29",
            "target_species": ["Chinook Salmon", "Sturgeon"],
            "best_conditions": "Fraser River出海口，夏季三文鱼大量聚集",
            "recommended_gear": "Trolling gear, large flasher",
            "is_restricted": False,
            "restriction_note": None,
        },
        {
            "id": "howe_sound_crab",
            "name": "Howe Sound (蟹区)",
            "latitude": 49.4000,
            "longitude": -123.3000,
            "dfo_area": "28",
            "target_species": ["Dungeness Crab", "Red Rock Crab"],
            "best_conditions": "泥沙底，30-60ft深度",
            "recommended_gear": "Crab trap, chicken/fish head作饵",
            "is_restricted": False,
            "restriction_note": None,
        },
        {
            "id": "indian_arm_prawn",
            "name": "Indian Arm (虾区)",
            "latitude": 49.3600,
            "longitude": -122.8800,
            "dfo_area": "28",
            "target_species": ["Spot Prawn"],
            "best_conditions": "300-500ft深度，5-6月最佳季节",
            "recommended_gear": "Prawn trap, commercial pellets + fish oil",
            "is_restricted": False,
            "restriction_note": None,
        },
        {
            "id": "race_rocks_rca",
            "name": "Race Rocks (禁渔区)",
            "latitude": 48.2981,
            "longitude": -123.5319,
            "dfo_area": "19",
            "target_species": ["Rockfish"],
            "best_conditions": "N/A - 禁渔区",
            "recommended_gear": "N/A",
            "is_restricted": True,
            "restriction_note": "Rockfish Conservation Area - 全年禁止捕捞底层鱼类",
        },
        {
            "id": "halibut_bank",
            "name": "Halibut Bank",
            "latitude": 49.3400,
            "longitude": -123.7300,
            "dfo_area": "29",
            "target_species": ["Halibut", "Lingcod"],
            "best_conditions": "潮汐平缓时，需要大船和重装备",
            "recommended_gear": "Heavy rod, 80lb braid, 16-32oz weight, herring/octopus",
            "is_restricted": False,
            "restriction_note": None,
        },
    ]

    @classmethod
    def get_all(cls) -> List[dict]:
        return cls.SPOTS

    @classmethod
    def get_by_id(cls, spot_id: str) -> Optional[dict]:
        for spot in cls.SPOTS:
            if spot["id"] == spot_id:
                return spot
        return None
