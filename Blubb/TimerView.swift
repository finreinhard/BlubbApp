//
//  TimerView.swift
//  Blubb
//
//  Created by Fin Reinhard on 28.01.20.
//  Copyright © 2020 Anguli Networks. All rights reserved.
//

import UIKit

class TimerView: UIView {
    
    var timerStopped = false
    let startDate: Date
    let plannedMinutes: Int
    var currentMode = Mode.REMAINING
    
    let timeLabel: UILabel
    let additionalTimeLabel: UILabel
    let switchButton: UIButton
    
    enum Mode {
        case ELAPSED
        case REMAINING
    }
    
    init(frame: CGRect, startDate: Date, plannedMinutes: Int) {
        self.startDate = startDate
        self.plannedMinutes = plannedMinutes
        
        var yOffset = CGFloat(0)
        
        self.timeLabel = UILabel(frame: CGRect(x: 0, y: yOffset, width: frame.width, height: 38))
        yOffset += self.timeLabel.bounds.height + 10
        
        self.additionalTimeLabel = UILabel(frame: CGRect(x: 0, y: yOffset, width: frame.width, height: 24))
        yOffset += self.additionalTimeLabel.bounds.height + 10
        
        self.switchButton = UIButton(frame: CGRect(x: 0, y: yOffset, width: frame.width, height: 24))
        self.switchButton.setTitleColor(UIColor(displayP3Red: 1, green: 1, blue: 1, alpha: 0.6), for: .normal)
        self.switchButton.titleLabel!.font = .italicSystemFont(ofSize: 18)
        
        super.init(frame: frame)
        
        self.buildView()
        
        self.addSubview(self.timeLabel)
        self.addSubview(self.additionalTimeLabel)
        self.addSubview(self.switchButton)
        
        let touchListener = UITapGestureRecognizer(target: self, action: #selector(self.handleTouch))
        self.switchButton.addGestureRecognizer(touchListener)
        
        self.updateView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func startTimer() {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) {(timer) in
            if self.timerStopped {
                timer.invalidate()
                return
            }
            
            self.updateView()
        }
    }
    
    func switchMode(to newMode: Mode) {
        self.currentMode = newMode
        
        self.buildView()
        self.updateView()
    }
    
    func buildView() {
        self.timeLabel.text = "00:00"
        self.timeLabel.textColor = .white
        self.timeLabel.font = .systemFont(ofSize: 38, weight: .bold)
        self.timeLabel.textAlignment = .center
        
        self.additionalTimeLabel.text = ""
        self.additionalTimeLabel.textColor = .white
        self.additionalTimeLabel.font = .systemFont(ofSize: 24, weight: .bold)
        self.additionalTimeLabel.textAlignment = .center
        
        var switchButtonTitle = ""
        
        switch self.currentMode {
        case .ELAPSED:
            switchButtonTitle = NSLocalizedString("Show remaining time", comment: "Shows the remaining time of the current activity.")
            break
        case .REMAINING:
            switchButtonTitle = NSLocalizedString("Show elapsed time", comment: "Shows the elapsed time of the current activity.")
            break
        }
        
        self.switchButton.setTitle(switchButtonTitle, for: .normal)
    }
    
    func updateView() {
        let secondsElapsed = Int(Date().timeIntervalSince(self.startDate))
        
        switch self.currentMode {
        case .ELAPSED:
            self.timeLabel.text = self.formatSeconds(secondsElapsed)
            break
        case .REMAINING:
            let remaining = self.plannedMinutes * 60 - secondsElapsed
            
            if remaining >= 0 {
                self.timeLabel.text = self.formatSeconds(remaining)
            } else {
                self.timeLabel.textColor = UIColor(displayP3Red: 1, green: 1, blue: 1, alpha: 0.7)
                self.timeLabel.text = self.formatSeconds(self.plannedMinutes * 60, converToMinutesAt: 0)
                self.additionalTimeLabel.text = "+ \(self.formatSeconds(remaining * -1))"
            }
            break
        }
    }
    
    func formatSeconds(_ seconds: Int, converToMinutesAt: Int = 5) -> String {
        if seconds >= converToMinutesAt * 60 {
            return String.localizedStringWithFormat(NSLocalizedString("%d minutes", comment: "Current passed minutes of the activity."), seconds / 60)
        }
        
        return String(format: "%02d:%02d", seconds / 60, seconds % 60)
    }
    
    public func stopTimer() {
        self.timerStopped = true
    }
    
    @objc func handleTouch(_ sender:UITapGestureRecognizer) {
        var newMode: Mode?
        
        switch self.currentMode {
        case .ELAPSED:
            newMode = .REMAINING
            break
        case .REMAINING:
            newMode = .ELAPSED
            break
        }
        
        self.switchMode(to: newMode!)
    }
}
