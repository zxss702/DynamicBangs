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
                if isCharging.isConnect {
                    Image(systemName: "battery.100percent")
                        .resizable()
                        .scaledToFit()
                        .padding([.top, .bottom], 2)
                        .foregroundStyle(isCharging.isCharging ? .green : .orange, .white.opacity(0.7))
                    Image(systemName: isCharging.isCharging ? "bolt.fill" : "powerplug.fill")
                        .resizable()
                        .scaledToFit()
                        .padding(.all, 2)
                        .foregroundStyle(isCharging.isCharging ? .green : .orange)
                } else {
                    Image(systemName: "battery.100percent")
                        .resizable()
                        .scaledToFit()
                        .padding([.top, .bottom], 2)
                        .foregroundStyle(.white, .white.opacity(0.7))
                }
            }
            .frame(height: BangsHeight - 12)
            .transition(.blur.combined(with: .scale(scale: 0, anchor: .trailing)))
        }
    }
}

struct BetterInfoView2: View {
    let isCharging: ChargingInfoFunction
    
    @AppStorage("BangsHeight") var BangsHeight:Double = 32
    
    var body: some View {
        if isCharging.fullType < 3 {
            HStack(spacing: 4) {
                Text(String(isCharging.beter) + "%")
                    .bold()
                    .scaledToFit()
                    .foregroundStyle(.white)
            }
            .frame(height: BangsHeight - 12)
            .transition(.blur.combined(with: .scale(scale: 0, anchor: .trailing)))
        }
    }
}
