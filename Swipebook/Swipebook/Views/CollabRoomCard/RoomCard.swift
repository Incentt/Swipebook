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
                        
                        Text(room.roomType.rawValue) // Display the room type
                            .font(.subheadline)
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

#Preview {
    RoomCard(room: Room(name: "Preview Room", roomType: .CR7)) {
        print("Book tapped")
    }
}
