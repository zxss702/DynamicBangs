//
//  Ex-View.swift
//  DynamicBangs
//
//  Created by 张旭晟 on 2024/2/16.
//

import SwiftUI

struct TapButtonStyle: ButtonStyle {
    @State var scale:CGFloat = 1
    @State var time:Date = Date()
   
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .scaleEffect(x: scale, y: scale)
            .foregroundColor(.accentColor)
            .contentShape(Rectangle())
            .onChange(of: configuration.isPressed, perform: { newValue in
                if newValue {
                    time = Date()
                    withAnimation(.spring().speed(2)) {
                        scale = 0.9
                    }
                } else {
                    if time.distance(to: Date()) > 0.15 {
                        withAnimation(.spring().speed(1.5)) {
                            scale = 1
                        }
                    } else {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                            withAnimation(.spring().speed(1.5)) {
                                scale = 1
                            }
                        }
                    }
                    
                }
            })
    }
}
struct TapButtonStyle2: ButtonStyle {
    @State var scale:CGFloat = 1
    @State var time:Date = Date()
   
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .scaleEffect(x: scale, y: scale)
            .foregroundColor(.accentColor)
            .contentShape(Rectangle())
            .onChange(of: configuration.isPressed, perform: { newValue in
                if newValue {
                    time = Date()
                    withAnimation(.spring().speed(2)) {
                        scale = 0.98
                    }
                } else {
                    if time.distance(to: Date()) > 0.15 {
                        withAnimation(.spring().speed(1.5)) {
                            scale = 1
                        }
                    } else {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                            withAnimation(.spring().speed(1.5)) {
                                scale = 1
                            }
                        }
                    }
                    
                }
            })
    }
}


struct blurModifier: ViewModifier {
    let state:Bool
    func body(content: Content) -> some View {
        content
            .blur(radius: state ? 20 : 0)
    }
}

extension AnyTransition {
    static var blur: AnyTransition {
        .modifier(
            active: blurModifier(state: true),
            identity: blurModifier(state: false)
        ).combined(with: .opacity)
    }
}

