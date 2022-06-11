//
//  CLBAlbumAlbumModel.swift
//  Album
//
//  Created by xinweizhou on 2021/12/8.
//

import UIKit
import Photos

class CLBAlbumAlbumModel: NSObject {
    var name: String?
    var count: Int = 0
    
    //
    var assetCollection: PHAssetCollection?
    //
    var assetFetchOptions: PHFetchOptions?
    var assetFetchResult: PHFetchResult<PHAsset>?
    var isCameraRoll: Bool = false
    
    // 用于Simple mode
    var isSelected: Bool = false
    var contentOffset: CGPoint?
    
    // decorateAssetModels 之后才有值
    var assets: [CLBAlbumAssetModel]?
    var selectedAssets: [CLBAlbumAssetModel]?
    
    init(collection: PHAssetCollection, option: PHFetchOptions) {
        
        self.assetCollection = collection
        self.name = collection.localizedTitle
        
        self.assetFetchOptions = option
        let assetFetch = PHAsset.fetchAssets(in: collection, options: option)
        
        self.assetFetchResult = assetFetch
        self.count = assetFetch.count
        
    }
    
    func decorateAssetModels() {
        
        if self.assets != nil {
            return
        }
        var array: [CLBAlbumAssetModel] = []
        assetFetchResult?.enumerateObjects({ assets, index, stop in
            let assetM = CLBAlbumAssetModel(asset: assets)
            array.append(assetM)
        })
        self.assets = array
    }
    
}
