//
//  BetterInfoView.swift
//  DynamicBangs
//
//  Created by 张旭晟 on 2024/2/16.
//

import SwiftUI

struct BetterInfoView: View {
    let isCharging: ChargingInfoFunction
    
    @AppStorage("BangsHeight") var BangsHeight:Double = 32
    
    var body: some View {
        if isCharging.fullType < 3 {
            HStack(spacing: 4) {
                Text(String(isCharging.beter) + "%")
                    .bold()
                    .scaledToFit()
                    .foregroundStyle(.white)
                
                Image(systemName: isCharging.isConnect ? (isCharging.isCharging ? "battery.100percent.bolt" : "minus.plus.batteryblock.exclamationmark") : "battery.100percent")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(.green, .green.opacity(0.5))
            }
            .frame(height: BangsHeight - 12)
            .padding(.trailing, 5)
            .transition(.blur.combined(with: .scale(scale: 0, anchor: .trailing)))
        }
    }
}
