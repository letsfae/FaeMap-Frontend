//
//  FAEChatToolBarContentView.swift
//  faeBeta
//
//  Created by YAYUAN SHI on 10/25/16.
//  Copyright © 2016 fae. All rights reserved.
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



/// Delegate to react the action from toolbar contentView
@objc protocol FAEChatToolBarContentViewDelegate {
    
    // move up the input bar
    func moveUpInputBar()
    
    // Show the alert to warn user only 10 images can be selected
    func showAlertView(withWarning text: String)
    
    /// send the sticker image with specific name
    ///
    /// - parameter name: the name of the sticker
    func sendStickerWithImageName(_ name : String)
    
    
    /// send multiple images from quick image picker
    ///
    /// - parameter images: an array of selected images
    func sendImages(_ images:[UIImage])
    
    // present the complete photo album
    // should present CustomCollectionViewController
    func showFullAlbum()
    
    /// need to implement this method if sending audio is needed
    ///
    /// - parameter data: the audio data to send
    @objc optional func sendAudioData(_ data:Data)
    
    // end any editing. Especially the input toolbar textView.
    @objc optional func endEdit()
    
    @objc optional func sendVideoData(_ video: Data, snapImage: UIImage, duration: Int)
}



/// This view contains all the stuff below a input toolbar, supporting stickers, photo, video, auido
class FAEChatToolBarContentView: UIView, UICollectionViewDelegate,UICollectionViewDataSource, AudioRecorderViewDelegate, SendStickerDelegate{

    //MARK: - Properties
    var keyboardShow = false // false: keyboard is hide
    
    // Whether the media content view is show
    var mediaContentShow : Bool{
        get{
            return imageQuickPickerShow || stickerViewShow || recordShow
        }
    }
    
    // Photos
    fileprivate var photoPicker : PhotoPicker!
    fileprivate var photoQuickCollectionView : UICollectionView!//preview of the photoes
    fileprivate let photoQuickCollectionReuseIdentifier = "photoQuickCollectionReuseIdentifier"

    fileprivate let requestOption = PHImageRequestOptions()
    fileprivate var imageQuickPickerShow = false //false : not open the photo preview
    
    fileprivate var quickSendImageButton : UIButton!//right
    fileprivate var moreImageButton : UIButton!//left
    
    //sticker
    fileprivate var stickerViewShow = false//false : not open the stick view
    fileprivate var stickerPicker : StickerPickView!
    
    //record
    fileprivate var recordShow = false // false: not open the record view
    fileprivate var audioRecorderContentView: AudioRecorderView!
    
    weak var delegate : FAEChatToolBarContentViewDelegate!
    
    weak var inputToolbar: JSQMessagesInputToolbarCustom!// IMPORTANT: need to set toolbar to use the whole function
    
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
    fileprivate func setup()
    {
        // sticker view
        func initializeStickerView() {
            stickerPicker = StickerPickView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height))
            stickerPicker.sendStickerDelegate = self
            self.addSubview(stickerPicker)
            stickerPicker.isHidden = true
        }
        
        //quick image picker
        
        func initializePhotoQuickPicker() {
            //photoes preview
            let layout = UICollectionViewFlowLayout()
            //        layout.itemSize = CGSizeMake(220, 235)
            layout.scrollDirection = .horizontal
            layout.itemSize = CGSize(width: 220, height: 271)
            layout.sectionInset = UIEdgeInsetsMake(0, 1, 0, 1)
            photoQuickCollectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height), collectionViewLayout: layout)
            photoQuickCollectionView.register(UINib(nibName: "QuickPhotoPickerCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: photoQuickCollectionReuseIdentifier)
            photoQuickCollectionView.backgroundColor = UIColor.white
            photoQuickCollectionView.delegate = self
            photoQuickCollectionView.dataSource = self
            moreImageButton = UIButton(frame: CGRect(x: 10, y: self.frame.height - 52, width: 42, height: 42))
            moreImageButton.setImage(UIImage(named: "moreImage"), for: UIControlState())
            moreImageButton.addTarget(self, action: #selector(self.showFullAlbum), for: .touchUpInside)
            quickSendImageButton = UIButton(frame: CGRect(x: self.frame.width - 52, y: self.frame.height - 52, width: 42, height: 42))
            quickSendImageButton.addTarget(self, action: #selector(self.sendImageFromQuickPicker), for: .touchUpInside)
            quickSendImageButton.setImage(UIImage(named: "imageQuickSend"), for: UIControlState())
            quickSendImageButton.setImage(UIImage(named: "imageQuickSend_disabled"), for: .disabled)
            photoPicker = PhotoPicker.shared
            
            self.addSubview(photoQuickCollectionView)
            self.addSubview(quickSendImageButton)
            self.addSubview(moreImageButton)

            photoQuickCollectionView.isHidden = true
            quickSendImageButton.isHidden = true
            moreImageButton.isHidden = true

            updateSendButtonStatus()
        }
        
        //MARK: voice helper function
        
        func setupRecorder() {
            self.audioRecorderContentView = Bundle.main.loadNibNamed("AudioRecorderView", owner: self, options: nil)![0] as! AudioRecorderView
            self.audioRecorderContentView.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
            self.audioRecorderContentView.delegate = self
            self.addSubview(audioRecorderContentView)
            
            audioRecorderContentView.isHidden = true
        }
        
        self.backgroundColor = UIColor.white
        initializeStickerView()
        initializePhotoQuickPicker()
        setupRecorder()
    }
    
    // MARK: - show different content
    func showKeyboard()
    {
        self.isHidden = true
        if stickerViewShow {
            stickerPicker.isHidden = true
            stickerViewShow = false
        }
        if imageQuickPickerShow {
            photoQuickCollectionView.isHidden = true
            moreImageButton.isHidden = true
            quickSendImageButton.isHidden = true
            imageQuickPickerShow = false
        }
        if recordShow {
            audioRecorderContentView.isHidden = true
            recordShow = false
        }
    }
    
    
    func showStikcer()
    {
        self.isHidden = false
        //show stick view, and dismiss all other views, like keyboard and photoes preview
        if !stickerViewShow {
            self.stickerPicker.isHidden = false
 
            if self.imageQuickPickerShow {
                self.photoQuickCollectionView.isHidden = true
                self.moreImageButton.isHidden = true
                self.quickSendImageButton.isHidden = true
                self.imageQuickPickerShow = false
            }
            else if (recordShow){
                self.audioRecorderContentView.isHidden = true
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
        self.isHidden = false
        if !imageQuickPickerShow {
            self.photoQuickCollectionView?.reloadData()
            let indexPath = IndexPath(row: 0, section: 0)
            if(photoPicker.currentAlbum != nil){
                self.photoQuickCollectionView?.scrollToItem(at: indexPath, at: UICollectionViewScrollPosition.left, animated: false)
            }
            photoQuickCollectionView.isHidden = false
            quickSendImageButton.isHidden = false
            moreImageButton.isHidden = false
            
            quickSendImageButton.alpha = 0
            moreImageButton.alpha = 0
            
            if stickerViewShow {
                stickerPicker.isHidden = true
                stickerViewShow = false
                self.quickSendImageButton.alpha = 1
                self.moreImageButton.alpha = 1
            }
            else if recordShow {
                self.audioRecorderContentView.isHidden = true
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
                UIView.animate(withDuration: 0.3, animations: {
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
        self.delegate.showFullAlbum()
    }
    
    func showRecord() {
        self.isHidden = false

        if !recordShow {
            self.audioRecorderContentView.requireForPermission(nil)
            self.audioRecorderContentView.isHidden = false
            
            if stickerViewShow {
                stickerPicker.isHidden = true
                stickerViewShow = false
            }else if imageQuickPickerShow{
                self.photoQuickCollectionView.isHidden = true
                self.moreImageButton.isHidden = true
                self.quickSendImageButton.isHidden = true
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
        stickerPicker.isHidden = true
        stickerViewShow = false
        
        photoQuickCollectionView.isHidden = true
        moreImageButton.isHidden = true
        quickSendImageButton.isHidden = true
        imageQuickPickerShow = false
        
        audioRecorderContentView.isHidden = true
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
        
        // use main queue to reload data to avoid problem
        DispatchQueue.main.async(execute: {
            self.photoQuickCollectionView.reloadData()
        });
    }

    // this is the method to handle the number at the top right of the cell
    fileprivate func shiftChosenFrameFromIndex(_ index : Int)
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
        photoPicker.indexAssetDict.removeValue(forKey: photoPicker.indexImageDict.count - 1)
        photoPicker.indexImageDict.removeValue(forKey: photoPicker.indexImageDict.count - 1)
        self.photoQuickCollectionView.reloadData()
    }
    
    fileprivate func updateSendButtonStatus()
    {
        quickSendImageButton.isEnabled = photoPicker.videoAsset != nil || photoPicker.assetIndexDict.count != 0
    }
    
    //MARK: - photoPicker Collection View Delegate
    //photoes preview layout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: photoQuickCollectionReuseIdentifier, for: indexPath) as! PhotoPickerCollectionViewCell
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if collectionView == self.photoQuickCollectionView {
            let cell = cell as! PhotoPickerCollectionViewCell
            //get image from PHFetchResult
            if(self.photoPicker.cameraRoll != nil){
                let asset : PHAsset = self.photoPicker.cameraRoll.albumContent[indexPath.section] as! PHAsset
                if let duration = photoPicker.assetDurationDict[asset]{
                    cell.setVideoDurationLabel(withDuration: duration)
                }
                else if photoPicker.gifAssetDict[asset] != nil {
                    cell.setGifLabel()
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
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == photoQuickCollectionView && self.photoPicker.cameraRoll != nil {
            let cell = collectionView.cellForItem(at: indexPath) as! PhotoPickerCollectionViewCell
            let asset : PHAsset = self.photoPicker.cameraRoll.albumContent[indexPath.section] as! PHAsset
            
            if !cell.photoSelected {
                if photoPicker.indexAssetDict.count == 10 {
                    self.delegate.showAlertView(withWarning: "You can only select up to 10 images at the same time")
                } else {

                    
                    if(asset.mediaType == .image){
                        if(photoPicker.videoAsset != nil){
                            self.delegate.showAlertView(withWarning: "You can't select photo with video")
                            return
                        }
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
                    }else{
                        if(self.photoPicker.indexImageDict.count != 0){
                            self.delegate.showAlertView(withWarning: "You can't select video while selecting photos")
                            return
                        }else if(self.photoPicker.videoAsset != nil){
                            self.delegate.showAlertView(withWarning: "You can only send one video at one time")
                            return
                        }else if(self.photoPicker.assetDurationDict[asset] > 60){
                            self.delegate.showAlertView(withWarning: "Sorry, for now you can only send video below 1 minute")
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
                    self.photoQuickCollectionView.scrollToItem(at: indexPath, at: .left, animated: true)
                }
            } else {
                cell.deselectCell()
                if let deselectedIndex = photoPicker.assetIndexDict[asset]{
                photoPicker.assetIndexDict.removeValue(forKey: asset)
                photoPicker.indexAssetDict.removeValue(forKey: deselectedIndex)
                photoPicker.indexImageDict.removeValue(forKey: deselectedIndex)
                shiftChosenFrameFromIndex(deselectedIndex + 1)
                }
                photoPicker.videoAsset = nil
                photoPicker.videoImage = nil
            }
            //            print("imageDict has \(imageDict.count) images")
            collectionView.deselectItem(at: indexPath, animated: true)
            updateSendButtonStatus()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if(photoPicker.cameraRoll == nil){
            photoPicker.getSmartAlbum()
        }
        if collectionView == photoQuickCollectionView && photoPicker.cameraRoll != nil{
            return photoPicker.cameraRoll.albumCount
        }
        return 0
    }
    
    
    //MARK: - AudioRecorderViewDelegate

    func audioRecorderView(_ audioView: AudioRecorderView, needToSendAudioData data: Data){
        self.delegate.sendAudioData?(data)
        
    }
    
    // MARK: - Sticker delegate
    func sendStickerWithImageName(_ name : String)
    {
        self.delegate.sendStickerWithImageName(name)
        self.stickerPicker.updateStickerHistory(name)
    }
    
    func appendEmojiWithImageName(_ name: String)
    {
        if inputToolbar != nil{
            inputToolbar.contentView.textView.text = inputToolbar.contentView.textView.text + "[\(name)]"
        }
    }
    
    // delete one emoji from the text view , if there's no emoji,then delete one character
    func deleteEmoji()
    {
        if inputToolbar != nil{
            var previous = inputToolbar.contentView.textView.text
            if previous?.characters.count > 0 && previous?.characters.last != "]"{
                inputToolbar.contentView.textView.text = previous?.substring(to: (previous?.characters.index((previous?.endIndex)!, offsetBy: -1 ))!)
            }else if previous?.characters.count > 0 && previous?.characters.last == "]"{
                var i = 1
                var findEmoji = false
                while( i <= (previous?.characters.count)!){
                    if previous?.characters[(previous?.characters.index((previous?.endIndex)!, offsetBy: -i ))!] == "[" {
                        let between = previous?.substring(with:
                            previous!.characters.index((previous?.endIndex)!, offsetBy: -(i-1)) ..< previous!.characters.index((previous?.endIndex)!, offsetBy: -1 ))
                        if between != nil && (StickerInfoStrcut.stickerDictionary["faeEmoji"]?.contains(between!))!{
                            findEmoji = true
                            break
                        }
                    }
                    i += 1
                }
                
                if findEmoji{
                    inputToolbar.contentView.textView.text = previous?.substring(to: (previous?.characters.index((previous?.endIndex)!, offsetBy: -i ))!)
                }else{
                    inputToolbar.contentView.textView.text = previous?.substring(to: (previous?.characters.index((previous?.endIndex)!, offsetBy: -1 ))!)
                }
            }
        }
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
    
    fileprivate func sendVideoFromQuickPicker()
    {
        UIScreenService.showActivityIndicator()

        let image = self.photoPicker.videoImage!
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
                    self.delegate.sendVideoData?(data, snapImage:image ,duration:duration)
                }
            }
            UIScreenService.hideActivityIndicator()
        }
    }
    
}
