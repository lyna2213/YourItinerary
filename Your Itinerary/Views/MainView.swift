//  MainView.swift
//  Your Itinerary
//
//  Created by Lyn A on 14/09/2026.
//

import SwiftUI
import SwiftData

struct MainView: View {
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false

    var body: some View {
        TabView {
            DestinationListView()
                .tabItem {
                    Label("Reiser", systemImage: "map.fill")
                }
            
            SupabaseView()
                .tabItem {
                    Label("Utforsk Reiser", systemImage: "globe.fill")
                }
            
            LocalTripsView()
                .tabItem {
                    Label("Mine Reiser", systemImage: "star.fill")
                }

            // Kalles nå uten binding, siden den bruker @AppStorage internt
            ProfileView()
                .tabItem {
                    Label("Profil", systemImage: "person.fill")
                }

            SettingsView()
                .tabItem {
                    Label("Innstillinger", systemImage: "gearshape.fill")
                }
        }
        .tint(.brand)
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }
}

#Preview {
    MainView()
        .modelContainer(for: SavedTrip.self, inMemory: true)
}
