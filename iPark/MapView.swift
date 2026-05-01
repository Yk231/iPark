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
    var userLocation: CLLocationCoordinate2D? = nil

    @State private var position: MapCameraPosition

    private var spotCoordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    // MARK: - Init

    init(longitude: Double, latitude: Double, title: String = "Location", userLocation: CLLocationCoordinate2D? = nil) {
        self.longitude = longitude
        self.latitude = latitude
        self.title = title
        self.userLocation = userLocation

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
            if let userCoord = userLocation {
                Marker("You", coordinate: userCoord)
                    .tint(.green)
                MapPolyline(coordinates: [userCoord, spotCoordinate])
                    .stroke(.blue, lineWidth: 3)
            }
        }
        .mapStyle(.standard)
        .accessibilityLabel("Map showing \(title)")
        .onChange(of: userLocation?.latitude) { _ in
            zoomToFitBoth()
        }
    }

    // MARK: - Private Methods

    private func zoomToFitBoth() {
        guard let userCoord = userLocation else { return }

        let minLat = min(spotCoordinate.latitude, userCoord.latitude)
        let maxLat = max(spotCoordinate.latitude, userCoord.latitude)
        let minLon = min(spotCoordinate.longitude, userCoord.longitude)
        let maxLon = max(spotCoordinate.longitude, userCoord.longitude)

        let center = CLLocationCoordinate2D(
            latitude: (minLat + maxLat) / 2,
            longitude: (minLon + maxLon) / 2
        )

        let span = MKCoordinateSpan(
            latitudeDelta: (maxLat - minLat) * 2.5,
            longitudeDelta: (maxLon - minLon) * 2.5
        )

        withAnimation {
            position = .region(MKCoordinateRegion(center: center, span: span))
        }
    }
}

// MARK: - Preview

#Preview {
    MapView(longitude: -122.4194, latitude: 37.7749)
        .frame(height: 240)
        .padding()
}
