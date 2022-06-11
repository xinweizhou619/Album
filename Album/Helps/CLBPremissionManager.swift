//
//  CMCPremissionManager.swift
//  FreeTranslate
//
//  Created by wkcloveYang on 2020/6/16.
//  Copyright © 2020 FreeTranslate. All rights reserved.
//

import UIKit
import Photos
import AppTrackingTransparency

class CLBPremissionManager: NSObject {
    
    static func checkCameraPermission(completion: @escaping ((Bool) -> ())) {
        let status: AVAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
        if status == .authorized {
            completion(true);
        } else if status == .notDetermined {
            AVCaptureDevice.requestAccess(for: .video) { (granted) in
                DispatchQueue.main.async {
                    completion(granted)
                }
            }
        } else {
            completion(false)
        }
    }
    
    
    
    // MARK: 系统的图片选择, 不需要权限访问
    // MARK: 自定义相册需要权限处理
    enum CLBAlbumState: Int {
        case authorized
        case unauthorized
        case limited
    }
    
    static func checkAlbumPermission(completion: @escaping ((CLBAlbumState) -> ())) {
        if #available(iOS 14, *) {
            checkAlbumPremissionAbove14(completion: completion)
        } else {
            checkAlbumPremissionBelow14(completion: completion)
        }
    }
    
    static fileprivate func checkAlbumPremissionAbove14(completion: @escaping ((CLBAlbumState) -> ())) {
        if #available(iOS 14, *) {
            let level = PHAccessLevel.readWrite
            let status = PHPhotoLibrary.authorizationStatus(for: level)
            if status == .authorized {
                DispatchQueue.main.async {
                    completion(.authorized)
                }
            } else if status == .notDetermined {
                PHPhotoLibrary.requestAuthorization(for: level) { (tStatus) in
                    DispatchQueue.main.async {
                        if tStatus == .authorized {
                            completion(.authorized)
                        } else if tStatus == .limited {
                            completion(.limited)
                        } else {
                            completion(.unauthorized)
                        }
                    }
                }
            } else if status == .limited {
                DispatchQueue.main.async {
                    completion(.limited)
                }
            } else {
                DispatchQueue.main.async {
                    completion(.unauthorized)
                }
            }
        }
    }
    
    static fileprivate func checkAlbumPremissionBelow14(completion: @escaping ((CLBAlbumState) -> ())) {
        let status: PHAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        if status == .authorized {
            DispatchQueue.main.async {
                completion(.authorized)
            }
        } else if status == .notDetermined {
            PHPhotoLibrary.requestAuthorization { (tStatus) in
                DispatchQueue.main.async {
                    completion(tStatus == .authorized ? .authorized : .unauthorized)
                }
            }
        } else {
            DispatchQueue.main.async {
                completion(.unauthorized)
            }
        }
    }
}
