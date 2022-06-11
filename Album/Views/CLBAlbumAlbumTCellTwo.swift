//
//  CLBAlbumAlbumTCellTwo.swift
//  CleanB-iOS
//
//  Created by xinweizhou on 2022/2/17.
//

import UIKit

class CLBAlbumAlbumTCellTwo: UITableViewCell {

    @IBOutlet weak var iconImageV: UIImageView!
    @IBOutlet weak var nameL: UILabel!
    @IBOutlet weak var numL: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.iconImageV.contentMode = .scaleAspectFill
        
        self.nameL.font = CLBTheme.clb_UniSansSemiBold(20)
        self.nameL.textColor = UIColor.clb_colorHex(0x181F2C)
        
        self.numL.font = CLBTheme.clb_UniSansRegular(16)
        self.numL.textColor = UIColor.clb_colorHex(0x181F2C)
        
        self.nameL.text = nil
        self.numL.text = nil
    }

    var model: CLBAlbumAlbumModel? {
        didSet {
            self.nameL.text = model?.name
            self.numL.text = "\(model?.count ?? 0)"

            _ = model.map { model in
                CLBAlbumMediaPickerManager.shared.getPostImage(album: model) { photo, error  in
                    self.iconImageV.image = photo
                }
            }
            
        }
    }
    
}
