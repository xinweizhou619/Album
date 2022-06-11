//
//  CLBAlbumPreviewCCell.swift
//  Album
//
//  Created by xinweizhou on 2022/1/13.
//

import UIKit
import Photos


class CLBAlbumPreviewCCell: UICollectionViewCell {

    lazy var imgPreview: CLBAlbumImagePreviewView = {
        let view = CLBAlbumImagePreviewView()
        return view
    }()
    
    lazy var videoPreview: CLBAlbumVideoPreviewView = {
        let view = CLBAlbumVideoPreviewView()
        return view
    }()
    
    
    enum Style {
        case image
        case video
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.style = .image
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 首先设置 style 再设置 model
    private(set) var style: Style = .image
    
    func show(style: Style, model: XWZAlbumAssetProtocol?) {
        
        self.style = style
        
        if style == .image {
            self.imgPreview.showContent(model: model)
        } else {
            self.videoPreview.showContent(model: model)
        }
    }
    
    func prepare(style: Style, model: XWZAlbumAssetProtocol?) {
        
        if style == .image {
            self.addSubview(self.imgPreview)
            self.imgPreview.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            self.imgPreview.reset()
            self.imgPreview.prepare(model: model)
            self.videoPreview.removeFromSuperview()
        } else {
            self.addSubview(self.videoPreview)
            self.videoPreview.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            self.videoPreview.reset()
            self.videoPreview.prepare(model: model)
            self.imgPreview.removeFromSuperview()
        }
       
    }
    
    
    func endDisplay()  {
        if style == .video {
            self.videoPreview.stopPlay()
        }
    }

    
}
