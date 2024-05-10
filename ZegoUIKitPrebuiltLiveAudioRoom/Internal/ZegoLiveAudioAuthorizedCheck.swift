//
//  ZegoLiveAudioAuthorizedCheck.swift
//  ZegoUIKitPrebuiltLiveAudio
//
//  Created by zego on 2022/11/21.
//

import UIKit
import AVFoundation
import Photos

enum ZegoAlterType: Int {
case micAlter
}

class ZegoLiveAudioAuthorizedCheck: NSObject {
    
    static func requestMicphoneAccess(okCompletion: @escaping () -> Void, cancelCompletion: @escaping () -> Void) {
        AVCaptureDevice.requestAccess(for: .audio, completionHandler: { (statusFirst) in
            if statusFirst {
                DispatchQueue.main.async {
                    okCompletion()
                }

            } else {
                DispatchQueue.main.async {
                    cancelCompletion()
                }
            }
        })

    }

    static func requestCameraAccess(okCompletion: @escaping () -> Void, cancelCompletion: @escaping () -> Void) {
        AVCaptureDevice.requestAccess(for: .video, completionHandler: { (statusFirst) in
            if statusFirst {
                DispatchQueue.main.async {
                    okCompletion()
                }
            } else {
                DispatchQueue.main.async {
                    cancelCompletion()
                }
            }
        })

    }

    static func isMicrophoneAuthorized() -> Bool {
        let status: AVAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .audio)
        return status == .authorized
    }

    static func isMicrophoneAuthorizationDetermined() -> Bool {
        let status: AVAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .audio)
        return status != .notDetermined
    }

    static func isMicrophoneNotDeterminedOrAuthorized() -> Bool {
        let status: AVAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .audio)
        return status == .notDetermined || status == .authorized
    }

    static func isCameraAuthorized() -> Bool {
        let status: AVAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
        return status == .authorized
    }

    static func isCameraAuthorizationDetermined() -> Bool {
        let status: AVAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
        return status != .notDetermined
    }

    static func isCameraNotDeterminedOrAuthorized() -> Bool {
        let status: AVAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
        return status == .notDetermined || status == .authorized
    }

    static func isPhotoAuthorized() -> Bool {
        let status: PHAuthorizationStatus
        if #available(iOS 14, *) {
            status = PHPhotoLibrary.authorizationStatus(for: .addOnly)
        } else {
            // Fallback on earlier versions
            status = PHPhotoLibrary.authorizationStatus()
        }
        return status == .authorized
    }

    static func isPhotoAuthorizationDetermined() -> Bool {
        let status: PHAuthorizationStatus
        if #available(iOS 14, *) {
            status = PHPhotoLibrary.authorizationStatus(for: .addOnly)
        } else {
            // Fallback on earlier versions
            status = PHPhotoLibrary.authorizationStatus()
        }
        return status != .notDetermined
    }

    // MARK: - Action
    static func takeCameraAuthorityStatus(completion: ((Bool) -> Void)?) {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            guard let completion = completion else { return }
            completion(granted)
        }
    }

    static func takeMicPhoneAuthorityStatus(completion: ((Bool) -> Void)?) {
        AVCaptureDevice.requestAccess(for: .audio) { granted in
            guard let completion = completion else { return }
            completion(granted)
        }
    }

    static func showMicrophoneUnauthorizedAlert(_ text: ZegoTranslationText, viewController: UIViewController, okCompletion: @escaping () -> Void, cancelCompletion: @escaping () -> Void) {
        showAlert(text, .micAlter, viewController, okCompletion: okCompletion, cancelCompletion: cancelCompletion)
    }


    private static func showAlert(_ text: ZegoTranslationText,
                                  _ type: ZegoAlterType,
                                  _ viewController: UIViewController,
                                  okCompletion: @escaping () -> Void, cancelCompletion: @escaping () -> Void) {
        var title: String = ""
        var message: String = ""
        var cancelStr: String = ""
        var sureStr: String = ""
       if type == .micAlter {
            title = text.microphonePermissionTitle
            message = text.microphonePermissionMessage
            cancelStr = text.memberListTitle
            sureStr = text.microphonePermissionConfirmButtonName
        }
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: cancelStr, style: .cancel) { action in
            cancelCompletion()
        }
        let okAction = UIAlertAction(title: sureStr, style: .default) { action in
            okCompletion()
        }
        alert.addAction(cancelAction)
        alert.addAction(okAction)
        viewController.present(alert, animated: true, completion: nil)
    }

    static func openAppSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}
