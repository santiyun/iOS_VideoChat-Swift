//
//  TTTUser.swift
//  TTTVideoChat
//
//  Created by yanzhen on 2018/8/14.
//  Copyright © 2018年 yanzhen. All rights reserved.
//

import UIKit

class TTTUser: NSObject {

    var uid: Int64 = 0
    var mutedSelf = false //是否静音
    
    init(_ uid: Int64) {
        self.uid = uid
    }
}
