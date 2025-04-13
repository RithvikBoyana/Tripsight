import SwiftUI

struct MainTabView: View {
    @EnvironmentObject private var authService: AuthenticationService
    @State private var selectedTab = 1
    
    var body: some View {
        TabView(selection: $selectedTab) {
            SavedTripsView()
                .tabItem {
                    Label("Saved", systemImage: "bookmark.fill")
                }
                .tag(0)
            
            ContentView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(1)
            
            AccountView()
                .tabItem {
                    Label("Account", systemImage: "person.fill")
                }
                .tag(2)
        }
        .accentColor(.blue)
    }
} 