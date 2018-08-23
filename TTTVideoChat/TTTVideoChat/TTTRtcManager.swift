//
//  TTTRtcManager.swift
//  TTTVideoChat
//
//  Created by yanzhen on 2018/8/14.
//  Copyright © 2018年 yanzhen. All rights reserved.
//

import UIKit
import TTTRtcEngineKit

let TTManager = TTTRtcManager.manager

class TTTRtcManager: NSObject {

    public static let manager = TTTRtcManager()
    public var rtcEngine: TTTRtcEngineKit!
    public var roomID = 0
    public var me = TTTUser(0)
    private override init() {
        super.init()
        rtcEngine = TTTRtcEngineKit.sharedEngine(withAppId: "a967ac491e3acf92eed5e1b5ba641ab7", delegate: nil)
    }
}
