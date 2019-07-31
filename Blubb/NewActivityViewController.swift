//
//  NewActivityViewController.swift
//  Blubb
//
//  Created by Fin Reinhard on 28.07.19.
//  Copyright © 2019 Anguli Networks. All rights reserved.
//

import UIKit
import UserNotifications
import EventKit
import EventKitUI

class NewActivityViewController: UIViewController, EKEventEditViewDelegate {
    
    func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
        controller.dismiss(animated: true)
        
        if action == .saved {
            self.navigateToMainScreen()
            
            let notificationContent = UNMutableNotificationContent()
            
            notificationContent.title = NSLocalizedString("Break over", comment: "Notification title for break end")
            notificationContent.body = NSLocalizedString("Back to work! You can do this!", comment: "Notification body for break end")
            notificationContent.sound = .default
            
            // Clear Notifications before queueing new one
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            
            let notificationDate = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second], from: Date(timeIntervalSinceNow: 1800))
            let trigger = UNCalendarNotificationTrigger(dateMatching: notificationDate, repeats: false)
            UNUserNotificationCenter.current().add(UNNotificationRequest(identifier: "Break Over Notification", content: notificationContent, trigger: trigger))
            
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }
    }
    
    @IBOutlet weak var counter: UILabel!
    let startDate = Date()
    var timerStopped = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (timer) in
            if self.timerStopped {
                timer.invalidate()
                return
            }
            
            let time = Int(Date().timeIntervalSince(self.startDate))
            self.counter.text = String(format: "%02d:%02d", time / 60, time % 60)
        }
        
        let notificationContent = UNMutableNotificationContent()
        
        notificationContent.title = NSLocalizedString("Take a Break", comment: "Notification title for break start")
        notificationContent.body = NSLocalizedString("Nice! You have done a lot. Now it is time for a 30 minutes break.", comment: "Notification body for break start")
        notificationContent.sound = .default
        
        // Clear Notifications before queueing new one
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        let notificationDate = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second], from: Date(timeIntervalSinceNow: 3600))
        let trigger = UNCalendarNotificationTrigger(dateMatching: notificationDate, repeats: false)
        UNUserNotificationCenter.current().add(UNNotificationRequest(identifier: "Break Notification", content: notificationContent, trigger: trigger))
        
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
    
    @IBAction func handleEndButtonClick(_ sender: UIButton) {
        let endDate = Date()
        
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        let nameAlert = UIAlertController(title: NSLocalizedString("Activity Done", comment: "Save Activity Alert title"), message: NSLocalizedString("Good Job! Now we need a name.", comment: "Save Activity Alert body"), preferredStyle: .alert)
        
        nameAlert.addTextField()
        nameAlert.addAction(UIAlertAction(title: NSLocalizedString("Delete", comment: "Delete the activity"), style: .destructive){ _ in
            UINotificationFeedbackGenerator().notificationOccurred(.error)
            self.navigateToMainScreen()
        })
        nameAlert.addAction(UIAlertAction(title: NSLocalizedString("Save", comment: "Save the activity"), style: .default){ _ in
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            let description = nameAlert.textFields![0].text!
            
            let eventStore = EKEventStore()
            
            eventStore.requestAccess(to: .event){ granted, error in
                if granted && error == nil {
                    let event = EKEvent(eventStore: eventStore)
                    event.title = description
                    event.startDate = self.startDate
                    event.endDate = endDate
                    event.notes = NSLocalizedString("Created with Blubb.", comment: "Event note")
                    event.calendar = eventStore.defaultCalendarForNewEvents
                    
                    DispatchQueue.main.async {
                        let eventViewController = EKEventEditViewController()
                        eventViewController.event = event
                        eventViewController.eventStore = eventStore
                        eventViewController.editViewDelegate = self
                        
                        self.present(eventViewController, animated: true)
                    }
                }
            }
        })
        
        self.present(nameAlert, animated: true){
            self.timerStopped = true
        }
    }
    
    func navigateToMainScreen() {
        dismiss(animated: true)
    }
    
}
