//
//  ZegoLiveAudioMemberListCell.swift
//  ZegoUIKitPrebuiltLiveAudio
//
//  Created by zego on 2022/11/16.
//

import UIKit
import ZegoUIKit

protocol ZegoLiveAudioMemberListCellDelegate: AnyObject {
    func moreButtonDidClick(_ user: ZegoUIKitUser)
    func agreeButtonDidClick(_ user: ZegoUIKitUser)
    func disAgreeButtonDidClick(_ user: ZegoUIKitUser)
}

class ZegoLiveAudioMemberListCell: UITableViewCell {
    weak var delegate: ZegoLiveAudioMemberListCellDelegate?
    var translationText: ZegoTranslationText = ZegoTranslationText(language: .ENGLISH)
    var enableCoHosting: Bool = true
    var seatLock:Bool = true
    var user: ZegoUIKitUser? {
        didSet {
            guard let userName = user?.userName else { return }
            if userName.count > 0 {
                let firstStr: String = String(userName[userName.startIndex])
                headLabel.text = firstStr
            } else {
                headLabel.text = ""
            }
          
          if user?.userID == ZegoUIKit.shared.localUserInfo?.userID {
              //is self
              self.moreButton.isHidden = true
          } else {
              self.moreButton.isHidden = role == .host ? true : false
          }
        self.agreeButton.setTitle(self.translationText.receivedCoHostInvitationDialogInfoConfirm, for: .normal)
        self.disAgreeButton.setTitle(self.translationText.receivedCoHostInvitationDialogInfoCancel, for: .normal)
        }
    }
    lazy var moreButton: UIButton = {
        let button = UIButton()
        button.setImage(ZegoUIKitLiveAudioIconSetType.member_more.load(), for: .normal)
        button.addTarget(self, action: #selector(moreButtonClick), for: .touchUpInside)
        return button
    }()
    
    lazy var agreeButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.colorWithHexString("#A754FF")
        button.setTitle(self.translationText.receivedCoHostInvitationDialogInfoConfirm, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        button.setTitleColor(UIColor.white, for: .normal)
        button.isHidden = true
        button.addTarget(self, action: #selector(agreeClick), for: .touchUpInside)
        return button
    }()
    
    lazy var disAgreeButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.colorWithHexString("#FFFFFF", alpha: 0.1)
        button.setTitle(self.translationText.receivedCoHostInvitationDialogInfoCancel, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        button.setTitleColor(UIColor.colorWithHexString("#A7A6B7"), for: .normal)
        button.addTarget(self, action: #selector(disAgreeClick), for: .touchUpInside)
        button.isHidden = true
        return button
    }()
    
    var currentHost: ZegoUIKitUser?
    
    var isRequestCoHost: Bool = false {
        didSet {
          self.setButtonDisplayStatus(self.role == .host ? true : false , isCoHost: self.role == .speaker ? true : false, isRequestCoHost: isRequestCoHost)
        }
    }
    
    var role: ZegoLiveAudioRoomRole = .audience {
        didSet {
            enableCoHosting = (role == .speaker) ? false :true
            self.setUserIdentity(role)
            self.setButtonDisplayStatus(self.role == .host ? true : false , isCoHost: self.role == .speaker ? true : false, isRequestCoHost: self.isRequestCoHost)
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
        label.lineBreakMode = .byTruncatingMiddle
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.addSubview(self.headLabel)
        self.contentView.addSubview(self.nameLabel)
        self.contentView.addSubview(self.moreButton)
        self.contentView.addSubview(self.agreeButton)
        self.contentView.addSubview(self.disAgreeButton)
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
      
        self.moreButton.frame = CGRect(x: self.frame.size.width - 30 - 18, y: 20, width: 30, height: 30)
        self.agreeButton.frame = CGRect(x: self.frame.size.width -  63 - 18, y: 19, width: 63, height: 32)
        self.disAgreeButton.frame = CGRect(x: self.agreeButton.frame.minX - 6 - 82, y: 19, width: 82, height: 32)
        self.agreeButton.layer.masksToBounds = true
        self.agreeButton.layer.cornerRadius = 16
        self.disAgreeButton.layer.masksToBounds = true
        self.disAgreeButton.layer.cornerRadius = 16
    }
    
    func setUserIdentity(_ role: ZegoLiveAudioRoomRole) {
        if role == .host {
            if self.user?.userID == ZegoUIKit.shared.localUserInfo?.userID {
              nameLabel.text = String(format: "%@%@",self.user?.userName ?? "",self.translationText.audioMemberListUserIdentifyYourHost)
            } else {
                nameLabel.text = String(format: "%@%@",self.user?.userName ?? "",self.translationText.audioMemberListUserIdentifyHost)
            }
            setButtonDisplayStatus(true, isCoHost: false, isRequestCoHost: false)
        }  else if role == .speaker {
            if user?.userID == ZegoUIKit.shared.localUserInfo?.userID {
                nameLabel.text = String(format: "%@%@",self.user?.userName ?? "",self.translationText.audioMemberListUserIdentifyYourSpeaker)
            } else {
                nameLabel.text = String(format: "%@%@",self.user?.userName ?? "",self.translationText.audioMemberListUserIdentifySpeaker)
            }
            setButtonDisplayStatus(false, isCoHost: true, isRequestCoHost: false)
        } else {
            if user?.userID == ZegoUIKit.shared.localUserInfo?.userID {
                nameLabel.text = String(format: "%@%@",self.user?.userName ?? "",self.translationText.audioMemberListUserIdentifyYou)
            } else {
                nameLabel.text = String(format: "%@",self.user?.userName ?? "")
            }
            setButtonDisplayStatus(false, isCoHost: false, isRequestCoHost: false)
        }
    }
  
    func setButtonDisplayStatus(_ isHost: Bool, isCoHost: Bool, isRequestCoHost: Bool) {
        if ZegoUIKit.shared.localUserInfo?.userID == self.currentHost?.userID {
          if self.seatLock == false {
            self.moreButton.isHidden = true
            self.agreeButton.isHidden = true
            self.disAgreeButton.isHidden = true
          } else {
            if isHost {
                self.moreButton.isHidden = true
                self.agreeButton.isHidden = true
                self.disAgreeButton.isHidden = true
            } else if isCoHost {
//                self.moreButton.isHidden = enableCoHosting ? false : true
                self.moreButton.isHidden = false
                self.agreeButton.isHidden = true
                self.disAgreeButton.isHidden = true
                
            } else if isRequestCoHost {
                self.moreButton.isHidden = true
                self.agreeButton.isHidden = false
                self.disAgreeButton.isHidden = false
            } else {
                self.moreButton.isHidden = enableCoHosting ? false : true
                self.agreeButton.isHidden = true
                self.disAgreeButton.isHidden = true
            }
          }
        } else {
            self.moreButton.isHidden = true
            self.agreeButton.isHidden = true
            self.disAgreeButton.isHidden = true
        }
        
    }
         
   
  @objc func moreButtonClick() {
      guard let user = user else {
          return
      }
      if (self.role == .speaker){
        return
      }
      self.delegate?.moreButtonDidClick(user)
  }
  
  @objc func agreeClick() {
      guard let user = user else {
          return
      }
      self.delegate?.agreeButtonDidClick(user)
  }
  
  @objc func disAgreeClick() {
      guard let user = user else {
          return
      }
      self.delegate?.disAgreeButtonDidClick(user)
  }

}
