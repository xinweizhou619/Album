//
//  CLBAlbumAssetsVController.swift
//  Album
//
//  Created by xinweizhou on 2021/12/8.
//

import UIKit
//import SCNRecorder

private let CELL_COUNT: CGFloat = 3
private let HORIZON_INSET: CGFloat = 4
private let TOP_INSET: CGFloat = 10
private let CELL_PADDING: CGFloat = 4

private let REUSE_IDENTIFIER = "CLBAlbumAssetCCell"
private let REUSE_IDENTIFIER2 = "CLBAlbumAlbumTCellTwo"

class CLBAlbumAssetsVController: CLBAlbumBaseVController {

    private var pickerStyle: MediaPickerStyle
    
    init(pickerStyle: MediaPickerStyle) {
        self.pickerStyle = pickerStyle
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var albumListV: UITableView = {
        let view = UITableView(frame: .zero, style: .plain)
        view.contentInsetAdjustmentBehavior = .never
        
        view.delegate = self;
        view.dataSource = self;
        view.backgroundColor = UIColor.white;
        view.rowHeight = 92;
        view.showsVerticalScrollIndicator = false;
        view.separatorStyle = .none;
        
        view.register(UINib(nibName: REUSE_IDENTIFIER2, bundle: nil), forCellReuseIdentifier: REUSE_IDENTIFIER2)
        
        return view
    }()
    
    private lazy var navV: CLBAlbumAssetsNavView = {
        let view = Bundle.main.loadNibNamed("CLBAlbumAssetsNavView", owner: nil, options: nil)?.first as! CLBAlbumAssetsNavView
        return view
    }()
    
    private lazy var collectionV: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = CELL_PADDING
        layout.minimumInteritemSpacing = CELL_PADDING
        
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.contentInsetAdjustmentBehavior = .never
        
        view.register(UINib(nibName: REUSE_IDENTIFIER, bundle: nil), forCellWithReuseIdentifier: REUSE_IDENTIFIER)
        view.delegate = self
        view.dataSource = self
        view.bounces = true
//        view.verticalScrollIndicatorInsets = UIEdgeInsets(top: TOP_INSET - 4, left: 0, bottom: 0, right: HORIZON_INSET - 6)
        view.alwaysBounceVertical = true
        return view
    }()
    
    private lazy var tipV: CLBAlbumAuthTipView = {
        let view = CLBAlbumAuthTipView()
        return view
    }()
    
    private lazy var chooseV: CLBAlbumChooseDoneView = {
        let view = CLBAlbumChooseDoneView()
        view.clipsToBounds = true
        return view
    }()
    
    var selectedAlbum: CLBAlbumAlbumModel?
    var allAlbums: [CLBAlbumAlbumModel]?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setUp()
        
        // initialize
        
        if self.pickerStyle == .`default` {
            self.navV.showStyle = .default
            
            self.navV.title = self.selectedAlbum?.name
            self.selectedAlbum?.decorateAssetModels()
            self.selectedAlbum?.isSelected = true
            //
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.125) {
                if let offset = self.selectedAlbum?.contentOffset {
                    self.collectionV.setContentOffset(offset, animated: false)
                }
            }
            
        } else {
            self.navV.showStyle = .decoratedClose
            
            DispatchQueue.global().async {
                CLBAlbumMediaPickerManager.shared.getAllAlbums { albums in
                    DispatchQueue.main.async {
                        self.allAlbums = albums
                        self.selectedAlbum = albums.first
                        
                        self.navV.title = self.selectedAlbum?.name
                        self.selectedAlbum?.decorateAssetModels()
                        self.selectedAlbum?.isSelected = true
                        
                        self.albumListV.reloadData()
                        self.albumListV.selectRow(at: IndexPath(item: 0, section: 0), animated: true, scrollPosition: .none)
                        self.collectionV.reloadData()
                    }
                }
            }
            
        }
        
    }
    
    private func setUp() {
        
        self.view.addSubview(self.navV)
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
        self.navV.titleClicked = { [weak self] isUp in
            if isUp == true {
                self?.navV.isUp = false
                self?.hideAlbumList()
            } else {
                self?.navV.isUp = true
                self?.showAlbumList()
            }
        }
        
        self.view.addSubview(self.albumListV)
        self.albumListV.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(self.navV.snp.bottom)
            var height = UIScreen.main.bounds.height
            if #available(iOS 13.0, *) {
                let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
                let statusBarHeight = window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
                height -= (statusBarHeight + 44)
            } else {
                let statusBarHeight = UIApplication.shared.statusBarFrame.height
                height -= (statusBarHeight + 44)
            }
            make.height.equalTo(height)
        }
        self.albumListV.contentInset = UIEdgeInsets(top: TOP_INSET, left: 0, bottom: 34, right: 0)
        
        
        self.view.addSubview(self.tipV)
        self.tipV.goClicked = { 
            DispatchQueue.main.asyncAfter(deadline: .now()+0.3) {
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
            }
        }
        self.view.addSubview(self.chooseV)
        self.chooseV.doneClicked = { [weak self] in
            debugPrint("chooseClicked")
            let nav = self?.navigationController as? CLBAlbumMediaPickerController
            let assetss = CLBAlbumMediaPickerManager.shared.selectedAssests.map { assetsM in
                return assetsM.phAsset!
            }
            CLBAlbumMediaPickerManager.shared.clearSelectedAssets()
            nav?.pickerDelegate?.mediaPickerController(nav!, didFinishPick: assetss)
        }
        
        CLBPremissionManager.checkAlbumPermission { state in
            
            if state == .limited {
                self.albumLimited = true
                self.refreshBottomLayout(showTip: true, showChoose: false)
            } else {
                self.albumLimited = false
                self.refreshBottomLayout(showTip: false, showChoose: false)
            }
            
        }
        
        self.view.addSubview(self.collectionV)
        self.collectionV.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(self.navV.snp.bottom)
            make.bottom.equalTo(self.chooseV.snp.bottom)
        }
        
        
        CLBAlbumMediaPickerManager.shared.selectedAssetsChanged = { [self] count in
            if count > 0 {
                self.refreshBottomLayout(showTip: self.albumLimited, showChoose: true)
                if count == 1 {
                    let title = String(format: "CLBPrivacyAlbumChooseTitleOnlyOne".clb_Localized(), "\(count)")
                    self.chooseV.title = title
                } else {
                    let title = String(format: "CLBPrivacyAlbumChooseTitle".clb_Localized(), "\(count)")
                    self.chooseV.title = title
                }
                
            } else {
                self.refreshBottomLayout(showTip: self.albumLimited, showChoose: false)
            }
            
        }
        
        self.view.bringSubviewToFront(self.chooseV)
        self.view.bringSubviewToFront(self.tipV)
        self.view.bringSubviewToFront(self.albumListV)
        self.view.bringSubviewToFront(self.navV)
    }
    
    private var albumLimited: Bool = false
    private func refreshBottomLayout(showTip: Bool, showChoose: Bool) {
        
        var Bottom: CGFloat = 0
        if #available(iOS 11.0, *) {
            let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
            Bottom = window?.safeAreaInsets.bottom ?? 0
        }
        
        var chooseVHeight: CGFloat = 10 + 60 + 44 - 34 + Bottom
        if showTip {
            self.tipV.snp.remakeConstraints { make in
                make.leading.trailing.equalToSuperview()
                make.bottom.equalToSuperview()
                make.height.equalTo(146 - 34 + Bottom)
            }
            chooseVHeight = chooseVHeight - 34
            
        } else {
            self.tipV.snp.remakeConstraints { make in
                make.leading.trailing.equalToSuperview()
                make.top.equalTo(self.tipV.superview!.snp.bottom)
                make.height.equalTo(146 - 34 + Bottom)
            }
        }
        
        if showChoose == false {
            chooseVHeight = 0
        }
        
        self.collectionV.contentInset = UIEdgeInsets(top: TOP_INSET, left: HORIZON_INSET, bottom: 34 + chooseVHeight, right: HORIZON_INSET)
        
        self.chooseV.snp.remakeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(self.tipV.snp.top)
            make.height.equalTo(chooseVHeight)
        }
    }
    
    private func showAlbumList() {
        UIView.animate(withDuration: 0.3, animations: {
            self.albumListV.transform = CGAffineTransform(translationX: 0, y: self.albumListV.bounds.height)
        }, completion: nil)
    }
    
    private func hideAlbumList() {
        UIView.animate(withDuration: 0.3, animations: {
            self.albumListV.transform = CGAffineTransform.identity
        }, completion: nil)
    }
    
    deinit {
        self.selectedAlbum?.isSelected = false
    }
}

extension CLBAlbumAssetsVController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.allAlbums?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: REUSE_IDENTIFIER2) as! CLBAlbumAlbumTCellTwo
        cell.selectionStyle = .none
        
        let model = self.allAlbums?[indexPath.row]
        if model?.isSelected == true {
            cell.backgroundColor = UIColor.clb_colorHex(0xE9F4FE)
        } else {
            cell.backgroundColor = UIColor.white
        }
        
        cell.model = model
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = self.allAlbums?[indexPath.row];
        self.selectedAlbum?.isSelected = false;
        self.selectedAlbum = model;
        self.selectedAlbum?.isSelected = true;
        self.albumListV.reloadData()
        
        //
        self.hideAlbumList()
        self.navV.title = self.selectedAlbum?.name
        self.navV.isUp = false
        DispatchQueue.global().async {
            self.selectedAlbum?.decorateAssetModels()
            DispatchQueue.main.async {
                self.collectionV.reloadData()
                //
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.125) {
                    if let offset = self.selectedAlbum?.contentOffset {
                        self.collectionV.setContentOffset(offset, animated: false)
                    }
                }
            }
        }

    }
   
}

extension CLBAlbumAssetsVController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (self.selectedAlbum?.assets?.count ?? 0)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = floor((collectionView.frame.size.width - 2 * HORIZON_INSET - (CELL_COUNT - 1) * CELL_PADDING) / CELL_COUNT)
        return CGSize(width: width, height: width)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: REUSE_IDENTIFIER, for: indexPath) as! CLBAlbumAssetCCell
        let model = self.selectedAlbum?.assets?[indexPath.row]
        cell.model = model
        cell.selectClicked = { [weak self] model in
            
            if model?.isSelected == false { // 接下来要选中
                if CLBAlbumMediaPickerManager.shared.isFullForSelected {
//                    CLBHUD.show(text: "CLBPrivacyAlbumSelectNumOverTip".clb_Localized(), duration: 1)
                    return
                }
            }
        
            model?.isSelected = !model!.isSelected
            if model?.isSelected == true {
                CLBAlbumMediaPickerManager.shared.addSelectedAssets(model: model!)
            } else {
                CLBAlbumMediaPickerManager.shared.removeSelectedAssets(model: model!)
            }
            self?.collectionV.reloadItems(at: [indexPath])
            
        }
        cell.backgroundColor = UIColor.brown
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = CLBAlbumPreviewVController()
        vc.model = self.selectedAlbum
        vc.currentIndex = indexPath.row
        vc.selectStatusChanged = { [weak self] index in
            let indexP = IndexPath(item: index, section: 0)
            self?.collectionV.reloadItems(at: [indexP])
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard scrollView == self.collectionV else {
            return
        }
        self.selectedAlbum?.contentOffset = scrollView.contentOffset
    }
}
