//
//  HomeController.swift
//  Swipebook
//
//  Created by Vincent Wisnata on 14/05/25.
//


import Foundation
import SwiftUI
import Combine

class HomeController: ObservableObject {
    // Room data
    private let roomDataProvider = RoomDataProvider.shared
    @Published var availableRooms: [Room] = []
    
    // Time selection
    @Published var selectedStartTime: Date = TimeFormatter.getDefaultStartTime()
    @Published var selectedEndTime: Date = TimeFormatter.getDefaultEndTime()
    
    // Tab selection
    @Published var selectedTabIndex: Int = 0
    
    // Booking state
    @Published var isBookingRoom: Bool = false
    @Published var selectedRoom: Room?
    @Published var bookingSuccess: Bool = false
    @Published var bookingError: String?
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Load initial data
        refreshAvailableRooms()
        
        // Set up publishers to refresh rooms when time changes
        $selectedStartTime
            .combineLatest($selectedEndTime)
            .debounce(for: 0.3, scheduler: RunLoop.main)
            .sink { [weak self] startTime, endTime in
                self?.refreshAvailableRooms()
            }
            .store(in: &cancellables)
    }
    
    func refreshAvailableRooms() {
        availableRooms = roomDataProvider.getAvailableRooms(
            forStartTime: selectedStartTime,
            endTime: selectedEndTime
        )
    }
    
    func bookRoom(_ room: Room) {
        // In a real app, this would communicate with the backend
        isBookingRoom = true
        selectedRoom = room
        
        // Simulate network request
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.isBookingRoom = false
            self?.bookingSuccess = true
            
            // Reset after showing success message
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
                self?.bookingSuccess = false
                self?.selectedRoom = nil
            }
        }
    }
    
    func updateTimeRange(startTime: Date, endTime: Date) {
        selectedStartTime = startTime
        selectedEndTime = endTime
        refreshAvailableRooms()
    }
}
