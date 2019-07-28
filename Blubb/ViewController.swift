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

    func formatDate(_ date: Date, short isShortForm: Bool = true) -> String {
        let calendar = Calendar.current
        
        var dateString = ""
        
        if !isShortForm {
            dateString = "\(calendar.component(.day, from: date)). \(calendar.monthSymbols[calendar.component(.month, from: date)]) \(calendar.component(.year, from: date)) "
        }
        
        return "\(dateString)\(String(format: "%02d:%02d", calendar.component(.hour, from: date), calendar.component(.minute, from: date)))"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let lastActivity = UIView(frame: CGRect(x:20, y:100, width: self.view.bounds.width - 40, height: 50))
        
        lastActivity.layer.borderWidth = 1
        lastActivity.layer.borderColor = UIColor(red: 221/255, green: 221/255, blue: 221/255, alpha: 1).cgColor
        lastActivity.layer.cornerRadius = 5
        
        let description = UILabel(frame: CGRect(x: 15, y: 5, width: lastActivity.bounds.width - 30, height: 20))
        description.text = "Lorem Ipsum"
        description.font = .boldSystemFont(ofSize: 14)
        
        let time = UILabel(frame: CGRect(x: 15, y: 25, width: lastActivity.bounds.width - 30, height: 20))
        
        let start = Calendar.current.date(byAdding: .hour, value: -1, to: Date())!
        let end = Date()
        time.text = "\(formatDate(start, short: false)) - \(formatDate(end)) Uhr"
        time.font = .systemFont(ofSize: 14)
        
        lastActivity.addSubview(description)
        lastActivity.addSubview(time)
        
        self.view.addSubview(lastActivity)
        
        let notificationCenter = UNUserNotificationCenter.current()
        
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) {
            (didAllow, error) in
            if !didAllow {
                let alert = UIAlertController(title: "Notifications abgelehnt", message: "Durch die Ablehnung steht die App nicht im Volle Funktionsumfang zur Verfügung.", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: NSLocalizedString("Beheben", comment: "Default action"), style: .default) { _ in
                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                })
                
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
}

