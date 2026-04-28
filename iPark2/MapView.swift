//
//  MapView.swift
//  iPark2
//
//  Created by Taila Iwase on 4/23/26.
//

import SwiftUI
import MapKit

struct MapView: View {
    let longitude: Double
    let latitude: Double
    var title: String = "Location"

    @State private var position: MapCameraPosition

    private var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    init(longitude: Double, latitude: Double, title: String = "Location") {
        self.longitude = longitude
        self.latitude = latitude
        self.title = title
        let coord = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        _position = State(initialValue: .region(MKCoordinateRegion(center: coord,
                                                                   span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))))
    }

    var body: some View {
        Map(position: $position) {
            Marker(title, coordinate: coordinate)
        }
        .mapStyle(.standard)
        .accessibilityLabel("Map showing \(title)")
    }
}




#Preview {
    MapView(longitude: -122.4194, latitude: 37.7749)
        .frame(height: 240)
        .padding()
}
