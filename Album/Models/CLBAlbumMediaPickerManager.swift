//
//  CLBAlbumMediaPickerManager.swift
//  Album
//
//  Created by xinweizhou on 2021/12/8.
//

import UIKit
import Photos
import MobileCoreServices

enum XWZMediaPickerType {
    case image
    case video
    case all
}
class CLBAlbumMediaPickerManager: NSObject {
    
    static let shared = CLBAlbumMediaPickerManager()
    var numOfSelectedAssets = 50
    
    
    private(set) var selectedAssests: [CLBAlbumAssetModel] = [] {
        didSet {
            self.selectedAssetsChanged?(selectedAssests.count)
        }
    }
    var selectedAssetsChanged: ((_ count: Int) -> ())?
    
    var isFullForSelected: Bool {
        return selectedAssests.count >= numOfSelectedAssets
    }
    
    func addSelectedAssets(model: CLBAlbumAssetModel) {
        self.removeSelectedAssets(model: model)
        if selectedAssests.count >= numOfSelectedAssets {
            return
        }
        self.selectedAssests.append(model)
    }
    func removeSelectedAssets(model: CLBAlbumAssetModel) {
        self.selectedAssests = self.selectedAssests.filter { assets in
            assets !== model
        }
    }
    func clearSelectedAssets() {
        self.selectedAssests.removeAll()
    }
    
    var selectType: XWZMediaPickerType = .all
    var sortAscendingByModificationDate: Bool = false
    
    
    func getAllAlbums(completion: (([CLBAlbumAlbumModel]) -> ())?) {
        
        
        let option = PHFetchOptions()
        option.includeHiddenAssets = false
        option.includeAllBurstAssets = false
//        option.includeAssetSourceTypes = PHAssetSourceTypeNone
        
        if selectType == .image {
            option.predicate = NSPredicate(format: "mediaType == %ld", PHAssetMediaType.image.rawValue)
        } else if selectType == .video {
            option.predicate = NSPredicate(format: "mediaType == %ld", PHAssetMediaType.video.rawValue)
        }
        
        if sortAscendingByModificationDate == false {
            let sortD = NSSortDescriptor(key: "creationDate", ascending: sortAscendingByModificationDate)
            option.sortDescriptors = [sortD]
        }
        
        
        //
        let myPhotoCollectionFetch = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumMyPhotoStream, options: nil)
        let smartColletionFetch = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .albumRegular, options: nil)
        let topLevelUserColletionFetch = PHAssetCollection.fetchTopLevelUserCollections(with: nil)
        
        let syncedColletionFetch = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumSyncedAlbum, options: nil)
        
        let cloudSharedColletionFetch = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumCloudShared, options: nil)
        
        let allCollectionFetchs = [myPhotoCollectionFetch, smartColletionFetch, topLevelUserColletionFetch, syncedColletionFetch, cloudSharedColletionFetch]
        
        var albums: [CLBAlbumAlbumModel] = []
        for colletionFetch in allCollectionFetchs {
            guard let fetch = colletionFetch as? PHFetchResult<PHCollection> else {
                continue
            }
            fetch.enumerateObjects { collection, index, stop in
                if let assetC = collection as? PHAssetCollection {
                    if assetC.estimatedAssetCount < 1 && self.isCameraRollCollection(collection: assetC) == false {
//                        continue
                        return
                    }
                    
                    if assetC.assetCollectionSubtype == .smartAlbumAllHidden {
                        return
                    }
                    if assetC.assetCollectionSubtype.rawValue == 1000000201 {
                        return // 最近删除
                    }
                    
                    let album = CLBAlbumAlbumModel(collection: assetC, option: option)
                    if album.count < 1 {
                        return
                    }
                    album.isCameraRoll = self.isCameraRollCollection(collection: assetC)
                    if album.isCameraRoll {
                        albums.insert(album, at: 0)
                    } else {
                        albums.append(album)
                    }
                    
                }
            }
        }
        
        completion?(albums)
        
    }
    
    // 最近项目
    func isCameraRollCollection(collection: PHAssetCollection) -> Bool {
        var version = UIDevice.current.systemVersion.replacingOccurrences(of: ".", with: "")
        if version.count <= 1 {
            version = version + "00"
        } else if version.count <= 2 {
            version = version + "0"
        }
        
        let ver = Float(version) ?? 0
        if ver >= 800 && ver <= 802 {
            return collection.assetCollectionSubtype == .smartAlbumRecentlyAdded
        } else {
            return collection.assetCollectionSubtype == .smartAlbumUserLibrary
        }
    }
    
    // 获取相册的封面图片
    func getPostImage(album: CLBAlbumAlbumModel, completion: ((_ photo: UIImage?, _ error: NSError?) -> ())?) -> PHImageRequestID? {
        var asset: PHAsset?
        if self.sortAscendingByModificationDate == true {
            asset = album.assetFetchResult?.lastObject
        } else {
            asset = album.assetFetchResult?.firstObject
        }
        guard asset != nil else {
            return nil
        }
        let size = CGSize(width: 360, height: 360)
        return self.getImage(asset: asset!, deliveryMode: .both, photoSize: size, progressHandler: nil) { photo, info, isDegrated in
            let error = info?[PHImageErrorKey] as? NSError
            completion?(photo, error)
        }
    }
    
    // 获取AssetModel的封面图片
    func getPostImage(assets: XWZAlbumAssetProtocol, completion: ((_ photo: UIImage?, _ error: NSError?) -> ())?) -> PHImageRequestID? {

        guard let asset = assets.phAsset else {
            return nil
        }
        let size = CGSize(width: 360, height: 360)
        
        return self.getImage(asset: asset, deliveryMode: .both, photoSize: size, progressHandler: nil) { photo, info, isDegrated in
            let error = info?[PHImageErrorKey] as? NSError
            completion?(photo, error)
        }
    }
    
    static func isCloudSyncError(error: NSError) -> Bool {
        if error.domain == "CKErrorDomain" || error.domain == "CloudPhotoLibraryErrorDomain" {
            return true
        }
        
        return false
    }
    
    // 获取大图（预览）压缩图
    func getPreviewCompressedImage(assets: XWZAlbumAssetProtocol, completion: ((_ photo: UIImage?, _ error: NSError?) -> ())?) -> PHImageRequestID? {

//        let resources: [PHAssetResource] = PHAssetResource.assetResources(for: assets.asset!)
        
        guard let asset = assets.phAsset else {
            return nil
        }
        
        let wi = CGFloat(asset.pixelWidth) == 0 ? UIScreen.main.bounds.width :  CGFloat(asset.pixelWidth)
        let hi = CGFloat(asset.pixelHeight) == 0 ? UIScreen.main.bounds.height : CGFloat(asset.pixelHeight)
    
        
//        Printing description of info:
//        ▿ Optional<Dictionary<AnyHashable, Any>>
//          ▿ some : 3 elements
//            ▿ 0 : 2 elements
//              ▿ key : AnyHashable("PHImageErrorKey")
//                - value : "PHImageErrorKey"
//              - value : Error Domain=PHPhotosErrorDomain Code=-1 "(null)"
//            ▿ 1 : 2 elements
//              ▿ key : AnyHashable("PHImageResultRequestIDKey")
//                - value : "PHImageResultRequestIDKey"
//              - value : 48
//            ▿ 2 : 2 elements
//              ▿ key : AnyHashable("PHImageResultIsDegradedKey")
//                - value : "PHImageResultIsDegradedKey"
//              - value : 0
        // 图片太小时，压缩模式返回错误
        var mode: ImageDeliverMode = .compressed
        if wi <= UIScreen.main.bounds.width && hi <= UIScreen.main.bounds.height {
            mode = .targetSize
        } else if wi < 360 {
            mode = .targetSize
        } else if hi < 360 {
            mode = .targetSize
        }
        
        let size = CGSize(width: wi, height: hi)
        return self.getImage(asset: asset, deliveryMode: mode, photoSize: size, progressHandler: nil) { photo, info, isDegrated in
            let error = info?[PHImageErrorKey] as? NSError
            completion?(photo, error)
        }
    
    }
    
    // 获取大图（预览）高质量图
    func getPreviewOriginImage(assets: XWZAlbumAssetProtocol, completion: ((_ photo: UIImage?, _ error: NSError?) -> ())?) -> PHImageRequestID? {

//        let resources: [PHAssetResource] = PHAssetResource.assetResources(for: assets.asset!)
        
        guard let asset = assets.phAsset else {
            return nil
        }
        let wi = CGFloat(asset.pixelWidth) == 0 ? UIScreen.main.bounds.width :  CGFloat(asset.pixelWidth)
        let hi = CGFloat(asset.pixelHeight) == 0 ? wi : CGFloat(asset.pixelHeight)
        let size = CGSize(width: wi, height: hi)
        return self.getImage(asset: asset, deliveryMode: .targetSize, photoSize: size, progressHandler: nil) { photo, info, isDegrated in
            let error = info?[PHImageErrorKey] as? NSError
            completion?(photo, error)
        }
    
    }
    
    
    enum ImageDeliverMode {
        case targetSize
        case compressed
        case both
    }
    
    
    /// 获取Image类型、video类型 的 图片
    private func getImage(asset: PHAsset, deliveryMode: ImageDeliverMode = .both, photoSize: CGSize, progressHandler:((_ progress: Double, _ error: Error?, _ stop: UnsafeMutablePointer<ObjCBool>, _ info: [AnyHashable: Any]?) -> ())?, completion: ((_ photo: UIImage?, _ info: [AnyHashable: Any]?, _ isDegrated: Bool?) -> ())?) -> PHImageRequestID? {
        let option = PHImageRequestOptions()
       
        
        // 取值返回分为两种：targetSize取值、压缩取值
        // 一般情况下，targetSize 设定越大，压缩取值也就越大
        
        // deliveryMode = .fastFormat时，只会返回压缩的取值  isSynchronous = false 会转回主线程
        // deliveryMode = .highQualityFormat 只会返回targetSize的取值 isSynchronous = false 会转回主线程
        // .fastFormat .highQualityFormat 时候 PHImageResultIsDegradedKey 都是false
        // deliveryMode = .opportunistic时，先返回压缩的取值，再返回targetsize取值
        // .opportunistic 返回压缩取值时，PHImageResultIsDegradedKey = true，返回targetsize取值时，PHImageResultIsDegradedKey = false
        
        // resizeMode 在于保证targetsize取值的准确性，和 压缩取值没有任何关系
        // fast 不保证 targetSize取值 完全按照targetSize设定走，但是经测试也差不多
        // exact 保证targetSize取值完全按照 targetSize设定 走
        
        // deliveryMode 在于设定返回不返回targetSize（.fastFormat只返回压缩取值）取值，以及何时返回targetSize取值（.opportunistic先返回压缩取值，再返回targesize取值）
        // 例如： 当targesize取值设定(360,360)时候，压缩取值返回（40,40), targetSize 取值返回（360, 360）或者（240, 390）
        
        option.resizeMode = .fast
        // 相册权限Limited 不允许 .fastFormat
        if deliveryMode == .compressed {
            option.deliveryMode = .fastFormat
            option.isSynchronous = true
        } else if deliveryMode == .targetSize {
            option.deliveryMode = .highQualityFormat
            option.isSynchronous = true
        } else {
            option.deliveryMode = .opportunistic
        }
        // targetSize（width : 35.0  height : 36.0  压缩模式 返回失败）
        let requestId = PHImageManager.default().requestImage(for: asset, targetSize: photoSize, contentMode: .aspectFill, options: option) { result, info in
            
            let cancelled = info?[PHImageCancelledKey] as? Bool ?? false
            if cancelled == false && result != nil {
//                resultImage = [self fixOrientation:resultImage];
                completion?(result, info, info?[PHImageResultIsDegradedKey] as? Bool)
            }
            
            // Download image from iCloud / 从iCloud下载图片
            if let isCloud = info?[PHImageResultIsInCloudKey] as? Bool, isCloud == true, result != nil {
                option.isNetworkAccessAllowed = true
                option.progressHandler = { progerss, error, stop, info in
                    progressHandler?(progerss, error, stop, info)
                }
                PHImageManager.default().requestImageData(for: asset, options: option) { imageData, dataUTI, orientation, info in
            
                    var resultImage = imageData.flatMap({ data in
                        UIImage(data: data)
                    })
                    if resultImage == nil {
                        resultImage = result
                    }
                    
//                    resultImage = [self fixOrientation:resultImage];
                    completion?(resultImage, info, false)
                }
            }
            
        }
        
        
        return requestId
    }
    
    
    /// 获取Image、video 类型 的Image Data
    ///  image 类型：包括git 返回全部数据（裁剪等操作后并非原始）live呢?
    ///  video类型：和 getImage类似，返回第一帧图片数据
    /// - Parameter asset: asset
    func getImageData(asset: PHAsset, progressHandler:((_ progress: Double, _ error: Error?, _ stop: UnsafeMutablePointer<ObjCBool>, _ info: [AnyHashable: Any]?) -> ())?, completion: ((_ data: Data?, _ orientation: UIImage.Orientation?) -> ())?) -> PHImageRequestID? {
        let option = PHImageRequestOptions()
        option.isNetworkAccessAllowed = true
        option.version = .current
        if let name = asset.value(forKey: "filename") as? String, name.hasPrefix("GIF") {
            // if version isn't PHImageRequestOptionsVersionOriginal, the gif may cann't play
            option.version = .original
        }
        option.progressHandler = progressHandler
        option.deliveryMode = .opportunistic
        
        //
        return PHImageManager.default().requestImageData(for: asset, options: option) { data, dataUTI, orientation, info in
//            let cancelled = info?[PHImageCancelledKey] as? Bool ?? false
            completion?(data, orientation)
        }
        
    }
    
    // 获取视频 AVPlayerItem
    func getVideo(asset: PHAsset, progressHandler:((_ progress: Double, _ error: Error?, _ stop: UnsafeMutablePointer<ObjCBool>, _ info: [AnyHashable: Any]?) -> ())?, completion: ((_ playItem: AVPlayerItem?, _ info: [AnyHashable: Any]?) -> ())?) -> PHImageRequestID? {
        let option = PHVideoRequestOptions()
        option.isNetworkAccessAllowed = true
        option.version = .current
        option.deliveryMode = .mediumQualityFormat
        option.progressHandler = progressHandler
        
        return PHImageManager.default().requestPlayerItem(forVideo: asset, options: option) { item, info in
            completion?(item, info)
        }
    }
    
    
    // 获取低质量LivePhoto
    func getPostLivePhoto(assets: XWZAlbumAssetProtocol, completion: ((_ livePhoto: PHLivePhoto?, _ error: NSError?) -> ())?) -> PHImageRequestID? {

        guard let asset = assets.phAsset else {
            return nil
        }
        let size = CGSize(width: 360, height: 360)
        
        return self.getLivePhoto(asset: asset, photoSize: size, progressHandler: nil) { livePhoto, info in
            let error = info?[PHImageErrorKey] as? NSError
            completion?(livePhoto, error)
        }
    }
    
    // 获取高质量LivePhoto
    func getPreviewLivePhoto(assets: XWZAlbumAssetProtocol, completion: ((_ livePhoto: PHLivePhoto?, _ error: NSError?) -> ())?) -> PHImageRequestID? {
        
        guard let asset = assets.phAsset else {
            return nil
        }
        let wi = CGFloat(asset.pixelWidth) == 0 ? UIScreen.main.bounds.width :  CGFloat(asset.pixelWidth)
        let hi = CGFloat(asset.pixelHeight) == 0 ? wi : CGFloat(asset.pixelHeight)
        let size = CGSize(width: wi, height: hi)
        
        return self.getLivePhoto(asset: asset, photoSize: size, progressHandler: nil) { livePhoto, info in
            let error = info?[PHImageErrorKey] as? NSError
            completion?(livePhoto, error)
        }
      
    }
    
    // 通过 asset 获取特定的LivePhoto
    private func getLivePhoto(asset: PHAsset, deliveryMode: ImageDeliverMode = .both, photoSize: CGSize, progressHandler:((_ progress: Double, _ error: Error?, _ stop: UnsafeMutablePointer<ObjCBool>, _ info: [AnyHashable: Any]?) -> ())?, completion: ((_ livePhoto: PHLivePhoto?, _ info: [AnyHashable: Any]?) -> ())?) -> PHImageRequestID? {
        let option = PHLivePhotoRequestOptions()
        option.isNetworkAccessAllowed = true
        option.version = .current
        
        if deliveryMode == .compressed {
            option.deliveryMode = .fastFormat
        } else if deliveryMode == .targetSize {
            option.deliveryMode = .highQualityFormat
        } else {
            option.deliveryMode = .opportunistic
        }
        
        option.progressHandler = progressHandler
        return PHImageManager.default().requestLivePhoto(for: asset, targetSize: photoSize, contentMode: .aspectFill, options: option) { livePhoto, info in
            completion?(livePhoto, info)
        }
      
    }
    
}
// MARK: 开放工具
// MARK: save media data(url)
extension CLBAlbumMediaPickerManager {
    
    func getVideoOutput(assets: PHAsset, success: ((_ filePath: String?) -> ())?, failure: ((_ msg: String?, _ error: Error?) -> ())?) {
        
        self.getVideoOutput(assets: assets, presetName: AVAssetExportPresetMediumQuality, timeRange: CMTimeRange.zero, success: success, failure: failure)
    }
    
    private func getVideoOutput(assets: PHAsset, presetName: String, timeRange: CMTimeRange, success: ((_ filePath: String?) -> ())?, failure: ((_ msg: String?, _ error: Error?) -> ())?) {
        
        let option = PHVideoRequestOptions()
        option.deliveryMode = .automatic
        option.isNetworkAccessAllowed = true
        // 转到主线程
        PHImageManager.default().requestExportSession(forVideo: assets, options: option, exportPreset: presetName) { exportSession, info in
            let outputPath = self.videoOutputPath()
            exportSession?.outputURL = URL(fileURLWithPath: outputPath)
            exportSession?.shouldOptimizeForNetworkUse = false
            exportSession?.outputFileType = .mp4
            if CMTimeRangeEqual(timeRange, CMTimeRange.zero) == false {
                exportSession?.timeRange = timeRange
            }
            // 转到子线程
            exportSession?.exportAsynchronously(completionHandler: {
                DispatchQueue.main.async {
                    self.handleVideoExportResult(session: exportSession!, outputPath: outputPath, success: success, failure: failure)
                }
            })
        }
        
//        if #available(iOS 14, *) {
//
//        } else {
//            let option = PHVideoRequestOptions()
//            option.deliveryMode = .automatic
//            option.isNetworkAccessAllowed = true
//            PHImageManager.default().requestAVAsset(forVideo: assets, options: option) { avasset, audioMix, info in
//
//            }
//        }
        
    }

    
    private func handleVideoExportResult(session: AVAssetExportSession, outputPath: String, success: ((_ filePath: String?) -> ())?, failure: ((_ msg: String?, _ error: Error?) -> ())? ) {
        switch session.status {
        case .unknown:
            debugPrint("AVAssetExportSessionStatusUnknown")
            break
        case .waiting:
            debugPrint("AVAssetExportSessionStatusWaiting")
            break
        case .exporting:
            debugPrint("AVAssetExportSessionStatusExporting")
            break
        case .completed:
            debugPrint("AVAssetExportSessionStatusCompleted")
            success?(outputPath)
            break
        case .failed:
            debugPrint("AVAssetExportSessionStatusUnknown")
            failure?("视频导出失败", session.error)
            break
        case .cancelled:
            debugPrint("AVAssetExportSessionStatusUnknown")
            failure?("导出任务已被取消", session.error)
            break
        default:
            break
        }
    }
    
    
    private func videoOutputPath() -> String {
        let dataF = DateFormatter()
        dataF.dateFormat = "yyyy-MM-dd-HH-mm-ss-SSS"
        let timeStr = dataF.string(from: Date())
        let path = NSHomeDirectory() + String(format: "/tmp/video-%@-%d.mp4", timeStr, arc4random_uniform(10000000))
        return path
    }
    
    
    
    // 获取大图（预览）高质量图
    func getOriginImage(assets: PHAsset, completion: ((_ photo: UIImage?, _ error: NSError?) -> ())?) -> PHImageRequestID? {

        let wi = CGFloat(assets.pixelWidth) == 0 ? UIScreen.main.bounds.width :  CGFloat(assets.pixelWidth)
        let hi = CGFloat(assets.pixelHeight) == 0 ? wi : CGFloat(assets.pixelHeight)
        let size = CGSize(width: wi, height: hi)
        return self.getImage(asset: assets, deliveryMode: .targetSize, photoSize: size, progressHandler: nil) { photo, info, isDegrated in
            let error = info?[PHImageErrorKey] as? NSError
            completion?(photo, error)
        }
    
    }
    
    func getPostImage(assets: PHAsset, completion: ((_ photo: UIImage?, _ error: NSError?) -> ())?) -> PHImageRequestID? {

        let size = CGSize(width: 360, height: 360)
        
        return self.getImage(asset: assets, deliveryMode: .targetSize, photoSize: size, progressHandler: nil) { photo, info, isDegrated in
            let error = info?[PHImageErrorKey] as? NSError
            completion?(photo, error)
        }
    }
    
    func savePhoto(image: UIImage, meta: Dictionary<String, Any>?, completion: @escaping ((_ asset: PHAsset?, _ error: NSError?) -> ())) {
        guard let imageData = image.jpegData(compressionQuality: 1) else {
            completion(nil, nil)
            return
        }
        
        let dateF = DateFormatter()
        dateF.dateFormat = "yyyy-MM-dd-HH:mm:ss-SSS"
        let dateStr = dateF.string(from: Date())
        let path = NSTemporaryDirectory() + "image-\(dateStr).jpg"
        let tmpURL = URL(fileURLWithPath: path)
        
        //
        guard let source = CGImageSourceCreateWithData(imageData as CFData, nil), let destination = CGImageDestinationCreateWithURL(tmpURL as CFURL, kUTTypeJPEG, 1, nil) else {
            completion(nil, nil)
            return
        }
        CGImageDestinationAddImageFromSource(destination, source, 0, meta as CFDictionary?)
        CGImageDestinationFinalize(destination)
        
        var localIdentifier: String?
        PHPhotoLibrary.shared().performChanges {
            let request = PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: tmpURL)
            request?.location = nil
            localIdentifier = request?.placeholderForCreatedAsset?.localIdentifier
            
        } completionHandler: { success, error in
            try? FileManager.default.removeItem(atPath: path)
            DispatchQueue.main.async {
                if success && localIdentifier != nil {
                    self.fetchAsset(by: localIdentifier!) { asset in
                        completion(asset, error as NSError?)
                    }
                } else {
                    completion(nil, error as NSError?)
                }
            }
        }
    }
    
    func saveVideo(url: URL, completion: @escaping ((_ asset: PHAsset?, _ error: NSError?) -> ())) {
        var localIdentifier: String?
        PHPhotoLibrary.shared().performChanges {
            let request = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
            request?.location = nil
            localIdentifier = request?.placeholderForCreatedAsset?.localIdentifier
            
        } completionHandler: { success, error in
//            try? FileManager.default.removeItem(atPath: path)
            DispatchQueue.main.async {
                if success && localIdentifier != nil {
                    self.fetchAsset(by: localIdentifier!, retry: 5) { asset in
                        completion(asset, error as NSError?)
                    }
                } else {
                    completion(nil, error as NSError?)
                }
            }
        }
    }
    
    private func fetchAsset(by localIdentifier: String, retry num: Int = 1, completion: @escaping ((_ asset: PHAsset?) -> ())) {
        let asset = PHAsset.fetchAssets(withLocalIdentifiers: [localIdentifier], options: nil).firstObject
        let retry = num - 1
        guard retry > 0, asset == nil else {
            completion(asset)
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            self.fetchAsset(by: localIdentifier, retry: retry, completion: completion)
        }
        
    }
    
}
