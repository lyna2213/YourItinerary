//
//  DestinationListView.swift
//  Your Itinerary
//
//  Created by Lyn A on 14/09/2026.
//

import SwiftUI

struct DestinationListView: View {
    // @AppStorage lagrer innstillingen i UserDefaults slik at den huskes
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false

    let destinations: [Destination]

    var body: some View {
        NavigationStack {
            ZStack {
                // Bruker bakgrunnsfarge på hele skjermen
                Color.customBackground
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Hero-bilde øverst på hovedskjermen
                    Image("hero_banner")
                        .resizable()
                        .scaledToFill()
                        .frame(height: 180)
                        .cornerRadius(16)
                        .overlay(
                            // Mørk overlay med tittel oppå bildet for god lesbarhet
                            ZStack {
                                Color.black.opacity(0.3)
                                Text("Your Itinerary")
                                    .font(.largeTitle)
                                    .bold()
                                    .foregroundColor(.white)
                            }
                        )
                        .cornerRadius(16)
                        .padding(.horizontal)
                        .padding(.top, 8)

                    // Liste over reiser bygget med List og ForEach (oppfyller arbeidskrav 1)
                    List {
                        ForEach(destinations) { destination in
                            NavigationLink(destination: DestinationDetailView(destination: destination)) {
                                HStack(spacing: 16) {
                                    // Viser reisemålets eget bilde fra Assets i listen
                                    Image(destination.imageName)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 50, height: 50)
                                        .cornerRadius(10)
                                        .clipped()

                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(destination.title)
                                            .font(.headline)
                                        Text(destination.country)
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }

                                    Spacer()
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden) // Skjuler standard grå/hvit bakgrunn på listen
                }
            }
            .toolbar(.hidden, for: .navigationBar) // Skjuler standard system-topplinje
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }
}

#Preview {
    DestinationListView(destinations: [
        Destination(
            title: "Sommer i London",
            country: "Storbritannia",
            imageName: "London",
            items: []
        )
    ])
}
