import Foundation
import CoreLocation
import SwiftUI

class RoutePlannerViewModel: ObservableObject {
    @Published var selectedRamp: BoatRamp?
    @Published var engineHP = "150"
    @Published var fuelCapacity = "200"
    @Published var cruiseSpeed = "20"
    @Published var wantsFishing = true
    @Published var wantsCrabbing = false
    @Published var wantsPrawning = false
    @Published var isCalculating = false
    @Published var routeResult: RouteResult?
    @Published var errorMessage: String?
    @Published var customWaypoints: [CustomWaypoint] = []
    
    // Map annotations computed from state
    var allAnnotations: [RouteAnnotation] {
        var annotations: [RouteAnnotation] = []
        
        // Departure ramp
        if let ramp = selectedRamp {
            annotations.append(RouteAnnotation(
                id: "departure_\(ramp.id)",
                name: ramp.name,
                coordinate: CLLocationCoordinate2D(latitude: ramp.latitude, longitude: ramp.longitude),
                color: .green,
                icon: "flag.fill",
                number: nil,
                size: 28,
                showLabel: true
            ))
        }
        
        // Custom waypoints (user-tapped)
        for (i, wp) in customWaypoints.enumerated() {
            annotations.append(RouteAnnotation(
                id: "custom_\(i)",
                name: wp.name,
                coordinate: CLLocationCoordinate2D(latitude: wp.lat, longitude: wp.lon),
                color: .purple,
                icon: "mappin",
                number: nil,
                size: 22,
                showLabel: true
            ))
        }
        
        // Route result waypoints
        if let result = routeResult {
            for (i, wp) in result.waypoints.enumerated() {
                annotations.append(RouteAnnotation(
                    id: "route_\(i)",
                    name: wp.name,
                    coordinate: CLLocationCoordinate2D(latitude: wp.latitude, longitude: wp.longitude),
                    color: .blue,
                    icon: "fish",
                    number: i + 1,
                    size: 26,
                    showLabel: true
                ))
            }
        }
        
        return annotations
    }
    
    func addCustomWaypoint(lat: Double, lon: Double) {
        let name = String(format: "📍 %.2f, %.2f", lat, lon)
        customWaypoints.append(CustomWaypoint(lat: lat, lon: lon, name: name))
    }
    
    func clearCustomWaypoints() {
        customWaypoints.removeAll()
    }
    
    let boatRamps: [BoatRamp] = [
        BoatRamp(id: "steveston", name: "Steveston (列治文)", latitude: 49.1244, longitude: -123.1868, description: "Richmond main dock"),
        BoatRamp(id: "horseshoe", name: "Horseshoe Bay (西温)", latitude: 49.3744, longitude: -123.2728, description: "West Vancouver ferry terminal area"),
        BoatRamp(id: "deep_cove", name: "Deep Cove (北温)", latitude: 49.3296, longitude: -122.9486, description: "North Vancouver"),
        BoatRamp(id: "belcarra", name: "Belcarra (高贵林港)", latitude: 49.3183, longitude: -122.9264, description: "Port Coquitlam area"),
        BoatRamp(id: "tsawwassen", name: "Tsawwassen (三角洲)", latitude: 49.0060, longitude: -123.0838, description: "Delta south"),
        BoatRamp(id: "white_rock", name: "White Rock (白石)", latitude: 49.0193, longitude: -122.8028, description: "South Surrey"),
    ]
    
    // Known fishing spots in Georgia Strait area
    private let fishingSpots: [RouteSpot] = [
        RouteSpot(name: "Bowen Island East", lat: 49.3833, lon: -123.3333, type: .fishing, depthFt: 80),
        RouteSpot(name: "Point Atkinson", lat: 49.3306, lon: -123.2636, type: .fishing, depthFt: 60),
        RouteSpot(name: "Sand Heads", lat: 49.1083, lon: -123.3000, type: .fishing, depthFt: 40),
        RouteSpot(name: "Thrasher Rock", lat: 49.0900, lon: -123.7100, type: .fishing, depthFt: 120),
        RouteSpot(name: "Five Finger Island", lat: 49.4500, lon: -123.3700, type: .fishing, depthFt: 100),
        RouteSpot(name: "T10 Buoy (Point Grey)", lat: 49.2600, lon: -123.2850, type: .fishing, depthFt: 90),
        RouteSpot(name: "Cowan Point (Bowen)", lat: 49.3650, lon: -123.3900, type: .fishing, depthFt: 150),
        RouteSpot(name: "Gabriola Pass", lat: 49.1300, lon: -123.7300, type: .fishing, depthFt: 70),
    ]
    
    private let crabSpots: [RouteSpot] = [
        RouteSpot(name: "Howe Sound - 蟹区", lat: 49.4000, lon: -123.3000, type: .crabbing, depthFt: 40),
        RouteSpot(name: "Deep Cove Flats - 蟹区", lat: 49.3300, lon: -122.9500, type: .crabbing, depthFt: 35),
        RouteSpot(name: "Burrard Inlet - 蟹区", lat: 49.3100, lon: -123.1000, type: .crabbing, depthFt: 30),
        RouteSpot(name: "Boundary Bay - 蟹区", lat: 49.0200, lon: -123.0200, type: .crabbing, depthFt: 25),
    ]
    
    private let prawnSpots: [RouteSpot] = [
        RouteSpot(name: "Indian Arm Deep - 虾区", lat: 49.3600, lon: -122.8800, type: .prawning, depthFt: 200),
        RouteSpot(name: "Howe Sound Deep - 虾区", lat: 49.4200, lon: -123.3200, type: .prawning, depthFt: 250),
        RouteSpot(name: "Defense Islands - 虾区", lat: 49.3450, lon: -122.9100, type: .prawning, depthFt: 180),
    ]
    
    func calculateRoute(apiService: APIService) {
        guard let ramp = selectedRamp else {
            errorMessage = "请选择出发码头"
            return
        }
        guard let hp = Int(engineHP), hp > 0 else {
            errorMessage = "请输入有效的马力"
            return
        }
        guard let fuel = Double(fuelCapacity), fuel > 0 else {
            errorMessage = "请输入有效的油箱容量"
            return
        }
        guard let speed = Double(cruiseSpeed), speed > 0 else {
            errorMessage = "请输入有效的巡航速度"
            return
        }
        
        errorMessage = nil
        isCalculating = true
        
        // Calculate locally for instant results
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [self] in
            self.routeResult = self.computeOptimalRoute(
                departure: (ramp.latitude, ramp.longitude),
                engineHP: hp,
                fuelCapacityL: fuel,
                cruiseSpeedKnots: speed
            )
            self.isCalculating = false
        }
    }
    
    // MARK: - Local Route Computation (Nearest Neighbor TSP)
    private func computeOptimalRoute(
        departure: (Double, Double),
        engineHP: Int,
        fuelCapacityL: Double,
        cruiseSpeedKnots: Double
    ) -> RouteResult {
        // Gather target spots based on selection
        var targets: [RouteSpot] = []
        
        // Include custom waypoints first (user-selected on map)
        for wp in customWaypoints {
            targets.append(RouteSpot(name: wp.name, lat: wp.lat, lon: wp.lon, type: .fishing, depthFt: 0))
        }
        
        // Then add auto-recommended spots if no custom waypoints
        if customWaypoints.isEmpty {
            if wantsFishing {
                let sorted = fishingSpots.sorted { a, b in
                    haversineNM(departure, (a.lat, a.lon)) < haversineNM(departure, (b.lat, b.lon))
                }
                targets.append(contentsOf: sorted.prefix(3))
            }
            if wantsCrabbing {
                let sorted = crabSpots.sorted { a, b in
                    haversineNM(departure, (a.lat, a.lon)) < haversineNM(departure, (b.lat, b.lon))
                }
                targets.append(contentsOf: sorted.prefix(1))
            }
            if wantsPrawning {
                let sorted = prawnSpots.sorted { a, b in
                    haversineNM(departure, (a.lat, a.lon)) < haversineNM(departure, (b.lat, b.lon))
                }
                targets.append(contentsOf: sorted.prefix(1))
            }
        } else {
            // Still add activity spots if toggled, but fewer
            if wantsCrabbing {
                let sorted = crabSpots.sorted { a, b in
                    haversineNM(departure, (a.lat, a.lon)) < haversineNM(departure, (b.lat, b.lon))
                }
                targets.append(contentsOf: sorted.prefix(1))
            }
            if wantsPrawning {
                let sorted = prawnSpots.sorted { a, b in
                    haversineNM(departure, (a.lat, a.lon)) < haversineNM(departure, (b.lat, b.lon))
                }
                targets.append(contentsOf: sorted.prefix(1))
            }
        }
        
        if targets.isEmpty {
            errorMessage = "请选择活动类型或在地图上添加途经点 / Select activities or add waypoints on map"
            return RouteResult(totalDistanceNM: 0, estimatedFuelL: 0, estimatedCostCAD: 0, estimatedTimeHours: 0, waypoints: [], fuelWarning: false)
        }
        
        // Nearest-neighbor TSP
        var route: [RouteSpot] = []
        var remaining = targets
        var currentPos = departure
        
        while !remaining.isEmpty {
            let nearest = remaining.min(by: { a, b in
                haversineNM(currentPos, (a.lat, a.lon)) < haversineNM(currentPos, (b.lat, b.lon))
            })!
            route.append(nearest)
            currentPos = (nearest.lat, nearest.lon)
            remaining.removeAll { $0.name == nearest.name }
        }
        
        // Calculate total distance including return
        var totalDistance: Double = 0
        var prev = departure
        for spot in route {
            totalDistance += haversineNM(prev, (spot.lat, spot.lon))
            prev = (spot.lat, spot.lon)
        }
        totalDistance += haversineNM(prev, departure) // Return trip
        
        // Fuel calculation
        // Rule of thumb: fuel burn (L/hr) ≈ HP × 0.06 at cruise
        let fuelRateLPH = Double(engineHP) * 0.06
        let transitTimeHours = totalDistance / cruiseSpeedKnots
        let estimatedFuel = fuelRateLPH * transitTimeHours
        let fuelCostPerLiter = 2.20 // CAD, marina diesel average
        let estimatedCost = estimatedFuel * fuelCostPerLiter
        
        // Activity time: 1.5hr per fishing spot, 2hr for crab (set & wait), 3hr for prawn (deep set)
        let activityTime = route.reduce(0.0) { total, spot in
            switch spot.type {
            case .fishing: return total + 1.5
            case .crabbing: return total + 2.0
            case .prawning: return total + 3.0
            }
        }
        let totalTime = transitTimeHours + activityTime
        
        // Safety check - enough fuel?
        let fuelSafetyMargin = fuelCapacityL * 0.75 // Keep 25% reserve
        let fuelWarning = estimatedFuel > fuelSafetyMargin
        
        let waypoints = route.map { spot in
            Waypoint(
                name: spot.name,
                latitude: spot.lat,
                longitude: spot.lon,
                activity: spot.activityLabel
            )
        }
        
        return RouteResult(
            totalDistanceNM: round(totalDistance * 10) / 10,
            estimatedFuelL: round(estimatedFuel * 10) / 10,
            estimatedCostCAD: round(estimatedCost * 100) / 100,
            estimatedTimeHours: round(totalTime * 10) / 10,
            waypoints: waypoints,
            fuelWarning: fuelWarning
        )
    }
    
    // MARK: - Haversine
    private func haversineNM(_ pos1: (Double, Double), _ pos2: (Double, Double)) -> Double {
        let lat1 = pos1.0 * .pi / 180
        let lon1 = pos1.1 * .pi / 180
        let lat2 = pos2.0 * .pi / 180
        let lon2 = pos2.1 * .pi / 180
        
        let dlat = lat2 - lat1
        let dlon = lon2 - lon1
        
        let a = sin(dlat / 2) * sin(dlat / 2) + cos(lat1) * cos(lat2) * sin(dlon / 2) * sin(dlon / 2)
        let c = 2 * asin(sqrt(a))
        
        let earthRadiusNM = 3440.065
        return earthRadiusNM * c
    }
}

// MARK: - Models
struct RouteSpot {
    let name: String
    let lat: Double
    let lon: Double
    let type: SpotType
    let depthFt: Int
    
    var activityLabel: String {
        switch type {
        case .fishing: return "🎣 钓鱼 Fishing (\(depthFt)ft)"
        case .crabbing: return "🦀 捕蟹 Crabbing (\(depthFt)ft)"
        case .prawning: return "🦐 捕虾 Prawning (\(depthFt)ft)"
        }
    }
}

enum SpotType {
    case fishing, crabbing, prawning
}

struct RouteRequest: Codable {
    let departureLatitude: Double
    let departureLongitude: Double
    let engineHP: Int
    let fuelCapacityL: Double
    let cruiseSpeedKnots: Double
    let wantsFishing: Bool
    let wantsCrabbing: Bool
    let wantsPrawning: Bool
}

struct RouteResult: Codable {
    let totalDistanceNM: Double
    let estimatedFuelL: Double
    let estimatedCostCAD: Double
    let estimatedTimeHours: Double
    let waypoints: [Waypoint]
    var fuelWarning: Bool = false
    
    enum CodingKeys: String, CodingKey {
        case totalDistanceNM, estimatedFuelL, estimatedCostCAD, estimatedTimeHours, waypoints
    }
}

struct Waypoint: Codable {
    let name: String
    let latitude: Double
    let longitude: Double
    let activity: String
}

struct CustomWaypoint: Identifiable {
    let id = UUID()
    let lat: Double
    let lon: Double
    let name: String
}
