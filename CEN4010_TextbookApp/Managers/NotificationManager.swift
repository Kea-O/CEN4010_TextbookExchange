//
//  NotificationManager.swift
//  CEN4010_TextbookApp
//
//  Created by Julian Arnau on 11/27/25
//

import Foundation
import UserNotifications

//Essentially handles all notifdication tasks for the app
final class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    
    static let shared = NotificationManager()
    
    private override init()
    {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }
    
    //Asks the user for permission to send notifications (like all apps does)
    func requestAuthorizationIfNeeded()
    {
        let center = UNUserNotificationCenter.current()
        
        center.getNotificationSettings { settings in
            switch settings.authorizationStatus
            {
            case .notDetermined:
                //We have never asked the user before
                center.requestAuthorization(options: [.alert, .badge, .sound])
                { granted, error in
                    if let error = error
                    {
                        print("Notification auth error: \(error.localizedDescription)")
                    } else
                    {
                        print("Notifications granted? \(granted)")
                    }
                }
            default:
            
            
                break
            }
        }
    }

    func notifyNewMessage(from senderName: String, about bookTitle: String) {
        let content = UNMutableNotificationContent()
        content.title = "New message from \(senderName)"
        content.body  = "They messaged you about \"\(bookTitle)\"."
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: 1,
            repeats: false
        )
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error.localizedDescription)")
            }
        }
    }
    
    func userNotificationCenter
    (
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    )
    {
        completionHandler([.banner, .sound])
    }
}
    




    /*
    in the messaging code call this function like this for example (delete comment when done):
    NotificationManager.shared.notifyNewMessage(
    from: senderName,
    about: textbookTitle
    )
    */

    /*
    Call this once when the app launches (for example in AppDelegate):
    NotificationManager.shared.requestAuthorizationIfNeeded()
    */
