//
//  ContentView.swift
//  Your Itinerary
//
//  Created by Lyn A on 14/09/2026.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    @State private var userName: String = "Reisende"
    @State private var destinations: [Destination] = [
        Destination(
            title: "London Helgetur",
            country: "Storbrittania",
            imageName: "building.2.fill",
            items: [
                ItineraryItem(day: "Dag 1", activity: "Innsjekk på hotell", location: "Sentrum"),
                ItineraryItem(day: "Dag 1", activity: "Middag på Ritz", location: "Piccadilly Circus"),
                ItineraryItem(day: "Dag 2", activity: "Besøke Big Ben", location: "Westminster")
            ]
        ),
        Destination(
            title: "Sommer i Paris",
            country: "Frankrike",
            imageName: "sparkles",
            items: [
                ItineraryItem(day: "Dag 1", activity: "Se Eiffeltårnet", location: "Champ de Mars"),
                ItineraryItem(day: "Dag 2", activity: "Tur til Louvremuseet", location: "Sentral-Paris")
            ]
        )
    ]

    var body: some View {
        TabView {
            DestinationListView(destinations: destinations)
                .tabItem {
                    Label("Reiser", systemImage: "map.fill")
                }

            ProfileView(userName: $userName, destinations: destinations)
                .tabItem {
                    Label("Profil", systemImage: "person.fill")
                }

            SettingsView()
                .tabItem {
                    Label("Innstillingar", systemImage: "gearshape.fill")
                }
        }
        .tint(.brand)
        // Skifter hele appens utseende basert på bryteren
                .preferredColorScheme(isDarkMode ? .dark : .light)
    }

}

#Preview {
    ContentView()
}
