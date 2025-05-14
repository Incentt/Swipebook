//
//  LoginController.swift
//  Swipebook
//
//  Created by Vincent Wisnata on 14/05/25.
//

import Foundation
import SwiftUI

class LoginController: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isShowingPassword: Bool = false
    @Published var isLoading: Bool = false
    @Published var isAuthenticated: Bool = false
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""
    
    // User token after successful login
    @Published var userToken: String? = nil
    
    // Login function that returns a LoginResponse
    func login() async -> LoginResponse {
        // Basic validation
        if email.isEmpty || password.isEmpty {
            return LoginResponse(
                success: false,
                message: "Email and password are required",
                token: nil
            )
        }
        
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second delay
        
        // Check credentials against mock database
        if let user = MockUserDatabase.shared.findUser(email: email, password: password) {
            // Successful login
            return LoginResponse(
                success: true,
                message: "Login successful",
                token: user.token
            )
        } else {
            // Failed login
            return LoginResponse(
                success: false,
                message: "Invalid email or password",
                token: nil
            )
        }
    }
    
    // Handle login response
    func handleLoginResponse(_ response: LoginResponse) {
        if response.success {
            // Set authentication state
            isAuthenticated = true
            userToken = response.token
            
            // Save token to UserDefaults or keychain in a real app
            UserDefaults.standard.set(response.token, forKey: "userToken")
            
            // You would normally navigate to the main app screen here
            // For now, we'll just print the success
            print("Login successful with token: \(response.token ?? "")")
        } else {
            // Show error alert
            alertMessage = response.message ?? "An unknown error occurred"
            showAlert = true
        }
    }
    
    // Function to log out
    func logout() {
        isAuthenticated = false
        userToken = nil
        
        // Clear saved token
        UserDefaults.standard.removeObject(forKey: "userToken")
    }
    
    // Check if user is already logged in (e.g., on app start)
    func checkExistingSession() {
        if let savedToken = UserDefaults.standard.string(forKey: "userToken") {
            // In a real app, you would validate this token with your server
            userToken = savedToken
            isAuthenticated = true
        }
    }
}
