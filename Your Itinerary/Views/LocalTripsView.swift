//  LocalTripsView.swift
//  Your Itinerary
//
//  Created by Lyn A on 24/10/2026.
//

import SwiftUI
import SwiftData

struct LocalTripsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var savedTrips: [SavedTrip]

    @State private var showingAddSheet = false
    @State private var tripTitle = ""
    @State private var tripCountry = ""
    @State private var tripDescription = ""
    @State private var tripImageName = "London"

    // Felter for tidsplan
    @State private var day1Activity = ""
    @State private var day1Location = ""
    @State private var day2Activity = ""
    @State private var day2Location = ""
    @State private var day3Activity = ""
    @State private var day3Location = ""

    var body: some View {
        NavigationStack {
            ZStack {
                Color.customBackground
                    .ignoresSafeArea()

                List {
                    if savedTrips.isEmpty {
                        Text("Ingen lagrede reiser enda. Trykk på plusstegnet for å legge til!")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(savedTrips) { trip in
                            NavigationLink(destination: DestinationDetailView(trip: trip)) {
                                HStack(spacing: 16) {
                                    if let uiImage = UIImage(named: trip.imageName) {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 50, height: 50)
                                            .cornerRadius(10)
                                            .clipped()
                                    } else {
                                        Image(systemName: "map.fill")
                                            .foregroundColor(.brand)
                                            .frame(width: 50, height: 50)
                                            .background(Color.brand.opacity(0.15))
                                            .cornerRadius(10)
                                    }

                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(trip.title).font(.headline)
                                        Text(trip.country).font(.subheadline).foregroundColor(.secondary)
                                    }

                                    Spacer()

                                    Button(action: {
                                        trip.isFavorite.toggle()
                                    }) {
                                        Image(systemName: trip.isFavorite ? "heart.fill" : "heart")
                                            .foregroundColor(trip.isFavorite ? .red : .gray)
                                            .font(.title3)
                                    }
                                    .buttonStyle(BorderlessButtonStyle())
                                }
                                .padding(.vertical, 4)
                            }
                        }
                        .onDelete { indexSet in
                            for index in indexSet {
                                modelContext.delete(savedTrips[index])
                            }
                        }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Mine Reiser")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        tripTitle = ""
                        tripCountry = ""
                        tripDescription = ""
                        tripImageName = "London"
                        day1Activity = ""
                        day1Location = ""
                        day2Activity = ""
                        day2Location = ""
                        day3Activity = ""
                        day3Location = ""
                        showingAddSheet = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.brand)
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                NavigationStack {
                    Form {
                        Section(header: Text("Reiseinformasjon")) {
                            TextField("Tittel (f.eks. London Helgetur)", text: $tripTitle)
                            TextField("Land (f.eks. Storbritannia)", text: $tripCountry)
                            TextField("Beskrivelse", text: $tripDescription)
                            TextField("Bilde navn i Assets (f.eks. London)", text: $tripImageName)
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
                    .navigationTitle("Legg til lokalt")
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Avbryt") { showingAddSheet = false }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Lagre") {
                                var initialItems: [ItineraryItem] = []
                                
                                if !day1Activity.isEmpty {
                                    let item = ItineraryItem(day: "Dag 1", activity: day1Activity, location: day1Location, iconName: "figure.walk")
                                    modelContext.insert(item)
                                    initialItems.append(item)
                                }
                                if !day2Activity.isEmpty {
                                    let item = ItineraryItem(day: "Dag 2", activity: day2Activity, location: day2Location, iconName: "figure.walk")
                                    modelContext.insert(item)
                                    initialItems.append(item)
                                }
                                if !day3Activity.isEmpty {
                                    let item = ItineraryItem(day: "Dag 3", activity: day3Activity, location: day3Location, iconName: "figure.walk")
                                    modelContext.insert(item)
                                    initialItems.append(item)
                                }

                                let newTrip = SavedTrip(
                                    title: tripTitle,
                                    country: tripCountry,
                                    tripDescription: tripDescription,
                                    imageName: tripImageName,
                                    items: initialItems
                                )
                                modelContext.insert(newTrip)
                                try? modelContext.save()

                                showingAddSheet = false
                            }
                            .disabled(tripTitle.isEmpty || tripCountry.isEmpty)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    LocalTripsView()
}
