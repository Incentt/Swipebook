//
//  HomeView.swift
//  Swipebook
//
//  Created by Vincent Wisnata on 14/05/25.
//

import SwiftUI


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

// Time Range Slider View
struct TimeRangeSlider: View {
    let startTime: Date
    let endTime: Date
    
    var body: some View {
        HStack(spacing: 0) {
            // Time Range Display
            Text("\(TimeFormatter.formatTime(startTime)) - \(TimeFormatter.formatTime(endTime))")
                .font(.headline)
                .padding(.top, 5)
            // Start time label
            Text("08:45")
                .font(.caption)
                .foregroundColor(.orange)
                .offset(y: -20)
                .padding(.leading, 20)
            
            // Time Slider
            ZStack(alignment: .leading) {
                // Timeline
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 2)
                    .padding(.horizontal, 20)
                
                // Start time handle
                Circle()
                    .fill(Color.white)
                    .frame(width: 20, height: 20)
                    .padding(.leading, 20)
                
                // End time handle
                Circle()
                    .fill(Color.white)
                    .frame(width: 20, height: 20)
                    .padding(.leading, 100)
                
                // Active range
                Rectangle()
                    .fill(Color.orange)
                    .frame(width: 80, height: 2)
                    .padding(.leading, 20)
            }
            .frame(height: 30)
            .padding(.vertical, 10)
            // End time label
            Text("17:00")
                .font(.caption)
                .foregroundColor(.green)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .offset(y: -20)
                .padding(.trailing, 20)
        }
    }
}

// MARK: - Main Views
struct BookView: View {
    @ObservedObject var controller: HomeController
    
    var body: some View {
        VStack(spacing: 0) {
            // Time Range Slider
            TimeRangeSlider(
                startTime: controller.selectedStartTime,
                endTime: controller.selectedEndTime
            )
            
            // Available Rooms Text
            Text("Available Room").font(.title3)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.vertical, 14)
            
            // Room List
            ScrollView {
                LazyVStack(spacing: 15) {
                    ForEach(controller.availableRooms) { room in
                        RoomCard(room: room) {
                            controller.bookRoom(room)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 100)
                .padding(.vertical, 10)
            }
        }
        .navigationTitle("Select Time and Room")
        .navigationBarTitleDisplayMode(.large)
        .background(Color.background)
        .alert(isPresented: $controller.bookingSuccess) {
            Alert(
                title: Text("Booking Successful"),
                message: Text("You've booked \(controller.selectedRoom?.name ?? "a room") for \(TimeFormatter.formatTime(controller.selectedStartTime)) - \(TimeFormatter.formatTime(controller.selectedEndTime))"),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}

struct ScanQRView: View {
    var body: some View {
        VStack {
            Text("QR Scanner Coming Soon")
                .foregroundColor(.white)
        }
        .navigationTitle("Scan QR Code")
    }
}

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
            .offset(y: -30) // Adjust this value to control how much the button overlaps the tab bar
        }
    }
}


#Preview {
    HomeView(loginController: LoginController())
}
