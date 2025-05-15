//
//  RoomCard.swift
//  Swipebook
//
//  Created by Vincent Wisnata on 15/05/25.
//



import SwiftUI

struct RoomCard: View {
    let room: Room
    let bookAction: () -> Void
    
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
                        
//                        Text(room.roomType.rawValue) // Display the room type
//                            .font(.subheadline)
                    }
                    Spacer()
                    
                    Button(action: bookAction) {
                        HStack {
                            Text("Book")
                                .fontWeight(.regular)
                                .foregroundColor(room.color)
                            
                            Image(systemName: "arrow.right").padding(.all, 8)
                                .frame(width: 24, height: 24)
                                .foregroundColor(Color.background)
                                .background(room.color).cornerRadius(999)
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 15)
                        .padding(.vertical, 10)
                    }.background(Color.background)                        .cornerRadius(999)

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

struct RoomDetails: View{
    var text: String = ""
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 999)
                .stroke(Color.background, lineWidth: 2)
            Text(text)
                .foregroundColor(Color.background)
                .font(.subheadline.weight(.semibold))
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
        }
        .fixedSize()
    }

}

// UnavailableRoomCard for displaying rooms that can't be booked
struct UnavailableRoomCard: View {
    let room: Room
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(room.color.opacity(0.5)) // Reduced opacity to show it's unavailable
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
                    
                    // Unavailable indicator
                    HStack {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.background)
                        
                        Text("Unavailable")
                            .fontWeight(.regular)
                            .foregroundColor(.background)
                    }
                    .padding(.horizontal, 15)
                    .padding(.vertical, 10)
                    .background(Color.gray.opacity(0.3))
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
            
            // Overlay to indicate unavailability
            Rectangle()
                .fill(Color.black.opacity(0.2))
                .cornerRadius(12)
        }
    }
}

#Preview {
    RoomCard(room: Room(name: "Preview Room", roomType: .CR7)) {
        print("Book tapped")
    }
}
