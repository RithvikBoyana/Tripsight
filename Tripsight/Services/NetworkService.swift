import Foundation

protocol NetworkServiceProtocol {
    func generateItinerary(request: TripRequest) async throws -> TripResponse
}

class NetworkService: NetworkServiceProtocol {
    static let shared = NetworkService()
    
    // Dummy URL - replace with actual backend URL later
    private let baseURL = "https://tripsight-backend.onrender.com"
    
    init() {
        print("NetworkService initialized")
    }
    
    func generateItinerary(request: TripRequest) async throws -> TripResponse {
        guard let url = URL(string: "\(baseURL)/generate-itinerary") else {
            throw NetworkError.invalidURL
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        urlRequest.httpBody = try encoder.encode(request)
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        if httpResponse.statusCode == 200 {
            let decoder = JSONDecoder()
            let tripResponse = try decoder.decode(TripResponse.self, from: data)
            return tripResponse
        } else {
            throw NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Server error"])
        }
    }
}

enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case decodingError
} 
