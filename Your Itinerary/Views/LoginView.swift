//
//  LoginView.swift
//  Your Itinerary
//
//  Created by Lyn A on 05/11/2026.
//

import SwiftUI

struct LoginView: View {
    @Binding var isAuthenticated: Bool

    @State private var fullName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var isSignUp = false
    @State private var errorMessage = ""
    @State private var isLoading = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Logo eller tittel
                Image(systemName: "map.circle.fill")
                    .resizable()
                    .frame(width: 80, height: 80)
                    .foregroundColor(.brand)
                    .padding(.bottom, 10)

                Text("Your Itinerary")
                    .font(.largeTitle)
                    .bold()

                Text(isSignUp ? "Opprett ny konto" : "Logg inn for å fortsette")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 20)

                // Skjema med inputfelter
                VStack(spacing: 12) {
                    // Vis kun navnefeltet hvis brukeren holder på å registrere seg
                    if isSignUp {
                        TextField("Fullt navn", text: $fullName)
                            .autocapitalization(.words)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                    }
                    TextField("E-postadresse", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)

                    SecureField("Passord", text: $password)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                }

                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundColor(.red)
                }

                // Knapp for innlogging / registrering
                Button(action: handleAuth) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(
                                CircularProgressViewStyle(tint: .white)
                            )
                    } else {
                        Text(isSignUp ? "Registrer deg" : "Logg inn")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(isFormValid ? Color.brand : Color.gray)
                .cornerRadius(10)
                .disabled(!isFormValid || isLoading)

                // Bytte mellom innlogging og registrering
                Button(action: { isSignUp.toggle() }) {
                    Text(
                        isSignUp
                            ? "Har du allerede konto? Logg inn"
                            : "Har du ikke konto? Registrer deg"
                    )
                    .font(.footnote)
                    .foregroundColor(.brand)
                }
                .padding(.top, 10)

                Spacer()
            }
            .padding()
            .navigationBarHidden(true)
        }
    }

    // Utvidet validering av brukerinput
    var isFormValid: Bool {
        let baseValid =
            !email.isEmpty && email.contains("@") && password.count >= 6
        if isSignUp {
            return baseValid && !fullName.isEmpty
        } else {
            return baseValid
        }
    }

    func handleAuth() {
        isLoading = true
        errorMessage = ""

        Task {
            do {
                if isSignUp {
                    try await SupabaseService.signUp(
                        email: email,
                        password: password
                    )

                    // Lagrer navnet lokalt slik at det kan hentes etter innlogging
                    UserDefaults.standard.set(fullName, forKey: "userName")

                    errorMessage = "Konto opprettet! Du kan nå logge inn."
                    isSignUp = false
                } else {
                    _ = try await SupabaseService.signIn(
                        email: email,
                        password: password
                    )

                    // Hvis brukeren logger inn og navnet ikke er satt fra før, kan vi bruke en del av e-posten som fallback
                    if UserDefaults.standard.string(forKey: "userName") == nil
                        || UserDefaults.standard.string(forKey: "userName")
                            == "Reisende"
                    {
                        let nameFromEmail =
                            email.components(separatedBy: "@").first
                            ?? "Reisende"
                        UserDefaults.standard.set(
                            nameFromEmail.capitalized,
                            forKey: "userName"
                        )
                    }

                    isAuthenticated = true
                }
            } catch {
                errorMessage = "Noe gikk galt. Sjekk opplysningene dine."
            }
            isLoading = false
        }
    }
}

#Preview {
    LoginView(isAuthenticated: .constant(false))
}
