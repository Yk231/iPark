//
//  CreateSpotView.swift
//  iPark2
//
//  Created by Yotam Krikov on 4/22/26.
//

import SwiftUI
import CoreLocation
import CoreData

struct CreateSpotView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var locationManager = LocationController()
    @State private var title: String = ""
    @State private var floor: String = ""
    @State private var notes: String = ""
    @State private var section: String = ""
    @State private var number: String = ""

    // Initializer to set textfields to existing values,
    // Only if we're editting a pre-existing spot.
    let existingSpot: ParkingSpot?
    init(existingSpot: ParkingSpot? = nil) {
        self.existingSpot = existingSpot
        
        _title = State(initialValue: existingSpot?.title ?? "")
        _notes = State(initialValue: existingSpot?.notes ?? "")
        _floor = State(initialValue: existingSpot?.floor != nil ? String(existingSpot!.floor) : "")
        _section = State(initialValue: existingSpot?.section ?? "")
        _number = State(initialValue: existingSpot?.number != nil ? String(existingSpot!.number) : "")
    }

    var body: some View {
        
        logo
            
        List {
            Section("Spot Details") {
                TextField("Title", text: $title)
                TextField("Floor", text: $floor)
                    .keyboardType(.numberPad)
                    .onChange(of: floor) {
                        floor = floor.filter { $0.isNumber }
                    }
                TextField("Section", text: $section)
                TextField("Number", text: $number)
                    .keyboardType(.numberPad)
                    .onChange(of: number) {
                        number = number.filter { $0.isNumber }
                    }
                TextField("Notes", text: $notes)
            }
            
            Section("Location") {
                if let location = locationManager.currentLocation {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Latitude: \(location.coordinate.latitude)")
                        Text("Longitude: \(location.coordinate.longitude)")
                    }
                    .font(.subheadline)
                } else {
                    Text("No location captured yet.")
                        .foregroundStyle(.secondary)
                }
                
                Button(action: {
                    locationManager.startUpdating()
                }, label: {
                    Text("Use Current Location")
                })
            }
            
            Section("Time Limit") {
                
            }

            Section {
                Button {
                    guard let location = locationManager.currentLocation else { return }
                    
                    let coordinate = location.coordinate
                    
                    // EDIT existing spot
                    if let spot = existingSpot {
                        spot.title = title.isEmpty ? "Saved Spot \(spot.id!.uuidString.prefix(4))" : title
                        spot.notes = notes
                        spot.section = section
                        spot.latitude = coordinate.latitude
                        spot.longitude = coordinate.longitude
                        if let floorInt = Int16(floor) {
                            spot.floor = floorInt
                        }
                        if let numberInt = Int16(number) {
                            spot.number = numberInt
                        }
                    }
                    // CREATE new spot
                    else {
                        let newSpot = ParkingSpot(context: viewContext)
                        newSpot.id = UUID()
                        newSpot.title = title.isEmpty ? "Saved Spot \(newSpot.id!.uuidString.prefix(4))" : title
                        newSpot.notes = notes
                        newSpot.section = section
                        newSpot.latitude = coordinate.latitude
                        newSpot.longitude = coordinate.longitude
                        newSpot.startTime = Date()
                        if let floorInt = Int16(floor) {
                            newSpot.floor = floorInt
                        }
                        if let numberInt = Int16(number) {
                            newSpot.number = numberInt
                        }
                    }
                    
                    do {
                        try viewContext.save()
                    } catch {
                        print("Save failed:", error)
                    }
                    
                    dismiss()
                    
                } label: {
                    Text(existingSpot == nil ? "Save Spot" : "Update Spot")
                }
            }
        }
        .navigationTitle(existingSpot == nil ? "Create Spot" : "Edit Spot")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    
    var logo: some View {
        Text("\(Text("i").foregroundStyle(.blue))\(Text("Park"))")
            .font(.largeTitle.bold())
    }

}

