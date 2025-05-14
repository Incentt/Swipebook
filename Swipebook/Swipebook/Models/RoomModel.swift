//
//  RoomModel.swift
//  Swipebook
//
//  Created by Vincent Wisnata on 14/05/25.
//

import SwiftUI

// MARK: - Models
struct Room: Identifiable {
    let id = UUID()
    let name: String
    let capacity: Int
    let available: Bool
    let color: Color
    let features: [String]
}

// MARK: - Room Data Provider
class RoomDataProvider {
    static let shared = RoomDataProvider()
    
    // Sample rooms data
    var rooms: [Room] = [
        Room(name: "Collab Room 1", capacity: 5, available: true, color: Color.red.opacity(0.7), features: []),
        Room(name: "Collab Room 3", capacity: 12, available: true, color: Color.green.opacity(0.7), features: ["TV", "Board"]),
        Room(name: "Collab Room 4", capacity: 5, available: true, color: Color.blue.opacity(0.5), features: []),
        Room(name: "Collab Room 5", capacity: 8, available: true, color: Color.blue.opacity(0.7), features: [])
    ]
    
    private init() {}
    
    // Get available rooms based on selected time
    func getAvailableRooms(forStartTime startTime: Date, endTime: Date) -> [Room] {
  
        return rooms
    }
}

// MARK: - Date Formatting Utilities
struct TimeFormatter {
    static func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
    
    static func getDefaultStartTime() -> Date {
        return Calendar.current.date(bySettingHour: 8, minute: 45, second: 0, of: Date()) ?? Date()
    }
    
    static func getDefaultEndTime() -> Date {
        return Calendar.current.date(bySettingHour: 9, minute: 55, second: 0, of: Date()) ?? Date()
    }
}
