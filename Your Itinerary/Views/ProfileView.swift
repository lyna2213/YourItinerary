//
//  ProfileView.swift
//  Your Itinerary
//
//  Created by Lyn A on 14/09/2026.
//

import SwiftUI

struct ProfileView: View {
    // @AppStorage lagrer innstillingen i UserDefaults slik at den huskes
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false

    @Binding var userName: String
    let destinations: [Destination]
    @State private var tempName: String = ""

    var body: some View {
        NavigationStack {
            ZStack {
                Color.customBackground
                    .ignoresSafeArea()

                VStack(spacing: 16) {
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

                    // Endring av brukernavn
                    HStack {
                        TextField("Skriv nytt navn...", text: $tempName)
                            .textFieldStyle(.roundedBorder)

                        Button("Lagre") {
                            if !tempName.isEmpty {
                                userName = tempName
                                tempName = ""
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.brand)
                    }
                    .padding(.horizontal)

                    // Overskrift for reiselisten
                    HStack {
                        Text("Mine Reiser")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)

                    // Liste over reiser
                    List(destinations) { destination in
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
                            .padding(.vertical, 2)
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("Profil")
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }
}

#Preview {
    ProfileView(
        userName: .constant("Lyn"),
        destinations: [
            Destination(
                title: "Sommer i London",
                country: "Storbritannia",
                imageName: "map.fill",
                items: []
            )
        ]
    )
}
