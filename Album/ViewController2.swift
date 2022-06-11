//
//  ViewController2.swift
//  Album
//
//  Created by xinweizhou on 2022/2/7.
//

import UIKit

class ViewController2: UIViewController {
    @IBOutlet weak var baseScrollV: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.baseScrollV.removeFromSuperview()
        self.view.addSubview(self.baseScrollV)
        self.baseScrollV.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(50)
            make.bottom.equalToSuperview()
            make.leading.equalToSuperview().offset(100)
            make.trailing.equalToSuperview().offset(-100)
        }
        self.baseScrollV.contentInsetAdjustmentBehavior = .scrollableAxes
        self.baseScrollV.alwaysBounceVertical = true
        
        let imageV = UIImageView()
        self.baseScrollV.addSubview(imageV)
        imageV.backgroundColor = UIColor.purple
        imageV.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalToSuperview()
            make.width.equalTo(200)
            make.height.equalTo(200)
            make.bottom.equalToSuperview()
        }
        
        self.baseScrollV.backgroundColor = UIColor.red
        // Do any additional setup after loading the view.
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("naviVC: ", self.navigationController?.view.safeAreaInsets)
        print("vc: ",self.view.safeAreaInsets)
        print("scrollView: ",self.baseScrollV.safeAreaInsets)

        
//        let comment: GitHubComment = "Hello \(user: "Boat") world \(user: "xin")"
//        let comment2: GitHubComment = "Hello \(issue: 10) world \(user: "Boat")"
        
        
        
    }
    
    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        print("viewSafeAreaInsetsDidChange", self.view.safeAreaInsets)
    }
    
    override func viewLayoutMarginsDidChange() {
        super.viewLayoutMarginsDidChange()
        print("viewLayoutMarginsDidChange",self.view.layoutMargins)
    }
}


struct GitHubComment {
  let markdown: String
}
extension GitHubComment: ExpressibleByStringLiteral {
  init(stringLiteral value: String) {
    self.markdown = value
  }
}
extension GitHubComment: CustomStringConvertible {
  var description: String {
    return self.markdown
  }
}


extension GitHubComment: ExpressibleByStringInterpolation {
    
    struct StringInterpolationHH: StringInterpolationProtocol {
        var parts: [String]
        init(literalCapacity: Int, interpolationCount: Int) {
            self.parts = []
            // - literalCapacity 文本片段的字符数 (L)
            // - interpolationCount 插值片段数 (I)
            // 我们预计通常结构会是像 "LILILIL"
            // — e.g. "Hello \(world, .color(.blue))!" — 因此是 2n+1
            self.parts.reserveCapacity(2*interpolationCount+1)
        }
        mutating func appendLiteral(_ literal: String) {
            self.parts.append(literal)
        }
        mutating func appendInterpolation(user name: String) {
            self.parts.append("[\(name)](https://github.com/\(name))")
        }
        mutating func appendInterpolation(issue number: Int) {
            self.parts.append("[#\(number)](issues/\(number))")
        }
    }
    
    typealias StringInterpolation = StringInterpolationHH
    
    init(stringInterpolation: StringInterpolationHH) {
        self.markdown = stringInterpolation.parts.joined()
    }
    
}
