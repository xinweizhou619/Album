//
//  CLBAlbumMediaPickerController.swift
//  Album
//
//  Created by xinweizhou on 2021/12/8.
//

import UIKit
import Photos


enum MediaPickerStyle {
    // 相册目录单独一层AlbumsVController
    case `default`
    // 相册目录集成在AssetsVController
    case decorated
}

protocol CLBAlbumMediaPickerDelegate: NSObjectProtocol {
    func mediaPickerController(_ picker: CLBAlbumMediaPickerController, didFinishPick assets: [PHAsset]?)
    func mediaPickerControllerDidCancel(_ picker: CLBAlbumMediaPickerController)
}

class CLBAlbumMediaPickerController: UINavigationController {

    private var pickerStyle: MediaPickerStyle
    weak var pickerDelegate: CLBAlbumMediaPickerDelegate?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    init(type: MediaPickerStyle) {
        self.pickerStyle = type
        var vc: CLBAlbumBaseVController?
        if type == .decorated {
            vc = CLBAlbumAssetsVController(pickerStyle: pickerStyle)
        } else {
            vc = CLBAlbumAlbumsVController()
        }
        super.init(rootViewController: vc!)
        //
        vc?.dissmissClicked = { [weak self] vc in
            CLBAlbumMediaPickerManager.shared.clearSelectedAssets()
            
            if self?.pickerDelegate != nil {
                self?.pickerDelegate?.mediaPickerControllerDidCancel(self!)
            } else {
                self?.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
