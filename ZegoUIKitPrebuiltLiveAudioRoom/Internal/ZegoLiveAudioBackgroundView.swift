//
//  ZegoLiveAudioBackgroundView.swift
//  ZegoUIKitPrebuiltLiveAudio
//
//  Created by zego on 2022/12/2.
//

import UIKit

class ZegoLiveAudioBackgroundView: UIView {
    
    var backgroundView: UIView?

    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundView?.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
    }
    
    func setBackgroundView(_ view: UIView) {
        backgroundView = view
        self.addSubview(view)
    }

}
