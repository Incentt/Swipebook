//
//  TimeRangeSlider.swift
//  Swipebook
//
//  Created by Vincent Wisnata on 15/05/25.
//

import SwiftUI

struct TimeRangeSlider: View {
    // Input values
    @Binding var startTime: Date
    @Binding var endTime: Date
    let minTime: Date  // Earliest time allowed (e.g., 8:00 AM)
    let maxTime: Date  // Latest time allowed (e.g., 6:00 PM)
    let stepMinutes: Int // Time step in minutes (e.g., 15, 30)
    
    // State for slider interaction
    @State private var draggedHandle: DraggedHandle? = nil
    @State private var startPosition: CGFloat = 0
    @State private var endPosition: CGFloat = 0
    
    enum DraggedHandle {
        case start, end
    }
    
    // Parameters for slider appearance
    private let handleDiameter: CGFloat = 24
    private let sliderHeight: CGFloat = 6
    private let timeLabelsOffset: CGFloat = 24
    
    // Calculate minute range for the whole day
    private var totalMinutes: Int {
        Calendar.current.dateComponents([.minute], from: minTime, to: maxTime).minute ?? 600
    }
    
    private var startTimeString: String {
        return TimeFormatter.formatTime(startTime)
    }
    
    private var endTimeString: String {
        return TimeFormatter.formatTime(endTime)
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Selected time range display
            Text("\(startTimeString) - \(endTimeString)")
                .font(.headline)
                .foregroundColor(.white)
            
            // The slider
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background track
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: sliderHeight)
                        .cornerRadius(sliderHeight / 2)
                    
                    // Active range track
                    Rectangle()
                        .fill(Color.primaryOrange)
                        .frame(width: endPosition - startPosition, height: sliderHeight)
                        .offset(x: startPosition)
                        .cornerRadius(sliderHeight / 2)
                    
                    // Start handle
                    Circle()
                        .fill(Color.white)
                        .frame(width: handleDiameter, height: handleDiameter)
                        .shadow(radius: 2)
                        .offset(x: startPosition - handleDiameter/2)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    draggedHandle = .start
                                    updateHandlePosition(value: value, geometry: geometry)
                                }
                                .onEnded { _ in
                                    draggedHandle = nil
                                }
                        )
                    
                    // End handle
                    Circle()
                        .fill(Color.white)
                        .frame(width: handleDiameter, height: handleDiameter)
                        .shadow(radius: 2)
                        .offset(x: endPosition - handleDiameter/2)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    draggedHandle = .end
                                    updateHandlePosition(value: value, geometry: geometry)
                                }
                                .onEnded { _ in
                                    draggedHandle = nil
                                }
                        )
                    
                    // Time markers below slider
                    ForEach(0..<5) { i in
                        let position = CGFloat(i) * geometry.size.width / 4
                        
                        VStack {
                            // Small tick
                            Rectangle()
                                .fill(Color.gray.opacity(0.5))
                                .frame(width: 1, height: 8)
                                .offset(y: sliderHeight / 2 + 6)
                            
                            // Time label
                            Text(getTimeLabel(for: i, total: 5))
                                .font(.caption)
                                .foregroundColor(.gray)
                                .offset(y: timeLabelsOffset)
                        }
                        .position(x: position, y: 0)
                    }
                }
                .frame(height: 60) // Enough height for the slider and the time labels
                .onAppear {
                    // Initial positions based on selected times
                    startPosition = calculatePosition(for: startTime, in: geometry)
                    endPosition = calculatePosition(for: endTime, in: geometry)
                }
            }
            .frame(height: 60)
            .padding(.horizontal, 24)
            .padding(.top, 12)
        }
        .padding(.vertical, 12)
    }
    
    // Generate time label for marker at index i out of total markers
    private func getTimeLabel(for index: Int, total: Int) -> String {
        let calendar = Calendar.current
        let totalMinutesInRange = calendar.dateComponents([.minute], from: minTime, to: maxTime).minute ?? 600
        let minutesPerStep = totalMinutesInRange / (total - 1)
        
        guard let date = calendar.date(byAdding: .minute, value: index * minutesPerStep, to: minTime) else {
            return ""
        }
        
        return TimeFormatter.formatTime(date)
    }
    
    // Calculate position on slider for a given time
    private func calculatePosition(for time: Date, in geometry: GeometryProxy) -> CGFloat {
        let calendar = Calendar.current
        let minutesFromStart = calendar.dateComponents([.minute], from: minTime, to: time).minute ?? 0
        let totalMinutesInRange = calendar.dateComponents([.minute], from: minTime, to: maxTime).minute ?? 600
        
        let fractionOfRange = CGFloat(minutesFromStart) / CGFloat(totalMinutesInRange)
        return fractionOfRange * geometry.size.width
    }
    
    // Calculate time for a given position on slider
    private func calculateTime(for position: CGFloat, in geometry: GeometryProxy) -> Date {
        let fractionOfRange = position / geometry.size.width
        let totalMinutesInRange = Calendar.current.dateComponents([.minute], from: minTime, to: maxTime).minute ?? 600
        let minutesFromStart = Int(fractionOfRange * CGFloat(totalMinutesInRange))
        
        // Round to nearest step (e.g., 15 or 30 minutes)
        let roundedMinutes = (minutesFromStart / stepMinutes) * stepMinutes
        
        return Calendar.current.date(byAdding: .minute, value: roundedMinutes, to: minTime) ?? minTime
    }
    
    // Update handle position based on drag gesture
    private func updateHandlePosition(value: DragGesture.Value, geometry: GeometryProxy) {
        let position = max(0, min(value.location.x, geometry.size.width))
        
        switch draggedHandle {
        case .start:
            // Don't allow start handle to go past end handle minus minimum session length
            let minimumSessionMinutes: CGFloat = 30 // Minimum 30-minute session
            let minimumSessionWidth = (CGFloat(minimumSessionMinutes) / CGFloat(totalMinutes)) * geometry.size.width
            let maxStartPosition = endPosition - minimumSessionWidth
            
            startPosition = min(position, maxStartPosition)
            startTime = calculateTime(for: startPosition, in: geometry)
            
        case .end:
            // Don't allow end handle to go before start handle plus minimum session length
            let minimumSessionMinutes: CGFloat = 30 // Minimum 30-minute session
            let minimumSessionWidth = (CGFloat(minimumSessionMinutes) / CGFloat(totalMinutes)) * geometry.size.width
            let minEndPosition = startPosition + minimumSessionWidth
            
            endPosition = max(position, minEndPosition)
            endTime = calculateTime(for: endPosition, in: geometry)
            
        case .none:
            break
        }
    }
}

// MARK: - Preview
struct TimeRangeSlider_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            TimeRangeSlider(
                startTime: .constant(TimeFormatter.getDefaultStartTime()),
                endTime: .constant(TimeFormatter.getDefaultEndTime()),
                minTime: Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: Date()) ?? Date(),
                maxTime: Calendar.current.date(bySettingHour: 18, minute: 0, second: 0, of: Date()) ?? Date(),
                stepMinutes: 15
            )
        }
    }
}
