//
//  MapView.swift
//  iPark2
//
//  Created by Taila Iwase on 4/23/26.
//

import SwiftUI
import MapKit

struct MapView: View {

    // MARK: - Properties

    let longitude: Double
    let latitude: Double
    var title: String = "Location"

    @State private var position: MapCameraPosition

    private var spotCoordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    // MARK: - Init

    init(longitude: Double, latitude: Double, title: String = "Parking Spot") {
        self.longitude = longitude
        self.latitude = latitude
        self.title = title

        let coord = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        _position = State(initialValue: .region(MKCoordinateRegion(
            center: coord,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )))
    }

    // MARK: - Body

    var body: some View {
        Map(position: $position) {
            Marker(title, coordinate: spotCoordinate)
                .tint(.blue)
        }
        .mapStyle(.standard)
        .accessibilityLabel("Map showing \(title)")
        .onChange(of: latitude) { recenter() }
        .onChange(of: longitude) { recenter() }

    }
    
    
    
    
    
    // MARK: - Helper functions
    // Recenter function
    private func recenter() {
        let coord = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        position = .region(MKCoordinateRegion(
            center: coord,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        ))
    }

 
}




// MARK: - Preview

#Preview {
    MapView(longitude: -122.4194, latitude: 37.7749)
        .frame(height: 240)
        .padding()
}
