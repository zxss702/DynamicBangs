//
//  ContentView.swift
//  DynamicBangs
//
//  Created by 张旭晟 on 2024/2/12.
//

import SwiftUI
import PrivateMediaRemote

struct blurModifier: ViewModifier {
    let state:Bool
    func body(content: Content) -> some View {
        content
            .blur(radius: state ? 20 : 0)
    }
}

extension AnyTransition {
    static var blur: AnyTransition {
        .modifier(
            active: blurModifier(state: true),
            identity: blurModifier(state: false)
        ).combined(with: .opacity)
    }
}

struct isLandView: View {
    @AppStorage("islandModle") var islandModle = false
    var body: some View {
        if islandModle {
            islandContentView()
        } else {
            ContentView()
        }
    }
}

struct islandContentView: View {
    @EnvironmentObject var appObserver:AppObserver
    @AppStorage("BangsWidth") var BangsWidth:Double = 145
    @AppStorage("BangsHeight") var BangsHeight:Double = 32
    
    @State var bigLit = false
    
    @AppStorage("showDevelpoBangs") var showDevelpoBangs = false
    @AppStorage("defautBangs") var defautBangs = true
    @AppStorage("islandModle") var islandModle = false
    
    @Namespace var nameSpace
    
    @State var musicControlHold = false
    @ViewBuilder
    func mediaView(media: mediaInfoFunction) -> some View {
        HStack(alignment: .top, spacing: 15) {
            Button {
                MRMediaRemoteSendCommand(MRMediaRemoteCommandSeekToPlaybackPosition, [:])
            } label: {
                ZStack {
                    if media.image != nil {
                        media.image!
                            .resizable()
                            .scaledToFill()
                            .transition(.blur)
                    } else {
                        Color(NSColor.windowBackgroundColor)
                            .overlay {
                                Image(systemName: "music.quarternote.3")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 45, height: 45)
                                    .foregroundStyle(.gray)
                            }
                            .transition(.blur)
                    }
                }
                .frame(width: 70, height: 70)
                .clipShape(RoundedRectangle(cornerRadius: 9))
                .matchedGeometryEffect(id: "mediaImage", in: nameSpace)
                .shadow(radius: 0.6)
                .scaleEffect(x: media.isPlay ? 1 : 0.8, y: media.isPlay ? 1 : 0.8)
            }
            
            VStack(alignment: .leading, spacing: 0) {
                Text(media.name == "" ? "未知媒体" : media.name)
                    .bold()
                    .font(.title2)
                    .lineLimit(1)
                Spacer(minLength: 0)
                if musicControlHold {
                    HStack(spacing: 17) {
                        Button {
                            MRMediaRemoteSendCommand(MRMediaRemoteCommandPreviousTrack, [:])
                        } label: {
                            Image(systemName: "backward.fill")
                                .font(.title)
                                .foregroundStyle(.gray)
                        }
                        Button {
                            MRMediaRemoteSendCommand(MRMediaRemoteCommandTogglePlayPause, [:])
                        } label: {
                            if media.isPlay {
                                Image(systemName: "pause.fill")
                                    .font(.title)
                                    .foregroundStyle(.gray)
                                    .transition(.blur)
                            } else {
                                Image(systemName: "play.fill")
                                    .font(.title)
                                    .foregroundStyle(.gray)
                                    .transition(.blur)
                            }
                        }
                        Button {
                            MRMediaRemoteSendCommand(MRMediaRemoteCommandNextTrack, [:])
                        } label: {
                            Image(systemName: "forward.fill")
                                .font(.title)
                                .foregroundStyle(.gray)
                        }
                    }
                    .shadow(radius: 8)
                    .transition(.blur)
                } else {
                    Text(media.Artist2 == "" ? "未知专辑" : media.Artist2)
                        .foregroundStyle(.gray)
                        .lineLimit(1)
                    Spacer(minLength: 0)
                    Text(media.Artist == "" ? "未知作者" : media.Artist)
                        .foregroundStyle(.gray)
                        .lineLimit(1)
                    Spacer(minLength: 0)
                }
                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .onHover { Bool in
                musicControlHold = Bool
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .animation(.spring(), value: musicControlHold)
    }
    
    @ViewBuilder
    func volumeView(volume: volumeInfoFunction) -> some View {
        HStack {
            Image(systemName: volume.volome == 0 ? "speaker.slash.fill" : "speaker.wave.3", variableValue: Double(volume.volome))
                .font(.title)
                .bold()
                .foregroundStyle(.black)
            Color.black.opacity(0.5)
                .frame(height: 5)
                .overlay(alignment: .leading) {
                    GeometryReader { GeometryProxy in
                        Capsule(style: .circular)
                            .foregroundStyle(.black)
                            .shadow(radius: 8)
                            .frame(width: GeometryProxy.size.width * CGFloat(volume.volome))
                    }
                }
                .clipShape(Capsule(style: .circular))
                .padding(.trailing, 5)
        }
        .frame(maxWidth: .infinity)
    }
    
    @ViewBuilder
    func brightView(volume: BrightInfoFunction) -> some View {
        HStack {
            Image(systemName: "sun.max.fill", variableValue: Double(volume.bright))
                .font(.title)
                .bold()
                .foregroundStyle(.black)
            Color.black.opacity(0.5)
                .frame(height: 5)
                .overlay(alignment: .leading) {
                    GeometryReader { GeometryProxy in
                        Capsule(style: .circular)
                            .foregroundStyle(.black)
                            .shadow(radius: 8)
                            .frame(width: GeometryProxy.size.width * CGFloat(volume.bright))
                    }
                }
                .clipShape(Capsule(style: .circular))
                .padding(.trailing, 5)
        }
        .frame(maxWidth: .infinity)
    }
    
    @ViewBuilder
    func keyBrightView(volume: BrightInfoFunction) -> some View {
        HStack {
            Image(systemName: "light.max", variableValue: Double(volume.bright))
                .font(.title)
                .bold()
                .foregroundStyle(.black)
            Color.black.opacity(0.5)
                .frame(height: 5)
                .overlay(alignment: .leading) {
                    GeometryReader { GeometryProxy in
                        Capsule(style: .circular)
                            .foregroundStyle(.black)
                            .shadow(radius: 8)
                            .frame(width: GeometryProxy.size.width * CGFloat(volume.bright))
                    }
                }
                .clipShape(Capsule(style: .circular))
                .padding(.trailing, 5)
        }
        .frame(maxWidth: .infinity)
    }
    
    var body: some View {
        let miniMediaImageShow = appObserver.media != nil && appObserver.media?.fullType ?? 10 >= 5 && !bigLit
        let MaxMediaImageShow = appObserver.media != nil && (appObserver.media?.fullType ?? 10 < 5 || bigLit)
        let VolumeShow = appObserver.volume.fullType < 3
        let BrightShow = appObserver.bright?.fullType ?? 10 < 3 && appObserver.bright != nil
        let KeyBrightShow = appObserver.keyBright?.fullType ?? 10 < 3 && appObserver.keyBright != nil
        
        let sc:CGFloat = (MaxMediaImageShow || VolumeShow || BrightShow || KeyBrightShow) ? 1.4 : 1
       
        VStack(spacing: 15) {
            Group {
                ZStack {
                    if MaxMediaImageShow {
                        mediaView(media: appObserver.media!)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .frame(height: 70)
                            .padding(.all, 10)
                            .padding([.leading, .trailing], 15)
                            .transition(.blur)
                            .frame(width: max(BangsWidth * sc, 190 * sc))
                    } else if miniMediaImageShow && !VolumeShow && !BrightShow && !KeyBrightShow {
                        ZStack {
                            if appObserver.media?.image != nil {
                                appObserver.media!.image!
                                    .resizable()
                                    .scaledToFill()
                                    .clipShape(Circle())
                            } else {
                                Image(systemName: "music.quarternote.3")
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundStyle(.gray)
                            }
                        }
                        .compositingGroup()
                        .frame(width: min(BangsHeight, BangsWidth) - 7, height: min(BangsHeight, BangsWidth) - 7)
                        .padding(.all, 7)
                        .transition(.blur)
                    }
                }
                
                if VolumeShow {
                    volumeView(volume: appObserver.volume)
                        .frame(width: max(BangsWidth * sc, 180 * sc), height: 35)
                        .padding(.all, 10)
                        .transition(.blur.combined(with: .move(edge: .top)))
                }
                if BrightShow {
                    brightView(volume: appObserver.bright!)
                        .frame(width: max(BangsWidth * sc, 180 * sc), height: 35)
                        .padding(.all, 10)
                        .transition(.blur.combined(with: .move(edge: .top)))
                }
                if KeyBrightShow {
                    keyBrightView(volume: appObserver.keyBright!)
                        .frame(width: max(BangsWidth * sc, 180 * sc), height: 35)
                        .padding(.all, 10)
                        .transition(.blur.combined(with: .move(edge: .top)))
                }
            }
            .background {
                Capsule()
                    .foregroundStyle(.bar)
                    .compositingGroup()
                    .shadow(radius: 0.6)
                    .shadow(radius: 15)
            }
        }
        .buttonStyle(TapButtonStyle())
        .scaleEffect(x: bigLit ? 1.1 : 1, y: bigLit ? 1.1 : 1, anchor: .top)
        .padding(.all, 5)
        .onHover { Bool in
            bigLit = Bool
        }
        .animation(.spring(), value: BangsWidth)
        .animation(.spring(), value: BangsHeight)
        .animation(.spring(), value: bigLit)
        .animation(.spring(), value: appObserver.media)
        .animation(.spring(), value: appObserver.volume)
        .animation(.spring(), value: appObserver.bright)
        .animation(.spring(), value: appObserver.keyBright)
        .animation(.spring(), value: defautBangs)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}

struct ContentView: View {
    @EnvironmentObject var appObserver:AppObserver
    @AppStorage("BangsWidth") var BangsWidth:Double = 145
    @AppStorage("BangsHeight") var BangsHeight:Double = 32
    
    @State var bigLit = false
    
    @AppStorage("showDevelpoBangs") var showDevelpoBangs = false
    @AppStorage("defautBangs") var defautBangs = true
    @AppStorage("islandModle") var islandModle = false
    
    @Namespace var nameSpace
    
    @State var musicControlHold = false
    @AppStorage("bigFillWidth") var bigFillWidth:Double = 5
    
    @ViewBuilder
    func mediaView(media: mediaInfoFunction) -> some View {
        HStack(alignment: .top, spacing: 15) {
            Button {
                MRMediaRemoteSendCommand(MRMediaRemoteCommandSeekToPlaybackPosition, [:])
            } label: {
                ZStack {
                    if media.image != nil {
                        media.image!
                            .resizable()
                            .scaledToFill()
                            .transition(.blur)
                    } else {
                        Color(NSColor.windowBackgroundColor)
                            .overlay {
                                Image(systemName: "music.quarternote.3")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 45, height: 45)
                                    .foregroundStyle(.gray)
                            }
                            .transition(.blur)
                    }
                }
                .frame(width: 70, height: 70)
                .clipShape(RoundedRectangle(cornerRadius: 9))
                .matchedGeometryEffect(id: "mediaImage", in: nameSpace)
                .shadow(color: .white, radius: 0.6)
                .scaleEffect(x: media.isPlay ? 1 : 0.8, y: media.isPlay ? 1 : 0.8)
            }
            
            VStack(alignment: .leading, spacing: 0) {
                Text(media.name == "" ? "未知媒体" : media.name)
                    .bold()
                    .font(.title2)
                    .foregroundStyle(.white)
                    .lineLimit(1)
                Spacer(minLength: 0)
                if musicControlHold {
                    HStack(spacing: 17) {
                        Button {
                            MRMediaRemoteSendCommand(MRMediaRemoteCommandPreviousTrack, [:])
                        } label: {
                            Image(systemName: "backward.fill")
                                .font(.title)
                                .foregroundStyle(.bar)
                        }
                        Button {
                            MRMediaRemoteSendCommand(MRMediaRemoteCommandTogglePlayPause, [:])
                        } label: {
                            if media.isPlay {
                                Image(systemName: "pause.fill")
                                    .font(.title)
                                    .foregroundStyle(.bar)
                                    .transition(.blur)
                            } else {
                                Image(systemName: "play.fill")
                                    .font(.title)
                                    .foregroundStyle(.bar)
                                    .transition(.blur)
                            }
                        }
                        Button {
                            MRMediaRemoteSendCommand(MRMediaRemoteCommandNextTrack, [:])
                        } label: {
                            Image(systemName: "forward.fill")
                                .font(.title)
                                .foregroundStyle(.bar)
                        }
                    }
                    .shadow(radius: 8)
                    .transition(.blur)
                } else {
                    Text(media.Artist2 == "" ? "未知专辑" : media.Artist2)
                        .foregroundStyle(.gray)
                        .lineLimit(1)
                    Spacer(minLength: 0)
                    Text(media.Artist == "" ? "未知作者" : media.Artist)
                        .foregroundStyle(.gray)
                        .lineLimit(1)
                    Spacer(minLength: 0)
                }
                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .onHover { Bool in
                musicControlHold = Bool
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .animation(.spring(), value: musicControlHold)
    }
    
    @ViewBuilder
    func volumeView(volume: volumeInfoFunction) -> some View {
        HStack {
            Image(systemName: volume.volome == 0 ? "speaker.slash.fill" : "speaker.wave.3", variableValue: Double(volume.volome))
                .font(.title)
                .bold()
                .foregroundStyle(.white)
            Color.white.opacity(0.5)
                .frame(height: 5)
                .overlay(alignment: .leading) {
                    GeometryReader { GeometryProxy in
                        Capsule(style: .circular)
                            .foregroundStyle(.white)
                            .shadow(radius: 8)
                            .frame(width: GeometryProxy.size.width * CGFloat(volume.volome))
                    }
                }
                .clipShape(Capsule(style: .circular))
                .padding(.trailing, 5)
        }
        .frame(maxWidth: .infinity)
    }
    
    @ViewBuilder
    func brightView(volume: BrightInfoFunction) -> some View {
        HStack {
            Image(systemName: "sun.max.fill", variableValue: Double(volume.bright))
                .font(.title)
                .bold()
                .foregroundStyle(.white)
            Color.white.opacity(0.5)
                .frame(height: 5)
                .overlay(alignment: .leading) {
                    GeometryReader { GeometryProxy in
                        Capsule(style: .circular)
                            .foregroundStyle(.white)
                            .shadow(radius: 8)
                            .frame(width: GeometryProxy.size.width * CGFloat(volume.bright))
                    }
                }
                .clipShape(Capsule(style: .circular))
                .padding(.trailing, 5)
        }
        .frame(maxWidth: .infinity)
    }
    
    @ViewBuilder
    func keyBrightView(volume: BrightInfoFunction) -> some View {
        HStack {
            Image(systemName: "light.max", variableValue: Double(volume.bright))
                .font(.title)
                .bold()
                .foregroundStyle(.white)
            Color.white.opacity(0.5)
                .frame(height: 5)
                .overlay(alignment: .leading) {
                    GeometryReader { GeometryProxy in
                        Capsule(style: .circular)
                            .foregroundStyle(.white)
                            .shadow(radius: 8)
                            .frame(width: GeometryProxy.size.width * CGFloat(volume.bright))
                    }
                }
                .clipShape(Capsule(style: .circular))
                .padding(.trailing, 5)
        }
        .frame(maxWidth: .infinity)
    }
    
    var body: some View {
        let miniMediaImageShow = appObserver.media != nil && appObserver.media?.fullType ?? 10 >= 5 && !bigLit
        let MaxMediaImageShow = appObserver.media != nil && (appObserver.media?.fullType ?? 10 < 5 || bigLit)
        let VolumeShow = appObserver.volume.fullType < 3
        let BrightShow = appObserver.bright?.fullType ?? 10 < 3 && appObserver.bright != nil
        let KeyBrightShow = appObserver.keyBright?.fullType ?? 10 < 3 && appObserver.keyBright != nil
        let BetterShow = appObserver.isCharging.fullType < 3
        
        let BigoneCan: Bool = MaxMediaImageShow || VolumeShow || BrightShow || KeyBrightShow
        let Have: Bool = MaxMediaImageShow || VolumeShow || BrightShow || KeyBrightShow || BetterShow || miniMediaImageShow
        
        let smOneCan = !VolumeShow && !BrightShow && !KeyBrightShow && !MaxMediaImageShow
        
        let sc:CGFloat = BigoneCan ? 1.4 : 1
       
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                let width: CGFloat = {
                    if smOneCan {
                        var retWidth:CGFloat = 0
                        if miniMediaImageShow {
                            retWidth = max(retWidth, BangsHeight)
                        }
                        if BetterShow {
                            retWidth = max(retWidth, BangsHeight * 1.3 + 60)
                        }
                        return retWidth
                    } else {
                        return 0
                    }
                }()
                HStack(spacing: 0) {
                    if smOneCan && miniMediaImageShow {
                        ZStack {
                            if appObserver.media?.image != nil {
                                appObserver.media!.image!
                                    .resizable()
                                    .scaledToFill()
                                    .clipShape(Circle())
                            } else {
                                Image(systemName: "music.quarternote.3")
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundStyle(.gray)
                            }
                        }
                        .padding([.leading, .bottom, .top], 5)
                        .frame(width: BangsHeight, height: BangsHeight)
                        .matchedGeometryEffect(id: "mediaImage", in: nameSpace)
                        .shadow(color: .white, radius: 0.6)
                        .padding(.all, 1)
                    }
                }
                .frame(width: width, alignment: .leading)
                
                Color.clear
                    .frame(width: BangsWidth * sc - 20)
                
                HStack(spacing: 0) {
                    if BetterShow && smOneCan {
                        Text(String(appObserver.isCharging.beter) + "%")
                            .bold()
                            .scaledToFit()
                            .foregroundStyle(.white)
                            .frame(width: 60, alignment: .trailing)
                        Image(systemName: appObserver.isCharging.isConnect ? (appObserver.isCharging.isCharging ? "battery.100percent.bolt" : "minus.plus.batteryblock.exclamationmark") : "battery.100percent")
                            .resizable()
                            .scaledToFit()
                            .foregroundStyle(.green, .green.opacity(0.5))
                            .padding(.all, 5)
                            .frame(width: BangsHeight * 1.3, height: BangsHeight)
                            .padding(.all, 1)
                    }
                }
                .frame(width: width, alignment: .trailing)
            }
            .frame(height: (defautBangs ? BangsHeight : ((smOneCan) ? BangsHeight : ((BigoneCan) ? 10 : BangsHeight))))
            
            if MaxMediaImageShow {
                mediaView(media: appObserver.media!)
                    .frame(width: max(BangsWidth * sc, 180 * sc), height: 70, alignment: .leading)
                    .padding([.bottom, .trailing, .leading], 10)
                    .padding(.top, 1)
                    .transition(.blur)
            }
            Group {
                if VolumeShow {
                    volumeView(volume: appObserver.volume)
                }
                if BrightShow {
                    brightView(volume: appObserver.bright!)
                }
                if KeyBrightShow {
                    keyBrightView(volume: appObserver.keyBright!)
                }
            }
            .frame(width: max(BangsWidth * sc, 180 * sc), height: 35, alignment: .leading)
            .padding([.bottom, .trailing, .leading], 10)
            .transition(.blur)
        }
        .clipped()
        .padding([.leading, .trailing], 10)
        .buttonStyle(TapButtonStyle())
        .background {
            ZStack(alignment: .top) {
                BangsShape()
                BangsShape2()
            }
            .foregroundStyle(.black)
            .compositingGroup()
            .shadow(radius: Have ? 8 : 0)
        }
        .scaleEffect(x: bigLit ? 1.1 : 1, y: bigLit ? 1.1 : 1, anchor: .top)
        .overlay(alignment: .top) {
            if showDevelpoBangs {
                ZStack(alignment: .top) {
                    BangsShape()
                    BangsShape2()
                }
                .foregroundStyle(.red)
                .frame(width: BangsWidth, height: BangsHeight)
            }
        }
        .padding([.bottom, .leading, .trailing], bigFillWidth)
        .onHover { Bool in
            bigLit = Bool
        }
        .animation(.spring(), value: BangsWidth)
        .animation(.spring(), value: BangsHeight)
        .animation(.spring().speed(1.1), value: bigLit)
        .animation(.spring(), value: appObserver.media)
        .animation(.spring(), value: appObserver.volume)
        .animation(.spring(), value: appObserver.bright)
        .animation(.spring(), value: appObserver.keyBright)
        .animation(.spring(), value: appObserver.isCharging)
        .animation(.spring(), value: defautBangs)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}
struct BangsShape: Shape {
    func path(in frame: CGRect) -> Path {
        var path = Path()
        path.addRoundedRect(in: CGRect(x: frame.minX + 10, y: frame.minY, width: frame.width - 10 * 2, height: frame.height), cornerRadii: RectangleCornerRadii(bottomLeading: 10, bottomTrailing: 10))
        return path
    }
}

struct BangsShape2: Shape {
    func path(in frame: CGRect) -> Path {
        var path = Path()
        
        path.move(to: CGPoint(x: frame.minX, y: frame.minY))
        path.addQuadCurve(to: CGPoint(x: frame.minX + 10, y: frame.minY + 10), control: CGPoint(x: frame.minX + 10, y: frame.minY))
        
        path.addLine(to: CGPoint(x: frame.maxX - 10, y: frame.minY + 10))
        path.addQuadCurve(to: CGPoint(x: frame.maxX, y: frame.minY), control: CGPoint(x: frame.maxX - 10, y: frame.minY))
        
        path.addLine(to: CGPoint(x: frame.minX, y: frame.minY))
        path.closeSubpath()
        return path
    }
}

struct TapButtonStyle: ButtonStyle {
    @State var scale:CGFloat = 1
    @State var time:Date = Date()
   
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .scaleEffect(x: scale, y: scale)
            .foregroundColor(.accentColor)
            .contentShape(Rectangle())
            .onChange(of: configuration.isPressed, perform: { newValue in
                if newValue {
                    time = Date()
                    withAnimation(.spring().speed(2)) {
                        scale = 0.9
                    }
                } else {
                    if time.distance(to: Date()) > 0.15 {
                        withAnimation(.spring().speed(1.5)) {
                            scale = 1
                        }
                    } else {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                            withAnimation(.spring().speed(1.5)) {
                                scale = 1
                            }
                        }
                    }
                    
                }
            })
    }
}
struct TapButtonStyle2: ButtonStyle {
    @State var scale:CGFloat = 1
    @State var time:Date = Date()
   
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .scaleEffect(x: scale, y: scale)
            .foregroundColor(.accentColor)
            .contentShape(Rectangle())
            .onChange(of: configuration.isPressed, perform: { newValue in
                if newValue {
                    time = Date()
                    withAnimation(.spring().speed(2)) {
                        scale = 0.98
                    }
                } else {
                    if time.distance(to: Date()) > 0.15 {
                        withAnimation(.spring().speed(1.5)) {
                            scale = 1
                        }
                    } else {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                            withAnimation(.spring().speed(1.5)) {
                                scale = 1
                            }
                        }
                    }
                    
                }
            })
    }
}
