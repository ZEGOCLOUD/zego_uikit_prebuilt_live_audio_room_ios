//
//  ZegoMemberButtom.swift
//  ZegoUIKitPrebuiltLiveAudio
//
//  Created by zego on 2022/11/16.
//

import UIKit
import ZegoUIKit

protocol ZegoLiveAudioMemberButtonDelegate: AnyObject {
    func memberListDidClickAgree(_ user: ZegoUIKitUser)
    func memberListDidClickDisagree(_ user: ZegoUIKitUser)
    func memberListDidClickInvite(_ user: ZegoUIKitUser)
}

public class ZegoMemberButton: UIButton {
    
    weak var controller: UIViewController?
    weak var delegate: ZegoLiveAudioMemberButtonDelegate?
    var currentUser: ZegoUIKitUser?
    var memberListView: ZegoLiveAudioMemberListView?
    var currentHost: ZegoUIKitUser? {
        didSet {
            self.memberListView?.currentHost = currentHost
        }
    }
    var config: ZegoUIKitPrebuiltLiveAudioRoomConfig?
    
    private let help: ZegoMemberButton_Help = ZegoMemberButton_Help()
    
    var hostInviteList: [ZegoUIKitUser]?
  
    var seatLock:Bool = true {
      didSet {
        self.memberListView?.seatLock = seatLock
      }
    }
  
    var requestCoHostList: [ZegoUIKitUser]? {
        didSet {
            self.memberListView?.requestCoHostList = requestCoHostList
        }
    }
    
    var sheetListData: [String] {
        get {
          if self.isSpeaker {
            return []
          } else {
            return [self.config?.translationText.inviteCoHostButton.replacingOccurrences(of: "%@", with: self.currentUser?.userName ?? "") ?? "",self.config?.translationText.cancelMenuDialogButton ?? ""]
          }
        }
    }
    
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
        listView.translationText = self.config?.translationText ?? ZegoTranslationText(language: .ENGLISH)
        listView.currentHost = self.currentHost
        listView.frame = CGRect(x: 0, y: 0, width: controller.view.bounds.size.width, height: controller.view.bounds.size.height)
        listView.requestCoHostList = self.requestCoHostList
        listView.currentHost = self.currentHost
        listView.delegate = self.help
        listView.seatLock = self.seatLock
        controller.view.addSubview(listView)
        
    }
  
    var isSpeaker:Bool  = false
  
    func currentUserIsSpeaker(user:ZegoUIKitUser) -> Bool {
      let roomProperties = ZegoUIKit.getSignalingPlugin().getRoomProperties()
      var isSpeaker: Bool = false

      if let roomProperties = roomProperties {
        for (_, value) in roomProperties {
              if user.userID == value {
                isSpeaker = true
                break
              }
          }
      }
      return isSpeaker
    }
}

class ZegoMemberButton_Help: NSObject, ZegoUIKitEventHandle,ZegoLiveAudioMemberListDelegate, ZegoLiveAudioSheetViewDelegate {
    weak var memberButton: ZegoMemberButton?
    
    func didSelectRowForIndex(_ index: Int) {
        guard let currentUser = memberButton?.currentUser,
              let userID = currentUser.userID,
              let memberButton = self.memberButton
        else {
            return
        }
        if index == 0 {
            if let hostInviteList = self.memberButton?.hostInviteList {
                if hostInviteList.contains(where: {
                    return $0.userID == userID
                }) {
                    ZegoLiveAudioTipView.showWarn((memberButton.config?.translationText.repeatInviteCoHostFailedToast)!, onView: memberButton.controller?.view)
                    return
                }
            }
            ZegoUIKit.getSignalingPlugin().sendInvitation([userID], timeout: 60, type: 3, data: nil, notificationConfig: nil) { data in
                guard let data = data else { return }
                if data["code"] as! Int == 0 {
                    memberButton.delegate?.memberListDidClickInvite(currentUser)
                } else {
                    ZegoLiveAudioTipView.showWarn((memberButton.config?.translationText.inviteCoHostFailedToast)!, onView: self.memberButton?.controller?.view)
                }
            }
        } else if index == 1 {
//            ZegoUIKit.shared.removeUserFromRoom([userID])
        } else {
            memberButton.currentUser = nil
        }
    }
    
    func onRemoteUserJoin(_ userList: [ZegoUIKitUser]) {
        let number: Int = ZegoUIKit.shared.getAllUsers().count
        self.memberButton?.setTitle(String(format: "%d", number), for: .normal)
    }
    
    func onRemoteUserLeave(_ userList: [ZegoUIKitUser]) {
        let number: Int = ZegoUIKit.shared.getAllUsers().count
        self.memberButton?.setTitle(String(format: "%d", number), for: .normal)
    }
    
    //MARK: ZegoLiveAudioMemberListDelegate
    func memberListDidClickAgree(_ user: ZegoUIKitUser) {
        self.memberButton?.delegate?.memberListDidClickAgree(user)
        self.memberButton?.requestCoHostList = self.memberButton?.requestCoHostList?.filter{
            return $0.userID != user.userID
        }
    }
    
    func memberListDidClickDisagree(_ user: ZegoUIKitUser) {
        self.memberButton?.delegate?.memberListDidClickDisagree(user)
        self.memberButton?.requestCoHostList = self.memberButton?.requestCoHostList?.filter{
            return $0.userID != user.userID
        }
    }
    
    func memberListDidClickMoreButton(_ user: ZegoUIKitUser) {
        memberButton?.currentUser = user
        guard let memberButton = memberButton,
              let controller = memberButton.controller
        else {
            return
        }
        memberButton.isSpeaker = memberButton.currentUserIsSpeaker(user: user)
        let sheetList = ZegoLiveAudioSheetView()
        sheetList.dataSource = memberButton.sheetListData
        if sheetList.dataSource!.count <= 0 {
          return
        }
        sheetList.frame = CGRect(x: 0, y: 0, width: controller.view.bounds.size.width, height: controller.view.bounds.size.height)
        sheetList.delegate = self
        controller.view.addSubview(sheetList)
    }
    
}
