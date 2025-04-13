import SwiftUI

struct SignUpView: View {
    @EnvironmentObject private var authService: AuthenticationService
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showingAlert = false
    @State private var isLoading = false
    @State private var emailError: String?
    @State private var hasAttemptedSignup = false
    @FocusState private var isEmailFocused: Bool
    @FocusState private var isPasswordFocused: Bool
    @FocusState private var isConfirmPasswordFocused: Bool
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    
    private var backgroundColor: Color {
        colorScheme == .dark ? Color(red: 0.15, green: 0.15, blue: 0.15) : Color(.systemGroupedBackground)
    }
    
    private var textFieldBackgroundColor: Color {
        colorScheme == .dark ? Color(red: 0.25, green: 0.25, blue: 0.25) : Color(.systemBackground)
    }
    
    private var isEmailValid: Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    private var isSignUpButtonDisabled: Bool {
        email.isEmpty || password.isEmpty || confirmPassword.isEmpty || (!isEmailValid && hasAttemptedSignup)
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
    
    private struct CustomButtonStyle: ViewModifier {
        let backgroundColor: Color
        let foregroundColor: Color
        let hasBorder: Bool
        let isLoading: Bool
        
        func body(content: Content) -> some View {
            content
                .font(.headline)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .contentShape(Rectangle())
                .background(backgroundColor)
                .foregroundColor(foregroundColor)
                .cornerRadius(12)
                .overlay(
                    Group {
                        if hasBorder {
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        }
                    }
                )
                .overlay(
                    Group {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: foregroundColor))
                        }
                    }
                )
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Image("AppLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                        .clipShape(RoundedRectangle(cornerRadius: 30))
                        .shadow(color: Color.black.opacity(0.15), radius: 12, x: 0, y: 6)
                    Text("Create Account")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                }
                .padding(.top, 20)
                
                // Sign Up Form
                VStack(spacing: 16) {
                    // Email Input
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "envelope.circle.fill")
                                .font(.title)
                                .foregroundColor(.blue)
                            TextField("Email", text: $email)
                                .textFieldStyle(CustomTextFieldStyle(backgroundColor: textFieldBackgroundColor))
                                .font(.body)
                                .frame(height: 50)
                                .autocapitalization(.none)
                                .keyboardType(.emailAddress)
                                .textContentType(.emailAddress)
                                .disableAutocorrection(true)
                                .focused($isEmailFocused)
                                .onChange(of: email) { _ in
                                    if hasAttemptedSignup && !isEmailValid {
                                        emailError = "Enter a valid email address"
                                    } else {
                                        emailError = nil
                                    }
                                }
                        }
                        .padding(.vertical, 8)
                        
                        if let error = emailError {
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.red)
                                .padding(.leading, 40)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Password Input
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "lock.circle.fill")
                                .font(.title)
                                .foregroundColor(.blue)
                            SecureField("Password", text: $password)
                                .textFieldStyle(CustomTextFieldStyle(backgroundColor: textFieldBackgroundColor))
                                .font(.body)
                                .frame(height: 50)
                                .textContentType(.newPassword)
                                .focused($isPasswordFocused)
                        }
                        .padding(.vertical, 8)
                    }
                    .padding(.horizontal)
                    
                    // Confirm Password Input
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "lock.circle.fill")
                                .font(.title)
                                .foregroundColor(.blue)
                            SecureField("Confirm Password", text: $confirmPassword)
                                .textFieldStyle(CustomTextFieldStyle(backgroundColor: textFieldBackgroundColor))
                                .font(.body)
                                .frame(height: 50)
                                .textContentType(.newPassword)
                                .focused($isConfirmPasswordFocused)
                        }
                        .padding(.vertical, 8)
                    }
                    .padding(.horizontal)
                    
                    // Sign Up Button
                    Button(action: {
                        isEmailFocused = false
                        isPasswordFocused = false
                        isConfirmPasswordFocused = false
                        hasAttemptedSignup = true
                        
                        if !isEmailValid {
                            emailError = "Enter a valid email address"
                            return
                        }
                        
                        if password != confirmPassword {
                            authService.errorMessage = "Passwords do not match"
                            showingAlert = true
                            return
                        }
                        
                        isLoading = true
                        authService.signUp(email: email, password: password) { success in
                            isLoading = false
                            if !success {
                                showingAlert = true
                            }
                        }
                    }) {
                        HStack {
                            Image(systemName: "person.crop.circle.badge.plus")
                            Text("Sign Up")
                        }
                        .opacity(isLoading ? 0 : 1)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .modifier(CustomButtonStyle(
                        backgroundColor: isSignUpButtonDisabled ? .gray.opacity(0.5) : .blue,
                        foregroundColor: .white,
                        hasBorder: false,
                        isLoading: isLoading
                    ))
                    .disabled(isSignUpButtonDisabled || isLoading)
                    .padding(.horizontal)
                }
            }
            .padding()
        }
        .background(backgroundColor)
        .alert(isPresented: $showingAlert) {
            Alert(
                title: Text("Error"),
                message: Text(authService.errorMessage ?? "An error occurred"),
                dismissButton: .default(Text("OK"))
            )
        }
    }
} 