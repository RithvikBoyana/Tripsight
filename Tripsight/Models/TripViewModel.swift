import SwiftUI
import Combine

class TripViewModel: ObservableObject {
    @Published var destination = ""
    @Published var interests: [String] = []
    @Published var currentInterest = ""
    @Published var days = 3
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    @Published var itinerary: [DayItinerary] = []
    @Published var daysError = false
    @Published var showItinerary = false
    @Published var showPopularCities = false
    @Published var showPopularInterests = false
    @Published var showLoadingTimeout = false
    @Published var rotationAngle: Double = 0
    
    private var animationTimer: Timer?
    private let networkService: NetworkServiceProtocol
    
    init(networkService: NetworkServiceProtocol = NetworkService.shared) {
        self.networkService = networkService
    }
    
    func addInterest() {
        let trimmedInterest = currentInterest.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedInterest.isEmpty && !interests.contains(trimmedInterest) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                interests.append(trimmedInterest)
            }
        }
        currentInterest = ""
    }
    
    func removeInterest(_ interest: String) {
        withAnimation(.easeOut(duration: 0.2)) {
            interests.removeAll { $0 == interest }
        }
    }
    
    func clearInterests() {
        withAnimation(.easeOut(duration: 0.2)) {
            interests.removeAll()
        }
    }
    
    func generateItinerary() {
        // Validate days before proceeding
        guard days >= 1 && days <= 20 else {
            daysError = true
            return
        }
        
        isLoading = true
        errorMessage = nil
        showLoadingTimeout = false
        
        // Start animation timer
        animationTimer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.rotationAngle += 0.04
            if self.rotationAngle >= 2 * .pi {
                self.rotationAngle = 0
            }
        }
        
        // Start timeout timer
        let timeoutTask = Task {
            try? await Task.sleep(nanoseconds: 8_000_000_000) // 8 seconds
            if !Task.isCancelled {
                await MainActor.run {
                    showLoadingTimeout = true
                }
            }
        }
        
        let request = TripRequest(
            destination: destination,
            interests: interests,
            days: days
        )
        
        Task {
            do {
                let response = try await networkService.generateItinerary(request: request)
                timeoutTask.cancel()
                let daysData = parseItinerary(response.itinerary)
                await MainActor.run {
                    itinerary = daysData
                    isLoading = false
                    showItinerary = true
                    animationTimer?.invalidate()
                    animationTimer = nil
                }
            } catch {
                timeoutTask.cancel()
                await MainActor.run {
                    errorMessage = "Error generating itinerary: \(error.localizedDescription)"
                    isLoading = false
                    animationTimer?.invalidate()
                    animationTimer = nil
                }
            }
        }
    }
    
    private func parseItinerary(_ response: String) -> [DayItinerary] {
        let daysArray = response.components(separatedBy: "Day ")
            .filter { !$0.isEmpty }
            .map { "Day " + $0 }
        
        return daysArray.map { dayContent in
            let lines = dayContent.components(separatedBy: .newlines)
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
            
            let title = lines[0]
            var sections: [String] = []
            var currentSection = ""
            
            for line in lines.dropFirst() {
                if line.hasPrefix("Morning:") || line.hasPrefix("Afternoon:") || 
                   line.hasPrefix("Evening:") || line.hasPrefix("Night:") {
                    if !currentSection.isEmpty {
                        sections.append(currentSection.trimmingCharacters(in: .whitespacesAndNewlines))
                    }
                    currentSection = line
                } else if line.hasPrefix("-") {
                    let cleanedLine = line.replacingOccurrences(of: "^\\s*-\\s*", with: "", options: .regularExpression)
                    currentSection += "\n" + cleanedLine
                }
            }
            
            if !currentSection.isEmpty {
                sections.append(currentSection.trimmingCharacters(in: .whitespacesAndNewlines))
            }
            
            return DayItinerary(title: title, sections: sections)
        }
    }
    
    deinit {
        animationTimer?.invalidate()
    }
} 