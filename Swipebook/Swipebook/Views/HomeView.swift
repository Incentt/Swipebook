//
//  HomeView.swift
//  Swipebook
//
//  Created by Vincent Wisnata on 14/05/25.
//

import SwiftUI

// MARK: - View Components
struct RoomCard: View {
    let room: Room
    let bookAction: () -> Void
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(room.color)
                .frame(height: 120)
            
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text(room.name)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.background)
                    
                    Text("Available")
                        .font(.subheadline)
                        .foregroundColor(.black.opacity(0.8))
                    
                    HStack(spacing: 8) {
                        FeatureTag(text: "\(room.capacity) People")
                        
                        ForEach(room.features, id: \.self) { feature in
                            FeatureTag(text: feature)
                        }
                    }
                    .padding(.top, 5)
                }
                .padding(.leading, 15)
                
                Spacer()
                
                Button(action: bookAction) {
                    HStack {
                        Text("Book")
                            .fontWeight(.medium)
                        
                        Image(systemName: "arrow.right")
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 15)
                    .padding(.vertical, 10)
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(20)
                }
                .padding(.trailing, 15)
            }
            .padding(.vertical, 10)
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

struct ProfileView: View {
    @ObservedObject var loginController: LoginController
    
    var body: some View {
        VStack {
            Text("Account Settings")
                .font(.headline)
                .padding(.bottom, 30)
            
            Button(action: {
                loginController.logout()
            }) {
                Text("Log Out")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(width: 200, height: 50)
                    .background(Color.red.opacity(0.7))
                    .cornerRadius(10)
            }
        }
        .navigationTitle("Profile")
    }
}

// MARK: - Main Home View with TabView
struct HomeView: View {
  
    @ObservedObject var loginController: LoginController
    @StateObject private var homeController = HomeController()
    
    var body: some View {
        TabView(selection: $homeController.selectedTabIndex) {
            // Book Tab
            NavigationStack {
                BookView(controller: homeController).toolbarBackground(.tabView, for: .tabBar)
            }
            .tabItem {
                Image(systemName: "star.fill")
                Text("Book")
            }
            .tag(0)
            
            // Scan QR Tab
            NavigationStack {
                ScanQRView()
            }
            .tabItem {
                Image(systemName: "qrcode")
                Text("Scan QR")
            }
            .tag(1)
            .overlay(
                ZStack {
                    Circle()
                        .fill(Color.primaryOrange)
                        .frame(width: 70, height: 70)
                        .offset(y: -15)
                    
                    Image(systemName: "qrcode")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30, height: 30)
                        .foregroundColor(.white)
                        .offset(y: -15)
                }
            )
            
            // Logout Tab
            NavigationStack {
                ProfileView(loginController: loginController)
            }
            .tabItem {
                Image(systemName: "person.fill")
                Text("Log Out")
            }
            .tag(2)
        }
        .accentColor(.primaryOrange)
    }
}

#Preview {
    HomeView(loginController: LoginController())
}
