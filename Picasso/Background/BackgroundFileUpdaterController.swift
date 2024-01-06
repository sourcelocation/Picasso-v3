//
//  BackgroundFileUpdaterController.swift
//  Picasso
//
//  Created by sourcelocation on 08/14/23.
//

import Foundation
import SwiftUI
import SystemConfiguration
import Combine

struct BackgroundOption: Identifiable {
    var id = UUID()
    var key: String
    var title: String
    var enabled: Bool = true
}

public class BackgroundFileUpdaterController {
    static public let shared = BackgroundFileUpdaterController()
    
    public var time = 120.0
    private var timer: Timer?
    
    func restartTimer() {
        ApplicationMonitor.shared.start()
        self.applyTweaks()
        timer = Timer.scheduledTimer(withTimeInterval: time, repeats: true) { timer in
            self.applyTweaks()
        }
    }
    
    func stopTimer() {
        ApplicationMonitor.shared.stop()
        timer?.invalidate()
        timer = nil
    }
    
    func applyTweaks() {
        UserDefaults.standard.set(true, forKey: "wasBackgroundRefreshing")
        Task {
            try await TweakApplier.shared.applyTweaks()
            UserDefaults.standard.set(false, forKey: "wasBackgroundRefreshing")
        }
    }
}
