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

    @State private var isGuiding: Bool = false
    @State private var distance: Double = 0.0

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                MapView(
                    longitude: spot.longitude,
                    latitude: spot.latitude,
                    userLocation: isGuiding ? locationController.currentLocation?.coordinate : nil
                )
                .frame(height: 240)
                .clipShape(RoundedRectangle(cornerRadius: 16))

                VStack(alignment: .leading, spacing: 8) {
                    if let title = spot.title, !title.isEmpty {
                        Text(title)
                            .font(.title)
                            .fontWeight(.semibold)
                    } else {
                        Text("Saved Spot")
                            .font(.title)
                            .fontWeight(.semibold)
                    }

                    if spot.floor != 0 {
                        Text("Floor: \(spot.floor)")
                            .font(.subheadline)
                    }

                    if let section = spot.section, !section.isEmpty {
                        Text("Section: \(section)")
                            .font(.subheadline)
                    }

                    if spot.number != 0 {
                        Text("Number: \(spot.number)")
                            .font(.subheadline)
                    }

                    if let notes = spot.notes, !notes.isEmpty {
                        Text("Notes: \(notes)")
                    }

                    Text("Open time: \(spot.startTime?.formatted(date: .abbreviated, time: .shortened) ?? "Unknown")")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    if showsEndTime, let endTime = spot.endTime {
                        Text("End time: \(endTime.formatted(date: .abbreviated, time: .shortened))")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Text("(\(durationString(from: spot.startTime, to: endTime)))")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }

                    if isGuiding {
                        Text(String(format: "%.0f meters away", distance))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }

                if !showsEndTime {
                    VStack(spacing: 12) {
                        
                        NavigationLink {
                            CreateSpotView(existingSpot: spot)
                        } label: {
                            Text("Edit")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.gray)
                        
                        
                        
                        Button {
                            if isGuiding {
                                stopGuiding()
                            } else {
                                startGuiding()
                            }
                        } label: {
                            Text(isGuiding ? "Stop Guiding" : "Guide Me")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)

                        
                        
                        Button {
                            spot.endTime = Date()
                        
                            NotificationManager.shared.cancelNotification(for: spot) 
                        
                            do {
                                try viewContext.save()
                                dismiss()
                            } catch {
                                print("Error ending park: \(error)")
                            }
                        } label: {
                            Text("End Park")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.red)
                
                    }
                    .padding(.top, 8)
                }
            }
            .padding()
        }
        .navigationTitle("Saved Spot")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: locationController.currentLocation) { _, newLocation in
            guard isGuiding, let newLocation = newLocation else { return }

            let spotLocation = CLLocation(
                latitude: spot.latitude,
                longitude: spot.longitude
            )
            let dist = newLocation.distance(from: spotLocation)
            distance = dist
        }
        .onDisappear {
            stopGuiding()
        }
    }

    // MARK: - Private Methods
    private func startGuiding() {
        isGuiding = true
        locationController.startUpdating()
    }
    private func stopGuiding() {
        isGuiding = false
        locationController.stopUpdating()
    }
    private func durationString(from start: Date?, to end: Date?) -> String {
        guard let start = start, let end = end else { return "" }
        let interval = end.timeIntervalSince(start)
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = .short
        return formatter.string(from: interval) ?? ""
    }
}
