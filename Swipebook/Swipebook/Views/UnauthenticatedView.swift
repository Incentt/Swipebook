//
//  UnauthenticatedView.swift
//  Swipebook
//
//  Created by Vincent Wisnata on 16/05/25.
//

import SwiftUI

struct UnauthenticatedView: View {
    @StateObject private var homeController = HomeController()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Session Slider - single slider that jumps between predefined sessions
                SessionSlider(
                    selectedSessionId: $homeController.selectedSessionId,
                    sessions: homeController.availableSessions
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
                        .foregroundColor(Color.background)
                    
                    Spacer()
                    
                    Text("\(homeController.availableRooms.count) Found")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 14)
                
                // If no session is selected
                if homeController.selectedSessionId == nil {
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
                else if homeController.availableRooms.isEmpty && homeController.unavailableRooms.isEmpty {
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
                            if !homeController.availableRooms.isEmpty {
                                ForEach(homeController.availableRooms) { room in
                                    UnauthenticatedRoomCard(room: room)
                                }
                            }
                            
                            // Unavailable rooms section (if any)
                            if !homeController.unavailableRooms.isEmpty {
                                // Section divider
                                Divider()
                                    .padding(.vertical, 16)
                                
                                // Unavailable Rooms Header
                                HStack {
                                    Text("Unavailable Rooms")
                                        .font(.title3)
                                        .foregroundColor(.white)
                                    
                                    Spacer()
                                    
                                    Text("\(homeController.unavailableRooms.count) Rooms")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                                .padding(.vertical, 14)
                                
                                // Unavailable room cards
                                ForEach(homeController.unavailableRooms) { room in
                                    UnavailableRoomCard(room: room)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 100)
                        .padding(.vertical, 10)
                    }
                }
                
                Spacer()
                
                // Login button at the bottom
                Button(action: {
                    dismiss()
                }) {
                    Text("Go to Login")
                        .fontWeight(.semibold)
                        .foregroundColor(.background)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.primaryOrange)
                        .cornerRadius(999)
                        .padding(.horizontal, 30)
                }
                .padding(.bottom, 30)
            }
            .navigationTitle("Room Availability")
            .navigationBarTitleDisplayMode(.large)
            .background(Color.background)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "arrow.left")
                            .foregroundColor(.white)
                    }
                }
            }
        }
    }
}

// UnauthenticatedRoomCard - similar to RoomCard but without the book button
struct UnauthenticatedRoomCard: View {
    let room: Room
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(room.color)
                .frame(height: 146)
            
            VStack(alignment: .leading){
                HStack {
                    VStack(alignment: .leading) {
                        Text(room.name)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.background)
                    }
                    Spacer()
                    
                    // Available indicator instead of book button
                    HStack {
                        Text("Available")
                            .fontWeight(.regular)
                            .foregroundColor(room.color)
                    }
                    .padding(.horizontal, 15)
                    .padding(.vertical, 10)
                    .background(Color.background)
                    .cornerRadius(999)
                }
                Spacer()
                HStack(spacing: 8) {
                    RoomDetails(text: "\(room.capacity) People")
                    
                    ForEach(room.features.prefix(2), id: \.self) { feature in
                        RoomDetails(text: feature)
                    }
                    
                    if room.features.count > 2 {
                        RoomDetails(text: "+\(room.features.count - 2) more")
                    }
                }
            }
            .padding(.vertical, 18)
            .padding(.horizontal, 14)
        }
    }
}

#Preview {
    UnauthenticatedView()
}
