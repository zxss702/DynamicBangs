//
//  musicImageView.swift
//  DynamicBangs
//
//  Created by 张旭晟 on 2024/2/16.
//

import SwiftUI

struct musicImageView: View {
    @AppStorage("musicLogo") var musicLogo = "music.note"
    var body: some View {
        switch musicLogo {
        case "网易云": return Image("网易云").resizable()
        case "": return Image(systemName: "music.note").resizable()
        default: return Image(systemName: musicLogo).resizable()
        }
    }
}
#Preview {
    musicImageView()
}
