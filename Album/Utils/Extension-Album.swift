//
//  Extension.swift
//  PulseD-iOS
//
//  Created by xinweizhou on 2021/11/22.
//

import Foundation
import UIKit


struct CLABoat<Base> {
    // base 这里是不可变的，如果Base是结构体类型，编译器不允许修改base的值（base的属性值、调用base的mutating方法）
    let base: Base
    init(base: Base) {
        self.base = base
    }
}

/// Class 类型协议
protocol CLABoatObjectCompatible: AnyObject {}
extension CLABoatObjectCompatible {
    var boat: CLABoat<Self> {
        get {
            return CLABoat<Self>(base: self)
        }
        // 见test方法 见126行
        set {}
    }
    
    static var boat: CLABoat<Self>.Type {
        get {
            return CLABoat<Self>.self
        }
        set {}
    }
}



/// 其他类型协议
protocol CLABoatCompatible {}
extension CLABoatCompatible {
    var boat: CLABoat<Self> {
        get {
            return CLABoat<Self>(base: self)
        }
        set {}
    }
    
    static var boat: CLABoat<Self>.Type {
        get {
            return CLABoat<Self>.self
        }
        set {}
    }
}

extension Date: CLABoatCompatible {}
extension UIColor: CLABoatObjectCompatible {}
extension String: CLABoatCompatible {}
//extension String {
//    var boat:CLABoat<String> {
//        get{return CLABoat(base: self)}
//        set{}
//    }
//}

// MARK: 这里 以下写法（UITextField） 会自动继承"协议"，协议扩展又自动实现了方法
extension UIView: CLABoatObjectCompatible {}
/// UITextField可以继承extension UIView 遵守的 "协议"
//extension UITextField: CLABoatObjectCompatible {}


// MARK: 这里 以下写法 会引起编译错误
//extension UIView {
//    var boat:CLABoat<UIView> {
//        get { CLABoat<UIView>(base: self) }
//        set{}
//    }
//
//    static var boat:CLABoat<UIView>.Type {
//        get { CLABoat<UIView>.self }
//        set {}
//    }
//}
////Property 'boat' with type 'dDocBoat<UITextField>' cannot override a property with type 'dDocBoat<UIView>'
//extension UITextField {
//    var boat:CLABoat<UITextField> {
//        get{ return CLABoat<UITextField>(base: self) }
//        set{ }
//    }
//
//    static var boat:CLABoat<UITextField>.Type {
//        get { CLABoat<UITextField>.self }
//        set {}
//    }
//}


// MARK: 这里说明了 CLABoatObjectCompatible CLABoatCompatible 协议之间的差别
class ClassMate {
    var name:String?
    var age:String?
}

extension ClassMate: CLABoatObjectCompatible {}
extension CLABoat where Base == ClassMate {
    var claName:String {
        set {
            self.base.name = newValue
        }
        get {
            return ""
        }
    }

}

func test() {
    let cm = ClassMate()
//    cm.boat = CLABoat<ClassMate>(base: cm)
    // 给boat的属性claName 赋值，编译器认为 boat的内容会改变
    // 而 boat 是 Struct类型，则意味着 cm.boat会被重新赋值，则要求property: 'boat'可写
    //    Cannot assign to property: 'boat' is a get-only property
    cm.boat.claName = ""
    
    
//    var cm2 = ClassMate2()
    // 接上文cm2.boat会被重新赋值，意味着cm2的内容会被修改
    // 又因为cm2是结构体类型，所以要求cm2变量可变
    // Change 'let' to 'var' to make it mutable
//    cm2.boat.claName = ""
}

struct ClassMate2 {
    var name:String?
    var age:String?
    
    mutating func setName(name: String) {
        self.name = name
    }
}

extension ClassMate2: CLABoatCompatible {}
extension CLABoat where Base == ClassMate2 {
    var claName:String {
        set {
//            self.base.setName(name: newValue)
        }
        get {
            return ""
        }
    }
}


