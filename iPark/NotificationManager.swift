//
//  NotificationManager.swift
//  iPark2
//
//  Created by Taila Iwase on 4/30/26.
//

import Foundation
import UserNotifications


class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationManager()
    
    override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }
    
    // MARK: - Permission
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error { print("Notification permission error:", error) }
        }
    }

    // MARK: - Schedule
    func scheduleNotification(for spot: ParkingSpot) {
        guard let id = spot.id?.uuidString,
              spot.timeLimitMinutes > 0,
              let title = spot.title else { return }
        
        cancelNotification(for: spot)
        
        let totalSeconds = Double(spot.timeLimitMinutes) * 60
        guard totalSeconds > 0 else { return }
                           
        let alerts: [(label: String, secondsBefore: Double)] = [
                    ("You have 15 minutes left for '\(title)'",  15 * 60),
                    ("You have 10 minutes left for '\(title)'",  10 * 60),
                    ("You have 5 minutes left for '\(title)'",    5 * 60),
                    ("Your time for '\(title)' is up!",           0)
                ]
        
        for alert in alerts {
            let fireAt = totalSeconds - alert.secondsBefore
            guard fireAt > 0 else { continue } // skip if time limit is shorter than the warning window

            let content = UNMutableNotificationContent()
            content.title = "Parking Alert — \(title)"
            content.body = alert.label
            content.sound = .default

            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: fireAt, repeats: false)
            let identifier = "\(id)_\(Int(alert.secondsBefore))"
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

            UNUserNotificationCenter.current().add(request) { error in
                if let error { print("Failed to schedule '\(alert.label)' notification:", error) }
            }
        }
    }
    
    // MARK: - Cancel Notifactions
    func cancelNotification(for spot: ParkingSpot) {
        guard let id = spot.id?.uuidString else { return }

        let identifiers = [15 * 60, 10 * 60, 5 * 60, 0].map { "\(id)_\($0)" }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
    }
    
    // MARK: - Presentation of Notification
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge])
    }
}
