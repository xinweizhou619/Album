//
//  UIView-extension.swift
//  CleanB-iOS
//
//  Created by xinweizhou on 2022/2/15.
//

import Foundation
import UIKit


extension String {
   
    
    /// 使用正则表达式找出所有匹配的字符串
    /// - Parameter pattern: 注意，使用 ^$ 字符作为匹配语法会带来问题
    /// - Returns: 返回匹配数组
    func regexGetSubs(pattern:String) -> [String] {
        var subs = [String]()
        let regex = try! NSRegularExpression(pattern: pattern, options:[])
        let matches = regex.matches(in: self, options: [], range: NSRange(self.startIndex..<self.endIndex,in: self))
        //解析出子串
        for  match in matches {
      
            let range = match.range
            let bI = self.index(self.startIndex, offsetBy: range.location)
            let be = self.index(bI, offsetBy: range.length)
            let sub = String(self[bI..<be])
            
            subs.append(sub)
        }
        return subs
    }
}

extension UIView {
    static var loadFromNib: Self? {
        let typeName = Self.description().components(separatedBy: ".")[1]
        let view = Bundle.main.loadNibNamed(typeName, owner: nil, options: nil)?[0] as? Self
        return view
    }
}




extension String {
    var floatValue: CGFloat {
        return CGFloat((self as NSString).floatValue)
    }
}
extension Int {
    var floatValue: CGFloat {
        return CGFloat(self)
    }
}



extension CLABoat where Base == UIView {
    ///  默认从主Bundle加载，Nib名字默认为类型名称
    /// - Returns: 返回响应类型
    static func loadV<T: UIView>(tp: T.Type, fromNib nib: String? = nil, bundle: Bundle? = nil) -> T? {
        
        //
        var tName = tp.description().components(separatedBy: ".")[1]
        if let nibN = nib {
            tName = nibN
        }
        
        let view = Bundle.main.loadNibNamed(tName, owner: nil, options: nil)?[0] as? T
        return view
    }
    
}

extension CLABoat where Base : UIView {

    static var loadFromNib: UIView? {
        
        // 参考 "Mirror for CLABoat<CLAChargingGuidesNavView>.Type"
        let des = Mirror(reflecting: self).description
        var typeName = des.regexGetSubs(pattern: "<[A-z]+>").first
        typeName?.removeFirst()
        typeName?.removeLast()
        if let name = typeName {
            let view = Bundle.main.loadNibNamed(name, owner: nil, options: nil)?[0] as? UIView
            return view
        }
        
        return nil
    }
    
}


