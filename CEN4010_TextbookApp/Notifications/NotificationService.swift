//
//  NotificationService.swift
//  CEN4010_TextbookApp
//
//  Created by Julian Arnau on 11/28/25
//

import UserNotifications

// Manages Local notifications within the app
extension NotificationManager
{

    func scheduleLocalNotification(
        title: String,
        body: String,
        after seconds: TimeInterval = 1
    ) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: seconds,
            repeats: false
        )

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Notification failed: \(error.localizedDescription)")
            }
        }
    }
}


/*
I'm not sure if it's needed but I essentially wrote a helper on Notification manager so anywhere in the app we can do something like:
NotificationManager.shared.scheduleLocalNotification(
    title: "New message",
    body: "Someone contacted you about your textbook."
)
*/
