//
//  DestinationListView.swift
//  Your Itinerary
//
//  Created by Lyn A on 14/09/2026.
//

import SwiftUI

struct DestinationListView: View {
    let destinations: [Destination]

    var body: some View {
        NavigationStack {
            ZStack {
                // Bruker bakgrunnsfarge på hele skjermen
                Color.customBackground
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Custom Navigation Title med LinearGradient i en ramme
                    ZStack {
                        LinearGradient(
                            colors: [.brand, .brand.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .frame(height: 200)
                        .cornerRadius(16)

                        Text("Your Itinerary")
                            .font(.largeTitle)
                            .bold()
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)

                    // Liste over reiser
                    List(destinations) { destination in
                        NavigationLink(destination: DestinationDetailView(destination: destination)) {
                            HStack(spacing: 16) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.brand.opacity(0.15))
                                        .frame(width: 50, height: 50)

                                    Image(systemName: destination.imageName)
                                        .foregroundColor(.brand)
                                        .font(.title2)
                                }

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
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden) // Skjuler standard grå/hvit bakgrunn på listen
                }
            }
            .toolbar(.hidden, for: .navigationBar) // Skjuler standard system-topplinje
        }
    }
}

#Preview {
    DestinationListView(destinations: [
        Destination(
            title: "Sommer i London",
            country: "Storbritannia",
            imageName: "map.fill",
            items: []
        )
    ])
}
