//
//  Image-Album.swift
//  CleanB-iOS
//
//  Created by xinweizhou on 2022/2/16.
//

import UIKit


extension UIImage {
    static func xwz_animatedImage(with gifData: Data?) -> UIImage? {
        guard let data = gifData as NSData? else {
            return nil
        }

        let point = data.bytes.assumingMemoryBound(to: UInt8.self)
        let cfData = CFDataCreate(kCFAllocatorDefault, point, data.length)
        let imageSource = cfData.flatMap { data in
            CGImageSourceCreateWithData(data, nil)
        }
        guard let source = imageSource else {
            return nil
        }
        
        let count = CGImageSourceGetCount(source)
        
        // 只有一张图（一帧）
        if count <= 1 {
            return UIImage(data: data as Data)
        }
        
        // 多帧
        // // images数组过大时内存会飙升，在这里限制下最大count
        let maxCount = 50
        let interval = max((count + (maxCount / 2)) / maxCount , 1)
        var images: [UIImage] = []
        var duration: TimeInterval = 0
        
        var index: Int = 0
        while index < count {
            let cfImage = CGImageSourceCreateImageAtIndex(source, index, nil)
            cfImage.map { img in
                let image = UIImage.init(cgImage: img, scale: UIScreen.main.scale, orientation: .up)
                images.append(image)
                
                let addD = self.xwz_frameDuration(source: source, index: index) * CGFloat(min(interval, 3))
                duration = duration + addD
            }

            index = index + interval
        }
        
        if duration == 0 {
            duration = 0.1 * 10
        }
        
        return UIImage.animatedImage(with: images, duration: duration)
    }
    
    static func xwz_frameDuration(source: CGImageSource, index: Int) -> CGFloat {
        let proper = CGImageSourceCopyPropertiesAtIndex(source, index, nil) as? Dictionary<String, Any>
        let gifProper = proper?[kCGImagePropertyGIFDictionary as String] as? Dictionary<String, Any>
        let delayTime = gifProper?[kCGImagePropertyGIFUnclampedDelayTime as String] as? NSNumber
        
        var duration: CGFloat = 0.1
        if let du = delayTime?.doubleValue {
            duration = du
        } else {
            let delayTime = gifProper?[kCGImagePropertyGIFDelayTime as String] as? NSNumber
            if let du = delayTime?.doubleValue {
                duration = du
            }
        }
        if duration < 0.01 {
            duration = 0.1
        }
        
        
        return duration
    }
    
    
    func xwz_fixRotation() -> UIImage {
        let orientation = self.imageOrientation
        
        if orientation == .up {
            return self
        }
        
        var transform = CGAffineTransform.identity
        
        switch orientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: self.size.height)
            transform = transform.rotated(by: CGFloat.pi)
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.rotated(by: CGFloat.pi / 2.0)
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: self.size.height)
            transform = transform.rotated(by: CGFloat.pi / -2.0)
        default:
            break
        }
        
        switch orientation {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: self.size.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        default:
            break
        }
        
        guard let cgimage = self.cgImage else { return self }
        guard let colorSpace = self.cgImage?.colorSpace else { return self }
        guard let bitmapInfo = self.cgImage?.bitmapInfo else { return self }
        guard let bitsPerComponent = self.cgImage?.bitsPerComponent else { return self }
        let ctx = CGContext(data: nil,
                            width: Int(self.size.width),
                            height: Int(self.size.height),
                            bitsPerComponent: bitsPerComponent,
                            bytesPerRow: 0,
                            space: colorSpace,
                            bitmapInfo: bitmapInfo.rawValue)
        
        ctx?.concatenate(transform)
        
        switch orientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            ctx?.draw(cgimage, in: CGRect(x: 0, y: 0, width: self.size.height, height: self.size.width))
        default:
            ctx?.draw(cgimage, in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        }
        
        guard let cgimageRef = ctx?.makeImage() else { return self }
        let result = UIImage(cgImage: cgimageRef)
        return result
    }
    
}
