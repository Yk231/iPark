//
//  PhotoMapOverlap.swift
//  iPark
//
//  Created by Yotam Krikov on 5/16/26.
//

import SwiftUI
import MapKit
import PhotosUI

// For the thumbnail view, where they switch on tap
// In SavedSpotCard and SavedSpotquickLookOverlay
struct PhotoAndOrMap1: View {
    
    let spot: ParkingSpot
    @StateObject var photoController = PhotoController()
    @State private var showingMap: Bool = true

    private var hasLocation: Bool { spot.latitude != 0 || spot.longitude != 0 }
    private var hasPhoto: Bool { photoController.selectedImage != nil }

    var body: some View{
        
        
        
        ZStack {
            // BACKGROUND — full size
            if showingMap && hasLocation {
                MapView(longitude: spot.longitude, latitude: spot.latitude)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .allowsHitTesting(false)
            } else if let image = photoController.selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .frame(height: 200)
                    .clipped()
            }

            // THUMBNAIL — bottom right, only when both exist
            if hasLocation && hasPhoto {
                Group {
                    if showingMap, let image = photoController.selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 90, height: 70)
                            .clipped()
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    } else if !showingMap && hasLocation {
                        MapView(longitude: spot.longitude, latitude: spot.latitude)
                            .frame(width: 90, height: 70)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .allowsHitTesting(false)
                    }
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(.white.opacity(0.5), lineWidth: 1.5)
                )
                .shadow(color: .black.opacity(0.3), radius: 6, x: 0, y: 3)
                .padding(10)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
            }

            // TAP LAYER
            if hasLocation && hasPhoto {
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            showingMap.toggle()
                        }
                    }
            }
        }
        .frame(height: 200)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(.ultraThinMaterial)
        )
        .onAppear {
            let data = spot.photo
            photoController.load(from: data)

        }
        
        
    }
}




// Mini overlay in rows of AlertsView and HistoryView
struct PhotoAndOrMap2: View {
    
    let spot: ParkingSpot
    @StateObject var photoController = PhotoController()
    
    private var hasLocation: Bool { spot.latitude != 0 || spot.longitude != 0 }
    private var hasPhoto: Bool { photoController.selectedImage != nil }

    var body: some View{
        
        
        
        ZStack {
            // BACKGROUND — full size
            if hasLocation && hasPhoto {
                    
                RoundedRectangle(cornerRadius: 18)
                    .fill(.black.opacity(0.35))
                    .frame(width: 100, height: 92)
                    .offset(x: 6, y: 6)
                
                MapView(longitude: spot.longitude, latitude: spot.latitude)
                    .frame(width: 100, height: 92)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                    .allowsHitTesting(false)

                    
            }
            else if !hasPhoto{
                MapView(longitude: spot.longitude, latitude: spot.latitude)
                    .frame(width: 100, height: 92)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                    .allowsHitTesting(false)
            }
            else if let image = photoController.selectedImage{
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 92)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 18))

            }
        }
        .onAppear {
            photoController.load(from: spot.photo)
        }
        .onChange(of: spot.photo) { _, newData in
            photoController.load(from: newData)
        }

        
        
    }
}
