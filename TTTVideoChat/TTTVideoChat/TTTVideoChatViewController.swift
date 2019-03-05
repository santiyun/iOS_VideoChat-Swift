//
//  TTTVideoChatViewController.swift
//  TTTVideoChat
//
//  Created by yanzhen on 2018/8/14.
//  Copyright © 2018年 yanzhen. All rights reserved.
//

import UIKit
import TTTRtcEngineKit

class TTTVideoChatViewController: UIViewController {

    private var users = [TTTUser]()
    private var avRegions = [TTTAVRegion]()
    @IBOutlet private weak var meImgView: UIImageView!
    @IBOutlet private weak var voiceBtn: UIButton!
    @IBOutlet private weak var roomIDLabel: UILabel!
    @IBOutlet private weak var idLabel: UILabel!
    @IBOutlet private weak var audioStatsLabel: UILabel!
    @IBOutlet private weak var videoStatsLabel: UILabel!
    @IBOutlet private weak var avRegionsView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        roomIDLabel.text = "房号: \(TTManager.roomID)"
        idLabel.text = "ID: \(TTManager.me.uid)"
        avRegions += avRegionsView.subviews.filter { $0 is TTTAVRegion } as! [TTTAVRegion]
        TTManager.rtcEngine.delegate = self
        TTManager.rtcEngine.startPreview()
        let videoCanvas = TTTRtcVideoCanvas()
        videoCanvas.uid = TTManager.me.uid
        videoCanvas.renderMode = .render_Adaptive
        videoCanvas.view = meImgView
        TTManager.rtcEngine.setupLocalVideo(videoCanvas)
    }

    @IBAction func leftBtnsAction(_ sender: UIButton) {
        switch sender.tag {
        case 1001:
            TTManager.rtcEngine.switchCamera()
        case 1002:
            sender.isSelected = !sender.isSelected
            TTManager.me.mutedSelf = sender.isSelected
            TTManager.rtcEngine.muteLocalAudioStream(sender.isSelected)
        default:
            print("")
        }
    }
    
    @IBAction func exitChannel(_ sender: Any) {
        let alert = UIAlertController(title: "提示", message: "你确定要退出房间吗？", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        let sureAction = UIAlertAction(title: "确定", style: .default) { (action) in
            TTManager.rtcEngine.leaveChannel(nil)
        }
        alert.addAction(sureAction)
        present(alert, animated: true, completion: nil)
    }
}

extension TTTVideoChatViewController: TTTRtcEngineDelegate {
    func rtcEngine(_ engine: TTTRtcEngineKit!, didJoinedOfUid uid: Int64, clientRole: TTTRtcClientRole, isVideoEnabled: Bool, elapsed: Int) {
        let user = TTTUser(uid)
        users.append(user)
        getAVRegion()?.configureRegion(user)
    }
    
    func rtcEngine(_ engine: TTTRtcEngineKit!, didOfflineOfUid uid: Int64, reason: TTTRtcUserOfflineReason) {
        guard let userInfo = getUser(uid) else { return }
        getAVRegion(uid)?.closeRegion()
        users.remove(at: userInfo.1)
    }
    
    func rtcEngine(_ engine: TTTRtcEngineKit!, reportAudioLevel userID: Int64, audioLevel: UInt, audioLevelFullRange: UInt) {
        if userID == TTManager.me.uid {
            voiceBtn.setImage(getVoiceImage(audioLevel), for: .normal)
        } else {
            getAVRegion(userID)?.reportAudioLevel(audioLevel)
        }
    }
    
    func rtcEngine(_ engine: TTTRtcEngineKit!, didAudioMuted muted: Bool, byUid uid: Int64) {
        guard let user = getUser(uid)?.0 else { return }
        user.mutedSelf = muted
        getAVRegion(uid)?.mutedSelf(muted)
    }
    
    func rtcEngine(_ engine: TTTRtcEngineKit!, localAudioStats stats: TTTRtcLocalAudioStats!) {
        audioStatsLabel.text = "A-↑\(stats.sentBitrate)kbps"
    }
    
    func rtcEngine(_ engine: TTTRtcEngineKit!, localVideoStats stats: TTTRtcLocalVideoStats!) {
        videoStatsLabel.text = "V-↑\(stats.sentBitrate)kbps"
    }
    
    func rtcEngine(_ engine: TTTRtcEngineKit!, remoteAudioStats stats: TTTRtcRemoteAudioStats!) {
        getAVRegion(stats.uid)?.setRemoterAudioStats(stats.receivedBitrate)
    }
    
    func rtcEngine(_ engine: TTTRtcEngineKit!, remoteVideoStats stats: TTTRtcRemoteVideoStats!) {
        getAVRegion(stats.uid)?.setRemoterVideoStats(stats.receivedBitrate)
    }
    
    func rtcEngine(_ engine: TTTRtcEngineKit!, firstRemoteVideoFrameDecodedOfUid uid: Int64, size: CGSize, elapsed: Int) {
        //解码远端用户第一帧
    }
    
    func rtcEngine(_ engine: TTTRtcEngineKit!, didLeaveChannelWith stats: TTTRtcStats!) {
        engine.stopPreview()
        dismiss(animated: true, completion: nil)
    }
    
    func rtcEngineConnectionDidLost(_ engine: TTTRtcEngineKit!) {
        TTProgressHud.showHud(view, message: "网络链接丢失，正在重连...", color: nil)
    }
    
    func rtcEngineReconnectServerTimeout(_ engine: TTTRtcEngineKit!) {
        TTProgressHud.hideHud(for: view)
        view.window?.showToast("网络丢失，请检查网络")
        engine.leaveChannel(nil)
        engine.stopPreview()
        dismiss(animated: true, completion: nil)
    }
    
    func rtcEngineReconnectServerSucceed(_ engine: TTTRtcEngineKit!) {
        TTProgressHud.hideHud(for: view)
    }
    
    func rtcEngine(_ engine: TTTRtcEngineKit!, didKickedOutOfUid uid: Int64, reason: TTTRtcKickedOutReason) {
        var errorInfo = ""
        switch reason {
        case .kickedOut_KickedByHost:
            errorInfo = "被主播踢出"
        case .kickedOut_PushRtmpFailed:
            errorInfo = "rtmp推流失败"
        case .kickedOut_MasterExit:
            errorInfo = "主播已退出"
        case .kickedOut_ReLogin:
            errorInfo = "重复登录"
        case .kickedOut_NoAudioData:
            errorInfo = "长时间没有上行音频数据"
        case .kickedOut_NoVideoData:
            errorInfo = "长时间没有上行视频数据"
        case .kickedOut_NewChairEnter:
            errorInfo = "其他人以主播身份进入"
        case .kickedOut_ChannelKeyExpired:
            errorInfo = "Channel Key失效"
        default:
            errorInfo = "未知错误"
        }
        view.window?.showToast(errorInfo)
    }
}

private extension TTTVideoChatViewController {
    func getAVRegion(_ uid: Int64? = nil) -> TTTAVRegion? {
        return avRegions.first { $0.user?.uid == uid }
    }
    
    func getUser(_ uid: Int64) -> (TTTUser, Int)? {
        if let index = users.index(where: { $0.uid == uid } ) {
            return (users[index], index)
        }
        return nil
    }
    
    func getVoiceImage(_ audioLevel: UInt) -> UIImage {
//        let speakerphone = routing != .audioOutput_Headset
        let speakerphone = true
        if TTManager.me.mutedSelf {
            return speakerphone ? #imageLiteral(resourceName: "voice_close") : #imageLiteral(resourceName: "tingtong_close")
        }
        var image: UIImage = #imageLiteral(resourceName: "voice_small")
        if audioLevel < 4 {
            image = speakerphone ? #imageLiteral(resourceName: "voice_small") : #imageLiteral(resourceName: "tingtong_small")
        } else if audioLevel < 7 {
            image = speakerphone ? #imageLiteral(resourceName: "voice_middle") : #imageLiteral(resourceName: "tingtong_middle")
        } else {
            image = speakerphone ? #imageLiteral(resourceName: "voice_big") : #imageLiteral(resourceName: "tingtong_big")
        }
        return image
    }
}
