//
//  CustomCollectionViewController.swift
//  quickChat
//
//  Created by User on 7/12/16.
//  Copyright © 2016 User. All rights reserved.
//

import UIKit

import Photos

// delegate to send mutiple image in ChatVC

@objc protocol SendMutipleImagesDelegate {
    
    func sendImages(images:[UIImage])
    optional func sendVideoData(video: NSData, snapImage: UIImage, duration: Int)
}

// this view controller is used to show image from one album, it has a table view for you to switch albums

class CustomCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UITableViewDelegate, UITableViewDataSource {
    
    var photoPicker : PhotoPicker!
    
    let photoPickerCellIdentifier = "FullPhotoPickerCollectionViewCell"
    
    let layOut = UICollectionViewFlowLayout()
    
    let screenWidth = UIScreen.mainScreen().bounds.width
    let screenHeight = UIScreen.mainScreen().bounds.height
    
    var quitButton : UIButton!
    var showTableButton : UIButton!
    
    var titleLabel : UILabel!
    
    let requestOption = PHImageRequestOptions()
    
    var currentCell : AlbumTableViewCell!
    
    // table view variable
    
    var tableViewAlbum : UITableView!
    let albumReuseIdentifiler = "AlbumTableViewCell"
    var tableViewAlbumVisible = false

    //send image delegate
    
    var imageDelegate : SendMutipleImagesDelegate!
    
    var frameImageName = ["photoSelection1", "photoSelection2", "photoSelection3", "photoSelection4","photoSelection5", "photoSelection6", "photoSelection7", "photoSelection8", "photoSelection9", "photoSelection10"]
    
    
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        photoPicker = PhotoPicker.shared
        collectionView?.backgroundColor = UIColor.whiteColor()
        collectionView?.registerNib(UINib(nibName: "FullPhotoPickerCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: photoPickerCellIdentifier)
        requestOption.synchronous = false
        requestOption.resizeMode = .Fast
        requestOption.deliveryMode = .HighQualityFormat
        self.collectionView?.decelerationRate = UIScrollViewDecelerationRateNormal
        navigationBarSet()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.appWillEnterForeground), name:"appWillEnterForeground", object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        //fetch photo from collection
        self.navigationController?.hidesBarsOnTap = false
        self.collectionView?.reloadData()
        prepareTableView()
    }
    
    func prepareTableView() {
        tableViewAlbum = UITableView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 480))
        tableViewAlbum.registerNib(UINib(nibName: "AlbumTableViewCell", bundle: nil), forCellReuseIdentifier: albumReuseIdentifiler)
        tableViewAlbum.delegate = self
        tableViewAlbum.dataSource = self
    }
    
    func getUserAlbumSet() {
        let userAlbumsOptions = PHFetchOptions()
        userAlbumsOptions.predicate = NSPredicate(format: "estimatedAssetCount > 0")
        
        let userAlbums = PHAssetCollection.fetchAssetCollectionsWithType(PHAssetCollectionType.Album, subtype: PHAssetCollectionSubtype.Any, options: userAlbumsOptions)
        
        userAlbums.enumerateObjectsUsingBlock( {
            if let collection = $0.0 as? PHAssetCollection {
                print("album title: \(collection.localizedTitle)")
                //For each PHAssetCollection that is returned from userAlbums: PHFetchResult you can fetch PHAssets like so (you can even limit results to include only photo assets):
                let onlyImagesOptions = PHFetchOptions()
                onlyImagesOptions.predicate = NSPredicate(format: "mediaType = %i", PHAssetMediaType.Image.rawValue)
                if let result = PHAsset.fetchKeyAssetsInAssetCollection(collection, options: nil) {
                    print("Images count: \(result.count)")
                }
            }
        } )
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: collectionViewController Delegate
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! PhotoPickerCollectionViewCell
        let asset : PHAsset = self.photoPicker.cameraRoll.albumContent[indexPath.row] as! PHAsset
        
        if !cell.photoSelected {
            if photoPicker.indexAssetDict.count == 10 {
                showAlertView(withWarning: "You can only select up to 10 images at the same time")
            } else {
                if(asset.mediaType == .Image){
                    if(photoPicker.videoAsset != nil){
                        showAlertView(withWarning: "You can't select photo with video")
                        return
                    }
                    photoPicker.assetIndexDict[asset] = photoPicker.indexImageDict.count
                    photoPicker.indexAssetDict[photoPicker.indexImageDict.count] = asset
                    let count = self.photoPicker.indexImageDict.count
                    
                    let highQRequestOption = PHImageRequestOptions()
                    highQRequestOption.resizeMode = .None
                    highQRequestOption.deliveryMode = .HighQualityFormat //high pixel
                    highQRequestOption.synchronous = true
                    PHCachingImageManager.defaultManager().requestImageForAsset(asset, targetSize: CGSizeMake(1500,1500), contentMode: .AspectFill, options: highQRequestOption) { (result, info) in
                        self.photoPicker.indexImageDict[count] = result
                    }
                }else{
                    if(self.photoPicker.indexImageDict.count != 0){
                        showAlertView(withWarning: "You can't select video while selecting photos")
                        return
                    }else if(self.photoPicker.videoAsset != nil){
                        showAlertView(withWarning: "You can only send one video at the same time")
                        return
                    }
                    photoPicker.assetIndexDict[asset] = photoPicker.indexImageDict.count
                    photoPicker.indexAssetDict[photoPicker.indexImageDict.count] = asset
                    let lowQRequestOption = PHVideoRequestOptions()
                    lowQRequestOption.deliveryMode = .FastFormat //high pixel
                    PHCachingImageManager.defaultManager().requestAVAssetForVideo(asset, options: lowQRequestOption) { (asset, audioMix, info) in
                        self.photoPicker.videoAsset = asset
                    }
                    
                    let highQRequestOption = PHImageRequestOptions()
                    highQRequestOption.resizeMode = .Exact
                    highQRequestOption.deliveryMode = .HighQualityFormat //high pixel
                    highQRequestOption.synchronous = true
                    PHCachingImageManager.defaultManager().requestImageForAsset(asset, targetSize: CGSizeMake(210,150), contentMode: .AspectFill, options: highQRequestOption) { (result, info) in
                        self.photoPicker.videoImage = result
                    }
                }
                cell.selectCell(max(photoPicker.indexImageDict.count - 1, 0))
            }
        } else {
            cell.deselectCell()
            if let deselectedIndex = photoPicker.assetIndexDict[asset]{
                photoPicker.assetIndexDict.removeValueForKey(asset)
                photoPicker.indexAssetDict.removeValueForKey(deselectedIndex)
                photoPicker.indexImageDict.removeValueForKey(deselectedIndex)
                shiftChosenFrameFromIndex(deselectedIndex + 1)
            }
            photoPicker.videoAsset = nil
            photoPicker.videoImage = nil
        }
        //            print("imageDict has \(imageDict.count) images")
        collectionView.deselectItemAtIndexPath(indexPath, animated: true)
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoPicker.currentAlbum.albumContent.count
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 1.5
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(view.frame.width / 3 - 1, view.frame.width / 3 - 1)
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(photoPickerCellIdentifier, forIndexPath: indexPath) as! PhotoPickerCollectionViewCell
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        let cell = cell as! PhotoPickerCollectionViewCell
        //get image from PHFetchResult
        let asset : PHAsset = self.photoPicker.currentAlbum.albumContent[indexPath.row] as! PHAsset
        if let duration = photoPicker.assetDurationDict[asset]{
            cell.setVideoDurationLabel(withDuration: duration)
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
    
    //MARK: support method
    
    func navigationBarSet() {
        let centerView = UIView(frame: CGRect(x: 0,y: 0,width: 200,height: 30))
        showTableButton = UIButton(frame: CGRect(x: 0, y: 0, width: 200, height: 30))
        showTableButton.titleLabel?.text = ""
        showTableButton.addTarget(self, action: #selector(CustomCollectionViewController.showAlbumTable), forControlEvents: .TouchUpInside)
        
        self.navigationController?.navigationBar.tintColor = UIColor.faeAppRedColor()
        self.navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.translucent = false
        
        titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 25))
        titleLabel.text = "All Photos"
        titleLabel.textAlignment = .Center
        titleLabel.font = UIFont(name: "AvenirNext-Medium", size: 20)
        titleLabel.textColor = UIColor(red: 89 / 255, green: 89 / 255, blue: 89 / 255, alpha: 1.0)
        centerView.addSubview(titleLabel)
        
        
        let arrow = UIImageView(frame: CGRect(x: 97, y: 25, width: 10, height: 6))
        arrow.image = UIImage(named: "arrow")
        centerView.addSubview(arrow)
        centerView.addSubview(showTableButton)
        self.navigationItem.titleView = centerView
        
        self.navigationItem.rightBarButtonItems = [UIBarButtonItem.init(title: "Send", style: .Plain, target: self, action: #selector(CustomCollectionViewController.sendImages))]
        
        self.navigationItem.leftBarButtonItems = [UIBarButtonItem.init(title: "Cancel", style: .Plain, target: self, action: #selector(CustomCollectionViewController.cancelSend))]
        
    }
    
    func showAlbumTable() {
        if !tableViewAlbumVisible {
            quitButton = UIButton(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
            quitButton.backgroundColor = UIColor(red: 58 / 255, green: 51 / 255, blue: 51 / 255, alpha: 0.5)
            self.view.addSubview(quitButton)
            quitButton.addTarget(self, action: #selector(CustomCollectionViewController.dismissAlbumTable), forControlEvents: .TouchUpInside)
            self.view.addSubview(tableViewAlbum)
            tableViewAlbum.setContentOffset(CGPointZero, animated: true)
        } else {
            dismissAlbumTable()
        }
        tableViewAlbumVisible = !tableViewAlbumVisible
    }
    
    func sendImages() {
        showProcessIndicator()
        if(photoPicker.videoAsset != nil){
            sendVideoFromQuickPicker()
        }else{
            var images = [UIImage]()
            for i in 0..<photoPicker.indexImageDict.count
            {
                images.append( photoPicker.indexImageDict[i]! )
            }
            imageDelegate.sendImages(images)
        }
        hideProcessIndicator()
        cancelSend()
    }
    
    private func sendVideoFromQuickPicker()
    {
        
        let snapImage = self.photoPicker.videoImage!
        let duration = photoPicker.assetDurationDict[photoPicker.indexAssetDict[0]!] ?? 0
        // asset is you AVAsset object
        let exportSession = AVAssetExportSession(asset:photoPicker.videoAsset!, presetName: AVAssetExportPresetMediumQuality)
        let filePath = NSTemporaryDirectory().stringByAppendingFormat("/video.mov")
        do{
            try NSFileManager.defaultManager().removeItemAtPath(filePath)
        }catch{
            
        }
        exportSession!.outputURL = NSURL(fileURLWithPath: filePath) // Better to use initFileURLWithPath:isDirectory: if you know if the path is a directory vs non-directory, as it saves an i/o.
        
        let fileUrl = exportSession!.outputURL
        // e.g .mov type
        exportSession!.outputFileType = AVFileTypeQuickTimeMovie
        
        exportSession!.exportAsynchronouslyWithCompletionHandler{
            Void in
            switch exportSession!.status {
            case  AVAssetExportSessionStatus.Failed:
                print("failed import video: \(exportSession!.error)")
            case AVAssetExportSessionStatus.Cancelled:
                print("cancelled import video: \(exportSession!.error)")
            default:
                print("completed import video")
                if let data = NSData(contentsOfURL:fileUrl!){
                    self.imageDelegate.sendVideoData?(data, snapImage: snapImage, duration: duration)
                }
            }
        }
    }
    
    func cancelSend() {
        photoPicker.indexAssetDict.removeAll()
        photoPicker.assetIndexDict.removeAll()
        photoPicker.indexImageDict.removeAll()

        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func dismissAlbumTable() {
        quitButton.removeFromSuperview()
        tableViewAlbum.removeFromSuperview()
    }
    
    func showAlertView(withWarning text:String) {
        let alert = UIAlertController(title: text, message: "", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func showProcessIndicator() {
        activityIndicator.center = self.view.center
        activityIndicator.startAnimating()
        activityIndicator.layer.zPosition = 10
        self.view.userInteractionEnabled = false
        self.view.addSubview(activityIndicator)
    }
    
    func hideProcessIndicator() {
        activityIndicator.stopAnimating()
        activityIndicator.removeFromSuperview()
        self.view.userInteractionEnabled = true
    }
    
    func shiftChosenFrameFromIndex(index : Int) {
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
        photoPicker.indexAssetDict.removeValueForKey(photoPicker.indexImageDict.count - 1)
        photoPicker.indexImageDict.removeValueForKey(photoPicker.indexImageDict.count - 1)
        self.collectionView?.performBatchUpdates({
            self.collectionView?.reloadSections(NSIndexSet(index: 0) )
            }, completion: nil)

    }
    
    func appWillEnterForeground(){
        photoPicker.getSmartAlbum()
        self.collectionView?.reloadData()
        self.tableViewAlbum.reloadData()

    }
    
    //MARK: table view delegate method
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(albumReuseIdentifiler) as! AlbumTableViewCell
        cell.albumTitleLabel.text = photoPicker.selectedAlbum[indexPath.row].albumName
        cell.albumNumberLabel.text = "\(photoPicker.selectedAlbum[indexPath.row].albumCount)"
        cell.checkMarkImage.hidden = photoPicker.selectedAlbum[indexPath.row].albumName != photoPicker.currentAlbum.albumName
        
        if !cell.checkMarkImage.hidden {
            currentCell = cell
        }
        //set thumbnail
        let asset : PHAsset = self.photoPicker.selectedAlbum[indexPath.row].albumContent[0] as! PHAsset
        
        PHCachingImageManager.defaultManager().requestImageForAsset(asset, targetSize: CGSizeMake(view.frame.width - 1 / 10, view.frame.width - 1 / 10), contentMode: .AspectFill, options: nil) { (result, info) in
            cell.titleImageView.image = result!
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photoPicker.selectedAlbum.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! AlbumTableViewCell
        if cell.checkMarkImage.hidden {
            photoPicker.currentAlbum = photoPicker.selectedAlbum[indexPath.row]
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            dismissAlbumTable()
            tableViewAlbumVisible = !tableViewAlbumVisible
            self.titleLabel.text = photoPicker.currentAlbum.albumName
            currentCell.checkMarkImage.hidden = true
            let cellNew = tableView.cellForRowAtIndexPath(indexPath) as! AlbumTableViewCell
            cellNew.checkMarkImage.hidden = false
            currentCell = cellNew
            collectionView?.reloadData()
        }
        else{
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            dismissAlbumTable()
            tableViewAlbumVisible = !tableViewAlbumVisible
        }
    }
}

extension UIImage {
    var uncompressedPNGData: NSData      { return UIImagePNGRepresentation(self)!        }
    var highestQualityJPEGNSData: NSData { return UIImageJPEGRepresentation(self, 1.0)!  }
    var highQualityJPEGNSData: NSData    { return UIImageJPEGRepresentation(self, 0.75)! }
    var mediumQualityJPEGNSData: NSData  { return UIImageJPEGRepresentation(self, 0.5)!  }
    var lowQualityJPEGNSData: NSData     { return UIImageJPEGRepresentation(self, 0.25)! }
    var lowestQualityJPEGNSData:NSData   { return UIImageJPEGRepresentation(self, 0.0)!  }
}
