//
//  SupabaseView.swift
//  Your Itinerary
//
//  Created by Lyn A on 24/10/2026.
//

import SwiftUI

struct SupabaseView: View {
    @State private var items: [SupabaseDestination] = []
    @State private var isLoading = true
    @State private var showingAddSheet = false

    // Tilstand for søkefelt
    @State private var searchText = ""

    // Felter for nytt skjema (reiseinformasjon)
    @State private var newTitle = ""
    @State private var newCountry = ""
    @State private var newDescription = ""
    @State private var newImageName = "London"

    // Felter for tidsplan (Dag 1 til 3)
    @State private var day1Activity = ""
    @State private var day1Location = ""
    @State private var day2Activity = ""
    @State private var day2Location = ""
    @State private var day3Activity = ""
    @State private var day3Location = ""

    let service = SupabaseService()

    // Filtrerer listen basert på hva brukeren skriver i søkefeltet
    var filteredItems: [SupabaseDestination] {
        if searchText.isEmpty {
            return items
        } else {
            return items.filter {
                $0.title.localizedCaseInsensitiveContains(searchText)
                    || $0.country.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView("Henter data fra Supabase...")
                } else {
                    List {
                        // Bruker den filtrerte listen for søk og den ryddige DestinationRowView-komponenten
                        ForEach(filteredItems) { item in
                            NavigationLink(
                                destination: SupabaseDetailView(
                                    destination: item,
                                    onUpdate: {
                                        Task { await loadData() }
                                    },
                                    onDelete: {
                                        Task { await loadData() }
                                    }
                                )
                            ) {
                                DestinationRowView(destination: item)
                            }
                        }
                        .onDelete(perform: deleteItem)
                    }
                    .listStyle(.plain)
                    .refreshable {
                        await loadData()
                    }
                }
            }
            .navigationTitle("Utforsk Reiser")
            .searchable(
                text: $searchText,
                prompt: "Søk etter reisemål eller land..."
            )
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        // Nullstill skjema ved åpning
                        newTitle = ""
                        newCountry = ""
                        newDescription = ""
                        newImageName = "London"
                        day1Activity = ""
                        day1Location = ""
                        day2Activity = ""
                        day2Location = ""
                        day3Activity = ""
                        day3Location = ""
                        showingAddSheet = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                NavigationStack {
                    Form {
                        Section(header: Text("Ny destinasjon")) {
                            TextField("Tittel (f.eks. Roma)", text: $newTitle)
                            TextField("Land (f.eks. Italia)", text: $newCountry)
                            TextField("Beskrivelse", text: $newDescription)
                            TextField(
                                "Bilde navn i Assets (f.eks. London)",
                                text: $newImageName
                            )
                        }

                        Section(header: Text("Tidsplan - Dag 1")) {
                            TextField("Aktivitet", text: $day1Activity)
                            TextField("Lokasjon", text: $day1Location)
                        }

                        Section(header: Text("Tidsplan - Dag 2")) {
                            TextField("Aktivitet", text: $day2Activity)
                            TextField("Lokasjon", text: $day2Location)
                        }

                        Section(header: Text("Tidsplan - Dag 3")) {
                            TextField("Aktivitet", text: $day3Activity)
                            TextField("Lokasjon", text: $day3Location)
                        }
                    }
                    .navigationTitle("Legg til reise")
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Avbryt") { showingAddSheet = false }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Lagre") {
                                // Bygg opp tidsplan-listen med standardikon ("map.fill")
                                var initialItems: [ItineraryItem] = []
                                if !day1Activity.isEmpty {
                                    initialItems.append(
                                        ItineraryItem(
                                            day: "Dag 1",
                                            activity: day1Activity,
                                            location: day1Location,
                                            iconName: "map.fill"
                                        )
                                    )
                                }
                                if !day2Activity.isEmpty {
                                    initialItems.append(
                                        ItineraryItem(
                                            day: "Dag 2",
                                            activity: day2Activity,
                                            location: day2Location,
                                            iconName: "map.fill"
                                        )
                                    )
                                }
                                if !day3Activity.isEmpty {
                                    initialItems.append(
                                        ItineraryItem(
                                            day: "Dag 3",
                                            activity: day3Activity,
                                            location: day3Location,
                                            iconName: "map.fill"
                                        )
                                    )
                                }

                                Task {
                                    do {
                                        try await SupabaseService
                                            .createDestination(
                                                title: newTitle,
                                                country: newCountry,
                                                description: newDescription,
                                                imageName: newImageName,
                                                items: initialItems
                                            )
                                        items =
                                            try await SupabaseService
                                            .fetchDestinations()
                                        showingAddSheet = false
                                    } catch {
                                        print("Feil ved lagring: \(error)")
                                    }
                                }
                            }
                            .disabled(newTitle.isEmpty || newCountry.isEmpty)
                        }
                    }
                }
            }
        }
        .task {
            await loadData()
        }
    }

    private func loadData() async {
        do {
            items = try await SupabaseService.fetchDestinations()
            isLoading = false
        } catch {
            print("Feil ved henting: \(error)")
            isLoading = false
        }
    }

    private func deleteItem(at offsets: IndexSet) {
        for index in offsets {
            let itemToDelete = filteredItems[index]

            items.removeAll { $0.id == itemToDelete.id }

            Task {
                do {
                    try await SupabaseService
                        .deleteDestination(id: itemToDelete.id)
                } catch {
                    print("Feil ved sletting fra server: \(error)")
                }
            }
        }
    }
}
