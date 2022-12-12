//
//  ZegoLiveAudioTipView.swift
//  ZegoUIKitPrebuiltLiveAudio
//
//  Created by zego on 2022/11/16.
//

import UIKit

enum ZegoLiveAudioTipViewType: Int {
    case warn
    case tip
}

class ZegoLiveAudioTipView: UIView {

    lazy var backGroundView: UIView = {
        let view = UIView()
        return view
    }()
    
    lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 2
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = UIColor.white
        return label
    }()
    
    var viewType: ZegoLiveAudioTipViewType = .warn
    var autoDismiss: Bool = true
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static func showTip(_ message: String, autoDismiss: Bool = true, onView: UIView?) {
        showTipView(.tip, message: message, autoDismiss: autoDismiss, onView: onView)
    }
    
    static func showWarn(_ message: String, autoDismiss: Bool = true, onView: UIView?) {
        showTipView(.warn, message: message, autoDismiss: autoDismiss, onView: onView)
    }
    
    static func showTipView(_ type: ZegoLiveAudioTipViewType, message: String, autoDismiss: Bool = true, onView: UIView?) {
        DispatchQueue.main.async {
            let y = KeyWindow().safeAreaInsets.top
            let tipView: ZegoLiveAudioTipView = ZegoLiveAudioTipView(frame: CGRect.init(x: 0, y: y, width: UIScreen.main.bounds.size.width, height: 70))
            tipView.autoDismiss = autoDismiss
            tipView.backGroundView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 70)
            tipView.messageLabel.frame = CGRect(x: 32, y: 0, width: UIScreen.main.bounds.size.width - 64, height: 70)
            switch type {
            case .warn:
                tipView.backGroundView.backgroundColor = UIColor.colorWithHexString("#BD5454")
            case .tip:
                tipView.backGroundView.backgroundColor =  UIColor.colorWithHexString("#55BC9E")
            }
            tipView.messageLabel.text = message
            tipView.addSubview(tipView.backGroundView)
            tipView.addSubview(tipView.messageLabel)
            tipView.show(onView)
        }
    }
        
    static func dismiss(_ onView: UIView?) {
        if let onView = onView {
            DispatchQueue.main.async {
                for subview in onView.subviews {
                    if subview is ZegoLiveAudioTipView {
                        let view: ZegoLiveAudioTipView = subview as! ZegoLiveAudioTipView
                        view.removeFromSuperview()
                    }
                }
            }
        } else {
            DispatchQueue.main.async {
                for subview in KeyWindow().subviews {
                    if subview is ZegoLiveAudioTipView {
                        let view: ZegoLiveAudioTipView = subview as! ZegoLiveAudioTipView
                        view.removeFromSuperview()
                    }
                }
            }
        }
    }
    
    private func show(_ onView: UIView?)  {
        if let onView = onView {
            onView.addSubview(self)
            if autoDismiss {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    ZegoLiveAudioTipView.dismiss(onView)
                }
            }
        } else {
            KeyWindow().addSubview(self)
            if autoDismiss {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    ZegoLiveAudioTipView.dismiss(nil)
                }
            }
        }
        
    }
}
