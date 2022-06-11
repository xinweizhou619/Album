//
//  CLBHUD.swift
//  Wallpaper
//
//  Created by Copper on 2021/1/25.
//

import UIKit
import Toast_Swift

class CLBHUD: NSObject {
    
    /// 默认3s
    /// - Parameter text: 文案
    static func show(text: String? = nil) {
        self.show(text: text, duration: 3.0)
    }
    
    /// 文案 + 持续时间
    /// - Parameters:
    ///   - text: 文案
    ///   - duration: 持续时间
    static func show(text: String? = nil, duration: TimeInterval) {
        DispatchQueue.main.async {
            self.dismiss()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                let topController = self.topMostViewController()
                if topController != nil {
                    let rootView = topController!.view
                    let style = ToastManager.shared.style
                    rootView!.makeToast(text, duration: duration, position: ToastPosition.center, title: nil, image: nil, style: style, completion: nil)
                }
            }
        }
    }
    
    static func showSuccess(text: String? = nil, duration: TimeInterval = 3.0) {
        show(text: text, duration: duration)
    }
    
    static func showError(text: String? = nil, duration: TimeInterval = 3.0) {
        show(text: text, duration: duration)
    }
    
    static func showLoading() {
        DispatchQueue.main.async {
            self.dismiss()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                let topController = self.topMostViewController()
                if topController != nil {
                    let rootView = topController!.view
                    rootView!.makeToastActivity(ToastPosition.center)
                }
            }
        }
    }
    
    /// 消失
    static func dismiss() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            let topController = self.topMostViewController()
            if topController != nil {
                let rootView = topController!.view
                rootView!.hideAllToasts(includeActivity: true, clearQueue: true)
            }
        }
    }
    
    static func dismiss(_ completion: @escaping ()->()) {
        DispatchQueue.main.async {
            self.dismiss()
            DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
                completion()
            }
        }
    }
}

extension CLBHUD {
    @objc static func topMostViewController() -> UIViewController? {
        let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        var topController: UIViewController? = window?.rootViewController
        while ((topController?.presentedViewController) != nil) {
            topController = topController?.presentedViewController
        }
        return topController
    }
}
