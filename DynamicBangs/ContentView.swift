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
    
    @AppStorage("showCard") var showCard = true
    @AppStorage("defautBangs") var defautBangs = true
    
    var body: some View {
        VStack(spacing: 1) {
            HStack(spacing: 1) {
                if addHeight == 0 {
                    ZStack(alignment: .leading) {
                        Color.clear
                            .frame(width: widthRight)
                        HStack(spacing: 8) {
                            mediaInfoImage(media: appObserver.media, isHover: $isHover)
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
                            BetterInfoView(isCharging: appObserver.isCharging)
                        }
                        .onSizeChange { CGSize in
                            widthRight = CGSize.width
                        }
                    }
                }
            }
            .frame(height: defautBangs ? BangsHeight : (addHeight == 0 ? BangsHeight : 10))
            
            VStack(spacing: 0) {
                mediaView(media: appObserver.media, isTap: $isTap)
                InfoFunctionFloatSetView(sysImage: (appObserver.volume?.value ?? 0.0) == 0 ? "speaker.slash.fill" : "speaker.wave.3", floatFunction: $appObserver.volume)
                InfoFunctionFloatSetView(sysImage: "sun.max.fill", floatFunction: $appObserver.bright)
                InfoFunctionFloatSetView(sysImage: "light.max", floatFunction: $appObserver.keyBright)
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
        
        .onHover { Bool in
            isHover = Bool
            if !Bool {
                isTap = false
            }
        }
        .onTapGesture {
            isTap = true
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
        
        .buttonStyle(TapButtonStyle())
    }
}
