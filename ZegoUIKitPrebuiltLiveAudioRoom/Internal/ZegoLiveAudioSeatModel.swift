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
    var lock:Bool
    init(index: Int, userID: String, userName: String, extras: String, lock:Bool) {
        self.index = index
        self.userID = userID
        self.userName = userName
        self.extras = extras
        self.lock = lock
    }
}
