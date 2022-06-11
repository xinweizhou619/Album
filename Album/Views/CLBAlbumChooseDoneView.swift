//
//  CLBAlbumChooseDoneView.swift
//  CleanB-iOS
//
//  Created by xinweizhou on 2022/2/17.
//

import UIKit

class CLBAlbumChooseDoneView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setUp()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var doneBtn: UIButton = {
        let view = UIButton(type: .system)
        view.titleLabel?.font = CLBTheme.clb_UniSansSemiBold(18)
        view.setTitleColor(UIColor.white, for: .normal)
        view.addTarget(self, action: #selector(btnClicked), for: .touchUpInside)
        view.backgroundColor = UIColor.clb_colorHex(0x2394FE)
        return view
    }()
    
    private lazy var maskV: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 1, alpha: 0.6)
        return view
    }()
    
    private func setUp() {
       
        self.addSubview(doneBtn)
        doneBtn.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(15)
            make.trailing.equalToSuperview().offset(-15)
            make.top.equalToSuperview().offset(10)
            make.height.equalTo(60)
        }
        doneBtn.layer.cornerRadius = 18
        
        self.addSubview(maskV)
        maskV.snp.makeConstraints({ make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
            make.top.equalTo(doneBtn).offset(20)
        })
        
        self.bringSubviewToFront(doneBtn)
    }
    
    @objc private func btnClicked() {
        self.doneClicked?()
    }
    
    var doneClicked: (() -> ())?
    
    var title: String? {
        set {
            self.doneBtn.setTitle(newValue, for: .normal)
        }
        get {
            return self.doneBtn.currentTitle
        }
    }
    
    
}
