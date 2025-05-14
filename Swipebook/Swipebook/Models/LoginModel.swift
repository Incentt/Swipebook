//
//  LoginModel.swift
//  Swipebook
//
//  Created by Vincent Wisnata on 14/05/25.
//

import Foundation

struct LoginCredentials {
    let email: String
    let password: String
}

struct LoginResponse {
    let success: Bool
    let message: String?
    let token: String?
}

struct User {
    let email: String
    let password: String
    let name: String
    let token: String
}

class MockUserDatabase {
    // Mock database with a single user
    static let shared = MockUserDatabase()
    
    private var users: [User]
    
    private init() {
        // Initialize with mock data
        users = [
            User(
                email: "vincent@gmail.com",
                password: "123456",
                name: "Vincent Wisnata",
                token: "mock-auth-token-12345"
            )
        ]
    }
    
    func findUser(email: String, password: String) -> User? {
        return users.first { $0.email.lowercased() == email.lowercased() && $0.password == password }
    }
}
