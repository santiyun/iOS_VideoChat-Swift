//
//  TTTSettingViewController.swift
//  TTTVideoChat
//
//  Created by yanzhen on 2018/9/11.
//  Copyright © 2018年 yanzhen. All rights reserved.
//

import UIKit
import TTTRtcEngineKit

private extension TTTRtcVideoProfile {
    func getBitRate() -> String {
        switch self {
        case ._VideoProfile_120P:
            return "65"
        case ._VideoProfile_180P:
            return "140"
        case ._VideoProfile_240P:
            return "200"
        case ._VideoProfile_480P:
            return "500"
        case ._VideoProfile_720P:
            return "1130"
        case ._VideoProfile_1080P:
            return "2080"
        default:
            return "400"
        }
    }
    
    func getSizeString() -> String {
        switch self {
        case ._VideoProfile_120P:
            return "160X120"
        case ._VideoProfile_180P:
            return "320X180"
        case ._VideoProfile_240P:
            return "320x240"
        case ._VideoProfile_480P:
            return "640x480"
        case ._VideoProfile_720P:
            return "1280x720"
        case ._VideoProfile_1080P:
            return "1920x1080"
        default:
            return "640x360"
        }
    }
}

class TTTSettingViewController: UIViewController {

    @IBOutlet private weak var videoTitleTF: UITextField!
    @IBOutlet private weak var videoSizeTF: UITextField!
    @IBOutlet private weak var videoBitrateTF: UITextField!
    @IBOutlet private weak var videoFpsTF: UITextField!
    @IBOutlet private weak var audioSwitch: UISwitch!
    @IBOutlet private weak var pickBGView: UIView!
    @IBOutlet private weak var pickView: UIPickerView!
    private let videoSizes = ["120P", "180P", "240P", "360P", "480P", "720P", "1080P", "自定义"]
    override func viewDidLoad() {
        super.viewDidLoad()
    
        audioSwitch.isOn = TTManager.isHighQualityAudio
        let isCustom = TTManager.videoCustomProfile.isCustom
        refreshState(isCustom, profile: TTManager.videoProfile)
        if isCustom {
            pickView.selectRow(7, inComponent: 0, animated: true)
            let custom = TTManager.videoCustomProfile
            videoSizeTF.text = "\(Int(custom.videoSize.width))x\(Int(custom.videoSize.height))"
            videoBitrateTF.text = custom.bitrate.description
            videoFpsTF.text = custom.fps.description
        } else {
            pickView.selectRow(Int(TTManager.videoProfile.rawValue / 10), inComponent: 0, animated: true)
        }
    }
    
    private func refreshState(_ isCustom: Bool, profile: TTTRtcVideoProfile) {
        if isCustom {
            videoTitleTF.text = "自定义"
            videoSizeTF.isEnabled = true
            videoBitrateTF.isEnabled = true
            videoFpsTF.isEnabled = true
        } else {
            let index = profile.rawValue / 10
            videoTitleTF.text = videoSizes[Int(index)]
            videoSizeTF.isEnabled = false
            videoBitrateTF.isEnabled = false
            videoFpsTF.isEnabled = false
            videoSizeTF.text = profile.getSizeString()
            videoBitrateTF.text = profile.getBitRate()
        }
    }
    
    @IBAction private func saveSettingAction(_ sender: Any) {
        if videoTitleTF.text == "自定义" {
            //videoSize必须以x分开两个数值
            if videoSizeTF.text == nil || videoSizeTF.text?.count == 0 {
                showToast("请输入正确的视频尺寸")
                return
            }
            
            let sizes = videoSizeTF.text?.components(separatedBy: "x")
            if sizes?.count != 2 {
                showToast("请输入正确的视频尺寸")
                return
            }
            
            guard let sizeW = Int(sizes![0]), let sizeH = Int(sizes![1]) else {
                showToast("请输入正确的视频尺寸")
                return
            }
            
            guard let bitrate = Int(videoBitrateTF.text!) else {
                showToast("请输入正确的码率")
                return
            }
            
            guard let fps = Int(videoFpsTF.text!) else {
                showToast("请输入正确的帧率")
                return
            }
            
            TTManager.videoCustomProfile = (true,CGSize(width: sizeW, height: sizeH),bitrate,fps)
        } else {
            TTManager.videoCustomProfile.isCustom = false
            let index = pickView.selectedRow(inComponent: 0)
            TTManager.videoProfile = TTTRtcVideoProfile(rawValue: UInt(index * 10))!
        }
        TTManager.isHighQualityAudio = audioSwitch.isOn
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func showMoreVideoPara(_ sender: UIButton) {
        pickBGView.isHidden = false
    }
    
    @IBAction private func back(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction private func cancelSetting(_ sender: Any) {
        pickBGView.isHidden = true
    }
    
    @IBAction private func sureSetting(_ sender: Any) {
        pickBGView.isHidden = true
        let index = pickView.selectedRow(inComponent: 0)
        let profile: TTTRtcVideoProfile = TTTRtcVideoProfile(rawValue: UInt(index * 10))!
        refreshState(index == 7, profile: profile)
        videoTitleTF.text = videoSizes[index]
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}

extension TTTSettingViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1;
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return videoSizes.count;
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return videoSizes[row]
    }
}
