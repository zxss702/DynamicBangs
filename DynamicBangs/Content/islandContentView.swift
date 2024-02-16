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
    
    @State var bigLit = false
    
   
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
            Image(systemName: volume.value == 0 ? "speaker.slash.fill" : "speaker.wave.3", variableValue: Double(volume.value))
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
                            .frame(width: GeometryProxy.size.width * CGFloat(volume.value))
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
            Image(systemName: "sun.max.fill", variableValue: Double(volume.value))
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
                            .frame(width: GeometryProxy.size.width * CGFloat(volume.value))
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
            Image(systemName: "light.max", variableValue: Double(volume.value))
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
                            .frame(width: GeometryProxy.size.width * CGFloat(volume.value))
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
        let VolumeShow = appObserver.volume?.fullType ?? 10 < 3 && appObserver.volume != nil
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
                    volumeView(volume: appObserver.volume!)
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

#Preview {
    islandContentView()
}
