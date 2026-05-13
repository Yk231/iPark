//
//  AlertsView.swift
//  iPark2
//
//  Created by Yotam Krikov on 4/29/26.
//

import Foundation
import SwiftUI

struct alertsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \ParkingSpot.startTime, ascending: false)],
        predicate: NSPredicate(format: "endTime == nil AND timeLimitMinutes > 0"),
        animation: .default
    )
    private var spots: FetchedResults<ParkingSpot>
    
    @State private var quickLookSpot: ParkingSpot? = nil
    @State private var showQuickLook: Bool = false
    
    
    // MARK: - Body
    var body: some View {
        
        let groupedSpots = splitSpotsByPriority(Array(spots))
        let highPrioritySpots = groupedSpots.highPriority
        let lowerPrioritySpots = groupedSpots.lowerPriority
        
        ScrollView {
            
            LogoView()
            
            VStack(spacing: 16) {
                alertsSection(
                    spots: highPrioritySpots,
                    title: "High-Priority Alerts",
                    icon: "exclamationmark.triangle.fill",
                    color: .red,
                    defaultMessage: "You're good, for now.")
                alertsSection(
                    spots: lowerPrioritySpots,
                    title: "Other Alerts",
                    icon: "clock.badge",
                    color: .gray,
                    defaultMessage: "No ongoing alerts.")
            }
            .padding(.horizontal, 16)
            .padding(.vertical)
        }
        .spotQuickLook(spot: quickLookSpot, isPresented: $showQuickLook)
        .navigationTitle("Alerts")
                         
    }
    
    // MARK: - Alerts Section
    private func alertsSection (spots: [ParkingSpot], title: String, icon: String, color: Color, defaultMessage: String) -> some View {
        VStack(spacing: 16) {
            
            // Header
            HStack{
                Image(systemName: icon)
                    .foregroundStyle(color)
                    .font(.title)
                
                Text("\(title)")
                    .font(.title2.weight(.bold))
                
                Spacer()
                
                Text("\(spots.count)")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(color)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(color.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(color.opacity(0.35), lineWidth: 1)
                    )
                
            }
            
            
            // Body
            if spots.isEmpty {
                Text("\(defaultMessage)")
                    .padding(.vertical, 30)
                    .padding(.horizontal, 30)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 26)
                            .fill(.ultraThinMaterial)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 26)
                            .stroke(.white.opacity(0.06), lineWidth: 1)
                    )
            } else {
                VStack(spacing: 14){
                    ForEach(spots, id: \.objectID) { spot in
                        Button {
                            quickLookSpot = spot
                            showQuickLook = true
                        } label: {
                            alertRow(spot)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
    
    
    // MARK: - Alert Rows
    func alertRow(_ spot: ParkingSpot) -> some View {
        
        let startTime = spot.startTime ?? Date()
        let minutesLeft = minutesLeft(spot)
        
        var icon: String
        var color: Color
        var status: String
        
        // Sort into priority
        switch minutesLeft {
        case 0:
            icon = "exclamationmark.circle.fill"
            color = .red
            status = "EXPIRED"
        case ..<15:
            icon = "timer"
            color = .orange
            status = "\(minutesLeft) MIN"
        case ..<30:
            icon = "clock.badge.exclamationmark"
            color = .yellow
            status = "\(minutesLeft) MIN"
        case ..<60:
            icon = "clock.badge.exclamationmark"
            color = .yellow
            status = "\(minutesLeft) MIN"
        default:
            icon = "clock"
            color = .green
            
            let hours = minutesLeft / 60
            let remainingMinutes = minutesLeft % 60
            
            status = "\(hours) HR \(remainingMinutes) MIN"
        }
        
        return HStack(spacing: 14) {
            
            
            
            VStack(alignment: .leading, spacing: 10) {
                
                
                // ICON & TITLE
                HStack{
                    Image(systemName: icon)
                        .foregroundStyle(color)
                        .font(.title2.weight(.bold))
                    
                    Text(spot.title ?? "Unknown Spot")
                        .font(.headline)
                        .lineLimit(1)
                }
                
                Divider()
                
                // STATUS BADGE
                Text(status)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(color)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(color.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(color.opacity(0.35), lineWidth: 1)
                    )
                
                
                // METADATA
                VStack(alignment: .leading, spacing: 4) {
                    
                    let hours = spot.timeLimitMinutes / 60
                    let remainder = spot.timeLimitMinutes % 60
                    
                    if hours > 0 {
                        Text("\(hours)h \(remainder)m limit")
                            .foregroundStyle(.secondary)
                    } else {
                        Text("\(remainder)m limit")
                            .foregroundStyle(.secondary)
                    }
                                        
                    Text("Started \(startTime.formatted(date: .abbreviated, time: .shortened))")
                        .foregroundStyle(.secondary)
                }
                .font(.caption)
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
    
    
    // MARK: - Helper functions
    // Splits a given array of parking spots into
    // - higher priority (<15min or expired)
    // - lower priority (>15min left)
    func splitSpotsByPriority(_ spots: [ParkingSpot]) -> (highPriority: [ParkingSpot], lowerPriority: [ParkingSpot]) {
        let sorted = spots.sorted {
            minutesLeft($0) < minutesLeft($1)
        }
        
        let highPriority = sorted.filter {
            minutesLeft($0) <= 15
        }
        
        let lowerPriority = sorted.filter {
            minutesLeft($0) > 15
        }
        
        return (highPriority, lowerPriority)
    }
    
    // Computes how many minutes left are in a given parking spot's time limit
    func minutesLeft(_ spot: ParkingSpot) -> Int {
        let startTime = spot.startTime ?? Date()
        let deadline = startTime.addingTimeInterval(Double(spot.timeLimitMinutes) * 60)
        let remainingSeconds = deadline.timeIntervalSince(Date())
        return max(0, Int(ceil(remainingSeconds / 60)))
    }
  
    
}
