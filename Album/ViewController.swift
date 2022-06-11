//
//  ViewController.swift
//  Album
//
//  Created by xinweizhou on 2021/12/8.
//

import UIKit
import SnapKit

class Person {
    var name: String?
    var age: Int?
}

class ViewController: UIViewController {
    @IBOutlet weak var redV: UIView!
    
    @IBAction func redVTap(_ sender: UITapGestureRecognizer) {
        let vc = ViewController2()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
//        let vc = ViewController()
//        let person = Person()
        
        if #available(iOS 13.0.0, *) {
            let p = self.getTestFood()
        } else {
            // Fallback on earlier versions
        }
    }


    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let vc = CLBAlbumMediaPickerController(type: .`default`)
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
    @available(iOS 13.0.0, *)
    func getTestFood() -> some Protocol0 {
        let p = PPP()
        return p
    }
    
    func getPPP() -> PPP {
        let p = PPP()
        return p
    }

}

protocol Protocol0 {
    associatedtype F = UIView
    func eatF(food: F)
}

struct PPP: Protocol0 {
    func eatF(food: UIView) {
        return
    }
    
    
}
