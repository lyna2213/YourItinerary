//
//  Your_ItineraryApp.swift
//  Your Itinerary
//
//  Created by Lyn A on 14/09/2026.
//

import SwiftUI
import SwiftData

@main
struct Your_ItineraryApp: App {
    @AppStorage("isAuthenticated") private var isAuthenticated = false

    var body: some Scene {
        WindowGroup {
            if isAuthenticated {
                MainView()
                    .modelContainer(for: SavedTrip.self)
            } else {
                LoginView(isAuthenticated: $isAuthenticated)
            }
        }
    }
}
