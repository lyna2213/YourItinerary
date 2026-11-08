import Foundation
import SwiftData

@Model
class SavedTrip {
    var title: String
    var country: String
    var tripDescription: String
    var imageName: String
    var isFavorite: Bool 
    
    @Relationship(deleteRule: .cascade)
    var items: [ItineraryItem]

    init(title: String, country: String, tripDescription: String, imageName: String = "London", isFavorite: Bool = false, items: [ItineraryItem] = []) {
        self.title = title
        self.country = country
        self.tripDescription = tripDescription
        self.imageName = imageName
        self.isFavorite = isFavorite
        self.items = items
    }
}
