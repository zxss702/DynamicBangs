//
//  BetterInfoView.swift
//  DynamicBangs
//
//  Created by 张旭晟 on 2024/2/16.
//

import SwiftUI
//CGFloat(isCharging.beter) / 100
struct BetterInfoShape: Shape {
    let isCharging: ChargingInfoFunction
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addRoundedRect(in: CGRect(x: 2.6, y: 2.6, width: (rect.width - 9.5) * (1), height: rect.height - 6), cornerSize: CGSize(width: 2.5, height: 2.5))
        return path
    }
}

struct BetterInfoView: View {
    let isCharging: ChargingInfoFunction
    
    @AppStorage("BangsHeight") var BangsHeight:Double = 32
    
    var body: some View {
        if isCharging.fullType < 3 {
            HStack(spacing: 4) {
                if isCharging.isConnect {
                    Image(systemName: {
                        if (0..<20).contains(isCharging.beter) {
                            return "battery.0percent"
                        } else if (20..<50).contains(isCharging.beter) {
                            return "battery.25percent"
                        } else if (50..<80).contains(isCharging.beter) {
                            return "battery.50percent"
                        } else if (80..<100).contains(isCharging.beter) {
                            return "battery.75percent"
                        } else {
                            return "battery.100percent"
                        }
                    }())
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(isCharging.isCharging ? .green : .orange, .white.opacity(0.8))
                    .padding([.top, .bottom], 2)
                    
                    Image(systemName: isCharging.isCharging ? "bolt.fill" : "powerplug.fill")
                        .resizable()
                        .scaledToFit()
                        .padding(.all, 2)
                        .foregroundStyle(isCharging.isCharging ? .green : .orange)
                } else {
                    Image(systemName: {
                        if (0..<20).contains(isCharging.beter) {
                            return "battery.0percent"
                        } else if (20..<50).contains(isCharging.beter) {
                            return "battery.25percent"
                        } else if (50..<80).contains(isCharging.beter) {
                            return "battery.50percent"
                        } else if (80..<100).contains(isCharging.beter) {
                            return "battery.75percent"
                        } else {
                            return "battery.100percent"
                        }
                    }())
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
