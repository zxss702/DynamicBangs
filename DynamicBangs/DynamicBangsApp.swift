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
import Foundation
import IOKit.ps
import AVFoundation

enum BatteryError: Error { case error }

struct mediaInfoFunction: Equatable {
    var image: Image?
    var name: String
    var Artist: String
    var Artist2: String
    var isPlay:Bool
    var fullType:Int = 10
    
    var fullTime: Double = 0.1
    var nowTime: Double = 0
}

protocol InfoFunctionFloat: Equatable {
    var value: Float { get set }
    var fullType: Int { get set }
}

struct messageInfoFunction: Equatable, Identifiable {
    var title: String = ""
    var color: Color = .white
    var image: Image?
    var title2: String = ""
    var body: String = ""
    
    var fullType: Int = 0
    var id = UUID()
}
struct volumeInfoFunction: InfoFunctionFloat {
    var value: Float
    var fullType: Int = 0
}
struct BrightInfoFunction: InfoFunctionFloat {
    var value: Float
    var fullType: Int = 0
}

struct ChargingInfoFunction: Equatable {
    var isCharging: Bool = false
    var isConnect: Bool = false
    var beter: Int = 0
    var fullType: Int = 10
}

extension String {
     
    //将原始的url编码为合法的url
    func urlEncoded() -> String {
        let encodeUrlString = self.addingPercentEncoding(withAllowedCharacters:
            .urlQueryAllowed)
        return encodeUrlString ?? ""
    }
     
    //将编码后的url转换回原始的url
    func urlDecoded() -> String {
        return self.removingPercentEncoding ?? ""
    }
}


struct mediaAppCanShow: Codable, Identifiable {
    var id: String
    var canShow: Bool = true
}

class AppObserver: NSObject, NSApplicationDelegate, ObservableObject, MediaKeyTapDelegate {
    var windows:[NSWindow] = []
    
    @Published var media:mediaInfoFunction?
    
    @Published var volume:volumeInfoFunction? = volumeInfoFunction(value: Sound.output.volume, fullType: 10)
    @Published var bright:BrightInfoFunction?
    @Published var keyBright:BrightInfoFunction?
    @Published var isCharging:ChargingInfoFunction = ChargingInfoFunction()
    @Published var message: [messageInfoFunction] = []
    
    @Published var SettingWindow:NSWindow?
    
    func setSettingWindows() {
        SettingWindow?.close()
        let BangsWindow = NSWindow()
        let hostionViewController = NSHostingController(
            rootView:  SettingView().environmentObject(self)
        )
        BangsWindow.contentView = hostionViewController.view
        BangsWindow.styleMask = [.titled, .closable]
        BangsWindow.level = .screenSaver
        BangsWindow.setFrame(CGRect(x: 0, y: 0, width: 350, height: 550), display: true)
        BangsWindow.center()
        BangsWindow.becomeKey()
        BangsWindow.isReleasedWhenClosed = true
        let notchWindowController = NSWindowController()
        notchWindowController.contentViewController = BangsWindow.contentViewController
        notchWindowController.window = BangsWindow
        
        notchWindowController.showWindow(self)
        SettingWindow = BangsWindow
    }
    
    @Published var showWhite = false
    
    @objc func getMediaisPlay() {
        MRMediaRemoteGetNowPlayingApplicationIsPlaying(.main) { Bool in
            if self.media == nil {
                self.media = mediaInfoFunction(name: "未知作品", Artist: "未知作者", Artist2: "未知专辑", isPlay: false)
            }
            self.media?.isPlay = Bool
        }
    }
    @objc func getMediaInfo() {
        MRMediaRemoteGetNowPlayingInfo(DispatchQueue.main, { [self] (information) in
            if let information = information {
                if self.media == nil {
                    self.media = mediaInfoFunction(name: "未知作品", Artist: "未知作者", Artist2: "未知专辑", isPlay: false)
                }
                let name = (information[kMRMediaRemoteNowPlayingInfoTitle] as? String) ?? "未知作品"
                let ar = (information[kMRMediaRemoteNowPlayingInfoArtist] as? String) ?? "未知作者"
                let ar2 = (information[kMRMediaRemoteNowPlayingInfoAlbum] as? String) ?? "未知专辑"
                if self.media?.name != name || self.media?.Artist != ar || self.media?.Artist2 != ar2 || self.media?.image == nil {
                    if let data = information[kMRMediaRemoteNowPlayingInfoArtworkData] as? Data {
                        self.media?.image = Image(nsImage: NSImage(data: data)!)
                    } else {
                        self.media?.image = nil
                    }
                }
                self.media?.name = name
                self.media?.Artist = ar
                self.media?.Artist2 = ar2
                
                if let allTime = information[kMRMediaRemoteNowPlayingInfoDuration] as? Double {
                    self.media?.fullTime = allTime
                }
                if let nowTime = information[kMRMediaRemoteNowPlayingInfoElapsedTime] as? Double {
                    self.media?.nowTime = nowTime
                }
                setShowMedia()
                getMediaisPlay()
            } else {
                self.media = nil
            }
        })
    }
    @objc func setShowMedia() {
        MRMediaRemoteGetNowPlayingClient(.main) { [self] MRNowPlayingClientProtobuf in
            if self.media == nil {
                self.media = mediaInfoFunction(name: "未知作品", Artist: "未知作者", Artist2: "未知专辑", isPlay: false)
            }
            if let id = MRNowPlayingClientProtobuf?.bundleIdentifier {
                var showImageList:[mediaAppCanShow] = (try? PropertyListDecoder().decode([mediaAppCanShow].self, from: self.showImageListData)) ?? []
                if let ff = showImageList.first(where: { mediaAppCanShow in
                    mediaAppCanShow.id == id
                }) {
                    if ff.canShow {
                        self.media?.fullType = 0
                        setMediaTime()
                    }
                } else {
                    showImageList.append(mediaAppCanShow(id: id, canShow: true))
                    self.media?.fullType = 0
                    setMediaTime()
                }
                self.showImageListData = (try? PropertyListEncoder().encode(showImageList)) ?? Data()
            }
        }
        
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        
        NotificationCenter.default.addObserver(self, selector: #selector(setWindow), name: NSApplication.didChangeScreenParametersNotification, object: nil)
        
        MRMediaRemoteRegisterForNowPlayingNotifications(.main)
        NotificationCenter.default.addObserver(self, selector: #selector(getMediaInfo), name: NSNotification.Name.mrMediaRemoteNowPlayingInfoDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(getMediaInfo), name: NSNotification.Name.mrMediaRemoteNowPlayingApplicationDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(getMediaisPlay), name: NSNotification.Name.mrMediaRemoteNowPlayingApplicationIsPlayingDidChange, object: nil)
        
        getMediaInfo()
        setvolume()
        DispatchQueue.main.async { [self] in
            setWindow()
            app.applicationDidFinishLaunching()
        }
        setBetterTime()
    }
    
    
    func application(_ application: NSApplication, open urls: [URL]) {
        urls.forEach { URL in
            let urlCompoents = URL.absoluteString.urlDecoded().components(separatedBy: "|")
            if urlCompoents.first == "DBangMS:" && urlCompoents.count == 6 {
                let title = urlCompoents[1]
                let title2 = urlCompoents[2]
                let body = urlCompoents[3]
                let color:Color = {
                    switch urlCompoents[4] {
                    case "1": return Color.white
                    case "2": return Color.red
                    case "3": return Color.orange
                    case "4": return Color.yellow
                    case "5": return Color.green
                    case "6": return Color.mint
                    case "7": return Color.blue
                    case "8": return Color.purple
                    default: return Color.white
                    }
                }()
                let image:Image? = {
                    let st = urlCompoents[5]
                    if st != "" {
                        if let data = Data(base64Encoded: urlCompoents[5]), let image = NSImage(data: data) {
                            return Image(nsImage: image)
                        }
                    }
                    return nil
                }()
                message.append(messageInfoFunction(title: title, color: color, image: image, title2: title2, body: body))
            } else {
                message.append(messageInfoFunction(title: "未知消息"))
            }
        }
        setMessageTime()
    }
    
    deinit {
        MRMediaRemoteUnregisterForNowPlayingNotifications()
    }
    
    var mediaKeyTap: MediaKeyTap?
    @AppStorage("showMedia") var mediashow = true
    @AppStorage("palyID") var playID: Int = 1
    
    func handle(mediaKey: MediaKey, event: KeyEvent?, modifiers: NSEvent.ModifierFlags?) {
        switch mediaKey {
        case .brightnessUp:
            self.bright = BrightInfoFunction(value: max(min((self.bright?.value ?? 1) + 0.0625, 1), 0))
            DisplayManager.shared.getAllDisplays().forEach { Display in
                _ = Display.setBrightness((self.bright?.value ?? 1))
            }
        case .brightnessDown:
            self.bright = BrightInfoFunction(value: max(min((self.bright?.value ?? 1) - 0.0625, 1), 0))
            DisplayManager.shared.getAllDisplays().forEach { Display in
                _ = Display.setBrightness((self.bright?.value ?? 1))
            }
        case .volumeUp:
            try? Sound.output.mute(false)
            try? Sound.output.setVolume(min(max(Sound.output.volume + 0.0625, 0), 1))
            self.volume = volumeInfoFunction(value: Sound.output.volume)
            AudioServicesPlaySystemSound(SystemSoundID(playID))
        case .volumeDown:
            try? Sound.output.mute(false)
            try? Sound.output.setVolume(min(max(Sound.output.volume - 0.0625, 0), 1))
            self.volume = volumeInfoFunction(value: Sound.output.volume)
            AudioServicesPlaySystemSound(SystemSoundID(playID))
        case .mute:
            try? Sound.output.mute(!Sound.output.isMuted)
            self.volume = volumeInfoFunction(value: Sound.output.isMuted ? 0 : Sound.output.volume)
            AudioServicesPlaySystemSound(SystemSoundID(playID))
        case .backlightUP:
            self.keyBright = BrightInfoFunction(value: min((self.keyBright?.value ?? 1) + 0.0625, 1))
        case .backlightDown:
            self.keyBright = BrightInfoFunction(value: max((self.keyBright?.value ?? 1) - 0.0625, 0))
        default:
            break
        }
        setFloatTime()
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
                    isCharging.beter = capacity
                    if isConnect {
                        if (IsCharging == 1) != isCharging.isCharging  || isConnect != isCharging.isConnect {
                            isCharging = ChargingInfoFunction(isCharging: IsCharging == 1, isConnect: isConnect, beter: capacity, fullType: 0)
                        }
                    } else {
                        if isCharging.isConnect {
                            isCharging = ChargingInfoFunction(isCharging: IsCharging == 1, isConnect: isConnect, beter: capacity, fullType: 0)
                        }
                    }
                }
            }
        } catch { }
    }
    
    func setvolume() {
        mediaKeyTap?.stop()
        if mediashow {
            mediaKeyTap = MediaKeyTap(delegate: self, for: [.volumeUp, .volumeDown, .mute, .brightnessUp, .brightnessDown], observeBuiltIn: true)//.brightnessUp, .brightnessDown, .backlightDown, .backlightUP])
            mediaKeyTap?.start()
        }
    }
    @AppStorage("showImageList") var showImageListData:Data = Data()
    
    var time:Timer?
    var time2:Timer?
    var time3:Timer?
    
    func setFloatTime() {
        if time == nil {
            time = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [self] Timer in
                if self.volume?.fullType ?? 10 < 10 {
                    self.volume?.fullType += 1
                } else {
                    self.volume = nil
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
                if self.keyBright == nil && self.bright == nil && self.volume == nil {
                    Timer.invalidate()
                    time = nil
                }
            }
        }
    }
    
    func setMediaTime() {
        if time2 == nil {
            time2 = Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { [self] Timer in
                if self.media?.fullType ?? 10 < 10 {
                    self.media?.fullType += 3
                } else {
                    Timer.invalidate()
                    time2 = nil
                }
            }
        }
    }
    func setMessageTime() {
        if time3 == nil {
            time3 = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [self] Timer in
                var cantonil = true
                for (index, _) in self.message.enumerated() {
                    self.message[index].fullType += 1
                }
                for i in self.message {
                    if i.fullType > 10 {
                        if let int = self.message.firstIndex(where: { messageInfoFunction in
                            messageInfoFunction.id == i.id
                        }) {
                            self.message.remove(at: int)
                        }
                    } else {
                        cantonil = false
                    }
                }
                if cantonil {
                    Timer.invalidate()
                    time3 = nil
                }
            }
        }
    }
    
    func setBetterTime() {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [self] Timer in
            if self.isCharging.fullType < 15 {
                self.isCharging.fullType += 1
            }
            setBeter()
        }
    }
    @Published var showDisplays:[Int] = [(NSScreen.main?.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? Int) ?? 1]
    
    @AppStorage("firstShow") var firstShow = true
    
    @objc func setWindow() {
        if firstShow {
            NSApplication.shared.windows.forEach { NSWindow in
                NSWindow.close()
            }
            if windows.isEmpty {
                guard let i = NSScreen.main else { return }
                let hostionViewController = NSHostingController(rootView: FirstShowView().environmentObject(self))
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
        } else {
            windows.forEach { NSWindow in
                NSWindow.close()
            }
            windows.removeAll()
            for i in NSScreen.screens {
                if let id = i.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? Int {
                    if showDisplays.contains(id) {
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
                        BangsWindow.canBecomeVisibleWithoutLogin = true
                        BangsWindow.isExcludedFromWindowsMenu = true
                        
                        
                        let notchWindowController = NSWindowController()
                        notchWindowController.contentViewController = BangsWindow.contentViewController
                        
                        notchWindowController.window = BangsWindow
                        notchWindowController.showWindow(self)
                        windows.append(BangsWindow)
                    }
                }
            }
        }
    }
}

class NotchWindow: NSWindow {
    var targetScreen: NSScreen!
    
    override func constrainFrameRect(_ frameRect: NSRect, to screen: NSScreen?) -> NSRect {
        return super.constrainFrameRect(frameRect, to: targetScreen)
    }
}


//@main
//struct DynamicBangsApp: App {
//    @StateObject var appObserver = AppObserver()
//    
//    var body: some Scene {
//        Settings {
//            EmptyView()
//        }
//    }
//}

func avg(_ values: [Float]) -> Float {
    var count:Float = 0
    values.forEach { Float in
        count += Float
    }
    return count / Float(values.count)
}
