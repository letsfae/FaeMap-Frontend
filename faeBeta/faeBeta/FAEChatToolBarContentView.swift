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

    // Show the alert to warn user only 10 images can be selected
    func showAlertView(withWarning text: String)
    /// send the sticker image with specific name
    ///
    /// - parameter name: the name of the sticker
    func sendStickerWithImageName(_ name: String)
    /// send multiple images from quick image picker
    ///
    /// - parameter images: an array of selected images
    func sendImages(_ images: [UIImage])
    // present the complete photo album
    // should present CustomCollectionViewController
    func showFullAlbum()
    /// need to implement this method if sending audio is needed
    ///
    /// - parameter data: the audio data to send
    @objc optional func sendAudioData(_ data: Data)
    // end any editing. Especially the input toolbar textView.
    @objc optional func endEdit()
    @objc optional func sendVideoData(_ video: Data, snapImage: UIImage, duration: Int)
    @objc optional func sendGifData(_ data: Data)
    @objc optional func appendEmoji(_ name: String)
    @objc optional func deleteLastEmoji()
}

enum FAEChatToolBarContentType: UInt32 {
    case sticker = 1
    case photo = 2
    case audio = 4
    case minimap = 5
}

/// This view contains all the stuff below a input toolbar, supporting stickers, photo, video, auido
class FAEChatToolBarContentView: UIView, UICollectionViewDelegate,UICollectionViewDataSource, AudioRecorderViewDelegate, SendStickerDelegate {

    // MARK: Properties
    var boolKeyboardShow = false // false: keyboard is hide
    
    // Whether the media content view is show
    var mediaContentShow : Bool {
        get{
            return boolImageQuickPickerShow || boolStickerViewShow || boolRecordShow || boolMiniLocationShow
        }
    }
    
    // Photos
    fileprivate var viewPhotoPicker : PhotoPicker!
    fileprivate var cllcPhotoQuick: UICollectionView!//preview of the photoes
    fileprivate let photoQuickCollectionReuseIdentifier = "photoQuickCollectionReuseIdentifier"
    //let photoQuickCollectionReuseIdentifier = "PhotoCell"
    
    fileprivate let requestOption = PHImageRequestOptions()
    fileprivate var boolImageQuickPickerShow = false //false : not open the photo preview
    
    fileprivate var btnQuickSendImage: UIButton!//right
    fileprivate var btnMoreImage: UIButton!//left
    
    //sticker
    fileprivate var boolStickerViewShow = false//false : not open the stick view
    fileprivate var viewStickerPicker : StickerPickView!
    
    
    //location
    var viewMiniLoc = LocationPickerMini()
    fileprivate var boolMiniLocationShow = false
    
    //record
    fileprivate var boolRecordShow = false // false: not open the record view
    fileprivate var viewAudioRecorder: AudioRecorderView!
    
    //initialize marker
    private var boolPhotoInitialized = false
    private var boolStickerInitialized = false
    private var boolAudioInitialized = false
    private var boolMiniMapInitialized = false
    
    var intMaxNumOfPhotos = 10
    
    weak var delegate : FAEChatToolBarContentViewDelegate!
    
    weak var inputToolbar: JSQMessagesInputToolbarCustom!// IMPORTANT: need to set value for this variable to use the whole function
    
    //MARK: init & setup
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    /// setup UI and funcs
    ///
    /// - Parameter type: this is an enum with all type of content you want to intialize.
    /// you should create this viraible like:         
    /// let initializeType = (FAEChatToolBarContentType.sticker.rawValue | FAEChatToolBarContentType.photo.rawValue | FAEChatToolBarContentType.audio.rawValue)

    func setup(_ type : UInt32) {
        // sticker view
        func initializeStickerView() {
            viewStickerPicker = StickerPickView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height))
            viewStickerPicker.sendStickerDelegate = self
            self.addSubview(viewStickerPicker)
            viewStickerPicker.isHidden = true
            
            boolStickerInitialized = true
        }
        
        //quick image picker
        
        func initializePhotoQuickPicker() {
            //photoes preview
            let layout = UICollectionViewFlowLayout()
            //        layout.itemSize = CGSizeMake(220, 235)
            layout.scrollDirection = .horizontal
            layout.itemSize = CGSize(width: 220, height: 271 + device_offset_bot)
            layout.sectionInset = UIEdgeInsetsMake(0, 1, 0, 1)
            cllcPhotoQuick = UICollectionView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height), collectionViewLayout: layout)
            cllcPhotoQuick.register(QuickPhotoPickerCollectionViewCell.self, forCellWithReuseIdentifier: photoQuickCollectionReuseIdentifier)
            cllcPhotoQuick.backgroundColor = UIColor.white
            cllcPhotoQuick.delegate = self
            cllcPhotoQuick.dataSource = self
            btnMoreImage = UIButton(frame: CGRect(x: 10, y: self.frame.height - 52 - device_offset_bot, width: 42, height: 42))
            btnMoreImage.setImage(UIImage(named: "moreImage"), for: UIControlState())
            btnMoreImage.addTarget(self, action: #selector(self.showFullAlbum), for: .touchUpInside)
            btnQuickSendImage = UIButton(frame: CGRect(x: self.frame.width - 52, y: self.frame.height - 52 - device_offset_bot, width: 42, height: 42))
            btnQuickSendImage.addTarget(self, action: #selector(self.sendImageFromQuickPicker), for: .touchUpInside)
            btnQuickSendImage.setImage(UIImage(named: "imageQuickSend"), for: UIControlState())
            btnQuickSendImage.setImage(UIImage(named: "imageQuickSend_disabled"), for: .disabled)
            viewPhotoPicker = PhotoPicker.shared
            
            self.addSubview(cllcPhotoQuick)
            self.addSubview(btnQuickSendImage)
            self.addSubview(btnMoreImage)

            cllcPhotoQuick.isHidden = true
            btnQuickSendImage.isHidden = true
            btnMoreImage.isHidden = true

            updateSendButtonStatus()
            
            boolPhotoInitialized = true
        }
        
        func initializeMiniLocation() {
            viewMiniLoc.isHidden = true
            self.addSubview(viewMiniLoc)
            boolMiniMapInitialized = true
        }
        
        //MARK: voice helper function
        func initializeRecorder() {
            self.viewAudioRecorder = AudioRecorderView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height))
            self.viewAudioRecorder.delegate = self
            self.addSubview(viewAudioRecorder)
            
            viewAudioRecorder.isHidden = true
            
            boolAudioInitialized = true
        }
        
        self.backgroundColor = UIColor.white
        
        if (type & FAEChatToolBarContentType.sticker.rawValue > 0) && !boolStickerInitialized {
            initializeStickerView()
        }
        if (type & FAEChatToolBarContentType.photo.rawValue > 0) && !boolPhotoInitialized {
            initializePhotoQuickPicker()
        }
        if (type & FAEChatToolBarContentType.audio.rawValue > 0) && !boolAudioInitialized {
            initializeRecorder()
        }
        if (type & FAEChatToolBarContentType.minimap.rawValue > 0) && !boolMiniMapInitialized {
            initializeMiniLocation()
        }
    }
    
    // MARK: show different content
    func showKeyboard() {
        self.isHidden = true
        if boolStickerViewShow {
            viewStickerPicker.isHidden = true
            boolStickerViewShow = false
        }
        if boolImageQuickPickerShow {
            cllcPhotoQuick.isHidden = true
            btnMoreImage.isHidden = true
            btnQuickSendImage.isHidden = true
            boolImageQuickPickerShow = false
        }
        if boolRecordShow {
            viewAudioRecorder.isHidden = true
            boolRecordShow = false
        }
        if boolMiniLocationShow {
            boolMiniLocationShow = false
            viewMiniLoc.isHidden = true
        }
        //boolKeyboardShow = true

    }
    
    
    func showStikcer() {
        assert(viewStickerPicker != nil, "You must call setup() before call showSticker!")
        self.isHidden = false
        //show stick view, and dismiss all other views, like keyboard and photoes preview
        if !boolStickerViewShow {
            self.viewStickerPicker.isHidden = false
 
            if self.boolImageQuickPickerShow {
                self.cllcPhotoQuick.isHidden = true
                self.btnMoreImage.isHidden = true
                self.btnQuickSendImage.isHidden = true
                self.boolImageQuickPickerShow = false
            } else if boolRecordShow {
                self.viewAudioRecorder.isHidden = true
                self.boolRecordShow = false
            } else if boolMiniLocationShow {
                self.boolMiniLocationShow = false
                self.viewMiniLoc.isHidden = true
            } else if boolKeyboardShow {
                UIView.setAnimationsEnabled(false)
                self.delegate.endEdit?()
                //self.boolKeyboardShow = false
                UIView.setAnimationsEnabled(true)
            }
            self.boolStickerViewShow = true
        }
    }
    
    
    func showMiniLocation() {
        self.isHidden = false;
        if !boolMiniLocationShow {
            self.viewMiniLoc.isHidden = false
            
            if self.boolImageQuickPickerShow {
                self.cllcPhotoQuick.isHidden = true
                self.btnMoreImage.isHidden = true
                self.btnQuickSendImage.isHidden = true
                self.boolImageQuickPickerShow = false
            }
            else if (boolRecordShow) {
                self.viewAudioRecorder.isHidden = true
                self.boolRecordShow = false
            } else if boolStickerViewShow {
                viewStickerPicker.isHidden = true
                boolStickerViewShow = false
                self.btnQuickSendImage.alpha = 1
                self.btnMoreImage.alpha = 1
            }
            else if (boolKeyboardShow){
                UIView.setAnimationsEnabled(false)
                self.delegate.endEdit?()
                //self.boolKeyboardShow = false
                UIView.setAnimationsEnabled(true)
            }
            
            self.boolMiniLocationShow = true
        }
    }
    
    func showLibrary() {
        assert(cllcPhotoQuick != nil, "You must call setup() before call showLibrary!")
        self.isHidden = false
        if !boolImageQuickPickerShow {
            self.cllcPhotoQuick?.reloadData()
            let indexPath = IndexPath(row: 0, section: 0)
            if viewPhotoPicker.currentAlbum != nil {
                self.cllcPhotoQuick?.scrollToItem(at: indexPath, at: UICollectionViewScrollPosition.left, animated: false)
            }
            cllcPhotoQuick.isHidden = false
            btnQuickSendImage.isHidden = false
            btnMoreImage.isHidden = false
            
            btnQuickSendImage.alpha = 0
            btnMoreImage.alpha = 0
            
            if boolStickerViewShow {
                viewStickerPicker.isHidden = true
                boolStickerViewShow = false
                self.btnQuickSendImage.alpha = 1
                self.btnMoreImage.alpha = 1
            } else if boolRecordShow {
                self.viewAudioRecorder.isHidden = true
                self.boolRecordShow = false
                self.btnQuickSendImage.alpha = 1
                self.btnMoreImage.alpha = 1
            } else if boolMiniLocationShow {
                self.boolMiniLocationShow = false
                self.viewMiniLoc.isHidden = true
                self.btnQuickSendImage.alpha = 1
                self.btnMoreImage.alpha = 1
            } else if (boolKeyboardShow){
                UIView.setAnimationsEnabled(false)
                self.delegate.endEdit?()
                //self.boolKeyboardShow = false
                UIView.setAnimationsEnabled(true)
                self.btnQuickSendImage.alpha = 1
                self.btnMoreImage.alpha = 1
            } else {
                UIView.animate(withDuration: 0.3, animations: {
                    self.btnQuickSendImage.alpha = 1
                    self.btnMoreImage.alpha = 1
                    }, completion:{ (Bool) -> Void in
                })
            }
            boolImageQuickPickerShow = true
        }
    }
    
    @objc func showFullAlbum() {
        self.delegate.showFullAlbum()
    }
    
    func showRecord() {
        assert(viewAudioRecorder != nil, "You must call setup() before call showRecord!")

        self.isHidden = false

        if !boolRecordShow {
            self.viewAudioRecorder.requireForPermission(nil)
            self.viewAudioRecorder.isHidden = false
            
            if boolStickerViewShow {
                viewStickerPicker.isHidden = true
                boolStickerViewShow = false
            } else if boolImageQuickPickerShow {
                self.cllcPhotoQuick.isHidden = true
                self.btnMoreImage.isHidden = true
                self.btnQuickSendImage.isHidden = true
                self.boolImageQuickPickerShow = false
            } else if (boolMiniLocationShow) {
                self.boolMiniLocationShow = false
                self.viewMiniLoc.isHidden = true
            } else if boolKeyboardShow {
                UIView.setAnimationsEnabled(false)
                self.delegate.endEdit?()
                UIView.setAnimationsEnabled(true)
            }
            boolRecordShow = true
        }
    }

    /// close all content
    func closeAll() {
        if viewStickerPicker != nil {
            viewStickerPicker.isHidden = true
        }
        boolStickerViewShow = false
        
        if cllcPhotoQuick != nil {
            cllcPhotoQuick.isHidden = true
            btnMoreImage.isHidden = true
            btnQuickSendImage.isHidden = true
        }
        boolImageQuickPickerShow = false
        
        if viewAudioRecorder != nil {
            viewAudioRecorder.isHidden = true
            viewAudioRecorder.switchToRecordMode()
        }
        boolRecordShow = false
        if boolMiniLocationShow {
            boolMiniLocationShow = false
            viewMiniLoc.isHidden = true
        }
    }
    
    func clearToolBarViews() {
        viewStickerPicker = nil
        boolStickerViewShow = false
        boolImageQuickPickerShow = false
        cllcPhotoQuick = nil
        if viewPhotoPicker != nil {
            viewPhotoPicker.cleanup()
        }
        viewAudioRecorder = nil
        boolRecordShow = false
        boolAudioInitialized = false
        boolPhotoInitialized = false
        boolStickerInitialized = false
        boolMiniMapInitialized = false
        felixprint("clear tool bar views")
    }
    
    // MARK: helper
    // reload the photo album, called after take new photos
    func reloadPhotoAlbum() {
        if let photoPicker = viewPhotoPicker {
            photoPicker.getSmartAlbum()
            self.cllcPhotoQuick?.reloadData()
        }
    }
    
    // remove all selected photos, clean up the select frames
    func cleanUpSelectedPhotos() {
        if let photoPicker = viewPhotoPicker {
            photoPicker.cleanup()
            // use main queue to reload data to avoid problem
            DispatchQueue.main.async(execute: {
                self.cllcPhotoQuick?.reloadData()
            })
        }
    }

    // this is the method to handle the number at the top right of the cell
    fileprivate func shiftChosenFrameFromIndex(_ index : Int) {
        // when deselect one image in photoes preview, we need to reshuffule
        if index > viewPhotoPicker.indexImageDict.count {
            return
        }
        for i in index...viewPhotoPicker.indexImageDict.count {
            let image = viewPhotoPicker.indexImageDict[i]
            let asset = viewPhotoPicker.indexAssetDict[i]
            viewPhotoPicker.assetIndexDict[asset!] = i - 1
            viewPhotoPicker.indexImageDict[i-1] = image
            viewPhotoPicker.indexAssetDict[i-1] = asset
        }
        viewPhotoPicker.indexAssetDict.removeValue(forKey: viewPhotoPicker.indexImageDict.count - 1)
        viewPhotoPicker.indexImageDict.removeValue(forKey: viewPhotoPicker.indexImageDict.count - 1)
        //self.cllcPhotoQuick.reloadData()
        for (asset, indexPath) in viewPhotoPicker.assetIndexpath {
            let indicatorNum = viewPhotoPicker.assetIndexDict[asset]
            if let cell = cllcPhotoQuick.cellForItem(at: indexPath) {
                let modifyCell = cell as! QuickPhotoPickerCollectionViewCell
                modifyCell.selectCell(indicatorNum!)
            } else {
                /*let cell = cllcPhotoQuick.dequeueReusableCell(withReuseIdentifier: photoQuickCollectionReuseIdentifier, for: indexPath) as! QuickPhotoPickerCollectionViewCell
                cell.selectCell(indicatorNum!)*/
            }
        }
    }
    
    fileprivate func updateSendButtonStatus() {
        btnQuickSendImage.isEnabled = viewPhotoPicker.videoAsset != nil || viewPhotoPicker.assetIndexDict.count != 0
    }
    
    // MARK: photoPicker Collection View Delegate
    //photoes preview layout
    @objc func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 10
    }
    
    @objc func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: photoQuickCollectionReuseIdentifier, for: indexPath) as! QuickPhotoPickerCollectionViewCell
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if collectionView == self.cllcPhotoQuick {
            let cell = cell as! QuickPhotoPickerCollectionViewCell
            //get image from PHFetchResult
            if self.viewPhotoPicker.cameraRoll != nil {
                let asset : PHAsset = self.viewPhotoPicker.cameraRoll.albumContent[indexPath.section]
                if let duration = viewPhotoPicker.assetDurationDict[asset] {
                    cell.setVideoDurationLabel(withDuration: duration)
                }
                let orgFilename = asset.value(forKey: "filename") as! String
                if orgFilename.lowercased().contains(".gif") {
                    cell.setGifLabel()
                }
                cell.loadImage(asset, requestOption: requestOption)
                if viewPhotoPicker.assetIndexDict[asset] != nil {
                    cell.selectCell(viewPhotoPicker.assetIndexDict[asset]!)
                } else {
                    cell.deselectCell()
                }
            }
        }
    }
    
    // photoes preview delegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == cllcPhotoQuick && self.viewPhotoPicker.cameraRoll != nil {
            let cell = collectionView.cellForItem(at: indexPath) as! QuickPhotoPickerCollectionViewCell
            let asset: PHAsset = self.viewPhotoPicker.cameraRoll.albumContent[indexPath.section]
            
            if !cell.photoSelected {
                if viewPhotoPicker.indexAssetDict.count == intMaxNumOfPhotos {
                    self.delegate.showAlertView(withWarning: "You can only select up to \(intMaxNumOfPhotos) images at the same time")
                } else {
                    if asset.mediaType == .image {
                        if viewPhotoPicker.videoAsset != nil {
                            self.delegate.showAlertView(withWarning: "Sorry, Videos must be sent alone!")
                            return
                        } else if viewPhotoPicker.gifAssetDict.count > 0 {
                            self.delegate.showAlertView(withWarning: "Sorry Gifs must be sent alone!")
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
                        highQRequestOption.deliveryMode = .highQualityFormat //high pixel
                        highQRequestOption.isSynchronous = true
                        PHCachingImageManager.default().requestImage(for: asset, targetSize: CGSize(width: 1500,height: 1500), contentMode: .aspectFill, options: highQRequestOption) { (result, info) in
                            self.viewPhotoPicker.indexImageDict[count] = result
                        }
                    } else{ // if is selecting video
                        if self.viewPhotoPicker.indexImageDict.count != 0 || viewPhotoPicker.gifAssetDict.count != 0 {
                            self.delegate.showAlertView(withWarning: "Sorry, Videos must be sent alone!")
                            return
                        } else if self.viewPhotoPicker.videoAsset != nil {
                            self.delegate.showAlertView(withWarning: "You can only send one video at one time")
                            return
                        } else if self.viewPhotoPicker.assetDurationDict[asset] > 60 {
                            self.delegate.showAlertView(withWarning: "Sorry, for now you can only send video below 1 minute")
                            return
                        }
                        
                        viewPhotoPicker.assetIndexDict[asset] = viewPhotoPicker.indexImageDict.count
                        viewPhotoPicker.indexAssetDict[viewPhotoPicker.indexImageDict.count] = asset
                        let lowQRequestOption = PHVideoRequestOptions()
                        lowQRequestOption.deliveryMode = .fastFormat //high pixel
                        PHCachingImageManager.default().requestAVAsset(forVideo: asset, options: lowQRequestOption) { (asset, audioMix, info) in
                            self.viewPhotoPicker.videoAsset = asset
                        }
                        
                        let highQRequestOption = PHImageRequestOptions()
                        highQRequestOption.resizeMode = .exact
                        highQRequestOption.deliveryMode = .highQualityFormat //high pixel
                        highQRequestOption.isSynchronous = true
                        PHCachingImageManager.default().requestImage(for: asset, targetSize: CGSize(width: asset.pixelWidth, height: asset.pixelHeight), contentMode: .aspectFill, options: highQRequestOption) { (result, info) in
                            if result != nil {
                                self.viewPhotoPicker.videoImage = result
                            }
                        }
                    }
                    cell.selectCell(max(viewPhotoPicker.indexImageDict.count - 1, 0))
                    self.cllcPhotoQuick.scrollToItem(at: indexPath, at: .left, animated: true)
                }
            } else {
                cell.deselectCell()
                if let deselectedIndex = viewPhotoPicker.assetIndexDict[asset]{
                    viewPhotoPicker.assetIndexDict.removeValue(forKey: asset)
                    viewPhotoPicker.indexAssetDict.removeValue(forKey: deselectedIndex)
                    viewPhotoPicker.indexImageDict.removeValue(forKey: deselectedIndex)
                    viewPhotoPicker.assetIndexpath.removeValue(forKey: asset)
                    shiftChosenFrameFromIndex(deselectedIndex + 1)
                }
                
                if let _ = viewPhotoPicker.gifAssetDict[asset]{
                    viewPhotoPicker.gifAssetDict.removeAll()
                }
                viewPhotoPicker.videoAsset = nil
                viewPhotoPicker.videoImage = nil
            }
            collectionView.deselectItem(at: indexPath, animated: true)
            updateSendButtonStatus()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if viewPhotoPicker.cameraRoll == nil {
            viewPhotoPicker.getSmartAlbum()
        }
        if collectionView == cllcPhotoQuick && viewPhotoPicker.cameraRoll != nil {
            return viewPhotoPicker.cameraRoll.albumCount
        }
        return 0
    }
    
    //MARK: AudioRecorderViewDelegate
    func audioRecorderView(_ audioView: AudioRecorderView, needToSendAudioData data: Data) {
        self.delegate.sendAudioData?(data)
        
    }
    
    // MARK: Sticker delegate
    func sendStickerWithImageName(_ name : String) {
        self.delegate.sendStickerWithImageName(name)
        self.viewStickerPicker.updateStickerHistory(name)
    }
    
    func appendEmojiWithImageName(_ name: String) {
        print("[appendEmojiWithImageName]")
        self.delegate.appendEmoji!(name)
        if inputToolbar != nil {
            inputToolbar.contentView.textView.insertText("[\(name)]")
        }
    }
    
    // delete one emoji from the text view , if there's no emoji,then delete one character
    func deleteEmoji() {
        print("[deleteEmoji]")
        self.delegate.deleteLastEmoji!()
        if inputToolbar != nil {
            let previous = inputToolbar.contentView.textView.text!
            inputToolbar.contentView.textView.text = previous.stringByDeletingLastEmoji()
        }
    }
    
    // MARK: - Quick image picker delegate
    @objc func sendImageFromQuickPicker() {
        if viewPhotoPicker.videoAsset != nil {
            sendVideoFromQuickPicker()
            return
        } else if viewPhotoPicker.gifAssetDict.count != 0 {
            if sendGifFromQuickPicker() {
                return
            }
        }
        var images = [UIImage]()

        for i in 0..<viewPhotoPicker.indexImageDict.count {
            images.append(viewPhotoPicker.indexImageDict[i]!)
        }
        self.delegate.sendImages(images)
    }
    
    private func sendGifFromQuickPicker() -> Bool {
        if self.delegate.sendGifData != nil {
            for data in viewPhotoPicker.gifAssetDict.values {
                self.delegate.sendGifData!(data)
            }
            return true
        }
        return false
    }
    
    fileprivate func sendVideoFromQuickPicker() {
        UIScreenService.showActivityIndicator()

        let image = self.viewPhotoPicker.videoImage!
        let duration = viewPhotoPicker.assetDurationDict[viewPhotoPicker.indexAssetDict[0]!] ?? 0
        // asset is you AVAsset object
        let exportSession = AVAssetExportSession(asset:viewPhotoPicker.videoAsset!, presetName: AVAssetExportPresetMediumQuality)
        let filePath = NSTemporaryDirectory().appendingFormat("/video.mov")
        do {
            try FileManager.default.removeItem(atPath: filePath)
        } catch {
            
        }
        exportSession!.outputURL = URL(fileURLWithPath: filePath) // Better to use initFileURLWithPath:isDirectory: if you know if the path is a directory vs non-directory, as it saves an i/o.

        let fileUrl = exportSession!.outputURL
        // e.g .mov type
        exportSession!.outputFileType = AVFileType.mov
        exportSession?.exportAsynchronously {
            switch exportSession!.status {
            case  AVAssetExportSessionStatus.failed:
                print("failed import video: \(String(describing: exportSession!.error))")
                break
            case AVAssetExportSessionStatus.cancelled:
                print("cancelled import video: \(String(describing: exportSession!.error))")
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
