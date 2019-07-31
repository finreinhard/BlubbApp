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
}

