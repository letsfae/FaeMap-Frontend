//
//  FAEChatToolBarContentView.swift
//  faeBeta
//
//  Created by YAYUAN SHI on 10/25/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
import Photos

@objc protocol FAEChatToolBarContentViewDelegate {
    func moveUpInputBar()
    func showAlertView()
    func sendAudioData(data:NSData)
    func sendStickerWithImageName(name : String)
    func sendImages(images:[UIImage])
    func getMoreImage()
    
    optional func scrollToBottom(animated: Bool)
    optional func endEdit()
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
    
    private var frameImageName = ["photoQuickSelection1", "photoQuickSelection2", "photoQuickSelection3", "photoQuickSelection4","photoQuickSelection5", "photoQuickSelection6", "photoQuickSelection7", "photoQuickSelection8", "photoQuickSelection9", "photoQuickSelection10"]// show at most 10 images

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
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
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
            layout.minimumLineSpacing = 1000.0
            layout.itemSize = CGSizeMake(220, 271)
            photoQuickCollectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height), collectionViewLayout: layout)
            photoQuickCollectionView.registerNib(UINib(nibName: "PhotoPickerCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: photoQuickCollectionReuseIdentifier)
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
            self.photoQuickCollectionView?.scrollToItemAtIndexPath(indexPath, atScrollPosition: UICollectionViewScrollPosition.Left, animated: false)
            
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
    }
    
    // MARK: - helper
    func reloadPhotoAlbum()
    {
        photoPicker.getSmartAlbum()
        self.photoQuickCollectionView.reloadData()
    }
    
    func cleanUpSelectedPhotos(){
        photoPicker.indexAssetDict.removeAll()
        photoPicker.assetIndexDict.removeAll()
        photoPicker.indexImageDict.removeAll()
        self.photoQuickCollectionView.reloadData()
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
                cell.loadImage(asset, requestOption: requestOption)
                
                if photoPicker.assetIndexDict[asset] != nil {
                    cell.chosenFrameImageView.hidden = false
                    cell.chosenFrameImageView.image = UIImage(named: self.frameImageName[photoPicker.assetIndexDict[asset]!])
                }else{
                    cell.chosenFrameImageView.hidden = true
                }
            }
        }
    }
    
    //photoes preview delegate
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if collectionView == photoQuickCollectionView && self.photoPicker.cameraRoll != nil {
            let cell = collectionView.cellForItemAtIndexPath(indexPath) as! PhotoPickerCollectionViewCell
            let asset : PHAsset = self.photoPicker.cameraRoll.albumContent[indexPath.section] as! PHAsset
            
            if cell.chosenFrameImageView.hidden {
                if photoPicker.indexAssetDict.count == 10 {
                    self.delegate.showAlertView()
                } else {
                    photoPicker.assetIndexDict[asset] = photoPicker.indexImageDict.count
                    photoPicker.indexAssetDict[photoPicker.indexImageDict.count] = asset
                    let count = self.photoPicker.indexImageDict.count
                    let highQRequestOption = PHImageRequestOptions()
                    highQRequestOption.resizeMode = .None
                    requestOption.deliveryMode = .HighQualityFormat //high pixel
                    requestOption.synchronous = true
                    PHCachingImageManager.defaultManager().requestImageForAsset(asset, targetSize: CGSizeMake(1500,1500), contentMode: .AspectFill, options: highQRequestOption) { (result, info) in
                        self.photoPicker.indexImageDict[count] = result
                    }
                    cell.chosenFrameImageView.image = UIImage(named: frameImageName[photoPicker.indexImageDict.count - 1])
                    cell.chosenFrameImageView.hidden = false
                    self.photoQuickCollectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: .Left, animated: true)
                }
            } else {
                cell.chosenFrameImageView.hidden = true
                let deselectedIndex = photoPicker.assetIndexDict[asset]
                photoPicker.assetIndexDict.removeValueForKey(asset)
                photoPicker.indexAssetDict.removeValueForKey(deselectedIndex!)
                photoPicker.indexImageDict.removeValueForKey(deselectedIndex!)
                shiftChosenFrameFromIndex(deselectedIndex! + 1)
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
        self.delegate.sendAudioData(data)
        
    }
    
    // MARK : - Sticker delegate
    func sendStickerWithImageName(name : String)
    {
        self.delegate.sendStickerWithImageName(name)
        self.stickerPicker.updateStickerHistory(name)
    }
    
    func sendImageFromQuickPicker()
    {
        var images = [UIImage]()
        for i in 0..<photoPicker.indexImageDict.count
        {
            images.append(photoPicker.indexImageDict[i]!)
        }
        
        self.delegate.sendImages(images)
    }
}
