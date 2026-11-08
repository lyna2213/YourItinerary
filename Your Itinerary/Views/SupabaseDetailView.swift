//  SupabaseDetailView.swift
//  Your Itinerary
//
//  Created by Lyn A on 24/10/2026.
//

import SwiftUI

struct SupabaseDetailView: View {
    let destination: SupabaseDestination
    var onUpdate: (() -> Void)? = nil // Callback for å oppdatere listen når noe endres
    var onDelete: (() -> Void)? = nil // Callback for å gå tilbake når den slettes

    @Environment(\.dismiss) private var dismiss
    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false

    // Redigeringsfelter for reiseinformasjon
    @State private var editTitle: String = ""
    @State private var editCountry: String = ""
    @State private var editDescription: String = ""
    @State private var editImageName: String = ""

    // Redigeringsfelter for tidsplan (Dag 1 til 3)
    @State private var day1Activity = ""
    @State private var day1Location = ""
    @State private var day2Activity = ""
    @State private var day2Location = ""
    @State private var day3Activity = ""
    @State private var day3Location = ""

    let service = SupabaseService()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let imageName = destination.imageName, !imageName.isEmpty {
                    Image(imageName)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 220)
                        .cornerRadius(16)
                        .padding(.horizontal)
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text(destination.title)
                        .font(.largeTitle)
                        .bold()
                    
                    Text(destination.country)
                        .font(.headline)
                        .foregroundColor(.secondary)

                    Divider()

                    Text("Om reisen:")
                        .font(.headline)
                        .padding(.top, 4)
                    
                    Text(destination.description ?? "Ingen beskrivelse tilgjengelig.")
                        .font(.body)
                        .foregroundColor(.primary)

                    // Vis tidsplan med standardikon hvis den finnes fra Supabase
                    if let items = destination.items, !items.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Tidsplan")
                                .font(.headline)
                                .padding(.top, 8)
                            
                            ForEach(items) { item in
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

                    Spacer()

                    // Sletteknapp nederst på siden
                    Button(role: .destructive) {
                        showingDeleteAlert = true
                    } label: {
                        Label("Slett reisemål", systemImage: "trash")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red.opacity(0.15))
                            .foregroundColor(.red)
                            .cornerRadius(10)
                    }
                    .padding(.top, 20)
                    .padding(.bottom)
                }
                .padding(.horizontal)
            }
        }
        .navigationTitle(destination.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Rediger") {
                    // Fyller inn eksisterende verdier før skjemaet åpnes
                    editTitle = destination.title
                    editCountry = destination.country
                    editDescription = destination.description ?? ""
                    editImageName = destination.imageName ?? "London"

                    // Tilbakestill og hent eksisterende tidsplan-elementer
                    day1Activity = ""
                    day1Location = ""
                    day2Activity = ""
                    day2Location = ""
                    day3Activity = ""
                    day3Location = ""

                    if let items = destination.items {
                        for item in items {
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
                    }

                    showingEditSheet = true
                }
            }
        }
        // Redigeringsskjema (Sheet)
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
                .navigationTitle("Endre reisemål")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Avbryt") { showingEditSheet = false }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Lagre") {
                            // Bygg opp den oppdaterte tidsplan-listen
                            var updatedItems: [ItineraryItem] = []
                            if !day1Activity.isEmpty {
                                updatedItems.append(ItineraryItem(day: "Dag 1", activity: day1Activity, location: day1Location))
                            }
                            if !day2Activity.isEmpty {
                                updatedItems.append(ItineraryItem(day: "Dag 2", activity: day2Activity, location: day2Location))
                            }
                            if !day3Activity.isEmpty {
                                updatedItems.append(ItineraryItem(day: "Dag 3", activity: day3Activity, location: day3Location))
                            }

                            Task {
                                do {
                                    // Sørg for at updateDestination-funksjonen i din SupabaseService
                                    // tar imot items: [ItineraryItem] for å lagre til jsonb-kolonnen
                                    try await SupabaseService.updateDestination(
                                        id: destination.id,
                                        title: editTitle,
                                        country: editCountry,
                                        description: editDescription,
                                        imageName: editImageName,
                                        items: updatedItems
                                    )
                                    showingEditSheet = false
                                    onUpdate?() // Oppdaterer listen i bakgrunnen
                                    dismiss()   // Går tilbake til listen
                                } catch {
                                    print("Feil ved oppdatering: \(error)")
                                }
                            }
                        }
                        .disabled(editTitle.isEmpty || editCountry.isEmpty)
                    }
                }
            }
        }
        // Bekreftelsesboks før sletting
        .alert("Slett reise", isPresented: $showingDeleteAlert) {
            Button("Avbryt", role: .cancel) { }
            Button("Slett", role: .destructive) {
                Task {
                    do {
                        try await SupabaseService
                            .deleteDestination(id: destination.id)
                        onDelete?()
                        dismiss()
                    } catch {
                        print("Feil ved sletting: \(error)")
                    }
                }
            }
        } message: {
            Text("Er du sikker på at du vil slette denne reisen? Dette kan ikke angres.")
        }
    }
}
