//
//  MapPickerSheet.swift
//  iPark
//
//  Created by Yotam Krikov on 5/12/26.
//

import SwiftUI


struct MapPickerSheet: View {
    @Binding var isPresented: Bool
    let spot: ParkingSpot
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 8) {
            
            // MAIN CARD
            VStack(spacing: 0) {
                Text("Open in Maps")
                    .font(.headline)
                    .padding(.vertical, 16)
                
                Divider()
                
                // Apple and Google Maps
                mapButton(title: "Apple Maps", image: "apple-maps-icon", map: "apple")
                if UIApplication.shared.canOpenURL(URL(string: "comgooglemaps://")!) {
                    mapButton(title: "Google Maps", image: "google-maps-icon", map: "google")
                }
                

            }
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal, 12)
            
            // CANCEL CARD
            Button {
                isPresented = false
            } label: {
                Text("Cancel")
                    .font(.body.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding()
            }
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal, 12)
        }
        .presentationDetents([.height(320)])
        .presentationDragIndicator(.hidden)
        .presentationBackground(.clear)
    }
    
    // MARK: - Map Row
    private func mapButton(title: String, image: String, map: String) -> some View {
        Button {
            openDirections(map: map)
            isPresented = false
        } label: {
            HStack(spacing: 14) {
                Image(image)
                    .resizable()
                    .frame(width: 32, height: 32)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                Text(title)
                    .font(.body)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
        .buttonStyle(.plain)
        
    }
    
    
    
    
    // MARK: - Open Directions function
    private func openDirections(map: String) {
        if map == "apple"{
            let appleMapsURL = URL(string: "maps://?daddr=\(spot.latitude),\(spot.longitude)&dirflg=d")!
            UIApplication.shared.open(appleMapsURL)
        }
        if map == "google"{
            let googleMapsURL = URL(string: "comgooglemaps://?daddr=\(spot.latitude),\(spot.longitude)&directionsmode=driving")!
            UIApplication.shared.open(googleMapsURL)
        }
    }
    
}



