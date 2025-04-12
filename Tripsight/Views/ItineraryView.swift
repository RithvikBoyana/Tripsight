import SwiftUI

struct ItineraryView: View {
    let itinerary: [DayItinerary]
    let destination: String
    let interests: [String]
    let days: Int
    
    @State private var currentDayIndex = 0
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    
    private var backgroundColor: Color {
        colorScheme == .dark ? Color(red: 0.15, green: 0.15, blue: 0.15) : Color(.systemGroupedBackground)
    }
    
    private var cardBackgroundColor: Color {
        colorScheme == .dark ? Color(red: 0.2, green: 0.2, blue: 0.2) : Color(.systemBackground)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Query Summary
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .font(.title3)
                                .foregroundColor(.blue)
                            Text("Your Trip Details")
                                .font(.title2)
                                .fontWeight(.bold)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(alignment: .top) {
                                Text("Location:")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                Text(destination.isEmpty ? "Not specified" : destination)
                                    .font(.headline)
                            }
                            
                            HStack(alignment: .top) {
                                Text("Interests:")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                if interests.isEmpty {
                                    Text("none")
                                        .font(.headline)
                                        .italic()
                                } else {
                                    Text(interests.joined(separator: ", "))
                                        .font(.headline)
                                }
                            }
                            
                            HStack(alignment: .top) {
                                Text("Days:")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                Text("\(days)")
                                    .font(.headline)
                            }
                        }
                        .padding(.leading, 8)
                    }
                    .padding()
                    .background(cardBackgroundColor)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                    .padding(.horizontal)
                    
                    // Day Card
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            HStack {
                                Image(systemName: "calendar.badge.clock")
                                    .font(.title3)
                                    .foregroundColor(.blue)
                                Text(itinerary[currentDayIndex].title)
                                    .font(.title)
                                    .fontWeight(.bold)
                            }
                            
                            Spacer()
                            
                            HStack(spacing: 16) {
                                Button(action: { if currentDayIndex > 0 { currentDayIndex -= 1 } }) {
                                    Image(systemName: "chevron.left")
                                        .font(.title3)
                                        .foregroundColor(.white)
                                        .padding(8)
                                        .background(currentDayIndex == 0 ? Color.gray : Color.blue)
                                        .cornerRadius(8)
                                }
                                .disabled(currentDayIndex == 0)
                                
                                Button(action: { if currentDayIndex < itinerary.count - 1 { currentDayIndex += 1 } }) {
                                    Image(systemName: "chevron.right")
                                        .font(.title3)
                                        .foregroundColor(.white)
                                        .padding(8)
                                        .background(currentDayIndex == itinerary.count - 1 ? Color.gray : Color.blue)
                                        .cornerRadius(8)
                                }
                                .disabled(currentDayIndex == itinerary.count - 1)
                            }
                        }
                        
                        ForEach(itinerary[currentDayIndex].sections, id: \.self) { section in
                            VStack(alignment: .leading, spacing: 12) {
                                let components = section.components(separatedBy: .newlines)
                                if let timePeriod = components.first {
                                    HStack {
                                        Image(systemName: timePeriodIcon(for: timePeriod))
                                            .font(.title3)
                                            .foregroundColor(.blue)
                                        Text(timePeriod)
                                            .font(.headline)
                                            .foregroundColor(.blue)
                                            .fontWeight(.bold)
                                    }
                                }
                                
                                ForEach(components.dropFirst(), id: \.self) { activity in
                                    HStack(alignment: .top) {
                                        Image(systemName: "circle.fill")
                                            .font(.system(size: 8))
                                            .foregroundColor(.blue)
                                            .padding(.top, 8)
                                        Text(activity)
                                            .font(.body)
                                            .foregroundColor(.primary)
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                    .background(cardBackgroundColor)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .background(backgroundColor)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .foregroundColor(.blue)
                    }
                }
            }
        }
    }
    
    private func timePeriodIcon(for timePeriod: String) -> String {
        if timePeriod.contains("Morning") {
            return "sunrise.fill"
        } else if timePeriod.contains("Afternoon") {
            return "sun.max.fill"
        } else if timePeriod.contains("Evening") {
            return "sunset.fill"
        } else if timePeriod.contains("Night") {
            return "moon.stars.fill"
        }
        return "clock.fill"
    }
} 