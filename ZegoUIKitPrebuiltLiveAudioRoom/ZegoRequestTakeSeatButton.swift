//
//  ZegoApplyWheatButton.swift
//  ZegoUIKitPrebuiltLiveAudioRoom
//
//  Created by zego on 2024/5/17.
//

import UIKit
import ZegoUIKit

protocol ZegoApplyWheatButtonDelegate: AnyObject {
    func applyWheatButtonDidClick(sender: ZegoRequestTakeSeatButton)
}

class ZegoRequestTakeSeatButton: UIView {

  weak var delegate: ZegoApplyWheatButtonDelegate?
  
  var config: ZegoUIKitPrebuiltLiveAudioRoomConfig = ZegoUIKitPrebuiltLiveAudioRoomConfig.audience() {
      didSet {
          self.applyWheatButton.setTitle(config.translationText.requestCoHostButton, for: .normal)
      }
  }
  
  internal var buttonEnable = true
  var requestList: [ZegoUIKitUser]?
  
  lazy var isSelected: Bool = false {
    didSet{
      self.applyWheatButton.isSelected = isSelected
    }
  }
  
  lazy var applyWheatButton: UIButton = {
      let button = UIButton.init(type: .custom)
      button.setImage(ZegoUIKitLiveAudioIconSetType.bottombar_lianmai.load(), for: .normal)
      button.setTitle(config.translationText.requestCoHostButton, for: .normal)
      button.setTitle(config.translationText.cancelRequestCoHostButton, for: .selected)
      button.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .medium)
      let imageEdgeInsets = UIEdgeInsets(top: 0, left: -3, bottom: 0, right: 3)
      let titleEdgeInsets = UIEdgeInsets(top: 0, left: 3, bottom: 0, right: -3)
      button.titleEdgeInsets = titleEdgeInsets
      button.imageEdgeInsets = imageEdgeInsets
    
      button.addTarget(self, action: #selector(onApplyWheatButtonClick), for: .touchUpInside)
      return button
  }()
  
  
  public init(frame: CGRect,translationText:ZegoTranslationText?) {
    super.init(frame: frame)
    self.backgroundColor = UIColor.colorWithHexString("#1E2740", alpha: 0.6)
    if let translationText = translationText {
      self.config.translationText = translationText
    }
    self.addSubview(self.applyWheatButton)
    self.buttonEnable = true
  }
  
  required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }
  
  override func layoutSubviews() {
      super.layoutSubviews()
      self.applyWheatButton.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
  }
  
  @objc func onApplyWheatButtonClick() {
      print("onApplyWheatButtonClick:\(self.buttonEnable)")
      if self.buttonEnable == false {
          ZegoLiveAudioTipView.showWarn(self.config.translationText.tryAgainToastString, onView: nil)
          return
      }
      self.buttonEnable = false
      self.isSelected = !self.isSelected
      self.delegate?.applyWheatButtonDidClick(sender: self)
      let workItem = DispatchWorkItem {
          self.buttonEnable = true
      }
      DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: workItem)
  }
}

