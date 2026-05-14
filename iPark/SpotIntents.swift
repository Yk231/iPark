//
//  SpotIntents.swift
//  iPark
//
//  Created by Yotam Krikov on 5/14/26.
//

import AppIntents
import CoreLocation
import CoreData

// MARK: - Save Parking Spot Intent
struct SaveParkingSpotIntent: AppIntent {

    static var title: LocalizedStringResource = "Save Parking Spot"
    static var description = IntentDescription("Saves your current location as a parking spot in iPark.")

    // Optional title the user can provide via Siri
    @Parameter(title: "Spot Title", default: "")
    var spotTitle: String
    
    func perform() async throws -> some ReturnsValue<String> & ProvidesDialog {

        // Siri follows up by asking for a spotTitle
        if spotTitle.isEmpty {
            spotTitle = try await $spotTitle.requestValue("What would you like to call this spot?")
        }

        
        let context = await PersistenceController.shared.container.viewContext
        let locationManager = await IntentLocationManager()

        // Request location
        let coordinate = try await locationManager.requestLocation()

        // Create spot on main thread
        let result: String = try await MainActor.run {
            let newSpot = ParkingSpot(context: context)
            newSpot.id = UUID()
            newSpot.startTime = Date()
            newSpot.latitude = coordinate.latitude
            newSpot.longitude = coordinate.longitude
            newSpot.title = spotTitle.isEmpty
                ? "Parking Spot \(newSpot.id!.uuidString.prefix(4))"
                : spotTitle

            do {
                try context.save()
                return newSpot.title ?? "Parking Spot"
            } catch {
                throw error
            }
        }

        return .result(
            value: result,
            dialog: "Got it! I saved \"\(result)\" as your parking spot."
        )
    }
}


// MARK: - App Shortcuts
struct iParkShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: SaveParkingSpotIntent(),
            phrases: [
                "Save my parking spot in \(.applicationName)",
                "I parked in \(.applicationName)",
                "Remember my parking spot in \(.applicationName)"
            ],
            shortTitle: "Save Parking Spot",
            systemImageName: "parkingsign.circle.fill"
        )
    }
}

// MARK: - Location Manager for Intents

private class IntentLocationManager: NSObject, CLLocationManagerDelegate {

    private let manager = CLLocationManager()
    private var continuation: CheckedContinuation<CLLocationCoordinate2D, Error>?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }

    func requestLocation() async throws -> CLLocationCoordinate2D {
        return try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
            manager.requestWhenInUseAuthorization()
            manager.requestLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        continuation?.resume(returning: location.coordinate)
        continuation = nil
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        continuation?.resume(throwing: error)
        continuation = nil
    }
}
