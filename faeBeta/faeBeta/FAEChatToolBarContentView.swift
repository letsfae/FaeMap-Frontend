//
//  FAEChatToolBarContentView.swift
//  faeBeta
//
//  Created by YAYUAN SHI on 10/25/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
import Photos


/// Delegate to react the action from toolbar contentView
@objc protocol FAEChatToolBarContentViewDelegate {
    
    // move up the input bar
    func moveUpInputBar()
    
    // Show the alert to warn user only 10 images can be selected
    func showAlertView(withWarning text: String)
    
    /// send the sticker image with specific name
    ///
    /// - parameter name: the name of the sticker
    func sendStickerWithImageName(name : String)
    
    
    /// send multiple images from quick image picker
    ///
    /// - parameter images: an array of selected images
    func sendImages(images:[UIImage])
    
    // present the complete photo album
    // should present CustomCollectionViewController
    func getMoreImage()
    
    /// need to implement this method if sending audio is needed
    ///
    /// - parameter data: the audio data to send
    optional func sendAudioData(data:NSData)
    
    // end any editing. Especially the input toolbar textView.
    optional func endEdit()
    
    optional func sendVideoData(video: NSData, snapImage: UIImage, duration: Int)
}

class FAEChatToolBarContentView: UIView, UICollectionViewDelegate,UICollectionViewDataSource, AudioRecorderViewDelegate, SendStickerDelegate{
    
    //MARK: - Properties
    var keyboardShow = false // false: keyboard is hide
    var mediaContentShow : Bool{
        get{
            return imageQuickPickerShow || stickerViewShow || recordShow
        }
    }
    // Photos
    private var photoPicker : PhotoPicker!
    private var photoQuickCollectionView : UICollectionView!//preview of the photoes
    private let photoQuickCollectionReuseIdentifier = "photoQuickCollectionReuseIdentifier"

    private let requestOption = PHImageRequestOptions()
    private var imageQuickPickerShow = false //false : not open the photo preview
    
    private var quickSendImageButton : UIButton!//right
    private var moreImageButton : UIButton!//left
    
    //sticker
    private var stickerViewShow = false//false : not open the stick view
    private var stickerPicker : StickerPickView!
    
    //record
    private var recordShow = false
    private var audioRecorderContentView: AudioRecorderView!
    
    weak var delegate : FAEChatToolBarContentViewDelegate!
    
    
    //MARK: - init & setup
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    
    /// setup UI and funcs
    private func setup()
    {
        // sticker view
        func initializeStickerView() {
            stickerPicker = StickerPickView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height))
            stickerPicker.sendStickerDelegate = self
            self.addSubview(stickerPicker)
            stickerPicker.hidden = true
        }
        
        //quick image picker
        
        func initializePhotoQuickPicker() {
            //photoes preview
            let layout = UICollectionViewFlowLayout()
            //        layout.itemSize = CGSizeMake(220, 235)
            layout.scrollDirection = .Horizontal
            layout.itemSize = CGSizeMake(220, 271)
            layout.sectionInset = UIEdgeInsetsMake(0, 1, 0, 1)
            photoQuickCollectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height), collectionViewLayout: layout)
            photoQuickCollectionView.registerNib(UINib(nibName: "QuickPhotoPickerCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: photoQuickCollectionReuseIdentifier)
            photoQuickCollectionView.backgroundColor = UIColor.whiteColor()
            photoQuickCollectionView.delegate = self
            photoQuickCollectionView.dataSource = self
            quickSendImageButton = UIButton(frame: CGRect(x: 10, y: self.frame.height - 52, width: 42, height: 42))
            quickSendImageButton.setImage(UIImage(named: "moreImage"), forState: .Normal)
            quickSendImageButton.addTarget(self, action: #selector(self.showFullAlbum), forControlEvents: .TouchUpInside)
            moreImageButton = UIButton(frame: CGRect(x: self.frame.width - 52, y: self.frame.height - 52, width: 42, height: 42))
            moreImageButton.addTarget(self, action: #selector(self.sendImageFromQuickPicker), forControlEvents: .TouchUpInside)
            moreImageButton.setImage(UIImage(named: "imageQuickSend"), forState: .Normal)
            
            photoPicker = PhotoPicker.shared
            
            self.addSubview(photoQuickCollectionView)
            self.addSubview(quickSendImageButton)
            self.addSubview(moreImageButton)

            photoQuickCollectionView.hidden = true
            quickSendImageButton.hidden = true
            moreImageButton.hidden = true

        }
        
        //MARK: voice helper function
        
        func setupRecorder() {
            self.audioRecorderContentView = NSBundle.mainBundle().loadNibNamed("AudioRecorderView", owner: self, options: nil)![0] as! AudioRecorderView
            self.audioRecorderContentView.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
            self.audioRecorderContentView.delegate = self
            self.addSubview(audioRecorderContentView)
            
            audioRecorderContentView.hidden = true
        }
        
        self.backgroundColor = UIColor.whiteColor()
        initializeStickerView()
        initializePhotoQuickPicker()
        setupRecorder()
    }
    
    // MARK: - show different content
    func showKeyboard()
    {
        self.hidden = true
        if stickerViewShow {
            stickerPicker.hidden = true
            stickerViewShow = false
        }
        if imageQuickPickerShow {
            photoQuickCollectionView.hidden = true
            moreImageButton.hidden = true
            quickSendImageButton.hidden = true
            imageQuickPickerShow = false
        }
        if recordShow {
            audioRecorderContentView.hidden = true
            recordShow = false
        }
    }
    
    
    func showStikcer()
    {
        self.hidden = false
        //show stick view, and dismiss all other views, like keyboard and photoes preview
        if !stickerViewShow {
            self.stickerPicker.hidden = false
 
            if self.imageQuickPickerShow {
                self.photoQuickCollectionView.hidden = true
                self.moreImageButton.hidden = true
                self.quickSendImageButton.hidden = true
                self.imageQuickPickerShow = false
            }
            else if (recordShow){
                self.audioRecorderContentView.hidden = true
                self.recordShow = false
            }
            else if (keyboardShow){
                UIView.setAnimationsEnabled(false)
                self.delegate.endEdit?()
                UIView.setAnimationsEnabled(true)
            }
            self.stickerViewShow = true
        }
    }
    
    func showLibrary()
    {
        self.hidden = false
        if !imageQuickPickerShow {
            self.photoQuickCollectionView?.reloadData()
            let indexPath = NSIndexPath(forRow: 0, inSection: 0)
            if(photoPicker.currentAlbum != nil){
                self.photoQuickCollectionView?.scrollToItemAtIndexPath(indexPath, atScrollPosition: UICollectionViewScrollPosition.Left, animated: false)
            }
            photoQuickCollectionView.hidden = false
            quickSendImageButton.hidden = false
            moreImageButton.hidden = false
            
            quickSendImageButton.alpha = 0
            moreImageButton.alpha = 0
            
            if stickerViewShow {
                stickerPicker.hidden = true
                stickerViewShow = false
                self.quickSendImageButton.alpha = 1
                self.moreImageButton.alpha = 1
            }
            else if recordShow {
                self.audioRecorderContentView.hidden = true
                self.recordShow = false
                self.quickSendImageButton.alpha = 1
                self.moreImageButton.alpha = 1
            }
            else if (keyboardShow){
                UIView.setAnimationsEnabled(false)
                self.delegate.endEdit?()
                UIView.setAnimationsEnabled(true)
                self.quickSendImageButton.alpha = 1
                self.moreImageButton.alpha = 1
            }else{
                UIView.animateWithDuration(0.3, animations: {
                    self.quickSendImageButton.alpha = 1
                    self.moreImageButton.alpha = 1
                    }, completion:{ (Bool) -> Void in
                })
            }
            imageQuickPickerShow = true
        }
    }
    
    func showFullAlbum()
    {
        self.delegate.getMoreImage()
    }
    
    func showRecord() {
        self.hidden = false

        if !recordShow {
            self.audioRecorderContentView.requireForPermission(nil)
            self.audioRecorderContentView.hidden = false
            
            if stickerViewShow {
                stickerPicker.hidden = true
                stickerViewShow = false
            }else if imageQuickPickerShow{
                self.photoQuickCollectionView.hidden = true
                self.moreImageButton.hidden = true
                self.quickSendImageButton.hidden = true
                self.imageQuickPickerShow = false
            }else if keyboardShow {
                UIView.setAnimationsEnabled(false)
                self.delegate.endEdit?()
                UIView.setAnimationsEnabled(true)
            }
            recordShow = true
        }
    }

    /// close all content
    func closeAll()
    {
        stickerPicker.hidden = true
        stickerViewShow = false
        
        photoQuickCollectionView.hidden = true
        moreImageButton.hidden = true
        quickSendImageButton.hidden = true
        imageQuickPickerShow = false
        
        audioRecorderContentView.hidden = true
        recordShow = false
        audioRecorderContentView.switchToRecordMode()
    }
    
    // MARK: - helper
    
    // reload the photo album, called after take new photos
    func reloadPhotoAlbum()
    {
        photoPicker.getSmartAlbum()
        self.photoQuickCollectionView.reloadData()
    }
    
    // remove all selected photos, clean up the select frames
    func cleanUpSelectedPhotos(){
        photoPicker.videoAsset = nil
        photoPicker.videoImage = nil
        photoPicker.indexAssetDict.removeAll()
        photoPicker.assetIndexDict.removeAll()
        photoPicker.indexImageDict.removeAll()
        dispatch_async(dispatch_get_main_queue(), {
            self.photoQuickCollectionView.reloadData()
        });
    }

    private func shiftChosenFrameFromIndex(index : Int)
    {
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
        self.photoQuickCollectionView.reloadData()
    }
    
    //MARK: - photoPicker Collection View Delegate
    //photoes preview layout
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 10
    }
//    
//    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> CGFloat {
//        return 3
//    }
//    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(photoQuickCollectionReuseIdentifier, forIndexPath: indexPath) as! PhotoPickerCollectionViewCell
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        if collectionView == self.photoQuickCollectionView {
            let cell = cell as! PhotoPickerCollectionViewCell
            //get image from PHFetchResult
            if(self.photoPicker.cameraRoll != nil){
                let asset : PHAsset = self.photoPicker.cameraRoll.albumContent[indexPath.section] as! PHAsset
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
        }
    }
    
    //photoes preview delegate
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if collectionView == photoQuickCollectionView && self.photoPicker.cameraRoll != nil {
            let cell = collectionView.cellForItemAtIndexPath(indexPath) as! PhotoPickerCollectionViewCell
            let asset : PHAsset = self.photoPicker.cameraRoll.albumContent[indexPath.section] as! PHAsset
            
            if !cell.photoSelected {
                if photoPicker.indexAssetDict.count == 10 {
                    self.delegate.showAlertView(withWarning: "You can only select up to 10 images at the same time")
                } else {

                    
                    if(asset.mediaType == .Image){
                        if(photoPicker.videoAsset != nil){
                            self.delegate.showAlertView(withWarning: "You can't select photo with video")
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
                            self.delegate.showAlertView(withWarning: "You can't select video while selecting photos")
                            return
                        }else if(self.photoPicker.videoAsset != nil){
                            self.delegate.showAlertView(withWarning: "You can only send one video at one time")
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
                    self.photoQuickCollectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: .Left, animated: true)
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
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        if(photoPicker.cameraRoll == nil){
            photoPicker.getSmartAlbum()
        }
        if collectionView == photoQuickCollectionView && photoPicker.cameraRoll != nil{
            return photoPicker.cameraRoll.albumCount
        }
        return 0
    }
    
    
    //MARK: - AudioRecorderViewDelegate

    func audioRecorderView(audioView: AudioRecorderView, needToSendAudioData data: NSData){
        self.delegate.sendAudioData?(data)
        
    }
    
    // MARK: - Sticker delegate
    func sendStickerWithImageName(name : String)
    {
        self.delegate.sendStickerWithImageName(name)
        self.stickerPicker.updateStickerHistory(name)
    }
    
    // MARK: - Quick image picker delegate
    func sendImageFromQuickPicker()
    {
        if(photoPicker.videoAsset != nil){
            sendVideoFromQuickPicker()
            return
        }
        var images = [UIImage]()

        for i in 0..<photoPicker.indexImageDict.count
        {
            images.append(photoPicker.indexImageDict[i]!)
        }
        self.delegate.sendImages(images)
    }
    
    private func sendVideoFromQuickPicker()
    {
        UIScreenService.showActivityIndicator()

        let image = self.photoPicker.videoImage!
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
                break
            case AVAssetExportSessionStatus.Cancelled:
                print("cancelled import video: \(exportSession!.error)")
                break
            default:
                print("completed import video")
                if let data = NSData(contentsOfURL:fileUrl!){
                    self.delegate.sendVideoData?(data, snapImage:image ,duration:duration)
                }
            }
            UIScreenService.hideActivityIndicator()
        }
    }
    
    func documentsPathForFileName(name: String) -> String {
        
        let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        return documentsPath.stringByAppendingString(name)
    }
}
