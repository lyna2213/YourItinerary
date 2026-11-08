import Foundation
import SwiftData

@Model
class ItineraryItem: Codable {
    var id: UUID
    var day: String
    var activity: String
    var location: String
    var iconName: String

    init(id: UUID = UUID(), day: String, activity: String, location: String, iconName: String = "star.fill") {
        self.id = id
        self.day = day
        self.activity = activity
        self.location = location
        self.iconName = iconName
    }

    enum CodingKeys: String, CodingKey {
        case id, day, activity, location, iconName
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        self.day = try container.decode(String.self, forKey: .day)
        self.activity = try container.decode(String.self, forKey: .activity)
        self.location = try container.decode(String.self, forKey: .location)
        self.iconName = try container.decodeIfPresent(String.self, forKey: .iconName) ?? "star.fill"
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(day, forKey: .day)
        try container.encode(activity, forKey: .activity)
        try container.encode(location, forKey: .location)
        try container.encode(iconName, forKey: .iconName)
    }
}
