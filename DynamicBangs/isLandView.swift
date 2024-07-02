//
//  isLandView.swift
//  DynamicBangs
//
//  Created by 张旭晟 on 2024/2/16.
//

import SwiftUI

struct isLandView: View {
    @AppStorage("islandModle") var islandModle = false
    @EnvironmentObject var appObserver:AppObserver
    @AppStorage("BangsWidth") var BangsWidth:Double = 204
    @AppStorage("BangsHeight") var BangsHeight:Double = 32
    
    var body: some View {
        if appObserver.showWhite {
            ZStack(alignment: .top) {
                BangsShape2()
                BangsShape()
                    .padding([.leading, .trailing], 10)
                BangsShape()
                    .stroke(lineWidth: 1)
                    .padding([.leading, .trailing], 10)
                    .foregroundStyle(.black)
            }
            .foregroundStyle(.white)
            .compositingGroup()
            .frame(width: BangsWidth, height: BangsHeight)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        } else {
                ContentView()
#if DEBUG
                .overlay {
                    ZStack(alignment: .top) {
                        BangsShape2()
                        BangsShape()
                            .padding([.leading, .trailing], 10)
                        BangsShape()
                            .stroke(lineWidth: 1)
                            .padding([.leading, .trailing], 10)
                            .foregroundStyle(.black)
                    }
                    .foregroundStyle(.white)
                    .compositingGroup()
                    .frame(width: BangsWidth, height: BangsHeight)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .allowsHitTesting(false)
                    .opacity(0.3)
                }
               
#endif
        }
    }
}


#Preview {
    isLandView()
}
