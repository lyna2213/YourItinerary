//
//  Itinerary.swift
//  Your Itinerary
//
//  Created by Lyn A on 14/09/2026.
//

import Foundation

struct ItineraryItem: Identifiable {
    let id = UUID()
    var day: String
    var activity: String
    var location: String
}

struct Destination: Identifiable {
    let id = UUID()
    var title: String
    var country: String
    var imageName: String
    var items: [ItineraryItem]
}
