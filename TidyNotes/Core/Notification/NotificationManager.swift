//
//  NotificationManager.swift
//  TidyNotes
//
//  Created by Prizega Fromadia on 14/05/25.
//

import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    
    private init() {}

    func requestPermissionIfNeeded() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("🔴 Notification permission error: \(error.localizedDescription)")
            }
        }
    }

    func scheduleReminderNotification(id: String, title: String, date: Date) {
        let content = UNMutableNotificationContent()
        content.title = "⏰ Reminder"
        content.body = "Don't forget: \(title)"
        content.sound = .default

        let triggerDate = Calendar.current.date(byAdding: .minute, value: -10, to: date) ?? date

        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: triggerDate
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("🔴 Error scheduling notification: \(error.localizedDescription)")
            }
        }
    }

    func cancelNotification(id: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
    }
}
