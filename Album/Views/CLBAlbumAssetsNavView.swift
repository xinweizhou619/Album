//
//  CLBAlbumAssetsNavView.swift
//  Album
//
//  Created by xinweizhou on 2022/1/5.
//

import UIKit

class CLBAlbumAssetsNavView: UIView {

    enum Style {
        case `default`
        case decoratedClose
        case close
    }
    
    @IBOutlet weak var dismissBtn: UIButton!
    @IBAction func dissmissBtnClicked(_ sender: UIButton) {
        self.dismissClicked?()
    }
    @IBOutlet weak var titleL: UILabel!
    @IBOutlet weak var titleImageV: UIImageView!
    @IBOutlet weak var titleCotainerV: UIView!
    
    //
    @IBOutlet weak var titleLForDefault: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        
        //
        self.setUp()
        
        // init
        self.isUp = false
        self.showStyle = .default
        self.title = nil
    }
    
    
    private func setUp() {
        //
        self.titleL.font = CLBTheme.clb_UniSansSemiBold(20)
        self.titleL.textColor = UIColor.clb_colorHex(0x181F2C)
        self.titleImageV.image = UIImage(named: "privacy_album_arrow")
        
        //
        self.titleLForDefault.font = CLBTheme.clb_UniSansSemiBold(20)
        self.titleLForDefault.textColor = UIColor.clb_colorHex(0x181F2C)
        
        //
        let tap = UITapGestureRecognizer()
        tap.addTarget(self, action: #selector(titleTaped(tap:)))
        self.titleCotainerV.addGestureRecognizer(tap)

    }
    
    @objc private func titleTaped(tap: UITapGestureRecognizer) {
        self.titleClicked?(isUp)
    }
    
    var titleClicked: ((_ isUp: Bool) -> ())?
    var dismissClicked: (() -> ())?
    
    var title: String? {
        didSet {
            self.titleL.text = title
            self.titleLForDefault.text = title
        }
    }
    
    var showStyle: Style = .default {
        didSet {
            if showStyle == .default {
                self.titleCotainerV.isHidden = true
                self.titleLForDefault.isHidden = false
                self.dismissBtn.setImage(UIImage(named: "nav_back_black"), for: .normal)
            } else if showStyle == .decoratedClose {
                self.titleCotainerV.isHidden = false
                self.titleLForDefault.isHidden = true
                self.dismissBtn.setImage(UIImage(named: "privacy_album_close"), for: .normal)
            } else {
                self.titleCotainerV.isHidden = true
                self.titleLForDefault.isHidden = false
                self.dismissBtn.setImage(UIImage(named: "privacy_album_close"), for: .normal)
            }
        }
    }
    
    
    var isUp: Bool = false {
        didSet {
            UIView.animate(withDuration: 0.5) {
                if self.isUp == true {
                    self.titleImageV.transform = CGAffineTransform(rotationAngle: Double.pi)
                } else {
                    self.titleImageV.transform = CGAffineTransform.identity;
                }
            } completion: { finished in
                
            }

        }
    }

    
}
