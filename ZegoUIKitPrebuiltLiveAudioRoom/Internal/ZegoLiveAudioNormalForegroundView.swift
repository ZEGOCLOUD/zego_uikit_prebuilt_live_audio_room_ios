//
//  ZegoLiveNormalForegroundView.swift
//  ZegoUIKitPrebuiltLiveAudio
//
//  Created by zego on 2022/11/18.
//

import UIKit
import ZegoUIKit

class ZegoLiveAudioNormalForegroundView: ZegoBaseAudioVideoForegroundView {
    
    lazy var hostIcon: UIImageView = {
        let imageView = UIImageView.init(image: ZegoUIKitLiveAudioIconSetType.seat_host_icon.load())
        return imageView
    }()
    
    var isHost: Bool = false {
        didSet {
            self.hostIcon.isHidden = !isHost
        }
    }
    
    lazy var userNameLabel: UILabel = {
        let label: UILabel = UILabel()
        label.textColor = UIColor.colorWithHexString("#000000")
        label.font = UIFont.systemFont(ofSize: 10, weight: .medium)
        label.numberOfLines = 1
        label.textAlignment = .center
        return label
    }()
    
    lazy var foregroundImageView: UIImageView = {
        let view: UIImageView = UIImageView(image: ZegoUIKitLiveAudioIconSetType.close_mic.load())
        view.isHidden = true
        return view
    }()
    
    var userInfo: ZegoUIKitUser? {
        didSet {
            guard let  userInfo = userInfo else {
                return
            }
            self.userNameLabel.text = userInfo.userName
            self.foregroundImageView.isHidden = ZegoUIKit.shared.isMicrophoneOn(userInfo.userID ?? "")
            self.setupLayOut()
        }
    }
    
    override init(frame: CGRect, userID: String?, delegate: ZegoBaseAudioVideoForegroundViewDelegate?) {
        super.init(frame: frame, userID: userID, delegate: delegate)
        self.addSubview(self.foregroundImageView)
        self.hostIcon.isHidden = true
        self.addSubview(self.hostIcon)
        self.addSubview(self.userNameLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.setupLayOut()
    }
    
    func setupLayOut() {
        let  height: CGFloat = 12
        let  width: CGFloat = self.frame.width - 2*18
        let x: CGFloat = (self.frame.size.width - UIKitLiveAudioSeatWidth) * 0.5
        self.foregroundImageView.frame = CGRect(x: x, y: (self.frame.size.height - UIKitLiveAudioSeatHeight) * 0.5, width: 54.0, height: 54.0)
        self.hostIcon.frame = CGRect(x: 18, y: foregroundImageView.frame.maxY -  height + 2 , width: width, height: height)
        self.userNameLabel.sizeToFit()
        self.userNameLabel.frame = CGRect(x: 5, y: self.hostIcon.frame.maxY + 2, width: self.frame.size.width - 10, height: self.userNameLabel.bounds.height)
    }
    
    override func onMicrophoneOn(_ user: ZegoUIKitUser, isOn: Bool) {
        if user.userID == self.userInfo?.userID {
            self.foregroundImageView.isHidden = isOn
        }
    }
}
