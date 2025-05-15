//
//  SessionModel.swift
//  Swipebook
//
//  Created by Vincent Wisnata on 15/05/25.
//

import SwiftUI
import Foundation

// MARK: - Session Model
struct Session: Identifiable {
    let id = UUID()
    let startTime: Date
    let endTime: Date
    var isAvailable: Bool
    var roomId: UUID?  // To link session with a specific room
    
    // Duration in minutes
    var durationMinutes: Int {
        return Calendar.current.dateComponents([.minute], from: startTime, to: endTime).minute ?? 0
    }
    
    // Format time as string
    var timeRangeString: String {
        return "\(TimeFormatter.formatTime(startTime)) - \(TimeFormatter.formatTime(endTime))"
    }
}

// MARK: - Session Data Provider
class SessionDataProvider {
    static let shared = SessionDataProvider()
    
    // Pre-defined session time slots for the day
    private(set) var predefinedSessions: [Session] = []
    
    // Dictionary to track booked sessions by room ID
    private var bookedSessions: [UUID: [UUID]] = [:]  // [roomId: [sessionId]]
    
    private init() {
        // Create default sessions for the current day
        createPredefinedSessions()
    }
    
    private func createPredefinedSessions() {
        let calendar = Calendar.current
        let today = Date()
        
        // Get start of day
        guard let startOfDay = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: today) else { return }
        
        // Define fixed session time slots
        let sessionTimes: [(hour: Int, minute: Int, duration: Int)] = [
            (8, 45, 70),    // 08:45 - 09:55 (70 min)
            (10, 0, 75),    // 10:00 - 11:15 (75 min)
            (11, 30, 90),   // 11:30 - 13:00 (90 min)
            (13, 15, 75),   // 13:15 - 14:30 (75 min)
            (14, 45, 75),   // 14:45 - 16:00 (75 min)
            (16, 15, 105)   // 16:15 - 18:00 (105 min)
        ]
        
        // Create sessions based on these fixed times
        for (hour, minute, durationMinutes) in sessionTimes {
            guard let sessionStart = calendar.date(bySettingHour: hour, minute: minute, second: 0, of: startOfDay),
                  let sessionEnd = calendar.date(byAdding: .minute, value: durationMinutes, to: sessionStart) else { continue }
            
            let session = Session(
                startTime: sessionStart,
                endTime: sessionEnd,
                isAvailable: true,
                roomId: nil
            )
            
            predefinedSessions.append(session)
        }
    }
    
    // Get available sessions for a specific room
    func getAvailableSessions(forRoom roomId: UUID) -> [Session] {
        // Get the booked session IDs for this room
        let bookedSessionIds = bookedSessions[roomId] ?? []
        
        // Return all sessions, marking them as unavailable if they're booked
        return predefinedSessions.map { session in
            var sessionCopy = session
            
            // Mark session as unavailable if booked for this room
            if bookedSessionIds.contains(session.id) {
                sessionCopy.isAvailable = false
            } else {
                // Randomize availability for rooms (for demo purposes)
                // In a real app, you'd use actual availability data from a database
                sessionCopy.isAvailable = Bool.random()
            }
            
            sessionCopy.roomId = roomId
            return sessionCopy
        }
    }
    
    // Get a specific session by its ID
    func getSession(byId sessionId: UUID) -> Session? {
        return predefinedSessions.first { $0.id == sessionId }
    }
    
    // Check if a room is available for a specific session
    func isRoomAvailable(roomId: UUID, sessionId: UUID) -> Bool {
        // Get booked sessions for this room
        let bookedSessionIds = bookedSessions[roomId] ?? []
        
        // If this session ID is in the booked list, the room isn't available
        return !bookedSessionIds.contains(sessionId)
    }
    
    // Book a session for a room
    func bookSession(roomId: UUID, sessionId: UUID) -> Bool {
        // Check if already booked
        if let bookedSessionsForRoom = bookedSessions[roomId],
            bookedSessionsForRoom.contains(sessionId) {
            return false
        }
        
        // Add this session to the booked list for this room
        if bookedSessions[roomId] == nil {
            bookedSessions[roomId] = []
        }
        
        bookedSessions[roomId]?.append(sessionId)
        return true
    }
    
    // Get all predefined sessions
    func getAllSessions() -> [Session] {
        return predefinedSessions
    }
    
    // Get the current or next available session
    func getCurrentOrNextSession() -> Session? {
        let calendar = Calendar.current
        let now = Date()
        
        // Sort sessions by start time
        let sortedSessions = predefinedSessions.sorted { $0.startTime < $1.startTime }
        
        // Find the first session that hasn't ended yet
        for session in sortedSessions {
            if session.endTime > now {
                return session
            }
        }
        
        // If no session is currently active or upcoming today, return the first session
        return sortedSessions.first
    }
}
