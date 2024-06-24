//
//  ZegoUIKitPrebuiltLiveAudioRoomVCDelegate.swift
//  ZegoUIKitPrebuiltLiveAudioRoom
//
//  Created by zego on 2024/1/18.
//

import Foundation
import ZegoUIKit

@objc public protocol ZegoUIKitPrebuiltLiveAudioRoomVCDelegate: AnyObject {
    @objc optional func getSeatForegroundView(_ userInfo: ZegoUIKitUser?, seatIndex: Int) -> ZegoBaseAudioVideoForegroundView?
    @objc optional func onLeaveLiveAudioRoom()
//    @objc optional func onUserCountOrPropertyChanged(_ users: [ZegoUIKitUser]?)
}

@objc public protocol ZegoSeatTakingRequestAudienceDelegate: AnyObject {
    @objc optional func onSeatTakingRequestRejected();

    @objc optional func onHostSeatTakingInviteSent();
}

@objc public protocol ZegoSeatTakingRequestHostDelegate: AnyObject {
    @objc optional func onSeatTakingRequested(audience: ZegoUIKitUser);

    @objc optional func onSeatTakingRequestCancelled(audience: ZegoUIKitUser);

    @objc optional func onSeatTakingInviteRejected(audience: ZegoUIKitUser);
}

@objc public protocol ZegoUserCountOrPropertyChangedDelegate: AnyObject {
    @objc optional func onUserCountOrPropertyChanged(userList: [ZegoUIKitUser]);
}

@objc public protocol ZegoSeatChangedDelegate: AnyObject {
    @objc optional func onSeatsChanged(takenSeats:[Int: ZegoUIKitUser], untakenSeats: [Int]);
}

@objc public protocol ZegoSeatsLockedDelegate: AnyObject {
    @objc optional func onSeatsClosed();

    @objc optional func onSeatsOpened();
}

@objc public protocol ZegoInRoomMessageCustomerItemDelegate :AnyObject {
  @objc optional func getInRoomMessageItemView(_ tableView: UITableView, indexPath: IndexPath, message: ZegoInRoomMessage) -> UITableViewCell?
}

@objc public protocol ZegoSeatClickedDelegate :AnyObject {
    @objc optional func onSeatClicked(_ index: Int, userInfo: ZegoUIKitUser?)
}

@objc public protocol ZegoMemberListMoreButtonPressedDelegate: NSObjectProtocol {
    @objc optional func onMemberListMoreButtonPressed(user:ZegoUIKitUser);
}
