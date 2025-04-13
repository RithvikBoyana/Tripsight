import Foundation
import FirebaseAuth
import FirebaseCore
import GoogleSignIn

class AuthenticationService: ObservableObject {
    @Published var user: User?
    @Published var errorMessage: String?
    @Published var rememberMe: Bool = false {
        didSet {
            UserDefaults.standard.set(rememberMe, forKey: "rememberMe")
        }
    }
    
    private let userDefaults = UserDefaults.standard
    
    init() {
        self.rememberMe = userDefaults.bool(forKey: "rememberMe")
        setupAuthStateListener()
        
        if rememberMe {
            // Try to restore the previous session
            if let user = Auth.auth().currentUser {
                self.user = user
            }
        }
    }
    
    private func setupAuthStateListener() {
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            if let self = self {
                self.user = user
                if self.rememberMe {
                    // Store the user's email for auto-login
                    if let email = user?.email {
                        self.userDefaults.set(email, forKey: "lastLoggedInEmail")
                    }
                } else {
                    // Clear stored email if remember me is off
                    self.userDefaults.removeObject(forKey: "lastLoggedInEmail")
                }
            }
        }
    }
    
    // MARK: - Email Authentication
    func signUp(email: String, password: String, completion: @escaping (Bool) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                self?.errorMessage = error.localizedDescription
                completion(false)
                return
            }
            completion(true)
        }
    }
    
    func signIn(email: String, password: String, completion: @escaping (Bool) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                self?.errorMessage = error.localizedDescription
                completion(false)
                return
            }
            completion(true)
        }
    }
    
    // MARK: - Google Sign-In
    func signInWithGoogle(completion: @escaping (Bool) -> Void) {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            errorMessage = "Firebase configuration error"
            completion(false)
            return
        }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootViewController = window.rootViewController else {
            errorMessage = "No root view controller found"
            completion(false)
            return
        }
        
        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { [weak self] result, error in
            if let error = error {
                self?.errorMessage = error.localizedDescription
                completion(false)
                return
            }
            
            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString else {
                self?.errorMessage = "Failed to get ID token"
                completion(false)
                return
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                         accessToken: user.accessToken.tokenString)
            
            Auth.auth().signIn(with: credential) { [weak self] result, error in
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    completion(false)
                    return
                }
                completion(true)
            }
        }
    }
    
    // MARK: - Sign Out
    func signOut() {
        do {
            try Auth.auth().signOut()
            GIDSignIn.sharedInstance.signOut()
            if !rememberMe {
                userDefaults.removeObject(forKey: "lastLoggedInEmail")
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
} 
