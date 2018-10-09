//
//  TTTLoginViewController.swift
//  TTTVideoChat
//
//  Created by yanzhen on 2018/8/14.
//  Copyright © 2018年 yanzhen. All rights reserved.
//

import UIKit
import TTTRtcEngineKit

class TTTLoginViewController: UIViewController {

    private var uid: Int64 = 0
    @IBOutlet private weak var roomIDTF: UITextField!
    @IBOutlet private weak var websiteLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let websitePrefix = "http://www.3ttech.cn  version  "
        websiteLabel.text = websitePrefix + TTTRtcEngineKit.getSdkVersion()
        uid = Int64(arc4random() % 100000) + 1
         if let rid = UserDefaults.standard.value(forKey: "ENTERROOMID") as? Int64 {
            roomIDTF.text = rid.description
        } else {
            roomIDTF.text = (arc4random() % 100000 + 1).description
        }
    }

    @IBAction private func enterChannel(_ sender: Any) {
        if roomIDTF.text == nil || roomIDTF.text!.count == 0 || roomIDTF.text!.count >= 19 {
            showToast("请输入19位以内的房间ID")
            return
        }
        let rid = Int64(roomIDTF.text!)!
        TTManager.me.uid = uid
        TTManager.me.mutedSelf = false
        TTManager.roomID = rid
        UserDefaults.standard.set(rid, forKey: "ENTERROOMID")
        UserDefaults.standard.synchronize()
        TTProgressHud.showHud(view)
        //TTT SDK
        let rtcEngine = TTManager.rtcEngine
        rtcEngine?.delegate = self
        rtcEngine?.setChannelProfile(.channelProfile_Communication)
        rtcEngine?.enableVideo()
        rtcEngine?.muteLocalAudioStream(false)
        rtcEngine?.enableAudioVolumeIndication(200, smooth: 3)
        let swapWH = UIInterfaceOrientationIsPortrait(UIApplication.shared.statusBarOrientation)
        if TTManager.videoCustomProfile.isCustom {//自定义
            let custom = TTManager.videoCustomProfile
            var videoSize = custom.videoSize
            if swapWH {
                videoSize = CGSize(width: videoSize.height, height: videoSize.width)
            }
            rtcEngine?.setVideoProfile(videoSize, frameRate: UInt(custom.fps), bitRate: UInt(custom.bitrate))
        } else {
            rtcEngine?.setVideoProfile(TTManager.videoProfile, swapWidthAndHeight: swapWH)
        }
        //高音质
        if TTManager.isHighQualityAudio {
            rtcEngine?.setHighQualityAudioParametersWithFullband(true, stereo: true, fullBitrate: true)
        }
        rtcEngine?.joinChannel(byKey: "", channelName: roomIDTF.text!, uid: uid, joinSuccess: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        roomIDTF.resignFirstResponder()
    }
}

extension TTTLoginViewController: TTTRtcEngineDelegate {
    
    func rtcEngine(_ engine: TTTRtcEngineKit!, didJoinChannel channel: String!, withUid uid: Int64, elapsed: Int) {
        TTProgressHud.hideHud(for: view)
        performSegue(withIdentifier: "VideoChat", sender: nil)
    }
    
    func rtcEngine(_ engine: TTTRtcEngineKit!, didOccurError errorCode: TTTRtcErrorCode) {
        var errorInfo = ""
        switch errorCode {
        case .error_Enter_TimeOut:
            errorInfo = "超时,10秒未收到服务器返回结果"
        case .error_Enter_Failed:
            errorInfo = "无法连接服务器"
        case .error_Enter_BadVersion:
            errorInfo = "版本错误"
        case .error_InvalidChannelName:
            errorInfo = "Invalid channel name"
        default:
            errorInfo = "未知错误: " + errorCode.rawValue.description
        }
        TTProgressHud.hideHud(for: view)
        showToast(errorInfo)
    }
}
