//
//  SavedSpotDetailView.swift
//  iPark2
//
//  Created by Yotam Krikov on 4/23/26.
//

import SwiftUI
import CoreData

struct SavedSpotDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    let spot: ParkingSpot
    var showsEndTime: Bool = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                MapView(longitude: spot.longitude, latitude: spot.latitude)
                    .frame(height: 240)
                    .clipShape(RoundedRectangle(cornerRadius: 16))

                VStack(alignment: .leading, spacing: 8) {
                    Text(spot.title ?? "Saved Spot")
                        .font(.title)
                        .fontWeight(.semibold)
                                        
                    if spot.floor != 0 {
                        Text("Floor: \(spot.floor)")
                            .font(.subheadline)
                    }
                    
                    if let section = spot.section, !section.isEmpty{
                        Text("Section: \(section)")
                            .font(.subheadline)
                    }
                    
                    if spot.number != 0 {
                        Text("Number: \(spot.number)")
                            .font(.subheadline)
                    }
                    
                    if let notes = spot.notes, !notes.isEmpty{
                        Text("Notes: \(notes)")
                            .font(.subheadline)
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
                }
                if !showsEndTime{
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
                            print("Guide Me logic")
                        } label: {
                            Text("Guide Me")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)

                        
                        Button {
                            spot.endTime = Date()
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



