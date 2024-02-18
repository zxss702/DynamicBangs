//
//  FirstShowView.swift
//  DynamicBangs
//
//  Created by 张旭晟 on 2024/2/18.
//

import SwiftUI

struct FirstShowView: View {
    @EnvironmentObject var appObserver:AppObserver
    
    @Namespace var nameSpace
    @State var showInfo:Int = -1
    var timer = Timer.publish(every: 1, on: .main, in: RunLoop.Mode.common).autoconnect()
    
    @ViewBuilder
    func DynamicBangs(ss: Bool = true) -> some View {
        ZStack {
            if (ss ? (0...1).contains(showInfo % 4) : (0...4).contains(showInfo % 10)) {
                Text("DynamicBangs")
                    .font(.system(size: ss ? 66 : 33).bold())
                    .lineLimit(1)
                    .scaledToFit()
                    .minimumScaleFactor(0.0001)
                    .foregroundStyle(Color.accentColor)
                    .transition(.blur.combined(with: .scale(scale: 0.8)))
            } else {
                Text("灵动刘海")
                    .font(.system(size: ss ? 66 : 33).bold())
                    .lineLimit(1)
                    .scaledToFit()
                    .minimumScaleFactor(0.0001)
                    .foregroundStyle(Color.accentColor)
                    .transition(.blur.combined(with: .scale(scale: 0.8)))
            }
        }.matchedGeometryEffect(id: "灵动刘海", in: nameSpace)
    }
    var body: some View {
        ZStack {
            if showInfo >= 0 && showInfo < 90 {
                RoundedRectangle(cornerRadius: 35)
                    .foregroundStyle(.ultraThinMaterial)
                    .shadow(radius: 0.6)
                    .shadow(radius: 35)
                    .transition(.asymmetric(insertion: .blur, removal: .blur.combined(with: .scale(scale: 2))))
            }
            VStack(spacing: 25) {
                if showInfo < 10 {
                    Group {
                        if showInfo >= 1 {
                            Image("appLogo")
                                .resizable()
                                .scaledToFit()
                                .shadow(radius: 5)
                                .matchedGeometryEffect(id: "appIcon", in: nameSpace)
                                .frame(maxWidth: 400, maxHeight: 400)
                                .transition(.blur.combined(with: .scale(scale: 0.8)))
                        }
                        if showInfo >= 2 {
                            HStack(spacing: 25) {
                                if showInfo <= 5 {
                                    Text("欢迎来到")
                                        .font(.system(size: 55).bold())
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.0001)
                                        .foregroundStyle(Color.accentColor)
                                        .transition(.blur.combined(with: .scale(scale: 0.8)))
                                }
                                if showInfo >= 3 {
                                    DynamicBangs()
                                }
                            }
                        }
                        if showInfo >= 6 {
                            Button {
                                withAnimation(.spring()) {
                                    showInfo = 10
                                }
                            } label: {
                                RoundedRectangle(cornerRadius: 17)
                                    .frame(maxWidth: 450, maxHeight: 50)
                                    .foregroundStyle(Color.accentColor)
                                    .overlay {
                                        Text("灵动起来")
                                            .bold()
                                            .foregroundStyle(.white)
                                    }
                            }
                            .matchedGeometryEffect(id: "divider", in: nameSpace)
                            .transition(.blur.combined(with: .scale(scale: 0.8)))
                        }
                    }
                }
                if showInfo >= 10 && showInfo < 40 {
                    HStack {
                        Image("appLogo")
                            .resizable()
                            .scaledToFit()
                            .matchedGeometryEffect(id: "appIcon", in: nameSpace)
                            .frame(maxHeight: 66)
                        DynamicBangs(ss: false)
                        Spacer()
                    }
                    .transition(.blur.combined(with: .scale(scale: 0.8)))
                    
                    Divider()
                        .matchedGeometryEffect(id: "divider", in: nameSpace)
                }
                if (10..<20).contains(showInfo) {
                    Group {
                        Text("俏皮而听话 多面而高雅")
                            .font(.system(size: 50).bold())
                            .lineLimit(1)
                            .scaledToFit()
                            .minimumScaleFactor(0.0001)
                            .foregroundStyle(Color.accentColor)
                            .transition(.blur.combined(with: .scale(scale: 0.8)))
                        ScrollView(showsIndicators: false) {
                            VStack(alignment: .leading, spacing: 25) {
                                HStack {
                                    Image(systemName: "display")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 50, height: 50)
                                        .foregroundStyle(Color(NSColor.systemBlue))
                                    VStack(alignment: .leading) {
                                        Text("多显示器")
                                            .bold()
                                            .foregroundStyle(Color.black)
                                        Text("在任何显示器上均可以显示灵动刘海和灵动岛，并且所有显示均同步显示。")
                                            .foregroundStyle(Color.gray)
                                    }
                                }
                                if showInfo >= 11 {
                                    HStack {
                                        Image(systemName: "music.quarternote.3")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 50, height: 50)
                                            .foregroundStyle(Color(NSColor.systemBlue))
                                        VStack(alignment: .leading) {
                                            Text("音乐、视频、声音")
                                                .bold()
                                                .foregroundStyle(Color.black)
                                            Text("实时同步所有媒体当前的状态到灵动刘海上。")
                                                .foregroundStyle(Color.gray)
                                        }
                                    }
                                }
                                if showInfo >= 12 {
                                    HStack {
                                        Image(systemName: "bubbles.and.sparkles")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 50, height: 50)
                                            .foregroundStyle(Color(NSColor.systemBlue))
                                        VStack(alignment: .leading) {
                                            Text("精细到每一帧")
                                                .bold()
                                                .foregroundStyle(Color.black)
                                            Text("灵动刘海动画的每一帧都是经过精心设计，只为给您俏皮又听话的感觉。")
                                                .foregroundStyle(Color.gray)
                                        }
                                    }
                                }
                                if showInfo >= 13 {
                                    HStack {
                                        Image(systemName: "music.quarternote.3")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 50, height: 50)
                                            .foregroundStyle(Color(NSColor.systemBlue))
                                        VStack(alignment: .leading) {
                                            Text("刘海上方方面面")
                                                .bold()
                                                .foregroundStyle(Color.black)
                                            Text("支持多种岛上操作，除媒体控制外还包含音量、亮度、状态提示等多种方面。不仅是多面，经过我们的设计还非常的优雅。")
                                                .foregroundStyle(Color.gray)
                                        }
                                    }
                                }
                            }
                            .padding(.top)
                        }
                    }
                    .transition(.blur)
                    .frame(maxWidth: 450)
                    
                    if showInfo >= 14 {
                        Button {
                            withAnimation(.spring()) {
                                showInfo = 20
                            }
                        } label: {
                            RoundedRectangle(cornerRadius: 17)
                                .frame(maxWidth: 450, maxHeight: 50)
                                .foregroundStyle(Color.accentColor)
                                .overlay {
                                    Text("继续")
                                        .bold()
                                        .foregroundStyle(.white)
                                }
                        }
                        .transition(.blur.combined(with: .scale(scale: 0.8)))
                    }
                }
                if (20..<30).contains(showInfo) {
                    findinmeda(big: true)
                        .frame(maxHeight: .infinity)
                    if showInfo >= 21 {
                        Button {
                            withAnimation(.spring()) {
                                showInfo = 30
                            }
                        } label: {
                            RoundedRectangle(cornerRadius: 17)
                                .frame(maxWidth: 450, maxHeight: 50)
                                .foregroundStyle(Color.accentColor)
                                .overlay {
                                    Text("继续")
                                        .bold()
                                        .foregroundStyle(.white)
                                }
                        }
                        .transition(.blur.combined(with: .scale(scale: 0.8)))
                    }
                    
                }
                if (30..<40).contains(showInfo) {
                    Text("请长按刘海，直到设置窗口弹出")
                        .font(.title)
                        .foregroundStyle(Color.accentColor)
                    
                    RoundedRectangle(cornerRadius: 9)
                        .foregroundStyle(.ultraThinMaterial)
                        .overlay {
                            ContentView()
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 9))
                        .shadow(radius: 0.6)
                        .shadow(radius: 20)
                        .padding([.leading, .trailing], 50)
                    if showInfo >= 36 {
                        Button {
                            withAnimation(.spring()) {
                                showInfo = 40
                            }
                        } label: {
                            RoundedRectangle(cornerRadius: 17)
                                .frame(maxWidth: 450, maxHeight: 50)
                                .foregroundStyle(Color.accentColor)
                                .overlay {
                                    Text("继续")
                                        .bold()
                                        .foregroundStyle(.white)
                                }
                        }
                        .transition(.blur.combined(with: .scale(scale: 0.8)))
                    } else {
                        Spacer()
                    }
                }
                if (40..<50).contains(showInfo) {
                    VStack(spacing: 25) {
                        Image("appLogo")
                            .resizable()
                            .scaledToFit()
                            .shadow(radius: 5)
                            .matchedGeometryEffect(id: "appIcon", in: nameSpace)
                            .frame(maxWidth: 400, maxHeight: 400)
                            .transition(.blur.combined(with: .scale(scale: 0.8)))
                        
                        Text("祝您使用愉快！")
                            .font(.system(size: 50).bold())
                            .lineLimit(1)
                            .scaledToFit()
                            .minimumScaleFactor(0.0001)
                            .foregroundStyle(Color.accentColor)
                            .transition(.blur.combined(with: .scale(scale: 0.8)))
                        Text("华夏大乾 灵动刘海团队 致上")
                            .bold()
                            .font(.title3)
                            .lineLimit(1)
                            .minimumScaleFactor(0.0001)
                            .transition(.blur.combined(with: .scale(scale: 0.8)))
                            .frame(maxWidth: 450, alignment: .trailing)
                        
                        Text("轻触灵动起来。")
                            .foregroundStyle(.gray)
                            .font(.footnote)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.accentColor.opacity(0.01))
                    .onTapGesture {
                        withAnimation(.spring()) {
                            showInfo = 100
                            appObserver.firstShow = false
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            appObserver.setWindow()
                        }
                    }
                }
            }
            .padding(.all, 30)
            .buttonStyle(TapButtonStyle2())
        }
        .onReceive(timer) { _ in
            withAnimation(.spring()) {
                if showInfo < 10 {
                    if showInfo == 9 {
                        showInfo = 6
                    } else {
                        showInfo += 1
                    }
                } else if (10..<20).contains(showInfo) {
                    if showInfo < 19 {
                        showInfo += 1
                    }
                } else if (20..<30).contains(showInfo) {
                    if showInfo < 29 {
                        showInfo += 1
                    }
                } else if (30..<40).contains(showInfo) {
                    if showInfo < 39 {
                        showInfo += 1
                    }
                } else if (40..<50).contains(showInfo) {
                    if showInfo < 49 {
                        showInfo += 1
                    }
                }
            }
        }
        .frame(maxWidth: 750, maxHeight: 550)
        .padding(.all, 150)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    FirstShowView()
}

struct findinmeda: View {
    @State var show小红书 = false
    @State var show抖音 = true
    @State var show企业微信 = false
    var big = true
    @Namespace var nameSpace
    var body: some View {
        HStack {
            Spacer()
            if !show小红书 {
                Button {
                    show抖音 = false
                    show企业微信 = false
                    show小红书 = true
                } label: {
                    Image("logo_xhs")
                        .resizable()
                        .clipShape(Circle())
                        .frame(width: big ? 75 : 50, height: big ? 75 : 50)
                }
                .matchedGeometryEffect(id: "xhs", in: nameSpace)
            } else {
                Image("小红书二维码")
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 17))
                    .matchedGeometryEffect(id: "xhs", in: nameSpace)
            }
            Spacer()
            if !show抖音 {
                Button {
                    show抖音 = true
                    show企业微信 = false
                    show小红书 = false
                } label: {
                    Image("logo_dy")
                        .resizable()
                        .clipShape(Circle())
                        .frame(width: big ? 75 : 50, height: big ? 75 : 50)
                }
                .matchedGeometryEffect(id: "dy", in: nameSpace)
            } else {
                Image("抖音二维码")
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 17))
                    .matchedGeometryEffect(id: "dy", in: nameSpace)
            }
            Spacer()
            if !show企业微信 {
                Button {
                    show抖音 = false
                    show企业微信 = true
                    show小红书 = false
                } label: {
                    Image("企业微信")
                        .resizable()
                        .clipShape(Circle())
                        .frame(width: big ? 75 : 50, height: big ? 75 : 50)
                }
                .matchedGeometryEffect(id: "qw", in: nameSpace)
            } else {
                Image("IMG_1796")
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 17))
                    .matchedGeometryEffect(id: "qw", in: nameSpace)
            }
            Spacer()
        }
        .animation(.spring(), value: show小红书)
        .animation(.spring(), value: show企业微信)
        .animation(.spring(), value: show抖音)
    }
}
