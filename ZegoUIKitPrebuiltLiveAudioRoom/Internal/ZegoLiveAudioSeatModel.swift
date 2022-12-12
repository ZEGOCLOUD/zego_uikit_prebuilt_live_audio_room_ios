//
//  ZegoLiveAudioSeatModel.swift
//  ZegoUIKitPrebuiltLiveAudio
//
//  Created by zego on 2022/11/21.
//

import UIKit

class ZegoLiveAudioSeatModel: NSObject {
    
    var index: Int
    var userID: String
    var userName: String
    var extras: String
    
    init(index: Int, userID: String, userName: String, extras: String) {
        self.index = index
        self.userID = userID
        self.userName = userName
        self.extras = extras
    }
}
