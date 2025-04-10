//
//  ContentView.swift
//  Tripsight
//
//  Created by Rithvik Boyana on 4/9/25.
//

import SwiftUI

struct ContentView: View {
    @State private var destination = ""
    @State private var interests: [String] = []
    @State private var currentInterest = ""
    @State private var days = 3
    @State private var isLoading = false
    @State private var errorMessage: String? = nil
    @State private var itinerary: [DayItinerary] = []
    @State private var daysError = false
    @FocusState private var isInterestFieldFocused: Bool
    @State private var showItinerary = false
    
    let networkService: NetworkServiceProtocol
    
    init(networkService: NetworkServiceProtocol = NetworkService.shared) {
        print("ContentView initialized with networkService: \(type(of: networkService))")
        self.networkService = networkService
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "airplane.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                        Text("Tripsight")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                    }
                    .padding(.top)
                    
                    // Input Form
                    VStack(spacing: 12) {
                        // Destination Input
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "mappin.circle.fill")
                                    .font(.title)
                                    .foregroundColor(.blue)
                                TextField("Enter destination", text: $destination)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .font(.body)
                                    .frame(height: 50)
                            }
                            .padding(.vertical, 8)
                        }
                        .padding(.horizontal)
                        
                        // Interests Input
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "heart.circle.fill")
                                    .font(.title)
                                    .foregroundColor(.blue)
                                TextField("Add interest and press enter", text: $currentInterest)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .font(.body)
                                    .frame(height: 50)
                                    .focused($isInterestFieldFocused)
                                    .onSubmit {
                                        addInterest()
                                        isInterestFieldFocused = true
                                    }
                            }
                            .padding(.vertical, 8)
                            
                            // Tags View
                            if !interests.isEmpty {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 8) {
                                        ForEach(interests, id: \.self) { interest in
                                            HStack(spacing: 4) {
                                                Text(interest)
                                                    .font(.subheadline)
                                                Button(action: {
                                                    removeInterest(interest)
                                                }) {
                                                    Image(systemName: "xmark.circle.fill")
                                                        .foregroundColor(.gray)
                                                }
                                            }
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(Color.blue.opacity(0.1))
                                            .cornerRadius(15)
                                            .transition(.asymmetric(
                                                insertion: .scale(scale: 0.8).combined(with: .opacity),
                                                removal: .scale(scale: 0.8).combined(with: .opacity)
                                            ))
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: interests)
                            }
                        }
                        .padding(.horizontal)
                        
                        // Days Input
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "calendar.circle.fill")
                                    .font(.title)
                                    .foregroundColor(.blue)
                                TextField("Number of days (2-10)", value: $days, formatter: NumberFormatter())
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .font(.body)
                                    .keyboardType(.numberPad)
                                    .frame(height: 50)
                                    .onChange(of: days) { newValue in
                                        daysError = newValue < 2 || newValue > 10
                                    }
                                
                                HStack(spacing: 8) {
                                    Button(action: {
                                        if days > 2 {
                                            days -= 1
                                        }
                                    }) {
                                        Image(systemName: "minus.circle.fill")
                                            .font(.title)
                                            .foregroundColor(days <= 2 || daysError ? .gray : .blue)
                                    }
                                    .disabled(days <= 2 || daysError)
                                    
                                    Button(action: {
                                        if days < 10 {
                                            days += 1
                                        }
                                    }) {
                                        Image(systemName: "plus.circle.fill")
                                            .font(.title)
                                            .foregroundColor(days >= 10 || daysError ? .gray : .blue)
                                    }
                                    .disabled(days >= 10 || daysError)
                                }
                                .padding(.leading, 8)
                            }
                            .padding(.vertical, 8)
                            
                            if daysError {
                                HStack {
                                    Image(systemName: "exclamationmark.circle.fill")
                                        .foregroundColor(.red)
                                    Text("Please enter a valid number of days (between 2-10)")
                                        .foregroundColor(.red)
                                        .font(.subheadline)
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        // Generate Button
                        Button(action: generateItinerary) {
                            HStack {
                                if isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Image(systemName: "wand.and.stars")
                                    Text("Generate Itinerary")
                                }
                            }
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(daysError ? Color.gray : Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        .disabled(daysError || isLoading)
                        .padding(.horizontal)
                    }
                    
                    // Error Message
                    if let error = errorMessage {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.red)
                            Text(error)
                                .foregroundColor(.red)
                                .font(.footnote)
                        }
                        .padding()
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarTitleDisplayMode(.inline)
            .fullScreenCover(isPresented: $showItinerary) {
                ItineraryView(itinerary: itinerary, destination: destination, interests: interests, days: days)
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
    
    private func addInterest() {
        let trimmedInterest = currentInterest.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedInterest.isEmpty && !interests.contains(trimmedInterest) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                interests.append(trimmedInterest)
            }
        }
        currentInterest = ""
        isInterestFieldFocused = true
    }
    
    private func removeInterest(_ interest: String) {
        withAnimation(.easeOut(duration: 0.2)) {
            interests.removeAll { $0 == interest }
        }
    }
    
    private func generateItinerary() {
        // Validate days before proceeding
        guard days >= 2 && days <= 10 else {
            daysError = true
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        let request = TripRequest(
            destination: destination,
            interests: interests,
            days: days
        )
        
        Task {
            do {
                print("ContentView: Starting itinerary generation")
                let response = try await networkService.generateItinerary(request: request)
                print("ContentView: Received response from network service")
                let daysData = parseItinerary(response.itinerary)
                await MainActor.run {
                    itinerary = daysData
                    isLoading = false
                    showItinerary = true
                }
            } catch {
                print("ContentView: Error generating itinerary: \(error)")
                await MainActor.run {
                    errorMessage = "Error generating itinerary: \(error.localizedDescription)"
                    isLoading = false
                }
            }
        }
    }
    
    private func parseItinerary(_ response: String) -> [DayItinerary] {
        // Split the response into days
        let daysArray = response.components(separatedBy: "Day ")
            .filter { !$0.isEmpty }
            .map { "Day " + $0 }
        
        return daysArray.map { dayContent in
            // Split the day content into lines
            let lines = dayContent.components(separatedBy: .newlines)
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
            
            // The first line is the day title
            let title = lines[0]
            
            // Process the rest of the lines
            var sections: [String] = []
            var currentSection = ""
            
            for line in lines.dropFirst() {
                if line.hasPrefix("Morning:") || line.hasPrefix("Afternoon:") || 
                   line.hasPrefix("Evening:") || line.hasPrefix("Night:") {
                    // If we have a previous section, add it
                    if !currentSection.isEmpty {
                        sections.append(currentSection.trimmingCharacters(in: .whitespacesAndNewlines))
                    }
                    currentSection = line
                } else if line.hasPrefix("-") {
                    // Remove the hyphen and any leading whitespace
                    let cleanedLine = line.replacingOccurrences(of: "^\\s*-\\s*", with: "", options: .regularExpression)
                    currentSection += "\n" + cleanedLine
                }
            }
            
            // Add the last section if it exists
            if !currentSection.isEmpty {
                sections.append(currentSection.trimmingCharacters(in: .whitespacesAndNewlines))
            }
            
            return DayItinerary(title: title, sections: sections)
        }
    }
}

struct ItineraryView: View {
    let itinerary: [DayItinerary]
    let destination: String
    let interests: [String]
    let days: Int
    
    @State private var currentDayIndex = 0
    @Environment(\.dismiss) private var dismiss
    
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
                            Text("Your Query")
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
                    .background(Color(.systemBackground))
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
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .background(Color(.systemGroupedBackground))
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

#Preview {
    ContentView(networkService: NetworkService.shared)
        .previewDevice("iPhone 16 Pro")
}
