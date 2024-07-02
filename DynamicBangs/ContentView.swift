//
//  ContentView.swift
//  DynamicBangs
//
//  Created by 张旭晟 on 2024/2/12.
//

import SwiftUI
import PrivateMediaRemote
import UniformTypeIdentifiers
import QuickLookThumbnailing

struct ContentView: View {
    @EnvironmentObject var appObserver:AppObserver
    @AppStorage("BangsWidth") var BangsWidth:Double = 204
    @AppStorage("BangsHeight") var BangsHeight:Double = 32
    
    @State var widthRight: CGFloat = 0
    @State var widthLeft: CGFloat = 0
    @State var addHeight: CGFloat = 0
    
    @State var isHover: Bool = false
    @State var isTap: Bool = false
    @State var isLongTap: Bool = false
    @State var ShowSetting: Bool = false
    
    @AppStorage("showCard") var showCard = true
    @AppStorage("defautBangs") var defautBangs = true
    @AppStorage("noLiveToHide") var noLiveToHide = false
    @AppStorage("islandModle") var islandModle = false
    
    @AppStorage("openNearBy") var openNearBy = false
    
    @Namespace var nameSpace
    
    @State var showSetting: Bool = false
    
    @State var onHover:Bool = false
    
    @State var isDrop = false
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                if addHeight == 0 {
                    HStack(spacing: 8) {
                        if ShowSetting {
                            Text("继续长按")
                                .foregroundStyle(.white)
                                .transition(.blur.combined(with: .scale))
                        } else if isDrop {
                            Image(systemName: "document.badge.plus.fill")
                                .foregroundStyle(.blue)
                                .frame(width: BangsHeight - 6, height: BangsHeight - 6)
                                .transition(.blur)
                        } else {
                            mediaInfoImage(media: appObserver.media, isHover: $isHover, nameSpace: nameSpace)
                            BetterInfoView2(isCharging: appObserver.isCharging)
                        }
                    }
                    .onSizeChange { CGSize in
                        widthLeft = CGSize.width
                    }
                    .frame(minWidth: widthRight, alignment: .leading)
                    .padding(.leading, 5)
                }
                
                Color.clear
                    .frame(width: BangsWidth - 20)
                
                if addHeight == 0 {
                    HStack(spacing: 8) {
                        if ShowSetting {
                            Image(systemName: "gear")
                                .resizable()
                                .scaledToFit()
                                .frame(width: BangsHeight - 10, height: BangsHeight - 10)
                                .foregroundStyle(.white)
                                .transition(.blur.combined(with: .scale))
                        } else if isDrop {
                            Text("松手中转")
                                .foregroundStyle(.white)
                                .transition(.blur.combined(with: .scale))
                        } else {
                            if !appObserver.saveURL.isEmpty {
                                Image(systemName: "document.on.clipboard.fill")
                                    .foregroundStyle(.blue)
                                    .frame(width: BangsHeight - 6, height: BangsHeight - 6)
                                    .transition(.blur)
                            }
                            BetterInfoView(isCharging: appObserver.isCharging)
                        }
                    }
                    .onSizeChange { CGSize in
                        widthRight = CGSize.width
                    }
                    .frame(minWidth: widthLeft, alignment: .trailing)
                    .padding(.trailing, 5)
                }
            }
            .frame(height: defautBangs ? (addHeight == 0 ? BangsHeight : islandModle ? 10 : BangsHeight) : (addHeight == 0 ? BangsHeight : 10))
            
            VStack(alignment: .leading, spacing: 0) {
                if !ShowSetting {
                    ForEach(appObserver.message.count <= 2 ? appObserver.message : Array(appObserver.message[(appObserver.message.count - 2)...])) { ms in
                        messageView(message: ms)
                    }
                    mediaView(media: $appObserver.media, isTap: $isTap, nameSpace: nameSpace)
                    InfoFunctionFloatSetView(sysImage: (appObserver.volume?.value ?? 0.0) == 0 ? "speaker.slash.fill" : "speaker.wave.3", floatFunction: $appObserver.volume)
                    InfoFunctionFloatSetView(sysImage: "sun.max.fill", floatFunction: $appObserver.bright)
                    InfoFunctionFloatSetView(sysImage: "light.max", floatFunction: $appObserver.keyBright)
                    filesCopyView(isTap: $isTap)
                }
            }
            .onSizeChange { CGSize in
                addHeight = CGSize.height
            }
        }
        .padding(.horizontal, islandModle ? 4 : 10)
        .padding(.vertical, islandModle ? 4 : 0)
        .clipped()
        .frame(minWidth: BangsWidth, minHeight: BangsHeight, alignment: .leading)
        
        .background {
            if islandModle {
                RoundedRectangle(cornerRadius: min(BangsHeight, BangsWidth) / 2 + 4, style: .continuous)
                    .foregroundStyle(.black)
                    .compositingGroup()
                    .shadow(radius: (addHeight != 0 || widthLeft != 0 || widthRight != 0 || isHover) ? 15 : 0)
            } else {
                BangsShapeView()
                    .foregroundStyle(.black)
                    .compositingGroup()
                    .shadow(radius: (addHeight != 0 || widthLeft != 0 || widthRight != 0 || isHover) ? 15 : 0)
            }
        }
        .provided(islandModle, { AnyView in
            AnyView
                .scaleEffect(x: isHover || isDrop ? 1.1 : 1, y: isHover || isDrop ? 1.1 : 1)
                .scaleEffect(x: ShowSetting ? 1.1 : 1, y: ShowSetting ? 1.1 : 1)
                .offset(y: noLiveToHide ? ((addHeight != 0 || widthLeft != 0 || widthRight != 0 || isHover || isDrop) ? 0 : -200) : 0)
                .padding(.top, defautBangs ? BangsHeight + 10 : nil)
        }, else: { AnyView in
            AnyView
                .scaleEffect(x: isHover || isDrop ? 1.1 : 1, y: isHover || isDrop ? 1.1 : 1, anchor: .top)
                .scaleEffect(x: ShowSetting ? 1.1 : 1, y: ShowSetting ? 1.1 : 1, anchor: .top)
                .scaleEffect(x: noLiveToHide ? ((addHeight != 0 || widthLeft != 0 || widthRight != 0 || isHover || isDrop) ? 1 : 0) : 1, y: noLiveToHide ? ((addHeight != 0 || widthLeft != 0 || widthRight != 0 || isHover || isDrop) ? 1 : 0) : 1, anchor: .top)
        })
        
        .background(Color.black.opacity(0.001))
        .provided(openNearBy, { AnyView in
            AnyView
                .overlay(alignment: .top) {
                    Color.black.opacity(0.001)
                        .frame(width: BangsWidth, height: BangsHeight)
                        .onLongPressGesture(minimumDuration: 1, maximumDistance: .infinity) {
                            appObserver.setSettingWindows()
                        } onPressingChanged: { Bool in
                            ShowSetting = false
                            isLongTap = Bool
                            if Bool {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                    ShowSetting = isLongTap
                                }
                            }
                        }
                }
                .onHover { Bool in
                    isHover = Bool
                    if !Bool {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            isTap = Bool
                        }
                    } else {
                        isTap = Bool
                    }
                }
        }, else: { AnyView in
            AnyView
                .onHover { Bool in
                    isHover = Bool
                    if !Bool {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            isTap = Bool
                        }
                    }
                }
                .onTapGesture {
                    isTap = true
                }
                .onLongPressGesture(minimumDuration: 1, maximumDistance: .infinity) {
                    if addHeight == 0 {
                        appObserver.setSettingWindows()
                    }
                } onPressingChanged: { Bool in
                    if addHeight == 0 {
                        ShowSetting = false
                        isLongTap = Bool
                        if Bool {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                ShowSetting = isLongTap
                            }
                        }
                    }
                }
        })
       
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .onDrop(of: [UTType.fileURL], isTargeted: $isDrop, perform: { provids in
            provids.forEach { Element in
                _ = Element.loadObject(ofClass: URL.self) { url, error in
                    if let url = url {
                        DispatchQueue.main.async {
                            appObserver.saveURL[url] = filesCopyHelper(name: url.lastPathComponent)
                            let request = QLThumbnailGenerator.Request(fileAt: url, size: CGSize(width: 150, height: 150), scale: 2, representationTypes: .all)
                            QLThumbnailGenerator.shared.generateRepresentations(for: request) { QLThumbnailRepresentation, type, error in
                                if let image = QLThumbnailRepresentation?.nsImage {
                                    DispatchQueue.main.async {
                                        appObserver.saveURL[url]?.image = Image(nsImage: image)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            print("sdc")
            return true
        })
        
        .animation(.spring(), value: BangsWidth)
        .animation(.spring(), value: BangsHeight)
        .animation(.spring(), value: appObserver.media)
        .animation(.spring(), value: appObserver.volume)
        .animation(.spring(), value: appObserver.bright)
        .animation(.spring(), value: appObserver.keyBright)
        .animation(.spring(), value: appObserver.isCharging)
        .animation(.spring(), value: appObserver.message)
        .animation(.spring(), value: isHover)
        .animation(.spring(), value: isTap)
        .animation(.spring(), value: widthRight)
        .animation(.spring(), value: widthLeft)
        .animation(.spring(), value: addHeight)
        .animation(.spring(), value: showCard)
        .animation(.spring(), value: defautBangs)
        .animation(.spring(), value: noLiveToHide)
        .animation(.spring(), value: isLongTap)
        .animation(.spring(), value: ShowSetting)
        .animation(.spring(), value: isDrop)
        .animation(.spring(), value: appObserver.saveURL)
        
        .buttonStyle(TapButtonStyle())
    }
}
