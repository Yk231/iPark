//
//  CreateSpotView.swift
//  iPark2
//
//  Created by Yotam Krikov on 4/22/26.
//

import SwiftUI
import CoreLocation
import CoreData
import MapKit
import PhotosUI

struct CreateSpotView: View {
    // MARK: - Enviroment and variables
    // Enviroment
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    
    // Form Fields
    @State private var title: String = ""
    @State private var floor: String = ""
    @State private var notes: String = ""
    @State private var section: String = ""
    @State private var number: String = ""
    @State private var selectedHours: Int = 0
    @State private var selectedMinutes: Int = 0
    @State private var hasTimeLimit: Bool = false
    var timeLimitMinutes: Int {
        selectedHours * 60 + selectedMinutes
    }
    
    // Photo
    @StateObject private var photoManager = PhotoController()
    @State private var showPhotoSourcePicker: Bool = false
    @State private var showPhotoPicker: Bool = false
    @State private var showCamera: Bool = false
    @State private var addOrReplacePhotoLabel: String = "Add photo"
    @State private var pendingPhotoAction: (() -> Void)? = nil

 
    // Location
    @StateObject private var locationManager = LocationController()
    @State private var mapPosition: MapCameraPosition
    @State private var pinCoordinate: CLLocationCoordinate2D? = nil
    
    // Alerts
    enum ActiveAlert: Identifiable{
        case noLocationOrPhoto
        var id: Self { self }
    }
    @State private var activeAlert: ActiveAlert? = nil
    
    // MARK: - Init
    let existingSpot: ParkingSpot?
    init(existingSpot: ParkingSpot? = nil) {
        self.existingSpot = existingSpot
        
        // Basic details
        _title = State(initialValue: existingSpot?.title ?? "")
        _notes = State(initialValue: existingSpot?.notes ?? "")
        _floor = State(initialValue:
                        existingSpot.map { $0.floor == 0 ? "" : String($0.floor) } ?? ""
        )
        _number = State(initialValue:
                            existingSpot.map { $0.number == 0 ? "" : String($0.number) } ?? ""
        )
        _section = State(initialValue: existingSpot?.section ?? "")
        
        // Pre-load existing photo
        //photoManager.load(from: data)

        // Pre-load map with coordinates
        if let spot = existingSpot, spot.latitude != 0 || spot.longitude != 0 {
            let coord = CLLocationCoordinate2D(latitude: spot.latitude, longitude: spot.longitude)
            _pinCoordinate = State(initialValue: coord)
            _mapPosition = State(initialValue: .region(MKCoordinateRegion(
                center: coord,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )))
        } else {
            _pinCoordinate = State(initialValue: nil)
            _mapPosition = State(initialValue: .region(MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 42.3601, longitude: -71.0589),
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )))
        }
        
        // Time limit
        let limit = Int(existingSpot?.timeLimitMinutes ?? 0)
        _hasTimeLimit = State(initialValue: limit > 0)
        _selectedHours = State(initialValue: limit / 60)
        _selectedMinutes = State(initialValue: limit % 60)
    }

    
    // MARK: - Body
    var body: some View {
        
        LogoView()
        
        
        List {
            
            
            // MARK: - BASIC DETAILS
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
            
            
            
            // MARK: - Photo
            Section("Photo") {
                if let image = photoManager.selectedImage {
                    
                    // Show selected photo with tap to replace
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 300)
                        .frame(maxWidth: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .listRowInsets(EdgeInsets())
                        .onTapGesture { showPhotoSourcePicker = true }
                        .padding(16)

                } else {
                    // Empty dotted placeholder
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.blue.opacity(0.07))
                            .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [8]))
                            .frame(height: 140)

                        VStack(spacing: 8) {
                            Image(systemName: "plus.circle")
                                .font(.system(size: 32))
                                .foregroundStyle(.secondary)
                            Text("Add Photo")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .onTapGesture { showPhotoSourcePicker = true }
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                }
                
                // Add or Replace Photo
                Button {
                    showPhotoSourcePicker = true
                } label: {
                    let text = photoManager.imageExists ? "Replace Photo" : "Add Photo"
                    Text("\(text)")
                }
                
                // Clear Photo
                Button(role: .destructive) {
                    photoManager.clear()
                } label: {
                    Text("Remove Photo")
                }
                
            }
            // Load photo from existingSpot if it exists
            .onAppear {
                photoManager.load(from: existingSpot?.photo)
            }
            .onChange(of: photoManager.photoPickerItem) { _, _ in
                Task { await photoManager.loadFromPicker() }
            }
            // Add photo sheet
            .sheet(isPresented: $showPhotoSourcePicker, onDismiss: {
                pendingPhotoAction?()
                pendingPhotoAction = nil
            }) {
                PhotoSourcePickerSheet(
                    isPresented: $showPhotoSourcePicker,
                    imageExists: photoManager.imageExists,
                    onCamera: {
                        pendingPhotoAction = { showCamera = true }
                    },
                    onLibrary: {
                        pendingPhotoAction = { showPhotoPicker = true }
                    },
                    onRemove: {
                        photoManager.clear()
                    }
                )
            }
            // Camera sheet
            .sheet(isPresented: $showCamera) {
                CameraView(image: $photoManager.selectedImage)
            }
            // Photo library picker
            .photosPicker(
                isPresented: $showPhotoPicker,
                selection: $photoManager.photoPickerItem,
                matching: .images
            )


            
            
            // MARK: - LOCATION
            Section("Location") {
                
                // Map View
                MapReader { proxy in
                    Map(position: $mapPosition) {
                        if let pin = pinCoordinate {
                            Marker("Parking Spot", coordinate: pin)
                                .tint(.blue)
                        }
                    }
                    .frame(height: 220)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .onTapGesture { screenPoint in
                        if let coord = proxy.convert(screenPoint, from: .local) {
                            pinCoordinate = coord
                        }
                    }
                }
                .listRowInsets(EdgeInsets())
                
                // Use Current Location button
                Button {
                    locationManager.startUpdating()
                } label: {
                    Text("Use Current Location")
                }
                
                // Clear Location button
                Button(role: .destructive) {
                    locationManager.clearLocation()
                    pinCoordinate = nil
                } label: {
                    Text("Clear Location")
                }
            }
            .onChange(of: locationManager.currentLocation) { _, newLocation in
                guard let newLocation else { return }
                let coord = newLocation.coordinate
                pinCoordinate = coord
                mapPosition = .region(MKCoordinateRegion(
                    center: coord,
                    span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
                ))
                locationManager.stopUpdating()
                
            }
            
            
            
            // MARK: - TIME LIMIT
            Section("Time Limit"){
                let hours = Array(0...23)
                
                let minutes = Array(0...59)
                
                
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
            
            
            
            // MARK: - SAVE BUTTON
            Section {
                Button {
                    // Must have at least a location or a photo
                    guard pinCoordinate != nil || photoManager.imageExists else {
                        activeAlert = .noLocationOrPhoto
                        return
                    }
                    saveSpot()
                    dismiss()
                } label: {
                    Text(existingSpot == nil ? "Save Spot" : "Update Spot")
                }
            }
            
            
        }
        .navigationTitle(existingSpot == nil ? "Create Spot" : "Edit Spot")
        .navigationBarTitleDisplayMode(.inline)
        // MARK: - .alerts
        .alert(item: $activeAlert) { alert in
            switch alert {
            case .noLocationOrPhoto:
                return Alert(
                    title: Text("No Location or Photo"),
                    message: Text("Please add either a location or a photo before saving."),
                    dismissButton: .cancel(Text("OK"))
                )
            }
        }
        
        
        
        

       
        
    }
    
    // MARK: - Helper functions
    // Saves a spot to persistent storage OR updates a pre-existing spot's data
    func saveSpot() {
        let coordinate = pinCoordinate
                
        if let spot = existingSpot {
            spot.title = title.isEmpty ? "Parking Spot \(spot.id!.uuidString.prefix(4))" : title
            spot.notes = notes
            spot.section = section
            spot.latitude = coordinate?.latitude ?? 0
            spot.longitude = coordinate?.longitude ?? 0
            spot.photo = photoManager.jpegData
            if let v = Int16(floor) { spot.floor = v }
            if let v = Int16(number) { spot.number = v }
            if hasTimeLimit && timeLimitMinutes > 0 {
                spot.timeLimitMinutes = Int16(timeLimitMinutes)
                NotificationManager.shared.scheduleNotification(for: spot)
            } else {
                spot.timeLimitMinutes = 0
                NotificationManager.shared.cancelNotification(for: spot)
            }
        } else {
            let newSpot = ParkingSpot(context: viewContext)
            newSpot.id = UUID()
            newSpot.title = title.isEmpty ? "Parking Spot \(newSpot.id!.uuidString.prefix(4))" : title
            newSpot.notes = notes
            newSpot.section = section
            newSpot.latitude = coordinate?.latitude ?? 0
            newSpot.longitude = coordinate?.longitude ?? 0
            newSpot.photo = photoManager.jpegData
            newSpot.startTime = Date()
            if let v = Int16(floor) { newSpot.floor = v }
            if let v = Int16(number) { newSpot.number = v }
            if hasTimeLimit && timeLimitMinutes > 0 {
                newSpot.timeLimitMinutes = Int16(timeLimitMinutes)
                NotificationManager.shared.scheduleNotification(for: newSpot)
            }
        }
        do {
            try viewContext.save()
        } catch {
            print("Save failed:", error)
        }
    }
}

