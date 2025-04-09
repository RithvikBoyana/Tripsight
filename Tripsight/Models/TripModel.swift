import Foundation

struct TripRequest: Codable {
    let destination: String
    let interests: [String]
    let days: Int
}

struct TripResponse: Codable {
    let itinerary: String
}

struct DayItinerary: Identifiable {
    let id = UUID()
    let title: String
    let sections: [String]
}

struct TimeSection: Identifiable {
    let id = UUID()
    let time: String
    let content: String
} 