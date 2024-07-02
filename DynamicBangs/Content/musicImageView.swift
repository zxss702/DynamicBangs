//
//  musicImageView.swift
//  DynamicBangs
//
//  Created by 张旭晟 on 2024/2/16.
//

import SwiftUI

struct musicImageView: View {
    let appID: String
    @AppStorage("musicLogo") var musicLogo = "music.note"
    var body: some View {
        switch appID {
        case "com.netease.163music": return Image("网易云").resizable()
        case "com.apple.Music": return Image("appleMusic").resizable()
        case "com.apple.WebKit.GPU": return Image("safari").resizable()
        case "com.apple.quicklook.QuickLookUIService": return Image("quickLook").resizable()
        default:
            switch musicLogo {
            case "": return Image(systemName: "music.note").resizable()
            default: return Image(systemName: musicLogo).resizable()
            }
        }
        
    }
}
