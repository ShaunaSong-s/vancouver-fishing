import Foundation
import MapKit

class FishingMapViewModel: ObservableObject {
    @Published var fishingSpots: [FishingSpot] = []
    @Published var selectedSpot: FishingSpot?
    @Published var selectedFilter: FishFilter? {
        didSet { applyFilter() }
    }
    
    private var allSpots: [FishingSpot] = []
    
    func loadFishingSpots(apiService: APIService) {
        Task { @MainActor in
            do {
                let spots = try await apiService.getFishingSpots()
                self.allSpots = spots
                self.fishingSpots = spots
            } catch {
                // Load default spots for offline use
                self.allSpots = FishingSpot.defaultSpots
                self.fishingSpots = FishingSpot.defaultSpots
            }
        }
    }
    
    private func applyFilter() {
        guard let filter = selectedFilter else {
            fishingSpots = allSpots
            return
        }
        
        switch filter {
        case .restricted:
            fishingSpots = allSpots.filter { $0.isRestricted }
        default:
            fishingSpots = allSpots.filter { spot in
                spot.targetSpecies.contains { $0.lowercased().contains(filter.rawValue.lowercased()) }
            }
        }
    }
}

enum FishFilter: String {
    case salmon = "salmon"
    case halibut = "halibut"
    case crab = "crab"
    case prawn = "prawn"
    case rockfish = "rockfish"
    case restricted = "restricted"
}
