//
//  ZegoUIKitPrebuiltLiveAudioVC.swift
//  ZegoUIKitPrebuiltLiveAudio
//
//  Created by zego on 2022/11/15.
//

import UIKit
import ZegoUIKitSDK

enum ZegoLiveAudioSeatActionType: Int {
    case take
    case leave
    case remove
}

@objc public protocol ZegoUIKitPrebuiltLiveAudioRoomVCDelegate: AnyObject {
    @objc optional func getSeatForegroundView(_ userInfo: ZegoUIKitUser?, seatIndex: Int) -> UIView?
    @objc optional func onLeaveLiveAudioRoom()
}

public class ZegoUIKitPrebuiltLiveAudioRoomVC: UIViewController {
    
    @objc public weak var delegate: ZegoUIKitPrebuiltLiveAudioRoomVCDelegate?
    
    let inputViewHeight: CGFloat = 55
    var userID: String?
    var userName: String?
    var roomID: String?
    
    var config: ZegoUIKitPrebuiltLiveAudioRoomConfig = ZegoUIKitPrebuiltLiveAudioRoomConfig.audience() {
        didSet{
            self.bottomBar.config = config
        }
    }
    
    var currentHost: ZegoUIKitUser? {
        didSet {
            self.bottomBar.currentHost = currentHost
            self.containerView.currentHost = currentHost
        }
    }
    
    var currentRole: ZegoLiveAudioRoomRole = .audience {
        didSet {
            self.updateConfigMenuBar(currentRole)
        }
    }
    
    weak var currentSheetView: ZegoLiveAudioSheetView?
    weak var currentAlterView: UIAlertController?
    var currentSeatAction: ZegoLiveAudioSeatActionType = .take
    var currentClickSeatModel: ZegoLiveAudioSeatModel?
    var isShowMicPermissionAlter: Bool = false
    var usersInRoomAttributes: [ZegoUserInRoomAttributesInfo]?
    var roomProperties: [String : String] = [:]
    var isSwitchingSeat: Bool = false

    @objc public init(_ appID: UInt32, appSign: String, userID: String, userName: String, roomID: String, config: ZegoUIKitPrebuiltLiveAudioRoomConfig) {
        super.init(nibName: nil, bundle: nil)
        if (config.role == .host || config.role == .speaker) && config.takeSeatIndexWhenJoining < 0 {
            config.role = .audience
            config.takeSeatIndexWhenJoining = -1
        } else if config.role == .speaker && config.hostSeatIndexes.contains(config.takeSeatIndexWhenJoining) {
            config.role = .audience
            config.takeSeatIndexWhenJoining = -1
        }
        self.config = config
        ZegoUIKit.getSignalingPlugin().installPlugins([ZegoUIKitSignalingPlugin()])
        ZegoUIKit.shared.initWithAppID(appID: appID, appSign: appSign)
        ZegoUIKit.getSignalingPlugin().initWithAppID(appID: appID, appSign: appSign)
        ZegoUIKit.shared.localUserInfo = ZegoUIKitUser.init(userID, userName)
        ZegoUIKit.shared.addEventHandler(self.help)
        self.userID = userID
        self.userName = userName
        self.roomID = roomID
        if config.role == .host {
            self.currentHost = ZegoUIKitUser.init(userID, userName)
            self.bottomBar.currentHost = self.currentHost
        }
        self.help.liveAudioVC = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let help = ZegoUIKitPrebuiltLiveAudioVC_Help()
    
    lazy var leaveButton: ZegoLeaveButton = {
        let button = ZegoLeaveButton()
        if let confirmDialogInfo = self.config.confirmDialogInfo {
            confirmDialogInfo.dialogPresentVC = self
            button.quitConfirmDialogInfo = confirmDialogInfo
        }
        button.delegate = self.help
        button.iconLeave = ZegoUIKitLiveAudioIconSetType.top_close.load()
        return button
    }()
    
    lazy var containerView: ZegoLiveAudioContainerView = {
        let view = ZegoLiveAudioContainerView(frame:.zero)
        view.config = self.config
        view.delegate = self
        return view
    }()
    
    lazy var bottomBar: ZegoLiveAudioRoomBottomBar = {
        let bar = ZegoLiveAudioRoomBottomBar()
        bar.controller = self
        bar.config = self.config
        bar.delegate = self.help
        return bar
    }()
    
    lazy var messageView: ZegoInRoomMessageView = {
        let messageList = ZegoInRoomMessageView()
        return messageList
    }()
    
    lazy var inputTextView: ZegoInRoomMessageInput = {
        let messageInputView = ZegoInRoomMessageInput()
        messageInputView.frame = CGRect(x: 0, y: UIScreen.main.bounds.size.height, width: UIScreen.main.bounds.size.width, height: inputViewHeight)
        return messageInputView
    }()
    
    lazy var backgroundView: ZegoLiveAudioBackgroundView = {
        let view: ZegoLiveAudioBackgroundView = ZegoLiveAudioBackgroundView()
        view.backgroundColor = UIColor.clear
        return view
    }()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        joinRoom()
        self.view.backgroundColor = UIColor.colorWithHexString("#F4F4F6")
        self.view.addSubview(self.backgroundView)
        self.view.addSubview(self.leaveButton)
        self.view.addSubview(self.containerView)
        self.view.addSubview(self.bottomBar)
        self.view.addSubview(self.messageView)
        self.view.addSubview(self.inputTextView)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame(node:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.setupLayout()
    }
    
    @objc public func addButtonToMenuBar(_ button: UIButton, role: ZegoLiveAudioRoomRole) {
        self.bottomBar.addButtonToMenuBar(button, role: role)
    }

    @objc func keyboardWillChangeFrame(node : Notification){
            print(node.userInfo ?? "")
            let duration = node.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as! TimeInterval
            let endFrame = (node.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
            let y = endFrame.origin.y
            
            let margin = UIScreen.main.bounds.size.height - y
            UIView.animate(withDuration: duration) {
                self.view.layoutIfNeeded()
                if margin > 0 {
                    self.inputTextView.frame = CGRect(x: 0, y: UIScreen.main.bounds.size.height - margin - self.inputViewHeight, width: UIScreen.main.bounds.size.width, height: self.inputViewHeight)
                } else {
                    self.inputTextView.frame = CGRect(x: 0, y: UIScreen.main.bounds.size.height - margin, width: UIScreen.main.bounds.size.width, height: self.inputViewHeight)
                }
                
            }
    }
    
    private func setupLayout() {
        self.backgroundView.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        self.leaveButton.frame = CGRect(x: self.view.frame.size.width - 34 - 15, y: 57, width: 34, height: 34)
        self.setContainerFrame()
        self.messageView.frame = CGRect(x: 0, y: self.view.frame.size.height - 62 - 200, width: UIkitLiveAudioScreenWidth - 16 - 89, height: 200)
        self.bottomBar.frame = CGRect(x: 0, y: self.view.frame.size.height - 62, width: self.view.frame.size.width, height: 62)

    }
    
    func setContainerFrame() {
        var height: Int = self.config.layoutConfig.rowConfigs.count * Int(UIkitLiveAudioSeatHeight)
        let space: Int = self.config.layoutConfig.rowSpecing * (self.config.layoutConfig.rowConfigs.count - 1)
        height = height + space
        self.containerView.frame = CGRect(x: 15, y: Int(self.leaveButton.frame.maxY) + 36, width: Int(UIScreen.main.bounds.size.width) - 30, height: height)
        
    }
    
    private func joinRoom() {
        guard let roomID = self.roomID,
              let userID = self.userID,
              let userName = self.userName
        else { return }
        ZegoUIKit.shared.joinRoom(userID, userName: userName, roomID: roomID)
        if self.config.turnOnMicrophoneWhenJoining {
            self.requestMicPermission(true)
        }
        ZegoUIKit.shared.turnMicrophoneOn(self.userID ?? "", isOn: self.config.turnOnMicrophoneWhenJoining)
        ZegoUIKit.shared.turnCameraOn(self.userID ?? "", isOn: false)
        ZegoUIKit.getSignalingPlugin().login(userID, userName: userName) { data in
            guard let data = data else { return }
            if data["code"] as! Int == 0 {
                ZegoUIKit.getSignalingPlugin().joinRoom(roomID: roomID) { data in
                    guard let data = data else { return }
                    if data["code"] as! Int == 0  {
                        self.currentRole = .audience
                        self.joinRoomAfterUpdateRoomInfo()
                        self.queryInRoomUserAttribute()
                    } else {
                        print("login IM fail")
                    }
                }
            }
        }
    }
    
    func queryInRoomUserAttribute() {
        ZegoUIKit.getSignalingPlugin().queryRoomProperties { data in
            guard let data = data else { return }
            let code: Int = data["code"] as? Int ?? 0
            if code == 0 {
                self.roomProperties = data["roomAttributes"] as! [String : String]
                self.updateLayout()
            }
        }
        
        ZegoUIKit.getSignalingPlugin().queryUsersInRoomAttributes(ZegoUsersInRoomAttributesQueryConfig()) { data in
            guard let data = data else { return }
            print("queryInRoomUserAttribute data:%@",data)
            if data["code"] as! Int == 0 {
                self.usersInRoomAttributes = data["infos"] as? [ZegoUserInRoomAttributesInfo]
                self.updateLayout()
            }
        }
    }
    
    fileprivate func updateLayout() {
        self.containerView.seatRowModelList.forEach { model in
            model.seatModels.forEach { seatModel in
                if !self.roomProperties.keys.contains("\(seatModel.index)") {
                    self.setLayoutSeatToEmptySeatView(seatModel.index)
                }
            }
        }
        
        self.roomProperties.forEach { property in
            let index: Int = Int(property.key) ?? -1
            var isContain: Bool = false
            self.containerView.seatRowModelList.forEach { model in
                model.seatModels.forEach { seatModel in
                    if seatModel.index == index {
                        isContain = true
                    }
                }
            }
            if isContain {
                self.setLayoutSeatToAudioVideoView(property.value, index: index)
            }
        }
        
    }
    
    private func replaceBottomMenuBarButtonsAndExtendButtons(_ role: ZegoLiveAudioRoomRole) {
        updateConfigMenuBar(role)
    }
    
    func updateConfigMenuBar(_ role: ZegoLiveAudioRoomRole) {
        self.bottomBar.curRole = role
    }
    
    func setLayoutSeatToEmptySeatView(_ index: Int) {
        self.containerView.setLayoutSeatToEmptySeatView(index)
    }
    
    func setLayoutSeatToAudioVideoView(_ value: String, index: Int) {
        self.containerView.setLayoutSeatToAudioVideoView(value, index: index)
    }
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.view.endEditing(true)
    }
    
    @objc public func clearBottomBarExtendButtons(_ role: ZegoLiveAudioRoomRole) {
        self.bottomBar.clearBottomBarExtendButtons(role)
    }
    
    deinit {
        print("===ZegoUIKitPrebuiltLiveAudioVC deinit")
    }
}

extension ZegoUIKitPrebuiltLiveAudioRoomVC: ZegoLiveAudioContainerViewDelegate, ZegoLiveAudioSheetViewDelegate {
    
    public func setBackgroundView(_ view: UIView) {
        self.backgroundView.setBackgroundView(view)
    }
    
    func joinRoomAfterUpdateRoomInfo() {
        guard let userID = self.userID else { return }
        if self.config.role == .host {
            ZegoUIKit.getSignalingPlugin().updateRoomProperty("\(self.config.takeSeatIndexWhenJoining)", value: userID, isDeleteAfterOwnerLeft: true, isForce: true, isUpdateOwner: true) { data in
                guard let data = data else { return }
                if data["code"] as! Int == 0 {
                    guard let roomID = self.roomID else { return }
                    ZegoUIKit.getSignalingPlugin().setUsersInRoomAttributes("role", value: "\(self.config.role.rawValue)", userIDs: [userID], roomID: roomID) { data in
                        guard let data = data else { return }
                        if data["code"] as! Int != 0 {
                            self.currentRole = .audience
                            ZegoUIKit.getSignalingPlugin().deleteRoomProperties(["\(self.config.takeSeatIndexWhenJoining)"], isForce: true, callBack: nil)
                            self.config.takeSeatIndexWhenJoining = -1
                        } else {
                            // take seat sucess
                            self.currentRole = .host
                            self.updateLayout()
                        }
                    }
                } else {
                    self.currentRole = .audience
                    self.config.takeSeatIndexWhenJoining = -1
                }
            }
        } else if self.config.role == .speaker {
            ZegoUIKit.getSignalingPlugin().updateRoomProperty("\(self.config.takeSeatIndexWhenJoining)", value: userID, isDeleteAfterOwnerLeft: true, isForce: true, isUpdateOwner: false) { data in
                guard let data = data else { return }
                if data["code"] as! Int != 0 {
                    self.currentRole = .audience
                    self.config.takeSeatIndexWhenJoining = -1
                } else {
                    // take seat sucess
                    self.currentRole = .speaker
                    self.updateLayout()
                }
            }
        }
    }
    
    //MARK: -ZegoLiveAudioContainerViewDelegate
    func getSeatForegroundView(_ userInfo: ZegoUIKitUser?, seatIndex: Int) -> UIView? {
        if let foregroundView = self.delegate?.getSeatForegroundView?(userInfo, seatIndex: seatIndex) {
            return foregroundView
        } else {
            // user nomal foregroundView
            let nomalForegroundView: ZegoLiveAudioNormalForegroundView = ZegoLiveAudioNormalForegroundView.init(frame: .zero)
            nomalForegroundView.userInfo = userInfo
            if self.config.role == .host {
                nomalForegroundView.isHost = self.currentHost?.userID == userInfo?.userID
            } else {
                nomalForegroundView.isHost = self.queryUserIsHost(userInfo)
                if nomalForegroundView.isHost {
                    self.currentHost = userInfo
                }
                
                if self.currentHost?.userID == userInfo?.userID, !nomalForegroundView.isHost {
                    self.currentHost = nil
                }
            }
            return nomalForegroundView
        }
    }
    
    func queryUserIsHost(_ userInfo: ZegoUIKitUser?) -> Bool {
        guard let InRoomAttributes = self.usersInRoomAttributes else { return false }
        for info in InRoomAttributes {
            let inRoomAttributeInfo: ZegoUserInRoomAttributesInfo = info
            if inRoomAttributeInfo.userID == userInfo?.userID && inRoomAttributeInfo.attributes["role"] == "0" {
                return true
            }
        }
        return false
    }
    
    func onSeatItemClick(_ seatModel: ZegoLiveAudioSeatModel?) {
        guard let seatModel = seatModel else { return }
        currentClickSeatModel = seatModel
        guard let roomProporty = ZegoUIKit.getSignalingPlugin().getRoomProperties() else { return }
        if self.currentRole == .host {
            //remove seat
            if roomProporty.keys.contains("\(seatModel.index)") && seatModel.userID != self.userID {
                self.currentSeatAction = .remove
                self.showSheetView([self.config.translationText.removeSpeakerMenuDialogButton.replacingOccurrences(of: "%@", with: self.currentClickSeatModel?.userName ?? ""),self.config.translationText.cancelMenuDialogButton])
            }
        } else if self.currentRole == .speaker {
            //switch seat or leave seat
            if self.config.hostSeatIndexes.contains(seatModel.index) {
                return
            }
            if roomProporty.keys.contains("\(seatModel.index)") && seatModel.userID == self.userID {
                self.currentSeatAction = .leave
                self.showSheetView([self.config.translationText.leaveSeatMenuDialogButton,self.config.translationText.cancelMenuDialogButton])
            } else if !roomProporty.keys.contains("\(seatModel.index)") {
                //switch seat
                self.switchSeat(seatModel)
            }
        } else if self.currentRole == .audience {
            //take seat
            if self.config.hostSeatIndexes.contains(seatModel.index) {
                return
            }
            if roomProporty.keys.contains("\(seatModel.index)") {
                print("Seat has been taken")
            } else {
                self.currentSeatAction = .take
                self.showSheetView([self.config.translationText.takeSeatMenuDialogButton,self.config.translationText.cancelMenuDialogButton])
            }
        }
    }
    
    func showSheetView(_ dataSource: [String]) {
        currentSheetView?.disMiss()
        let sheetView: ZegoLiveAudioSheetView = ZegoLiveAudioSheetView.init(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height))
        sheetView.dataSource = dataSource
        currentSheetView = sheetView
        sheetView.delegate = self
        sheetView.show(self.view)
    }
    
    func didSelectRowForIndex(_ index: Int) {
        if index == 0 {
            if currentSeatAction == .take {
                guard let currentClickSeatModel = self.currentClickSeatModel else { return }
                self.takeSeat(currentClickSeatModel.index)
            } else {
                self.showSeatAlter()
            }
        }
    }
    
    func showSeatAlter() {
        var alterTitle: String = ""
        var alterMessage: String = ""
        var cancelName: String = ""
        var sureName: String = ""
        switch currentSeatAction {
        case .take:
            break
        case .leave:
            alterTitle = self.config.translationText.leaveSeatDialogInfo.title ?? "Leave the seat"
            alterMessage = self.config.translationText.leaveSeatDialogInfo.message ?? "Are you sure to leave the seat?"
            cancelName = self.config.translationText.leaveSeatDialogInfo.cancelButtonName
            sureName = self.config.translationText.leaveSeatDialogInfo.confirmButtonName
        case .remove:
            alterTitle = self.config.translationText.removeSpeakerFromSeatDialogInfo.title ?? ""
            alterMessage = self.config.translationText.removeSpeakerFromSeatDialogInfo.message?.replacingOccurrences(of: "%@", with: self.currentClickSeatModel?.userName ?? "") ?? ""
            cancelName = self.config.translationText.removeSpeakerFromSeatDialogInfo.cancelButtonName
            sureName = self.config.translationText.removeSpeakerFromSeatDialogInfo.confirmButtonName
        }
        guard let currentClickSeatModel = self.currentClickSeatModel else { return }
        let alterView: UIAlertController = UIAlertController.init(title: alterTitle, message: alterMessage, preferredStyle: .alert)
        self.currentAlterView = alterView
        let cancelButton: UIAlertAction = UIAlertAction.init(title: cancelName, style: .cancel, handler: nil)
        let sureButton: UIAlertAction = UIAlertAction.init(title: sureName, style: .default) { action in
            switch self.currentSeatAction {
            case .leave:
                self.leaveSeat(currentClickSeatModel.index)
            case .remove:
                self.removeSeat(currentClickSeatModel.index)
            case .take:
                break
            }
        }
        alterView.addAction(cancelButton)
        alterView.addAction(sureButton)
        self.present(alterView, animated: true, completion: nil)
    }
    
    func takeSeat(_ index: Int) {
        if isShowMicPermissionAlter {
            self.applicationHasMicAccess()
        } else {
            self.requestMicPermission(true)
        }
        ZegoUIKit.getSignalingPlugin().updateRoomProperty("\(index)", value: self.userID ?? "", isDeleteAfterOwnerLeft: true, isForce: false, isUpdateOwner: false) { data in
            guard let data = data else { return }
            if data["code"] as! Int == 0 {
                self.currentRole = .speaker
                self.updateLayout()
                ZegoUIKit.shared.turnMicrophoneOn(self.userID ?? "", isOn: true)
                ZegoUIKit.shared.turnCameraOn(self.userID ?? "", isOn: false)
            }
        }
    }
    
    func leaveSeat(_ index: Int) {
        ZegoUIKit.getSignalingPlugin().deleteRoomProperties(["\(index)"], isForce: true) { data in
            guard let data = data else { return }
            if data["code"] as! Int == 0 {
                self.currentRole = .audience
                self.updateLayout()
                ZegoUIKit.shared.turnMicrophoneOn(self.userID ?? "", isOn: false)
            }
        }
    }
    
    func removeSeat(_ index: Int) {
        guard let roomProperties = ZegoUIKit.getSignalingPlugin().getRoomProperties() else { return }
        if roomProperties.keys.contains("\(index)") {
            ZegoUIKit.getSignalingPlugin().deleteRoomProperties(["\(index)"], isForce: true) { data in
                guard let data = data else { return }
                if data["code"] as! Int != 0  {
                    let message = self.config.translationText.removeSpeakerFailedToast.replacingOccurrences(of: "%@", with: self.currentClickSeatModel?.userName ?? "")
                    ZegoLiveAudioTipView.showWarn(message, onView: self.view)
                }
            }
        }
    }
    
    func switchSeat(_ seatModel: ZegoLiveAudioSeatModel) {
        if isSwitchingSeat { return }
        if isShowMicPermissionAlter {
            self.applicationHasMicAccess()
        } else {
            self.requestMicPermission()
        }
        guard let userID = self.userID else { return }
        self.isSwitchingSeat = true
        let oldIndex = getSeatIndexByUserID(userID)
        ZegoUIKit.getSignalingPlugin().beginRoomPropertiesBatchOperation(false, isDeleteAfterOwnerLeft: true, isUpdateOwner: false)
        ZegoUIKit.getSignalingPlugin().updateRoomProperty("\(seatModel.index)", value: userID, callback: nil)
        ZegoUIKit.getSignalingPlugin().deleteRoomProperties(["\(oldIndex)"], callBack: nil)
        ZegoUIKit.getSignalingPlugin().endRoomPropertiesBatchOperation { data in
            self.isSwitchingSeat = false
            guard let data = data else { return }
            if data["code"] as! Int == 0 {
                self.updateLayout()
            }
        }
    }
    
    func getSeatIndexByUserID(_ userID: String) -> Int {
        guard let roomProporty = ZegoUIKit.getSignalingPlugin().getRoomProperties() else { return -1 }
        var index = -1
        for key in roomProporty.keys {
            if roomProporty[key] == userID {
                index = Int(key) ?? -1
                break
            }
        }
        return index
    }
    
    func requestMicPermission(_ needDelay: Bool = false) {
        var requestMicEnd: Bool = false
        self.isShowMicPermissionAlter = true
        if !ZegoLiveAudioAuthorizedCheck.isMicrophoneAuthorizationDetermined() {
            requestMicEnd = false
            //not determined
            ZegoLiveAudioAuthorizedCheck.requestMicphoneAccess {
                //agree
                requestMicEnd = true
                self.showMicAlter(requestMicEnd, needDelay: false)
            } cancelCompletion: {
                //disagree
                requestMicEnd = true
                self.showMicAlter(requestMicEnd, needDelay: false)
            }
        } else {
            requestMicEnd = true
            self.showMicAlter(requestMicEnd, needDelay: needDelay)
        }
    }
    
    func showMicAlter(_ showMic: Bool, needDelay: Bool) {
        if needDelay {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.delayExecution(showMic)
            }
        } else {
            self.delayExecution(showMic)
        }
    }
    
    func delayExecution(_ showMic: Bool) {
        if showMic {
            if !ZegoLiveAudioAuthorizedCheck.isMicrophoneAuthorized() {
                ZegoLiveAudioAuthorizedCheck.showMicrophoneUnauthorizedAlert(self.config.translationText, viewController: self) {
                    ZegoLiveAudioAuthorizedCheck.openAppSettings()
                } cancelCompletion: {
                    
                }
            }
        }
    }
    
    fileprivate func applicationHasMicAccess() {
        self.isShowMicPermissionAlter = true
        // determined but not authorized
        if !ZegoLiveAudioAuthorizedCheck.isMicrophoneAuthorized() {
            ZegoLiveAudioAuthorizedCheck.showMicrophoneUnauthorizedAlert(self.config.translationText, viewController: self) {
                ZegoLiveAudioAuthorizedCheck.openAppSettings()
            } cancelCompletion: {
                print("cancel")
            }
        } else {
            print("#####")
        }
    }
    
}


class ZegoUIKitPrebuiltLiveAudioVC_Help: NSObject,ZegoUIKitEventHandle, LeaveButtonDelegate,ZegoLiveAudioRoomBottomBarDelegate {
    
    weak var liveAudioVC: ZegoUIKitPrebuiltLiveAudioRoomVC?
    
    func onMenuBarMoreButtonClick(_ buttonList: [UIView]) {
        let newList:[UIView] = buttonList
        let vc: ZegoLiveAudioMoreView = ZegoLiveAudioMoreView()
        vc.buttonList = newList
        self.liveAudioVC?.view.addSubview(vc.view)
        self.liveAudioVC?.addChild(vc)
    }
    
    func onInRoomMessageButtonClick() {
        self.liveAudioVC?.inputTextView.startEdit()
    }
    
    func onLeaveButtonClick(_ isLeave: Bool) {
        
        guard let _ = liveAudioVC else { return }
        if isLeave {
            ZegoUIKit.getSignalingPlugin().leaveRoom { data in
                ZegoUIKit.getSignalingPlugin().loginOut()
            }
            self.liveAudioVC?.dismiss(animated: true)
            self.liveAudioVC?.delegate?.onLeaveLiveAudioRoom?()
        }
    }
    
    func onUsersInRoomAttributesUpdated(_ updateKeys: [String]?, oldAttributes: [ZegoUserInRoomAttributesInfo]?, attributes: [ZegoUserInRoomAttributesInfo]?, editor: ZegoUIKitUser?) {
        self.liveAudioVC?.usersInRoomAttributes = attributes
        self.liveAudioVC?.updateLayout()
    }
    
    func onRoomPropertyUpdated(_ key: String, oldValue: String, newValue: String) {
        guard let userID = self.liveAudioVC?.userID else { return }
        self.liveAudioVC?.roomProperties.updateValue(newValue, forKey: key)
        if oldValue == userID && newValue == "" {
            self.liveAudioVC?.currentRole = .audience
            ZegoUIKit.shared.turnMicrophoneOn(userID, isOn: false)
            if self.liveAudioVC?.currentSeatAction == .leave {
                self.liveAudioVC?.currentSheetView?.disMiss()
                self.liveAudioVC?.currentAlterView?.dismiss(animated: false, completion: nil)
            }
        } else if oldValue != userID && oldValue == self.liveAudioVC?.currentClickSeatModel?.userID && newValue == "" {
            if self.liveAudioVC?.currentSeatAction == .remove {
                self.liveAudioVC?.currentSheetView?.disMiss()
                self.liveAudioVC?.currentAlterView?.dismiss(animated: false, completion: nil)
            }
        }
        self.liveAudioVC?.updateLayout()
    }
    
}
