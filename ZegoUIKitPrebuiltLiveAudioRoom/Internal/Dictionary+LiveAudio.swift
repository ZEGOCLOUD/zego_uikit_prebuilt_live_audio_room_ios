//
//  Dictionary+LiveAudio.swift
//  ZegoUIKitPrebuiltLiveAudioRoom
//
//  Created by zego on 2022/11/21.
//

import Foundation

extension Dictionary where Key: ExpressibleByStringLiteral, Value:AnyObject {
    
    var audio_jsonString:String {
        do {
            let stringData = try JSONSerialization.data(withJSONObject: self as NSDictionary, options: JSONSerialization.WritingOptions.prettyPrinted)
            if let string = String(data: stringData, encoding: String.Encoding.utf8){
                return string
            }
        } catch _ {
            
        }
        return ""
    }
}
