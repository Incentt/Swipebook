//
//  RoomModel.swift
//  Swipebook
//
//  Created by Vincent Wisnata on 14/05/25.
//

import SwiftUI

// MARK: - Room Type Enum
enum RoomType: String, CaseIterable {
    case CR1
    case CR2
    case CR3
    case CR4
    case CR5
    case CR6
    case CR7
    
    // Define color based on room type
    var color: Color {
        switch self {
        case .CR1: return Color.CR_1
        case .CR2: return Color.CR_2
        case .CR3: return Color.CR_3
        case .CR4: return Color.CR_4
        case .CR5: return Color.CR_5
        case .CR6: return Color.CR_6
        case .CR7: return Color.CR_7
        }
    }
    
    // Define default capacity
    var defaultCapacity: Int {
        switch self {
        case .CR1: return 5
        case .CR2: return 8
        case .CR3: return 12
        case .CR4: return 20
        case .CR5: return 10
        case .CR6: return 15
        case .CR7: return 25
        }
    }
    
    // Define default features
    var defaultFeatures: [String] {
        switch self {
        case .CR1: return ["Whiteboard"]
        case .CR2: return ["Whiteboard", "TV"]
        case .CR3: return ["Whiteboard", "TV"]
        case .CR4: return [ "TV", "Board"]
        case .CR5: return ["Whiteboard", "Ipad"]
        case .CR6: return ["Whiteboard", "Projector"]
        case .CR7: return ["Whiteboard", "TV"]
        }
    }
}


// MARK: - Models
struct Room: Identifiable {
    let id = UUID()
    let name: String
    let roomType: RoomType
    let capacity: Int
    let available: Bool
    let features: [String]
    
    // Color is now derived from room type
    var color: Color {
        return roomType.color
    }
    
    // Initializer with custom capacity and features
    init(name: String, roomType: RoomType, capacity: Int? = nil, available: Bool = true, features: [String]? = nil) {
        self.name = name
        self.roomType = roomType
        self.capacity = capacity ?? roomType.defaultCapacity
        self.available = available
        self.features = features ?? roomType.defaultFeatures
    }
}

// MARK: - Room Data Provider
class RoomDataProvider {
    static let shared = RoomDataProvider()
    
    // Sample rooms data using the new enum-based approach
    var rooms: [Room] = [
        Room(name: "Collab Room 1", roomType: .CR1),
        Room(name: "Collab Room 2", roomType: .CR2),
        Room(name: "Collab Room 3", roomType: .CR3),
        Room(name: "Collab Room 4", roomType: .CR4),
        Room(name: "Collab Room 5", roomType: .CR5),
        Room(name: "Collab Room 6", roomType: .CR6),
        Room(name: "Collab Room 7", roomType: .CR7),
    ]
    
    private init() {}
    
    func getAvailableRooms(forStartTime startTime: Date, endTime: Date) -> [Room] {
        // In a real app, you'd implement scheduling logic here
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
