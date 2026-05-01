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
    @State private var selectedHours: Int = 0
    @State private var selectedMinutes: Int = 1
    @State private var hasTimeLimit: Bool = false
    
    var timeLimitMinutes: Int {
        selectedHours * 60 + selectedMinutes
    }

    let existingSpot: ParkingSpot?
    init(existingSpot: ParkingSpot? = nil) {
        self.existingSpot = existingSpot
        
        _title = State(initialValue: existingSpot?.title ?? "")
        _notes = State(initialValue: existingSpot?.notes ?? "")
        _floor = State(initialValue:
            existingSpot.map {
                $0.floor == 0 ? "" : String($0.floor)
            } ?? ""
        )
        _number = State(initialValue:
            existingSpot.map {
                $0.number == 0 ? "" : String($0.number)
            } ?? ""
        )
        _section = State(initialValue: existingSpot?.section ?? "")
        _hasTimeLimit = State(initialValue: existingSpot?.timeLimitMinutes != nil && existingSpot!.timeLimitMinutes > 0)
        if let existing = existingSpot, existing.timeLimitMinutes > 0 {
            _selectedHours = State(initialValue: Int(existing.timeLimitMinutes) / 60)
            _selectedMinutes = State(initialValue: Int(existing.timeLimitMinutes) % 60)
        }
        
    }
    
    var body: some View {
                
        LogoView()
        
        
        List {
            
            
            // BASIC DETAILS ------------------------------------------------------------------------------------
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
            
            
            
            
            
            
            
            // LOCATION ------------------------------------------------------------------------------------
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
            
            
            
            
            
            
            
            // TIME LIMIT ------------------------------------------------------------------------------------
            Section("Time Limit"){
                let hours = Array(0...23)
                
                let minutes = [1, 15, 30, 45]
        
                
                Toggle("Enable Time Limit", isOn: $hasTimeLimit)
                if hasTimeLimit {
                    
                    HStack {
                        
                        // Hours
                        Picker("Hours", selection: $selectedHours) {
                            ForEach(hours, id: \.self) { hour in
                                Text("\(hour) h")
                                    .tag(hour)
                            }
                        }
                        .pickerStyle(.wheel)
                        
                        // Minutes
                        Picker("Minutes", selection: $selectedMinutes) {
                            ForEach(minutes, id: \.self) { minute in
                                Text("\(minute) m")
                                    .tag(minute)
                            }
                        }
                        .pickerStyle(.wheel)
                                                
                    }
                    .frame(height: 150)
                                        
                }
                
            }
            
            
            
            
            // SAVE BUTTON ------------------------------------------------------------------------------------
            Section {
                Button {
                    guard let location = locationManager.currentLocation else { return }
                    
                    let coordinate = location.coordinate
                    
                    // EDIT existing spot
                    if let spot = existingSpot {
                        spot.title = title.isEmpty ? "Parking Spot \(spot.id!.uuidString.prefix(4))" : title
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
                        if hasTimeLimit {
                            spot.timeLimitMinutes = Int16(timeLimitMinutes)
                           
                            NotificationManager.shared.cancelNotification(for: spot)
                            NotificationManager.shared.scheduleNotification(for: spot)
                            
                        } else {
                        
                            NotificationManager.shared.cancelNotification(for: spot)
                          
                        }
                    }
                    // CREATE new spot
                    else {
                        let newSpot = ParkingSpot(context: viewContext)
                        newSpot.id = UUID()
                        newSpot.title = title.isEmpty ? "Parking Spot \(newSpot.id!.uuidString.prefix(4))" : title
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
                        if hasTimeLimit {
                            newSpot.timeLimitMinutes = Int16(timeLimitMinutes)
                            
                            NotificationManager.shared.scheduleNotification(for: newSpot)
                         
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
    
}

