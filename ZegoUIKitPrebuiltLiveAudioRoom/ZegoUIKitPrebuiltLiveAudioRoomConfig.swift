//
//  ZegoUIKitPrebuiltLiveAudioRoomConfig.swift
//  ZegoUIKitPrebuiltLiveAudio
//
//  Created by zego on 2022/11/15.
//

import UIKit
import ZegoUIKit

@objcMembers
public class ZegoUIKitPrebuiltLiveAudioRoomConfig: NSObject {
    
    public var role: ZegoLiveAudioRoomRole = .audience
    public var takeSeatIndexWhenJoining: Int = -1
    public var turnOnMicrophoneWhenJoining: Bool = false
    public var useSpeakerWhenJoining: Bool = true
    public var bottomMenuBarConfig: ZegoBottomMenuBarConfig = ZegoBottomMenuBarConfig(hostButtons: [.closeSeatButton,.showSpeakerButton, .showMemberListButton,.toggleMicrophoneButton], speakerButtons: [.showSpeakerButton,.showMemberListButton,.toggleMicrophoneButton], audienceButtons: [.showMemberListButton])
    // 如果进房时发现房间属性有“lockseat”这个key，则不处理
    // 主播是否进房时就调用closeSeats方法
    public var closeSeatsWhenJoin = true
    public var translationText: ZegoTranslationText = ZegoTranslationText(language: .ENGLISH)
    public var layoutConfig: ZegoLiveAudioRoomLayoutConfig = ZegoLiveAudioRoomLayoutConfig()
    public var seatConfig: ZegoLiveAudioRoomSeatConfig = ZegoLiveAudioRoomSeatConfig()
    public var hostSeatIndexes: [Int] = [0]
    
    public var userAvatarUrl: String?
    public var userInRoomAttributes:[String : String]?
 
    public lazy var confirmDialogInfo: ZegoLeaveConfirmDialogInfo? = {
      let confirmDialogInfo = ZegoLeaveConfirmDialogInfo()
      confirmDialogInfo.title = self.translationText.leaveConfirmDialogTitle
      confirmDialogInfo.message = self.translationText.leaveConfirmDialogMessage
      confirmDialogInfo.cancelButtonName = self.translationText.cancelMenuDialogButton
      confirmDialogInfo.confirmButtonName = self.translationText.leaveRoomDialogConfirmButtonTitle
      if self.role == .host {
        return confirmDialogInfo
      } else {
        return nil
      }
    }()
    
    public static func host() -> ZegoUIKitPrebuiltLiveAudioRoomConfig {
        let config = ZegoUIKitPrebuiltLiveAudioRoomConfig()
        config.role = .host
        config.takeSeatIndexWhenJoining = 0
        config.turnOnMicrophoneWhenJoining = true
        config.closeSeatsWhenJoin = true
//        let confirmDialogInfo = ZegoLeaveConfirmDialogInfo()
//        confirmDialogInfo.title = self.translationText.leaveConfirmDialogTitle
//        confirmDialogInfo.message = self.translationText.leaveConfirmDialogMessage
//        confirmDialogInfo.cancelButtonName = self.translationText.cancelMenuDialogButton
//        confirmDialogInfo.confirmButtonName = self.translationText.leaveRoomDialogConfirmButtonTitle
//        config.confirmDialogInfo = confirmDialogInfo
        
        return config
    }
    
    public static func audience() -> ZegoUIKitPrebuiltLiveAudioRoomConfig {
        let config = ZegoUIKitPrebuiltLiveAudioRoomConfig()
        config.role = .audience
        return config
    }

}
@objcMembers
public class ZegoLiveAudioRoomSeatConfig: NSObject {
   public var showSoundWaveInAudioMode: Bool = true
   public var backgroundColor: UIColor?
   public var backgroundImage: UIImage?
}

@objcMembers
public class ZegoLiveAudioRoomLayoutConfig: NSObject {
   public var rowConfigs: [ZegoLiveAudioRoomLayoutRowConfig] = []
   public var rowSpecing: Int = 0
    
   public override init() {
        super.init()
        let firstConfigs = ZegoLiveAudioRoomLayoutRowConfig()
        firstConfigs.count = 4
        firstConfigs.alignment = .center
        let secondConfig = ZegoLiveAudioRoomLayoutRowConfig()
        secondConfig.count = 4
        secondConfig.alignment = .center
        rowConfigs = [firstConfigs, secondConfig]
    }
}

@objcMembers
public class ZegoLiveAudioRoomLayoutRowConfig: NSObject {
    
   public var count: Int = 0 {
        didSet {
            if count > 4 {
                count = 4
            }
        }
    }
   public var seatSpacing: Int = 0
   public var alignment: ZegoLiveAudioRoomLayoutAlignment = .center
}

@objcMembers
public class ZegoBottomMenuBarConfig: NSObject {
    public var maxCount: UInt = 5
    public var showInRoomMessageButton: Bool = true
    //MARK: The following properties are provided solely by Swift
    public var hostButtons: [ZegoMenuBarButtonName] = []
    public var speakerButtons: [ZegoMenuBarButtonName] = []
    public var audienceButtons: [ZegoMenuBarButtonName] = []
    
    //MARK: swift func
    public convenience init(hostButtons: [ZegoMenuBarButtonName], speakerButtons: [ZegoMenuBarButtonName], audienceButtons: [ZegoMenuBarButtonName]) {
        self.init()
        self.hostButtons = hostButtons
        self.speakerButtons = speakerButtons
        self.audienceButtons = audienceButtons
    }
  
    //MARK: The following properties are provided solely by OC
    public var hostButtonsOC: NSArray {
        get {
            return hostButtons.map { NSNumber(value: $0.rawValue) } as NSArray
        }
        set {
          hostButtons = newValue.compactMap { ZegoMenuBarButtonName(rawValue: ($0 as AnyObject).intValue) }
        }
    }
    
    public var speakerButtonsOC: NSArray {
        get {
            return speakerButtons.map { NSNumber(value: $0.rawValue) } as NSArray
        }
        set {
          speakerButtons = newValue.compactMap { ZegoMenuBarButtonName(rawValue: ($0 as AnyObject).intValue) }
        }
    }
    
    public var audienceButtonsOC: NSArray {
        get {
            return audienceButtons.map { NSNumber(value: $0.rawValue) } as NSArray
        }
        set {
          audienceButtons = newValue.compactMap { ZegoMenuBarButtonName(rawValue: ($0 as AnyObject).intValue) }
        }
    }
  
    //MARK: OC func
    public convenience init(hostButtons: NSArray, speakerButtons: NSArray, audienceButtons: NSArray) {
        self.init()
        self.hostButtonsOC = hostButtons
        self.speakerButtonsOC = speakerButtons
        self.audienceButtonsOC = speakerButtons
    }
}

@objcMembers
public class ZegoTranslationText: NSObject {
    
    var language :ZegoUIKitLanguage  = .ENGLISH
    public var removeSpeakerMenuDialogButton : String = "Remove %@ from seat"
    public var takeSeatMenuDialogButton : String = "Take the seat"
    public var leaveSeatMenuDialogButton : String = "Leave the seat"
    public var cancelMenuDialogButton : String = "Cancel"
    public var memberListTitle : String = "Audience"
    public var removeSpeakerFailedToast : String = "Failed to remove %@ from seat"
  
    public var microphonePermissionTitle : String = "Can not use Microphone!"
    public var microphonePermissionMessage : String = "Please enable microphone access in the system settings!"
    public var microphonePermissionConfirmButtonName : String = "Settings"
    
    public var leaveSeatDialogInfoMessage : String = "Are you sure to leave the seat?"
    
    public var removeSpeakerFromSeatDialogInfoTitle : String = "Remove the speaker"
    public var removeSpeakerFromSeatDialogInfoMessage : String = "Are you sure to remove %@ from the seat?"

  
    public var leaveConfirmDialogMessage : String = "Are you sure to leave the room?"
    public var leaveConfirmDialogTitle : String = "Leave the room"
  
    public var leaveRoomDialogConfirmButtonTitle : String = "OK"
  
    public var audioMemberListUserIdentifyHost : String = "(Host)"
    public var audioMemberListUserIdentifyYourHost : String = "(You,Host)"
    public var audioMemberListUserIdentifyYourSpeaker : String = "(You,Speaker)"
    public var audioMemberListUserIdentifySpeaker : String = "(Speaker)"
    public var audioMemberListUserIdentifyYou : String = "(You)"
  
    public var requestCoHostButton: String = "Apply to co-host"
    public var cancelRequestCoHostButton: String = "Cancel the application"
  
    public var receivedCoHostInvitationDialogInfoConfirm: String = "Agree"
    public var receivedCoHostInvitationDialogInfoCancel: String = "Disagree"
  
    public var receivedCoHostInvitationDialogInfoTitle: String = "Invitation"
    public var receivedCoHostInvitationDialogInfoMessage: String = "The host is inviting you to co-host."
    public var audienceRejectInvitationToast: String = "refused to be a co-host."
    public var hostRejectCoHostRequestToast: String = "Your request to co-host with the host has been refused."
    public var inviteCoHostButton: String = "Invite %@ to co-host"
    public var repeatInviteCoHostFailedToast:String = "You've sent the co-host invitation, please wait for confirmation."
    public var inviteCoHostFailedToast: String = "Failed to connect with the co-host，please try again."
    public var muteSpeakerMicDialogButton: String = "Sound off %@"
   @objc public init(language:ZegoUIKitLanguage) {
      super.init()
      self.language = language
      if language == .CHS {
        removeSpeakerMenuDialogButton = "将 %@ 移下麦位"
        takeSeatMenuDialogButton = "上麦"
        leaveSeatMenuDialogButton = "下麦"
        cancelMenuDialogButton = "取消"
        memberListTitle = "观众"
        removeSpeakerFailedToast = "无法将 %@ 移下麦位"

        leaveConfirmDialogMessage = "您确定要离开房间吗？"
        leaveConfirmDialogTitle = "离开房间"
        leaveRoomDialogConfirmButtonTitle = "确定"
        
        microphonePermissionTitle = "无法使用麦克风！"
        microphonePermissionMessage = "请在系统设置中启用麦克风访问！"
        microphonePermissionConfirmButtonName = "设置"
        
        leaveSeatDialogInfoMessage = "您确定要下麦吗？"
        
        removeSpeakerFromSeatDialogInfoTitle = "从麦位上移除"
        removeSpeakerFromSeatDialogInfoMessage = "您确定要将 %@ 从麦位上移除吗？"
      
        audioMemberListUserIdentifyHost = "(房主)"
        audioMemberListUserIdentifyYourHost = "(我,房主)"
        audioMemberListUserIdentifyYourSpeaker = "(我,连麦中)"
        audioMemberListUserIdentifySpeaker = "(连麦中)"
        audioMemberListUserIdentifyYou = "(您)"
        requestCoHostButton = "申请连麦"
        cancelRequestCoHostButton = "取消申请"
        
        receivedCoHostInvitationDialogInfoTitle = "邀请"
        receivedCoHostInvitationDialogInfoMessage = "房主邀请您上麦"
        receivedCoHostInvitationDialogInfoConfirm = "同意"
        receivedCoHostInvitationDialogInfoCancel = "不同意"
        audienceRejectInvitationToast = "拒绝连麦。"
        hostRejectCoHostRequestToast = "您的连麦申请已被拒绝。"
        inviteCoHostButton = "邀请 %@ 连麦"
        repeatInviteCoHostFailedToast = "您已发送连麦邀请，请等待确认。"
        inviteCoHostFailedToast = "连麦失败，请重试。"
        muteSpeakerMicDialogButton = "静音 %@"
      }
    }

  
    public func getLanguage() -> ZegoUIKitLanguage {
      return self.language
    }
}

@objcMembers
public class ZegoDialogInfo: NSObject {
  
    public var title: String?
    public var message: String?
    public var cancelButtonName:String?
    public var confirmButtonName:String?
    var translationText: ZegoTranslationText = ZegoTranslationText(language: .ENGLISH)
    private override init() {
        super.init()
    }
    
    public convenience init(_ title: String, message: String, cancelButtonName: String?, confirmButtonName: String?,language: ZegoUIKitLanguage) {
        self.init()
        if language == .CHS {
          translationText = ZegoTranslationText(language: .CHS)
        }
        self.title = title
        self.message = message
        self.cancelButtonName = cancelButtonName ?? translationText.cancelMenuDialogButton
        self.confirmButtonName = confirmButtonName ?? translationText.leaveRoomDialogConfirmButtonTitle
    }
}
