//
//  InfoFunctionFloatSetView.swift
//  DynamicBangs
//
//  Created by 张旭晟 on 2024/2/16.
//

import SwiftUI

struct InfoFunctionFloatSetView<T:InfoFunctionFloat>: View {
    let sysImage: String
    @Binding var floatFunction: T?
    @AppStorage("BangsWidth") var BangsWidth:Double = 204
    
    var body: some View {
        if let floatFunction = floatFunction, floatFunction.fullType < 3 {
            let doubleValue = Double(floatFunction.value)
            HStack {
                Image(systemName: sysImage, variableValue: doubleValue)
                    .font(.title)
                    .bold()
                    .foregroundStyle(.white)
                Color.white.opacity(0.5)
                    .frame(height: 5)
                    .overlay(alignment: .leading) {
                        GeometryReader { GeometryProxy in
                            Capsule(style: .circular)
                                .foregroundStyle(.white)
                                .shadow(radius: 8)
                                .frame(width: GeometryProxy.size.width * doubleValue)
                        }
                    }
                    .clipShape(Capsule(style: .circular))
                    .padding(.trailing, 5)
            }
            .padding([.bottom, .trailing, .leading], 10)
            .frame(width: max(BangsWidth * 1.4, 160 * 1.4), height: 35)
            .transition(.blur)
        }
    }
}
