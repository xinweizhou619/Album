//
//  CLBAlbumAlbumsVController.swift
//  Album
//
//  Created by xinweizhou on 2021/12/8.
//

import UIKit
import SnapKit

class CLBAlbumAlbumsVController: CLBAlbumBaseVController {

    static let ALBUM_TCELL_IDENTIFIER = "CLBAlbumAlbumTCell"
    
    private lazy var navV: CLBAlbumAssetsNavView = {
        let view = Bundle.main.loadNibNamed("CLBAlbumAssetsNavView", owner: nil, options: nil)?.first as! CLBAlbumAssetsNavView
        return view
    }()
    
    private lazy var tableV: UITableView = {
        let view = UITableView(frame: .zero, style: .plain)
        view.contentInsetAdjustmentBehavior = .never
        if #available(iOS 13.0, *) {
            view.backgroundColor = UIColor.tertiarySystemBackground
        } else {
            view.backgroundColor = UIColor.white
        }
        view.rowHeight = 70
        view.tableFooterView = UIView.init()
        view.delegate = self
        view.dataSource = self
        view.register(UINib(nibName: CLBAlbumAlbumsVController.ALBUM_TCELL_IDENTIFIER, bundle: nil), forCellReuseIdentifier: CLBAlbumAlbumsVController.ALBUM_TCELL_IDENTIFIER)
        return view
    }()
    
    private var allAlbums: [CLBAlbumAlbumModel]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //
        self.view.addSubview(self.navV)
        self.navV.title = "Photos".clb_Localized()
        self.navV.showStyle = .close
    
        self.navV.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalToSuperview()
            if #available(iOS 13.0, *) {
                let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
                let statusBarHeight = window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
                make.height.equalTo(44 + statusBarHeight)
            } else {
                let statusBarHeight = UIApplication.shared.statusBarFrame.height
                make.height.equalTo(44 + statusBarHeight)
            }
        }
        self.navV.dismissClicked = { [weak self] in
            self?.dissmissClicked?(self)
        }
        
        
        DispatchQueue.global().async {
            CLBAlbumMediaPickerManager.shared.getAllAlbums { albums in
                DispatchQueue.main.async {
                    self.allAlbums = albums
                    self.setUp()
                }
            }
        }
    }

    
    
    private func setUp() {
    
        self.view.addSubview(self.tableV)
        self.tableV.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(self.view.snp_bottomMargin)
            make.top.equalTo(self.navV.snp.bottom)
        }
    }

}

extension CLBAlbumAlbumsVController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.allAlbums?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CLBAlbumAlbumsVController.ALBUM_TCELL_IDENTIFIER) as! CLBAlbumAlbumTCell
        let model = self.allAlbums?[indexPath.row]
        cell.model = model
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        let model = self.allAlbums?[indexPath.row]
        
        let vc = CLBAlbumAssetsVController(pickerStyle: .`default`)
        vc.dissmissClicked = { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }
        vc.selectedAlbum = model
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
}
