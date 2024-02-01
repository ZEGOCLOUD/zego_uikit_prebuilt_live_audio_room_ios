//
//  LiveAudioRoomVCApi.swift
//  ZegoUIKitPrebuiltLiveAudioRoom
//
//  Created by zego on 2024/1/18.
//

import Foundation

public protocol LiveAudioRoomVCApi {
    func addButtonToMenuBar(_ button: UIButton, role: ZegoLiveAudioRoomRole)
    func clearBottomBarExtendButtons(_ role: ZegoLiveAudioRoomRole) 
    func setBackgroundView(_ view: UIView)
}
