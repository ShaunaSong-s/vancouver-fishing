import Foundation

struct FishingSpot: Identifiable, Codable {
    let id: String
    let name: String
    let latitude: Double
    let longitude: Double
    let dfoArea: String
    let targetSpecies: [String]
    let bestConditions: String
    let recommendedGear: String
    let isRestricted: Bool
    let restrictionNote: String?
    
    static let defaultSpots: [FishingSpot] = [
        FishingSpot(
            id: "bowen_island",
            name: "Bowen Island",
            latitude: 49.3833,
            longitude: -123.3333,
            dfoArea: "28",
            targetSpecies: ["Chinook Salmon", "Coho Salmon", "Lingcod"],
            bestConditions: "潮汐转换时段，清晨或傍晚最佳",
            recommendedGear: "Downrigger, Flasher + Hoochie, 20-60ft深度",
            isRestricted: false,
            restrictionNote: nil
        ),
        FishingSpot(
            id: "thrasher_rock",
            name: "Thrasher Rock",
            latitude: 49.0900,
            longitude: -123.7100,
            dfoArea: "29",
            targetSpecies: ["Chinook Salmon", "Halibut"],
            bestConditions: "退潮时最佳，需注意海流较强",
            recommendedGear: "Heavy tackle, 100-200ft深度钓比目鱼",
            isRestricted: false,
            restrictionNote: nil
        ),
        FishingSpot(
            id: "point_atkinson",
            name: "Point Atkinson",
            latitude: 49.3306,
            longitude: -123.2636,
            dfoArea: "28",
            targetSpecies: ["Chinook Salmon", "Coho Salmon"],
            bestConditions: "涨潮早期，配合bait ball出现",
            recommendedGear: "Mooching setup, Cut plug herring",
            isRestricted: false,
            restrictionNote: nil
        ),
        FishingSpot(
            id: "howe_sound_crab",
            name: "Howe Sound (蟹区)",
            latitude: 49.4000,
            longitude: -123.3000,
            dfoArea: "28",
            targetSpecies: ["Dungeness Crab", "Red Rock Crab"],
            bestConditions: "泥沙底，30-60ft深度",
            recommendedGear: "Crab trap, chicken/fish head作饵",
            isRestricted: false,
            restrictionNote: nil
        ),
        FishingSpot(
            id: "indian_arm_prawn",
            name: "Indian Arm (虾区)",
            latitude: 49.3600,
            longitude: -122.8800,
            dfoArea: "28",
            targetSpecies: ["Spot Prawn"],
            bestConditions: "300-500ft深度，5-6月最佳季节",
            recommendedGear: "Prawn trap, commercial pellets + fish oil",
            isRestricted: false,
            restrictionNote: nil
        ),
        FishingSpot(
            id: "area29_restricted",
            name: "Race Rocks",
            latitude: 48.2981,
            longitude: -123.5319,
            dfoArea: "19",
            targetSpecies: ["Rockfish"],
            bestConditions: "N/A - 禁渔区",
            recommendedGear: "N/A",
            isRestricted: true,
            restrictionNote: "Rockfish Conservation Area - 全年禁止捕捞底层鱼类"
        ),
        FishingSpot(
            id: "passage_island_rca",
            name: "Passage Island RCA",
            latitude: 49.3450,
            longitude: -123.3050,
            dfoArea: "28",
            targetSpecies: ["Rockfish"],
            bestConditions: "N/A - 禁渔区",
            recommendedGear: "N/A",
            isRestricted: true,
            restrictionNote: "Rockfish Conservation Area - 禁止rockfish捕捞，全年生效"
        ),
        FishingSpot(
            id: "howe_sound_sponge",
            name: "Howe Sound Sponge Reef",
            latitude: 49.4200,
            longitude: -123.2950,
            dfoArea: "28",
            targetSpecies: [],
            bestConditions: "N/A - 禁渔区",
            recommendedGear: "N/A",
            isRestricted: true,
            restrictionNote: "Glass Sponge Reef - 禁止锚泊及底部作业"
        ),
        FishingSpot(
            id: "halibut_bank_rca",
            name: "Halibut Bank RCA",
            latitude: 49.3400,
            longitude: -123.7300,
            dfoArea: "29",
            targetSpecies: ["Rockfish"],
            bestConditions: "N/A - 禁渔区",
            recommendedGear: "N/A",
            isRestricted: true,
            restrictionNote: "Rockfish Conservation Area - 禁止底钓"
        ),
        FishingSpot(
            id: "gabriola_rca",
            name: "Gabriola Island RCA",
            latitude: 49.1600,
            longitude: -123.7900,
            dfoArea: "29",
            targetSpecies: ["Rockfish", "Lingcod"],
            bestConditions: "N/A - 禁渔区",
            recommendedGear: "N/A",
            isRestricted: true,
            restrictionNote: "Rockfish Conservation Area - 禁止底钓及lingcod捕捞"
        ),
    ]
}
