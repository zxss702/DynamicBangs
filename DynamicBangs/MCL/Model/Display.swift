//  Copyright © MonitorControlLite. @waydabber

import Cocoa
import Foundation
import os.log

class Display: Equatable {
    let identifier: CGDirectDisplayID
    let prefsId: String
    var name: String
    var vendorNumber: UInt32?
    var modelNumber: UInt32?
    var serialNumber: UInt32?
    let swBrightnessSemaphore = DispatchSemaphore(value: 1)
    
    static func == (lhs: Display, rhs: Display) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    
    var isVirtual: Bool = false
    var isDummy: Bool = false
    
    var defaultGammaTableRed = [CGGammaValue](repeating: 0, count: 256)
    var defaultGammaTableGreen = [CGGammaValue](repeating: 0, count: 256)
    var defaultGammaTableBlue = [CGGammaValue](repeating: 0, count: 256)
    var defaultGammaTableSampleCount: UInt32 = 0
    var defaultGammaTablePeak: Float = 1
    
    init(_ identifier: CGDirectDisplayID, name: String, vendorNumber: UInt32?, modelNumber: UInt32?, serialNumber: UInt32?, isVirtual: Bool = false, isDummy: Bool = false) {
        self.identifier = identifier
        self.name = name
        self.vendorNumber = vendorNumber
        self.modelNumber = modelNumber
        self.serialNumber = serialNumber
        self.isVirtual = isVirtual
        self.isDummy = isDummy
        self.prefsId = "(" + String(name.filter { !$0.isWhitespace }) + String(vendorNumber ?? 0) + String(modelNumber ?? 0) + "@" + (self.isVirtual ? String(self.serialNumber ?? 9999) : String(identifier)) + ")"
        os_log("Display init with prefsIdentifier %{public}@", type: .info, self.prefsId)
        self.swUpdateDefaultGammaTable()
        if self.isVirtual, !self.isDummy {
            os_log("Creating or updating shade for display %{public}@", type: .info, String(self.identifier))
            _ = DisplayManager.shared.updateShade(displayID: self.identifier)
        } else {
            os_log("Destroying shade (if exists) for display %{public}@", type: .info, String(self.identifier))
            _ = DisplayManager.shared.destroyShade(displayID: self.identifier)
        }
    }
    
    func swUpdateDefaultGammaTable() {
        guard !self.isDummy else {
            return
        }
        CGGetDisplayTransferByTable(self.identifier, 256, &self.defaultGammaTableRed, &self.defaultGammaTableGreen, &self.defaultGammaTableBlue, &self.defaultGammaTableSampleCount)
        let redPeak = self.defaultGammaTableRed.max() ?? 0
        let greenPeak = self.defaultGammaTableGreen.max() ?? 0
        let bluePeak = self.defaultGammaTableBlue.max() ?? 0
        self.defaultGammaTablePeak = max(redPeak, greenPeak, bluePeak)
    }
    
    func setBrightness(_ value: Float) -> Bool {
        self.swBrightnessSemaphore.wait()
        let brightnessValue = max(min(1, value), 0)
        guard !self.isDummy else {
          self.swBrightnessSemaphore.signal()
          return true
        }
        var newValue = brightnessValue
        if self.isVirtual {
          self.swBrightnessSemaphore.signal()
          return DisplayManager.shared.setShadeAlpha(value: 1 - newValue, displayID: DisplayManager.resolveEffectiveDisplayID(self.identifier))
        } else {
          let gammaTableRed = self.defaultGammaTableRed.map { $0 * newValue }
          let gammaTableGreen = self.defaultGammaTableGreen.map { $0 * newValue }
          let gammaTableBlue = self.defaultGammaTableBlue.map { $0 * newValue }
          DisplayManager.shared.moveGammaActivityEnforcer(displayID: self.identifier)
          CGSetDisplayTransferByTable(self.identifier, self.defaultGammaTableSampleCount, gammaTableRed, gammaTableGreen, gammaTableBlue)
          DisplayManager.shared.enforceGammaActivity()
        }
        self.swBrightnessSemaphore.signal()
        return true
    }
}
