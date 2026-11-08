//
//  DestinationListView.swift
//  Your Itinerary
//
//  Created by Lyn A on 14/09/2026.
//

import SwiftUI

struct DestinationListView: View {
    @State private var destinations: [SupabaseDestination] = []
    @State private var isLoading = true
    @State private var searchText = ""
    
    let service = SupabaseService()

    // Filtrerer listen basert på søkefeltet
    var filteredDestinations: [SupabaseDestination] {
        if searchText.isEmpty {
            return destinations
        } else {
            return destinations.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.country.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

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

                    // Innhold basert på om det laster eller er klart
                    Group {
                        if isLoading {
                            Spacer()
                            ProgressView("Henter reiser fra skyen...")
                                .tint(.brand)
                            Spacer()
                        } else {
                            List {
                                ForEach(filteredDestinations) { destination in
                                    NavigationLink(destination: SupabaseDetailView(destination: destination)) {
                                        // Bruker en pen rad-visning
                                        HStack(spacing: 16) {
                                            if let imageName = destination.imageName, !imageName.isEmpty {
                                                Image(imageName)
                                                    .resizable()
                                                    .scaledToFill()
                                                    .frame(width: 60, height: 60)
                                                    .cornerRadius(10)
                                                    .clipped()
                                            } else {
                                                Image(systemName: "photo")
                                                    .frame(width: 60, height: 60)
                                                    .background(Color.gray.opacity(0.2))
                                                    .cornerRadius(10)
                                            }

                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(destination.title)
                                                    .font(.headline)
                                                Text(destination.country)
                                                    .font(.subheadline)
                                                    .foregroundColor(.secondary)
                                            }
                                        }
                                        .padding(.vertical, 4)
                                    }
                                }
                                .onDelete(perform: deleteItem)
                            }
                            .listStyle(.plain)
                            .scrollContentBackground(.hidden)
                            .refreshable {
                                await loadData()
                            }
                        }
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Søk etter reisemål...")
            .toolbar(.hidden, for: .navigationBar)
            .task {
                await loadData()
            }
        }
    }

    private func loadData() async {
        do {
            destinations = try await SupabaseService.fetchDestinations()
            isLoading = false
        } catch {
            print("Feil ved henting: \(error)")
            isLoading = false
        }
    }

    private func deleteItem(at offsets: IndexSet) {
        for index in offsets {
            let itemToDelete = filteredDestinations[index]
            destinations.removeAll { $0.id == itemToDelete.id }
            Task {
                do {
                    try await SupabaseService
                        .deleteDestination(id: itemToDelete.id)
                } catch {
                    print("Feil ved sletting: \(error)")
                }
            }
        }
    }
}

#Preview {
    DestinationListView()
}
