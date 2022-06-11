//
//  CLBAlbumAssetModel.swift
//  Album
//
//  Created by xinweizhou on 2021/12/8.
//

import UIKit
import Photos

enum CLBAlbumAssetMediaType {
    // Image
    case photo
    case livePhoto
    case gifPhoto
    
    case video 
    case audio
    case unknow
    
    init?(asset: PHAsset?) {
        if asset?.mediaType == .video {
            self = .video
        } else if asset?.mediaType == .audio {
            self = .audio
        } else if asset?.mediaType == .image {
            if asset!.mediaSubtypes.contains(.photoLive) {
                self = .livePhoto
            } else if let suffix = asset?.value(forKey: "filename") as? String, suffix.hasSuffix("GIF") {
                self = .gifPhoto
            } else {
                self = .photo
            }
        } else {
            self = .unknow
        }
        
//        return nil
    }
}

class CLBAlbumAssetModel: NSObject {
    var phAsset: PHAsset?
    var isSelected: Bool = false
    var type: CLBAlbumAssetMediaType?
    var duration: String?
    var isCloudFailed: Bool = false
    
    init(asset: PHAsset) {
        super.init()
        self.phAsset = asset
        self.type = CLBAlbumAssetMediaType(asset: asset)
        if self.type == .video {
            self.duration = self.formularTime(time: asset.duration)
        }
    }
    
    private func formularTime(time: TimeInterval?) -> String? {
        guard let t = time else {
            return nil
        }
        if t < 10 {
            return String(format: "00:%02.0f", t)
        } else if t < 60 {
            return String(format: "00:%02.0f", t)
        } else {
            let minite = Int(t / 60)
            let second = Int(t) - minite * 60
            return String(format: "%02d:%02d", minite, second)
        }
        
    }
    
}
extension CLBAlbumAssetModel: XWZAlbumAssetProtocol {}

protocol XWZAlbumAssetProtocol {
    var phAsset: PHAsset? { get }
    var type: CLBAlbumAssetMediaType? { get }
    var duration: String? { get }
    var isCloudFailed: Bool { get set }
}
