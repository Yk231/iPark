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
    
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
        
            } else if let error = error {
            }
        }
    }
    
    func scheduleNotification(for spot: ParkingSpot) {
        guard let id = spot.id?.uuidString,
              spot.timeLimitMinutes > 0,
              let title = spot.title else {
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = "Parking Time Alert"
        content.body = "Your time for '\(title)' is up!"
        content.sound = .default
        
        let timeInterval = Double(spot.timeLimitMinutes) * 60
    
        guard timeInterval > 0 else { return }
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
            } else {

            }
        }
    }
    
    func cancelNotification(for spot: ParkingSpot) {
        guard let id = spot.id?.uuidString else { return }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge])
    }
}



