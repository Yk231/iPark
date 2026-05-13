//
//  CreateSpotView.swift
//  iPark2
//
//  Created by Yotam Krikov on 4/22/26.
//

import SwiftUI
import Foundation
import CoreData

struct HistoryView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \ParkingSpot.endTime, ascending: false)],
        predicate: NSPredicate(format: "endTime != nil"),
        animation: .default
    )
    private var completedSpots: FetchedResults<ParkingSpot>
    @State private var quickLookSpot: ParkingSpot? = nil
    @State private var showQuickLook: Bool = false
    
    
    // MARK: - Body
    var body: some View {
        
        LogoView()
        
        if completedSpots.isEmpty {
            Text("No history yet")
                .foregroundStyle(.secondary)
        }
        else{
            List {
                ForEach(completedSpots) { spot in
                    historyRow(spot)
                        .onTapGesture {
                            quickLookSpot = spot
                            showQuickLook = true
                        }
                        .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                    
                        // Swipe actions
                        .swipeActions(edge: .leading) {
                            Button(role: .destructive) {
                                withAnimation { delete(spot) }
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button {
                                withAnimation { unarchive(spot) }
                            } label: {
                                Label("Unarchive", systemImage: "arrow.uturn.backward")
                            }
                            .tint(.green)
                        }
                }
            }
            .listStyle(.plain)
            .spotQuickLook(spot: quickLookSpot, isPresented: $showQuickLook)
            .navigationTitle("History")
        }


        
    }
    
    
    // MARK: - Delete and Unarchive functions
    func delete(_ spot: ParkingSpot) {
        viewContext.delete(spot)
        do {
            try viewContext.save()
        } catch {
            print("Delete failed:", error)
        }
    }
    func unarchive(_ spot: ParkingSpot) {
        spot.endTime = nil
        spot.startTime = Date()
        spot.timeLimitMinutes = 0

        do {
            try viewContext.save()
        } catch {
            print("Unarchival failed:", error)
        }
    }
    
    
    // MARK: - History Row
    func historyRow(_ spot: ParkingSpot) -> some View {
        let start = spot.startTime ?? Date()
        let end = spot.endTime ?? Date()
        let duration = durationString(from: start, to: end)

        return HStack(spacing: 14) {

            VStack(alignment: .leading, spacing: 6) {

                // Title
                Text(spot.title ?? "Unknown Spot")
                    .font(.headline)
                    .lineLimit(1)


                Divider()

                // Dates
                VStack(alignment: .leading, spacing: 4) {
                    Label(start.formatted(date: .abbreviated, time: .shortened), systemImage: "car.fill")
                    Label(end.formatted(date: .abbreviated, time: .shortened), systemImage: "flag.checkered")
                    if let duration {
                        Label(duration, systemImage: "clock")
                    }
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            
            Spacer(minLength: 12)
            
            // MAP
            MapView(longitude: spot.longitude, latitude: spot.latitude)
                .frame(width: 100, height: 92)
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .allowsHitTesting(false)
            

        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 26)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 26)
                .stroke(.white.opacity(0.06), lineWidth: 1)
        )
    }



    

}


// MARK: - Computes and formats the duration of the parking spot
private func durationString(from start: Date, to end: Date) -> String? {
    let formatter = DateComponentsFormatter()
    formatter.allowedUnits = [.hour, .minute]
    formatter.unitsStyle = .short
    return formatter.string(from: end.timeIntervalSince(start))
}


