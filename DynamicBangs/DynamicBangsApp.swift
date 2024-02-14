//
//  DynamicBangsApp.swift
//  DynamicBangs
//
//  Created by 张旭晟 on 2024/2/12.
//

import SwiftUI
import PrivateMediaRemote
import Cocoa
import Foundation
import os.log
import CoreGraphics
import MediaKeyTap
import Foundation
import IOKit.ps

enum BatteryError: Error { case error }

struct mediaInfoFunction: Equatable {
    var image: Image?
    var name: String
    var Artist: String
    var Artist2: String
    var isPlay:Bool
    var fullType:Int = 0
}

struct volumeInfoFunction: Equatable {
    var volome: Float
    var fullType: Int = 0
}
struct BrightInfoFunction: Equatable {
    var bright: Float
    var fullType: Int = 0
}
// 定义CoreDisplay_Display_SetUserBrightness函数的类型
typealias CoreDisplay_Display_SetUserBrightness = @convention(c) (CGDirectDisplayID, Double) -> Void

// 动态加载CoreDisplay框架并尝试调用CoreDisplay_Display_SetUserBrightness函数
func setBrightnessForAllDisplays(brightness: Double) {
    // 动态加载CoreDisplay框架
    guard let coreDisplay = dlopen("/System/Library/Frameworks/CoreDisplay.framework/CoreDisplay", RTLD_NOW) else {
        print("Failed to load CoreDisplay.framework")
        return
    }
    
    // 尝试获取CoreDisplay_Display_SetUserBrightness函数的地址
    guard let CDSetUserBrightness = dlsym(coreDisplay, "CoreDisplay_Display_SetUserBrightness") else {
        print("Failed to locate CoreDisplay_Display_SetUserBrightness")
        dlclose(coreDisplay)
        return
    }
    
    // 将函数地址转换为Swift可调用的函数
    let setUserBrightness = unsafeBitCast(CDSetUserBrightness, to: CoreDisplay_Display_SetUserBrightness.self)
    
    // 获取所有活动显示器的ID并设置亮度
    let displayIDs = NSScreen.screens.map { ($0.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as! NSNumber).uint32Value }
    for displayID in displayIDs {
        setUserBrightness(displayID, brightness)
    }
    
//    // 卸载CoreDisplay框架
    dlclose(coreDisplay)
}

typealias setBrightness = @convention(c) (Float) -> Void

func setKeyBrightness(brightness: Float) {
    // 动态加载CoreBrightness框架
    guard let coreBrightness = dlopen("/System/Library/PrivateFrameworks/CoreBrightness.framework/CoreBrightness", RTLD_NOW) else {
        print("Failed to load CoreBrightness.framework")
        return
    }
    
    // 尝试获取设置键盘亮度的函数地址，这里使用伪函数名作为示例
    guard let setKeyboardBrightnessFunction = dlsym(coreBrightness, "CBSetKeyboardBrightness") else {
        print("Failed to locate the function to set keyboard brightness")
        dlclose(coreBrightness)
        return
    }
    
    // 将函数地址转换为Swift可调用的函数
    let function = unsafeBitCast(setKeyboardBrightnessFunction, to: (@convention(c) (Float) -> Void).self)
    
    // 调用函数设置键盘亮度
    function(brightness)
    
    // 卸载CoreBrightness框架
    dlclose(coreBrightness)
}

struct ChargingInfoFunction: Equatable {
    var isCharging: Bool = false
    var isConnect: Bool = false
    var beter: Int = 0
    var fullType: Int = 10
}
class AppObserver: NSObject, ObservableObject, MediaKeyTapDelegate {
    var windows:[NSWindow] = []
    
    @Published var media:mediaInfoFunction?
    @Published var volume:volumeInfoFunction
    @Published var bright:BrightInfoFunction?
    @Published var keyBright:BrightInfoFunction?
    @Published var isCharging:ChargingInfoFunction = ChargingInfoFunction()
    
    override init() {
        volume = volumeInfoFunction(volome: Sound.output.volume, fullType: 10)
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(setWindow), name: NSApplication.didChangeScreenParametersNotification, object: nil)
        
        MRMediaRemoteRegisterForNowPlayingNotifications(.main)
        NotificationCenter.default.addObserver(self, selector: #selector(upDateMedia), name: NSNotification.Name.mrMediaRemoteNowPlayingInfoDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(upDateMedia), name: NSNotification.Name.mrMediaRemotePickableRoutesDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(upDateMedia), name: NSNotification.Name.mrMediaRemoteNowPlayingApplicationDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(upDateMedia), name: NSNotification.Name.mrMediaRemoteNowPlayingApplicationIsPlayingDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(upDateMedia), name: NSNotification.Name.mrMediaRemoteRouteStatusDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(upDateMedia), name: NSNotification.Name.mrNowPlayingPlaybackQueueChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(upDateMedia), name: NSNotification.Name.mrPlaybackQueueContentItemsChanged, object: nil)
        
        setvolume()
        upDateMedia()
        DispatchQueue.main.async { [self] in
            setWindow()
        }
    }
    
    deinit {
        MRMediaRemoteUnregisterForNowPlayingNotifications()
    }
    
    var mediaKeyTap: MediaKeyTap?
    
    func handle(mediaKey: MediaKey, event: KeyEvent?, modifiers: NSEvent.ModifierFlags?) {
        switch mediaKey {
        case .brightnessUp:
            self.bright = BrightInfoFunction(bright: min((self.bright?.bright ?? 1) + 0.0625, 1))
            setBrightnessForAllDisplays(brightness: Double((self.bright?.bright ?? 1)))
        case .brightnessDown:
            self.bright = BrightInfoFunction(bright: max((self.bright?.bright ?? 1) - 0.0625, 0))
            setBrightnessForAllDisplays(brightness: Double((self.bright?.bright ?? 1)))
        case .volumeUp:
            try? Sound.output.setVolume(Sound.output.volume + 0.0625)
            self.volume = volumeInfoFunction(volome: Sound.output.volume)
        case .volumeDown:
            try? Sound.output.setVolume(Sound.output.volume - 0.0625)
            self.volume = volumeInfoFunction(volome: Sound.output.volume)
        case .mute:
            try? Sound.output.mute(!Sound.output.isMuted)
            self.volume = volumeInfoFunction(volome: Sound.output.isMuted ? 0 : Sound.output.volume)
        case .backlightUP:
           
            self.keyBright = BrightInfoFunction(bright: min((self.keyBright?.bright ?? 1) + 0.0625, 1))
            setKeyBrightness(brightness: (self.keyBright?.bright ?? 1))
        case .backlightDown:
            self.keyBright = BrightInfoFunction(bright: max((self.keyBright?.bright ?? 1) - 0.0625, 0))
            setKeyBrightness(brightness: (self.keyBright?.bright ?? 1))
        default:
            break
        }
        setTime()
    }
    
    func setBeter() {
        do {
            // Take a snapshot of all the power source info
            guard let snapshot = IOPSCopyPowerSourcesInfo()?.takeRetainedValue()
                else { throw BatteryError.error }

            // Pull out a list of power sources
            guard let sources: NSArray = IOPSCopyPowerSourcesList(snapshot)?.takeRetainedValue()
                else { throw BatteryError.error }

            // For each power source...
            for ps in sources {
                // Fetch the information for a given power source out of our snapshot
                guard let info: NSDictionary = IOPSGetPowerSourceDescription(snapshot, ps as CFTypeRef)?.takeUnretainedValue()
                    else { throw BatteryError.error }

                // Pull out the name and current capacity
                if 
                    let IsCharging = info[kIOPSIsChargingKey] as? Int,
                    let power = info[kIOPSPowerSourceStateKey] as? String,
                    let capacity = info[kIOPSCurrentCapacityKey] as? Int
                {
                    let isConnect = power == kIOPSACPowerValue
                    if isConnect {
                        if (IsCharging == 1) != isCharging.isCharging  || isConnect != isCharging.isConnect {
                            isCharging = ChargingInfoFunction(isCharging: IsCharging == 1, isConnect: isConnect, beter: capacity, fullType: 0)
                        }
                    } else {
                        if isCharging.isConnect {
                            print("scd")
                            isCharging = ChargingInfoFunction(isCharging: IsCharging == 1, isConnect: isConnect, beter: capacity, fullType: 0)
                        }
                    }
                }
            }
        } catch { }
    }
    
    func setvolume() {
        mediaKeyTap = MediaKeyTap(delegate: self, for: [.volumeUp, .volumeDown, .mute, ])//.brightnessUp, .brightnessDown, .backlightDown, .backlightUP])
        mediaKeyTap?.start()
    }
    
    @objc func upDateMedia() {
        MRMediaRemoteGetNowPlayingInfo(DispatchQueue.main, { (information) in
            if let information = information {
                let name = (information[kMRMediaRemoteNowPlayingInfoTitle] as? String) ?? "未知作品"
                let Artist = (information[kMRMediaRemoteNowPlayingInfoArtist] as? String) ?? "未知作者"
                let Artist2 = (information[kMRMediaRemoteNowPlayingInfoAlbum] as? String) ?? ""
                
                if self.media?.name != name || self.media?.Artist != Artist || self.media?.Artist2 != Artist2 {
                    if self.media == nil {
                        self.media = mediaInfoFunction(name: name, Artist: Artist, Artist2: Artist2, isPlay: false)
                    } else {
                        self.media?.name = name
                        self.media?.Artist = Artist
                        self.media?.Artist2 = Artist2
                    }
                    self.media?.fullType = 0
                    self.media?.image = nil
                    if let data = information[kMRMediaRemoteNowPlayingInfoArtworkData] as? Data {
                        let artwork = NSImage(data: data)
                        self.media?.image = Image(nsImage: artwork!)
                    }
                } else {
                    if let data = information[kMRMediaRemoteNowPlayingInfoArtworkData] as? Data {
                        let artwork = NSImage(data: data)
                        if self.media?.image == nil {
                            self.media?.image = Image(nsImage: artwork!)
                        }
                    }
                }
            } else {
                self.media = nil
            }
        })
        
        MRMediaRemoteGetNowPlayingApplicationIsPlaying(.main) { Bool in
            self.media?.isPlay = Bool
        }
        setTime()
    }
    
    var time:Timer?
    func setTime() {
        if time == nil {
            time = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [self] Timer in
                self.media?.fullType += 1
                
                if self.volume.fullType < 10 {
                    self.volume.fullType += 1
                }
                if self.bright?.fullType ?? 10 < 10 {
                    self.bright?.fullType += 1
                } else {
                    self.bright = nil
                }
                if self.keyBright?.fullType ?? 10 < 10 {
                    self.keyBright?.fullType += 1
                } else {
                    self.keyBright = nil
                }
                self.isCharging.fullType += 1
                setBeter()
                
//                if self.keyBright?.fullType ?? 10 >= 10 && self.bright?.fullType ?? 10 >= 10 && self.volume.fullType >= 10 && self.media?.fullType ?? 10 >= 10 {
//                    time?.invalidate()
//                    time = nil
//                }
            }
        }
    }
    
    @objc func setWindow() {
        for item in windows {
            item.close()
        }
        windows.removeAll()
        for i in NSScreen.screens {
            let hostionViewController = NSHostingController(rootView: isLandView().environmentObject(self))
            let BangsWindow = NotchWindow()
            BangsWindow.targetScreen = i
            BangsWindow.contentViewController = hostionViewController
            BangsWindow.styleMask = [.borderless, .nonactivatingPanel]
            BangsWindow.backingType = .buffered
            BangsWindow.backgroundColor = .clear
            BangsWindow.hasShadow = false
            BangsWindow.level = .screenSaver
            BangsWindow.collectionBehavior =  [.canJoinAllSpaces, .stationary, .fullScreenAuxiliary]
            BangsWindow.setFrame(i.frame, display: true)
            let notchWindowController = NSWindowController()
            notchWindowController.contentViewController = BangsWindow.contentViewController
            
            notchWindowController.window = BangsWindow
            notchWindowController.showWindow(self)
            windows.append(BangsWindow)
        }
    }
}

class NotchWindow: NSWindow {
    var targetScreen: NSScreen!
    
    override func constrainFrameRect(_ frameRect: NSRect, to screen: NSScreen?) -> NSRect {
        return super.constrainFrameRect(frameRect, to: targetScreen)
    }
}



@main
struct DynamicBangsApp: App {
    @StateObject var appObserver = AppObserver()
    
    @Environment(\.openWindow) var openWindow
    
    var body: some Scene {
        MenuBarExtra("灵动刘海设置", systemImage: "rectangle.portrait.topthird.inset.filled") {
            Button("打开设置") {
                openWindow.callAsFunction(id: "灵动刘海设置")
            }
            Divider()
            Button("退出程序") {
                NSApplication.shared.terminate(nil)
            }
        }
        Window(Text("灵动刘海设置"), id: "灵动刘海设置") {
            SettingView()
                .environmentObject(appObserver)
        }
    }
}
