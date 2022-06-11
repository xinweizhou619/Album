//
//  CLBAlbumImagePreviewView.swift
//  Album
//
//  Created by xinweizhou on 2022/1/13.
//

import UIKit
import Photos
import PhotosUI
import SDWebImage

/// CLBAlbumAssetMediaType {
// Image
//case photo
//case livePhoto
//case gifPhoto
//}

fileprivate let BASE_MAX_SCALE: CGFloat = 2.4

class CLBAlbumImagePreviewView: UIView {

    private lazy var scrollV: UIScrollView = {
        let view = UIScrollView()
        view.bouncesZoom = true
        view.maximumZoomScale = BASE_MAX_SCALE
        view.minimumZoomScale = 1
        view.isMultipleTouchEnabled = true
        view.scrollsToTop = false
        view.showsVerticalScrollIndicator = true
        view.showsHorizontalScrollIndicator = false
//        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.delegate = self
        view.delaysContentTouches = false
        view.canCancelContentTouches = true
        view.alwaysBounceVertical = false
    
        return view
    }()
    
    private lazy var containerV: UIView = {
        let view = UIView()
//        view.clipsToBounds = true
//        view.contentMode = .scaleAspectFill
        return view
    }()
    
    private lazy var imageV: UIImageView = {
        let view = UIImageView()
//        view.clipsToBounds = true
        view.contentMode = .scaleAspectFit
        view.backgroundColor = UIColor(white: 1.0, alpha: 0.5)
        return view
    }()
    
    private lazy var liveV: PHLivePhotoView = {
        let view = PHLivePhotoView()
//        view.delegate = self
        return view
    }()
    
    var tapClicked: (() -> ())?
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(self.scrollV)
        self.scrollV.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        //
        self.scrollV.addSubview(self.containerV)
        self.containerV.addSubview(self.imageV)
        self.imageV.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.containerV.addSubview(self.liveV)
        self.liveV.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        self.liveV.isHidden = true
        //
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(singleTap(tap:)))
        self.addGestureRecognizer(tapGesture)
        
        let tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(doubleTap(tap:)))
        tapGesture2.numberOfTapsRequired = 2
        self.addGestureRecognizer(tapGesture2)
        
        tapGesture.require(toFail: tapGesture2)
    }
    
    
    @objc func doubleTap(tap: UITapGestureRecognizer) {
        if self.scrollV.zoomScale > self.scrollV.minimumZoomScale {
            self.scrollV.contentInset = .zero
            self.scrollV.setZoomScale(self.scrollV.minimumZoomScale, animated: true)
        } else {
            let point = tap.location(in: self.imageV)
            let zoomScale = self.scrollV.maximumZoomScale
            debugPrint("zoom scale", zoomScale)
            let xsize = self.scrollV.bounds.width / zoomScale
            let ysize = self.scrollV.bounds.height / zoomScale
            let rect = CGRect(x: point.x - xsize / 2, y: point.y - ysize / 2, width: xsize, height: ysize)
            self.scrollV.zoom(to: rect, animated: true)
        }
    }
    @objc func singleTap(tap: UITapGestureRecognizer) {
        self.tapClicked?()
    }
    
    
    func reset() {
        self.scrollV.setZoomScale(self.scrollV.minimumZoomScale, animated: false)
        self.scrollV.contentInset = .zero
        self.scrollV.maximumZoomScale = BASE_MAX_SCALE
        self.liveV.livePhoto = nil
        self.liveV.isHidden = true
        self.imageV.image = nil
        self.initContainerFrame()
    }
    
    private var requestId: PHImageRequestID?
    private(set) var model: XWZAlbumAssetProtocol?
    
    func showContent(model: XWZAlbumAssetProtocol?) {
        self.model = model
        
        guard let assetM = model else {
            return
        }
        
        if model?.type == .gifPhoto {
            _ = CLBAlbumMediaPickerManager.shared.getImageData(asset: (assetM.phAsset)!) { progress, error, stop, info in
                print("progress =", progress)
            } completion: { data, orientation in
                print(orientation ?? "")
                let img = UIImage.xwz_animatedImage(with: data)
                self.imageV.image = img
            }
        
        } else if model?.type == .livePhoto {
            _ = CLBAlbumMediaPickerManager.shared.getPreviewLivePhoto(assets: assetM, completion: { livePhoto, error in
                self.liveV.isHidden = false
                self.liveV.livePhoto = livePhoto
            })

        } else {
            self.setImage(with: model!)
        }
        
        let width = (model?.phAsset?.pixelWidth ?? 0) < 1 ? Int(UIScreen.main.bounds.width) : (model?.phAsset?.pixelWidth ?? 0)
        let height = (model?.phAsset?.pixelHeight ?? 0) < 1 ? width : (model?.phAsset?.pixelHeight ?? 0)
        
        let aspect = CGFloat(width) / CGFloat(height)
        if aspect > 0.9 && aspect < 1.0 {
            self.scrollV.maximumZoomScale = BASE_MAX_SCALE
        } else if aspect <= 0.9 {
            self.scrollV.maximumZoomScale = BASE_MAX_SCALE / aspect
        } else {
            self.scrollV.maximumZoomScale = BASE_MAX_SCALE * aspect
        }
    }
    func prepare(model: XWZAlbumAssetProtocol?) {
        self.model = model

        if model?.type == .gifPhoto || model?.type == .livePhoto {
            self.setImage(with: model!)
        } else {
            model.map { model in
                self.setCompressedImage(with: model)
            }
        }
        
        //
        self.initContainerFrame()
    }
    
    private func setCompressedImage(with asset: XWZAlbumAssetProtocol) {
        if let id = self.requestId {
            PHImageManager.default().cancelImageRequest(id)
        }
        
        self.requestId = CLBAlbumMediaPickerManager.shared.getPreviewCompressedImage(assets: asset) { photo, error  in
            if let err = error {
                if CLBAlbumMediaPickerManager.isCloudSyncError(error: err) == true {
                    debugPrint("icloud error")
                } else {
                    debugPrint("other error")
                }
                return
            }
            
            self.imageV.image = photo
            
            //
            self.requestId = nil
            
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
                    self.imageV.image = img
                }
            }
            
            //
            self.requestId = nil
            
        }
    }
    
    
    
    private func initContainerFrame()  {
        
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
            
            let x = (self.scrollV.bounds.width - width) / 2.0
            self.containerV.frame = CGRect(x: x, y: 0, width: width, height: height)
            
        } else {
            width = baseWidth
            height = width / contentRatio
            
            let y = (self.scrollV.bounds.height - height) / 2.0
            self.containerV.frame = CGRect(x: 0, y: y, width: width, height: height)
        }
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        //
        self.initContainerFrame()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension CLBAlbumImagePreviewView: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.containerV
    }
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        scrollView.contentInset = .zero
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        self.refreshContanierVCenter()
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        
    }
    
    func refreshContanierVCenter()  {
        
//        // 缩小(或者变大)时居中
        let offx = self.scrollV.bounds.width > self.scrollV.contentSize.width ? (self.scrollV.bounds.width - self.scrollV.contentSize.width) * 0.5 : 0
        let offy = self.scrollV.bounds.height > self.scrollV.contentSize.height ? (self.scrollV.bounds.height - self.scrollV.contentSize.height) * 0.5 : 0
        self.containerV.center = CGPoint(x: self.scrollV.contentSize.width * 0.5 + offx, y: self.scrollV.contentSize.height * 0.5 + offy)
        
//        let height = self.scrollV.bounds.height
//        let width = self.scrollV.bounds.width
//        if offx > 0 {
//            self.containerV.snp.remakeConstraints { make in
//                make.center.equalTo(self)
//                make.height.equalTo(height)
//                make.width.equalTo(width)
//            }
//            self.setNeedsLayout()
//            self.layoutIfNeeded()
//        }
        
    }
}

//extension CLBAlbumImagePreviewView: PHLivePhotoViewDelegate {
//    func livePhotoView(_ livePhotoView: PHLivePhotoView, willBeginPlaybackWith playbackStyle: PHLivePhotoViewPlaybackStyle) {}
//    func livePhotoView(_ livePhotoView: PHLivePhotoView, didEndPlaybackWith playbackStyle: PHLivePhotoViewPlaybackStyle) {}
//    func livePhotoView(_ livePhotoView: PHLivePhotoView, canBeginPlaybackWith playbackStyle: PHLivePhotoViewPlaybackStyle) -> Bool {true}
//}

