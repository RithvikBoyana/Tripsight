//
//  ContentView.swift
//  Tripsight
//
//  Created by Rithvik Boyana on 4/9/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel: TripViewModel
    @FocusState private var isInterestFieldFocused: Bool
    @FocusState private var isDestinationFieldFocused: Bool
    @FocusState private var isDaysFieldFocused: Bool
    @Environment(\.colorScheme) private var colorScheme
    
    private var backgroundColor: Color {
        colorScheme == .dark ? Color(red: 0.15, green: 0.15, blue: 0.15) : Color(.systemGroupedBackground)
    }
    
    private var cardBackgroundColor: Color {
        colorScheme == .dark ? Color(red: 0.2, green: 0.2, blue: 0.2) : Color(.systemBackground)
    }
    
    private var textFieldBackgroundColor: Color {
        colorScheme == .dark ? Color(red: 0.25, green: 0.25, blue: 0.25) : Color(.systemBackground)
    }
    
    private struct CustomTextFieldStyle: TextFieldStyle {
        let backgroundColor: Color
        
        func _body(configuration: TextField<Self._Label>) -> some View {
            configuration
                .padding(10)
                .background(backgroundColor)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
        }
    }
    
    init(networkService: NetworkServiceProtocol = NetworkService.shared) {
        _viewModel = StateObject(wrappedValue: TripViewModel(networkService: networkService))
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    // Header
                    VStack(spacing: 8) {
                        Image("AppLogo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 160, height: 160)
                            .clipShape(RoundedRectangle(cornerRadius: 30))
                            .shadow(color: Color.black.opacity(0.15), radius: 12, x: 0, y: 6)
                        Text("Tripsight")
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                    }
                    .padding(.top, 0)
                    
                    // Input Form
                    VStack(spacing: 8) {
                        // Destination Input
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "mappin.circle.fill")
                                    .font(.title)
                                    .foregroundColor(.blue)
                                TextField("Enter destination", text: $viewModel.destination)
                                    .textFieldStyle(CustomTextFieldStyle(backgroundColor: textFieldBackgroundColor))
                                    .font(.body)
                                    .frame(height: 50)
                                    .focused($isDestinationFieldFocused)
                                    .frame(maxWidth: .infinity)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        isDestinationFieldFocused = true
                                    }
                                Button(action: { viewModel.destination = "" }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.title)
                                        .foregroundColor(viewModel.destination.isEmpty ? .gray : .red)
                                }
                                .disabled(viewModel.destination.isEmpty)
                                Button(action: { viewModel.showPopularCities = true }) {
                                    Image(systemName: "list.bullet.circle.fill")
                                        .font(.title)
                                        .foregroundColor(.blue)
                                }
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
                                TextField("Interests (press enter to add)", text: $viewModel.currentInterest)
                                    .textFieldStyle(CustomTextFieldStyle(backgroundColor: textFieldBackgroundColor))
                                    .font(.body)
                                    .frame(height: 50)
                                    .focused($isInterestFieldFocused)
                                    .onSubmit {
                                        viewModel.addInterest()
                                        isInterestFieldFocused = true
                                    }
                                    .frame(maxWidth: .infinity)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        isInterestFieldFocused = true
                                    }
                                Button(action: viewModel.clearInterests) {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.title)
                                        .foregroundColor(viewModel.interests.isEmpty ? .gray : .red)
                                }
                                .disabled(viewModel.interests.isEmpty)
                                Button(action: { viewModel.showPopularInterests = true }) {
                                    Image(systemName: "list.bullet.circle.fill")
                                        .font(.title)
                                        .foregroundColor(.blue)
                                }
                            }
                            .padding(.vertical, 8)
                            
                            // Tags View
                            if !viewModel.interests.isEmpty {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 8) {
                                        ForEach(viewModel.interests, id: \.self) { interest in
                                            HStack(spacing: 4) {
                                                Text(interest)
                                                    .font(.subheadline)
                                                Button(action: {
                                                    viewModel.removeInterest(interest)
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
                                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: viewModel.interests)
                            }
                        }
                        .padding(.horizontal)
                        
                        // Days Input
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "calendar.circle.fill")
                                    .font(.title)
                                    .foregroundColor(.blue)
                                TextField("Duration (1-20 days)", value: $viewModel.days, formatter: NumberFormatter())
                                    .textFieldStyle(CustomTextFieldStyle(backgroundColor: textFieldBackgroundColor))
                                    .font(.body)
                                    .keyboardType(.numberPad)
                                    .frame(height: 50)
                                    .focused($isDaysFieldFocused)
                                    .frame(maxWidth: .infinity)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        isDaysFieldFocused = true
                                    }
                                    .onChange(of: viewModel.days) { newValue in
                                        viewModel.daysError = newValue < 1 || newValue > 20
                                    }
                                
                                Button(action: {
                                    if viewModel.days > 1 {
                                        viewModel.days -= 1
                                    }
                                }) {
                                    Image(systemName: "minus.circle.fill")
                                        .font(.title)
                                        .foregroundColor(viewModel.days <= 1 || viewModel.daysError ? .gray : .blue)
                                }
                                .disabled(viewModel.days <= 1 || viewModel.daysError)
                                
                                Button(action: {
                                    if viewModel.days < 20 {
                                        viewModel.days += 1
                                    }
                                }) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.title)
                                        .foregroundColor(viewModel.days >= 20 || viewModel.daysError ? .gray : .blue)
                                }
                                .disabled(viewModel.days >= 20 || viewModel.daysError)
                            }
                            .padding(.vertical, 8)
                            
                            if viewModel.daysError {
                                HStack {
                                    Image(systemName: "exclamationmark.circle.fill")
                                        .foregroundColor(.red)
                                    Text("Please enter a valid number of days (between 1-20)")
                                        .foregroundColor(.red)
                                        .font(.subheadline)
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        // Generate Button
                        Button(action: viewModel.generateItinerary) {
                            HStack {
                                if viewModel.isLoading {
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
                            .background(viewModel.daysError || viewModel.destination.isEmpty ? Color.gray : Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        .disabled(viewModel.daysError || viewModel.isLoading || viewModel.destination.isEmpty)
                        .padding(.horizontal)
                    }
                    
                    // Error Message
                    if let error = viewModel.errorMessage {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.red)
                            Text(error)
                                .foregroundColor(.red)
                                .font(.footnote)
                        }
                        .padding(.vertical, 4)
                    }
                    
                    // Loading Animation
                    if viewModel.isLoading {
                        VStack(spacing: 12) {
                            // Animated plane with dotted circle
                            ZStack {
                                // Dotted circle
                                Circle()
                                    .stroke(style: StrokeStyle(lineWidth: 2, dash: [5]))
                                    .foregroundColor(.blue.opacity(0.3))
                                    .frame(width: 80, height: 80)
                                
                                // Animated plane
                                Image(systemName: "airplane")
                                    .font(.system(size: 30))
                                    .foregroundColor(.blue)
                                    .rotationEffect(.degrees(viewModel.rotationAngle * 180 / .pi + 90))
                                    .offset(x: 40 * cos(viewModel.rotationAngle), y: 40 * sin(viewModel.rotationAngle))
                            }
                            .frame(width: 80, height: 80)
                            
                            // Loading message
                            Text("Creating your perfect itinerary...")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            // Timeout message
                            if viewModel.showLoadingTimeout {
                                Text("This is taking longer than usual. Please wait while we generate your itinerary...")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(cardBackgroundColor)
                                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: -2)
                        )
                        .padding(.horizontal)
                        .padding(.bottom, 12)
                        .transition(.asymmetric(
                            insertion: .scale(scale: 0.8).combined(with: .opacity),
                            removal: .scale(scale: 0.8).combined(with: .opacity)
                        ))
                    }
                }
                .padding(.vertical, 8)
            }
            .background(backgroundColor)
            .navigationBarTitleDisplayMode(.inline)
            .fullScreenCover(isPresented: $viewModel.showItinerary) {
                ItineraryView(
                    itinerary: viewModel.itinerary,
                    destination: viewModel.destination,
                    interests: viewModel.interests,
                    days: viewModel.days
                )
            }
            .sheet(isPresented: $viewModel.showPopularCities) {
                PopularCitiesView(selectedCity: $viewModel.destination)
            }
            .sheet(isPresented: $viewModel.showPopularInterests) {
                PopularInterestsView(selectedInterests: $viewModel.interests)
            }
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        isDestinationFieldFocused = false
                        isInterestFieldFocused = false
                        isDaysFieldFocused = false
                    }
                }
            }
            .ignoresSafeArea(.keyboard)
        }
    }
}

#Preview {
    ContentView(networkService: NetworkService.shared)
        .previewDevice("iPhone 16 Pro")
}

#Preview("Dark Mode") {
    ContentView(networkService: NetworkService.shared)
        .previewDevice("iPhone 16 Pro")
        .preferredColorScheme(.dark)
}
