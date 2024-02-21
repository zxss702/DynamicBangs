//
//  main.swift
//  DynamicBangs
//
//  Created by 张旭晟 on 2024/2/21.
//

import Cocoa

autoreleasepool {
    let app =   NSApplication.shared //创建应用
    let delegate = AppObserver()
    app.delegate =  delegate
    app.run() //启动应用
}
