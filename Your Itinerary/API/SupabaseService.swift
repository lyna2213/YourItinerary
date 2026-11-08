//  SupabaseService.swift
//  Your Itinerary
//
//  Created by Lyn A on 24/10/2026.
//

import Foundation

class SupabaseService {
    
    static let supabaseURL = "https://nxvlgopznbfvfxkstsnm.supabase.co/rest/v1/destinations"
    static let authURL = "https://nxvlgopznbfvfxkstsnm.supabase.co/auth/v1"
    static let apiKey = "sb_publishable_jQvMOHMLytqjjnG6TrVSaw_EvmcAvHA"

    // ==========================================
    // MARK: - AUTENTISERING (Supabase Auth)
    // ==========================================

    // Logg inn bruker
        static func signIn(email: String, password: String) async throws -> String {
            guard let url = URL(string: "\(authURL)/token?grant_type=password") else {
                throw URLError(.badURL)
            }

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue(apiKey, forHTTPHeaderField: "apikey")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

            let body: [String: Any] = ["email": email, "password": password]
            request.httpBody = try JSONSerialization.data(withJSONObject: body)

            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                if let errorString = String(data: data, encoding: .utf8) {
                    print("🔴 INNLOGGING FEIL: \(errorString)")
                }
                throw URLError(.badServerResponse) // Rettet til vanlig parentes her
            }

            // Henter ut access_token fra responsen
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            guard let accessToken = json?["access_token"] as? String else {
                throw URLError(.cannotDecodeRawData) // Endret fra .cannotDecodeContent til .cannotDecodeRawData
            }

            return accessToken
        }

    // Registrer ny bruker
    static func signUp(email: String, password: String) async throws {
        guard let url = URL(string: "\(authURL)/signup") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(apiKey, forHTTPHeaderField: "apikey")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = ["email": email, "password": password]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            if let errorString = String(data: data, encoding: .utf8) {
                print("🔴 REGISTRERING FEIL: \(errorString)")
            }
            throw URLError(.badServerResponse)
        }
    }

    // ==========================================
    // MARK: - CRUD OPERASJONER (Destinations)
    // ==========================================

    // Funksjon for å HENTE data fra Supabase (GET)
    static func fetchDestinations() async throws -> [SupabaseDestination] {
        guard let url = URL(string: SupabaseService.supabaseURL) else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        request.setValue(SupabaseService.apiKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(SupabaseService.apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            if let errorString = String(data: data, encoding: .utf8) {
                print("🔴 SUPABASE GET FEIL: \(errorString)")
            }
            throw URLError(.badServerResponse)
        }

        let destinations = try JSONDecoder().decode([SupabaseDestination].self, from: data)
        return destinations
    }

    // Funksjon for å SENDE/OPPRETTE ny data i Supabase (POST) - med tidsplan (items)
    static func createDestination(title: String, country: String, description: String, imageName: String, items: [ItineraryItem]) async throws {
        guard let url = URL(string: SupabaseService.supabaseURL) else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        request.setValue(SupabaseService.apiKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(SupabaseService.apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("return=representation", forHTTPHeaderField: "Prefer")

        // Konverterer ItineraryItem-objekter til JSON som Supabase lagrer i jsonb-kolonnen
        let itemsData = try JSONEncoder().encode(items)
        let itemsJSON = try JSONSerialization.jsonObject(with: itemsData)

        let newRecord: [String: Any] = [
            "title": title,
            "country": country,
            "description": description,
            "image_name": imageName,
            "items": itemsJSON
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: newRecord)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            if let errorString = String(data: data, encoding: .utf8) {
                print("🔴 SUPABASE POST FEIL: \(errorString)")
            }
            throw URLError(.badServerResponse)
        }
        
        print("Data ble suksessfullt opprettet i Supabase!")
    }

    // Funksjon for å SLETTE data fra Supabase (DELETE)
    static func deleteDestination(id: Int) async throws {
        guard let url = URL(string: "\(SupabaseService.supabaseURL)?id=eq.\(id)") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        request.setValue(SupabaseService.apiKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(SupabaseService.apiKey)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            if let errorString = String(data: data, encoding: .utf8) {
                print("🔴 SUPABASE DELETE FEIL: \(errorString)")
            }
            throw URLError(.badServerResponse)
        }
        
        print("Reise ble slettet fra Supabase!")
    }
    
    // Funksjon for å OPPDATERE data i Supabase (PATCH) - med tidsplan (items)
    static func updateDestination(id: Int, title: String, country: String, description: String, imageName: String, items: [ItineraryItem]) async throws {
        guard let url = URL(string: "\(SupabaseService.supabaseURL)?id=eq.\(id)") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        
        request.setValue(SupabaseService.apiKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(SupabaseService.apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Konverterer tidsplan-listen til JSON for jsonb-kolonnen
        let itemsData = try JSONEncoder().encode(items)
        let itemsJSON = try JSONSerialization.jsonObject(with: itemsData)

        let updatedRecord: [String: Any] = [
            "title": title,
            "country": country,
            "description": description,
            "image_name": imageName,
            "items": itemsJSON
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: updatedRecord)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            if let errorString = String(data: data, encoding: .utf8) {
                print("🔴 SUPABASE PATCH FEIL: \(errorString)")
            }
            throw URLError(.badServerResponse)
        }
        
        print("Reise ble oppdatert i Supabase med tidsplan!")
    }
}
