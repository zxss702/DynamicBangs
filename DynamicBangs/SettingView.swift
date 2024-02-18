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
    @Binding var show: Bool
    var settingWindow:NSWindow? = nil
    
    @EnvironmentObject var appObserver:AppObserver
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 5) {
                    Spacer()
                        .frame(height: 25)
                    Text("设置")
                        .font(.largeTitle)
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding([.leading, .trailing])
                    Divider()
                        .padding([.leading, .trailing], 8)
                        .padding(.bottom, 5)
                    VStack(spacing: 15) {
                        NavigationLink {
                            通用()
                        } label: {
                            MainColumnButton(image: Image(systemName: "gearshape"), color: .gray, text: Text("通用"))
                        }
                        NavigationLink {
                            显示器()
                        } label: {
                            MainColumnButton(image: Image(systemName: "display"), color: .blue, text: Text("显示器"))
                        }
                        .padding(.top)
                        NavigationLink {
                            活动()
                        } label: {
                            MainColumnButton(image: Image(systemName: "ellipsis"), color: .orange, text: Text("活动"))
                        }
                        NavigationLink {
                            媒体()
                        } label: {
                            MainColumnButton(image: Image(systemName: "music.note"), color: .red, text: Text("媒体"))
                        }
                       
                        NavigationLink {
                            关于()
                        } label: {
                            MainColumnButton(image: Image(systemName: "info"), color: .accent, text: Text("关于"))
                        }
                        .padding(.top)
                        NavigationLink {
                            工作室()
                        } label: {
                            MainColumnButton(image: Image("华夏大乾"), color: .yellow, text: Text("工作室"))
                        }
                        
                    }
                    .padding([.leading, .trailing], 8)
                    .buttonStyle(TapButtonStyle2())
                    
                    Group {
                        Divider()
                            .padding([.top, .bottom], 10)
                        Text("在社交媒体上找到我们")
                            .font(.custom("Bradley Hand", size: 20))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text("获取最新资讯和技巧或加入我们")
                            .font(.footnote)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        findinmeda(big: false)
                            .padding(.bottom, 20)
                    }
                    .padding([.leading, .trailing], 10)
                    
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay(alignment: .topLeading) {
            if settingWindow != nil {
                Button {
                    appObserver.isSettingOpen = false
                    withAnimation(.spring()) {
                        show = false
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        settingWindow?.close()
                    }
                } label: {
                    Circle().frame(width: 13, height: 13)
                        .foregroundStyle(.red)
                }
                .padding(.all, 10)
            }
        }
        .overlay(alignment: .topTrailing) {
            if settingWindow != nil {
                Button {
                    NSApplication.shared.terminate(nil)
                } label: {
                    Text("退出程序")
                        .foregroundStyle(Color(.labelColor))
                        .padding([.leading, .trailing], 5)
                        .background(Capsule().foregroundStyle(.accent))
                        .frame(height: 13)
                }
                .padding(.all, 10)
            }
        }
        .buttonStyle(TapButtonStyle())
    }
    
    @AppStorage("musicLogo") var musicLogo = "music.note"
    @AppStorage("palyID") var playID: Int = 1
    
    @ViewBuilder
    func 媒体() -> some View {
        SettingViewCellViewType(title: "媒体") {
            SettingCellView(showDivier: false, name: "音乐占位符", bottomName: "SFImage或“网易云“作为占位符") {
                TextField("music.note", text: $musicLogo)
            }
            SettingCellView(showDivier: true, name: "音量和亮度", bottomName: "使用灵动刘海调节音量和亮度") {
                Toggle(isOn: $appObserver.mediashow) {
                    
                }
                .labelsHidden()
            }
            .onChange(of: appObserver.mediashow, perform: { value in
                appObserver.setvolume()
            })
            
            SettingCellView(showDivier: true, name: "提示音", bottomName: "设定当音量更改时播放的提示音") {
                Menu(list[playID] ?? "", content: {
                    ForEach(Array(list.keys), id: \.self) { key in
                        Button(list[key]!) {
                            playID = key
                        }
                    }
                })
            }
            
            SettingCellView2(showDivier: true, name: "黑名单", bottomName: "未勾选的程序将不会激活大卡片") {
                VStack(spacing: 15) {
                    let showImageList:[mediaAppCanShow] = (try? PropertyListDecoder().decode([mediaAppCanShow].self, from: appObserver.showImageListData)) ?? []
                    
                    ForEach(showImageList) { list in
                        Button {
                            var listCopy = showImageList
                            if let int = listCopy.firstIndex(where: { mediaAppCanShow in
                                mediaAppCanShow.id == list.id
                            }) {
                                listCopy[int].canShow.toggle()
                            }
                            do {
                                appObserver.showImageListData = try PropertyListEncoder().encode(listCopy)
                            } catch {
                                print(error)
                            }
                        } label: {
                            MainColumnButton2(image: Image(systemName: "app"), color: list.canShow ? .blue : .gray, text:  Text(list.id))
                        }
                    }
                }
                .padding([.leading, .trailing], 10)
                .padding(.top, 5)
            }
        }
    }
    
    
    @AppStorage("showCard") var showCard = true
    @AppStorage("noLiveToHide") var noLiveToHide = false
    
    @ViewBuilder
    func 活动() -> some View {
        SettingViewCellViewType(title: "活动") {
            SettingCellView(showDivier: false, name: "大卡片", bottomName: "勾选后将在有活动时显示大卡片") {
                Toggle(isOn: $showCard) {
                    
                }
                .labelsHidden()
            }
            SettingCellView(showDivier: true, name: "隐藏视图", bottomName: "无活动时隐藏所有视图") {
                Toggle(isOn: $noLiveToHide) {
                    
                }
                .labelsHidden()
            }
            
        }
    }
    
    @AppStorage("defautBangs") var defautBangs = true
    
    @ViewBuilder
    func 显示器() -> some View {
        SettingViewCellViewType(title: "显示器") {
            SettingCellView2(showDivier: false, name: "显示的屏幕", bottomName: "勾选您希望显示灵动刘海的显示器") {
                VStack(spacing: 15) {
                    ForEach(NSScreen.screens, id: \.displayInt) { sc in
                        Button {
                            withAnimation(.spring()) {
                                if let int = appObserver.showDisplays.firstIndex(of: sc.displayInt) {
                                    appObserver.showDisplays.remove(at: int)
                                } else {
                                    appObserver.showDisplays.append(sc.displayInt)
                                }
                            }
                            appObserver.setWindow()
                        } label: {
                            MainColumnButton2(image: Image(systemName: "display"), color: appObserver.showDisplays.contains(sc.displayInt) ? .blue : .gray, text: Text(String(sc.localizedName)))
                        }
                    }
                }
                .padding([.leading, .trailing], 10)
                .padding(.top, 5)
            }
            SettingCellView(showDivier: true, name: "显示器刘海", bottomName: "您的显示器是否具有刘海") {
                Toggle(isOn: $defautBangs) {
                    
                }
                .labelsHidden()
            }
        }
    }
    
    @AppStorage("BangsWidth") var BangsWidth:Double = 204
    @AppStorage("BangsHeight") var BangsHeight:Double = 32
    @AppStorage("islandModle") var islandModle = false
    
    @ViewBuilder
    func 通用() -> some View {
        SettingViewCellViewType(title: "通用") {
            Text("确保刘海外有黑色边缘，白色被刘海覆盖。")
                .bold()
                .lineLimit(1)
                .font(.title3)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding([.leading, .trailing], 10)
            Group {
                SettingCellView(showDivier: true, name: "刘海宽度", bottomName: "用于确定刘海的位置和宽度") {
                    Slider(value: $BangsWidth, in: 100...300) { Bool in
                        withAnimation(.spring()) {
                            appObserver.showWhite = Bool
                        }
                    }
                    .animation(.spring(), value: BangsWidth)
                }
                SettingCellView(showDivier: true, name: "刘海高度", bottomName: "用于确定刘海的位置和高度") {
                    Slider(value: $BangsHeight, in: 21...100) { Bool in
                        withAnimation(.spring()) {
                            appObserver.showWhite = Bool
                        }
                    }
                    .animation(.spring(), value: BangsHeight)
                }
                SettingCellView(showDivier: true, name: "抹掉设置", bottomName: "重置刘海宽度和高度") {
                    Button("重置") {
                        BangsWidth = 204
                        BangsHeight = 32
                    }
                }
            }
            .padding(.leading, 10)
            SettingCellView(showDivier: true, name: "灵动岛模式", bottomName: "勾选后将使用胶囊造型") {
                Toggle(isOn: $islandModle) {
                    
                }
                .labelsHidden()
            }
        }
    }
}

struct SettingViewCellViewType<Content: View>: View {
    let title:String
    @ViewBuilder var content: () -> Content
    
    @Environment(\.dismiss) var dismiss
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 5) {
                Spacer()
                    .frame(height: 25)
                if title != "" {
                    Text(title)
                        .font(.largeTitle)
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding([.leading, .trailing])
                    Divider()
                        .padding([.leading, .trailing], 8)
                        .padding(.bottom, 5)
                }
                VStack {
                    content()
                }
                .padding([.leading, .trailing], 8)
                .buttonStyle(TapButtonStyle2())
                Spacer()
                    .frame(height: 55)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay(alignment: .bottomLeading) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.backward")
                    .EditViewLabelStyle()
                    .EditShadow()
            }
            .padding(.all)
        }
        
    }
}
struct SettingView2: View {
    @EnvironmentObject var appObserver:AppObserver
    
    @Binding var show: Bool
    var settingWindow:NSWindow? = nil
    
    @AppStorage("BangsWidth") var BangsWidth:Double = 204
    @AppStorage("BangsHeight") var BangsHeight:Double = 32
    
   
    @AppStorage("defautBangs") var defautBangs = true
    
    
    @AppStorage("fontSecler") var fontSecler:Double = 1
    
    @AppStorage("showCard") var showCard = true
    
    @AppStorage("palyID") var playID: Int = 1
    
    @AppStorage("musicLogo") var musicLogo = "music.note"
    @AppStorage("noLiveToHide") var noLiveToHide = false
    
    var body: some View {
        PopoverRootStyle {
            Group {
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
            
        }
    }
}

private func getSystemSoundFileEnumerator() -> FileManager.DirectoryEnumerator? {
    guard let libraryDirectory = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .systemDomainMask, true).first,
          let soundsDirectory = NSURL(string: libraryDirectory)?.appendingPathComponent("Sounds"),
          let soundFileEnumerator = FileManager.default.enumerator(at: soundsDirectory, includingPropertiesForKeys: nil) else { return nil }
    return soundFileEnumerator
}

struct SettingCellView<Content:View>:View {
   
    let showDivier:Bool
    let name:String
    let bottomName:String
    
    @ViewBuilder var content:Content
    var body: some View {
        VStack {
            if showDivier {
                Divider()
            }
            
            HStack {
                VStack {
                    Text(name)
                        .bold()
                        .lineLimit(1)
                        .font(.title3)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text(bottomName)
                        .font(.footnote)
                        .lineLimit(1)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxWidth: .infinity)
                Spacer()
                content
            }
            .padding([.leading, .trailing], 10)
        }
    }
}

struct SettingCellView2<Content:View>:View {
   
    let showDivier:Bool
    let name:String
    let bottomName:String
    
    @ViewBuilder var content:Content
    var body: some View {
        VStack {
            if showDivier {
                Divider()
            }
            
            HStack {
                VStack {
                    Text(name)
                        .bold()
                        .lineLimit(1)
                        .font(.title3)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text(bottomName)
                        .font(.footnote)
                        .lineLimit(1)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxWidth: .infinity)
                Spacer()
            }
            .padding([.leading, .trailing], 10)
            
            content
        }
    }
}

@ViewBuilder
func MainColumnButton(image: Image, color: Color, text: Text) -> some View {
    HStack(spacing: 12) {
        image
            .resizable()
            .scaledToFit()
            .foregroundColor(color)
            .frame(width: 21, height: 21)
            .frame(width: 30, height: 30)
            .background(.bar)
            .clipShape(RoundedRectangle(cornerRadius: 9))
            .shadow(color: color.opacity(0.5), radius: 3)
            .shadow(color: color, radius: 30)
        text
            .foregroundStyle(Color(NSColor.labelColor))
        Spacer()
        Image(systemName: "chevron.forward")
            .foregroundStyle(.gray)
    }
    .padding(EdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 10))
    .background(.background)
    .compositingGroup()
    .drawingGroup()
    .clipShape(RoundedRectangle(cornerRadius: 13))
    .EditShadow()
}

@ViewBuilder
func MainColumnButton2(image: Image, color: Color, text: Text) -> some View {
    HStack(spacing: 12) {
        image
            .resizable()
            .scaledToFit()
            .foregroundColor(color)
            .frame(width: 21, height: 21)
            .frame(width: 30, height: 30)
            .background(.bar)
            .clipShape(RoundedRectangle(cornerRadius: 9))
            .shadow(color: color.opacity(0.5), radius: 3)
            .shadow(color: color, radius: 30)
        text
            .foregroundStyle(Color(NSColor.labelColor))
        Spacer()
    }
    .padding(EdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 10))
    .background(.background)
    .compositingGroup()
    .drawingGroup()
    .clipShape(RoundedRectangle(cornerRadius: 13))
    .EditShadow()
}
