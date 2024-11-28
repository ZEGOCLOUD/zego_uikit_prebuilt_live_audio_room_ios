//
//  ZegoUIKitPrebuiltLiveAudioVC.swift
//  ZegoUIKitPrebuiltLiveAudio
//
//  Created by zego on 2022/11/15.
//

import UIKit
import ZegoUIKit
import ZegoUIKitSignalingPlugin
import ZegoPluginAdapter
enum ZegoLiveAudioSeatActionType: Int {
    case take
    case leave
    case remove
}

extension ZegoUIKitPrebuiltLiveAudioRoomVC: LiveAudioRoomVCApi {
    
    @objc  public func addButtonToMenuBar(_ button: UIButton, role: ZegoLiveAudioRoomRole) {
        self.bottomBar.addButtonToMenuBar(button, role: role)
    }
    
    @objc  public func clearBottomBarExtendButtons(_ role: ZegoLiveAudioRoomRole) {
        self.bottomBar.clearBottomBarExtendButtons(role)
    }
    
    @objc public func setBackgroundView(_ view: UIView) {
        self.backgroundView.setBackgroundView(view)
    }
  
    @objc public func applyToTakeSeat(callback: ((Int, String) -> Void)?) {
        self.bottomBar.applyToTakeSeat(callback: callback)
    }
    
    @objc public func cancelSeatTakingRequest() {
        self.bottomBar.cancelSeatTakingRequest()
    }
    
    @objc public func acceptSeatTakingRequest(audienceUserID:String) {
        ZegoUIKit.getSignalingPlugin().acceptInvitation(audienceUserID, data: nil, callback: nil)
        self.addOrRemoveSeatListUser(ZegoUIKitUser(audienceUserID, audienceUserID), isAdd: false)
    }
    
    @objc public func rejectSeatTakingRequest(audienceUserID:String) {
        ZegoUIKit.getSignalingPlugin().refuseInvitation(audienceUserID, data: nil)
        self.addOrRemoveSeatListUser(ZegoUIKitUser(audienceUserID, audienceUserID), isAdd: false)
    }
    
    @objc public func inviteAudienceToTakeSeat(audienceUserID:String) {
        ZegoUIKit.getSignalingPlugin().sendInvitation([audienceUserID], timeout: 60, type: 3, data: nil, notificationConfig: nil) { data in
            guard let data = data else { return }
            if data["code"] as! Int == 0 {
            } else {
            }
        }
    }
    
    @objc public func acceptHostTakeSeatInvitation() {
        if self.currentHost?.userID == nil {return}
        self.requestCameraAndMicPermission()
        ZegoUIKit.getSignalingPlugin().acceptInvitation((self.currentHost?.userID)!, data: nil, callback: nil)
        let seatIndex = self.findFirstAvailableSeatIndex()
        if seatIndex != Int.max {
            self.updateRoomProperty(seatIndex: self.findFirstAvailableSeatIndex()) {success  in
            }
        } else {
            self.bottomBar.resetApplySeatStateNormal()
        }
    }
    
    @objc public func openSeats() {
        self.openOrLockedSeats(lock: false)
    }
    
    @objc public func closeSeats() {
        self.openOrLockedSeats(lock: true)
    }
    
    @objc public func removeSpeakerFromSeat(userID:String) {
        self.removeSeat(self.findSeatIndexWithUserID(userID: userID))
    }
    
    @objc public func leaveSeat() {
        self.leaveSeat(self.findSeatIndexWithUserID(userID:self.userID ?? ""))
    }
    
    @objc public func leaveRoom() {
        self.help.onLeaveButtonClick(true)
    }
}

public class ZegoUIKitPrebuiltLiveAudioRoomVC: UIViewController {
    
    @objc public weak var delegate: ZegoUIKitPrebuiltLiveAudioRoomVCDelegate?
    
    @objc public var inRoomMessageViewConfig: ZegoInRoomMessageViewConfig = ZegoInRoomMessageViewConfig() {
        didSet{
          self.messageView.isHidden = !self.inRoomMessageViewConfig.inRoomMessageViewVisible
        }
    }
    
    let inputViewHeight: CGFloat = 55
    var userID: String?
    var userName: String?
    var roomID: String?
    var requestCoHostCount: Int = 0
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
    weak var invitateAlter: UIAlertController?
    //host
    var audienceSeatList: [ZegoUIKitUser] = []
    var hostInviteList: [ZegoUIKitUser] = []
    var coHostList: [ZegoUIKitUser] = []
    //audience
    var audienceInviteList: [ZegoUIKitUser] = []
    var audienceReceiveInviteList: [ZegoUIKitUser] = []
    var seatLock:Bool = true
    
    weak var seatTakingRequestAudienceDelegate: ZegoSeatTakingRequestAudienceDelegate?
    weak var seatTakingRequestHostDelegate: ZegoSeatTakingRequestHostDelegate?
    weak var userCountOrPropertyChangedDelegate: ZegoUserCountOrPropertyChangedDelegate?
    weak var seatChangedDelegate: ZegoSeatChangedDelegate?
    weak var seatsLockedDelegate: ZegoSeatsLockedDelegate?
    /// Initialization of chat room
    /// - Parameters:
    ///   - appID: Your appID
    ///   - appSign: Your appSign
    ///   - userID: User unique identification
    ///   - userName: userName
    ///   - roomID: Chat room ID
    ///   - config: Personalized configuration
    @objc public init(_ appID: UInt32, appSign: String, userID: String, userName: String, roomID: String, config: ZegoUIKitPrebuiltLiveAudioRoomConfig) {
        super.init(nibName: nil, bundle: nil)
        let zegoLanguage: ZegoUIKitLanguage = config.translationText.getLanguage()
        let zegoUIKitLanguage = ZegoUIKitLanguage(rawValue: zegoLanguage.rawValue)!
        ZegoUIKitTranslationTextConfig.shared.translationText = ZegoUIKitTranslationText(language: zegoUIKitLanguage);
        
        if (config.role == .host || config.role == .speaker) && config.takeSeatIndexWhenJoining < 0 {
            config.role = .audience
            config.takeSeatIndexWhenJoining = -1
        } else if config.role == .speaker && config.hostSeatIndexes.contains(config.takeSeatIndexWhenJoining) {
            config.role = .audience
            config.takeSeatIndexWhenJoining = -1
        }
        self.config = config
        self.seatLock = config.closeSeatsWhenJoin
        ZegoUIKit.getSignalingPlugin().installPlugins([ZegoUIKitSignalingPlugin()])
        ZegoUIKit.shared.initWithAppID(appID: appID, appSign: appSign)
        ZegoUIKit.shared.setAudioVideoResourceMode(.RTCOnly)
        ZegoUIKit.getSignalingPlugin().initWithAppID(appID: appID, appSign: appSign)
        //        ZegoUIKit.shared.localUserInfo = ZegoUIKitUser.init(userID, userName)
        ZegoUIKit.shared.addEventHandler(self.help)
        self.userID = userID
        self.userName = userName
        self.roomID = roomID
        
        if config.role == .host {
            self.currentHost = ZegoUIKitUser.init(userID, userName)
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
        let bar = ZegoLiveAudioRoomBottomBar(frame: CGRectZero)
        bar.controller = self
        bar.config = self.config
        bar.delegate = self.help
        bar.currentHost = self.currentHost
        return bar
    }()
    
    lazy var messageView: ZegoInRoomMessageView = {
        
      if self.inRoomMessageViewConfig.roomMessageDelegate == nil{
        let messageList = ZegoInRoomMessageView()
        messageList.isHidden = !self.inRoomMessageViewConfig.inRoomMessageViewVisible
        return messageList
      } else {
        let messageList = ZegoInRoomMessageView(frame: CGRectZero, customerRegisterCell: true)
        messageList.isHidden = !self.inRoomMessageViewConfig.inRoomMessageViewVisible
        messageList.delegate = self.help
        return messageList
      }
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
        self.view.backgroundColor = UIColor.colorWithHexString("#F4F4F6")
        self.view.addSubview(self.backgroundView)
        self.view.addSubview(self.leaveButton)
        self.view.addSubview(self.containerView)
        self.view.addSubview(self.bottomBar)
        self.view.addSubview(self.messageView)
        self.view.addSubview(self.inputTextView)
        self.joinRoom()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame(node:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.setupLayout()
    }
    
    @objc public func registerInRoomMessageItemView(_ cellClass: AnyClass?, forCellReuseIdentifier: String) {
      self.messageView.registerClassForCellReuseIdentifier(cellClass, forCellReuseIdentifier: forCellReuseIdentifier)
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
        self.messageView.frame = CGRect(x: 0, y: self.view.frame.size.height - 62 - 200, width: UIKitLiveAudioScreenWidth - 16 - 89, height: 200)
        self.bottomBar.frame = CGRect(x: 0, y: self.view.frame.size.height - 62, width: self.view.frame.size.width, height: 62)
        
    }
    
    func setContainerFrame() {
        var height: Int = self.config.layoutConfig.rowConfigs.count * Int(UIKitLiveAudioSeatHeight)
        let space: Int = self.config.layoutConfig.rowSpecing * (self.config.layoutConfig.rowConfigs.count - 1)
        height = height + space
        self.containerView.frame = CGRect(x: 15, y: Int(self.leaveButton.frame.maxY) + 36, width: Int(UIScreen.main.bounds.size.width) - 30, height: height)
        
    }
    
    private func joinRoom() {
        guard let roomID = self.roomID,
              let userID = self.userID,
              let userName = self.userName
        else { return }
        ZegoUIKit.shared.joinRoom(userID, userName: userName, roomID: roomID) { errorCode in
            
        }
        if self.config.turnOnMicrophoneWhenJoining {
            self.requestMicPermission(true)
        }
        ZegoUIKit.shared.turnMicrophoneOn(self.userID ?? "", isOn: self.config.turnOnMicrophoneWhenJoining)
        ZegoUIKit.shared.turnCameraOn(self.userID ?? "", isOn: false)
        ZegoUIKit.getSignalingPlugin().login(userID, userName: userName) { data in
            guard let data = data else { return }
            if data["code"] as! Int == 0 {
                self.joinRTCAndZIMRoom { errorCode in
                    if errorCode == 6000323 {
                        ZegoUIKit.getSignalingPlugin().leaveRoom { data in
                            self.joinRTCAndZIMRoom(callback: nil)
                        }
                    }
                }
            }
        }
    }
    
    func joinRTCAndZIMRoom(callback: ((Int) -> Void)?) {
        ZegoUIKit.getSignalingPlugin().joinRoom(roomID: self.roomID!) { data in
            guard let data = data else { return }
            let code = data["code"] as! Int
            if code == 0  {
                self.currentRole = .audience
                //set avata  url
                ZegoUIKit.getSignalingPlugin().setUsersInRoomAttributes("avatar", value: self.config.userAvatarUrl ?? "", userIDs: [self.userID!], roomID: self.roomID!, callBack: nil)
                self.setCurrentUserAttributes()
                self.joinRoomAfterUpdateRoomInfo()
                self.queryInRoomUserAttribute()
                self.setSeatLockState()
            } else {
                print("login IM fail")
            }
            callback?(code)
        }
    }
    func setSeatLockState() {
        if self.config.role == .host {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.bottomBar.lockSeatButton?.isLock = self.seatLock
                ZegoUIKit.shared.setRoomProperty("lockseat", value: self.seatLock ? "1" : "0", callback: ZegoUIKitCallBack? {data in
                    
                })
            }
        }
    }
    
    func openOrLockedSeats(lock:Bool) {
        self.seatLock = lock
        self.bottomBar.lockSeatButton?.isLock = self.seatLock
        ZegoUIKit.shared.setRoomProperty("lockseat", value: self.seatLock ? "1" : "0", callback: ZegoUIKitCallBack? {data in
            
        })
    }
    
    private func setCurrentUserAttributes() {
        guard let userInRoomAttributes = config.userInRoomAttributes,
              let userID = userID,
              let roomID = roomID
        else { return }
        for (key, value) in userInRoomAttributes {
            ZegoUIKit.getSignalingPlugin().setUsersInRoomAttributes(key, value: value, userIDs: [userID], roomID: roomID, callBack: nil)
        }
    }
    
    func queryInRoomUserAttribute() {
        ZegoUIKit.getSignalingPlugin().queryRoomProperties { data in
            print("queryInRoomUserAttribute \(String(describing: data))")
            guard let data = data else { return }
            let code: Int = data["code"] as? Int ?? 0
            if code == 0 {
                self.roomProperties = data["roomAttributes"] as! [String : String]
                self.updateLayout()
                self.updateCurrentRole()
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
    func updateCurrentRole() {
        if self.config.role != .host {
            if self.roomProperties.values.contains(self.userID ?? "") {
                self.currentRole = .speaker
                ZegoUIKit.shared.turnMicrophoneOn(self.userID ?? "", isOn: true)
                ZegoUIKit.shared.turnCameraOn(self.userID ?? "", isOn: false)
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
    
    func setLayoutSeatToLock(_ lock : Bool) {
        self.containerView.setSeatLockToSeatItemView(lock)
    }
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.view.endEditing(true)
    }
    
    
    deinit {
        print("===ZegoUIKitPrebuiltLiveAudioVC deinit")
    }
    
    @objc public func setSeatTakingRequestAudienceObserve(_ observe:ZegoSeatTakingRequestAudienceDelegate) {
        self.seatTakingRequestAudienceDelegate = observe
    }
    
    @objc public func setSeatTakingRequestHostObserve(_ observe:ZegoSeatTakingRequestHostDelegate) {
        self.seatTakingRequestHostDelegate = observe
    }
    
    @objc public func setUserCountOrPropertyChangedObserve(_ observe:ZegoUserCountOrPropertyChangedDelegate) {
        self.userCountOrPropertyChangedDelegate = observe
    }
    
    @objc public func setSeatChangedObserve(_ observe:ZegoSeatChangedDelegate) {
        self.seatChangedDelegate = observe
    }
    
    @objc public func setSeatsLockedObserve(_ observe:ZegoSeatsLockedDelegate) {
        self.seatsLockedDelegate = observe
    }
}

extension ZegoUIKitPrebuiltLiveAudioRoomVC: ZegoLiveAudioContainerViewDelegate, ZegoLiveAudioSheetViewDelegate {
    
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
    func getSeatForegroundView(_ userInfo: ZegoUIKitUser?, seatIndex: Int) -> ZegoBaseAudioVideoForegroundView? {
        if let foregroundView = self.delegate?.getSeatForegroundView?(userInfo, seatIndex: seatIndex) {
            return foregroundView
        } else {
            // user normal foregroundView
            let normalForegroundView: ZegoLiveAudioNormalForegroundView = ZegoLiveAudioNormalForegroundView(frame: .zero, userID: userInfo?.userID, delegate: nil)
            normalForegroundView.userInfo = userInfo
            if self.config.role == .host {
                normalForegroundView.isHost = self.currentHost?.userID == userInfo?.userID
            } else {
                normalForegroundView.isHost = self.queryUserIsHost(userInfo)
                if normalForegroundView.isHost {
                    self.currentHost = userInfo
                }
                
                if self.currentHost?.userID == userInfo?.userID, !normalForegroundView.isHost {
                    self.currentHost = nil
                }
            }
            return normalForegroundView
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
        if self.config.seatConfig.seatClickedDelegate != nil {
            self.config.seatConfig.seatClickedDelegate?.onSeatClicked?(seatModel.index, userInfo: ZegoUIKitUser(seatModel.userID, seatModel.userName))
            return
        }
        currentClickSeatModel = seatModel
        guard let roomProperty = ZegoUIKit.getSignalingPlugin().getRoomProperties() else { return }
        if self.currentRole == .host {
            //remove seat
            if roomProperty.keys.contains("\(seatModel.index)") && seatModel.userID != self.userID {
                self.currentSeatAction = .remove
                self.showSheetView([self.config.translationText.muteSpeakerMicDialogButton.replacingOccurrences(of: "%@", with: self.currentClickSeatModel?.userName ?? ""),self.config.translationText.removeSpeakerMenuDialogButton.replacingOccurrences(of: "%@", with: self.currentClickSeatModel?.userName ?? ""),self.config.translationText.cancelMenuDialogButton])
            }
        } else if self.currentRole == .speaker {
            //switch seat or leave seat
            if self.config.hostSeatIndexes.contains(seatModel.index) {
                return
            }
            if roomProperty.keys.contains("\(seatModel.index)") && seatModel.userID == self.userID {
                self.currentSeatAction = .leave
                self.showSheetView([self.config.translationText.leaveSeatMenuDialogButton,self.config.translationText.cancelMenuDialogButton])
            } else if !roomProperty.keys.contains("\(seatModel.index)") {
                //switch seat
                if seatModel.lock {
                    return
                }
                self.switchSeat(seatModel)
            }
        } else if self.currentRole == .audience {
            //take seat
            if self.config.hostSeatIndexes.contains(seatModel.index) {
                return
            }
            if roomProperty.keys.contains("\(seatModel.index)") {
                print("Seat has been taken")
            } else {
                if seatModel.lock {
                    return
                }
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
                //观众上麦
                guard let currentClickSeatModel = self.currentClickSeatModel else { return }
                self.takeSeat(currentClickSeatModel.index)
            } else if currentSeatAction == .remove {
                //静音麦上成员
                ZegoUIKit.shared.turnMicrophoneOn(self.currentClickSeatModel?.userID ?? "", isOn: false, mute: true)
            } else {
                self.showSeatAlter()
            }
        } else if index == 1 {
            if currentSeatAction == .remove {
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
            alterTitle = self.config.translationText.leaveSeatMenuDialogButton
            alterMessage = self.config.translationText.leaveSeatDialogInfoMessage
            cancelName = self.config.translationText.cancelMenuDialogButton
            sureName = self.config.translationText.leaveRoomDialogConfirmButtonTitle
        case .remove:
            alterTitle = self.config.translationText.removeSpeakerFromSeatDialogInfoTitle
            alterMessage = self.config.translationText.removeSpeakerFromSeatDialogInfoMessage.replacingOccurrences(of: "%@", with: self.currentClickSeatModel?.userName ?? "")
            cancelName = self.config.translationText.cancelMenuDialogButton
            sureName = self.config.translationText.leaveRoomDialogConfirmButtonTitle
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
    
    func findFirstAvailableSeatIndex () -> Int {
        var allSeats:Int = 0
        var emptySeatIndex:Int = 1
        for rowConfig in self.config.layoutConfig.rowConfigs {
            allSeats  = allSeats + rowConfig.count
        }
        for seatNumber in 1...allSeats {
            if roomProperties["\(seatNumber)"] == nil {
                emptySeatIndex = seatNumber
                break
            }
        }
        
        return (emptySeatIndex < allSeats) ? emptySeatIndex : Int.max
    }
    
    func findSeatIndexWithUserID(userID:String) -> Int {
        var seatIndex:Int?
        for (key, value) in self.roomProperties {
            if value == userID {
                seatIndex = Int(key)
            }
        }
        return seatIndex ?? 0
    }
    
    @objc public func takeSeat(_ seatIndex: Int) {
        if isShowMicPermissionAlter {
            self.applicationHasMicAccess()
        } else {
            self.requestMicPermission(true)
        }
        self.updateRoomProperty(seatIndex: seatIndex)
    }
    
    func updateRoomProperty(seatIndex: Int, callback: ((Bool) -> Void)? = nil) {
        ZegoUIKit.getSignalingPlugin().updateRoomProperty("\(seatIndex)", value: self.userID ?? "", isDeleteAfterOwnerLeft: true, isForce: false, isUpdateOwner: false) { data in
            guard let data = data else { return }
            if data["code"] as! Int == 0 {
                self.currentRole = .speaker
                self.roomProperties.updateValue(self.userID ?? "", forKey: "\(seatIndex)")
                self.updateLayout()
                ZegoUIKit.shared.turnMicrophoneOn(self.userID ?? "", isOn: true)
                ZegoUIKit.shared.turnCameraOn(self.userID ?? "", isOn: false)
                callback?(true)
                
            } else {
                callback?(false)
                
            }
        }
    }
    
    func leaveSeat(_ index: Int) {
        if index == 0 {return}
        ZegoUIKit.getSignalingPlugin().deleteRoomProperties(["\(index)"], isForce: true) { data in
            guard let data = data else { return }
            if data["code"] as! Int == 0 {
                self.currentRole = .audience
                self.roomProperties.removeValue(forKey: "\(index)")
                self.updateLayout()
                ZegoUIKit.shared.turnMicrophoneOn(self.userID ?? "", isOn: false)
                if self.seatLock {
                    if !self.config.bottomMenuBarConfig.audienceButtons.contains(.applyTakeSeatButton) {
                        self.config.bottomMenuBarConfig.audienceButtons.insert(.applyTakeSeatButton, at: 0)
                    }
                } else {
                    if self.config.bottomMenuBarConfig.audienceButtons.contains(.applyTakeSeatButton) {
                        self.config.bottomMenuBarConfig.audienceButtons.remove(at:0)
                        self.bottomBar.config = self.config
                    }
                }
                self.bottomBar.config = self.config
                
            }
        }
    }
    
    func removeSeat(_ index: Int) {
        if index == 0 {return}
        guard let roomProperties = ZegoUIKit.getSignalingPlugin().getRoomProperties() else { return }
        if roomProperties.keys.contains("\(index)") {
            ZegoUIKit.getSignalingPlugin().deleteRoomProperties(["\(index)"], isForce: true) { data in
                guard let data = data else { return }
                if data["code"] as! Int != 0  {
                    let message = self.config.translationText.removeSpeakerFailedToast.replacingOccurrences(of: "%@", with: self.currentClickSeatModel?.userName ?? "")
                    ZegoLiveAudioTipView.showWarn(message, onView: self.view)
                } else {
                    self.roomProperties.removeValue(forKey: "\(index)")
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
                self.roomProperties.removeValue(forKey: "\(oldIndex)")
                self.roomProperties.updateValue(self.userID ?? "", forKey: "\(seatModel.index)")
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
    
    func addOrRemoveSeatListUser(_ user: ZegoUIKitUser, isAdd: Bool) {
        if isAdd {
            self.audienceSeatList.append(user)
        } else {
            self.audienceSeatList = self.audienceSeatList.filter({
                return $0.userID != user.userID
            })
        }
        self.updateRequestCoHost(user, isAdd: isAdd)
        self.bottomBar.memberButton.requestCoHostList = self.audienceSeatList
    }
    
    func addOrRemoveHostInviteList(_ user: ZegoUIKitUser, isAdd: Bool) {
        if isAdd {
            self.hostInviteList.append(user)
        } else {
            self.hostInviteList = self.hostInviteList.filter({
                return $0.userID != user.userID
            })
        }
        self.bottomBar.memberButton.hostInviteList = self.hostInviteList
    }
    
    func addOrRemoveAudienceInviteList(_ user: ZegoUIKitUser, isAdd: Bool) {
        if isAdd {
            self.audienceInviteList.append(user)
        } else {
            self.audienceInviteList.removeAll()
        }
        self.bottomBar.audienceInviteList = self.audienceInviteList
    }
    
    func addOrRemoveAudienceReceiveInviteList(_ user: ZegoUIKitUser, isAdd: Bool) {
        if isAdd {
            self.audienceReceiveInviteList.append(user)
        } else {
            self.audienceReceiveInviteList.removeAll()
        }
    }
    
    func updateRequestCoHost(_ user: ZegoUIKitUser, isAdd: Bool) {
        if isAdd {
            self.requestCoHostCount = self.requestCoHostCount + 1
        } else {
            self.requestCoHostCount = (self.requestCoHostCount - 1) < 0 ? 0 : self.requestCoHostCount - 1
        }
        if self.seatLock == false {
            self.requestCoHostCount = 0
        }
        self.bottomBar.showRedDot = self.requestCoHostCount > 0
    }
    
    func requestCameraAndMicPermission(_ needDelay: Bool = false) {
        var requestCamerEnd: Bool = false
        var requestMicEnd: Bool = false
        if !ZegoLiveAudioAuthorizedCheck.isCameraAuthorizationDetermined() {
            requestCamerEnd = false
            //not determined
            ZegoLiveAudioAuthorizedCheck.requestCameraAccess {
                //agree
                requestCamerEnd = true
                self.showCameraOrMicAlter(requestCamerEnd, showMic: requestMicEnd, needDelay: false)
            } cancelCompletion: {
                //disagree
                requestCamerEnd = true
                self.showCameraOrMicAlter(requestCamerEnd, showMic: requestMicEnd, needDelay: false)
            }
        } else {
            requestCamerEnd = true
            self.showCameraOrMicAlter(requestCamerEnd, showMic: requestMicEnd, needDelay: needDelay)
        }
        
        if !ZegoLiveAudioAuthorizedCheck.isMicrophoneAuthorizationDetermined() {
            requestMicEnd = false
            //not determined
            ZegoLiveAudioAuthorizedCheck.requestMicphoneAccess {
                //agree
                requestMicEnd = true
                self.showCameraOrMicAlter(requestCamerEnd, showMic: requestMicEnd, needDelay: false)
            } cancelCompletion: {
                //disagree
                requestMicEnd = true
                self.showCameraOrMicAlter(requestCamerEnd, showMic: requestMicEnd, needDelay: false)
            }
        } else {
            requestMicEnd = true
            self.showCameraOrMicAlter(requestCamerEnd, showMic: requestMicEnd, needDelay: needDelay)
        }
    }
    
    func showCameraOrMicAlter(_ showCamera: Bool, showMic: Bool, needDelay: Bool) {
        if needDelay {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.delayExecution(showMic: showMic)
            }
        } else {
            self.delayExecution(showMic: showMic)
        }
    }
    
    func delayExecution( showMic: Bool) {
        if showMic {
            if !ZegoLiveAudioAuthorizedCheck.isMicrophoneAuthorized() {
                ZegoLiveAudioAuthorizedCheck.showMicrophoneUnauthorizedAlert(self.config.translationText, viewController: self) {
                    ZegoLiveAudioAuthorizedCheck.openAppSettings()
                } cancelCompletion: {
                    
                }
            }
        }
    }
    
    //MARK: Customer
    func onIncomingAcceptCohostRequest(invitee: ZegoUIKitUser, data: String?) {
        if self.config.role != .host && self.currentRole == .audience{
            // is host accept
            // update bottom bar button
            self.requestCameraAndMicPermission()
            let seatIndex = self.findFirstAvailableSeatIndex()
            if seatIndex != Int.max {
                self.updateRoomProperty(seatIndex: self.findFirstAvailableSeatIndex())
            } else {
                self.bottomBar.resetApplySeatStateNormal()
            }
        }
        self.addOrRemoveSeatListUser(invitee, isAdd: false)
        self.addOrRemoveHostInviteList(invitee, isAdd: false)
    }
    
    func onIncomingCohostRequest(inviter: ZegoUIKitUser) {
        if self.currentRole == .host {
            self.addOrRemoveSeatListUser(inviter, isAdd: true)
            self.seatTakingRequestHostDelegate?.onSeatTakingRequested?(audience: inviter)
        }
    }
    
    func onIncomingInviteToCohostRequest(inviter: ZegoUIKitUser, invitationID: String) {
        guard let userID = inviter.userID else { return }
        self.seatTakingRequestAudienceDelegate?.onHostSeatTakingInviteSent?()
        self.addOrRemoveAudienceReceiveInviteList(inviter, isAdd: true)
        self.bottomBar.receiveHostInviteCancelOwnerApply()
        self.showInvitationAlert(userID, invitationID: invitationID)
    }
    
    
    func onIncomingRemoveCohostRequest(inviter: ZegoUIKitUser) {
        self.addOrRemoveAudienceInviteList(inviter, isAdd: false)
        self.addOrRemoveAudienceReceiveInviteList(inviter, isAdd: false)
        self.bottomBar.curRole = .audience
        ZegoUIKit.shared.turnCameraOn(self.userID ?? "", isOn: false)
        ZegoUIKit.shared.turnMicrophoneOn(self.userID ?? "", isOn: false)
        self.updateConfigMenuBar(.audience)
    }
    
    func onIncomingCancelCohostRequest(inviter: ZegoUIKitUser, data: String?) {
        self.addOrRemoveSeatListUser(inviter, isAdd: false)
        self.seatTakingRequestHostDelegate?.onSeatTakingRequestCancelled?(audience: inviter)
    }
    
    func onIncomingCancelCohostInvite(inviter: ZegoUIKitUser, data: String?) {
        self.invitateAlter?.dismiss(animated: false)
        self.addOrRemoveAudienceReceiveInviteList(inviter, isAdd: false)
    }
    
    func onIncomingRefuseCohostInvite(invitee: ZegoUIKitUser, data: String?) {
        let user: ZegoUIKitUser? = ZegoUIKit.shared.getUser(invitee.userID ?? "")
        guard let user = user else { return }
        self.seatTakingRequestHostDelegate?.onSeatTakingInviteRejected?(audience: invitee)
        ZegoLiveAudioTipView.showWarn(String(format: "%@ %@", user.userName ?? "",self.config.translationText.audienceRejectInvitationToast), onView: self.view)
        self.addOrRemoveSeatListUser(invitee, isAdd: false)
        self.addOrRemoveHostInviteList(invitee, isAdd: false)
    }
    
    func onIncomingRefuseCohostRequest(invitee: ZegoUIKitUser, data: String?) {
        self.seatTakingRequestAudienceDelegate?.onSeatTakingRequestRejected?()
        self.addOrRemoveAudienceInviteList(invitee, isAdd: false)
        if self.seatLock {
            ZegoLiveAudioTipView.showWarn(self.config.translationText.hostRejectCoHostRequestToast, onView: self.view)
        }
        self.updateConfigMenuBar(.audience)
    }
    
    func onIncomingCohostInviteTimeOut(inviter: ZegoUIKitUser, data: String?) {
        self.addOrRemoveSeatListUser(inviter, isAdd: false)
    }
    
    func onIncomingCohostRequestTimeOut(inviter: ZegoUIKitUser, data: String?) {
        self.addOrRemoveAudienceReceiveInviteList(inviter, isAdd: false)
    }
    
    func onIncomingCohostInviteResponseTimeOut(invitees: [ZegoUIKitUser], data: String?) {
        for invitee in invitees {
            self.addOrRemoveHostInviteList(invitee, isAdd: false)
        }
    }
    
    func onIncomingCohostRequestResponseTimeOut(invitees: [ZegoUIKitUser], data: String?) {
        for invitee in invitees {
            self.addOrRemoveAudienceInviteList(invitee, isAdd: false)
        }
        self.bottomBar.curRole = .audience
        self.updateConfigMenuBar(.audience)
    }
    func showInvitationAlert(_ inviterID: String, invitationID: String?) {
        
        let workItem = DispatchWorkItem {
            self.invitateAlter?.dismiss(animated: false)
        }
        
        let title: String = self.config.translationText.receivedCoHostInvitationDialogInfoTitle
        let message: String = self.config.translationText.receivedCoHostInvitationDialogInfoMessage
        let cancelStr: String = self.config.translationText.receivedCoHostInvitationDialogInfoCancel
        let sureStr: String = self.config.translationText.receivedCoHostInvitationDialogInfoConfirm
        
        let alterView: UIAlertController = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
        self.invitateAlter = alterView
        let cancelButton: UIAlertAction = UIAlertAction.init(title: cancelStr, style: .cancel) { action in
            let dataDict: [String : AnyObject] = ["invitationID": invitationID as AnyObject]
            ZegoUIKit.getSignalingPlugin().refuseInvitation(inviterID, data: dataDict.audio_jsonString)
            self.addOrRemoveAudienceReceiveInviteList(ZegoUIKitUser.init(inviterID, ""), isAdd: false)
            workItem.cancel()
        }
        
        let sureButton: UIAlertAction = UIAlertAction.init(title: sureStr, style: .default) { action in
            if self.currentRole == .audience {
                self.requestCameraAndMicPermission()
                ZegoUIKit.getSignalingPlugin().acceptInvitation(inviterID, data: nil, callback: nil)
                let seatIndex = self.findFirstAvailableSeatIndex()
                if seatIndex != Int.max {
                    self.updateRoomProperty(seatIndex: self.findFirstAvailableSeatIndex()) {success  in
                        
                    }
                } else {
                    self.bottomBar.resetApplySeatStateNormal()
                }
            }
            workItem.cancel()
        }
        alterView.addAction(cancelButton)
        alterView.addAction(sureButton)
        self.present(alterView, animated: false, completion: nil)
        // 一分钟后隐藏视图
        DispatchQueue.main.asyncAfter(deadline: .now() + 60.0, execute: workItem)
    }
    
    func cancelMyInvitations() {
        if self.currentRole != .host {
            return
        }
        var inviteUserIDList:[String] = []
        if let inviteList = self.bottomBar.memberButton.hostInviteList {
            
            for user in inviteList {
                inviteUserIDList.append(user.userID ?? "")
                self.addOrRemoveHostInviteList(user, isAdd: false)
            }
        }
        ZegoUIKit.getSignalingPlugin().cancelInvitation(inviteUserIDList , data: "") { data in
            self.bottomBar.memberButton.hostInviteList = []
        }
    }
    func refuseAllRequest () {
        if self.currentRole != .host {
            return
        }
        if let requestList = self.bottomBar.memberButton.requestCoHostList {
            
            for user in requestList {
                self.addOrRemoveSeatListUser(user, isAdd: false)
                ZegoUIKit.getSignalingPlugin().refuseInvitation(user.userID ?? "", data: "")
            }
        }
        
    }
}


class ZegoUIKitPrebuiltLiveAudioVC_Help: NSObject,ZegoUIKitEventHandle, LeaveButtonDelegate,ZegoLiveAudioRoomBottomBarDelegate,ZegoInRoomMessageViewDelegate {
    
    weak var liveAudioVC: ZegoUIKitPrebuiltLiveAudioRoomVC?
    func onMenuBarMoreButtonClick(_ buttonList: [UIView]) {
        let newList:[UIView] = buttonList
        let vc: ZegoLiveAudioMoreView = ZegoLiveAudioMoreView()
        vc.buttonList = newList
        self.liveAudioVC?.view.addSubview(vc.view)
        self.liveAudioVC?.addChild(vc)
    }
    
    func onLeaveButtonClick(_ isLeave: Bool) {
        if isLeave {
            self.liveAudioVC?.cancelMyInvitations()
            self.liveAudioVC?.bottomBar.cancelOwnerApply()
            ZegoUIKit.getSignalingPlugin().leaveRoom { data in
                ZegoUIKit.getSignalingPlugin().loginOut()
            }
            liveAudioVC?.dismiss(animated: true)
            liveAudioVC?.delegate?.onLeaveLiveAudioRoom?()
        }
    }
    
    func onInRoomMessageButtonClick() {
        liveAudioVC?.inputTextView.startEdit()
    }
    
    func onDidClickAgree(_ user: ZegoUIKitUser) {
        liveAudioVC?.addOrRemoveSeatListUser(user, isAdd: false)
    }
    
    func onDidClickDisagree(_ user: ZegoUIKitUser) {
        liveAudioVC?.addOrRemoveSeatListUser(user, isAdd: false)
    }
    
    func onDidClickInvite(_ user: ZegoUIKitUser) {
        guard let liveAudioVC = liveAudioVC else {
            return
        }
        liveAudioVC.addOrRemoveHostInviteList(user, isAdd: true)
    }
    
    func onInvitationReceived(_ inviter: ZegoUIKitUser, type: Int, data: String?) {
        let dataDic: Dictionary? = data?.audio_convertStringToDictionary()
        let pluginInvitationID: String = dataDic?["invitationID"] as? String ?? ""
        
        if type == 2 {// apply
            liveAudioVC?.onIncomingCohostRequest(inviter: inviter)
        } else if type == 3 {//invite
            liveAudioVC?.onIncomingInviteToCohostRequest(inviter: inviter, invitationID: pluginInvitationID)
        } else if type == 4 {//remove
            liveAudioVC?.onIncomingRemoveCohostRequest(inviter: inviter)
        }
    }
    
    func onInvitationAccepted(_ invitee: ZegoUIKitUser, data: String?) {
        //      let dataDic: Dictionary? = data?.audio_convertStringToDictionary()
        //      let pluginInvitationID: String = dataDic?["invitationID"] as? String ?? ""
        liveAudioVC?.onIncomingAcceptCohostRequest(invitee: invitee, data: data)
    }
    
    func onInvitationRefused(_ invitee: ZegoUIKitUser, data: String?) {
        //      let dataDic: Dictionary? = data?.audio_convertStringToDictionary()
        //      let pluginInvitationID: String = dataDic?["invitationID"] as? String ?? ""
        if liveAudioVC?.currentRole == .host {
            liveAudioVC?.onIncomingRefuseCohostInvite(invitee: invitee, data: data)
        } else {
            liveAudioVC?.onIncomingRefuseCohostRequest(invitee: invitee, data: data)
        }
    }
    
    func onInvitationCanceled(_ inviter: ZegoUIKitUser, data: String?) {
        if liveAudioVC?.currentRole == .host {
            liveAudioVC?.onIncomingCancelCohostRequest(inviter: inviter, data: data)
        } else {
            liveAudioVC?.onIncomingCancelCohostInvite(inviter: inviter, data: data)
        }
    }
    
    func onInvitationTimeout(_ inviter: ZegoUIKitUser, data: String?) {
        //      let dataDic: Dictionary? = data?.audio_convertStringToDictionary()
        //      let pluginInvitationID: String = dataDic?["invitationID"] as? String ?? ""
        if liveAudioVC?.currentRole == .host {
            liveAudioVC?.onIncomingCohostInviteTimeOut(inviter: inviter, data: data)
        } else {
            liveAudioVC?.onIncomingCohostRequestTimeOut(inviter: inviter, data: data)
        }
    }
    
    func onInvitationResponseTimeout(_ invitees: [ZegoUIKitUser], data: String?) {
        //      let dataDic: Dictionary? = data?.audio_convertStringToDictionary()
        //      let pluginInvitationID: String = dataDic?["invitationID"] as? String ?? ""
        if liveAudioVC?.currentRole == .host {
            liveAudioVC?.onIncomingCohostInviteResponseTimeOut(invitees: invitees, data: data)
        } else {
            liveAudioVC?.onIncomingCohostRequestResponseTimeOut(invitees: invitees, data: data)
        }
    }
    func onRoomPropertyUpdated(_ key: String, oldValue: String, newValue: String) {
        if key == "lockseat" {
            if newValue == "1" {
                self.liveAudioVC?.seatLock = true
                self.liveAudioVC?.setLayoutSeatToLock(true)
                self.liveAudioVC?.seatsLockedDelegate?.onSeatsClosed?()
            } else {
                self.liveAudioVC?.seatLock = false
                self.liveAudioVC?.setLayoutSeatToLock(false)
                self.liveAudioVC?.bottomBar.hostUnlockSeatCancelOwnerApply()
              self.liveAudioVC?.seatsLockedDelegate?.onSeatsOpened?()
            }
            if liveAudioVC?.currentRole == .audience {
                if newValue == "1" {
                    if ((self.liveAudioVC?.config.bottomMenuBarConfig.audienceButtons.contains(.applyTakeSeatButton)) == false) {
                        self.liveAudioVC?.config.bottomMenuBarConfig.audienceButtons.insert(.applyTakeSeatButton, at: 0)
                    }
                } else {
                    if ((self.liveAudioVC?.config.bottomMenuBarConfig.audienceButtons.contains(.applyTakeSeatButton)) == true) {
                        self.liveAudioVC?.config.bottomMenuBarConfig.audienceButtons.remove(at: 0)
                    }
                }
                self.liveAudioVC?.bottomBar.config = self.liveAudioVC?.config ?? ZegoUIKitPrebuiltLiveAudioRoomConfig.audience()
            }
            self.liveAudioVC?.cancelMyInvitations()
            self.liveAudioVC?.refuseAllRequest()
            self.liveAudioVC?.bottomBar.memberButton.seatLock = (newValue as NSString).boolValue
        }
    }
    
    
    func onUsersInRoomAttributesUpdated(_ updateKeys: [String]?, oldAttributes: [ZegoUserInRoomAttributesInfo]?, attributes: [ZegoUserInRoomAttributesInfo]?, editor: ZegoUIKitUser?) {
//        print("nRoomAttributesUpdated \(String(describing: attributes))")
        
        // Update the user's role
        // the live vc's usersInRoomAttributes only used to set user role.
        guard let attributes = attributes else { return }
        for attribute in attributes {
            if attribute.attributes.keys.contains("role") {
                let oldAttribute = self.liveAudioVC?.usersInRoomAttributes?.filter({ $0.userID == attribute.userID }).first
                if oldAttribute == nil {
                    self.liveAudioVC?.usersInRoomAttributes?.append(attribute)
                } else {
                    oldAttribute?.attributes = attribute.attributes
                }
            }
        }
        self.liveAudioVC?.updateLayout()
    }
    
    func onRoomMemberLeft(_ userIDList: [String]?, roomID: String) {
//        print("[ZIM connectionState] user", userIDList ?? "")
        if self.liveAudioVC?.currentRole != .host {
            if let userIDList = userIDList {
                for userID in userIDList {
                    if userID == self.liveAudioVC?.currentHost?.userID {
                        self.liveAudioVC?.currentHost = nil
                    }
                }
            }
        }
    }
    
    func onSignalPluginRoomPropertyUpdated(_ key: String, oldValue: String, newValue: String) {
        guard let userID = self.liveAudioVC?.userID else { return }
        self.liveAudioVC?.roomProperties.updateValue(newValue, forKey: key)
        if oldValue == userID && newValue == "" {
            // 自己下麦
            self.liveAudioVC?.currentRole = .audience
            ZegoUIKit.shared.turnMicrophoneOn(userID, isOn: false)
            if self.liveAudioVC?.currentSeatAction == .leave {
                self.liveAudioVC?.currentSheetView?.disMiss()
                self.liveAudioVC?.currentAlterView?.dismiss(animated: false, completion: nil)
            }
            self.liveAudioVC?.roomProperties.removeValue(forKey: key)
        } else if oldValue != userID && oldValue == self.liveAudioVC?.currentClickSeatModel?.userID && newValue == "" {
            if self.liveAudioVC?.currentSeatAction == .remove {
                self.liveAudioVC?.currentSheetView?.disMiss()
                self.liveAudioVC?.currentAlterView?.dismiss(animated: false, completion: nil)
            }
            self.liveAudioVC?.roomProperties.removeValue(forKey: key)
        } else if oldValue != userID && newValue == "" {
            // 别人下麦
            if self.liveAudioVC?.currentSeatAction == .remove {
                self.liveAudioVC?.currentSheetView?.disMiss()
                self.liveAudioVC?.currentAlterView?.dismiss(animated: false, completion: nil)
            }
            self.liveAudioVC?.roomProperties.removeValue(forKey: key)
            
        }
        self.liveAudioVC?.updateLayout()
    }
    
    func onUserCountOrPropertyChanged(_ userList: [ZegoUIKitUser]?) {
//        self.liveAudioVC?.delegate?.onUserCountOrPropertyChanged?(userList)
        self.liveAudioVC?.userCountOrPropertyChangedDelegate?.onUserCountOrPropertyChanged?(userList: userList ?? [])
    }
    
  
    func onSignalPluginRoomPropertyFullUpdated(_ updateKeys: [String], oldProperties: [String : String], properties: [String : String]) {
        var takenSeats = [Int:ZegoUIKitUser]()
        var untakenSeats = [Int]()
        
        var allSeats:Int = 0
        if let rowConfigs = self.liveAudioVC?.config.layoutConfig.rowConfigs as? [ZegoLiveAudioRoomLayoutRowConfig] {
            for rowConfig in rowConfigs {
                allSeats  = allSeats + rowConfig.count
            }
        }
        guard allSeats > 1 else {
            return
        }
        for seatNumber in 0...(allSeats - 1) {
            if self.liveAudioVC?.roomProperties["\(seatNumber)"] == nil {
                untakenSeats.append(seatNumber)
            } else {
                let userID:String = self.liveAudioVC?.roomProperties["\(seatNumber)"] ?? ""
                takenSeats.updateValue(ZegoUIKitUser(userID, userID), forKey: seatNumber)
            }
        }
        
        self.liveAudioVC?.seatChangedDelegate?.onSeatsChanged?(takenSeats: takenSeats, untakenSeats: untakenSeats)
    }
    func onRoomStateChanged(_ reason: ZegoUIKitRoomStateChangedReason, errorCode: Int32, extendedData: [AnyHashable : Any], roomID: String) {
//        print("[RTC connectionState] reason = \(reason) errorCode = \(errorCode)")
    }
    
    func onIMRoomStateChanged(_ state: Int, event: Int, roomID: String) {
        
//        print("[ZIM RoomStateChanged]",state,event,roomID)
        //ZIMRoomStateDisconnected ZIMRoomEventConnectTimeout
        if state == 0 && event == 9 {
            ZegoUIKit.getSignalingPlugin().clearRoomInfo()
            ZegoUIKit.getSignalingPlugin().joinRoom(roomID: self.liveAudioVC?.roomID ?? "") { data in
                self.liveAudioVC?.queryInRoomUserAttribute()
                self.liveAudioVC?.currentRole = .audience
                ZegoUIKit.shared.turnMicrophoneOn(self.liveAudioVC?.userID ?? "", isOn: false)
                ZegoUIKit.shared.turnCameraOn(self.liveAudioVC?.userID ?? "", isOn: false)
            }
        } else if state == 2 {
            //ZIMRoomStateConnected
            self.liveAudioVC?.queryInRoomUserAttribute()
        }
    }
  
  //ZegoInRoomMessageViewDelegate
  func getInRoomMessageItemView(_ tableView: UITableView, indexPath: IndexPath, message: ZegoInRoomMessage) -> UITableViewCell? {
    if self.liveAudioVC?.inRoomMessageViewConfig.roomMessageDelegate != nil {
      return self.liveAudioVC?.inRoomMessageViewConfig.roomMessageDelegate?.getInRoomMessageItemView?(tableView, indexPath: indexPath, message: message)
    } else {
      return nil
    }
    
  }
}
