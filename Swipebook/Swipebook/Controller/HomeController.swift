//
//  HomeController.swift
//  Swipebook
//
//  Created by Vincent Wisnata on 15/05/25.
//

import SwiftUI
import Combine

class HomeController: ObservableObject {
    // MARK: - Published properties
    @Published var selectedTabIndex = 0
    @Published var selectedSessionId: UUID?
    @Published var availableRooms: [Room] = []
    @Published var unavailableRooms: [Room] = []
    @Published var selectedRoom: Room?
    @Published var bookingSuccess = false
    @Published var availableSessions: [Session] = []
    
    // Session and room data providers
    private let roomDataProvider = RoomDataProvider.shared
    private let sessionDataProvider = SessionDataProvider.shared
    
    // Cancellable storage
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Computed properties
    var selectedSession: Session? {
        guard let sessionId = selectedSessionId else { return nil }
        return sessionDataProvider.getSession(byId: sessionId)
    }
    
    // MARK: - Initialization
    init() {
        // Load all available sessions
        self.loadAvailableSessions()
        
        // Set a default session if available
        if let defaultSession = sessionDataProvider.getCurrentOrNextSession() {
            self.selectedSessionId = defaultSession.id
        }
        
        // Load available rooms for the selected session
        self.loadAvailableRooms()
        
        // Set up listeners for session selection changes
        self.setupSubscriptions()
    }
    
    // MARK: - Private methods
    private func setupSubscriptions() {
        // Monitor changes to the selected session
        $selectedSessionId
            .sink { [weak self] _ in
                self?.loadAvailableRooms()
            }
            .store(in: &cancellables)
    }
    
    private func loadAvailableSessions() {
        // Get all predefined sessions from the provider
        availableSessions = sessionDataProvider.getAllSessions()
    }
    
    private func loadAvailableRooms() {
        guard let sessionId = selectedSessionId else {
            availableRooms = []
            unavailableRooms = []
            return
        }
        
        // Get all rooms
        let allRooms = roomDataProvider.rooms
        
        // Split rooms into available and unavailable for the selected session
        var available: [Room] = []
        var unavailable: [Room] = []
        
        for room in allRooms {
            if sessionDataProvider.isRoomAvailable(roomId: room.id, sessionId: sessionId) {
                available.append(room)
            } else {
                unavailable.append(room)
            }
        }
        
        // Update the published properties
        self.availableRooms = available
        self.unavailableRooms = unavailable
    }
    
    // MARK: - Public methods
    func bookRoom(_ room: Room) {
        guard let sessionId = selectedSessionId else { return }
        
        // Set selected room
        selectedRoom = room
        
        // Book the session for the room
        let bookingSuccessful = sessionDataProvider.bookSession(
            roomId: room.id,
            sessionId: sessionId
        )
        
        // Show success message
        if bookingSuccessful {
            bookingSuccess = true
            
            // Reload available rooms after booking
            loadAvailableRooms()
        }
    }
    
    // Reset booking
    func resetBooking() {
        selectedRoom = nil
        bookingSuccess = false
    }
}
