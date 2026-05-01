//
//  ParkingSpot.swift
//  iPark2
//
//  Created by Yotam Krikov on 4/22/26.
//

import Foundation
import CoreLocation

struct SavedSpot: Codable, Identifiable {
    
    let id: UUID
    let latitude: Double
    let longitude: Double
    let title: String
    let floor: Int?
    let section: String?
    let number: Int?
    let notes: String?
    let startTime: Date
    let endTime: Date?
    let distanceTo: Double
    let timeLimitMinutes: Int?
    
    
    init(id: UUID, latitude: Double, longitude: Double, title: String? = nil, floor: Int? = nil, section: String? = nil, number: Int? = nil, notes: String? = nil, timeLimitMinutes: Int? = nil) {
        self.id = id
        self.latitude = latitude
        self.longitude = longitude

        //Title
        if let unwrappedTitle = title, !unwrappedTitle.isEmpty {
            self.title = unwrappedTitle
        } else {
            self.title = "Parking Spot \(self.id.uuidString.prefix(4))"
        }
    
        self.floor = floor
        self.section = section
        self.number = number
        self.notes = notes
        self.startTime = Date()
        self.distanceTo = 0
        self.endTime = nil
        self.timeLimitMinutes = timeLimitMinutes
    }
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
