//
//  BookinSuccess.swift
//  Swipebook
//
//  Created by Vincent Wisnata on 15/05/25.
//

import SwiftUI
struct BookingSuccessView: View {
    @ObservedObject var controller: HomeController
    
    var body: some View {
        ZStack {
            // Dark background
            Color.background.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                // Close button
                HStack {
                    Spacer()
                    Button(action: {
                        // Only reset the booking, which will handle the dismissal
                        controller.resetBooking()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 20))
                            .foregroundColor(.gray)
                            .padding(8)
                            .background(Color.gray.opacity(0.2))
                            .clipShape(Circle())
                    }
                    .padding(.trailing, 20)
                }
                
                // Success checkmark
                Circle()
                    .fill(Color.primaryOrange)
                    .frame(width: 80, height: 80)
                    .overlay(
                        Image(systemName: "checkmark")
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(.white)
                    )
                    .padding(.top, 30)
                
                // Success text
                Text("Booking Successful") // Fixed typo here
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.top, 10)
                    .padding(.bottom, 30)
                
                // Room information section
                VStack(alignment: .leading, spacing: 6) {
                    Text("Room")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text(controller.selectedRoom?.name ?? "Unknown Room")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 30)
                
                // Time information section
                VStack(alignment: .leading, spacing: 6) {
                    Text("Time")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text(controller.selectedSession?.timeRangeString ?? "Unknown Time")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 30)
                
                Spacer()
                
                // Action buttons
                VStack(spacing: 15) {
                    // Add to Calendar button
                    Button(action: {
                        controller.addToCalendar()
                    }) {
                        HStack {
                            Text("Add To Calendar")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.primaryGreen)
                        .cornerRadius(30)
                    }
                    .padding(.horizontal, 30)
                    
                    // Continue button
                    Button(action: {
                        // Only reset the booking, which will handle the dismissal
                        controller.resetBooking()
                    }) {
                        HStack {
                            Text("Continue")
                                .font(.headline)
                                .foregroundColor(.background)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.primaryOrange)
                        .cornerRadius(30)
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, 30)
                }
            }
        }
    }
}
