//
//  NewActivityViewController.swift
//  Blubb
//
//  Created by Fin Reinhard on 28.07.19.
//  Copyright © 2019 Anguli Networks. All rights reserved.
//

import UIKit
import EventKit
import EventKitUI

class NewActivityViewController: UIViewController, EKEventEditViewDelegate {
    
    @IBOutlet weak var counter: UILabel!
    let defaults = UserDefaults.standard
    var notificationController: NotificationController? = nil
    var timerStopped = false
    public var timerMinutes = 60
    public var startDate = Date()
    
    func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
        controller.dismiss(animated: true)
        
        if action == .saved {
            self.navigateToMainScreen()
            
            self.notificationController!.sendBreakOverIn30MinutesNotification()
            
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.notificationController = NotificationController(viewController: self)
        
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
        
        self.notificationController!.sendTakeABreakNotification(in: self.timerMinutes, from: self.startDate)
        
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
