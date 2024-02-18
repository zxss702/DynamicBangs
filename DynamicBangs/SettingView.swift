//
//  SettingView.swift
//  DynamicBangs
//
//  Created by 张旭晟 on 2024/2/12.
//

import SwiftUI
import AVFoundation

let list:[Int:String] = {
    var newL:[Int:String] = [:]
    newL[0] = "关闭"
    guard let systemSoundFiles = getSystemSoundFileEnumerator() else { return newL }
    for item in systemSoundFiles {
        guard let url = item as? URL, let name = url.deletingPathExtension().pathComponents.last else { continue }
        var soundId: SystemSoundID = 0
        AudioServicesCreateSystemSoundID(url as CFURL, &soundId)
        newL[Int(soundId as UInt32)] = name
    }
    return newL
}()

struct SettingView: View {
    @EnvironmentObject var appObserver:AppObserver
    @AppStorage("BangsWidth") var BangsWidth:Double = 204
    @AppStorage("BangsHeight") var BangsHeight:Double = 32
    
   
    @AppStorage("defautBangs") var defautBangs = true
    
    @AppStorage("islandModle") var islandModle = false
    @AppStorage("fontSecler") var fontSecler:Double = 1
    
    @AppStorage("showCard") var showCard = true
    
    @AppStorage("palyID") var playID: Int = 1
    
    @AppStorage("musicLogo") var musicLogo = "music.note"
    @AppStorage("noLiveToHide") var noLiveToHide = false
    
    var body: some View {
        PopoverRootStyle {
            Group {
                Text("长按刘海，呼出设置窗口。")
                Text("确保刘海外有黑色边缘，白色被刘海覆盖。")
                menuButton(titleName: "刘海宽度", showDivider: false) {
                    Button("恢复默认"){
                        BangsWidth = 204
                    }
                    .font(.caption)
                    .foregroundColor(Color(NSColor.systemBlue))
                } MainTitle2: {
                    Text(String(Int(BangsWidth)))
                        .font(.caption)
                        .bold()
                        .foregroundColor(.gray)
                } content: {
                    Slider(value: $BangsWidth, in: 100...300) { Bool in
                        withAnimation(.spring()) {
                            appObserver.showWhite = Bool
                        }
                    }
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
                    Slider(value: $BangsHeight, in: 21...100) { Bool in
                        withAnimation(.spring()) {
                            appObserver.showWhite = Bool
                        }
                    }
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
            
            Group {
                menuButton(titleName: "显示灵动的屏幕", showDivider: true) {
                    Spacer()
                } MainTitle2: {
                    Spacer()
                } content: {
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(NSScreen.screens, id: \.displayInt) { sc in
                                Button {
                                    if let int = appObserver.showDisplays.firstIndex(of: sc.displayInt) {
                                        appObserver.showDisplays.remove(at: int)
                                    } else {
                                        appObserver.showDisplays.append(sc.displayInt)
                                    }
                                    appObserver.setWindow()
                                } label: {
                                    Image(systemName: "display")
                                        .overlay {
                                            Text(String( sc.displayInt))
                                        }
                                        .foregroundStyle(appObserver.showDisplays.contains(sc.displayInt) ? .black : .gray)
                                }
                            }
                        }
                        .padding(.all)
                    }
                }
            }
            
            menuButton(titleName: "灵动岛模式", showDivider: true) {
                Spacer()
            } MainTitle2: {
                Spacer()
            } content: {
                Toggle(isOn: $islandModle) {
                    
                }
                .labelsHidden()
            }
            Group {
                menuButton(titleName: "活动时不显大卡片", showDivider: true) {
                    Spacer()
                } MainTitle2: {
                    Spacer()
                } content: {
                    Toggle(isOn: $showCard) {
                        
                    }
                    .labelsHidden()
                }
                menuButton(titleName: "无活动时不显示", showDivider: true) {
                    Spacer()
                } MainTitle2: {
                    Spacer()
                } content: {
                    Toggle(isOn: $noLiveToHide) {
                        
                    }
                    .labelsHidden()
                }
            }
            Group {
                menuButton(titleName: "小音乐图:sfImage", showDivider: true) {
                    Spacer()
                } MainTitle2: {
                    Spacer()
                } content: {
                    TextField("music.note", text: $musicLogo)
                }
            }
            Group {
                menuButton(titleName: "用刘海更改音量和亮度", showDivider: true) {
                    Spacer()
                } MainTitle2: {
                    Spacer()
                } content: {
                    Toggle(isOn: $appObserver.mediashow) {
                        
                    }
                    .labelsHidden()
                }
                .onChange(of: appObserver.mediashow, perform: { value in
                    appObserver.setvolume()
                })
                
                menuButton(titleName: "显示器是否具有刘海", showDivider: true) {
                    Spacer()
                } MainTitle2: {
                    Spacer()
                } content: {
                    Toggle(isOn: $defautBangs) {
                        
                    }
                    .labelsHidden()
                }
                menuButton(titleName: "音量提醒音", showDivider: true) {
                    Spacer()
                } MainTitle2: {
                    Spacer()
                } content: {
                    Menu(list[playID] ?? "", content: {
                        ForEach(Array(list.keys), id: \.self) { key in
                            Button(list[key]!) {
                                playID = key
                            }
                        }
                    })
                }
                .padding(.bottom, 55)
            }
            
        }
        .frame(minWidth: 450, minHeight: 300)
    }
}

#Preview {
    SettingView()
}

private func getSystemSoundFileEnumerator() -> FileManager.DirectoryEnumerator? {
    guard let libraryDirectory = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .systemDomainMask, true).first,
          let soundsDirectory = NSURL(string: libraryDirectory)?.appendingPathComponent("Sounds"),
          let soundFileEnumerator = FileManager.default.enumerator(at: soundsDirectory, includingPropertiesForKeys: nil) else { return nil }
    return soundFileEnumerator
}
