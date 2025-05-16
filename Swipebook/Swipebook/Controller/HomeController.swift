//
//  HomeController.swift
//  Swipebook
//
//  Created by Vincent Wisnata on 15/05/25.
//
import SwiftUI
import Combine
import EventKit

class HomeController: ObservableObject {
    // MARK: - Published properties
    @Published var selectedTabIndex = 0
    @Published var selectedSessionId: UUID?
    @Published var availableRooms: [Room] = []
    @Published var unavailableRooms: [Room] = []
    @Published var selectedRoom: Room?
    @Published var bookingSuccess = false // Keeping for backward compatibility
    @Published var showBookingSuccess = false // For the modal view
    @Published var availableSessions: [Session] = []
    @Published var calendarAddSuccess = false
    
    @Published var showBookingConfirmation = false
    @Published var roomToBook: Room? = nil
    
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
        // Store the room to book
        roomToBook = room
        // Show confirmation alert
        showBookingConfirmation = true
    }
    func confirmBooking() {
        guard let room = roomToBook, let sessionId = selectedSessionId else { return }
        
        // Book the session for the room
        let bookingSuccessful = sessionDataProvider.bookSession(
            roomId: room.id,
            sessionId: sessionId
        )
        
        // Show success message
        if bookingSuccessful {
            // Set the selected room
            selectedRoom = room
            
            // Show the success modal
            showBookingSuccess = true
            
            // Reload available rooms after booking
            loadAvailableRooms()
        }
        
        // Reset the confirmation state
        roomToBook = nil
        showBookingConfirmation = false
    }
    
    // Add a method to cancel booking
    func cancelBooking() {
        roomToBook = nil
        showBookingConfirmation = false
    }

    func addToCalendar() {
        guard let session = selectedSession, let room = selectedRoom else {
            return
        }
        
        let eventStore = EKEventStore()
        
        // Request access to the calendar
        eventStore.requestAccess(to: .event) { granted, error in
            if granted {
                // Create a new calendar event
                let event = EKEvent(eventStore: eventStore)
                event.title = "Room Booking: \(room.name)"
                event.notes = "Booked via Swipebook"
                event.startDate = session.startTime
                event.endDate = session.endTime
                event.calendar = eventStore.defaultCalendarForNewEvents
                
                // Add location if available
                event.location = "Room \(room.name)"
                
                // Add alarm 15 minutes before start
                let alarm = EKAlarm(relativeOffset: -15 * 60)
                event.addAlarm(alarm)
                
                do {
                    try eventStore.save(event, span: .thisEvent)
                    
                    // Update UI on main thread
                    DispatchQueue.main.async {
                        // Show a success indicator for the calendar addition
                        self.calendarAddSuccess = true
                    }
                } catch {
                    // Handle error
                    print("Error saving event: \(error)")
                }
            } else {
                // Handle calendar access denied
                if let error = error {
                    print("Calendar access denied: \(error)")
                }
            }
        }
    }
    
    // Reset booking
    func resetBooking() {
        selectedRoom = nil
        bookingSuccess = false
        showBookingSuccess = false // Make sure to reset this as well
        calendarAddSuccess = false // Reset calendar success flag
    }
}
