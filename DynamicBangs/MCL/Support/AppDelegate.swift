//  Copyright © MonitorControlLite. @waydabber

import AVFoundation
import Cocoa
import Foundation
import os.log
import ServiceManagement

var app = AppDelegate()

class AppDelegate: NSObject {
    var reconfigureID: Int = 0 // dispatched reconfigure command ID
    var sleepID: Int = 0 // sleep event ID
    var safeMode = false
    
    func applicationDidFinishLaunching() {
        self.subscribeEventListeners()
        CGDisplayRegisterReconfigurationCallback({ CGDirectDisplayID, CGDisplayChangeSummaryFlags, UnsafeMutableRawPointer in
            app.displayReconfigured()
        }, nil)
        self.configure(firstrun: true)
        DisplayManager.shared.createGammaActivityEnforcer()
    }
    
    @objc func displayReconfigured() {
        CGDisplayRestoreColorSyncSettings()
        self.reconfigureID += 1
        os_log("Bumping reconfigureID to %{public}@", type: .info, String(self.reconfigureID))
        _ = DisplayManager.shared.destroyAllShades()
        if self.sleepID == 0 {
            let dispatchedReconfigureID = self.reconfigureID
            os_log("Display to be reconfigured with reconfigureID %{public}@", type: .info, String(dispatchedReconfigureID))
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.configure(dispatchedReconfigureID: dispatchedReconfigureID)
            }
        }
    }
    
    func configure(dispatchedReconfigureID: Int = 0, firstrun: Bool = false) {
        guard self.sleepID == 0, dispatchedReconfigureID == self.reconfigureID else {
            return
        }
        os_log("Request for configuration with reconfigreID %{public}@", type: .info, String(dispatchedReconfigureID))
        self.reconfigureID = 0
        DisplayManager.shared.gammaInterferenceCounter = 0
        DisplayManager.shared.configureDisplays()
        DisplayManager.shared.addDisplayCounterSuffixes()
    }
    
    private func subscribeEventListeners() {
        DistributedNotificationCenter.default.addObserver(self, selector: #selector(self.displayReconfigured), name: NSNotification.Name(rawValue: kColorSyncDisplayDeviceProfilesNotification.takeRetainedValue() as String), object: nil) // ColorSync change
        NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(self.sleepNotification), name: NSWorkspace.screensDidSleepNotification, object: nil) // sleep and wake listeners
        NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(self.wakeNotification), name: NSWorkspace.screensDidWakeNotification, object: nil)
        NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(self.sleepNotification), name: NSWorkspace.willSleepNotification, object: nil)
        NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(self.wakeNotification), name: NSWorkspace.didWakeNotification, object: nil)
    }
    
    @objc private func sleepNotification() {
        self.sleepID += 1
        os_log("Sleeping with sleep %{public}@", type: .info, String(self.sleepID))
    }
    
    @objc private func wakeNotification() {
        if self.sleepID != 0 {
            os_log("Waking up from sleep %{public}@", type: .info, String(self.sleepID))
            let dispatchedSleepID = self.sleepID
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { // Some displays take time to recover...
                self.soberNow(dispatchedSleepID: dispatchedSleepID)
            }
        }
    }
    
    private func soberNow(dispatchedSleepID: Int) {
        if self.sleepID == dispatchedSleepID {
            os_log("Sober from sleep %{public}@", type: .info, String(self.sleepID))
            self.sleepID = 0
            if self.reconfigureID != 0 {
                let dispatchedReconfigureID = self.reconfigureID
                os_log("Displays need reconfig after sober with reconfigureID %{public}@", type: .info, String(dispatchedReconfigureID))
                self.configure(dispatchedReconfigureID: dispatchedReconfigureID)
            }
        }
    }
    
}
