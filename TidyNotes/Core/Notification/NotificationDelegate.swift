//
//  NotificationDelegate.swift
//  TidyNotes
//
//  Created by Prizega Fromadia on 14/05/25.
//

import Foundation
import UserNotifications
import UIKit

class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationDelegate()

    private override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }

    // Tampilkan notifikasi saat app sedang dibuka
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }

    // Handle aksi button dari notif
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let id = response.notification.request.identifier
        let userInfo = response.notification.request.content.userInfo

        if let taskIdString = userInfo["taskId"] as? String,
           let taskId = UUID(uuidString: taskIdString) {
            DispatchQueue.main.async {
                DeepLinkManager.shared.handle(.openTaskDetail(taskId: taskId))
            }
        }
        
        switch response.actionIdentifier {
        case "SNOOZE_ACTION":
            let newDate = Date().addingTimeInterval(600) // 10 menit snooze
            NotificationManager.shared.scheduleReminderNotification(id: id, title: "Snoozed Reminder", date: newDate)

        case "CLOSE_ACTION":
            NotificationManager.shared.cancelNotification(id: id)
            // Tambahkan call update task via Realm (di bagian ini nanti kita lanjutkan)
            ServiceLocator.shared.taskRepository.disableReminder(for: id)

        default:
            break
        }

        completionHandler([.banner, .sound, .list])
    }
}
