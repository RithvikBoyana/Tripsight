import SwiftUI

struct PopularInterestsView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedInterests: [String]
    @State private var expandedCategories: Set<String> = []
    
    // Sample data - you can expand this with more interests and categories
    private let interestsByCategory: [String: [String]] = [
        "Outdoor Activities": ["Hiking", "Beach", "Camping", "Skiing", "Surfing", "Cycling", "Kayaking", "Rock Climbing"],
        "Cultural": ["Museums", "Historical Sites", "Art Galleries", "Local Festivals", "Traditional Music", "Cultural Shows"],
        "Food & Drink": ["Local Cuisine", "Wine Tasting", "Cooking Classes", "Street Food", "Fine Dining", "Food Markets"],
        "Shopping": ["Local Markets", "Shopping Malls", "Souvenirs", "Fashion", "Antiques", "Handicrafts"],
        "Entertainment": ["Nightlife", "Live Music", "Theater", "Cinema", "Theme Parks", "Casinos"],
        "Relaxation": ["Spa", "Yoga", "Meditation", "Beach Relaxation", "Hot Springs", "Massage"],
        "Adventure": ["Scuba Diving", "Paragliding", "Bungee Jumping", "Zip-lining", "Wildlife Safari", "Hot Air Balloon"],
        "Photography": ["Landscape Photography", "Street Photography", "Wildlife Photography", "Architecture", "Sunset/Sunrise"]
    ]
    
    var body: some View {
        NavigationView {
            List {
                ForEach(interestsByCategory.keys.sorted(), id: \.self) { category in
                    DisclosureGroup(
                        isExpanded: Binding(
                            get: { expandedCategories.contains(category) },
                            set: { isExpanded in
                                if isExpanded {
                                    expandedCategories.insert(category)
                                } else {
                                    expandedCategories.remove(category)
                                }
                            }
                        )
                    ) {
                        ForEach(interestsByCategory[category] ?? [], id: \.self) { interest in
                            Button(action: {
                                if selectedInterests.contains(interest) {
                                    selectedInterests.removeAll { $0 == interest }
                                } else {
                                    selectedInterests.append(interest)
                                }
                            }) {
                                HStack {
                                    Text(interest)
                                        .foregroundColor(.primary)
                                    Spacer()
                                    if selectedInterests.contains(interest) {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.blue)
                                    }
                                }
                            }
                            .padding(.leading, 8)
                        }
                    } label: {
                        HStack {
                            Text(category)
                                .font(.headline)
                            Spacer()
                            Text("\(interestsByCategory[category]?.count ?? 0) interests")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .navigationTitle("Popular Interests")
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