//
//  ZegoLiveAudioMemberList.swift
//  ZegoUIKitPrebuiltLiveAudio
//
//  Created by zego on 2022/11/16.
//

import UIKit
import ZegoUIKit

class ZegoLiveAudioMemberListView: UIView {
    
    var translationText: ZegoTranslationText?
    
    var currentHost: ZegoUIKitUser? {
        didSet {
            self.reloadMemberList()
        }
    }
    
    var config: ZegoUIKitPrebuiltLiveAudioRoomConfig?
    
    lazy var memberListView: ZegoMemberList = {
        let listView = ZegoMemberList()
        listView.delegate = self
        listView.registerCell(ZegoLiveAudioMemberListCell.self, forCellReuseIdentifier: "ZegoLiveAudioMemberListCell")
        return listView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        let tap: UITapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(tapClick))
        self.addGestureRecognizer(tap)
        self.addSubview(self.memberListView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func tapClick() {
        self.removeFromSuperview()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let height: CGFloat = self.frame.size.height * 0.6
        self.memberListView.frame = CGRect(x: 0, y: self.frame.size.height - height, width: self.frame.size.width, height: self.frame.size.height * 0.6)
        self.memberListView.cornerCut(16, corner: [.topLeft,.topRight])
    }
    
    func reloadMemberList() {
        self.memberListView.reloadData()
    }
}

extension ZegoLiveAudioMemberListView: ZegoMemberListDelegate {
    
    //MARK: -ZegoMemberListDelegate
    
    func getMemberListItemView(_ tableView: UITableView, indexPath: IndexPath, userInfo: ZegoUIKitUser) -> UITableViewCell? {
        let cell: ZegoLiveAudioMemberListCell = tableView.dequeueReusableCell(withIdentifier: "ZegoLiveAudioMemberListCell") as! ZegoLiveAudioMemberListCell
        cell.selectionStyle = .none
        cell.user = userInfo
        cell.currentHost = self.currentHost
        cell.backgroundColor = UIColor.clear
        cell.translationText = self.translationText
      
        if userInfo.userID == self.currentHost?.userID {
            cell.role = .host
        } else if let userID = userInfo.userID, userInfo.inRoomAttributes.values.contains(userID) {
            cell.role = .speaker
        } else {
            cell.role = .audience
        }
            
        return cell
    }
    
    func getMemberListItemHeight(_ userInfo: ZegoUIKitUser) -> CGFloat {
        return 70
    }
  
    func getMemberListviewForHeaderInSection(_ tableView: UITableView, section: Int) -> UIView? {
        let view = UIView()
        let label = UILabel()
        label.frame = CGRect(x: 16, y: 26, width: 150, height: 22)
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 16)
        label.text = String(format: "%@·%d", self.translationText?.memberListTitle ?? "Audience",(ZegoUIKit.shared.userList.count))
        view.addSubview(label)
        return view
    }
    
    func getMemberListHeaderHeight(_ tableView: UITableView, section: Int) -> CGFloat {
        return 58
    }
    
    func sortUserList(_ userList: [ZegoUIKitUser]) -> [ZegoUIKitUser] {
        var newUserList: [ZegoUIKitUser] = []
        var host: ZegoUIKitUser?
        var mySelf: ZegoUIKitUser?
        var speckerUserList: [ZegoUIKitUser] = []
        var audienceUserList: [ZegoUIKitUser] = []
        let roomProperties = ZegoUIKit.getSignalingPlugin().getRoomProperties()
        for user in userList {
            
            if let roomProperties = roomProperties {
                var isExist: Bool = false
                for (key, value) in roomProperties {
                    if user.userID == value {
                        user.inRoomAttributes.updateValue(value, forKey: key)
                        isExist = true
                    }
                }
                
                if !isExist {
                    user.inRoomAttributes = [:]
                }
            }
            
            if user.userID == self.currentHost?.userID {
                host = user
            } else if user.userID == ZegoUIKit.shared.localUserInfo?.userID {
                mySelf = user
            } else {
                if let userID = user.userID, let roomProperties = roomProperties,  roomProperties.values.contains(userID) {
                    speckerUserList.append(user)
                } else {
                    audienceUserList.append(user)
                }
            }
        }
        if let host = host {
            newUserList.append(host)
        }
        if let mySelf = mySelf {
            if mySelf.userID != host?.userID {
                newUserList.append(mySelf)
            }
        }
        newUserList.append(contentsOf: speckerUserList)
        newUserList.append(contentsOf: audienceUserList)
        return newUserList
    }

}
