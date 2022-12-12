//
//  ZegoLiveAudioMemberListCell.swift
//  ZegoUIKitPrebuiltLiveAudio
//
//  Created by zego on 2022/11/16.
//

import UIKit
import ZegoUIKitSDK

class ZegoLiveAudioMemberListCell: UITableViewCell {
    
    var user: ZegoUIKitUser? {
        didSet {
            guard let userName = user?.userName else { return }
            if userName.count > 0 {
                let firstStr: String = String(userName[userName.startIndex])
                headLabel.text = firstStr
            } else {
                headLabel.text = ""
            }
        }
    }
    
    var currentHost: ZegoUIKitUser?
    
    var role: ZegoLiveAudioRoomRole = .audience {
        didSet {
            self.setUserIdentity(role)
        }
    }
    
    lazy var headLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = UIColor.colorWithHexString("#222222")
        label.backgroundColor = UIColor.colorWithHexString("#DBDDE3")
        return label
    }()
    
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor.white
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.addSubview(self.headLabel)
        self.contentView.addSubview(self.nameLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.setupLayout()
    }
    
    func setupLayout() {
        self.headLabel.frame = CGRect(x: 18, y: 12, width: 46, height: 46)
        self.headLabel.layer.masksToBounds = true
        self.headLabel.layer.cornerRadius = 23
        self.nameLabel.frame = CGRect(x: headLabel.frame.maxX + 12, y: 23.5, width: 200, height: 20)
    }
    
    func setUserIdentity(_ role: ZegoLiveAudioRoomRole) {
        if role == .host {
            if self.user?.userID == ZegoUIKit.shared.localUserInfo?.userID {
                nameLabel.text = String(format: "%@(You,Host)",self.user?.userName ?? "")
            } else {
                nameLabel.text = String(format: "%@(Host)",self.user?.userName ?? "")
            }
        }  else if role == .speaker {
            if user?.userID == ZegoUIKit.shared.localUserInfo?.userID {
                nameLabel.text = String(format: "%@(You,Speaker)",self.user?.userName ?? "")
            } else {
                nameLabel.text = String(format: "%@(Speaker)",self.user?.userName ?? "")
            }
        } else {
            if user?.userID == ZegoUIKit.shared.localUserInfo?.userID {
                nameLabel.text = String(format: "%@(You)",self.user?.userName ?? "")
            } else {
                nameLabel.text = String(format: "%@",self.user?.userName ?? "")
            }
        }
    }

}
