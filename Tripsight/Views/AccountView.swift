import SwiftUI

struct AccountView: View {
    @EnvironmentObject private var authService: AuthenticationService
    @Environment(\.colorScheme) private var colorScheme
    @State private var showingAlert = false
    @State private var showingPasswordChange = false
    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    
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
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Profile Header
                VStack(spacing: 16) {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.blue)
                    
                    if let email = authService.user?.email {
                        Text(email)
                            .font(.system(size: 18, weight: .medium, design: .rounded))
                    }
                }
                .padding(.top, 20)
                
                // Account Actions
                VStack(spacing: 16) {
                    // Change Password
                    Button(action: {
                        showingPasswordChange = true
                    }) {
                        HStack {
                            Image(systemName: "lock.fill")
                                .font(.title2)
                            Text("Change Password")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(cardBackgroundColor)
                        .cornerRadius(12)
                    }
                    
                    // Sign Out
                    Button(action: {
                        authService.signOut()
                    }) {
                        HStack {
                            Image(systemName: "arrow.right.square.fill")
                                .font(.title2)
                            Text("Sign Out")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(cardBackgroundColor)
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal)
            }
            .padding()
        }
        .background(backgroundColor)
        .sheet(isPresented: $showingPasswordChange) {
            NavigationView {
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 8) {
                            Image(systemName: "lock.circle.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.blue)
                            Text("Change Password")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                        }
                        .padding(.top, 20)
                        
                        // Password Change Form
                        VStack(spacing: 16) {
                            // Current Password
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Image(systemName: "lock.fill")
                                        .font(.title)
                                        .foregroundColor(.blue)
                                    SecureField("Current Password", text: $currentPassword)
                                        .textFieldStyle(CustomTextFieldStyle(backgroundColor: textFieldBackgroundColor))
                                        .font(.body)
                                        .frame(height: 50)
                                }
                                .padding(.vertical, 8)
                            }
                            .padding(.horizontal)
                            
                            // New Password
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Image(systemName: "lock.fill")
                                        .font(.title)
                                        .foregroundColor(.blue)
                                    SecureField("New Password", text: $newPassword)
                                        .textFieldStyle(CustomTextFieldStyle(backgroundColor: textFieldBackgroundColor))
                                        .font(.body)
                                        .frame(height: 50)
                                }
                                .padding(.vertical, 8)
                            }
                            .padding(.horizontal)
                            
                            // Confirm New Password
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Image(systemName: "lock.fill")
                                        .font(.title)
                                        .foregroundColor(.blue)
                                    SecureField("Confirm New Password", text: $confirmPassword)
                                        .textFieldStyle(CustomTextFieldStyle(backgroundColor: textFieldBackgroundColor))
                                        .font(.body)
                                        .frame(height: 50)
                                }
                                .padding(.vertical, 8)
                            }
                            .padding(.horizontal)
                            
                            // Change Password Button
                            Button(action: {
                                if newPassword == confirmPassword {
                                    // TODO: Implement password change
                                    showingPasswordChange = false
                                } else {
                                    authService.errorMessage = "New passwords do not match"
                                    showingAlert = true
                                }
                            }) {
                                HStack {
                                    Image(systemName: "lock.rotation")
                                    Text("Change Password")
                                }
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding()
                }
                .background(backgroundColor)
                .navigationTitle("Change Password")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Cancel") {
                            showingPasswordChange = false
                        }
                    }
                }
            }
        }
        .alert(isPresented: $showingAlert) {
            Alert(
                title: Text("Error"),
                message: Text(authService.errorMessage ?? "An error occurred"),
                dismissButton: .default(Text("OK"))
            )
        }
    }
} 