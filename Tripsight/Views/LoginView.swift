import SwiftUI

struct LoginView: View {
    @StateObject private var authService = AuthenticationService()
    @State private var email = ""
    @State private var password = ""
    @State private var showingAlert = false
    @State private var isLoading = false
    @State private var isGoogleLoading = false
    @State private var emailError: String?
    @State private var hasAttemptedLogin = false
    @FocusState private var isEmailFocused: Bool
    @FocusState private var isPasswordFocused: Bool
    @Environment(\.colorScheme) private var colorScheme
    
    private var backgroundColor: Color {
        colorScheme == .dark ? Color(red: 0.15, green: 0.15, blue: 0.15) : Color(.systemGroupedBackground)
    }
    
    private var textFieldBackgroundColor: Color {
        colorScheme == .dark ? Color(red: 0.25, green: 0.25, blue: 0.25) : Color(.systemBackground)
    }
    
    private var googleButtonBackgroundColor: Color {
        colorScheme == .dark ? Color(red: 0.25, green: 0.25, blue: 0.25) : Color(red: 0.98, green: 0.98, blue: 0.98)
    }
    
    private var googleButtonTextColor: Color {
        colorScheme == .dark ? Color.white : Color.black
    }
    
    private var isLoginButtonDisabled: Bool {
        email.isEmpty || password.isEmpty
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
        NavigationView {
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
                        Text("Welcome Back")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                    }
                    .padding(.top, 20)
                    
                    // Login Form
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
                            }
                            .padding(.vertical, 8)
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
                                    .textContentType(.password)
                                    .focused($isPasswordFocused)
                            }
                            .padding(.vertical, 8)
                            
                            // Remember Me Checkbox
                            Toggle(isOn: $authService.rememberMe) {
                                Text("Remember Me")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            .toggleStyle(CheckboxToggleStyle())
                            .padding(.leading, 40)
                        }
                        .padding(.horizontal)
                        
                        // Login Button
                        Button(action: {
                            isEmailFocused = false
                            isPasswordFocused = false
                            isLoading = true
                            authService.signIn(email: email, password: password) { success in
                                isLoading = false
                                if !success {
                                    authService.errorMessage = "Incorrect email or password"
                                    showingAlert = true
                                }
                            }
                        }) {
                            HStack {
                                Image(systemName: "arrow.right.circle.fill")
                                Text("Log In")
                            }
                            .opacity(isLoading ? 0 : 1)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .modifier(CustomButtonStyle(
                            backgroundColor: isLoginButtonDisabled ? .gray.opacity(0.5) : .blue,
                            foregroundColor: .white,
                            hasBorder: false,
                            isLoading: isLoading
                        ))
                        .disabled(isLoginButtonDisabled || isLoading)
                        .padding(.horizontal)
                        
                        // Divider
                        HStack {
                            Rectangle()
                                .frame(height: 1)
                                .foregroundColor(.gray.opacity(0.3))
                            Text("OR")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            Rectangle()
                                .frame(height: 1)
                                .foregroundColor(.gray.opacity(0.3))
                        }
                        .padding(.horizontal)
                        
                        // Google Sign-In Button
                        Button(action: {
                            isEmailFocused = false
                            isPasswordFocused = false
                            isGoogleLoading = true
                            authService.signInWithGoogle { success in
                                isGoogleLoading = false
                                if !success {
                                    showingAlert = true
                                }
                            }
                        }) {
                            HStack(spacing: 12) {
                                Image("GoogleLogo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 24, height: 24)
                                Text("Continue with Google")
                            }
                            .opacity(isGoogleLoading ? 0 : 1)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .modifier(CustomButtonStyle(backgroundColor: googleButtonBackgroundColor, foregroundColor: googleButtonTextColor, hasBorder: true, isLoading: isGoogleLoading))
                        .disabled(isGoogleLoading)
                        .padding(.horizontal)
                        
                        // Sign Up Link
                        NavigationLink(destination: SignUpView().environmentObject(authService)) {
                            HStack {
                                Image(systemName: "person.crop.circle.badge.plus")
                                Text("Don't have an account? Sign Up")
                            }
                            .font(.headline)
                            .foregroundColor(.blue)
                            .padding(.top, 8)
                        }
                    }
                }
                .padding()
            }
            .background(backgroundColor)
            .navigationBarHidden(true)
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

struct CheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            Image(systemName: configuration.isOn ? "checkmark.square.fill" : "square")
                .foregroundColor(configuration.isOn ? .blue : .gray)
                .font(.system(size: 20, weight: .regular, design: .default))
                .onTapGesture {
                    configuration.isOn.toggle()
                }
            configuration.label
            Spacer()
        }
    }
} 