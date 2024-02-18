//
//  工作室.swift
//  noteE
//
//  Created by 张旭晟 on 2024/2/6.
//

import SwiftUI

struct 工作室: View {
    var body: some View {
        SettingViewCellViewType(title: "") {
            Image("华夏大乾")
                .resizable()
                .scaledToFit()
                .padding(.all, 50)
                .shadow(color: .yellow.opacity(0.3), radius: 40)
            TitleText(title: "关于我们", text:
"""
    华夏大乾是一家地址位于北京，且尚未创立的公司。我们旨在于为世界带来不可思议的改变。我们以用户为根本，时代为基础，谱写时代辉煌，构建荣华篇章。
    我们主要营业包含多种方面，将在未来在软件硬件等多个方面不断发展，包含计算机软件和操作系统、手机软硬件，可穿戴设备软件硬件、航空航天、多种生活用品。华夏大乾将会成为一家从产品广度超过世界上任何一家企业，在规模上达到空前宏大、前无古人、后无来者的一家超级集团。
"""
            )
            TitleText(title: "成员组成", text:
"""
    ·创始人：筑梦（艺名），一位00后追求完美的疯狂原始人，目前正在就读高三。现负责华夏大乾旗下所有业务包括设计、开发、测试、宣传。
    ......
    更多等待您的加入
"""
            )
            TitleText(title: "发展状况", text:
"""
    近年来，华夏大乾完成并推出了noteE，并且在不断的维护更新。未来形式一片大好，期待美好的明天。
"""
            )
            TitleText(title: "主要产品", text:
"""
    华夏大乾旗下共有5款产品分别处于不同阶段。
    1.华夏大乾于2022年完成了noteE设计和构建，于2023年放出了noteE的公开测试版本，目前noteE尚在公开测试。
    2.华夏大乾于2023年初开始设计并开始构建信鸽通讯软件，目前尚未完成第一个公测版本构建，内部测试产品存在功能缺陷和缺失。
    3.华夏大乾于2023年底开启ChasingOS设计，目前仍然处于早期尝试阶段。
    4.华夏大乾于2022年底开启灵域虚拟桌面程序设计和构建。目前尚未完成第一个公测版本，内部版本基本操作界面已经完成构建，内部小型程序还在构建中，目前已经完成两个内部程序构建。
    5.华夏大乾于2024年初开启了灵动刘海DynamicBangs的设计和构建。于2024年初放出了灵动刘海的公开测试版本，目前灵动刘海尚在公开测试。
"""
            )
            TitleText(title: "销售业绩及网络", text:
"""
    从华夏大乾已经开启公测的软件数据来开，我们在全球范围内拥有越400左右的用户。
"""
            )
            Group {
                TitleText(title: "加入我们", text:
"""
    华夏大乾将会成为世界一流企业，现在加入我们，成为华夏大乾成长路上的功臣！
    华夏大乾目前尚未成立，您可以通过添加创始人（筑梦）的企业微信来寻求合作事宜。
"""
                )
                Image("IMG_1796")
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 9))
                    .frame(maxWidth: 250)
                    .padding([.leading, .trailing], 20)
                    .EditShadow()
            }
            Group {
                TitleText(title: "为我们捐款", text:
"""
    资助华夏大乾成立和壮大，我们将会在未来的所有版本中、以及华夏大乾将来的网站和总部永远放置您的名字，并且永远记住您。
"""
                )
                HStack {
                    Image("IMG_2601")
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 9))
                        .frame(maxWidth: 250)
                        .padding([.leading, .trailing], 20)
                    Image("IMG_2602")
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 9))
                        .frame(maxWidth: 250)
                        .padding([.leading, .trailing], 20)
                }
                .EditShadow()
                TitleText(title: "所有捐款者", text: "")
            }
        }
    }
}

@ViewBuilder
func TitleText(title: String, text: String) -> some View {
    VStack(alignment: .leading, spacing: 8, content: {
        Text(title)
            .font(.title)
            .bold()
            .padding([.leading, .trailing])
            .frame(maxWidth: .infinity, alignment: .leading)
        Text(text)
            .padding([.leading, .trailing])
    })
}

#Preview {
    工作室()
}
