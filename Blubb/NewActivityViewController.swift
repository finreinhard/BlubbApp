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
    
    @IBOutlet weak var counter: UILabel!
    let defaults = UserDefaults.standard
    var timerStopped = false
    public var timerMinutes = 60
    public var startDate = Date()
    
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
    
    func getProgressFrame(percentageDone: CGFloat) -> CGRect {
        return CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height * percentageDone)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backgroundGradient = CAGradientLayer()
        backgroundGradient.colors = [UIColor.systemBlue.cgColor, UIColor.systemGreen.cgColor]
        backgroundGradient.frame = self.view.bounds
        backgroundGradient.locations = [1, 1]
        self.view.layer.insertSublayer(backgroundGradient, at: 0)
        
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (timer) in
            if self.timerStopped {
                timer.invalidate()
                return
            }
            
            if !self.view.bounds.equalTo(backgroundGradient.frame) {
                backgroundGradient.frame = self.view.bounds
            }

            let time = Int(Date().timeIntervalSince(self.startDate))
            
            if time >= 5 * 60 {
                self.counter.text = String.localizedStringWithFormat(NSLocalizedString("%d minutes", comment: "Current passed minutes of the activity."), time / 60)
            } else {
                self.counter.text = String(format: "%02d:%02d", time / 60, time % 60)
            }
            
            
            if time > self.timerMinutes * 60 {
                backgroundGradient.locations = [0, 0]
            } else {
                let percentage = NSNumber(value: 1 - Double(time) / (Double(self.timerMinutes) * 60.0))
                backgroundGradient.locations = [percentage, percentage]
            }
        }
        
        let notificationContent = UNMutableNotificationContent()
        
        notificationContent.title = NSLocalizedString("Take a Break", comment: "Notification title for break start")
        notificationContent.body = NSLocalizedString("Nice! You have done a lot. Now it is time for a 30 minutes break.", comment: "Notification body for break start")
        notificationContent.sound = .default
        
        // Clear Notifications before queueing new one
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        let notificationDate = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second], from: Date(timeInterval: TimeInterval(self.timerMinutes * 60), since: self.startDate))
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
            
            self.defaults.removeObject(forKey: defaultsKeys.currentActivityStartDate)
        }
    }
    
    func navigateToMainScreen() {
        dismiss(animated: true)
    }
    
}
