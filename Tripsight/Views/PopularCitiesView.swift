import SwiftUI

struct PopularCitiesView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedCity: String
    @State private var expandedCountries: Set<String> = []
    
    // Sample data - you can expand this with more cities and countries
    private let citiesByCountry: [String: [String]] = [
        "United States": ["New York", "Los Angeles", "Chicago", "Miami", "San Francisco", "Las Vegas"],
        "United Kingdom": ["London", "Edinburgh", "Manchester", "Birmingham", "Glasgow"],
        "France": ["Paris", "Nice", "Lyon", "Marseille", "Bordeaux"],
        "Italy": ["Rome", "Venice", "Florence", "Milan", "Naples"],
        "Spain": ["Barcelona", "Madrid", "Seville", "Valencia", "Granada"],
        "Japan": ["Tokyo", "Kyoto", "Osaka", "Hiroshima", "Sapporo"],
        "Australia": ["Sydney", "Melbourne", "Brisbane", "Perth", "Adelaide"],
        "Canada": ["Toronto", "Vancouver", "Montreal", "Calgary", "Ottawa"]
    ]
    
    var body: some View {
        NavigationView {
            List {
                ForEach(citiesByCountry.keys.sorted(), id: \.self) { country in
                    DisclosureGroup(
                        isExpanded: Binding(
                            get: { expandedCountries.contains(country) },
                            set: { isExpanded in
                                if isExpanded {
                                    expandedCountries.insert(country)
                                } else {
                                    expandedCountries.remove(country)
                                }
                            }
                        )
                    ) {
                        ForEach(citiesByCountry[country] ?? [], id: \.self) { city in
                            Button(action: {
                                selectedCity = city
                                dismiss()
                            }) {
                                HStack {
                                    Text(city)
                                        .foregroundColor(.primary)
                                    Spacer()
                                    if selectedCity == city {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.blue)
                                    }
                                }
                            }
                            .padding(.leading, 8)
                        }
                    } label: {
                        HStack {
                            Text(country)
                                .font(.headline)
                            Spacer()
                            Text("\(citiesByCountry[country]?.count ?? 0) cities")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .navigationTitle("Popular Cities")
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
} 