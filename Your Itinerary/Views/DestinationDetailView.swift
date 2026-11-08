//  DestinationDetailView.swift
//  Your Itinerary
//
//  Created by Lyn A on 24/10/2026.
//

import SwiftUI
import SwiftData

struct DestinationDetailView: View {
    @Bindable var trip: SavedTrip
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var showingEditSheet = false
    @State private var editTitle = ""
    @State private var editCountry = ""
    @State private var editDescription = ""
    @State private var editImageName = ""
    
    // Felter for tidsplan redigering
    @State private var day1Activity = ""
    @State private var day1Location = ""
    @State private var day2Activity = ""
    @State private var day2Location = ""
    @State private var day3Activity = ""
    @State private var day3Location = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let uiImage = UIImage(named: trip.imageName) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 200)
                        .clipped()
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text(trip.title)
                        .font(.largeTitle)
                        .bold()
                    
                    Text(trip.country)
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text(trip.tripDescription)
                        .padding(.vertical, 4)
                    
                    // Vis tidsplan alltid når den finnes
                    if !trip.items.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Tidsplan")
                                .font(.headline)
                                .padding(.top, 8)
                            
                            ForEach(trip.items.sorted(by: { $0.day < $1.day })) { item in
                                HStack(spacing: 12) {
                                    Image(systemName: "figure.walk")
                                        .foregroundColor(.brand)
                                        .frame(width: 32, height: 32)
                                        .background(Color.brand.opacity(0.15))
                                        .cornerRadius(8)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(item.day).font(.caption).bold().foregroundColor(.secondary)
                                        Text(item.activity).font(.subheadline).bold()
                                        Text(item.location).font(.caption).foregroundColor(.secondary)
                                    }
                                    Spacer()
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }
                    
                    Button(role: .destructive) {
                        modelContext.delete(trip)
                        try? modelContext.save()
                        dismiss()
                    } label: {
                        HStack {
                            Image(systemName: "trash")
                            Text("Slett reise")
                        }
                        .font(.headline)
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(10)
                    }
                    .padding(.top, 24)
                }
                .padding()
            }
        }
        .navigationTitle("Reisedetaljer")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Rediger") {
                    editTitle = trip.title
                    editCountry = trip.country
                    editDescription = trip.tripDescription
                    editImageName = trip.imageName
                    
                    // Tilbakestill og hent eksisterende tidsplan inn i redigeringsfeltene
                    day1Activity = ""
                    day1Location = ""
                    day2Activity = ""
                    day2Location = ""
                    day3Activity = ""
                    day3Location = ""
                    
                    for item in trip.items {
                        if item.day == "Dag 1" {
                            day1Activity = item.activity
                            day1Location = item.location
                        } else if item.day == "Dag 2" {
                            day2Activity = item.activity
                            day2Location = item.location
                        } else if item.day == "Dag 3" {
                            day3Activity = item.activity
                            day3Location = item.location
                        }
                    }
                    
                    showingEditSheet = true
                }
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            NavigationStack {
                Form {
                    Section(header: Text("Rediger reiseinformasjon")) {
                        TextField("Tittel", text: $editTitle)
                        TextField("Land", text: $editCountry)
                        TextField("Beskrivelse", text: $editDescription)
                        TextField("Bilde navn i Assets", text: $editImageName)
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
                .navigationTitle("Endre reise")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Avbryt") { showingEditSheet = false }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Lagre") {
                            // 1. Oppdater reiseinformasjon
                            trip.title = editTitle
                            trip.country = editCountry
                            trip.tripDescription = editDescription
                            trip.imageName = editImageName.isEmpty ? "London" : editImageName
                            
                            // 2. Smart oppdatering av tidsplan (gjenbruker eller oppretter elementer)
                            // Dag 1
                            if !day1Activity.isEmpty {
                                if let existingItem = trip.items.first(where: { $0.day == "Dag 1" }) {
                                    existingItem.activity = day1Activity
                                    existingItem.location = day1Location
                                } else {
                                    let newItem = ItineraryItem(day: "Dag 1", activity: day1Activity, location: day1Location, iconName: "figure.walk")
                                    modelContext.insert(newItem)
                                    trip.items.append(newItem)
                                }
                            } else {
                                if let existingItem = trip.items.first(where: { $0.day == "Dag 1" }) {
                                    modelContext.delete(existingItem)
                                    trip.items.removeAll(where: { $0.day == "Dag 1" })
                                }
                            }
                            
                            // Dag 2
                            if !day2Activity.isEmpty {
                                if let existingItem = trip.items.first(where: { $0.day == "Dag 2" }) {
                                    existingItem.activity = day2Activity
                                    existingItem.location = day2Location
                                } else {
                                    let newItem = ItineraryItem(day: "Dag 2", activity: day2Activity, location: day2Location, iconName: "figure.walk")
                                    modelContext.insert(newItem)
                                    trip.items.append(newItem)
                                }
                            } else {
                                if let existingItem = trip.items.first(where: { $0.day == "Dag 2" }) {
                                    modelContext.delete(existingItem)
                                    trip.items.removeAll(where: { $0.day == "Dag 2" })
                                }
                            }
                            
                            // Dag 3
                            if !day3Activity.isEmpty {
                                if let existingItem = trip.items.first(where: { $0.day == "Dag 3" }) {
                                    existingItem.activity = day3Activity
                                    existingItem.location = day3Location
                                } else {
                                    let newItem = ItineraryItem(day: "Dag 3", activity: day3Activity, location: day3Location, iconName: "figure.walk")
                                    modelContext.insert(newItem)
                                    trip.items.append(newItem)
                                }
                            } else {
                                if let existingItem = trip.items.first(where: { $0.day == "Dag 3" }) {
                                    modelContext.delete(existingItem)
                                    trip.items.removeAll(where: { $0.day == "Dag 3" })
                                }
                            }
                            
                            // 3. Lagre endringene permanent i SwiftData
                            try? modelContext.save()
                            
                            showingEditSheet = false
                        }
                        .disabled(editTitle.isEmpty || editCountry.isEmpty)
                    }
                }
            }
        }
    }
}
