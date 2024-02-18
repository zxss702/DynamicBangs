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


extension View {
    func EditViewLabelStyle(_ padding: Bool = false, color: Color = Color.init(nsColor: .windowBackgroundColor)) -> some View {
        self
            .frame(minWidth: 27, minHeight: 27)
            .padding([.leading, .trailing], padding ? 11 : 0)
            .background(color)
            .clipShape(Capsule(style: .continuous))
    }
    func EditShadow() -> some View {
        self
            .shadow(color: Color(.sRGBLinear, white: 0, opacity: 0.1), radius: 0.3)
            .shadow(color: Color(.sRGBLinear, white: 0, opacity: 0.1), radius: 8)
    }
}

extension View {
    func ifMode(@ViewBuilder ifAction: (AnyView) -> some View) -> some View {
        ifAction(AnyView(self))
    }
    
    @ViewBuilder
    func provided(_ Bool: Bool, _ ifAction: (AnyView) -> some View, else elseAction: (AnyView) -> some View = { AnyView in return AnyView}) -> some View {
        if Bool {
            ifAction(AnyView(self))
        } else {
            elseAction(AnyView(self))
        }
    }
    
    
    func shadow(Ofset: CGPoint = .zero) -> some View {
        self
            .shadow(radius: 0.3)
            .shadow(color: Color(.sRGBLinear, white: 0, opacity: 0.2), radius: 35, x: Ofset.x, y: Ofset.y)
    }
    func shadow(size: CGFloat, Ofset: CGPoint = .zero) -> some View {
        self
            .shadow(radius: size, x: Ofset.x, y: Ofset.y)
    }
    func shadow(color: Color, size: CGFloat, Ofset: CGPoint = .zero) -> some View {
        self
            .shadow(color: color, radius: size, x: Ofset.x, y: Ofset.y)
    }
}
