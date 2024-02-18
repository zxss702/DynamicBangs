//
//  关于.swift
//  notesE
//
//  Created by 张旭晟 on 2023/3/11.
//

import SwiftUI

struct 关于:View {
    var body: some View {
        SettingViewCellViewType(title: "") {
            VStack(spacing: 12) {
                Image("appLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 160, height: 160)
                    .shadow(size:40)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                HStack(alignment: .bottom) {
                    Text("灵动刘海")
                        .font(.largeTitle)
                        .scaledToFit()
                        .bold()
                        .foregroundStyle( Color(NSColor.labelColor))
                    Text(Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String)
                        .bold()
                        .foregroundColor(.gray)
                    Spacer()
                }
                Text("由筑梦编写❤️")
                    .font(.system(size: 20))
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("改变世界的梦想")
                    .font(.system(size: 20))
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Divider()
            }
        }
    }
}
