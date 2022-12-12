//
//  ZegoLiveAudioRoomBottomBar.swift
//  ZegoUIKitPrebuiltLiveAudio
//
//  Created by zego on 2022/11/15.
//

import UIKit
import ZegoUIKitSDK

protocol ZegoLiveAudioRoomBottomBarDelegate: AnyObject {
    func onMenuBarMoreButtonClick(_ buttonList: [UIView])
    func onInRoomMessageButtonClick()
    func onLeaveButtonClick(_ isLeave: Bool)
}

extension ZegoLiveAudioRoomBottomBarDelegate {
    func onMenuBarMoreButtonClick(_ buttonList: [UIView]) { }
    func onInRoomMessageButtonClick() { }
    func onLeaveButtonClick(_ isLeave: Bool){ }
}

class ZegoLiveAudioRoomBottomBar: UIView {

    var userID: String?
    var config: ZegoUIKitPrebuiltLiveAudioRoomConfig = ZegoUIKitPrebuiltLiveAudioRoomConfig.audience() {
        didSet {
            self.messageButton.isHidden = !config.bottomMenuBarConfig.showInRoomMessageButton
            self.barButtons = config.role == .host ? config.bottomMenuBarConfig.hostButtons : (config.role == .audience ? config.bottomMenuBarConfig.audienceButtons : config.bottomMenuBarConfig.speakerButtons)
        }
    }
    
    var currentHost: ZegoUIKitUser? {
        didSet {
            for button in self.buttons {
                if button.isKind(of: ZegoMemberButton.self) {
                    let memberBtn: ZegoMemberButton = button as! ZegoMemberButton
                    memberBtn.currentHost = self.currentHost
                }
            }
        }
    }
    
    var curRole: ZegoLiveAudioRoomRole = .audience {
        didSet {
            self.messageButton.isHidden = !config.bottomMenuBarConfig.showInRoomMessageButton
            self.barButtons = curRole == .host ? config.bottomMenuBarConfig.hostButtons : (curRole == .audience ? config.bottomMenuBarConfig.audienceButtons : config.bottomMenuBarConfig.speakerButtons)
        }
    }
    
    weak var delegate: ZegoLiveAudioRoomBottomBarDelegate?
    weak var controller: UIViewController?
    weak var showQuitDialogVC: UIViewController?
    
    private var buttons: [UIView] = []
    private var moreButtonList: [UIView] = []
    private var hostExtendButtons: [UIButton] = []
    private var speakerExtendButtons: [UIButton] = []
    private var audienceExtendButtons: [UIButton] = []
    
    var barButtons:[ZegoMenuBarButtonName] = [] {
        didSet {
            self.removeAllButton()
            self.moreButtonList.removeAll()
            self.createButton()
            self.setupLayout()
        }
    }
    private let margin: CGFloat = UIkitLiveAudioAdaptLandscapeWidth(16)
    private let itemSpace: CGFloat = UIkitLiveAudioAdaptLandscapeWidth(8)
    
    private lazy var messageButton: ZegoInRoomMessageButton = {
        let button = ZegoInRoomMessageButton()
        button.delegate = self
        button.layer.masksToBounds = true
        button.layer.cornerRadius = itemSize.width * 0.5
        return button
    }()
    
    let itemSize: CGSize = CGSize.init(width: UIkitLiveAudioAdaptLandscapeWidth(36), height: UIkitLiveAudioAdaptLandscapeWidth(36))
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        self.addSubview(self.messageButton)
        self.createButton()
        self.setupLayout()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        self.setupLayout()
    }
    
    /// - Parameter button: button description
    public func addButtonToMenuBar(_ button: UIButton, role: ZegoLiveAudioRoomRole) {
        if role == .host {
            self.hostExtendButtons.append(button)
        } else if role == .speaker {
            self.speakerExtendButtons.append(button)
        } else if role == .audience {
            self.audienceExtendButtons.append(button)
        }
        
        if role == self.config.role {
            if self.buttons.count > self.config.bottomMenuBarConfig.maxCount - 1 {
                if self.buttons.first is ZegoMoreButton {
                    self.moreButtonList.append(button)
                    return
                }
                //替换最后一个元素
                let moreButton: ZegoMoreButton = ZegoMoreButton()
                moreButton.addTarget(self, action: #selector(moreClick), for: .touchUpInside)
                self.addSubview(moreButton)
                let lastButton: UIButton = self.buttons.last as! UIButton
                lastButton.removeFromSuperview()
                self.moreButtonList.append(lastButton)
                self.moreButtonList.append(button)
                self.buttons.insert(moreButton, at: 0)
    //            self.buttons.replaceSubrange(4...4, with: [moreButton])
            } else {
                self.buttons.append(button)
                self.addSubview(button)
            }
            self.setupLayout()
        }
    }
    
    func clearBottomBarExtendButtons(_ role: ZegoLiveAudioRoomRole) {
        switch role {
        case .host:
            self.hostExtendButtons.removeAll()
        case .speaker:
            self.speakerExtendButtons.removeAll()
        case .audience:
            self.audienceExtendButtons.removeAll()
        }
    }
    
    
    //MARK: -private
    private func setupLayout() {
        self.messageButton.frame = CGRect(x: self.margin, y: UIkitLiveAudioAdaptLandscapeHeight(10), width: itemSize.width, height: itemSize.height)
        switch self.buttons.count {
        case 1:
            self.layoutViewWithButton()
        case 2:
            self.layoutViewWithButton()
            break
        case 3:
            self.layoutViewWithButton()
            break
        case 4:
            self.layoutViewWithButton()
            break
        case 5:
            self.layoutViewWithButton()
        default:
            break
        }
    }
    
    private func replayAddAllView() {
        for view in self.subviews {
            view.removeFromSuperview()
        }
        for item in self.buttons {
            self.addSubview(item)
        }
    }
    
    private func removeAllButton() {
        for button in self.buttons {
            button.removeFromSuperview()
        }
    }
    
    private func layoutViewWithButton() {
        var index: Int = 0
        var lastView: UIView?
        for button in self.buttons {
            if index == 0 {
                button.frame = CGRect.init(x: self.frame.size.width - self.margin - itemSize.width, y: UIkitLiveAudioAdaptLandscapeHeight(10), width: itemSize.width, height: itemSize.height)
            } else {
                if let lastView = lastView {
                    button.frame = CGRect.init(x: lastView.frame.minX - itemSpace - itemSize.width, y: lastView.frame.minY, width: itemSize.width, height: itemSize.height)
                }
            }
            lastView = button
            index = index + 1
        }
    }
    
    private func createButton() {
        self.buttons.removeAll()
        var index = 0
        for item in self.barButtons {
            index = index + 1
            if self.config.bottomMenuBarConfig.maxCount < self.barButtons.count && index == self.config.bottomMenuBarConfig.maxCount {
                //显示更多按钮
                let moreButton: ZegoMoreButton = ZegoMoreButton()
                moreButton.addTarget(self, action: #selector(moreClick), for: .touchUpInside)
                self.buttons.insert(moreButton, at: 0)
                self.addSubview(moreButton)
            }
            switch item {
            case .toggleMicrophoneButton:
                let micButtonComponent: ZegoToggleMicrophoneButton = ZegoToggleMicrophoneButton()
                micButtonComponent.userID = ZegoUIKit.shared.localUserInfo?.userID
                micButtonComponent.isOn = self.config.turnOnMicrophoneWhenJoining
                micButtonComponent.layer.masksToBounds = true
                micButtonComponent.layer.cornerRadius = itemSize.width * 0.5
                micButtonComponent.backgroundColor = UIColor.colorWithHexString("#FFFFFF")
                micButtonComponent.iconMicrophoneOn = ZegoUIKitLiveAudioIconSetType.bottom_mic_on.load()
                micButtonComponent.iconMicrophoneOff = ZegoUIKitLiveAudioIconSetType.bottom_mic_off.load()
                
                if self.config.bottomMenuBarConfig.maxCount < self.barButtons.count && index >= self.config.bottomMenuBarConfig.maxCount {
                    self.moreButtonList.append(micButtonComponent)
                } else {
                    self.buttons.append(micButtonComponent)
                    self.addSubview(micButtonComponent)
                }
            case .showMemberListButton:
                let memberButton: ZegoMemberButton = ZegoMemberButton()
                memberButton.layer.masksToBounds = true
                memberButton.layer.cornerRadius = itemSize.width * 0.5
                memberButton.controller = controller
                memberButton.currentHost = self.currentHost
                memberButton.config = config
                if self.config.bottomMenuBarConfig.maxCount < self.barButtons.count && index >= self.config.bottomMenuBarConfig.maxCount {
                    self.moreButtonList.append(memberButton)
                } else {
                    self.buttons.append(memberButton)
                    self.addSubview(memberButton)
                }
            case .leaveButton:
                let leaveButtonComponent: ZegoLeaveButton = ZegoLeaveButton()
                leaveButtonComponent.delegate = self
                leaveButtonComponent.quitConfirmDialogInfo = self.config.confirmDialogInfo ?? ZegoLeaveConfirmDialogInfo()
                leaveButtonComponent.iconLeave = ZegoUIKitLiveAudioIconSetType.top_close.load()
                if self.config.bottomMenuBarConfig.maxCount < self.barButtons.count && index >= self.config.bottomMenuBarConfig.maxCount {
                    self.moreButtonList.append(leaveButtonComponent)
                } else {
                    self.buttons.append(leaveButtonComponent)
                    self.addSubview(leaveButtonComponent)
                }
            }
        }
        self.createExtendButton()
    }
    
    private func createExtendButton() {
        var extendButtons: [UIButton] = []
        switch self.config.role {
        case .host:
            extendButtons = self.hostExtendButtons
        case .speaker:
            extendButtons = self.speakerExtendButtons
        case .audience:
            extendButtons = self.audienceExtendButtons
        }
        var index = 0
        for button in extendButtons {
            index = index + 1
            if self.config.bottomMenuBarConfig.maxCount < (self.barButtons.count + extendButtons.count) && index == (Int(self.config.bottomMenuBarConfig.maxCount) - self.barButtons.count) {
                //显示更多按钮
                let moreButton: ZegoMoreButton = ZegoMoreButton()
                moreButton.addTarget(self, action: #selector(moreClick), for: .touchUpInside)
                self.buttons.insert(moreButton, at: 0)
                self.addSubview(moreButton)
            }
            if self.config.bottomMenuBarConfig.maxCount < (self.barButtons.count + extendButtons.count) && index >= (Int(self.config.bottomMenuBarConfig.maxCount) - self.barButtons.count) {
                self.moreButtonList.append(button)
            } else {
                self.buttons.append(button)
                self.addSubview(button)
            }
        }
    }
    
    @objc func moreClick() {
        //更多按钮点击事件
        self.delegate?.onMenuBarMoreButtonClick(self.moreButtonList)
    }

}

class ZegoMoreButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setImage(ZegoUIKitLiveAudioIconSetType.icon_more.load(), for: .normal)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ZegoLiveAudioRoomBottomBar: ZegoInRoomMessageButtonDelegate, LeaveButtonDelegate {
    func inRoomMessageButtonDidClick() {
        self.delegate?.onInRoomMessageButtonClick()
    }
    
    func onLeaveButtonClick(_ isLeave: Bool) {
        if isLeave {
            self.showQuitDialogVC?.dismiss(animated: true, completion: nil)
        }
        self.delegate?.onLeaveButtonClick(isLeave)
    }
    
}
