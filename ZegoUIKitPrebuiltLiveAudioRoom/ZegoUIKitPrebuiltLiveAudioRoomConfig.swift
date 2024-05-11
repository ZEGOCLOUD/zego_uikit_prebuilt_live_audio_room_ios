//
//  ZegoUIKitPrebuiltLiveAudioRoomConfig.swift
//  ZegoUIKitPrebuiltLiveAudio
//
//  Created by zego on 2022/11/15.
//

import UIKit
import ZegoUIKit

@objc public enum ZegoLanguage : UInt32 {
  case english
  case chinese
}

@objcMembers
public class ZegoUIKitPrebuiltLiveAudioRoomConfig: NSObject {
    
    public var role: ZegoLiveAudioRoomRole = .audience
    public var takeSeatIndexWhenJoining: Int = -1
    public var turnOnMicrophoneWhenJoining: Bool = false
    public var useSpeakerWhenJoining: Bool = true
    public var bottomMenuBarConfig: ZegoBottomMenuBarConfig = ZegoBottomMenuBarConfig(hostButtons: [.showSpeakerButton, .showMemberListButton,.toggleMicrophoneButton], speakerButtons: [.showSpeakerButton,.showMemberListButton,.toggleMicrophoneButton], audienceButtons: [.showMemberListButton])
    
    public var translationText: ZegoTranslationText = ZegoTranslationText(language: .english)
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

public class ZegoLiveAudioRoomSeatConfig: NSObject {
    public var showSoundWaveInAudioMode: Bool = true
    public var backgroudColor: UIColor?
    public var backgroundImage: UIImage?
}

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

public class ZegoBottomMenuBarConfig: NSObject {
    
    public var showInRoomMessageButton: Bool = true
    public var hostButtons: [ZegoMenuBarButtonName] = []
    public var speakerButtons: [ZegoMenuBarButtonName] = []
    public var audienceButtons: [ZegoMenuBarButtonName] = []
    
    public var maxCount: UInt = 5
    
    public convenience init(hostButtons: [ZegoMenuBarButtonName], speakerButtons: [ZegoMenuBarButtonName], audienceButtons: [ZegoMenuBarButtonName]) {
        self.init()
        self.hostButtons = hostButtons
        self.speakerButtons = speakerButtons
        self.audienceButtons = audienceButtons
    }
}


public class ZegoTranslationText: NSObject {
    
    var language :ZegoLanguage  = .english
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
  
    public init(language:ZegoLanguage) {
      super.init()
      self.language = language
      if language == .chinese {
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
      }
    }

  
    public func getLanguage() -> ZegoLanguage {
      return self.language
    }
}

public class ZegoDialogInfo: NSObject {
  
    public var title: String?
    public var message: String?
    public var cancelButtonName:String?
    public var confirmButtonName:String?
    public var translationText: ZegoTranslationText = ZegoTranslationText(language: .english)
    private override init() {
        super.init()
    }
    
    public convenience init(_ title: String, message: String, cancelButtonName: String?, confirmButtonName: String?,language: ZegoLanguage) {
        self.init()
        if language == .chinese {
          translationText = ZegoTranslationText(language: .chinese)
        }
        self.title = title
        self.message = message
        self.cancelButtonName = cancelButtonName ?? translationText.cancelMenuDialogButton
        self.confirmButtonName = confirmButtonName ?? translationText.leaveRoomDialogConfirmButtonTitle
    }
}
