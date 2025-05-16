//
//  BookingView.swift
//  Swipebook
//
//  Created by Vincent Wisnata on 15/05/25.
//

import SwiftUI
// MARK: - Main Views
struct BookView: View {
    @ObservedObject var controller: HomeController
    
    var body: some View {
        VStack(spacing: 0) {
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
        // Replace the alert with the modal sheet
        .fullScreenCover(isPresented: $controller.showBookingSuccess) {
            BookingSuccessView(controller: controller)
        }
        .alert("Confirm Booking", isPresented: $controller.showBookingConfirmation) {
            Button("Cancel", role: .cancel) {
                controller.cancelBooking()
            }
            
            Button("Confirm", role: .destructive) {
                controller.confirmBooking()
            }
        } message: {
            if let room = controller.roomToBook, let session = controller.selectedSession {
                Text("Do you want to book \(room.name) for \(session.timeRangeString)?")
            } else {
                Text("Do you want to book this room?")
            }
        }
        // Add a success alert for calendar add success
        .alert(isPresented: $controller.calendarAddSuccess) {
            Alert(
                title: Text("Added to Calendar"),
                message: Text("Your booking has been added to your calendar."),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}
