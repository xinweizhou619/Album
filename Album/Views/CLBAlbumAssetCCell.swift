//
//  CLBAlbumAssetCCell.swift
//  Album
//
//  Created by xinweizhou on 2021/12/22.
//

import UIKit

class CLBAlbumAssetCCell: UICollectionViewCell {
    @IBOutlet weak var imageV: UIImageView!
    @IBOutlet weak var maskV: UIView!
    @IBOutlet weak var selectBtn: UIButton!
    
    
    private lazy var durationV: UIView = {
        let view = UIView()
        
        let baseV = UIView()
        baseV.backgroundColor = UIColor.clb_colorHex(0x000000)
        baseV.alpha = 0.6
        view.addSubview(baseV)
        baseV.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        view.addSubview(durationL)
        durationL.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.equalToSuperview().offset(7)
            make.trailing.equalToSuperview().offset(-7)
        }
        
        return view
    }()
    
    private lazy var durationL: UILabel = {
        let durationLabel = UILabel()
        durationLabel.textColor = CLBTheme.pureWhite
        durationLabel.font = CLBTheme.clb_UniSansRegular(13)
        return durationLabel
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        //
        self.maskV.isHidden = false
        
        //
        self.addSubview(self.durationV)
        self.durationV.layer.cornerRadius = 9.5
        self.durationV.clipsToBounds = true
        self.durationV.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(8)
            make.top.equalToSuperview().offset(8)
            make.height.equalTo(19)
            make.width.greaterThanOrEqualTo(49)
        }
    }
    
    var selectClicked: ((_ model: CLBAlbumAssetModel?) -> ())?
    
    @IBAction func selectBtnClicked(_ sender: UIButton) {
        self.selectClicked?(self.model)
    }
    
    var model: CLBAlbumAssetModel? {
        didSet {
            _ = model.map { model in
                _ = CLBAlbumMediaPickerManager.shared.getPostImage(assets: model) { photo, error in
                    self.imageV.image = photo
                }
                
                if model.isSelected == true {
                    self.maskV.backgroundColor = UIColor.clb_colorHex(0x1A5DB4)
                    self.selectBtn.isSelected = true
                } else {
                    self.maskV.backgroundColor = UIColor.clear
                    self.selectBtn.isSelected = false
                }
                
                if model.type == .video, let duration = model.duration {
                    durationV.isHidden = false
                    durationL.text = duration
                } else {
                    durationV.isHidden = true
                }
                
            }
        }
    }
    

}
