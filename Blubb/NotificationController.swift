//
//  NotificationController.swift
//  Blubb
//
//  Created by Fin Reinhard on 27.01.20.
//  Copyright © 2020 Anguli Networks. All rights reserved.
//

import Foundation
import UserNotifications
import UIKit

class NotificationController {
    var permissionGranted = false
    let notificationCenter: UNUserNotificationCenter
    
    init(viewController: UIViewController) {
        self.notificationCenter = UNUserNotificationCenter.current()
        
        self.notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) {
            (didAllow, error) in
            
            self.permissionGranted = didAllow
            
            if !didAllow {
                let alert = UIAlertController(title: NSLocalizedString("Notifications declined", comment: "Title for the notifications declined alert"), message: NSLocalizedString("If you wan't to get informed about your activities, you should allow notifications.", comment: "Summary for notifications declined alert"), preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: NSLocalizedString("Ignore", comment: "Ignore the notification feature"), style: .cancel))
                
                alert.addAction(UIAlertAction(title: NSLocalizedString("Grant access", comment: "Grant notification access"), style: .default) { _ in
                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                })
                
                viewController.present(alert, animated: true)
            }
        }
    }
    
    func sendNotification(identifier: String, title: String, body: String, date: Date) {
        if !permissionGranted {
            return
        }
        
        self.clearAllPrendingNotifications()
        
        let notificationContent = UNMutableNotificationContent()
        
        notificationContent.title = title
        notificationContent.body = body
        notificationContent.sound = .default
        
        let notificationDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: notificationDate, repeats: false)
        
        self.notificationCenter.add(UNNotificationRequest(identifier: identifier, content: notificationContent, trigger: trigger))
    }
    
    func sendBreakOverIn30MinutesNotification() {
        self.sendNotification(identifier: "breakOver", title: NSLocalizedString("Break over", comment: "Notification title for break end"), body: NSLocalizedString("Back to work! You can do this!", comment: "Notification body for break end"), date: Date(timeIntervalSinceNow: 30 * 60))
    }
    
    func sendTakeABreakNotification(in minutes: Int, from startDate: Date) {
        self.sendNotification(identifier: "takeABreak", title: NSLocalizedString("Take a Break", comment: "Notification title for break start"), body: NSLocalizedString("Nice! You have done a lot. Now it is time for a 30 minutes break.", comment: "Notification body for break start"), date: Date(timeInterval: TimeInterval(minutes * 60), since: startDate))
    }
    
    func clearAllPrendingNotifications() {
        if !permissionGranted {
            return
        }
        
        self.notificationCenter.removeAllPendingNotificationRequests()
    }
}
