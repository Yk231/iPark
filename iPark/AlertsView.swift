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
    
    @State var showAlerts: Bool = true
    
    var body: some View{
        
        VStack(spacing: 16) {
            
            ZStack {
                Text("Alerts")
                    .font(.headline)
                
                Spacer()
                
            }
            .padding(.horizontal)

            if spots.isEmpty {
                Text("No alerts")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(spots) { spot in
                    alertRow(spot)
                }
            }
            
                        
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .padding()
        
        
    }
    
    
}
func alertRow(_ spot: ParkingSpot) -> some View {
    let startTime = spot.startTime ?? Date()
    let deadline = startTime.addingTimeInterval(Double(spot.timeLimitMinutes) * 60)

    return TimelineView(.periodic(from: .now, by: 1.0)) { context in
        let isExpired = context.date > deadline
        
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(isExpired ? .red : .orange)
            
            VStack(alignment: .leading) {
                Text(spot.title ?? "Unknown Spot")
                    .font(.headline)
                
                if isExpired {
                    Text("Expired")
                        .font(.subheadline)
                        .foregroundStyle(.red)
                } else {

                    Text(timerInterval: startTime...deadline, countsDown: true)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
        }
        .padding()
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}


