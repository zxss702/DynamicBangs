//
//  islandContentView.swift
//  DynamicBangs
//
//  Created by 张旭晟 on 2024/2/16.
//

import SwiftUI
import PrivateMediaRemote

struct islandContentView: View {
    @EnvironmentObject var appObserver:AppObserver
    @AppStorage("BangsWidth") var BangsWidth:Double = 204
    @AppStorage("BangsHeight") var BangsHeight:Double = 32
    
    @State var addHeight: CGFloat = 0
    
    @State var isHover: Bool = false
    @State var isTap: Bool = false
    @State var isLongTap: Bool = false
    @State var ShowSetting: Bool = false
    
    @AppStorage("showCard") var showCard = true
    @AppStorage("defautBangs") var defautBangs = true
    @AppStorage("noLiveToHide") var noLiveToHide = false
    
    
    var body: some View {
        VStack(alignment: .center, spacing: 1) {
            if addHeight == 0 {
                if ShowSetting {
                    HStack(spacing: 8) {
                        Text("继续长按")
                            .foregroundStyle(.white)
                            .transition(.blur.combined(with: .scale))
                            .padding(.leading, 5)
                        Spacer()
                            .frame(width: 100)
                        Image(systemName: "gear")
                            .resizable()
                            .scaledToFit()
                            .frame(width: BangsHeight - 10, height: BangsHeight - 10)
                            .padding(.trailing, 5)
                            .foregroundStyle(.white)
                            .transition(.blur.combined(with: .scale))
                    }
                    .frame(height: BangsHeight)
                } else {
                    HStack(spacing: 8) {
                        mediaInfoImage(media: appObserver.media, isHover: $isHover)
                            .padding(.trailing, 3)
                            .frame(height: BangsHeight)
                        BetterInfoView(isCharging: appObserver.isCharging)
                            .padding(.leading, 3)
                            .frame(height: BangsHeight)
                    }
                }
            } else {
                Spacer()
                    .frame(height: 10)
            }
            VStack(spacing: 8) {
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
        .clipShape(RoundedRectangle(cornerRadius: BangsHeight / 2))
        .background {
            RoundedRectangle(cornerRadius: BangsHeight / 2)
                .foregroundStyle(.black)
                .shadow(radius: (addHeight != 0 || isHover) ? 15 : 0)
        }
        .frame(minWidth: BangsWidth)
        
        .scaleEffect(x: isHover ? 1.1 : 1, y: isHover ? 1.1 : 1, anchor: .top)
        .scaleEffect(x: ShowSetting ? 1.1 : 1, y: ShowSetting ? 1.1 : 1, anchor: .top)
        
        .padding(.top, 5)
        .scaleEffect(x: noLiveToHide ? ((addHeight != 0 || isHover) ? 1 : 0) : 1, y: noLiveToHide ? ((addHeight != 0 || isHover) ? 1 : 0) : 1, anchor: .top)
        
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
        .animation(.spring(), value: addHeight)
        .animation(.spring(), value: showCard)
        .animation(.spring(), value: defautBangs)
        .animation(.spring(), value: noLiveToHide)
        .animation(.spring(), value: isLongTap)
        .animation(.spring(), value: ShowSetting)
        
        .buttonStyle(TapButtonStyle())
    }
}
