import SwiftUI
import CoreLocation

class AppState: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var currentUser: UserProfile?
    @Published var currentLocation: Location?
    @Published var selectedBoatRamp: BoatRamp?
    @Published var selectedTab: Int = 0
    @Published var navigateToCoordinate: CLLocationCoordinate2D?
    @Published var isCaptain: Bool {
        didSet {
            UserDefaults.standard.set(isCaptain, forKey: "is_captain")
        }
    }
    
    let apiService = APIService()
    let locationManager = FishingLocationManager()
    let l10n = L10n.shared
    
    init() {
        // Restore captain status
        self.isCaptain = UserDefaults.standard.bool(forKey: "is_captain")
        
        // Restore login state
        if let data = UserDefaults.standard.data(forKey: "saved_user"),
           let user = try? JSONDecoder().decode(UserProfile.self, from: data) {
            self.currentUser = user
            self.isLoggedIn = true
        }
    }
    
    private func saveUser(_ user: UserProfile) {
        if let data = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(data, forKey: "saved_user")
        }
    }
    
    private func clearSavedUser() {
        UserDefaults.standard.removeObject(forKey: "saved_user")
    }
    
    func login(email: String, password: String) async -> Bool {
        // In production, call backend auth API
        // For demo, accept any non-empty credentials
        guard !email.isEmpty, !password.isEmpty else { return false }
        await MainActor.run {
            let user = UserProfile(
                id: UUID().uuidString,
                email: email,
                displayName: email.components(separatedBy: "@").first ?? "Fisher",
                avatarURL: nil
            )
            self.currentUser = user
            self.isLoggedIn = true
            self.saveUser(user)
        }
        return true
    }
    
    func signup(email: String, password: String, name: String) async -> Bool {
        guard !email.isEmpty, !password.isEmpty, !name.isEmpty else { return false }
        await MainActor.run {
            let user = UserProfile(
                id: UUID().uuidString,
                email: email,
                displayName: name,
                avatarURL: nil
            )
            self.currentUser = user
            self.isLoggedIn = true
            self.saveUser(user)
        }
        return true
    }
    
    func logout() {
        isLoggedIn = false
        currentUser = nil
        clearSavedUser()
    }
}

struct UserProfile: Codable {
    let id: String
    let email: String
    let displayName: String
    let avatarURL: String?
}

struct Location: Codable {
    let latitude: Double
    let longitude: Double
}

struct BoatRamp: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let latitude: Double
    let longitude: Double
    let description: String
}
