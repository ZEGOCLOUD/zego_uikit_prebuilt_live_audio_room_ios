//
//  ZegoLiveAudioSeatItemView.swift
//  ZegoUIKitPrebuiltLiveAudio
//
//  Created by zego on 2022/11/18.
//

import UIKit
import ZegoUIKit

protocol ZegoLiveAudioSeatItemViewDelegate: AnyObject {
    func getSeatForegroundView(_ userInfo: ZegoUIKitUser?, seatIndex: Int) -> ZegoBaseAudioVideoForegroundView?
    func onSeatItemClick(_ seatModel: ZegoLiveAudioSeatModel?)
}

class ZegoLiveAudioSeatItemView: UIView {
    
    weak var delegate: ZegoLiveAudioSeatItemViewDelegate? {
        didSet {
            self.audioViewView.delegate = self
        }
    }
    
    var currentHost: ZegoUIKitUser? {
        didSet {
            
        }
    }
    
    var currentRole: ZegoLiveAudioRoomRole = .audience {
        didSet {
            
        }
    }
    
    var currUser: ZegoUIKitUser? {
        didSet {
            guard let _ = currUser?.userName else { return }
        }
    }
    
    var currSeatModel: ZegoLiveAudioSeatModel? {
        didSet {
            guard let model = currSeatModel else { return }
            if model.userID.count != 0 {
                self.audioViewView.userID = model.userID
                self.audioViewView.delegate = self
            }
            self.audioViewView.isHidden = model.userID.count == 0
            self.seatImageView.image = model.lock ? ZegoUIKitLiveAudioIconSetType.seat_icon_disabled.load() : ZegoUIKitLiveAudioIconSetType.seat_icon_normal.load()
        }
    }
    
    var seatConfig: ZegoLiveAudioRoomSeatConfig? {
        didSet {
            self.backgroundColor = seatConfig?.backgroundColor ?? UIColor.clear
            if let backgroundImage = seatConfig?.backgroundImage {
                self.audioViewView.audioViewBackgroundImage = backgroundImage
            }
            self.audioViewView.showVoiceWave = seatConfig?.showSoundWaveInAudioMode ?? true
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(self.seatImageView)
        self.addSubview(self.audioViewView)
        self.addSubview(self.seatButton)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupLayOut()
    }
    
    func setupLayOut() {
        self.seatButton.frame = CGRect(x: 0, y: 0, width: UIKitLiveAudioSeatHeight, height: UIKitLiveAudioSeatHeight)
        self.audioViewView.avatarSize = CGSize(width: UIKitLiveAudioSeatWidth, height: UIKitLiveAudioSeatWidth)
        self.audioViewView.frame = CGRect(x: 0, y: 0, width: UIKitLiveAudioSeatHeight, height: UIKitLiveAudioSeatHeight)
        let x: CGFloat = (self.frame.size.width - CGFloat(UIKitLiveAudioSeatWidth)) * 0.5
        self.seatImageView.frame = CGRect(x: x, y: 0, width: 54.0, height: 54.0)
    }
    
    lazy var seatButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.layer.cornerRadius = CGFloat(UIKitLiveAudioSeatWidth / 2)
        btn.layer.masksToBounds = true
        btn.addTarget(self, action: #selector(seatClickAction(_:)), for: .touchUpInside)
        return btn
    }()
    
    lazy var seatImageView: UIImageView = {
        let image = UIImageView.init(image: ZegoUIKitLiveAudioIconSetType.seat_icon_normal.load())
        image.layer.cornerRadius = CGFloat(UIKitLiveAudioSeatWidth / 2)
        image.layer.masksToBounds = true
        return image
    }()
    
    @objc func seatClickAction(_ sender: UIButton) {
        self.delegate?.onSeatItemClick(self.currSeatModel)
    }

    lazy var audioViewView: ZegoAudioVideoView = {
        let view = ZegoAudioVideoView()
        view.avatarAlignment = .start
        view.soundWaveColor = UIColor.init(red: 58/255.0, green: 85/255.0, blue: 251/255.0, alpha: 1.0)
        view.isHidden = true
        return view
    }()
}

extension ZegoLiveAudioSeatItemView: AudioVideoViewDelegate {
    func getForegroundView(_ userInfo: ZegoUIKitUser?) -> ZegoBaseAudioVideoForegroundView? {
        if userInfo?.userID == self.currSeatModel?.userID {
            self.currSeatModel?.userName = userInfo?.userName ?? ""
        }
        return self.delegate?.getSeatForegroundView(userInfo, seatIndex: self.currSeatModel?.index ?? 0)
    }
}
