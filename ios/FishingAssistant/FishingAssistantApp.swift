import SwiftUI

@main
struct FishingAssistantApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var l10n = L10n.shared
    
    var body: some Scene {
        WindowGroup {
            if appState.isLoggedIn {
                MainTabView()
                    .environmentObject(appState)
                    .environmentObject(l10n)
            } else {
                LoginView()
                    .environmentObject(appState)
                    .environmentObject(l10n)
            }
        }
    }
}
