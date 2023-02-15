//
//  ZegoUIKitPrebuiltLiveAudioRoomConfig.swift
//  ZegoUIKitPrebuiltLiveAudio
//
//  Created by zego on 2022/11/15.
//

import UIKit
import ZegoUIKitSDK

@objcMembers
public class ZegoUIKitPrebuiltLiveAudioRoomConfig: NSObject {
    
    public var role: ZegoLiveAudioRoomRole = .audience
    public var takeSeatIndexWhenJoining: Int = -1
    public var turnOnMicrophoneWhenJoining: Bool = false
    public var useSpeakerWhenJoining: Bool = true
    public var bottomMenuBarConfig: ZegoBottomMenuBarConfig = ZegoBottomMenuBarConfig(hostButtons: [ .showMemberListButton,.toggleMicrophoneButton], speakerButtons: [.showMemberListButton,.toggleMicrophoneButton], audienceButtons: [.showMemberListButton])
    
    public var confirmDialogInfo: ZegoLeaveConfirmDialogInfo?
    public var translationText: ZegoTranslationText = ZegoTranslationText()
    public var layoutConfig: ZegoLiveAudioRoomLayoutConfig = ZegoLiveAudioRoomLayoutConfig()
    public var seatConfig: ZegoLiveAudioRoomSeatConfig = ZegoLiveAudioRoomSeatConfig()
    public var hostSeatIndexes: [Int] = [0]
    
    public var userAvatarUrl: String?
    public var userInRoomAttributes:[String : String]?
    
    public static func host() -> ZegoUIKitPrebuiltLiveAudioRoomConfig {
        let config = ZegoUIKitPrebuiltLiveAudioRoomConfig()
        config.role = .host
        config.takeSeatIndexWhenJoining = 0
        config.turnOnMicrophoneWhenJoining = true
        
        let confirmDialogInfo = ZegoLeaveConfirmDialogInfo()
        confirmDialogInfo.title = "Leave the room"
        confirmDialogInfo.message = "Are you sure to leave the  room?"
        confirmDialogInfo.cancelButtonName = "Cancel"
        confirmDialogInfo.confirmButtonName = "OK"
        config.confirmDialogInfo = confirmDialogInfo
        
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
    
    override init() {
        super.init()
    }
    
    public convenience init(hostButtons: [ZegoMenuBarButtonName], speakerButtons: [ZegoMenuBarButtonName], audienceButtons: [ZegoMenuBarButtonName]) {
        self.init()
        self.hostButtons = hostButtons
        self.speakerButtons = speakerButtons
        self.audienceButtons = audienceButtons
    }
}


public class ZegoTranslationText: NSObject {
    
    public var removeSpeakerMenuDialogButton: String = "Remove %@ from seat"
    public var takeSeatMenuDialogButton: String = "Take the seat"
    public var leaveSeatMenuDialogButton: String = "Leave the seat"
    public var cancelMenuDialogButton: String = "Cancel"
    public var memberListTitle: String = "Audience"
    public var removeSpeakerFailedToast: String = "Failed to remove %@ from seat"
    public var microphonePermissionSettingDialogInfo: ZegoDialogInfo = ZegoDialogInfo.init("Can not use Microphone!", message: "Please enable microphone access in the system settings!", cancelButtonName: "Cancel", confirmButtonName: "Settings")
    public var leaveSeatDialogInfo: ZegoDialogInfo = ZegoDialogInfo.init("Leave the seat", message: "Are you sure to leave the seat?", cancelButtonName: "Cancel", confirmButtonName: "OK")
    public var removeSpeakerFromSeatDialogInfo: ZegoDialogInfo = ZegoDialogInfo.init("Remove the speaker", message: "Are you sure to remove %@ from the seat?", cancelButtonName: "Cancel", confirmButtonName: "OK")
}


public class ZegoDialogInfo: NSObject {
    public var title: String?
    public var message: String?
    public var cancelButtonName: String = "Cancel"
    public var confirmButtonName: String = "OK"
    
    public override init() {
        super.init()
    }
    
    public convenience init(_ title: String, message: String, cancelButtonName: String = "Cancel", confirmButtonName: String = "OK") {
        self.init()
        
        self.title = title
        self.message = message
        self.cancelButtonName = cancelButtonName
        self.confirmButtonName = confirmButtonName
    }
}
