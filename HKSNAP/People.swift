//
//  People.swift
//  HKSNAP
//
//  Created by xinweizhou on 2022/2/25.
//

import Foundation

@objc public class People: NSObject {
    var name: String?
    var id: Int = 0
    var address: String?
    
    init(name: String) {
        self.name = name
    }
    
    func work() {
        let st = Street()
        
    }
    
}
