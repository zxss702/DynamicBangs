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
    var fullType:Int = 0
    var fullTime: Double = 0.1
    var nowTime: Double = 0
}

protocol InfoFunctionFloat: Equatable {
    var value: Float { get set }
    var fullType: Int { get set }
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

struct settingHelperView: View {
    
    @State var show = false
    let settingWindow:NSWindow?
    
    @State var offset: CGPoint = .zero
    @State var offset2: CGPoint = .zero
    
    var body: some View {
        RoundedRectangle(cornerRadius: 17)
            .foregroundStyle(.ultraThinMaterial)
            .frame(maxWidth: 350, maxHeight: 550)
            .overlay {
                SettingView(show: $show, settingWindow: settingWindow)
            }
            .clipShape(RoundedRectangle(cornerRadius: 17))
            .padding(.all)
            .shadow(radius: 0.6)
            .shadow(radius: 34)
            .offset(x: show ? offset.x : -400, y: show ? offset.y : 0)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        offset.x = offset2.x + value.translation.width
                        offset.y = offset2.y + value.translation.height
                    }
                    .onEnded { value in
                        offset2 = offset
                    }
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    withAnimation(.spring()) {
                        show = true
                    }
                }
            }
    }
}

struct mediaAppCanShow: Codable, Identifiable {
    var id: String
    var canShow: Bool = true
}

class AppObserver: NSObject, ObservableObject, MediaKeyTapDelegate {
    var windows:[NSWindow] = []
    
    @Published var media:mediaInfoFunction?
    @Published var volume:volumeInfoFunction?
    @Published var bright:BrightInfoFunction?
    @Published var keyBright:BrightInfoFunction?
    @Published var isCharging:ChargingInfoFunction = ChargingInfoFunction()
    @Published var isSettingOpen = false
    
    func setSettingWindows() {
        if !isSettingOpen {
            isSettingOpen = true
            guard let i = NSScreen.main else { return }
            let BangsWindow = NSPanel()
            let hostionViewController = NSHostingController(
                rootView: settingHelperView(settingWindow: BangsWindow).environmentObject(self)
            )
//            BangsWindow.targetScreen = i
            BangsWindow.contentViewController = hostionViewController
            BangsWindow.styleMask = [.borderless]
            BangsWindow.backingType = .buffered
            BangsWindow.backgroundColor = .clear
            BangsWindow.hasShadow = false
            BangsWindow.level = .screenSaver
            BangsWindow.collectionBehavior =  [.canJoinAllSpaces, .stationary, .fullScreenAuxiliary]
            BangsWindow.setFrame(i.frame, display: true)
            BangsWindow.becomeKey()
            let notchWindowController = NSWindowController()
            notchWindowController.contentViewController = BangsWindow.contentViewController
            
            notchWindowController.window = BangsWindow
            
            notchWindowController.showWindow(self)
        }
    }
    
    @Published var showWhite = false
    override init() {
        volume = volumeInfoFunction(value: Sound.output.volume, fullType: 10)
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
            app.applicationDidFinishLaunching()
        }
        setTime()
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
            try? Sound.output.setVolume(min(max(Sound.output.volume + 0.0625, 0), 1))
            self.volume = volumeInfoFunction(value: Sound.output.volume)
            AudioServicesPlaySystemSound(SystemSoundID(playID))
        case .volumeDown:
            try? Sound.output.setVolume(min(max(Sound.output.volume - 0.0625, 0), 1))
            self.volume = volumeInfoFunction(value: Sound.output.volume)
            AudioServicesPlaySystemSound(SystemSoundID(playID))
        case .mute:
            try? Sound.output.mute(!Sound.output.isMuted)
            self.volume = volumeInfoFunction(value: Sound.output.isMuted ? 0 : Sound.output.volume)
        case .backlightUP:
            self.keyBright = BrightInfoFunction(value: min((self.keyBright?.value ?? 1) + 0.0625, 1))
        case .backlightDown:
            self.keyBright = BrightInfoFunction(value: max((self.keyBright?.value ?? 1) - 0.0625, 0))
        default:
            break
        }
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
                    self.media?.fullType = 10
                    MRMediaRemoteGetNowPlayingClient(.main) { MRNowPlayingClientProtobuf in
                        if let id = MRNowPlayingClientProtobuf?.bundleIdentifier {
                            var showImageList:[mediaAppCanShow] = (try? PropertyListDecoder().decode([mediaAppCanShow].self, from: self.showImageListData)) ?? []
                            if let ff = showImageList.first(where: { mediaAppCanShow in
                                mediaAppCanShow.id == id
                            }) {
                                if ff.canShow {
                                    self.media?.fullType = 0
                                }
                            } else {
                                showImageList.append(mediaAppCanShow(id: id, canShow: true))
                                self.media?.fullType = 0
                            }
                            self.showImageListData = (try? PropertyListEncoder().encode(showImageList)) ?? Data()
                            print(showImageList)
                        }
                    }
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
                
                if
                    let allTime = information[kMRMediaRemoteNowPlayingInfoDuration] as? Double,
                    let nowTime = information[kMRMediaRemoteNowPlayingInfoElapsedTime] as? Double
                {
                    self.media?.fullTime = allTime
                    self.media?.nowTime = nowTime
                }
                
                MRMediaRemoteGetNowPlayingApplicationIsPlaying(.main) { Bool in
                    self.media?.isPlay = Bool
                }
            } else {
                self.media = nil
            }
        })
    }
    
    func setTime() {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [self] Timer in
            
            if self.media != nil {
                self.media?.fullType += 1
                MRMediaRemoteGetNowPlayingInfo(DispatchQueue.main, { (information) in
                    if let information = information {
                        if
                            let allTime = information[kMRMediaRemoteNowPlayingInfoDuration] as? Double,
                            let nowTime = information[kMRMediaRemoteNowPlayingInfoElapsedTime] as? Double
                        {
                            self.media?.fullTime = allTime
                            self.media?.nowTime = nowTime
                        }
                    }
                })
            }
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


@main
struct DynamicBangsApp: App {
    @StateObject var appObserver = AppObserver()
    
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

func avg(_ values: [Float]) -> Float {
    var count:Float = 0
    values.forEach { Float in
        count += Float
    }
    return count / Float(values.count)
}
