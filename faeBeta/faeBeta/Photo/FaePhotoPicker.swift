//
//  FaePhotoPicker.swift
//  faeBeta
//
//  Created by Jichao on 2018/2/2.
//  Copyright © 2018 fae. All rights reserved.
//

import UIKit
import Photos
import PhotosUI

struct FaePhotoPickerConfigure {
    var boolFullPicker = true
    var strRightBtnTitle = "Send"
    var boolSingleSelection = false
    var boolAllowdVideo = true
    var sizeThumbnail = CGSize(width: screenWidth / 3 - 1, height: screenWidth / 3 - 1)
}

class FaePhotoPicker: UIView {
    
    // MARK: - properties
    var collectionView: UICollectionView!
    var lblTilte: UILabel?
    var tblAlbums: UITableView?
    var btnRight: UIButton?
    
    var selectedAssets = [FaePHAsset]() {
        didSet {
            if boolSingleSelection { return }
            btnRight?.isEnabled = (selectedAssets.count > 0)
            let attributedText = NSAttributedString(string: strRightBtnTitle, attributes: [NSAttributedStringKey.foregroundColor: selectedAssets.count > 0 ? UIColor._2499090() : UIColor._255160160(), NSAttributedStringKey.font: UIFont(name: "AvenirNext-Medium", size: 18)!])
            btnRight?.setAttributedTitle(attributedText, for: UIControlState())
        }
    }
    var collections = [FaePHAssetCollection]()
    var currentCollection: FaePHAssetCollection? = nil
    var requestIds = [IndexPath: PHImageRequestID]()
    var cloudRequestIds = [IndexPath: PHImageRequestID]()
    var photoLibrary = FaePhotoLibrary()
    
    var prefetchQueue = DispatchQueue(label: "prefetchQueue")
    var intMaxSelectedAssets: Int = 9
    var activityIndicator: UIActivityIndicatorView?
    var leftBtnHandler: (() -> Void)? = nil
    var rightBtnHandler: (([FaePHAsset], Bool) -> Void)? = nil
    
    // MARK: configuration
    var configuration = FaePhotoPickerConfigure()
    var scrollDirection: UICollectionViewScrollDirection { return boolFullPicker ? .vertical : .horizontal }
    var boolFullPicker: Bool { return configuration.boolFullPicker }
    var strRightBtnTitle: String { return configuration.strRightBtnTitle }
    var boolSingleSelection: Bool { return configuration.boolSingleSelection }
    var boolAllowedVideo: Bool { return configuration.boolAllowdVideo }
    var thumbnailSize: CGSize { return configuration.sizeThumbnail }
    
    // MARK: - init & setup
    init(frame: CGRect, with configure: FaePhotoPickerConfigure) {
        self.configuration = configure
        super.init(frame: frame)
        if PHPhotoLibrary.authorizationStatus() != .authorized {
            PHPhotoLibrary.requestAuthorization { [weak self] _ in
                self?.photoLibrary.delegate = self
                self?.photoLibrary.fetchCollection(with: (self?.configuration)!)
            }
        }
        
        if photoLibrary.delegate == nil {
            if PHPhotoLibrary.authorizationStatus() == .authorized {
                photoLibrary.delegate = self
                photoLibrary.fetchCollection(with: configuration)
            }
        }
        setupUI(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI(frame: CGRect) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = scrollDirection
        collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height), collectionViewLayout: layout)
        collectionView.register(PhotoCollectionViewCell.self, forCellWithReuseIdentifier: PhotoCollectionViewCell.identifier)
        collectionView.backgroundColor = .white
        addSubview(collectionView)
        collectionView.dataSource = self
        collectionView.delegate = self
        if #available(iOS 10.0, *) {
            collectionView.isPrefetchingEnabled = true
            collectionView.prefetchDataSource = self
        } else {
            // Fallback on earlier versions
        }
        if boolFullPicker {
            setupNavBar()
            
            collectionView.frame = CGRect(x: 0, y: 65 + device_offset_top, width: frame.width, height: frame.height - 65 - device_offset_top)
            
            activityIndicator = UIActivityIndicatorView(frame: CGRect(x: screenWidth / 2 - 15, y: screenHeight / 2 - 15, width: 30, height: 30))
            activityIndicator!.activityIndicatorViewStyle = .whiteLarge
            addSubview(activityIndicator!)
        }
    }
    
    func setupNavBar() {
        let uiviewNavBar = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 65 + device_offset_top))
        uiviewNavBar.backgroundColor = .white
        addSubview(uiviewNavBar)
        
        let uiviewLine = UIView(frame: CGRect(x: 0, y: 64 + device_offset_top, width: screenWidth, height: 1))
        uiviewLine.layer.borderWidth = screenWidth
        uiviewLine.layer.borderColor = UIColor._200199204cg()
        uiviewNavBar.addSubview(uiviewLine)
        
        let uiviewCenter = UIView()
        uiviewNavBar.addSubview(uiviewCenter)
        uiviewNavBar.addConstraintsWithFormat("H:|-\(screenWidth / 2 - 100)-[v0(200)]", options: [], views: uiviewCenter)
        uiviewNavBar.addConstraintsWithFormat("V:|-\(28 + device_offset_top)-[v0(30)]", options: [], views: uiviewCenter)
        
        let btnShowAlbums = UIButton(frame: CGRect(x: 0, y: 0, width: 200, height: 30))
        btnShowAlbums.titleLabel?.text = ""
        btnShowAlbums.addTarget(self, action: #selector(showAlbumTable), for: .touchUpInside)
        uiviewCenter.addSubview(btnShowAlbums)
        
        lblTilte = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 30))
        lblTilte!.text = "All Photos"
        lblTilte!.textAlignment = .center
        uiviewCenter.addSubview(lblTilte!)
        setupNavTitle(at: lblTilte, albumTable: false)
        
        let btnLeft = UIButton()
        let attributedTextLeft = NSAttributedString(string: "Cancel", attributes: [NSAttributedStringKey.foregroundColor: UIColor._496372(), NSAttributedStringKey.font: UIFont(name: "AvenirNext-Medium", size: 18)!])
        btnLeft.setAttributedTitle(attributedTextLeft, for: UIControlState())
        btnLeft.contentHorizontalAlignment = .left
        btnLeft.addTarget(self, action: #selector(leftBtnAction), for: .touchUpInside)
        uiviewNavBar.addSubview(btnLeft)
        uiviewNavBar.addConstraintsWithFormat("H:|-15-[v0(60)]", options: [], views: btnLeft)
        uiviewNavBar.addConstraintsWithFormat("V:|-\(30 + device_offset_top)-[v0(25)]", options: [], views: btnLeft)
        
        self.btnRight = UIButton()
        let attributedTextRight = NSAttributedString(string: strRightBtnTitle, attributes: [NSAttributedStringKey.foregroundColor: boolSingleSelection ? UIColor._2499090() : UIColor._255160160(), NSAttributedStringKey.font: UIFont(name: "AvenirNext-Medium", size: 18)!])
        let btnRight = self.btnRight!
        btnRight.setAttributedTitle(attributedTextRight, for: UIControlState())
        btnRight.contentHorizontalAlignment = .right
        btnRight.addTarget(self, action: #selector(rightBtnAction), for: .touchUpInside)
        uiviewNavBar.addSubview(btnRight)
        uiviewNavBar.addConstraintsWithFormat("H:[v0(70)]-15-|", options: [], views: btnRight)
        uiviewNavBar.addConstraintsWithFormat("V:|-\(30 + device_offset_top)-[v0(25)]", options: [], views: btnRight)
        btnRight.isEnabled = boolSingleSelection
    }
    
    func setupAlbumTable() {
        self.tblAlbums = UITableView()
        let tblAlbums = self.tblAlbums!
        tblAlbums.backgroundColor = .clear
        tblAlbums.separatorStyle = .singleLine
        tblAlbums.separatorColor = UIColor._200199204()
        tblAlbums.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0)
        tblAlbums.tableFooterView = UIView()
        let tableHeight = min(CGFloat(collections.count * 80), screenHeight - 65 - device_offset_top)
        tblAlbums.frame = CGRect(x: 0, y: 65 + device_offset_top, width: screenWidth, height: tableHeight)
        tblAlbums.register(AlbumsTableViewCell.self, forCellReuseIdentifier: AlbumsTableViewCell.identifier)
        addSubview(tblAlbums)
        tblAlbums.delegate = self
        tblAlbums.dataSource = self
        tblAlbums.alwaysBounceVertical = false
        tblAlbums.bounces = false
        tblAlbums.isHidden = true
    }
    
    @objc func showAlbumTable() {
        guard let tableView = self.tblAlbums else { return }
        if tableView.isHidden {
            //tableView.frame.origin.y = screenHeight
            tableView.isHidden = false
            /*UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations: {
             tableView.frame.origin.y = 65 + device_offset_top
             }, completion: nil)*/
            setupNavTitle(at: lblTilte, albumTable: true)
        } else {
            /*UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
             tableView.frame.origin.y = screenHeight
             }, completion: { _ in
             tableView.isHidden = true
             })*/
            tableView.isHidden = true
            setupNavTitle(at: lblTilte, albumTable: false)
        }
    }
    
    @objc func rightBtnAction() {
        rightBtnHandler?(selectedAssets, boolSingleSelection)
    }
    
    @objc func leftBtnAction() {
        leftBtnHandler?()
    }
}

// MARK: - UICollectionViewDataSource & Prefetching
extension FaePhotoPicker: UICollectionViewDataSource, UICollectionViewDataSourcePrefetching {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let collection = currentCollection else { return 0 }
        return collection.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCollectionViewCell.identifier, for: indexPath) as! PhotoCollectionViewCell
        guard let collection = currentCollection else { return cell }
        guard let asset = collection.getFaePHAsset(at: indexPath.item) else { return cell }
        cell.boolFullPicker = boolFullPicker
        if let selectedAsset = getSelectedAssets(asset) {
            cell.boolIsSelected = true
            cell.intSelectedOrder = selectedAsset.selectedOrder
        } else {
            cell.boolIsSelected = false
        }
        if let phAsset = asset.phAsset {
            let options = PHImageRequestOptions()
            options.deliveryMode = .opportunistic
            options.isNetworkAccessAllowed = true
            let requestId = photoLibrary.imageAsset(asset: phAsset, size: thumbnailSize, options: options) { [weak cell] (image, complete) in
                DispatchQueue.main.async {
                    if self.requestIds[indexPath] != nil {
                        cell?.imgPhoto.image = image
                        if asset.assetType == .video {
                            cell?.setupVideo(with: phAsset.duration)
                        } else if asset.fileFormat() == .gif {
                            cell?.setupGifLabel()
                        }
                        if complete {
                            self.requestIds.removeValue(forKey: indexPath)
                        }
                    }
                }
            }
            if requestId > 0 {
                requestIds[indexPath] = requestId
            }
        }
        return cell
    }
    
    func getSelectedAssets(_ asset: FaePHAsset) -> FaePHAsset? {
        if let index = selectedAssets.index(where: { $0.phAsset == asset.phAsset }) {
            return selectedAssets[index]
        }
        return nil
    }
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        prefetchQueue.async { [weak self] in
            guard let `self` = self, let collection = self.currentCollection else { return }
            let indexInOrder = indexPaths.sorted(by: { $0.row < $1.row })
            if indexPaths.count <= collection.count, let first = indexInOrder.first?.row, let last = indexInOrder.last?.row {
                guard let assets = collection.getPHAssets(at: first...last) else { return }
                let scale = max(UIScreen.main.scale, 2)
                let targetSize = CGSize(width: self.thumbnailSize.width * scale, height: self.thumbnailSize.height * scale)
                self.photoLibrary.imageManager.startCachingImages(for: assets, targetSize: targetSize, contentMode: .aspectFill, options: nil)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            guard let requestId = requestIds[indexPath] else { continue }
            photoLibrary.cancelPHImageRequest(requestId: requestId)
            requestIds.removeValue(forKey: indexPath)
        }
        prefetchQueue.async { [weak self] in
            guard let `self` = self, let collection = self.currentCollection else { return }
            let indexInOrder = indexPaths.sorted(by: { $0.row < $1.row })
            if indexPaths.count <= collection.count, let first = indexInOrder.first?.row, let last = indexInOrder.last?.row {
                guard let assets = collection.getPHAssets(at: first...last) else { return }
                let scale = max(UIScreen.main.scale, 2)
                let targetSize = CGSize(width: self.thumbnailSize.width * scale, height: self.thumbnailSize.height * scale)
                self.photoLibrary.imageManager.stopCachingImages(for: assets, targetSize: targetSize, contentMode: .aspectFill, options: nil)
            }
        }
    }
}

// MARK: UICollectionViewDelegate
extension FaePhotoPicker: UICollectionViewDelegate {
    func updateSelectedOrder() {
        let visibleIndexPaths = collectionView.indexPathsForVisibleItems.sorted(by: { $0.row < $1.row})
        for indexPath in visibleIndexPaths {
            guard let cell = collectionView.cellForItem(at: indexPath) as? PhotoCollectionViewCell else { continue }
            guard let asset = currentCollection?.getFaePHAsset(at: indexPath.row) else { continue }
            if let selectedAsset = getSelectedAssets(asset) {
                cell.boolIsSelected = true
                cell.intSelectedOrder = selectedAsset.selectedOrder
            } else {
                cell.boolIsSelected = false
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let collection = currentCollection, let cell = collectionView.cellForItem(at: indexPath) as? PhotoCollectionViewCell else { return }
        guard var asset = collection.getFaePHAsset(at: indexPath.row) else { return }
        if boolSingleSelection {
            rightBtnHandler?([asset], false)
        } else {
            if let index = selectedAssets.index(where: { $0.phAsset == asset.phAsset }) {
                selectedAssets.remove(at: index)
                selectedAssets = selectedAssets.enumerated().flatMap({ (offset, asset) -> FaePHAsset? in
                    var asset = asset
                    asset.selectedOrder = offset + 1
                    return asset
                })
                cell.boolIsSelected = false
                updateSelectedOrder()
            } else {
                guard !maxCheck() else { return }
                asset.selectedOrder = selectedAssets.count + 1
                selectedAssets.append(asset)
                requestCloudDownload(asset: asset, indexPath: indexPath)
                cell.boolIsSelected = true
                cell.intSelectedOrder = asset.selectedOrder
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let requestId = requestIds[indexPath] else { return }
        requestIds.removeValue(forKey: indexPath)
        photoLibrary.cancelPHImageRequest(requestId: requestId)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? PhotoCollectionViewCell, let collection = self.currentCollection, let asset = collection.getFaePHAsset(at: indexPath.item) {
            if let selectedAsset = getSelectedAssets(asset) {
                cell.boolIsSelected = true
                cell.intSelectedOrder = selectedAsset.selectedOrder
            } else {
                cell.boolIsSelected = false
            }
        }
    }
}

// MARK: UICollectionViewDelegateFlowLayout
extension FaePhotoPicker: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return thumbnailSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0 / 3
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0 / 3
    }
}

// MARK: - UITableViewDataSource
extension FaePhotoPicker: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return collections.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: AlbumsTableViewCell.identifier, for: indexPath) as! AlbumsTableViewCell
        let collection = collections[indexPath.row]
        cell.imgTitle.image = collection.thumbnail
        cell.lblAlbumTitle.text = collection.title
        if let phAsset = collection.getPHAsset(at: 0), collection.thumbnail == nil {
            let scale = UIScreen.main.scale
            let size = CGSize(width: 30 * scale, height: 30 * scale)
            photoLibrary.imageAsset(asset: phAsset, size: size, completion: { (image, complete) in
                DispatchQueue.main.async {
                    cell.imgTitle.image = image
                }
            })
        }
        return cell
    }
}

// MARK: UITableViewDelegate
extension FaePhotoPicker: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectAlbum(collection: collections[indexPath.row])
        tableView.isHidden = true
        setupNavTitle(at: lblTilte, albumTable: false)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}

// MARK: - FaePhotoLibraryDelegate
extension FaePhotoPicker: FaePhotoLibraryDelegate {
    func loadCameraRollCollection(collection: FaePHAssetCollection) {
        changeCollection(collection: collection)
        collections = [collection]
        collectionView.reloadData()
        collectionView.setNeedsLayout()
        collectionView.layoutIfNeeded()
        tblAlbums?.reloadData()
        setupNavTitle(at: lblTilte, albumTable: false)
    }
    
    func loadCompleteAllCollection(collections: [FaePHAssetCollection]) {
        self.collections = collections
        setupAlbumTable()
        tblAlbums?.reloadData()
    }
    
    func changeCollection(collection: FaePHAssetCollection) {
        currentCollection = collection
        
    }
}

extension FaePhotoPicker {
    func maxCheck() -> Bool {
        if intMaxSelectedAssets <= selectedAssets.count {
            return true
        }
        return false
    }
    
    func selectAlbum(collection: FaePHAssetCollection) {
        cancelAllCloudRequests()
        cancelAllAssetsRequests()
        currentCollection = collection
        currentCollection?.fetchResult = photoLibrary.fetchResult(collection: collection)
        collectionView.reloadData()
    }
    
    func setupNavTitle(at lblTitle: UILabel?, albumTable isOpen: Bool) {
        guard let title = lblTilte else { return }
        let attributedStrM: NSMutableAttributedString = NSMutableAttributedString()
        guard let collection = currentCollection else { return }
        let albumName = NSAttributedString(string: collection.title, attributes: [NSAttributedStringKey.foregroundColor: UIColor._898989(), NSAttributedStringKey.font: UIFont(name: "AvenirNext-Medium", size: 20)!])
        attributedStrM.append(albumName)
        let arrowAttachment: NSTextAttachment = NSTextAttachment()
        if isOpen {
            arrowAttachment.image = UIImage(named: "arrow_up")
        } else {
            arrowAttachment.image = UIImage(named: "arrow_down")
        }
        arrowAttachment.bounds = CGRect(x: 8, y: 1, width: 10, height: 6)
        attributedStrM.append(NSAttributedString(attachment: arrowAttachment))
        title.attributedText = attributedStrM
    }
}

extension FaePhotoPicker {
    func requestCloudDownload(asset: FaePHAsset, indexPath: IndexPath) {
        if asset.state != .complete {
            var asset = asset
            asset.state = .ready
            guard let phAsset = asset.phAsset else { return }
            let requestId = asset.cloudImageDownload(progress: { [weak self] (progress) in
                guard let `self` = self else { return }
                if asset.state == .ready {
                    asset.state = .progress
                    if let index = self.selectedAssets.index(where: { $0.phAsset == phAsset }) {
                        self.selectedAssets[index] = asset
                    }
                    DispatchQueue.main.async {
                        self.activityIndicator?.startAnimating()
                    }
                }
                }, completion: { [weak self] (image) in
                    guard let `self` = self else { return }
                    asset.state = .complete
                    if let index = self.selectedAssets.index(where: { $0.phAsset == phAsset }) {
                        self.selectedAssets[index] = asset
                    }
                    self.cloudRequestIds.removeValue(forKey: indexPath)
                    DispatchQueue.main.async {
                        self.activityIndicator?.stopAnimating()
                    }
            })
            if let id = requestId, id > 0 {
                cloudRequestIds[indexPath] = id
            }
        }
    }
    
    func cancelCloudRequest(indexPath: IndexPath) {
        guard let requestId = cloudRequestIds[indexPath] else { return }
        cloudRequestIds.removeValue(forKey: indexPath)
        photoLibrary.cancelPHImageRequest(requestId: requestId)
    }
    
    func cancelAllCloudRequests() {
        for (_, requestId) in cloudRequestIds {
            photoLibrary.cancelPHImageRequest(requestId: requestId)
        }
        cloudRequestIds.removeAll()
    }
    
    func cancelAllAssetsRequests() {
        for (_, requestId) in requestIds {
            photoLibrary.cancelPHImageRequest(requestId: requestId)
        }
        requestIds.removeAll()
    }
    
    
}

