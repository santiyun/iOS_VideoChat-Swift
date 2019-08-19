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
    public var roomID: Int64 = 0
    public var me = TTTUser(0)
    //高级设置
    public var isHighQualityAudio = false
    public var videoProfile = TTTRtcVideoProfile._VideoProfile_Default
    //自定义
    public var videoCustomProfile = (isCustom: false, videoSize: CGSize.zero, bitrate: 0, fps: 0)
    private override init() {
        super.init()
        //设置AppID
        rtcEngine = TTTRtcEngineKit.sharedEngine(withAppId: <#name#>, delegate: nil)
    }
}
