//
//  ViewController.swift
//  Blubb
//
//  Created by Fin Reinhard on 28.07.19.
//  Copyright © 2019 Anguli Networks. All rights reserved.
//

import UIKit
import UserNotifications

class ViewController: UIViewController {
    
    @IBOutlet weak var minutesInput: UITextField!
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let notificationCenter = UNUserNotificationCenter.current()
        
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) {
            (didAllow, error) in
            if !didAllow {
                let alert = UIAlertController(title: NSLocalizedString("Notifications declined", comment: "Title for notifications declined alert"), message: NSLocalizedString("Due the rejection, the app is not available in full functionality.", comment: "Summary for notifications declined alert"), preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: NSLocalizedString("Fix", comment: "Fix the issue"), style: .default) { _ in
                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                })
                
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let minutes = defaults.string(forKey: defaultsKeys.minutesInput) {
            self.minutesInput.text = minutes
            
            if let currentStartDate = defaults.string(forKey: defaultsKeys.currentActivityStartDate) {
                print(currentStartDate)
                print(Date(timeIntervalSince1970: TimeInterval(Double(currentStartDate)!)))
                self.showActivityModal(duration: Int(minutes)!, startedAt: Date(timeIntervalSince1970: TimeInterval(Double(currentStartDate)!)))
            }
        }
    }
    
    @IBAction func onMinutesChanged(_ sender: Any) {
        var color = UIColor.systemBlue
        
        if Int(self.minutesInput.text!) == nil {
            color = .red;
        }
        
        self.minutesInput.textColor = color
    }
    
    @IBAction func onMinutesEditEnd(_ sender: Any) {
        self.startNewActivity()
    }
    
    
    @IBAction func onNewActivityClicked(_ sender: Any) {
        self.startNewActivity()
    }
    
    func startNewActivity() {
        if let minutes = Int(self.minutesInput.text!) {

            let startDate = Date()
            
            defaults.set(self.minutesInput.text!, forKey: defaultsKeys.minutesInput)
            defaults.set("\(startDate.timeIntervalSince1970)", forKey: defaultsKeys.currentActivityStartDate)
            
            self.showActivityModal(duration: minutes, startedAt: startDate)
        }
    }
    
    func showActivityModal(duration minutes: Int, startedAt startDate: Date) {
        self.modalTransitionStyle = .coverVertical
        self.modalPresentationStyle = .automatic
        
        let storyboard = self.storyboard!
        let controller = storyboard.instantiateViewController(withIdentifier: "newActivity") as! NewActivityViewController
        
        controller.timerMinutes = minutes
        controller.startDate = startDate
        
        self.present(controller, animated: true, completion: nil)
    }
}

