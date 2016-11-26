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
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
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
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


// delegate to send mutiple image in ChatVC

@objc protocol SendMutipleImagesDelegate {
    
    func sendImages(_ images:[UIImage])
    @objc optional func sendVideoData(_ video: Data, snapImage: UIImage, duration: Int)
    @objc optional func sendGifData(_ data: Data)
}

// this view controller is used to show image from one album, it has a table view for you to switch albums

class FullAlbumCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UITableViewDelegate, UITableViewDataSource {
    
    //MARK: - properties
    private var photoPicker : PhotoPicker!
    
    private let photoPickerCellIdentifier = "FullPhotoPickerCollectionViewCell"
    
    private var cancelButton : UIButton! // left nav button
    private var sendButton: UIButton! // right nav button
    
    private var quitButton : UIButton! // the background quit button when opening the album table
    private var showTableButton : UIButton! // middle nav button
    
    private var titleLabel : UILabel! // the lable for the album name
    
    private let requestOption = PHImageRequestOptions()
    
    private var currentCell : AlbumTableViewCell! // current selected album cell
    
    // table view variable
    
    private var tableViewAlbum : UITableView! // the table for all the album name
    private let albumReuseIdentifiler = "AlbumTableViewCell"
    private var tableViewAlbumVisible = false // true: displaying the album table

    //send image delegate
    
    weak var imageDelegate : SendMutipleImagesDelegate!

    //MARK: - life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        photoPicker = PhotoPicker.shared
        collectionView?.backgroundColor = UIColor.white
        collectionView?.register(UINib(nibName: "FullPhotoPickerCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: photoPickerCellIdentifier)
        requestOption.isSynchronous = false
        requestOption.resizeMode = .fast
        requestOption.deliveryMode = .highQualityFormat
        self.collectionView?.decelerationRate = UIScrollViewDecelerationRateNormal
        navigationBarSet()
        NotificationCenter.default.addObserver(self, selector: #selector(self.appWillEnterForeground), name:NSNotification.Name(rawValue: "appWillEnterForeground"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //fetch photo from collection
        self.navigationController?.hidesBarsOnTap = false
        self.collectionView?.reloadData()
        prepareTableView()
    }
    
    //MARK: - Setup
    private func prepareTableView() {
        tableViewAlbum = UITableView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 480))
        tableViewAlbum.register(UINib(nibName: "AlbumTableViewCell", bundle: nil), forCellReuseIdentifier: albumReuseIdentifiler)
        tableViewAlbum.delegate = self
        tableViewAlbum.dataSource = self
    }
    
    func getUserAlbumSet() {
        let userAlbumsOptions = PHFetchOptions()
        userAlbumsOptions.predicate = NSPredicate(format: "estimatedAssetCount > 0")
        
        let userAlbums = PHAssetCollection.fetchAssetCollections(with: PHAssetCollectionType.album, subtype: PHAssetCollectionSubtype.any, options: userAlbumsOptions)
        
        userAlbums.enumerateObjects( {
            let collection = $0.0
            print("album title: \(collection.localizedTitle)")
            //For each PHAssetCollection that is returned from userAlbums: PHFetchResult you can fetch PHAssets like so (you can even limit results to include only photo assets):
            let onlyImagesOptions = PHFetchOptions()
            onlyImagesOptions.predicate = NSPredicate(format: "mediaType = %i", PHAssetMediaType.image.rawValue)
            if let result = PHAsset.fetchKeyAssets(in: collection, options: nil) {
                print("Images count: \(result.count)")
            }
            
        } )
    }
    
    func navigationBarSet() {
        let centerView = UIView(frame: CGRect(x: 0,y: 0,width: 200,height: 30))
        showTableButton = UIButton(frame: CGRect(x: 0, y: 0, width: 200, height: 30))
        showTableButton.titleLabel?.text = ""
        showTableButton.addTarget(self, action: #selector(FullAlbumCollectionViewController.showAlbumTable), for: .touchUpInside)
        
        self.navigationController?.navigationBar.tintColor = UIColor.faeAppRedColor()
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.isTranslucent = false
        
        titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 25))
        titleLabel.text = "All Photos"
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont(name: "AvenirNext-Medium", size: 20)
        titleLabel.textColor = UIColor(red: 89 / 255, green: 89 / 255, blue: 89 / 255, alpha: 1.0)
        centerView.addSubview(titleLabel)
        
        
        let arrow = UIImageView(frame: CGRect(x: 97, y: 25, width: 10, height: 6))
        arrow.image = UIImage(named: "arrow")
        centerView.addSubview(arrow)
        centerView.addSubview(showTableButton)
        self.navigationItem.titleView = centerView
        
        sendButton = UIButton(frame: CGRect(x: 0,y: 0,width: 50,height: 30))
        let attributedText = NSAttributedString(string:"Send", attributes: [NSForegroundColorAttributeName: UIColor.faeAppRedColor(), NSFontAttributeName: UIFont(name: "AvenirNext-Medium", size: 18)!])
        sendButton.setAttributedTitle(attributedText, for: UIControlState())
        sendButton.contentHorizontalAlignment = .right
        sendButton.addTarget(self, action: #selector(self.sendImages), for: .touchUpInside)
        sendButton.isEnabled = false
        let offsetItem = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        offsetItem.width = -10
        self.navigationItem.rightBarButtonItems = [offsetItem, UIBarButtonItem.init(customView: sendButton)]
        
        
        cancelButton = UIButton(frame: CGRect(x: 0,y: 0,width: 60,height: 30))
        let attributedText2 = NSAttributedString(string:"Cancel", attributes: [NSForegroundColorAttributeName: UIColor.faeAppRedColor(), NSFontAttributeName: UIFont(name: "AvenirNext-Medium", size: 18)!])
        cancelButton.setAttributedTitle(attributedText2, for: UIControlState())
        cancelButton.contentHorizontalAlignment = .left
        cancelButton.addTarget(self, action: #selector(self.cancelSend), for: .touchUpInside)
        self.navigationItem.leftBarButtonItems = [offsetItem, UIBarButtonItem.init(customView: cancelButton)]
        
        updateSendButtonStatus()
    }
    
    //MARK: - support method
    
    @objc private func showAlbumTable() {
        if !tableViewAlbumVisible {
            quitButton = UIButton(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
            quitButton.backgroundColor = UIColor(red: 58 / 255, green: 51 / 255, blue: 51 / 255, alpha: 0.5)
            self.view.addSubview(quitButton)
            quitButton.addTarget(self, action: #selector(FullAlbumCollectionViewController.dismissAlbumTable), for: .touchUpInside)
            self.view.addSubview(tableViewAlbum)
            tableViewAlbum.setContentOffset(CGPoint.zero, animated: true)
        } else {
            dismissAlbumTable()
        }
        tableViewAlbumVisible = !tableViewAlbumVisible
    }
    
    // first check if tne user want to send images or video then do things accordingly
    @objc private func sendImages() {
        if(photoPicker.videoAsset != nil){
            sendVideoFromQuickPicker()
        }
        else if (photoPicker.gifAssetDict.count != 0 && sendGifFromQuickPicker()){
            
        }
        else{
            var images = [UIImage]()
            for i in 0..<photoPicker.indexImageDict.count
            {
                images.append( photoPicker.indexImageDict[i]! )
            }
            imageDelegate.sendImages(images)
        }
        cancelSend()
    }
    
    private func sendGifFromQuickPicker() -> Bool
    {
        if self.imageDelegate.sendGifData != nil{
            for data in photoPicker.gifAssetDict.values {
                self.imageDelegate.sendGifData!(data)
            }
            return true
        }
        return false
    }
    
    fileprivate func sendVideoFromQuickPicker()
    {
        UIScreenService.showActivityIndicator()
        let snapImage = self.photoPicker.videoImage!
        let duration = photoPicker.assetDurationDict[photoPicker.indexAssetDict[0]!] ?? 0
        // asset is you AVAsset object
        let exportSession = AVAssetExportSession(asset:photoPicker.videoAsset!, presetName: AVAssetExportPresetMediumQuality)
        let filePath = NSTemporaryDirectory().appendingFormat("/video.mov")
        do{
            try FileManager.default.removeItem(atPath: filePath)
        }catch{
            
        }
        exportSession!.outputURL = URL(fileURLWithPath: filePath) // Better to use initFileURLWithPath:isDirectory: if you know if the path is a directory vs non-directory, as it saves an i/o.
        
        let fileUrl = exportSession!.outputURL
        // e.g .mov type
        exportSession!.outputFileType = AVFileTypeQuickTimeMovie
        
        exportSession!.exportAsynchronously{
            Void in
            switch exportSession!.status {
            case  AVAssetExportSessionStatus.failed:
                print("failed import video: \(exportSession!.error)")
                break
            case AVAssetExportSessionStatus.cancelled:
                print("cancelled import video: \(exportSession!.error)")
                break
            default:
                print("completed import video")
                if let data = try? Data(contentsOf: fileUrl!){
                    self.imageDelegate.sendVideoData?(data, snapImage: snapImage, duration: duration)
                }
            }
            UIScreenService.hideActivityIndicator()
        }
    }
    
    @objc private func cancelSend() {
        photoPicker.cleanup()

        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @objc private func dismissAlbumTable() {
        quitButton.removeFromSuperview()
        tableViewAlbum.removeFromSuperview()
    }
    
    private func showAlertView(withWarning text:String) {
        let alert = UIAlertController(title: text, message: "", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    
    private func shiftChosenFrameFromIndex(_ index : Int) {
        // when deselect one image in photoes preview, we need to reshuffule
        if index > photoPicker.indexImageDict.count {
            return
        }
        for i in index...photoPicker.indexImageDict.count {
            let image = photoPicker.indexImageDict[i]
            let asset = photoPicker.indexAssetDict[i]
            photoPicker.assetIndexDict[asset!] = i - 1
            photoPicker.indexImageDict[i-1] = image
            photoPicker.indexAssetDict[i-1] = asset
        }
        photoPicker.indexAssetDict.removeValue(forKey: photoPicker.indexImageDict.count - 1)
        photoPicker.indexImageDict.removeValue(forKey: photoPicker.indexImageDict.count - 1)
        self.collectionView?.performBatchUpdates({
            self.collectionView?.reloadSections(IndexSet(integer: 0) )
            }, completion: nil)

    }
    
    fileprivate func updateSendButtonStatus()
    {
        sendButton.isEnabled = photoPicker.videoAsset != nil || photoPicker.assetIndexDict.count != 0
        let attributedText = NSAttributedString(string:"Send", attributes: [NSForegroundColorAttributeName:sendButton.isEnabled ? UIColor.faeAppRedColor() : UIColor.faeAppDisabledRedColor(), NSFontAttributeName: UIFont(name: "AvenirNext-Medium", size: 18)!])
        sendButton.setAttributedTitle(attributedText, for: UIControlState())
    }
    
    //MARK: - observe value
    @objc private func appWillEnterForeground()
    {
        photoPicker.getSmartAlbum()
        self.collectionView?.reloadData()
        self.tableViewAlbum.reloadData()
    }
    
    //MARK: - collectionViewController Delegate
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath) as! PhotoPickerCollectionViewCell
        let asset : PHAsset = self.photoPicker.cameraRoll.albumContent[indexPath.row] as! PHAsset
        
        if !cell.photoSelected {
            if photoPicker.indexAssetDict.count == 10 {
                showAlertView(withWarning: "You can only select up to 10 images at the same time")
            } else {
                if(asset.mediaType == .image){
                    if(photoPicker.videoAsset != nil){
                        showAlertView(withWarning: "You can't select photo with video")
                        return
                    }else if(photoPicker.gifAssetDict.count > 0){
                        showAlertView(withWarning: "You can't select Image with GIF")
                        return
                    }
                    
                    let resources = PHAssetResource.assetResources(for: asset)
                    let orgFilename = (resources[0]).originalFilename;
                    if orgFilename.lowercased().contains(".gif") {
                        let imageManager = PHCachingImageManager()
                        let options = PHImageRequestOptions()
                        options.resizeMode = .fast
                        imageManager.requestImageData(for: asset, options: options, resultHandler: { (imageData, dataUTI, orientation, info) in
                            if let data = imageData{
                                self.photoPicker.gifAssetDict[asset] = data
                            }
                        })
                    }
//                        else{
                        photoPicker.assetIndexDict[asset] = photoPicker.indexImageDict.count
                        photoPicker.indexAssetDict[photoPicker.indexImageDict.count] = asset
                        let count = self.photoPicker.indexImageDict.count
                        
                        let highQRequestOption = PHImageRequestOptions()
                        highQRequestOption.resizeMode = .none
                        highQRequestOption.deliveryMode = .highQualityFormat //high pixel
                        highQRequestOption.isSynchronous = true
                        PHCachingImageManager.default().requestImage(for: asset, targetSize: CGSize(width: 1500,height: 1500), contentMode: .aspectFill, options: highQRequestOption) { (result, info) in
                            self.photoPicker.indexImageDict[count] = result
                        }
//                    }
                }else{
                    if(self.photoPicker.indexImageDict.count != 0 || photoPicker.gifAssetDict.count != 0){
                        showAlertView(withWarning: "You can't select video while selecting photos")
                        return
                    }else if(self.photoPicker.videoAsset != nil){
                        showAlertView(withWarning: "You can only send one video at the same time")
                        return
                    }else if(self.photoPicker.assetDurationDict[asset] > 60){
                        showAlertView(withWarning: "Sorry, for now you can only send video below 1 minute")
                        return
                    }
                    photoPicker.assetIndexDict[asset] = photoPicker.indexImageDict.count
                    photoPicker.indexAssetDict[photoPicker.indexImageDict.count] = asset
                    let lowQRequestOption = PHVideoRequestOptions()
                    lowQRequestOption.deliveryMode = .fastFormat //high pixel
                    PHCachingImageManager.default().requestAVAsset(forVideo: asset, options: lowQRequestOption) { (asset, audioMix, info) in
                        self.photoPicker.videoAsset = asset
                    }
                    
                    let highQRequestOption = PHImageRequestOptions()
                    highQRequestOption.resizeMode = .exact
                    highQRequestOption.deliveryMode = .highQualityFormat //high pixel
                    highQRequestOption.isSynchronous = true
                    PHCachingImageManager.default().requestImage(for: asset, targetSize: CGSize(width: 210,height: 150), contentMode: .aspectFill, options: highQRequestOption) { (result, info) in
                        self.photoPicker.videoImage = result
                    }
                }
                cell.selectCell(max(photoPicker.indexImageDict.count - 1, 0))
            }
        } else {
            cell.deselectCell()
            if let deselectedIndex = photoPicker.assetIndexDict[asset]{
                photoPicker.assetIndexDict.removeValue(forKey: asset)
                photoPicker.indexAssetDict.removeValue(forKey: deselectedIndex)
                photoPicker.indexImageDict.removeValue(forKey: deselectedIndex)
                shiftChosenFrameFromIndex(deselectedIndex + 1)
            }
            
            if let _ = photoPicker.gifAssetDict[asset]{
                photoPicker.gifAssetDict.removeAll()
            }
            
            photoPicker.videoAsset = nil
            photoPicker.videoImage = nil
        }
        collectionView.deselectItem(at: indexPath, animated: true)
        updateSendButtonStatus()
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoPicker.currentAlbum.albumContent.count
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: photoPickerCellIdentifier, for: indexPath) as! PhotoPickerCollectionViewCell
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let cell = cell as! PhotoPickerCollectionViewCell
        //get image from PHFetchResult
        let asset : PHAsset = self.photoPicker.currentAlbum.albumContent[indexPath.row] as! PHAsset
        if let duration = photoPicker.assetDurationDict[asset]{
            cell.setVideoDurationLabel(withDuration: duration)
        }
        let resources = PHAssetResource.assetResources(for: asset)
        let orgFilename = (resources[0]).originalFilename;
        if orgFilename.lowercased().contains(".gif") {
            cell.setGifLabel()
        }
        
        cell.loadImage(asset, requestOption: requestOption)
        if photoPicker.assetIndexDict[asset] != nil {
            cell.selectCell(photoPicker.assetIndexDict[asset]!)
        }else{
            cell.deselectCell()
        }
    }
    //
    //    override func collectionView(collectionView: UICollectionView, didEndDisplayingCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
    //        let mycell = cell as! PhotoPickerCollectionViewCell
    //        mycell.photoImageView.image = nil
    //    }
    //
    
    //MARK: - table view delegate method
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: albumReuseIdentifiler) as! AlbumTableViewCell
        
        if let albumName = photoPicker.selectedAlbum[indexPath.row].albumName{
            cell.albumTitleLabel.text = albumName
        }
        if let albumCount = photoPicker.selectedAlbum[indexPath.row].albumCount{
            cell.albumNumberLabel.text = "\(albumCount)"
        }

        cell.checkMarkImage.isHidden = photoPicker.selectedAlbum[indexPath.row].albumName != photoPicker.currentAlbum.albumName
        
        if !cell.checkMarkImage.isHidden {
            currentCell = cell
        }
        //set thumbnail
        let asset : PHAsset = self.photoPicker.selectedAlbum[indexPath.row].albumContent[0] as! PHAsset
        
        PHCachingImageManager.default().requestImage(for: asset, targetSize: CGSize(width: view.frame.width - 1 / 10, height: view.frame.width - 1 / 10), contentMode: .aspectFill, options: nil) { (result, info) in
            cell.titleImageView.image = result
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photoPicker.selectedAlbum.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! AlbumTableViewCell
        if cell.checkMarkImage.isHidden {
            photoPicker.currentAlbum = photoPicker.selectedAlbum[indexPath.row]
            tableView.deselectRow(at: indexPath, animated: true)
            dismissAlbumTable()
            tableViewAlbumVisible = !tableViewAlbumVisible
            self.titleLabel.text = photoPicker.currentAlbum.albumName
            currentCell.checkMarkImage.isHidden = true
            let cellNew = tableView.cellForRow(at: indexPath) as! AlbumTableViewCell
            cellNew.checkMarkImage.isHidden = false
            currentCell = cellNew
            collectionView?.reloadData()
        }
        else{
            tableView.deselectRow(at: indexPath, animated: true)
            dismissAlbumTable()
            tableViewAlbumVisible = !tableViewAlbumVisible
        }
    }
}
