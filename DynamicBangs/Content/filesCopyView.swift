//
//  filesCopyView.swift
//  DynamicBangs
//
//  Created by 张旭晟 on 2024/6/27.
//

import SwiftUI

struct filesCopyView: View {
    @Binding var isTap: Bool
    
    @EnvironmentObject var appObserver:AppObserver
    @AppStorage("BangsWidth") var BangsWidth:Double = 204
    
    var body: some View {
        if isTap && !appObserver.saveURL.isEmpty {
            let height1:CGFloat = CGFloat(appObserver.saveURL.count * 50)
            let height2 = 200.0
            
            ScrollView(showsIndicators: false) {
                cells()
            }
            .frame(height: min(height2, height1))
            .scrollDisabled(height1 <= height2)
            .transition(.blur)
        }
    }
    
    @ViewBuilder
    func cells() -> some View {
        VStack(spacing: 10) {
            ForEach(Array(appObserver.saveURL.keys), id: \.self) { url in
                HStack(spacing: 15) {
                    appObserver.saveURL[url]?.image
                        .resizable()
                        .scaledToFit()
                        .frame(width: 35, height: 35, alignment: .center)
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                    
                    VStack(alignment: .leading, spacing: 0) {
                        Text(appObserver.saveURL[url]?.name ?? "")
                            .bold()
                            .font(.title2)
                            .truncationMode(.middle)
                            .lineLimit(1)
                            .foregroundStyle(.white)
                        
                        Text(url.deletingLastPathComponent().lastPathComponent)
                            .lineLimit(3)
                            .foregroundStyle(.gray)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Button {
                        appObserver.saveURL.removeValue(forKey: url)
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundStyle(.red)
                    }
                }
                .transition(.blur)
                .frame(height: 40)
                .onDrag {
                    appObserver.saveURL.removeValue(forKey: url)
                    return NSItemProvider(object: url as NSURL)
                } preview: {
                    appObserver.saveURL[url]?.image
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                }

            }
        }
        .padding(.horizontal, 10)
        .padding(.bottom, 10)
        .frame(width: max(BangsWidth * 1.4, 245), alignment: .leading)
    }
}
