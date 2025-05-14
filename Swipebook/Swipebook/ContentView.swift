//
//  ContentView.swift
//  Swipebook
//
//  Created by Vincent Wisnata on 14/05/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var loginController = LoginController()
    
    var body: some View {
        ZStack {
            // Set the background color
            Color.background.edgesIgnoringSafeArea(.all)
            

            if loginController.isAuthenticated {
                HomeView(loginController: loginController)
            } else {
                LoginView()
            }
        }
        .onAppear {
            // Check for existing login session when app starts
            loginController.checkExistingSession()
        }
    }
}
#Preview {
    ContentView()
}
