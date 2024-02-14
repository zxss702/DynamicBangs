//
//  SettingView.swift
//  DynamicBangs
//
//  Created by 张旭晟 on 2024/2/12.
//

import SwiftUI

struct SettingView: View {
    @EnvironmentObject var appObserver:AppObserver
    @AppStorage("BangsWidth") var BangsWidth:Double = 145
    @AppStorage("BangsHeight") var BangsHeight:Double = 32
    
    @AppStorage("showDevelpoBangs") var showDevelpoBangs = false
    @AppStorage("defautBangs") var defautBangs = true
    
    @AppStorage("islandModle") var islandModle = false
    
    @AppStorage("bigFillWidth") var bigFillWidth:Double = 5
    @AppStorage("fontSecler") var fontSecler:Double = 1
    
    var body: some View {
        PopoverRootStyle {
            Group {
                menuButton(titleName: "刘海宽度", showDivider: false) {
                    Button("恢复默认"){
                        BangsWidth = 145
                    }
                    .font(.caption)
                    .foregroundColor(Color(NSColor.systemBlue))
                } MainTitle2: {
                    Text(String(Int(BangsWidth)))
                        .font(.caption)
                        .bold()
                        .foregroundColor(.gray)
                } content: {
                    Slider(value: $BangsWidth, in: 100...300)
                        .animation(.spring(), value: BangsWidth)
                }
                menuButton(titleName: "刘海高度", showDivider: false) {
                    Button("恢复默认"){
                        BangsHeight = 32
                    }
                    .font(.caption)
                    .foregroundColor(Color(NSColor.systemBlue))
                } MainTitle2: {
                    Text(String(Int(BangsHeight)))
                        .font(.caption)
                        .bold()
                        .foregroundColor(.gray)
                } content: {
                    Slider(value: $BangsHeight, in: 21...100)
                        .animation(.spring(), value: BangsHeight)
                }
                menuButton(titleName: "刘海标准字体", showDivider: false) {
                    Button("恢复默认"){
                        fontSecler = 1
                    }
                    .font(.caption)
                    .foregroundColor(Color(NSColor.systemBlue))
                } MainTitle2: {
                    Text(String(Int(fontSecler * 100)))
                        .font(.caption)
                        .bold()
                        .foregroundColor(.gray)
                } content: {
                    Slider(value: $fontSecler, in: 0.1...3)
                        .animation(.spring(), value: fontSecler)
                }
            }
            menuButton(titleName: "刘海扩大感知距离", showDivider: false) {
                Button("恢复默认"){
                    bigFillWidth = 5
                }
                .font(.caption)
                .foregroundColor(Color(NSColor.systemBlue))
            } MainTitle2: {
                Text(String(Int(bigFillWidth)))
                    .font(.caption)
                    .bold()
                    .foregroundColor(.gray)
            } content: {
                Slider(value: $bigFillWidth, in: 5...30)
                    .animation(.spring(), value: bigFillWidth)
            }
            
            #if DEBUG
            menuButton(titleName: "显示Bar", showDivider: true) {
                Spacer()
            } MainTitle2: {
                Spacer()
            } content: {
                Toggle(isOn: $showDevelpoBangs) {
                    
                }
                .labelsHidden()
            }
            #endif
            
            menuButton(titleName: "灵动岛模式", showDivider: true) {
                Spacer()
            } MainTitle2: {
                Spacer()
            } content: {
                Toggle(isOn: $islandModle) {
                    
                }
                .labelsHidden()
            }
            menuButton(titleName: "显示器是否具有刘海", showDivider: true) {
                Spacer()
            } MainTitle2: {
                Spacer()
            } content: {
                Toggle(isOn: $defautBangs) {
                    
                }
                .labelsHidden()
            }
        }
        .frame(minWidth: 450, minHeight: 300)
    }
}

#Preview {
    SettingView()
}
