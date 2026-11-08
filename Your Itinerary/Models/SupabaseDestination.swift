//
//  SupabaseDestination.swift
//  Your Itinerary
//
//  Created by Lyn A on 24/10/2026.
//

import Foundation

struct SupabaseDestination: Codable, Identifiable {
    let id: Int
    let title: String
    let country: String
    let description: String?
    let imageName: String?
    let items: [ItineraryItem]? // Henter tidsplanen direkte fra JSON-kolonnen!

    enum CodingKeys: String, CodingKey {
        case id, title, country, description
        case imageName = "image_name"
        case items
    }
}
