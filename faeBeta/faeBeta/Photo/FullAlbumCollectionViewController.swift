//
//  CustomCollectionViewController.swift
//  quickChat
//
//  Created by User on 7/12/16.
//  Copyright © 2016 User. All rights reserved.
//

import UIKit

import Photos
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l > r
    default:
        return rhs < lhs
    }
}

// delegate to send mutiple image in ChatVC

@objc protocol SendMutipleImagesDelegate {
    
    func sendImages(_ images: [UIImage])
    @objc optional func sendVideoData(_ video: Data, snapImage: UIImage, duration: Int)
    @objc optional func sendGifData(_ data: Data)
    @objc optional func cancel()
}

private extension UICollectionView {
    func indexPathsForElements(in rect: CGRect) -> [IndexPath] {
        let allLayoutAttributes = collectionViewLayout.layoutAttributesForElements(in: rect)!
        return allLayoutAttributes.map { $0.indexPath }
    }
}

// this view controller is used to show image from one album, it has a table view for you to switch albums

class FullAlbumCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UITableViewDelegate, UITableViewDataSource {
    
    //MARK: - properties
    var viewPhotoPicker: PhotoPicker!
    
    private let photoPickerCellIdentifier = "FullPhotoPickerCollectionViewCell"
    
    private var btnCancel: UIButton! // left nav button
    private var btnSend: UIButton! // right nav button
    
    private var btnQuit: UIButton! // the background quit button when opening the album table
    private var btnShowAlbums: UIButton! // middle nav button
    
    private var lblTitle: UILabel! // the lable for the album name
    
    private let requestOption = PHImageRequestOptions()
    
    private var currentCell: AlbumTableViewCell! // current selected album cell
    
    // table view variable
    
    private var tblAlbums: UITableView! // the table for all the album name
    private let albumReuseIdentifiler = "AlbumTableViewCell"
    private var boolAlbumsVisible = false // true: displaying the album table
    
    //send image delegate
    weak var imageDelegate: SendMutipleImagesDelegate!
    
    //the maximum number of photos selected at the same time, should be 0-10
    var _maximumSelectedPhotoNum: Int = 10
    var maximumSelectedPhotoNum: Int {
        get {
            return self._maximumSelectedPhotoNum
        }
        set {
            if newValue <= 0 {
                self._maximumSelectedPhotoNum = 1
            } else if newValue > 10 {
                self._maximumSelectedPhotoNum = 10
            } else {
                self._maximumSelectedPhotoNum = newValue
            }
        }
    }
    
    var boolCreateStoryPin = false // is creating story pin
    var boolSelectingAvatar = false // is selecting avatar
    
    fileprivate let imageManager = PHCachingImageManager()
    fileprivate var sizeThumbnail: CGSize!
    fileprivate var rectPreviousPreheat = CGRect.zero
    
    enum ComeFromType {
        case lefeSlidingMenu
        case firstTimeLogin
        case setInfoNamecardAvatar
        case setInfoNamecardCover
        case chat
    }
    var vcComeFromType: ComeFromType = .chat
    var vcComeFrom: UIViewController?
    
    //MARK: - life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        resetCachedAssets()
        viewPhotoPicker = PhotoPicker.shared
        sizeThumbnail = CGSize(width: view.frame.width / 3 - 1, height: view.frame.width / 3 - 1)
        self.automaticallyAdjustsScrollViewInsets = false
        collectionView?.frame = CGRect(x: 0, y: 65 + device_offset_top, width: screenWidth, height: screenHeight - 65 - device_offset_top)
        collectionView?.backgroundColor = .white
        collectionView?.register(FullPhotoPickerCollectionViewCell.self, forCellWithReuseIdentifier: photoPickerCellIdentifier)
        requestOption.isSynchronous = false
        requestOption.resizeMode = .fast
        requestOption.deliveryMode = .highQualityFormat
        self.collectionView?.decelerationRate = UIScrollViewDecelerationRateNormal
        NotificationCenter.default.addObserver(self, selector: #selector(self.appWillEnterForeground), name: NSNotification.Name(rawValue: "appWillEnterForeground"), object: nil)
        //PHPhotoLibrary.shared().register(self)
    }
    
    /*deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }*/
    
    override func viewWillAppear(_ animated: Bool) {
        //fetch photo from collection
        self.navigationController?.hidesBarsOnTap = false
        self.collectionView?.reloadData()
        navigationBarSet()
        prepareTableView()
    }
    
    //MARK: - Setup
    private func prepareTableView() {
        tblAlbums = UITableView()
        tblAlbums.backgroundColor = UIColor.clear
        tblAlbums.separatorStyle = UITableViewCellSeparatorStyle.singleLine
        tblAlbums.separatorColor = UIColor._200199204()
        tblAlbums.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0)
        tblAlbums.tableFooterView = UIView()
        let tableViewHeight = min(CGFloat(viewPhotoPicker.selectedAlbum.count * 80), screenHeight - 65 - device_offset_top)
        tblAlbums.frame = CGRect(x: 0, y: 65 + device_offset_top, width: screenWidth, height: tableViewHeight)
        tblAlbums.register(AlbumTableViewCell.self, forCellReuseIdentifier: albumReuseIdentifiler)
        tblAlbums.delegate = self
        tblAlbums.dataSource = self
        tblAlbums.alwaysBounceVertical = false
        tblAlbums.bounces = false
    }
    
    func getUserAlbumSet() {
        let userAlbumsOptions = PHFetchOptions()
        userAlbumsOptions.predicate = NSPredicate(format: "estimatedAssetCount > 0")
        
        let userAlbums = PHAssetCollection.fetchAssetCollections(with: PHAssetCollectionType.album, subtype: PHAssetCollectionSubtype.any, options: userAlbumsOptions)
        userAlbums.enumerateObjects { (collection, _, _) in
            print("album title: \(String(describing: collection.localizedTitle))")
            //For each PHAssetCollection that is returned from userAlbums: PHFetchResult you can fetch PHAssets like so (you can even limit results to include only photo assets):
            let onlyImagesOptions = PHFetchOptions()
            onlyImagesOptions.predicate = NSPredicate(format: "mediaType = %i", PHAssetMediaType.image.rawValue)
            if let result = PHAsset.fetchKeyAssets(in: collection, options: nil) {
                print("Images count: \(result.count)")
            }
        }
    }
    
    func navigationBarSet() {
        let uiviewNavBar = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 65 + device_offset_top))
        uiviewNavBar.backgroundColor = .white
        view.addSubview(uiviewNavBar)
        
        let bottomLine = UIView(frame: CGRect(x: 0, y: 64 + device_offset_top, width: screenWidth, height: 1))
        bottomLine.layer.borderWidth = screenWidth
        bottomLine.layer.borderColor = UIColor._200199204cg()
        uiviewNavBar.addSubview(bottomLine)
        
        let centerView = UIView()
        uiviewNavBar.addSubview(centerView)
        let gapToSide = (screenWidth - 200) / 2
        uiviewNavBar.addConstraintsWithFormat("H:|-\(gapToSide)-[v0(200)]", options: [], views: centerView)
        uiviewNavBar.addConstraintsWithFormat("V:|-\(28 + device_offset_top)-[v0(30)]", options: [], views: centerView)
        
        btnShowAlbums = UIButton(frame: CGRect(x: 0, y: 0, width: 200, height: 30))
        btnShowAlbums.titleLabel?.text = ""
        btnShowAlbums.addTarget(self, action: #selector(showAlbumTable), for: .touchUpInside)
        centerView.addSubview(btnShowAlbums)
        
        lblTitle = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 30))
        let attributedStrM: NSMutableAttributedString = NSMutableAttributedString()
        let albumName = NSAttributedString(string: viewPhotoPicker.currentAlbum.albumName, attributes: [NSAttributedStringKey.foregroundColor: UIColor._898989(), NSAttributedStringKey.font: UIFont(name: "AvenirNext-Medium", size: 20)!])
        attributedStrM.append(albumName)
        let arrowAttachment: NSTextAttachment = NSTextAttachment()
        arrowAttachment.image = UIImage(named: "arrow_down")
        arrowAttachment.bounds = CGRect(x: 8, y: 1, width: 10, height: 6)
        attributedStrM.append(NSAttributedString(attachment: arrowAttachment))
        lblTitle.attributedText = attributedStrM
        lblTitle.textAlignment = .center
        centerView.addSubview(lblTitle)
        
        var strSendBtn = "Send"
        if boolCreateStoryPin {
            strSendBtn = "Select"
        }
        if vcComeFromType != .chat {
            strSendBtn = "Camera"
        }
        
        btnSend = UIButton()
        let attributedText = NSAttributedString(string: strSendBtn, attributes: [NSAttributedStringKey.foregroundColor: UIColor._2499090(), NSAttributedStringKey.font: UIFont(name: "AvenirNext-Medium", size: 18)!])
        btnSend.setAttributedTitle(attributedText, for: UIControlState())
        btnSend.contentHorizontalAlignment = .right
        btnSend.addTarget(self, action: #selector(self.sendImages), for: .touchUpInside)
        btnSend.isEnabled = false
        uiviewNavBar.addSubview(btnSend)
        uiviewNavBar.addConstraintsWithFormat("H:[v0(70)]-15-|", options: [], views: btnSend)
        uiviewNavBar.addConstraintsWithFormat("V:|-\(30 + device_offset_top)-[v0(25)]", options: [], views: btnSend)
        
        btnCancel = UIButton()
        let attributedText2 = NSAttributedString(string: "Cancel", attributes: [NSAttributedStringKey.foregroundColor: UIColor._496372(), NSAttributedStringKey.font: UIFont(name: "AvenirNext-Medium", size: 18)!])
        btnCancel.setAttributedTitle(attributedText2, for: UIControlState())
        btnCancel.contentHorizontalAlignment = .left
        btnCancel.addTarget(self, action: #selector(self.cancelSend), for: .touchUpInside)
        uiviewNavBar.addSubview(btnCancel)
        uiviewNavBar.addConstraintsWithFormat("H:|-15-[v0(60)]", options: [], views: btnCancel)
        uiviewNavBar.addConstraintsWithFormat("V:|-\(30 + device_offset_top)-[v0(25)]", options: [], views: btnCancel)
        
        updateSendButtonStatus()
    }
    
    //MARK: - support method
    @objc private func showAlbumTable() {
        if !boolAlbumsVisible {
            btnQuit = UIButton(frame: CGRect(x: 0, y: 65  + device_offset_top, width: screenWidth, height: screenHeight))
            btnQuit.backgroundColor = UIColor(red: 58 / 255, green: 51 / 255, blue: 51 / 255, alpha: 0.5)
            self.view.addSubview(btnQuit)
            btnQuit.addTarget(self, action: #selector(dismissAlbumTable), for: .touchUpInside)
            self.view.addSubview(tblAlbums)
            tblAlbums.setContentOffset(CGPoint.zero, animated: true)
            
            setupNavTitle(true)
        } else {
            dismissAlbumTable()
            setupNavTitle(false)
        }
        boolAlbumsVisible = !boolAlbumsVisible
    }
    
    // first check if tne user want to send images or video then do things accordingly
    @objc private func sendImages() {
        if viewPhotoPicker.videoAsset != nil {
            sendVideoFromQuickPicker()
        } else if viewPhotoPicker.gifAssetDict.count != 0 && sendGifFromQuickPicker() {
            
        } else if vcComeFromType != .chat {
            let imagePicker = UIImagePickerController()
            //imagePicker.delegate = arrViewController
            imagePicker.sourceType = .camera
            switch vcComeFromType {
            case .lefeSlidingMenu:
                imagePicker.delegate = vcComeFrom as! LeftSlidingMenuViewController
                break
            case .firstTimeLogin:
                imagePicker.delegate = vcComeFrom as! FirstTimeLoginViewController
                break
            case .setInfoNamecardAvatar:
                break
            case .setInfoNamecardCover:
                break
            default:
                break
            }
            var photoStatus = PHPhotoLibrary.authorizationStatus()
            if photoStatus != .authorized {
                PHPhotoLibrary.requestAuthorization({ (status) in
                    photoStatus = status
                    if photoStatus != .authorized {
                        self.showAlert(title: "Cannot access photo library", message: "Open System Setting -> Fae Map to turn on the camera access")
                        return
                    }
                    self.dismiss(animated: true, completion: nil)
                    self.vcComeFrom?.present(imagePicker, animated: true, completion: nil)
                    return
                })
            } else {
                dismiss(animated: true, completion: nil)
                vcComeFrom?.present(imagePicker, animated: true, completion: nil)
                return
                //self.dismiss(animated: true, completion: nil)
            }
        } else {
            var images = [UIImage]()
            for (_, image) in viewPhotoPicker.indexImageDict {
                images.append(image)
            }
            imageDelegate.sendImages(images)
        }
        cancelSend()
    }
    
    private func sendGifFromQuickPicker() -> Bool {
        if self.imageDelegate.sendGifData != nil {
            for data in viewPhotoPicker.gifAssetDict.values {
                self.imageDelegate.sendGifData!(data)
            }
            return true
        }
        return false
    }
    
    fileprivate func sendVideoFromQuickPicker() {
        UIScreenService.showActivityIndicator()
        let snapImage = self.viewPhotoPicker.videoImage!
        let duration = viewPhotoPicker.assetDurationDict[viewPhotoPicker.indexAssetDict[0]!] ?? 0
        // asset is you AVAsset object
        let exportSession = AVAssetExportSession(asset: viewPhotoPicker.videoAsset!, presetName: AVAssetExportPresetMediumQuality)
        let filePath = NSTemporaryDirectory().appendingFormat("/video.mov")
        do {
            try FileManager.default.removeItem(atPath: filePath)
        } catch {
            
        }
        exportSession!.outputURL = URL(fileURLWithPath: filePath) // Better to use initFileURLWithPath:isDirectory: if you know if the path is a directory vs non-directory, as it saves an i/o.
        
        let fileUrl = exportSession!.outputURL
        // e.g .mov type
        exportSession!.outputFileType = AVFileType.mov
        
        exportSession!.exportAsynchronously {
            
            switch exportSession!.status {
            case AVAssetExportSessionStatus.failed:
                print("failed import video: \(String(describing: exportSession!.error))")
                break
            case AVAssetExportSessionStatus.cancelled:
                print("cancelled import video: \(String(describing: exportSession!.error))")
                break
            default:
                print("completed import video")
                if let data = try? Data(contentsOf: fileUrl!) {
                    self.imageDelegate.sendVideoData?(data, snapImage: snapImage, duration: duration)
                }
            }
            UIScreenService.hideActivityIndicator()
        }
    }
    
    @objc private func cancelSend() {
        viewPhotoPicker.cleanup()
        
        _ = self.navigationController?.popViewController(animated: true)
        self.imageDelegate.cancel?()
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc private func dismissAlbumTable() {
        btnQuit.removeFromSuperview()
        tblAlbums.removeFromSuperview()
    }
    
    private func showAlertView(withWarning text: String) {
        let alert = UIAlertController(title: text, message: "", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func shiftChosenFrameFromIndex(_ index: Int) {
        // when deselect one image in photoes preview, we need to reshuffule
        if index > viewPhotoPicker.indexImageDict.count {
            return
        }
        for i in index...viewPhotoPicker.indexImageDict.count {
            let image = viewPhotoPicker.indexImageDict[i]
            let asset = viewPhotoPicker.indexAssetDict[i]
            viewPhotoPicker.assetIndexDict[asset!] = i - 1
            viewPhotoPicker.indexImageDict[i - 1] = image
            viewPhotoPicker.indexAssetDict[i - 1] = asset
        }
        viewPhotoPicker.indexAssetDict.removeValue(forKey: viewPhotoPicker.indexImageDict.count - 1)
        viewPhotoPicker.indexImageDict.removeValue(forKey: viewPhotoPicker.indexImageDict.count - 1)
        
        for (asset, indexPath) in viewPhotoPicker.assetIndexpath {
            let indicatorNum = viewPhotoPicker.assetIndexDict[asset]
            if let cell = collectionView?.cellForItem(at: indexPath) {
                let modifyCell = cell as! FullPhotoPickerCollectionViewCell
                modifyCell.selectCell(indicatorNum!)
            }
            /*let cell = collectionView?.dequeueReusableCell(withReuseIdentifier: photoPickerCellIdentifier, for: indexPath) as! FullPhotoPickerCollectionViewCell
            cell.selectCell(indicatorNum!)*/
        }
        // TODO blinking
        /*UIView.animate(withDuration: 0.1, animations: {
            self.collectionView?.performBatchUpdates({
                self.collectionView?.reloadSections(IndexSet(integer: 0))
                //self.collectionView?.reloadData()
            }, completion: nil)
        }, completion: nil)*/
        /*UIView.performWithoutAnimation {
            //self.collectionView?.performBatchUpdates({
                self.collectionView?.reloadSections(IndexSet(integer: 0))
            //}, completion: nil)
        }*/
    }
    
    fileprivate func updateSendButtonStatus() {
        var strSendBtn = "Send"
        if boolCreateStoryPin {
            strSendBtn = "Select"
        }
        if vcComeFromType != .chat {
            strSendBtn = "Camera"
        }
        btnSend.isEnabled = viewPhotoPicker.videoAsset != nil || viewPhotoPicker.assetIndexDict.count != 0 || vcComeFromType != .chat
        let attributedText = NSAttributedString(string: strSendBtn, attributes: [NSAttributedStringKey.foregroundColor: btnSend.isEnabled ? UIColor._2499090() : UIColor._255160160(), NSAttributedStringKey.font: UIFont(name: "AvenirNext-Medium", size: 18)!])
        btnSend.setAttributedTitle(attributedText, for: UIControlState())
    }
    
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.destructive)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    // MARK: observe value
    @objc private func appWillEnterForeground() {
        viewPhotoPicker.getSmartAlbum()
        self.collectionView?.reloadData()
        self.tblAlbums.reloadData()
    }
    
    // MARK: collectionViewController Delegate
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath) as! FullPhotoPickerCollectionViewCell
        let asset: PHAsset = self.viewPhotoPicker.currentAlbum.albumContent[indexPath.row]
        // TODO high quality photo
        if !cell.photoSelected {
            if vcComeFromType != .chat {
                let highQRequestOption = PHImageRequestOptions()
                highQRequestOption.resizeMode = .none
                //highQRequestOption.deliveryMode = .highQualityFormat //high pixel
                highQRequestOption.deliveryMode = .fastFormat
                highQRequestOption.isSynchronous = true
                highQRequestOption.isNetworkAccessAllowed = false
                PHCachingImageManager.default().requestImage(for: asset, targetSize: sizeThumbnail, contentMode: .aspectFill, options: highQRequestOption, resultHandler: { image, _ in
                    if image != nil {
                        self.imageDelegate.sendImages([image!])
                        self.cancelSend()
                    }
                })
                return
            }
            if viewPhotoPicker.indexAssetDict.count == maximumSelectedPhotoNum {
                if boolCreateStoryPin {
                    showAlertView(withWarning: "You can only have up to 6 items for your story")
                } else {
                    showAlertView(withWarning: "You can only select up to \(maximumSelectedPhotoNum) images at the same time")
                }
            } else {
                if asset.mediaType == .image {
                    if viewPhotoPicker.videoAsset != nil {
                        showAlertView(withWarning: "Sorry, Videos must be sent alone!")
                        return
                    } else if viewPhotoPicker.gifAssetDict.count > 0 {
                        showAlertView(withWarning: "Sorry Gifs must be sent alone!")
                        return
                    }
                    
                    let resources = PHAssetResource.assetResources(for: asset)
                    let orgFilename = (resources[0]).originalFilename
                    if orgFilename.lowercased().contains(".gif") {
                        //let imageManager = PHCachingImageManager()
                        let options = PHImageRequestOptions()
                        options.resizeMode = .fast
                        PHCachingImageManager.default().requestImageData(for: asset, options: options, resultHandler: { imageData, _, _, _ in
                            if let data = imageData {
                                self.viewPhotoPicker.gifAssetDict[asset] = data
                            }
                        })
                    }
                    viewPhotoPicker.assetIndexDict[asset] = viewPhotoPicker.indexImageDict.count
                    viewPhotoPicker.indexAssetDict[viewPhotoPicker.indexImageDict.count] = asset
                    viewPhotoPicker.assetIndexpath[asset] = indexPath
                    let count = self.viewPhotoPicker.indexImageDict.count
                    
                    let highQRequestOption = PHImageRequestOptions()
                    highQRequestOption.resizeMode = .none
                    //highQRequestOption.deliveryMode = .highQualityFormat //high pixel
                    highQRequestOption.deliveryMode = .fastFormat
                    highQRequestOption.isSynchronous = true
                    highQRequestOption.isNetworkAccessAllowed = false
                    PHCachingImageManager.default().requestImage(for: asset, targetSize: sizeThumbnail/*CGSize(width: asset.pixelWidth / 2, height: asset.pixelHeight / 2)*/, contentMode: .aspectFill, options: nil, resultHandler: { image, _ in
                        if image != nil {
                            self.viewPhotoPicker.indexImageDict[count] = image
                        }
                    })
                } else {
                    if self.viewPhotoPicker.indexImageDict.count != 0 || viewPhotoPicker.gifAssetDict.count != 0 {
                        showAlertView(withWarning: "Sorry Videos must be sent alone!")
                        return
                    } else if self.viewPhotoPicker.videoAsset != nil {
                        showAlertView(withWarning: "You can only send one video at the same time")
                        return
                    } else if self.viewPhotoPicker.assetDurationDict[asset] > 60 {
                        showAlertView(withWarning: "Sorry, for now you can only send video below 1 minute")
                        return
                    }
                    viewPhotoPicker.assetIndexDict[asset] = viewPhotoPicker.indexImageDict.count
                    viewPhotoPicker.indexAssetDict[viewPhotoPicker.indexImageDict.count] = asset
                    let lowQRequestOption = PHVideoRequestOptions()
                    lowQRequestOption.deliveryMode = .fastFormat //high pixel
                    PHCachingImageManager.default().requestAVAsset(forVideo: asset, options: lowQRequestOption) { asset, _, _ in
                        self.viewPhotoPicker.videoAsset = asset
                    }
                    
                    let highQRequestOption = PHImageRequestOptions()
                    highQRequestOption.resizeMode = .exact
                    highQRequestOption.deliveryMode = .highQualityFormat //high pixel
                    highQRequestOption.isSynchronous = true
                    PHCachingImageManager.default().requestImage(for: asset, targetSize: CGSize(width: 210, height: 150), contentMode: .aspectFill, options: highQRequestOption) { result, _ in
                        self.viewPhotoPicker.videoImage = result
                    }
                }
                cell.selectCell(max(viewPhotoPicker.indexImageDict.count - 1, 0))
            }
        } else {
            cell.deselectCell()
            if let deselectedIndex = viewPhotoPicker.assetIndexDict[asset] {
                viewPhotoPicker.assetIndexDict.removeValue(forKey: asset)
                viewPhotoPicker.indexAssetDict.removeValue(forKey: deselectedIndex)
                viewPhotoPicker.indexImageDict.removeValue(forKey: deselectedIndex)
                viewPhotoPicker.assetIndexpath.removeValue(forKey: asset)
                shiftChosenFrameFromIndex(deselectedIndex + 1)
            }
            
            if let _ = viewPhotoPicker.gifAssetDict[asset] {
                viewPhotoPicker.gifAssetDict.removeAll()
            }
            
            viewPhotoPicker.videoAsset = nil
            viewPhotoPicker.videoImage = nil
        }
        collectionView.deselectItem(at: indexPath, animated: true)
        updateSendButtonStatus()
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if viewPhotoPicker.cameraRoll == nil {
            viewPhotoPicker.getSmartAlbum()
        }
        return viewPhotoPicker.currentAlbum != nil ? viewPhotoPicker.currentAlbum.albumContent.count : 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1.5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width / 3 - 1, height: view.frame.width / 3 - 1)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: photoPickerCellIdentifier, for: indexPath) as! FullPhotoPickerCollectionViewCell
        
        if vcComeFromType != .chat {
            cell.imgChosenIndicator.isHidden = true
        }
        
        //get image from PHFetchResult
        let asset: PHAsset = self.viewPhotoPicker.currentAlbum.albumContent[indexPath.row]
        //let asset : PHAsset = fetchAllPhotos.object(at: indexPath.row)
        if let duration = viewPhotoPicker.assetDurationDict[asset] {
            cell.setVideoDurationLabel(withDuration: duration)
        }
        let orgFilename = asset.value(forKey: "filename") as! String
        if orgFilename.lowercased().contains(".gif") {
            cell.setGifLabel()
        }
        DispatchQueue.main.async {
            // Request an image for the asset from the PHCachingImageManager.
            cell.representedAssetIdentifier = asset.localIdentifier
            PHCachingImageManager.default().requestImage(for: asset, targetSize: self.sizeThumbnail, contentMode: .aspectFill, options: nil, resultHandler: { image, _ in
                // The cell may have been recycled by the time this handler gets called;
                // set the cell's thumbnail image only if it's still showing the same asset.
                if cell.representedAssetIdentifier == asset.localIdentifier && image != nil {
                    cell.thumbnailImage = image
                }
            })
        }
        
        if viewPhotoPicker.assetIndexDict[asset] != nil {
            cell.selectCell(viewPhotoPicker.assetIndexDict[asset]!)
        } else {
            cell.deselectCell()
        }
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let cell = cell as! FullPhotoPickerCollectionViewCell
        let asset : PHAsset = self.viewPhotoPicker.currentAlbum.albumContent[indexPath.row]
        if viewPhotoPicker.assetIndexDict[asset] != nil {
            cell.selectCell(viewPhotoPicker.assetIndexDict[asset]!)
        }else{
            cell.deselectCell()
        }
    }
    
    // MARK: table view delegate method
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: albumReuseIdentifiler) as! AlbumTableViewCell
        cell.frame = CGRect(x: 0, y: 0, width: screenWidth, height: 80)
        if indexPath.row == viewPhotoPicker.selectedAlbum.count - 1 {
            let maskPath = UIBezierPath(roundedRect: cell.bounds, byRoundingCorners: [.bottomLeft, .bottomRight], cornerRadii: CGSize(width: 5.0, height: 5.0))
            let maskLayer = CAShapeLayer()
            maskLayer.frame = cell.bounds
            maskLayer.path = maskPath.cgPath
            cell.layer.mask = maskLayer
            //cell.layer.masksToBounds = true
        }
        
        if let albumName = viewPhotoPicker.selectedAlbum[indexPath.row].albumName {
            cell.lblAlbumTitle.text = albumName
        }
        if let albumCount = viewPhotoPicker.selectedAlbum[indexPath.row].albumCount {
            cell.lblAlbumNumber.text = "\(albumCount)"
        }
        
        cell.imgCheckMark.isHidden = viewPhotoPicker.selectedAlbum[indexPath.row].albumName != viewPhotoPicker.currentAlbum.albumName
        
        if !cell.imgCheckMark.isHidden {
            currentCell = cell
        }
        //set thumbnail
        let asset: PHAsset = self.viewPhotoPicker.selectedAlbum[indexPath.row].albumContent[0]
        
        PHCachingImageManager.default().requestImage(for: asset, targetSize: CGSize(width: view.frame.width - 1 / 10, height: view.frame.width - 1 / 10), contentMode: .aspectFill, options: nil) { result, _ in
            cell.imgTitle.image = result
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewPhotoPicker.selectedAlbum.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! AlbumTableViewCell
        if cell.imgCheckMark.isHidden {
            viewPhotoPicker.currentAlbum = viewPhotoPicker.selectedAlbum[indexPath.row]
            tableView.deselectRow(at: indexPath, animated: true)
            dismissAlbumTable()
            boolAlbumsVisible = !boolAlbumsVisible
            
            setupNavTitle(false)
            
            currentCell.imgCheckMark.isHidden = true
            let cellNew = tableView.cellForRow(at: indexPath) as! AlbumTableViewCell
            cellNew.imgCheckMark.isHidden = false
            currentCell = cellNew
            collectionView?.reloadData()
        } else {
            tableView.deselectRow(at: indexPath, animated: true)
            dismissAlbumTable()
            boolAlbumsVisible = !boolAlbumsVisible
        }
    }
    
    // MARK: set the title of navigation bar
    func setupNavTitle(_ albumIsOpen: Bool) {
        let attributedStrM: NSMutableAttributedString = NSMutableAttributedString()
        let albumName = NSAttributedString(string: viewPhotoPicker.currentAlbum.albumName, attributes: [NSAttributedStringKey.foregroundColor: UIColor._898989(), NSAttributedStringKey.font: UIFont(name: "AvenirNext-Medium", size: 20)!])
        attributedStrM.append(albumName)
        let arrowAttachment: NSTextAttachment = NSTextAttachment()
        if albumIsOpen {
            arrowAttachment.image = UIImage(named: "arrow_up")
        } else {
            arrowAttachment.image = UIImage(named: "arrow_down")
        }
        arrowAttachment.bounds = CGRect(x: 8, y: 1, width: 10, height: 6)
        attributedStrM.append(NSAttributedString(attachment: arrowAttachment))
        lblTitle.attributedText = attributedStrM
    }
    
    // MARK: UIScrollView
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.updateCachedAssets()
    }
    
    // MARK: Asset Caching    
    fileprivate func resetCachedAssets() {
        imageManager.stopCachingImagesForAllAssets()
        rectPreviousPreheat = .zero
    }
    
    fileprivate func updateCachedAssets() {
        // Update only if the view is visible.
        guard isViewLoaded && view.window != nil else { return }
        
        // The preheat window is twice the height of the visible rect.
        let visibleRect = CGRect(origin: collectionView!.contentOffset, size: collectionView!.bounds.size)
        let preheatRect = visibleRect.insetBy(dx: 0, dy: -0.5 * visibleRect.height)
        
        // Update only if the visible area is significantly different from the last preheated area.
        let delta = abs(preheatRect.midY - rectPreviousPreheat.midY)
        guard delta > view.bounds.height / 3 else { return }
        
        // Compute the assets to start caching and to stop caching.
        let (addedRects, removedRects) = differencesBetweenRects(rectPreviousPreheat, preheatRect)
        let addedAssets = addedRects
            .flatMap { rect in collectionView!.indexPathsForElements(in: rect) }
            .map { indexPath in viewPhotoPicker.currentAlbum.albumContent.object(at: indexPath.item) }
        //.map { indexPath in fetchAllPhotos.object(at: indexPath.item) }
        let removedAssets = removedRects
            .flatMap { rect in collectionView!.indexPathsForElements(in: rect) }
            .map { indexPath in viewPhotoPicker.currentAlbum.albumContent.object(at: indexPath.item) }
        
        // Update the assets the PHCachingImageManager is caching.
        imageManager.startCachingImages(for: addedAssets,
                                        targetSize: sizeThumbnail, contentMode: .aspectFill, options: nil)
        imageManager.stopCachingImages(for: removedAssets,
                                       targetSize: sizeThumbnail, contentMode: .aspectFill, options: nil)
        
        // Store the preheat rect to compare against in the future.
        rectPreviousPreheat = preheatRect
    }
    
    fileprivate func differencesBetweenRects(_ old: CGRect, _ new: CGRect) -> (added: [CGRect], removed: [CGRect]) {
        if old.intersects(new) {
            var added = [CGRect]()
            if new.maxY > old.maxY {
                added += [CGRect(x: new.origin.x, y: old.maxY,
                                 width: new.width, height: new.maxY - old.maxY)]
            }
            if old.minY > new.minY {
                added += [CGRect(x: new.origin.x, y: new.minY,
                                 width: new.width, height: old.minY - new.minY)]
            }
            var removed = [CGRect]()
            if new.maxY < old.maxY {
                removed += [CGRect(x: new.origin.x, y: new.maxY,
                                   width: new.width, height: old.maxY - new.maxY)]
            }
            if old.minY < new.minY {
                removed += [CGRect(x: new.origin.x, y: old.minY,
                                   width: new.width, height: new.minY - old.minY)]
            }
            return (added, removed)
        } else {
            return ([new], [old])
        }
    }
    
}

// MARK: PHPhotoLibraryChangeObserver
extension FullAlbumCollectionViewController: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        
        guard let changes = changeInstance.changeDetails(for: viewPhotoPicker.currentAlbum.albumContent)
        else { return }
        
        // Change notifications may be made on a background queue. Re-dispatch to the
        // main queue before acting on the change as we'll be updating the UI.
        DispatchQueue.main.sync {
            // Hang on to the new fetch result.
            viewPhotoPicker.currentAlbum = SmartAlbum(albumName: viewPhotoPicker.currentAlbum.albumName, albumCount: viewPhotoPicker.currentAlbum.albumCount, albumContent: changes.fetchResultAfterChanges)
            if changes.hasIncrementalChanges {
                // If we have incremental diffs, animate them in the collection view.
                guard let collectionView = self.collectionView else { fatalError() }
                collectionView.performBatchUpdates({
                    // For indexes to make sense, updates must be in this order:
                    // delete, insert, reload, move
                    if let removed = changes.removedIndexes, !removed.isEmpty {
                        collectionView.deleteItems(at: removed.map({ IndexPath(item: $0, section: 0) }))
                    }
                    if let inserted = changes.insertedIndexes, !inserted.isEmpty {
                        collectionView.insertItems(at: inserted.map({ IndexPath(item: $0, section: 0) }))
                    }
                    if let changed = changes.changedIndexes, !changed.isEmpty {
                        collectionView.reloadItems(at: changed.map({ IndexPath(item: $0, section: 0) }))
                    }
                    changes.enumerateMoves { fromIndex, toIndex in
                        collectionView.moveItem(at: IndexPath(item: fromIndex, section: 0),
                                                to: IndexPath(item: toIndex, section: 0))
                    }
                })
            } else {
                // Reload the collection view if incremental diffs are not available.
                collectionView!.reloadData()
            }
            resetCachedAssets()
        }
    }
}
