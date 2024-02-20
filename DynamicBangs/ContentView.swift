//
//  ContentView.swift
//  DynamicBangs
//
//  Created by 张旭晟 on 2024/2/12.
//

import SwiftUI
import PrivateMediaRemote


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
    
    var body: some View {
        VStack(spacing: 1) {
            HStack(spacing: 1) {
                if addHeight == 0 {
                    ZStack(alignment: .leading) {
                        Color.clear
                            .frame(width: widthRight)
                        HStack(spacing: 8) {
                            if ShowSetting {
                                Text("继续长按")
                                    .foregroundStyle(.white)
                                    .transition(.blur.combined(with: .scale))
                                    .padding(.leading, 5)
                            } else {
                                mediaInfoImage(media: appObserver.media, isHover: $isHover)
                            }
                        }
                        .onSizeChange { CGSize in
                            widthLeft = CGSize.width
                        }
                    }
                }
                
                Color.clear
                    .frame(width: BangsWidth - 20)
                
                if addHeight == 0 {
                    ZStack(alignment: .trailing) {
                        Color.clear
                            .frame(width: widthLeft)
                        HStack(spacing: 8) {
                            if ShowSetting {
                                Image(systemName: "gear")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: BangsHeight - 10, height: BangsHeight - 10)
                                    .padding(.trailing, 5)
                                    .foregroundStyle(.white)
                                    .transition(.blur.combined(with: .scale))
                            } else {
                                BetterInfoView(isCharging: appObserver.isCharging)
                            }
                        }
                        .onSizeChange { CGSize in
                            widthRight = CGSize.width
                        }
                    }
                }
            }
            .frame(height: defautBangs ? BangsHeight : (addHeight == 0 ? BangsHeight : 10))
            
            VStack(spacing: 0) {
                if !ShowSetting {
                    mediaView(media: appObserver.media, isTap: $isTap)
                    InfoFunctionFloatSetView(sysImage: (appObserver.volume?.value ?? 0.0) == 0 ? "speaker.slash.fill" : "speaker.wave.3", floatFunction: $appObserver.volume)
                    InfoFunctionFloatSetView(sysImage: "sun.max.fill", floatFunction: $appObserver.bright)
                    InfoFunctionFloatSetView(sysImage: "light.max", floatFunction: $appObserver.keyBright)
                }
            }
            .onSizeChange { CGSize in
                addHeight = CGSize.height
            }
        }
        .clipShape(BangsShape())
        
        .padding([.leading, .trailing], 10)
        .background {
            BangsShapeView()
                .foregroundStyle(.black)
                .compositingGroup()
                .shadow(radius: (addHeight != 0 || widthLeft != 0 || widthRight != 0 || isHover) ? 15 : 0)
        }
        .scaleEffect(x: isHover ? 1.1 : 1, y: isHover ? 1.1 : 1, anchor: .top)
        .scaleEffect(x: ShowSetting ? 1.1 : 1, y: ShowSetting ? 1.1 : 1, anchor: .top)
        .scaleEffect(x: noLiveToHide ? ((addHeight != 0 || widthLeft != 0 || widthRight != 0 || isHover) ? 1 : 0) : 1, y: noLiveToHide ? ((addHeight != 0 || widthLeft != 0 || widthRight != 0 || isHover) ? 1 : 0) : 1, anchor: .top)
        .background {
            Color.accentColor.opacity(0.01)
        }
        .onHover { Bool in
            isHover = Bool
            if !Bool {
                isTap = false
            }
        }
        .onTapGesture {
            isTap = true
        }
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
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        
        .animation(.spring(), value: BangsWidth)
        .animation(.spring(), value: BangsHeight)
        .animation(.spring(), value: appObserver.media)
        .animation(.spring(), value: appObserver.volume)
        .animation(.spring(), value: appObserver.bright)
        .animation(.spring(), value: appObserver.keyBright)
        .animation(.spring(), value: appObserver.isCharging)
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
        
        .buttonStyle(TapButtonStyle())
    }
}
