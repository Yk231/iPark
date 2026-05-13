//
//  SpotQuickLookView.swift
//  iPark2
//

import SwiftUI
import CoreData

// MARK: - Quick Look Modifier
extension View {
    func spotQuickLook(spot: ParkingSpot?, isPresented: Binding<Bool>) -> some View {
        self.overlay {
            if isPresented.wrappedValue, let spot = spot {
                SpotQuickLookOverlay(spot: spot, isPresented: isPresented)
                    .transition(.opacity.combined(with: .scale(scale: 0.96)))
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.85), value: isPresented.wrappedValue)
    }
}

// MARK: - Overlay Container
private struct SpotQuickLookOverlay: View {

    let spot: ParkingSpot
    @Binding var isPresented: Bool

    var body: some View {
        ZStack {
            // Blurred backdrop — tapping dismisses
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea()
                .onTapGesture { isPresented = false }

            SpotQuickLookCard(spot: spot, isPresented: $isPresented)
                .padding(.horizontal, 24)
        }
    }
}

// MARK: - Saved Spot Card Body

private struct SpotQuickLookCard: View {

    let spot: ParkingSpot
    @Binding var isPresented: Bool

    // Pull the small map snapshot
    private var hasLocation: Bool {
        spot.latitude != 0 || spot.longitude != 0
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // Header bar
            HStack {
                Label("Quick Look", systemImage: "location.viewfinder")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                Spacer()
                Button {
                    isPresented = false
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title3)
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)

            Divider()

            // Map thumbnail
            if hasLocation {
                MapView(
                    longitude: spot.longitude,
                    latitude: spot.latitude,
                )
                .frame(height: 160)
                .clipped()
            }

            // Info rows
            VStack(alignment: .leading, spacing: 10) {

                // Title
                if let title = spot.title, !title.isEmpty {
                    Text(title)
                        .font(.title3.weight(.semibold))
                } else {
                    Text("Saved Spot")
                        .font(.title3.weight(.semibold))
                }

                Divider()
                
                
                // Other info
                Group {
                    if spot.floor != 0 {
                        infoRow(label: "Floor", value: "\(spot.floor)")
                    }
                    if let section = spot.section, !section.isEmpty {
                        infoRow(label: "Section", value: section)
                    }
                    if spot.number != 0 {
                        infoRow(label: "Number", value: "\(spot.number)")
                    }
                    if let notes = spot.notes, !notes.isEmpty {
                        infoRow(label: "Notes", value: notes)
                    }
                    infoRow(label: "Started at", value: spot.startTime?.formatted(date: .abbreviated, time: .shortened) ?? "Unknown")
                    if let endTime = spot.endTime {
                        infoRow(
                            label: "Ended at",
                            value: endTime.formatted(date: .abbreviated, time: .shortened)
                        )
                        if let duration = durationString(from: spot.startTime, to: endTime) {
                            infoRow(label: "Duration", value: duration)
                        }
                    }
                    // Creates a timer if time limit is ongoing
                    else if spot.timeLimitMinutes > 0 {
        
                        if (minutesLeft(spot) > 0){
                            let startTime = spot.startTime ?? Date()
                            let deadline = startTime.addingTimeInterval(Double(spot.timeLimitMinutes) * 60)
                            
                            TimelineView(.periodic(from: .now, by: 1.0)) { context in
                                let isExpired = context.date > deadline
                                
                                HStack {
                                    Image(systemName: "timer")
                                    if isExpired {
                                        Text("Expired")
                                    } else {
                                        Text(timerInterval: startTime...deadline, countsDown: true)
                                    }
                                }
                                .font(.subheadline.bold())
                                .foregroundStyle(isExpired ? .red : .blue)
                                .padding(.vertical, 4)
                            }
                        }
                        // Displays EXPIRED if time limit exists but has been surpassed
                        else {
                            Text("EXPIRED")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.red)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(.red.opacity(0.12))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(.red.opacity(0.35), lineWidth: 1)
                                )

                        }
                        
                    }
                
                }
            }
            .padding(16)
        }
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: .black.opacity(0.18), radius: 30, x: 0, y: 8)
    }

    
    
    
    
    // MARK: - Helpers
    private func infoRow(label: String, value: String) -> some View {
        HStack(alignment: .top) {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(width: 80, alignment: .leading)
            Text(value)
                .font(.subheadline)
                .foregroundStyle(.primary)
            Spacer()
        }
    }

    private func durationString(from start: Date?, to end: Date?) -> String? {
        guard let start, let end else { return nil }
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = .short
        return formatter.string(from: end.timeIntervalSince(start))
    }
    
    func minutesLeft(_ spot: ParkingSpot) -> Int {
        let startTime = spot.startTime ?? Date()
        let deadline = startTime.addingTimeInterval(Double(spot.timeLimitMinutes) * 60)
        let remainingSeconds = deadline.timeIntervalSince(Date())
        return max(0, Int(ceil(remainingSeconds / 60)))
    }
}
