//
//  mediaView.swift
//  DynamicBangs
//
//  Created by 张旭晟 on 2024/2/16.
//

import SwiftUI
import PrivateMediaRemote

struct mediaView: View {
    @Binding var media: mediaInfoFunction?
    @Binding var isTap: Bool
    let nameSpace: Namespace.ID
    
    @State var trW:CGFloat = 0
    @GestureState var isDragMedia = false
    @State var musicControlHold = false
    @EnvironmentObject var appObserver:AppObserver
    @AppStorage("BangsWidth") var BangsWidth:Double = 204
    
    @AppStorage("showCard") var showCard = true
    
    var body: some View {
        if let media = media {
            let canShow = (media.fullType < 5 && showCard) || isTap
            HStack(alignment: .top, spacing: 15) {
                if canShow {
                    Button {
                        MRMediaRemoteGetNowPlayingClient(.main) { MRNowPlayingClientProtobuf in
                            if let id = MRNowPlayingClientProtobuf?.bundleIdentifier {
                                guard let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: id) else { return }
                                
                                let path = "/bin"
                                let configuration = NSWorkspace.OpenConfiguration()
                                configuration.arguments = [path]
                                NSWorkspace.shared.openApplication(at: url, configuration: configuration, completionHandler: nil)
                            }
                        }
                    } label: {
                        ZStack {
                            Color(.windowBackgroundColor)
                                .overlay {
                                    musicImageView(appID: media.appID)
                                        .scaledToFit()
                                        .frame(width: 45, height: 45)
                                        .foregroundStyle(.accent)
                                }
                                .opacity(media.image == nil ? 1 : 0)
                                .overlay {
                                    media.image?
                                        .resizable()
                                        .scaledToFill()
                                }
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                    }
                    .matchedGeometryEffect(id: "mediaImage", in: nameSpace)
                    .frame(width: 70, height: 70)
                    .scaleEffect(x: media.isPlay ? 1 : 0.95, y: media.isPlay ? 1 : 0.95)
                    .padding([.bottom, .leading], 10)
                    .transition(.blur)
                }
                if canShow {
                    VStack(alignment: .leading, spacing: 0) {
                        Text(media.name)
                            .bold()
                            .font(.title2)
                            .foregroundStyle(.white)
                            .truncationMode(.middle)
                            .lineLimit(1)
                        if musicControlHold {
                            Spacer(minLength: 0)
                            HStack(spacing: 0) {
                                Button {
                                    MRMediaRemoteSendCommand(MRMediaRemoteCommandPreviousTrack, [:])
                                } label: {
                                    Image(systemName: "backward.fill")
                                        .font(.title)
                                        .foregroundStyle(.white)
                                }
                                Spacer(minLength: 0)
                                Button {
                                    MRMediaRemoteSendCommand(MRMediaRemoteCommandTogglePlayPause, [:])
                                } label: {
                                    if media.isPlay {
                                        Image(systemName: "pause.fill")
                                            .font(.title)
                                            .foregroundStyle(.white)
                                            .transition(.blur)
                                    } else {
                                        Image(systemName: "play.fill")
                                            .font(.title)
                                            .foregroundStyle(.white)
                                            .transition(.blur)
                                    }
                                }
                                Spacer(minLength: 0)
                                Button {
                                    MRMediaRemoteSendCommand(MRMediaRemoteCommandNextTrack, [:])
                                } label: {
                                    Image(systemName: "forward.fill")
                                        .font(.title)
                                        .foregroundStyle(.bar)
                                }
                                Spacer(minLength: 0)
                                Spacer(minLength: 0)
                            }
                            .transition(.blur)
                            
                            Spacer(minLength: 0)
                            
                            if media.fullTime != 0.1 {
                                GeometryReader { GeometryProxy in
                                    Color.white.opacity(0.5)
                                        .overlay(alignment: .leading) {
                                            Capsule(style: .circular)
                                                .foregroundStyle(.white)
                                                .shadow(radius: 8)
                                                .frame(width: max(GeometryProxy.size.width * CGFloat(media.nowTime / media.fullTime) + trW, 1))
                                        }
                                        .clipShape(Capsule(style: .circular))
                                        .padding(.trailing, 5)
                                        .gesture(
                                            DragGesture(minimumDistance: 0)
                                                .updating($isDragMedia, body: { Value, State, Transaction in
                                                    State = true
                                                    DispatchQueue.main.async {
                                                        let n = GeometryProxy.size.width * CGFloat(media.nowTime / media.fullTime) + Value.translation.width
                                                        if (0...GeometryProxy.size.width).contains(n) {
                                                            trW = Value.translation.width
                                                        } else {
                                                            if n <= 0 {
                                                                trW = 0
                                                            } else {
                                                                trW = GeometryProxy.size.width - GeometryProxy.size.width * CGFloat(media.nowTime / media.fullTime)
                                                            }
                                                        }
                                                    }
                                                })
                                                .onEnded { V in
                                                    let newD = ((GeometryProxy.size.width * CGFloat(media.nowTime / media.fullTime) + trW) / GeometryProxy.size.width) * media.fullTime
                                                    MRMediaRemoteSetElapsedTime(newD)
                                                    appObserver.media?.nowTime = newD
                                                    withAnimation(.spring()) {
                                                        trW = 0
                                                    }
                                                }
                                        )
                                }
                                .frame(height: 5)
                                .padding([.bottom, .top], 5)
                            }
                        } else {
                            Spacer(minLength: 0)
                            Text(media.Artist2)
                                .foregroundStyle(.gray)
                                .lineLimit(1)
                                .truncationMode(.middle)
                            Spacer(minLength: 0)
                            Text(media.Artist)
                                .foregroundStyle(.gray)
                                .lineLimit(1)
                                .truncationMode(.middle)
                            Spacer(minLength: 0)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .onHover { Bool in
                        musicControlHold = Bool
                    }
                    .animation(.spring(), value: musicControlHold)
                    .padding([.bottom, .trailing], 10)
                    .frame(width: max(160, (BangsWidth - 85) * 1.4), height: 80)
                    .transition(.blur)
                }
            }
        }
    }
}


struct mediaInfoImage: View {
    @AppStorage("BangsHeight") var BangsHeight:Double = 32
    let media: mediaInfoFunction?
    @Binding var isHover: Bool
    let nameSpace: Namespace.ID
    
    var body: some View {
        if let media = media, (isHover || media.fullType < 6) {
            ZStack {
                if media.image == nil {
                    musicImageView(appID: media.appID)
                        .scaledToFit()
                        .foregroundStyle(.accent)
                }
                media.image?
                    .resizable()
                    .scaledToFill()
            }
            .clipShape(Circle())
            .matchedGeometryEffect(id: "mediaImage", in: nameSpace)
            .frame(width: BangsHeight - 6, height: BangsHeight - 6)
            .transition(.blur)
        }
    }
}
