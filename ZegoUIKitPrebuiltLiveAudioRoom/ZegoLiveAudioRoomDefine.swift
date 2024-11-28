//
//  ZegoLiveAudioDefine.swift
//  ZegoUIKitPrebuiltLiveAudio
//
//  Created by zego on 2022/11/15.
//

import Foundation
import UIKit

//MARK: -Internal
let UIKitLiveAudioScreenHeight = UIScreen.main.bounds.size.height
let UIKitLiveAudioScreenWidth = UIScreen.main.bounds.size.width
let UIKitLiveAudioBottomSafeAreaHeight = UIApplication.key?.safeAreaInsets.bottom ?? 0

let UIKitLiveAudioSeatWidth: CGFloat = 54.0
let UIKitLiveAudioSeatHeight: CGFloat = 75.0

func UIkitLiveAudioAdaptLandscapeWidth(_ x: CGFloat) -> CGFloat {
    return x * (UIKitLiveAudioScreenWidth / 375.0)
}

func UIkitLiveAudioAdaptLandscapeHeight(_ x: CGFloat) -> CGFloat {
    return x * (UIKitLiveAudioScreenHeight / 818.0)
}

func KeyWindow() -> UIWindow {
    let window: UIWindow = UIApplication.shared.windows.filter({ $0.isKeyWindow }).last!
    return window
}
 

enum ZegoUIKitLiveAudioIconSetType: String, Hashable {
    
    case bottom_message
    case bottom_member
    case bottom_mic_on
    case bottom_mic_off
    case seat_host_icon
    case seat_icon_normal
    case seat_icon_disabled
    case icon_more
    case icon_more_light
    case top_close
    case icon_nav_flip
    case icon_comeback
    case close_mic
    case bottombar_lianmai
    case member_more
    // MARK: - Image handling
    func load() -> UIImage {
        let image = UIImage.resource.loadImage(name: self.rawValue, bundleName: "ZegoUIKitPrebuiltLiveAudioRoom") ?? UIImage()
        return image
    }
}

@objc public enum ZegoLiveAudioRoomRole: Int {
    case host = 0
    case speaker = 1
    case audience = 2
}

@objc public enum ZegoLiveAudioRoomLayoutAlignment: Int {
  case spaceAround
  case spaceBetween
  case spaceEvenly
  case start
  case end
  case center
}

//MARK: - Public
@objc public enum ZegoMenuBarButtonName: Int {
    case leaveButton
    case toggleMicrophoneButton
    case showMemberListButton
    case showSpeakerButton
    case closeSeatButton
    case applyTakeSeatButton
}
