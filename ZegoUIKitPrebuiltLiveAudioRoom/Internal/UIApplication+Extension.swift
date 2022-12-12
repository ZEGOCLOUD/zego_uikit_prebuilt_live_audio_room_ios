//
//  UIApplication+Extension.swift
//  ZegoUIKitPrebuiltLiveAudio
//
//  Created by zego on 2022/11/17.
//

import Foundation

import UIKit

extension UIApplication {
    /// get the key window of application
    public static var key: UIWindow? {
        if #available(iOS 13, *) {
            return UIApplication.shared.windows.first { $0.isKeyWindow }
        } else {
            return UIApplication.shared.keyWindow
        }
    }
}
