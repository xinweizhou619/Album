//
//  CLBAlbumVideoPreviewView.swift
//  Album
//
//  Created by xinweizhou on 2022/1/13.
//

import UIKit
import Photos
import AVFoundation

/// CLBAlbumAssetMediaType {
//video
//}
class CLBAlbumVideoPreviewView: UIView {

    private var player: AVPlayer!
    private var playerLayer: AVPlayerLayer!
    
    private lazy var playBtn: UIButton = {
        let view = UIButton(type: .system)
        view.isUserInteractionEnabled = false
        let image = UIImage(named: "privacy_album_play")?.withRenderingMode(.alwaysOriginal)
        view.setImage(image, for: .normal)
        return view
    }()
    
    
    ///  占位图片（显示 视频预览图 或者 iCloudErrorIcon）
    private lazy var placeHImageV: UIImageView = {
        let view = UIImageView()
        view.isUserInteractionEnabled = true
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setUp()
    }
    
    private func setUp() {
        //
        self.addSubview(self.placeHImageV)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(gestureTap))
        self.placeHImageV.addGestureRecognizer(tapGesture)
        
        //
        self.player = AVPlayer()
        self.player.actionAtItemEnd = .pause
        self.storePlayLayer()
        //
        self.addSubview(self.playBtn)
        
        //
        NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidPlayToEndTime(noti:)), name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    private func storePlayLayer() {
        
        if self.playerLayer != nil {
            self.playerLayer.removeFromSuperlayer()
        }
        self.playerLayer = AVPlayerLayer(player: self.player)
        self.placeHImageV.layer.addSublayer(self.playerLayer)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
//    override func updateConstraints() {
//        super.updateConstraints()
//    self.frame 还没有值
//        self.reloadLayout()
//    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    
        self.reloadLayout()
    }
    
    private var requestId: PHImageRequestID?
    private(set) var model: XWZAlbumAssetProtocol?

    func showContent(model: XWZAlbumAssetProtocol?) {
        model.map { model in
            self.setVideo(with: model)
        }
    }
    
    func prepare(model: XWZAlbumAssetProtocol?) {
        self.model = model
        //
        model.map { model in
            self.setImage(with: model)
        }
        
        //
        self.reloadLayout()
    }
    
    
    func reset() {
        self.stopPlay()
        self.placeHImageV.image = nil
    }
    
    func stopPlay() {
        self.player.pause()
        self.player.replaceCurrentItem(with: nil)
        self.playBtn.isHidden = false
    }
    
    private var playItem: AVPlayerItem?
    private func setVideo(with asset: XWZAlbumAssetProtocol) {
        _ = CLBAlbumMediaPickerManager.shared.getVideo(asset: asset.phAsset!, progressHandler: nil) { playItem, info in
            // 这里使用容易卡，这里做播放赋值
//            self.player.replaceCurrentItem(with: playItem)
            
            self.playItem = playItem
        }
    }
    
    private func setImage(with asset: XWZAlbumAssetProtocol) {
        if let id = self.requestId {
            PHImageManager.default().cancelImageRequest(id)
        }
        
        self.requestId = CLBAlbumMediaPickerManager.shared.getPreviewOriginImage(assets: asset) { photo, error  in
            if let err = error {
                if CLBAlbumMediaPickerManager.isCloudSyncError(error: err) == true {
                    debugPrint("icloud error")
                } else {
                    debugPrint("other error")
                }
                return
            }
           
            DispatchQueue.global().async {
                let img = UIImage.sd_decodedImage(with: photo)
                DispatchQueue.main.async {
                    self.placeHImageV.image = img
                }
            }
            
            //
            self.requestId = nil
            
        }
    }
    
    
    private func reloadLayout() {
        
        guard self.bounds.width > 0, self.bounds.height > 0, self.model != nil else {
            return
        }
        
        let baseHeight = self.bounds.height
        let baseWidth = self.bounds.width
        
        // 初步处理
        var width = (model?.phAsset?.pixelWidth.floatValue ?? 0) == 0 ? baseWidth : (model?.phAsset?.pixelWidth.floatValue ?? 0)
        var height = (model?.phAsset?.pixelHeight.floatValue ?? 0) == 0 ? baseHeight : (model?.phAsset?.pixelHeight.floatValue ?? 0)

        // 按比例处理
        let baseRatio = baseWidth / baseHeight
        let contentRatio = width / height
        
        if baseRatio.isNaN || contentRatio.isNaN {
            return
        }
        
        if contentRatio < baseRatio {
            height = baseHeight
            width = height * contentRatio
        } else {
            width = baseWidth
            height = width / contentRatio
        }
        
        self.placeHImageV.snp.remakeConstraints { (make) in
            make.center.equalToSuperview() //.offset(-66.0/2.0)
            make.height.equalTo(height)
            make.width.equalTo(width)
        }
        
        if self.playerLayer != nil {
            // bounds 值对于 不完全立即 对等于 约束值
//            self.playerLayer.frame = self.placeHImageV.bounds
            self.playerLayer.frame = CGRect(x: 0, y: 0, width: width, height: height)
        }
        
        self.playBtn.snp.makeConstraints { make in
            make.center.equalTo(self.placeHImageV)
            make.height.width.equalTo(60)
        }
    }

}

// MARK: Action
extension CLBAlbumVideoPreviewView {
    
    @objc private func gestureTap() {
      
        if self.playerLayer.player?.rate == 0.0 {
            
            // 播放时加载 item
            if self.playItem != nil {
                self.player.replaceCurrentItem(with: self.playItem)
                self.playItem = nil
            }
            let currentT = self.player.currentItem?.currentTime()
            let durationT = self.player.currentItem?.duration
            if currentT?.value == durationT?.value {
                self.player.currentItem?.seek(to: CMTime(value: 0, timescale: 1), completionHandler: nil)
            }
            
            self.player.play()
            self.playBtn.isHidden = true
        } else {
            self.player.pause()
            self.playBtn.isHidden = false
            self.playBtn.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn) {
                self.playBtn.transform = .identity
            } completion: { finish in }
        }
    }
    @objc private func playerItemDidPlayToEndTime(noti: NSNotification) {
        //notification of player to stop
        let playingItem = noti.object as? AVPlayerItem
        //
        if playingItem != self.player.currentItem {
            return
        }
        self.player.pause()
        self.playBtn.isHidden = false
    }
}
