//
//  SavedSpotCard.swift
//  iPark
//
//  Created by Yotam Krikov on 5/16/26.
//

import SwiftUI
import MapKit

struct SavedSpotCard: View {

    let spot: ParkingSpot
    @StateObject var photoController = PhotoController()
    @State private var showingMap: Bool = true

    private var hasLocation: Bool { spot.latitude != 0 || spot.longitude != 0 }
    private var hasPhoto: Bool { photoController.selectedImage != nil }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {

            // MARK: - Header
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(spot.title ?? "Parking Spot")
                        .font(.title3.bold())
                    Text("Your current saved parking spot.")
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer()
                Image(systemName: "mappin.circle.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(.blue)
            }

            Divider()

            // MARK: - Timer
            if spot.timeLimitMinutes > 0 {
                let startTime = spot.startTime ?? Date()
                let deadline = startTime.addingTimeInterval(Double(spot.timeLimitMinutes) * 60)
                TimelineView(.periodic(from: .now, by: 1.0)) { context in
                    let isExpired = context.date > deadline
                    HStack {
                        Image(systemName: "timer")
                        if isExpired { Text("Expired") }
                        else { Text(timerInterval: startTime...deadline, countsDown: true) }
                    }
                    .font(.subheadline.bold())
                    .foregroundStyle(isExpired ? .red : .blue)
                    .padding(.vertical, 4)
                }
            }

            // MARK: - PhotoAndOrMap
            PhotoAndOrMap1(spot: spot)
            
            

            // MARK: - Navigate to Detail
            NavigationLink {
                SavedSpotDetailView(spot: spot)
            } label: {
                Text("View Parking Spot")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.blue)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .buttonStyle(.plain)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 26)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 26)
                .stroke(.white.opacity(0.06), lineWidth: 1)
        )
        .onAppear {
            photoController.load(from: spot.photo)
        }
        .onChange(of: spot.photo) { _, newData in
            photoController.load(from: newData)
        }
    }
}
