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
                let alert = UIAlertController(title: "Notifications abgelehnt", message: "Durch die Ablehnung steht die App nicht im vollen Funktionsumfang zur Verfügung.", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "Beheben", style: .default) { _ in
                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                })
                
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
}

