//
//  messageView.swift
//  DynamicBangs
//
//  Created by 张旭晟 on 2024/2/16.
//

import SwiftUI
import PrivateMediaRemote

struct messageView: View {
    let message: messageInfoFunction
    @AppStorage("BangsWidth") var BangsWidth:Double = 204
    
    var body: some View {
        if message.fullType < 5 {
            HStack(alignment: .top, spacing: 15) {
                message.image?
                    .resizable()
                    .scaledToFill()
                    .frame(width: 70, height: 70)
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                
                VStack(alignment: .leading, spacing: 0) {
                    HStack(alignment: .bottom, spacing: 5) {
                        Text(message.title)
                            .bold()
                            .font(.title2)
                            .truncationMode(.middle)
                            .lineLimit(1)
                            .foregroundStyle(message.color)
                        Text(message.title2)
                            .font(.title3)
                            .lineLimit(1)
                            .truncationMode(.middle)
                            .foregroundStyle(message.color.opacity(0.7))
                    }
                    Text(message.body)
                        .lineLimit(3)
                        .foregroundStyle(.gray)
                }
            }
            .padding([.bottom, .trailing, .leading], 10)
            .transition(.blur)
            .frame(width: max(BangsWidth * 1.4, 160 * 1.4), alignment: .leading)
        }
    }
}
