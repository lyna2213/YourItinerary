//
//  DestinationDetailView.swift
//  Your Itinerary
//
//  Created by Lyn A on 14/09/2026.
//

import SwiftUI

struct DestinationDetailView: View {
    let destination: Destination
    @State private var showHeaderInfo: Bool = true
    
    var body: some View {
        ZStack {
            // Bruker bakgrunnsfarge på hele skjermen
            Color.customBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header med ZStack, frame og padding
                ZStack {
                    LinearGradient(
                        colors: [.brand, .brand.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .frame(height: 140)
                    .cornerRadius(16)
                    
                    VStack {
                        Text(destination.title)
                            .font(.title)
                            .bold()
                            .foregroundColor(.white)
                        Text(destination.country)
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
                
                // Liste med ForEach for tidsplan
                List {
                    Section(header: Text("Tidsplan")) {
                        ForEach(destination.items) { item in
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(item.activity)
                                        .font(.body)
                                        .bold()
                                    HStack {
                                        Image(systemName: "mappin.and.ellipse")
                                            .foregroundColor(.brand)
                                        Text(item.location)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                Spacer()
                                Text(item.day)
                                    .font(.caption)
                                    .padding(6)
                                    .background(Color.brand.opacity(0.15))
                                    .cornerRadius(8)
                            }
                            .padding(.vertical, 2)
                        }
                    }
                }
                .scrollContentBackground(.hidden) // Skjuler standard grå/hvit liste-bakgrunn
            }
        }
        .navigationTitle(destination.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    DestinationDetailView(
        destination: Destination(
            title: "Sommer i London",
            country: "Storbritannia",
            imageName: "sparkles",
            items: [
                ItineraryItem(day: "Dag 1", activity: "Testaktivitet", location: "London")
            ]
        )
    )
}
