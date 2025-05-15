//
//  SessionSlider.swift
//  Swipebook
//
//  Created by Vincent Wisnata on 15/05/25.
//

import SwiftUI

struct SessionSlider: View {
    // Input binding
    @Binding var selectedSessionId: UUID?
    let sessions: [Session]
    
    // State for slider interaction
    @State private var sliderPosition: CGFloat = 0
    @State private var isDragging = false
    
    // Calculated properties
    private var sortedSessions: [Session] {
        return sessions.sorted { $0.startTime < $1.startTime }
    }
    
    private var selectedSession: Session? {
        guard let sessionId = selectedSessionId else { return nil }
        return sessions.first { $0.id == sessionId }
    }
    
    // UI constants
    private let handleDiameter: CGFloat = 28
    private let trackHeight: CGFloat = 6
    private let sessionPointDiameter: CGFloat = 12
    
    var body: some View {
        VStack(spacing: 10) {
            // Selected session time display
            if let session = selectedSession {
                Text(session.timeRangeString)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
            } else {
                Text("Select a session")
                    .font(.title3)
                    .foregroundColor(.white)
            }
            
            // Slider component
            HStack{
                Text("08:45")
                    .font(.subheadline)
                    .foregroundColor(.primaryOrange)
                    .bold()
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Track background
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: trackHeight)
                            .cornerRadius(trackHeight / 2)

                        // Handle
                        ZStack{
                            Rectangle()
                                .foregroundColor(Color.primaryOrange)
                                .frame(width: 32).position(
                                    x: sliderPosition + 24,
                                    y: trackHeight / 2
                                )
                            Circle()
                                .fill(Color.white)
                                .frame(width: handleDiameter, height: handleDiameter)
                                .shadow(radius: 1)
                                .position(
                                    x: sliderPosition,
                                    y: trackHeight / 2
                                )
                            
                            Circle()
                                .fill(Color.white)
                                .frame(width: handleDiameter, height: handleDiameter)
                                .shadow(radius: 1)
                                .position(
                                    x: sliderPosition + 48,
                                    y: trackHeight / 2
                                )
                            
                        } .gesture(
                            DragGesture()
                                .onChanged { value in
                                    isDragging = true
                                    let newPosition = min(max(value.location.x, 0), geometry.size.width)
                                    sliderPosition = newPosition
                                    
                                    // Find the nearest session
                                    updateSelectedSession(position: newPosition, in: geometry)
                                }
                                .onEnded { value in
                                    isDragging = false
                                    
                                    // Snap to nearest session
                                    if let session = selectedSession {
                                        withAnimation(.spring()) {
                                            sliderPosition = getPositionForSession(session, in: geometry)
                                        }
                                    }
                                }
                        )
                       
                           
                    }
                    .frame(height: 0)
                    .onAppear {
                        // Set initial position based on selected session
                        if let session = selectedSession {
                            sliderPosition = getPositionForSession(session, in: geometry)
                        } else if let firstSession = sortedSessions.first {
                            // Default to first session
                            sliderPosition = getPositionForSession(firstSession, in: geometry)
                            selectedSessionId = firstSession.id
                        }
                    }
                    .onChange(of: selectedSessionId) { newValue in
                        // Update position when selected session changes externally
                        if let session = selectedSession {
                            withAnimation(.spring()) {
                                sliderPosition = getPositionForSession(session, in: geometry)
                            }
                        }
                    }
                }
                .frame(height: 20)
                .padding(.top, 20)
                .padding(.horizontal, 10)

                Text("17:00")
                    .font(.subheadline)
                    .foregroundColor(.primaryGreen)
                    .bold()
            }.padding(.horizontal, 14)
        }

    }
    
    // Get horizontal position for a session
    private func getPositionForSession(_ session: Session, in geometry: GeometryProxy) -> CGFloat {
        guard let firstSession = sortedSessions.first,
              let lastSession = sortedSessions.last else {
            return 0
        }
        
        let startTime = firstSession.startTime
        let endTime = lastSession.endTime
        let totalSeconds = endTime.timeIntervalSince(startTime)
        let secondsFromStart = session.startTime.timeIntervalSince(startTime)
        
        let positionRatio = CGFloat(secondsFromStart / totalSeconds)
        let sliderWidth = geometry.size.width
        
        return positionRatio * sliderWidth
    }
    
    // Find the nearest session to current position
    private func updateSelectedSession(position: CGFloat, in geometry: GeometryProxy) {
        var closestSession: Session?
        var smallestDistance: CGFloat = .infinity
        
        // Find the closest session based on position
        for session in sortedSessions {
            let sessionPosition = getPositionForSession(session, in: geometry)
            let distance = abs(sessionPosition - position)
            
            if distance < smallestDistance {
                smallestDistance = distance
                closestSession = session
            }
        }
        
        // Only select available sessions
        if let closestSession = closestSession, closestSession.isAvailable {
            selectedSessionId = closestSession.id
        }
    }
}

struct SessionSlider_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.background.ignoresSafeArea()
            
            SessionSlider(
                selectedSessionId: .constant(nil),
                sessions: [
                    Session(
                        startTime: Calendar.current.date(bySettingHour: 8, minute: 45, second: 0, of: Date()) ?? Date(),
                        endTime: Calendar.current.date(bySettingHour: 9, minute: 55, second: 0, of: Date()) ?? Date(),
                        isAvailable: true,
                        roomId: nil
                    ),
                    Session(
                        startTime: Calendar.current.date(bySettingHour: 10, minute: 10, second: 0, of: Date()) ?? Date(),
                        endTime: Calendar.current.date(bySettingHour: 11, minute: 20, second: 0, of: Date()) ?? Date(),
                        isAvailable: true,
                        roomId: nil
                    ),
                    Session(
                        startTime: Calendar.current.date(bySettingHour: 11, minute: 35, second: 0, of: Date()) ?? Date(),
                        endTime: Calendar.current.date(bySettingHour: 12, minute: 45, second: 0, of: Date()) ?? Date(),
                        isAvailable: false,
                        roomId: nil
                    )
                ]
            )
        }
    }
}
