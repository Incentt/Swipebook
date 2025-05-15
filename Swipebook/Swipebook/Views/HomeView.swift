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


// MARK: - Main Views
struct BookView: View {
    @ObservedObject var controller: HomeController
    
    var body: some View {
        VStack(spacing: 0) {
            // Session Slider - single slider that jumps between predefined sessions
            SessionSlider(
                selectedSessionId: $controller.selectedSessionId,
                sessions: controller.availableSessions
            )
            .padding(.bottom, 16)
            
            
            // Divider
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(height: 1)
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
            
            // Available Rooms Text
            HStack {
                Text("Available Rooms")
                    .font(.title3)
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("\(controller.availableRooms.count) Found")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            
            // If no session is selected
            if controller.selectedSessionId == nil {
                Spacer()
                VStack(spacing: 12) {
                    Image(systemName: "calendar")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                    
                    Text("Select a Session")
                        .font(.title3)
                        .foregroundColor(.white)
                    
                    Text("Use the slider above to select a time slot")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                .padding()
                Spacer()
            }
            // If no rooms are available for the selected session
            else if controller.availableRooms.isEmpty && controller.unavailableRooms.isEmpty {
                Spacer()
                VStack(spacing: 12) {
                    Image(systemName: "calendar.badge.exclamationmark")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                    
                    Text("No Available Rooms")
                        .font(.title3)
                        .foregroundColor(.white)
                    
                    Text("Try selecting a different session")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                .padding()
                Spacer()
            }
            // Room lists
            else {
                ScrollView {
                    LazyVStack(spacing: 15) {
                        // Available rooms section
                        if !controller.availableRooms.isEmpty {
                            ForEach(controller.availableRooms) { room in
                                RoomCard(room: room) {
                                    controller.bookRoom(room)
                                }
                            }
                        }
                        
                        // Unavailable rooms section (if any)
                        if !controller.unavailableRooms.isEmpty {
                            // Section divider
                            Divider()
                                .padding(.vertical, 16)
                            
                            // Unavailable Rooms Header
                            HStack {
                                Text("Unavailable Rooms")
                                    .font(.title3)
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                Text("\(controller.unavailableRooms.count) Rooms")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            .padding(.vertical, 14)
                            
                            // Unavailable room cards
                            ForEach(controller.unavailableRooms) { room in
                                UnavailableRoomCard(room: room)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 100)
                    .padding(.vertical, 10)
                }
            }
        }
        .navigationTitle("Book a Room")
        .navigationBarTitleDisplayMode(.large)
        .background(Color.background)
        .alert(isPresented: $controller.bookingSuccess) {
            Alert(
                title: Text("Booking Successful"),
                message: Text(getBookingConfirmationMessage()),
                dismissButton: .default(Text("OK")) {
                    controller.resetBooking()
                }
            )
        }
    }
    
    // Helper to get booking confirmation message
    private func getBookingConfirmationMessage() -> String {
        guard let session = controller.selectedSession,
              let room = controller.selectedRoom else {
            return "You've booked a room successfully."
        }
        
        return "You've booked \(room.name) for \(session.timeRangeString)."
    }
    
    // Helper to calculate and format duration
    private func getDurationString(from startTime: Date, to endTime: Date) -> String {
        let minutes = Calendar.current.dateComponents([.minute], from: startTime, to: endTime).minute ?? 0
        
        if minutes >= 60 {
            let hours = minutes / 60
            let remainingMinutes = minutes % 60
            
            if remainingMinutes == 0 {
                return "\(hours)h"
            } else {
                return "\(hours)h \(remainingMinutes)m"
            }
        } else {
            return "\(minutes)m"
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
