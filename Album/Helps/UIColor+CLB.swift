//
//  UIColor+HTR.swift
//  FancyTranslate
//
//  Created by 高文立 on 2020/8/12.
//  Copyright © 2020 mouos. All rights reserved.
//

import UIKit

@objc extension UIColor {
    static func clb_colorHex(_ hex: Int) -> UIColor {
        return UIColor(hexInt: hex)
    }
    
    /// 字符串初始化
    ///  例: UIColor(hexString: "#4DA2D9")
    ///  或  UIColor(hexString: "#4DA2D9CC")
    /// - Parameter hexString: 字符串
    convenience init(_ hexString: String) {
        self.init(hexString: hexString, alpha: 1.0)
    }
    
    /// 十六进制初始化
    convenience init(hexInt: Int, alpha: Float = 1.0) {
        let hexString = String(format: "%06X", hexInt)
        self.init(hexString: hexString, alpha: alpha)
    }
    
    /// 生成图片
    func clb_toImage(size: CGSize = CGSize(width: 1, height: 1)) -> UIImage? {
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        self.setFill()
        UIRectFill(rect)
        let image: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    convenience init(hexString: String, alpha: Float = 1.0) {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var mAlpha: CGFloat = CGFloat(alpha)
        var minusLength = 0
        
        let scanner = Scanner(string: hexString)
        
        if hexString.hasPrefix("#") {
            scanner.scanLocation = 1
            minusLength = 1
        }
        if hexString.hasPrefix("0x") {
            scanner.scanLocation = 2
            minusLength = 2
        }
        var hexValue: UInt64 = 0
        scanner.scanHexInt64(&hexValue)
        switch hexString.count - minusLength {
        case 3:
            red = CGFloat((hexValue & 0xF00) >> 8) / 15.0
            green = CGFloat((hexValue & 0x0F0) >> 4) / 15.0
            blue = CGFloat(hexValue & 0x00F) / 15.0
        case 4:
            red = CGFloat((hexValue & 0xF000) >> 12) / 15.0
            green = CGFloat((hexValue & 0x0F00) >> 8) / 15.0
            blue = CGFloat((hexValue & 0x00F0) >> 4) / 15.0
            mAlpha = CGFloat(hexValue & 0x00F) / 15.0
        case 6:
            red = CGFloat((hexValue & 0xFF0000) >> 16) / 255.0
            green = CGFloat((hexValue & 0x00FF00) >> 8) / 255.0
            blue = CGFloat(hexValue & 0x0000FF) / 255.0
        case 8:
            red = CGFloat((hexValue & 0xFF000000) >> 24) / 255.0
            green = CGFloat((hexValue & 0x00FF0000) >> 16) / 255.0
            blue = CGFloat((hexValue & 0x0000FF00) >> 8) / 255.0
            mAlpha = CGFloat(hexValue & 0x000000FF) / 255.0
        default:
            break
        }
        self.init(red: red, green: green, blue: blue, alpha: mAlpha)
    }
}


extension UIColor {
    /// 生成渐变颜色
    ///
    /// - Parameters:
    ///   - size: 大小
    ///   - start: 初始位置 - 默认 (0,0)
    ///   - end: 结束值 - 默认(1,1)
    ///   - locations: 变化位置 - 默认 [0.5]
    ///   - colors: 渐变色们
    /// - Returns: 返回color
    static func clb_gradient(size: CGSize,
                            start: (CGFloat, CGFloat) = (0, 0),
                            end: (CGFloat, CGFloat) = (1, 1),
                            locations: [CGFloat] = [0.5],
                            colors: [UInt]) -> UIColor? {
        let image: UIImage? =  self.clb_imageWithColors(colors,
                                                        startPoint: CGPoint(x: start.0, y: start.1),
                                                        endPoint: CGPoint(x: end.0, y: end.1),
                                                        corners: UIRectCorner.allCorners,
                                                        cornerRadius: 0,
                                                        borderWidth: 0,
                                                        borderColor: nil,
                                                        size: size)
        guard let i = image else { return nil }
        return UIColor(patternImage: i)
    }
    
    static func clb_imageWithColors(_ rgbaHexAr: Array<UInt>,
                                   startPoint: CGPoint,
                                   endPoint: CGPoint,
                                   corners: UIRectCorner,
                                   cornerRadius: CGFloat,
                                   borderWidth: CGFloat,
                                   borderColor: UIColor?,
                                   size: CGSize) -> UIImage?
    {
        var boundingRect : CGRect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContextWithOptions(boundingRect.size, false, 0)
        let context : CGContext = UIGraphicsGetCurrentContext()!
        
        if borderWidth > 0 {
            let bof : CGFloat  = borderWidth/2.0
            boundingRect = boundingRect.insetBy(dx: bof, dy: bof)
        }
        
        let cornerspath : UIBezierPath = UIBezierPath(roundedRect: boundingRect,
                                                      byRoundingCorners: corners,
                                                      cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
        let path : CGPath  = cornerspath.cgPath
        context.addPath(path)
        context.clip()
        
        var rgbaHex = Array(rgbaHexAr)
        if rgbaHexAr.count == 1 {
            rgbaHex.append(rgbaHexAr.first!)
        }
        let rgb : CGColorSpace = CGColorSpaceCreateDeviceRGB()
        var colors : [CGFloat] = Array(repeating: 0.0, count: rgbaHex.count * 4)
        for idx in 0..<rgbaHex.count {
            let rgba : UInt = rgbaHex[idx]
            for i in 0..<4 {
                let value : CGFloat = CGFloat((rgba >> (24 - 8*i)) & 0xFF)
                colors[idx * 4 + i] = value / 255.0
            }
        }
        
        let gradient: CGGradient = CGGradient(colorSpace: rgb, colorComponents: colors, locations: nil, count: rgbaHex.count)!
        
        let sp : CGPoint = CGPoint(x: boundingRect.size.width * startPoint.x, y: boundingRect.size.height * startPoint.y)
        let ep : CGPoint = CGPoint(x: boundingRect.size.width * endPoint.x, y: boundingRect.size.height * endPoint.y)
        
        context.drawLinearGradient(gradient,
                                   start: sp,
                                   end: ep,
                                   options: CGGradientDrawingOptions.drawsAfterEndLocation)
        
        if borderWidth > 0, borderColor != nil {
            context.resetClip()
            context.addPath(path)
            context.setStrokeColor(borderColor!.cgColor)
            context.setLineWidth(borderWidth)
            context.strokePath()
        }
        
        let image : UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return image.resizableImage(withCapInsets: UIEdgeInsets(top: cornerRadius, left: cornerRadius, bottom: cornerRadius, right: cornerRadius), resizingMode: UIImage.ResizingMode.stretch)
    }
}

