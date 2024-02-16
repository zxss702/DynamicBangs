//
//  BangsShape.swift
//  DynamicBangs
//
//  Created by 张旭晟 on 2024/2/16.
//

import SwiftUI

struct BangsShape: Shape {
    func path(in frame: CGRect) -> Path {
        var path = Path()
        path.addRoundedRect(in: CGRect(x: frame.minX, y: frame.minY, width: frame.width, height: frame.height), cornerRadii: RectangleCornerRadii(bottomLeading: 10, bottomTrailing: 10))
        return path
    }
}

struct BangsShape2: Shape {
    func path(in frame: CGRect) -> Path {
        var path = Path()
        
        path.move(to: CGPoint(x: frame.minX, y: frame.minY))
        path.addQuadCurve(to: CGPoint(x: frame.minX + 10, y: frame.minY + 10), control: CGPoint(x: frame.minX + 10, y: frame.minY))
        
        path.addLine(to: CGPoint(x: frame.maxX - 10, y: frame.minY + 10))
        path.addQuadCurve(to: CGPoint(x: frame.maxX, y: frame.minY), control: CGPoint(x: frame.maxX - 10, y: frame.minY))
        
        path.addLine(to: CGPoint(x: frame.minX, y: frame.minY))
        path.closeSubpath()
        return path
    }
}


struct BangsShapeView: View {
    var body: some View {
        ZStack(alignment: .top) {
            BangsShape2()
            BangsShape()
                .padding([.leading, .trailing], 10)
        }
        .compositingGroup()
    }
}
