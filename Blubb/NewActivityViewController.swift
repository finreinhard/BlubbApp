//
//  NewActivityViewController.swift
//  Blubb
//
//  Created by Fin Reinhard on 28.07.19.
//  Copyright © 2019 Anguli Networks. All rights reserved.
//

import UIKit
import UserNotifications

class NewActivityViewController: UIViewController {
    
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
        
        notificationContent.title = "Mach eine Pause"
        notificationContent.body = "Prima! Du hast gut was geschafft. Jetzt wird es aber Zeit für eine Pause."
        notificationContent.sound = .default
        
        let notificationDate = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second], from: Date(timeIntervalSinceNow: 3600))
        let trigger = UNCalendarNotificationTrigger(dateMatching: notificationDate, repeats: false)
        UNUserNotificationCenter.current().add(UNNotificationRequest(identifier: "Break Notification", content: notificationContent, trigger: trigger))
        
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
    
    @IBAction func handleEndButtonClick(_ sender: UIButton) {
        let endDate = Date()
        
        let nameAlert = UIAlertController(title: "Aktivität abgeschlossen", message: "Super! Jetzt brauchen wir nur noch einen Namen", preferredStyle: .alert)
        
        nameAlert.addTextField()
        nameAlert.addAction(UIAlertAction(title: NSLocalizedString("Löschen", comment: "Lösche die Aktivität"), style: .destructive){ _ in
            UINotificationFeedbackGenerator().notificationOccurred(.error)
            self.navigateToMainScreen()
        })
        nameAlert.addAction(UIAlertAction(title: NSLocalizedString("Speichern", comment: "Speichere die Aktivität"), style: .default){ _ in
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            let description = nameAlert.textFields![0].text!
        })
        
        self.present(nameAlert, animated: true){
            self.timerStopped = true
        }
    }
    
    func navigateToMainScreen() {
        self.navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    
}
