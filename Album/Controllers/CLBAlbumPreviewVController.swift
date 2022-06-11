//
//  CLBAlbumPreviewVController.swift
//  Album
//
//  Created by xinweizhou on 2021/12/8.
//

import UIKit

private let TOP_INSET: CGFloat = 10
private let CELL_PADDING: CGFloat = 5
private let REUSE_IDENTIFIER = "CLBAlbumPreviewCCell"

class CLBAlbumPreviewVController: CLBAlbumBaseVController {

    private lazy var selectBtn: UIButton = {
        let view = UIButton(type: .custom)
        view.contentMode = .right
        let image0 = UIImage(named: "privacy_album_item_select")?.withRenderingMode(.alwaysOriginal)
        view.setImage(image0, for: .selected)
        let image1 = UIImage(named: "privacy_album_item_unselect")?.withRenderingMode(.alwaysOriginal)
        view.setImage(image1, for: .normal)
        view.addTarget(self, action: #selector(selectBtnClicked), for: .touchUpInside)
        return view
    }()
    
    @objc private func selectBtnClicked() {
        if let assets = self.model?.assets?[currentIndex ?? 0] {
            if assets.isSelected == false && CLBAlbumMediaPickerManager.shared.isFullForSelected { // 接下来要选中
                CLBHUD.show(text: "CLBPrivacyAlbumSelectNumOverTip".clb_Localized(), duration: 1)
                return
            }
            
            assets.isSelected = !assets.isSelected
            if assets.isSelected == true {
                CLBAlbumMediaPickerManager.shared.addSelectedAssets(model: assets)
            } else {
                CLBAlbumMediaPickerManager.shared.removeSelectedAssets(model: assets)
            }
    
            selectBtn.isSelected = assets.isSelected
            self.selectStatusChanged?(self.currentIndex ?? 0)
        }
    }
    
    var selectStatusChanged: ((_ index: Int) -> ())?
    
    
    private lazy var navV: CLBAlbumAssetsNavView = {
        let view = Bundle.main.loadNibNamed("CLBAlbumAssetsNavView", owner: nil, options: nil)?.first as! CLBAlbumAssetsNavView
        
        view.addSubview(self.selectBtn)
        self.selectBtn.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.width.height.equalTo(44)
            make.trailing.equalToSuperview().offset(-16)
        }
        
        return view
    }()
    
    
    private lazy var collectionV: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = CELL_PADDING
        layout.minimumInteritemSpacing = CELL_PADDING
        
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.register(CLBAlbumPreviewCCell.self, forCellWithReuseIdentifier: REUSE_IDENTIFIER)
        view.delegate = self
        view.dataSource = self
        view.isPagingEnabled = true
        view.bounces = false
        view.showsHorizontalScrollIndicator = false
        view.showsVerticalScrollIndicator = false
        view.contentInsetAdjustmentBehavior = UIScrollView.ContentInsetAdjustmentBehavior.never
        
        return view
    }()
    
    var model: CLBAlbumAlbumModel?
    var currentIndex: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set up
        self.setUp()
        
        // init
//        self.collectionV.safeAreaInsets
//        self.collectionV.contentInsetAdjustmentBehavior
        self.navV.showStyle = .default
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let index = self.currentIndex ?? 0
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.025) {
            //
            let model = self.model?.assets?[index]
            self.selectBtn.isSelected = model!.isSelected
            //
            let indexPath = IndexPath(row: index, section: 0)
            self.collectionV.scrollToItem(at: indexPath, at: .left, animated: false)
        }

    }
    
    private func setUp() {
        
        //
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
            self?.navigationController?.popViewController(animated: true)
        }
        
        self.view.addSubview(self.collectionV)
        self.collectionV.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview().offset(CELL_PADDING)
            make.top.equalTo(self.navV.snp.bottom)
            make.bottom.equalToSuperview().offset(-34)
        }
        self.collectionV.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: CELL_PADDING)
        
    }

    
    
}


extension CLBAlbumPreviewVController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentOffsetx = scrollView.contentOffset.x
        let index = Int((contentOffsetx + 1) / scrollView.bounds.width)
        if index == self.currentIndex {
            return
        }
        self.currentIndex = index
        let model = self.model?.assets?[index]
        self.selectBtn.isSelected = model!.isSelected
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (self.model?.assets?.count ?? 0)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width -  CELL_PADDING
        return CGSize(width: width, height: collectionView.bounds.height)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: REUSE_IDENTIFIER, for: indexPath) as! CLBAlbumPreviewCCell
        
        let model = self.model?.assets?[indexPath.row]
        if model?.type == .video {
            cell.prepare(style: .video, model: model)
        } else {
            cell.prepare(style: .image, model: model)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let model = self.model?.assets?[indexPath.row]
        let cell = cell as? CLBAlbumPreviewCCell
    
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if model?.type == .video {
                cell?.show(style: .video, model: model)
            } else {
                cell?.show(style: .image, model: model)
            }
        }

    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let ce = cell as? CLBAlbumPreviewCCell
        ce?.endDisplay()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let vc = PLDMeditationPlayViewController()
//        vc.model = self.model
//        let item = self.model?.data?[indexPath.row]
//        vc.selectedItem = item
//        self.navigationController?.pushViewController(vc, animated: true)
    }
}
