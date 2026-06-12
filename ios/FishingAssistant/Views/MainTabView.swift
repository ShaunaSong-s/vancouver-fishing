import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var l10n: L10n
    
    var body: some View {
        TabView(selection: $appState.selectedTab) {
            ChatView()
                .tabItem {
                    Image(systemName: "bubble.left.and.bubble.right")
                    Text(l10n.tabAI)
                }
                .tag(0)
            
            MarineMapView()
                .tabItem {
                    Image(systemName: "cloud.sun.bolt")
                    Text(l10n.t("海况", "Marine"))
                }
                .tag(1)
            
            if appState.isCaptain {
                RoutePlannerView()
                    .tabItem {
                        Image(systemName: "map")
                        Text(l10n.t("钓点航线", "Spots"))
                    }
                    .tag(2)
            }
            
            InfoCenterView()
                .tabItem {
                    Image(systemName: "book")
                    Text(l10n.tabInfo)
                }
                .tag(appState.isCaptain ? 3 : 2)
            
            ProfileView()
                .tabItem {
                    Image(systemName: "person.circle")
                    Text(l10n.tabProfile)
                }
                .tag(appState.isCaptain ? 4 : 3)
        }
        .accentColor(AppTheme.Colors.goldLight)
        .onAppear {
            // Style the tab bar
            let tabBarAppearance = UITabBarAppearance()
            tabBarAppearance.configureWithOpaqueBackground()
            tabBarAppearance.backgroundColor = UIColor(AppTheme.Colors.deepOcean)
            UITabBar.appearance().standardAppearance = tabBarAppearance
            UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        }
    }
}
