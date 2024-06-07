//
//  ZegoLiveAudioContainerView.swift
//  ZegoUIKitPrebuiltLiveAudio
//
//  Created by zego on 2022/11/21.
//

import UIKit
import ZegoUIKit

protocol ZegoLiveAudioContainerViewDelegate: AnyObject {
    func getSeatForegroundView(_ userInfo: ZegoUIKitUser?, seatIndex: Int) -> ZegoBaseAudioVideoForegroundView?
    func onSeatItemClick(_ seatModel: ZegoLiveAudioSeatModel?)
}

class ZegoSeatRowModel: NSObject {
    var seatSpacing: Int = 0
    var seatModels: [ZegoLiveAudioSeatModel] = []
    var alignment: ZegoLiveAudioRoomLayoutAlignment = .center
}

protocol ZegoSeatRowViewDelegate: AnyObject {
    func getSeatForegroundView(_ userInfo: ZegoUIKitUser?, seatIndex: Int) -> ZegoBaseAudioVideoForegroundView?
    func onSeatItemClick(_ seatModel: ZegoLiveAudioSeatModel?)
}

class ZegoSeatRowView: UIView, ZegoLiveAudioSeatItemViewDelegate {
    
    weak var delegate: ZegoSeatRowViewDelegate?
    var index: Int = 0
    
    var seatConfig: ZegoLiveAudioRoomSeatConfig? {
        didSet {
            for itemView in seatItemList {
                itemView.seatConfig = seatConfig
            }
        }
    }
    
    var seatRowModel: ZegoSeatRowModel? {
        didSet {
            guard let seatRowModel = seatRowModel else { return }
            self.clearAllItemView()
            for seatModel in seatRowModel.seatModels {
                let itemView: ZegoLiveAudioSeatItemView = ZegoLiveAudioSeatItemView()
                itemView.backgroundColor = self.seatConfig?.backgroundColor ?? UIColor.clear
                itemView.currSeatModel = seatModel
                itemView.delegate = self
                self.seatItemList.append(itemView)
            }
            self.setupUI()
        }
    }
    var seatItemList: [ZegoLiveAudioSeatItemView] = []
    var currentHost: ZegoUIKitUser? {
        didSet {
            for seatView in seatItemList {
                seatView.currentHost = currentHost
            }
        }
    }
    var currentRole: ZegoLiveAudioRoomRole = .audience {
        didSet {
            for seatView in seatItemList {
                seatView.currentRole = currentRole
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.setupUI()
    }
    
    func clearAllItemView() {
        for itemView in seatItemList {
            itemView.removeFromSuperview()
        }
        seatItemList.removeAll()
    }
    
    func setupUI() {
        guard let seatRowModel = seatRowModel else {
            return
        }
        let itemWidth: CGFloat = CGFloat(UIkitLiveAudioSeatHeight)
        let itemHeight: CGFloat = CGFloat(UIkitLiveAudioSeatHeight)
        var startX: CGFloat = 0
        var maxSpace: CGFloat = 0
        if seatRowModel.seatModels.count <= 1 {
            maxSpace = self.frame.size.width
        } else {
            maxSpace = (self.frame.size.width - itemWidth * CGFloat(seatRowModel.seatModels.count)) / CGFloat(seatRowModel.seatModels.count - 1)
        }
        let itemSpace: CGFloat = CGFloat(seatRowModel.seatSpacing) > maxSpace ? maxSpace : CGFloat(seatRowModel.seatSpacing)
        
        switch seatRowModel.alignment {
        case .center:
            startX = (self.frame.size.width - (itemWidth * CGFloat(seatRowModel.seatModels.count)) - (itemSpace * CGFloat(seatRowModel.seatModels.count))) * 0.5
        case .start:
            startX = 0
        case .end:
            startX = (self.frame.size.width - (itemWidth * CGFloat(seatRowModel.seatModels.count)) - (itemSpace * CGFloat(seatRowModel.seatModels.count)))
        case .spaceAround,.spaceBetween,.spaceEvenly:
            break
        }
        
        var index = 0
        for itemView in seatItemList {
            switch seatRowModel.alignment {
            case .center,.start,.end:
                itemView.frame = CGRect(x: startX + (itemWidth * CGFloat(index) + (itemSpace * CGFloat(index))), y: 0, width: itemWidth, height: itemHeight)
            case .spaceBetween:
                let newItemSpace = (self.frame.size.width - itemWidth * CGFloat(seatItemList.count)) / CGFloat(seatItemList.count - 1)
                itemView.frame = CGRect(x: (itemWidth * CGFloat(index) + (newItemSpace * CGFloat(index))), y: 0, width: itemWidth, height: itemHeight)
            case .spaceAround:
                let newItemSpace = (self.frame.size.width - itemWidth * CGFloat(seatItemList.count)) / CGFloat(seatItemList.count)
                let x: CGFloat = newItemSpace * 0.5
                itemView.frame = CGRect(x: x + (itemWidth * CGFloat(index) + (newItemSpace * CGFloat(index))), y: 0, width: itemWidth, height: itemHeight)
            case .spaceEvenly:
                let newItemSpace = (self.frame.size.width - itemWidth * CGFloat(seatItemList.count)) / CGFloat(seatItemList.count + 1)
                let x: CGFloat = newItemSpace
                itemView.frame = CGRect(x: x + (itemWidth * CGFloat(index) + newItemSpace * CGFloat(index)), y: 0, width: itemWidth, height: itemHeight)
            }
            self.addSubview(itemView)
            index = index + 1
        }
    }
    
    func setLayoutSeatToEmptySeatView(_ index: Int) {
        guard let seatRowModel = seatRowModel else {
            return
        }
        for seatModel in seatRowModel.seatModels {
            if seatModel.index == index {
                seatModel.userID = ""
            }
        }
        self.updateSeat()
    }
    
    func setLayoutSeatToAudioVideoView(_ value: String, index: Int) {
        guard let seatRowModel = seatRowModel else {
            return
        }
        for seatModel in seatRowModel.seatModels {
            if seatModel.index == index {
                seatModel.userID = value
            }
        }
        self.updateSeat()
    }
  
    func setSeatLockToSeatItemView(_ lock: Bool) {
        guard let seatRowModel = seatRowModel else {
            return
        }
        for seatModel in seatRowModel.seatModels {
            seatModel.lock = lock
        }
        self.updateSeat()
    }
    
    func updateSeat() {
        guard let seatRowModel = seatRowModel else {
            return
        }
        for view in seatItemList {
            for model in seatRowModel.seatModels {
                if view.currSeatModel?.index == model.index {
                    view.currSeatModel = model
                }
            }
            view.seatConfig = seatConfig
        }
    }
    
    //MARK: -ZegoLiveAudioSeatItemViewDelegate
    func getSeatForegroundView(_ userInfo: ZegoUIKitUser?, seatIndex: Int) -> ZegoBaseAudioVideoForegroundView? {
        return self.delegate?.getSeatForegroundView(userInfo, seatIndex: seatIndex)
    }
    
    func onSeatItemClick(_ seatModel: ZegoLiveAudioSeatModel?) {
        self.delegate?.onSeatItemClick(seatModel)
    }
    
}

class ZegoLiveAudioContainerView: UIView {
    
    var config: ZegoUIKitPrebuiltLiveAudioRoomConfig? {
        didSet {
            self.createSeatModel()
            self.createSeatItemView()
            self.setupUI()
        }
    }
    
    var currentRole: ZegoLiveAudioRoomRole = .audience {
        didSet {
            for view in seatRowViewList {
                view.currentRole = currentRole
            }
        }
    }
    
    weak var delegate: ZegoLiveAudioContainerViewDelegate?
    var seatRowModelList: [ZegoSeatRowModel] = []
    var seatRowViewList: [ZegoSeatRowView] = []
    var currentHost: ZegoUIKitUser? {
        didSet {
            for view in seatRowViewList {
                view.currentHost = currentHost
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.setupUI()
    }
    
    lazy var seatItem: ZegoLiveAudioSeatItemView = {
        let seatItem = ZegoLiveAudioSeatItemView(frame: CGRect(x: 0, y: 0, width: UIkitLiveAudioSeatWidth, height: UIkitLiveAudioSeatHeight))
        return seatItem
    }()
    
    func setupUI() {
        guard let config = config else {
            return
        }
        let rowHeight: CGFloat = 75
        let maxRowSpace: CGFloat = (self.frame.size.height - (rowHeight * CGFloat(self.seatRowViewList.count))) / CGFloat(self.seatRowViewList.count - 1)
        let rowSpace: CGFloat = CGFloat(config.layoutConfig.rowSpecing) > maxRowSpace ? maxRowSpace : CGFloat(config.layoutConfig.rowSpecing)
        var index = 0
        for seatRowView in self.seatRowViewList {
            let y: CGFloat = rowHeight * CGFloat(index) + rowSpace * CGFloat(index)
            seatRowView.frame = CGRect(x: 0, y: y, width: self.frame.size.width, height: rowHeight)
            self.addSubview(seatRowView)
            index = index + 1
        }
    }
    
    func setLayoutSeatToEmptySeatView(_ index: Int) {
        for view in self.seatRowViewList {
            view.setLayoutSeatToEmptySeatView(index)
        }
    }
    
    func setLayoutSeatToAudioVideoView(_ value: String, index: Int) {
        for view in self.seatRowViewList {
            view.setLayoutSeatToAudioVideoView(value, index: index)
        }
    }
    func setSeatLockToSeatItemView(_ lock: Bool) {
      for view in self.seatRowViewList {
          view.setSeatLockToSeatItemView(lock)
      }
    }
}

extension ZegoLiveAudioContainerView: ZegoSeatRowViewDelegate {
    
    func createSeatModel() {
        self.clearAllSeatList()
        guard let config = self.config else { return }
        var seatIndex: Int = 0
        for rowConfig in config.layoutConfig.rowConfigs {
            let seatRowModel: ZegoSeatRowModel = ZegoSeatRowModel()
            seatRowModel.alignment = rowConfig.alignment
            seatRowModel.seatSpacing = rowConfig.seatSpacing
            let count: Int = rowConfig.count
            for _ in (0..<count) {
                let seatModel: ZegoLiveAudioSeatModel = ZegoLiveAudioSeatModel.init(index: seatIndex, userID: "", userName: "", extras: "",lock: false)
                seatIndex = seatIndex + 1
                seatRowModel.seatModels.append(seatModel)
            }
            self.seatRowModelList.append(seatRowModel)
        }
    }
    
    func clearAllSeatList() {
        self.seatRowModelList.removeAll()
    }
    
    func createSeatItemView() {
        self.clearAllItemView()
        var index = 0
        for model in self.seatRowModelList {
            let seatRowView: ZegoSeatRowView = ZegoSeatRowView()
            seatRowView.seatConfig = self.config?.seatConfig
            seatRowView.seatRowModel = model
            seatRowView.index = index
            seatRowView.currentRole = self.currentRole
            seatRowView.delegate = self
            self.seatRowViewList.append(seatRowView)
            index = index + 1
        }
    }
    
    func clearAllItemView() {
        for itemView in self.seatRowViewList {
            itemView.clearAllItemView()
            itemView.removeFromSuperview()
        }
        self.seatRowViewList.removeAll()
    }
    
    
    //MARK: - ZegoSeatRowViewDelegate
    func getSeatForegroundView(_ userInfo: ZegoUIKitUser?, seatIndex: Int) -> ZegoBaseAudioVideoForegroundView? {
        return self.delegate?.getSeatForegroundView(userInfo, seatIndex: seatIndex)
    }
    
    func onSeatItemClick(_ seatModel: ZegoLiveAudioSeatModel?) {
        self.delegate?.onSeatItemClick(seatModel)
    }
}
