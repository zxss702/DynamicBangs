//
//  menuButton.swift
//  noteE
//
//  Created by 张旭晟 on 2023/3/3.
//

import SwiftUI

struct menuButton<Content:View,Content2:View, Content3:View>:View {
    
    let titleName:String
    let showDivider:Bool
    @ViewBuilder var MainTitle:Content
    @ViewBuilder var MainTitle2:Content3
    @ViewBuilder var content:Content2
    
    var body: some View {
        VStack {
            if showDivider {
                Divider()
            }
            HStack{
                Text(titleName)
                    .font(.caption)
                    .foregroundColor(.gray)
                MainTitle
                    .frame(maxWidth: .infinity, alignment: .leading)
                MainTitle2
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding([.leading, .trailing],10)
            
            content
                .padding([.leading,.trailing],10)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .frame(height: 30)
        }
    }
}

struct PopoverRootStyle<Content: View>: View {
    @ViewBuilder var content:Content
    
    var body: some View {
        ScrollView{
            VStack{
               content
            }
            .padding([.leading,.trailing],10)
            .padding([.top, .bottom], 15)
        }
    }
}
