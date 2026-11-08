//  ProfileView.swift
//  Your Itinerary
//
//  Created by Lyn A on 14/09/2026.
//

import SwiftUI
import SwiftData

struct ProfileView: View {
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    
    // Henter brukernavn direkte fra @AppStorage
    @AppStorage("userName") private var userName: String = "Reisende"
    
    // Styrer innloggingsstatus for å kunne logge ut
    @AppStorage("isAuthenticated") private var isAuthenticated: Bool = true

    // Om meg / Bio tilstander
    @AppStorage("userBio") private var userBio: String = "Elsker å reise, oppleve nye kulturer og planlegge spennende turer!"
    @State private var isEditingBio = false
    @State private var tempBio = ""

    // Henter kun favorittreiser automatisk fra SwiftData
    @Query(filter: #Predicate<SavedTrip> { $0.isFavorite == true })
    private var favoriteTrips: [SavedTrip]

    var body: some View {
        NavigationStack {
            ZStack {
                Color.customBackground
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // Profilbilde
                        ZStack {
                            Circle()
                                .fill(Color.brand.opacity(0.15))
                                .frame(width: 90, height: 90)
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .frame(width: 80, height: 80)
                                .foregroundColor(.brand)
                        }
                        .padding(.top, 10)

                        Text("Velkommen, \(userName)!")
                            .font(.title2)
                            .bold()

                        // OM MEG SEKSJON
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Om meg")
                                    .font(.headline)
                                Spacer()
                                Button(isEditingBio ? "Ferdig" : "Rediger") {
                                    if isEditingBio {
                                        userBio = tempBio
                                    } else {
                                        tempBio = userBio
                                    }
                                    isEditingBio.toggle()
                                }
                                .font(.subheadline)
                                .foregroundColor(.brand)
                            }

                            if isEditingBio {
                                TextField("Skriv litt om deg selv...", text: $tempBio, axis: .vertical)
                                    .textFieldStyle(.roundedBorder)
                            } else {
                                Text(userBio)
                                    .foregroundColor(.secondary)
                                    .font(.body)
                            }
                        }
                        .padding()
                        .background(Color.brand.opacity(0.05))
                        .cornerRadius(12)
                        .padding(.horizontal)

                        // MINE FAVORITTER SEKSJON
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Mine Favoritter ❤️")
                                .font(.headline)
                                .padding(.horizontal)

                            if favoriteTrips.isEmpty {
                                Text("Ingen favoritter enda. Trykk på hjerte-ikonet på en reise for å legge den til her!")
                                    .foregroundColor(.secondary)
                                    .font(.subheadline)
                                    .padding(.horizontal)
                            } else {
                                VStack(spacing: 8) {
                                    ForEach(favoriteTrips) { trip in
                                        NavigationLink(destination: DestinationDetailView(trip: trip)) {
                                            HStack(spacing: 12) {
                                                if let uiImage = UIImage(named: trip.imageName) {
                                                    Image(uiImage: uiImage)
                                                        .resizable()
                                                        .scaledToFill()
                                                        .frame(width: 45, height: 45)
                                                        .cornerRadius(8)
                                                        .clipped()
                                                } else {
                                                    Image(systemName: "map.fill")
                                                        .foregroundColor(.brand)
                                                        .frame(width: 45, height: 45)
                                                        .background(Color.brand.opacity(0.15))
                                                        .cornerRadius(8)
                                                }

                                                VStack(alignment: .leading, spacing: 2) {
                                                    Text(trip.title).font(.headline).foregroundColor(.primary)
                                                    Text(trip.country).font(.subheadline).foregroundColor(.secondary)
                                                }
                                                Spacer()

                                                Image(systemName: "heart.fill")
                                                    .foregroundColor(.red)
                                            }
                                            .padding()
                                            .background(Color.customBackground.opacity(0.6))
                                            .cornerRadius(10)
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }

                        // LOGG UT KNAPP
                        Button(role: .destructive) {
                            isAuthenticated = false
                        } label: {
                            HStack {
                                Image(systemName: "arrow.right.square")
                                Text("Logg ut")
                            }
                            .font(.headline)
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(10)
                        }
                        .padding(.horizontal)
                        .padding(.top, 20)
                        .padding(.bottom, 30)
                    }
                }
            }
            .navigationTitle("Profil")
        }
    }
}

#Preview {
    ProfileView()
        .modelContainer(for: SavedTrip.self, inMemory: true)
}
