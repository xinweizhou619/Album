//
//  CLBAlbumAuthTipView.swift
//  CleanB-iOS
//
//  Created by xinweizhou on 2022/2/17.
//

import UIKit

class CLBAlbumAuthTipView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setUp()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUp() {
        self.backgroundColor = UIColor.clb_colorHex(0xD9EBFC)
        
        let baseV = UIView()
        baseV.layer.cornerRadius = 18
        baseV.layer.borderWidth = 2
        baseV.layer.borderColor = UIColor.clb_colorHex(0x2394FE).cgColor
        self.addSubview(baseV)
        baseV.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(15)
            make.trailing.equalToSuperview().offset(-15)
            make.top.equalToSuperview().offset(20)
            make.height.equalTo(81)
        }
        let tap = UITapGestureRecognizer()
        tap.addTarget(self, action: #selector(tapClicked))
        baseV.addGestureRecognizer(tap)
        
        let iconImageV = UIImageView()
        iconImageV.image = UIImage(named: "privacy_album_tip_info")
        baseV.addSubview(iconImageV)
        iconImageV.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(15)
            make.width.height.equalTo(35)
            make.centerY.equalToSuperview()
        }
        
        let indicatorImageV = UIImageView()
        indicatorImageV.image = UIImage(named: "privacy_album_tip_indicator")
        baseV.addSubview(indicatorImageV)
        indicatorImageV.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-20)
            make.height.greaterThanOrEqualTo(21)
            make.width.greaterThanOrEqualTo(28)
            make.centerY.equalToSuperview()
        }
        
        
        let infoL = UILabel()
        baseV.addSubview(infoL)
        infoL.numberOfLines = 0
        infoL.textColor = UIColor.clb_colorHex(0x2394FE)
        infoL.font = CLBTheme.clb_UniSansSemiBold(16)
        infoL.text = "CLBPrivacyAlbumAuthTip".clb_Localized()
        infoL.snp.makeConstraints { make in
            make.leading.equalTo(iconImageV.snp.trailing).offset(10)
            make.trailing.equalTo(indicatorImageV.snp.leading).offset(-26)
            make.top.equalToSuperview().offset(10)
            make.bottom.equalToSuperview().offset(-10)
        }
    }
    
    @objc private func tapClicked() {
        self.goClicked?()
    }

    
    var goClicked: (() -> ())?
    
}
