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
    
    var body: some View {
        
        LogoView()
        
        if completedSpots.isEmpty {
            Text("No history yet")
                .foregroundStyle(.secondary)
        }
        else{
            List {
                ForEach(completedSpots) { spot in
                    SavedSpotDetailView(spot: spot, showsEndTime: true)
                        .allowsHitTesting(false)
                        .listRowInsets(EdgeInsets())
                        //.listRowSeparator(.hidden)
                        .listRowBackground(Color.white)
                        .padding()
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 4)
                        
                        
                        //Swipe right to delete from memory
                        .swipeActions(edge: .leading) {
                            Button(role: .destructive) {
                                withAnimation {
                                    delete(spot)
                                }
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                        
                        //Swipe left to unarchive
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button {
                                withAnimation {
                                    unarchive(spot)
                                }
                            } label: {
                                Label("Unarchive", systemImage: "arrow.uturn.backward")
                            }
                            .tint(.green)
                        }


                }
                
            }
            .listStyle(.plain)
            .navigationTitle("History")
        }


        
    }
    
    
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

        do {
            try viewContext.save()
        } catch {
            print("Unarchival failed:", error)
        }
    }


    

}
