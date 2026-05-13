//
//  SavedSpotDetailView.swift
//  iPark2
//
//  Created by Yotam Krikov on 4/23/26.
//

import Foundation
import SwiftUI
import CoreData
import CoreLocation

struct SavedSpotDetailView: View {

    // MARK: - Environment

    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    // MARK: - Properties

    let spot: ParkingSpot
    var showsEndTime: Bool = false

    @StateObject private var locationController = LocationController()
    @State private var showMapPicker = false

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                
                // MAP VIEW
                MapView(
                    longitude: spot.longitude,
                    latitude: spot.latitude,
                )
                .frame(height: 240)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 26)
                        .stroke(.ultraThinMaterial)
                )
 
                

                
                
                // SPOT INFO
                spotInfo(spot: spot)
                

                
                
                // BUTTONS
                VStack(spacing: 12) {
                    
                    // EDIT SPOT
                    NavigationLink {
                        CreateSpotView(existingSpot: spot)
                    } label: {
                        ActionRow(
                            title: "Edit Spot",
                            subtitle: "Update your parking details.",
                            icon: "square.and.pencil",
                            color: .gray
                        )
                    }
                    .buttonStyle(.plain)

                    
                    // GUIDE ME
                    Button {
                        showMapPicker = true
                    } label: {
                        ActionRow(
                            title: "Guide Me",
                            subtitle: "Get directions to your parked car.",
                            icon: "location.fill",
                            color: .blue
                        )
                    }
                    .sheet(isPresented: $showMapPicker) {
                        MapPickerSheet(isPresented: $showMapPicker, spot: spot)
                    }
                    .buttonStyle(.plain)

                    
                    
                    
                    // END PARK
                    Button {
                        spot.endTime = Date()
                        spot.timeLimitMinutes = 0
                        
                        NotificationManager.shared.cancelNotification(for: spot)
                        
                        do {
                            try viewContext.save()
                            dismiss()
                        } catch {
                            print("Error ending park: \(error)")
                        }
                    } label: {
                        ActionRow(
                            title: "End Park",
                            subtitle: "End your current session.",
                            icon: "trash.fill",
                            color: .red
                        )
                    }
                    .buttonStyle(.plain)

                }
                    
            }
        }
        .padding()
        .navigationTitle("Saved Spot")
        .navigationBarTitleDisplayMode(.inline)
    }
}




// MARK: - Info Section
private func spotInfo(spot: ParkingSpot) -> some View {
    VStack(alignment: .leading, spacing: 18) {
        
        
        // Title
        if let title = spot.title, !title.isEmpty {
            Text(title)
                .font(.title)
                .fontWeight(.semibold)
        } else {
            Text("Saved Spot")
                .font(.title)
                .fontWeight(.semibold)
        }
        
        Divider()
        
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
        
        
            // Timer
            if spot.timeLimitMinutes > 0 {
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
        }

    }
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
