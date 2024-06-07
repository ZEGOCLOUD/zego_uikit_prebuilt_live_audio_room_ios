//
//  String+LiveAudio.swift
//  ZegoUIKitPrebuiltLiveAudio
//
//  Created by zego on 2022/11/21.
//

import Foundation

extension  String {
    func audio_convertStringToDictionary() -> [String:AnyObject]? {
        if let data = self.data(using: String.Encoding.utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: [JSONSerialization.ReadingOptions.init(rawValue: 0)]) as? [String:AnyObject]
            } catch let error as NSError {
                print(error)
            }
        }
        return nil
    }
}
