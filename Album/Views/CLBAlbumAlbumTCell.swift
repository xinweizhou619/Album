//
//  CLBAlbumAlbumTCell.swift
//  Album
//
//  Created by xinweizhou on 2021/12/8.
//

import UIKit

class CLBAlbumAlbumTCell: UITableViewCell {
    @IBOutlet weak var iconImageV: UIImageView!
    @IBOutlet weak var nameL: UILabel!
    @IBOutlet weak var numL: UILabel!
    @IBOutlet weak var selectedNumL: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.iconImageV.contentMode = .scaleAspectFill
    }

    var model: CLBAlbumAlbumModel? {
        didSet {
            self.nameL.text = model?.name
            self.numL.text = "(\(model?.count ?? 0))"
            self.selectedNumL.text = "(\(model?.selectedAssets?.count ?? 0))"
            _ = model.map { model in
                CLBAlbumMediaPickerManager.shared.getPostImage(album: model) { photo, error  in
                    self.iconImageV.image = photo
                }
            }
            
        }
    }
    
}
