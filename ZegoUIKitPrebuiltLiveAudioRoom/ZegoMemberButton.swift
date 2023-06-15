//
//  ZegoMemberButtom.swift
//  ZegoUIKitPrebuiltLiveAudio
//
//  Created by zego on 2022/11/16.
//

import UIKit
import ZegoUIKit

public class ZegoMemberButton: UIButton {
    
    weak var controller: UIViewController?
    var memberListView: ZegoLiveAudioMemberListView?
    var currentHost: ZegoUIKitUser? {
        didSet {
            self.memberListView?.currentHost = currentHost
        }
    }
    var config: ZegoUIKitPrebuiltLiveAudioRoomConfig?
    
    private let help: ZegoMemberButton_Help = ZegoMemberButton_Help()
    

    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.help.memberButton = self
        ZegoUIKit.shared.addEventHandler(self.help)
        self.backgroundColor = UIColor.colorWithHexString("#FFFFFF")
        self.addTarget(self, action: #selector(buttonClick), for: .touchUpInside)
        self.setImage(ZegoUIKitLiveAudioIconSetType.bottom_member.load(), for: .normal)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    @objc func buttonClick() {
        guard let controller = controller else {
            return
        }
        let listView: ZegoLiveAudioMemberListView = ZegoLiveAudioMemberListView()
        self.memberListView = listView
        listView.translationText = self.config?.translationText
        listView.currentHost = self.currentHost
        listView.frame = CGRect(x: 0, y: 0, width: controller.view.bounds.size.width, height: controller.view.bounds.size.height)
        controller.view.addSubview(listView)
    }

}

class ZegoMemberButton_Help: NSObject, ZegoUIKitEventHandle {

    weak var memberButton: ZegoMemberButton?
        
    func onRemoteUserJoin(_ userList: [ZegoUIKitUser]) {
        let number: Int = ZegoUIKit.shared.getAllUsers().count
        self.memberButton?.setTitle(String(format: "%d", number), for: .normal)
    }
    
    func onRemoteUserLeave(_ userList: [ZegoUIKitUser]) {
        let number: Int = ZegoUIKit.shared.getAllUsers().count
        self.memberButton?.setTitle(String(format: "%d", number), for: .normal)
    }
    
}
