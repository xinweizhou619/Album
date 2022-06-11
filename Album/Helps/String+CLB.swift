//
//  String+HTR.swift
//  FancyTranslate
//
//  Created by 高文立 on 2020/8/12.
//  Copyright © 2020 mouos. All rights reserved.
//

import UIKit
import CommonCrypto

// MARK: - String
extension String {
    /// 转成Data
    var clb_toData: Data? {
        return self.data(using: String.Encoding.utf8)
    }
    
    /// MD5加密
    var clb_toMd5: String {
        let cStr = cString(using: String.Encoding.utf8);
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: Int(CC_MD5_DIGEST_LENGTH))
        CC_MD5(cStr!,(CC_LONG)(strlen(cStr!)), buffer)
        let md5String = NSMutableString();
        for i in 0 ..< CC_MD5_DIGEST_LENGTH {
            md5String.appendFormat("%02x", buffer[Int(i)])
        }
        free(buffer)
        return md5String as String
    }

    /// 转成富文本
    func clb_toAttribute(_ att: [NSAttributedString.Key : Any]) -> NSAttributedString {
        let attStr: NSMutableAttributedString = NSMutableAttributedString(string: self)
        attStr.addAttributes(att, range: NSRange(location: 0, length: self.count))
        return attStr
    }
    
    /// 绑定宽度
    ///
    /// - Parameters:
    ///   - width: 宽度
    ///   - att: 属性
    /// - Returns: 高度值
    func clb_boundingWidth(width: CGFloat,
                           att: [NSAttributedString.Key : Any]?) -> CGFloat {
        return self.boundingRect(with: CGSize(width: width, height: CGFloat(MAXFLOAT)), options:[.usesFontLeading, .usesLineFragmentOrigin], attributes: att, context: nil).size.height
    }
    
    /// 绑定高度
    ///
    /// - Parameters:
    ///   - height: 高度值
    ///   - att: 属性
    /// - Returns: 宽度值
    func clb_boundingHeight(height: CGFloat,
                            att: [NSAttributedString.Key : Any]?) -> CGFloat {
        return self.boundingRect(with: CGSize(width: CGFloat(MAXFLOAT), height: height), options: [.usesFontLeading, .usesLineFragmentOrigin], attributes: att, context: nil).size.width
    }
    
    /// 本地语言
    func clb_Localized() -> String {
        let lang : String = NSLocalizedString(self, comment: "")
        if lang == self {
            let bundle : Bundle? = Bundle(path: Bundle.main.path(forResource: "en", ofType: "lproj") ?? "")
            if bundle != nil {
                return NSLocalizedString(self, tableName: "Localizable", bundle: bundle!, value: "", comment: "")
            }
        }
        return lang
    }
    
    // 根据语言标识取对应的内容
    func clb_nativeContent(languageCode: String) -> String {
        var bundle: Bundle? = Bundle(path: Bundle.main.path(forResource: languageCode, ofType: "lproj") ?? "")
        if bundle == nil {
             bundle = Bundle(path: Bundle.main.path(forResource: "en", ofType: "lproj") ?? "")
        }
        if bundle == nil {
             return self
        }
        
        return NSLocalizedString(self, tableName: "Localizable", bundle: bundle!, value: "", comment: "")
    }
}


extension NSString {
    /// 本地语言
   @objc func clb_Localized() -> NSString
    {
        let lang : String = NSLocalizedString(self as String, comment: "")
        if lang == self as String {
            let bundle : Bundle? = Bundle(path: Bundle.main.path(forResource: "en", ofType: "lproj") ?? "")
            if bundle != nil {
                return NSLocalizedString(self as String, tableName: "Localizable", bundle: bundle!, value: "", comment: "") as NSString
            }
        }
        return lang as NSString
    }
}
