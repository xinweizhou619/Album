//
//  CLBTheme.swift
//  Wallpaper
//
//  Created by Copper on 2021/1/25.
//

import UIKit

let SCREEN_WIDTH = UIScreen.main.bounds.width
let SCREEN_HEIGHT = UIScreen.main.bounds.height

class CLBTheme: NSObject {
    
    @objc static var pureWhite: UIColor = UIColor(hexInt: 0xFFFFFF)
    @objc static var pureBlack: UIColor = UIColor(hexInt: 0x000000)
    
    /*
     UniSansHeavyItalic
     UniSansBold
     UniSansBoldItalic
     UniSansBook
     UniSansBookItalic
     UniSansHeavy
     UniSansLight
     UniSansLightItalic
     UniSansRegular
     UniSansRegularItalic
     UniSansSemiBold
     UniSansSemiBoldItalic
     UniSansThin
     UniSansThinItalic
     */
    @objc static func clb_UniSansHeavyItalic(_ size: CGFloat) -> UIFont {
        return UIFont(name: "UniSansHeavyItalic", size: size) ?? UIFont.italicSystemFont(ofSize: size)
    }

    @objc static func clb_UniSansBold(_ size: CGFloat) -> UIFont {
        return UIFont(name: "UniSansBold", size: size) ?? UIFont.systemFont(ofSize: size, weight: .bold)
    }
    
    @objc static func clb_UniSansBoldItalic(_ size: CGFloat) -> UIFont {
        return UIFont(name: "UniSansBoldItalic", size: size) ?? UIFont.italicSystemFont(ofSize: size)
    }
    
    @objc static func clb_UniSansBook(_ size: CGFloat) -> UIFont {
        return UIFont(name: "UniSansBook", size: size) ?? UIFont.systemFont(ofSize: size, weight: .light)
    }
    
    @objc static func clb_UniSansBookItalic(_ size: CGFloat) -> UIFont {
        return UIFont(name: "UniSansBookItalic", size: size) ?? UIFont.italicSystemFont(ofSize: size)
    }
    
    @objc static func clb_UniSansHeavy(_ size: CGFloat) -> UIFont {
        return UIFont(name: "UniSansHeavy", size: size) ?? UIFont.systemFont(ofSize: size, weight: .heavy)
    }
    
    @objc static func clb_UniSansLight(_ size: CGFloat) -> UIFont {
        return UIFont(name: "UniSansLight", size: size) ?? UIFont.systemFont(ofSize: size, weight: .light)
    }
    
    @objc static func clb_UniSansLightItalic(_ size: CGFloat) -> UIFont {
        return UIFont(name: "UniSansLightItalic", size: size) ?? UIFont.italicSystemFont(ofSize: size)
    }
    
    @objc static func clb_UniSansRegular(_ size: CGFloat) -> UIFont {
        return UIFont(name: "UniSansRegular", size: size) ?? UIFont.systemFont(ofSize: size, weight: .regular)
    }
    
    @objc static func clb_UniSansRegularItalic(_ size: CGFloat) -> UIFont {
        return UIFont(name: "UniSansRegularItalic", size: size) ?? UIFont.italicSystemFont(ofSize: size)
    }
    
    @objc static func clb_UniSansSemiBold(_ size: CGFloat) -> UIFont {
        return UIFont(name: "UniSansSemiBold", size: size) ?? UIFont.systemFont(ofSize: size, weight: .semibold)
    }
    
    @objc static func clb_UniSansSemiBoldItalic(_ size: CGFloat) -> UIFont {
        return UIFont(name: "UniSansSemiBoldItalic", size: size) ?? UIFont.italicSystemFont(ofSize: size)
    }
    
    @objc static func clb_UniSansThin(_ size: CGFloat) -> UIFont {
        return UIFont(name: "UniSansThin", size: size) ?? UIFont.systemFont(ofSize: size, weight: .heavy)
    }
    
    @objc static func clb_UniSansThinItalic(_ size: CGFloat) -> UIFont {
        return UIFont(name: "UniSansThinItalic", size: size) ?? UIFont.italicSystemFont(ofSize: size)
    }
}
