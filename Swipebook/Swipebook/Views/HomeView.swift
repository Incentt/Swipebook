//
//  HomeView.swift
//  Swipebook
//
//  Created by Vincent Wisnata on 14/05/25.
//

import SwiftUI
// MARK: - Custom Tab Bar Components
struct CustomTabBar: View {
    @Binding var selectedTab: Int
    @ObservedObject var loginController: LoginController
    
    var body: some View {
        ZStack {
            // Tab items
            HStack {
                // Book Tab Button
                Button(action: {
                    selectedTab = 0
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: "book.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 22, height: 22)
                            .foregroundColor(selectedTab == 0 ? .primaryOrange : .gray)
                        
                        Text("Book")
                            .font(.caption)
                            .foregroundColor(selectedTab == 0 ? .primaryOrange : .gray)
                    }
                }
                .frame(maxWidth: .infinity)
                
                // Middle spacer for QR button
                Spacer()
                    .frame(maxWidth: .infinity)
                
                // Log Out Tab Button
                Button(action: {
                    loginController.requestLogout()
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: "person.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 22, height: 22)
                            .foregroundColor(selectedTab == 2 ? .primaryOrange : .gray)
                        
                        Text("Log Out")
                            .font(.caption)
                            .foregroundColor(selectedTab == 2 ? .primaryOrange : .gray)
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, 30).padding(.vertical, 12)
        }
        .background(.tabView)
        .alert(isPresented: $loginController.showLogoutConfirmation) {
            Alert(
                title: Text("Confirm Logout"),
                message: Text("Are you sure you want to log out of your account?"),
                primaryButton: .destructive(Text("Log Out")) {
                    loginController.logout()
                },
                secondaryButton: .cancel()
            )
        }
    }
}

// Feature Tag View
struct FeatureTag: View {
    let text: String
    
    var body: some View {
        Text(text)
            .font(.caption)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Color.black.opacity(0.2))
            .cornerRadius(15)
    }
}

//Update this later
struct ScanQRView: View {
    var body: some View {
        VStack {
            Text("QR Scanner Coming Soon")
                .foregroundColor(.black)
        }
        .navigationTitle("Scan QR Code")
    }
}

// MARK: - Main Home View with Custom Tab Bar
struct HomeView: View {
    @ObservedObject var loginController: LoginController
    @StateObject private var homeController = HomeController()
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Main content based on selected tab
            ZStack {
                if homeController.selectedTabIndex == 0 {
                    NavigationStack {
                        BookView(controller: homeController)
                    }
                } else if homeController.selectedTabIndex == 1 {
                    NavigationStack {
                        ScanQRView()
                    }
                }
            }
            
            // Custom Tab Bar
            VStack(spacing: 0) {
                VStack(spacing: 0) {
                    CustomTabBar(selectedTab: $homeController.selectedTabIndex, loginController: loginController)
                }            }
            
            // QR Button overlaid on top
            Button(action: {
                homeController.selectedTabIndex = 1
            }) {
                ZStack {
                    Circle()
                        .stroke(.tabView, lineWidth: 10)
                        .fill(Color.primaryOrange)
                        .frame(width: 70, height: 70)

                    VStack(spacing: 4) {
                        Image(systemName: "qrcode")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 28, height: 28)
                            .foregroundColor(.white)
                        
                        Text("Scan QR")
                            .font(.caption)
                            .foregroundColor(.white)
                    }
                }
            }
            .offset(y: -30)
        }
    }
}


#Preview {
    HomeView(loginController: LoginController())
}
