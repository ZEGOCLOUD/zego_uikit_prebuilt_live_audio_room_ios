//
//  ZegoUIKitPrebuiltLiveAudioRoomVCDelegate.swift
//  ZegoUIKitPrebuiltLiveAudioRoom
//
//  Created by zego on 2024/1/18.
//

import Foundation
import ZegoUIKit

@objc public protocol ZegoUIKitPrebuiltLiveAudioRoomVCDelegate: AnyObject {
    @objc optional func getSeatForegroundView(_ userInfo: ZegoUIKitUser?, seatIndex: Int) -> ZegoBaseAudioVideoForegroundView?
    @objc optional func onLeaveLiveAudioRoom()
    @objc optional func onUserCountOrPropertyChanged(_ users: [ZegoUIKitUser]?)
}
