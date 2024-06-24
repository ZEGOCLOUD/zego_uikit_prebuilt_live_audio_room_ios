//
//  LiveAudioRoomVCApi.swift
//  ZegoUIKitPrebuiltLiveAudioRoom
//
//  Created by zego on 2024/1/18.
//

import Foundation

public protocol LiveAudioRoomVCApi {
    func addButtonToMenuBar(_ button: UIButton, role: ZegoLiveAudioRoomRole)
    func clearBottomBarExtendButtons(_ role: ZegoLiveAudioRoomRole) 
    func setBackgroundView(_ view: UIView)
    
    //MARK: 自定义上麦
    func applyToTakeSeat(callback: ((_ errorCode: Int,_ errorMsg: String) -> Void)?)
    func cancelSeatTakingRequest()
//    func takeSeat(index:Int)
    func leaveSeat()
    func acceptSeatTakingRequest(audienceUserID:String)
    func rejectSeatTakingRequest(audienceUserID:String)
    func inviteAudienceToTakeSeat(audienceUserID:String)
    func acceptHostTakeSeatInvitation()
    func openSeats()
    func closeSeats()
    func removeSpeakerFromSeat(userID:String)
    func leaveRoom()
}
