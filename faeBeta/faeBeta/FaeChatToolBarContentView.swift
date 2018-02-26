//
//  FaeChatToolBarContentView.swift
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

protocol FaeChatToolBarContentViewDelegate: class {
    func sendMediaMessage(with faePHAssets: [FaePHAsset])
    func showAlertView(withWarning text: String)
    func sendStickerWithImageName(_ name: String)
    func sendImages(_ images: [UIImage])
    func showFullAlbum(with photoPicker: FaePhotoPicker)
    func sendAudioData(_ data: Data)
    func endEdit()
    //@objc optional func sendVideoData(_ video: Data, snapImage: UIImage, duration: Int)
    //@objc optional func sendGifData(_ data: Data)
    func appendEmoji(_ name: String)
    func deleteLastEmoji()
}

/// This view contains all the stuff below a input toolbar, supporting stickers, photo, video, auido
class FaeChatToolBarContentView: UIView {

    // MARK: Properties
    static let STICKER = 0b1
    static let PHOTO = 0b10
    static let AUDIO = 0b100
    static let MINIMAP = 0b10000
    
    var boolKeyboardShow = false
    
    // Whether the media content view is show
    var boolMediaShow: Bool {
        get {
            return boolImageQuickPickerShow || boolStickerViewShow || boolRecordShow || boolMiniLocationShow
        }
    }
    
    // Photos
    fileprivate var faePhotoPicker: FaePhotoPicker!
    //fileprivate var photoPicker: PhotoPicker!
    //fileprivate var cllcPhotoQuick: UICollectionView!//preview of the photoes
    //fileprivate let photoQuickCollectionReuseIdentifier = "photoQuickCollectionReuseIdentifier"
    //fileprivate let requestOption = PHImageRequestOptions()
    fileprivate var btnQuickSendImage: UIButton!
    fileprivate var btnMoreImage: UIButton!
    fileprivate var boolImageQuickPickerShow = false
    
    //sticker
    fileprivate var viewStickerPicker: StickerKeyboardView!
    fileprivate var boolStickerViewShow = false
    
    //location
    var viewMiniLoc: LocationPickerMini!
    fileprivate var boolMiniLocationShow = false
    
    //record
    fileprivate var viewAudioRecorder: AudioRecorderView!
    fileprivate var boolRecordShow = false
    
    //initialize marker
    fileprivate var boolPhotoInitialized = false
    fileprivate var boolStickerInitialized = false
    fileprivate var boolAudioInitialized = false
    fileprivate var boolMiniMapInitialized = false
    
    var intMaxNumOfPhotos = 10
    
    weak var delegate: FaeChatToolBarContentViewDelegate!
    
    weak var inputToolbar: JSQMessagesInputToolbarCustom!// IMPORTANT: need to set value for this variable to use the whole function
    
    // MARK: init & setup
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setup(_ type : Int) {
        // sticker view
        func initializeStickerView() {
            //viewStickerPicker = StickerPickView(frame: CGRect(x: 0, y: 0, width: frame.width, height: self.frame.height))
            //viewStickerPicker.sendStickerDelegate = self
            viewStickerPicker = StickerKeyboardView(frame: CGRect(x: 0, y: 0, width: frame.width, height: self.frame.height))
            viewStickerPicker.delegate = self
            addSubview(viewStickerPicker)
            viewStickerPicker.isHidden = true
            boolStickerInitialized = true
        }
        
        // quick photo picker
        func initializePhotoQuickPicker() {
            /*uiviewPhotoPicker = UIView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
            uiviewPhotoPicker.backgroundColor = .white
            addSubview(uiviewPhotoPicker)
            uiviewPhotoPicker.isHidden = true
            
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .horizontal
            layout.itemSize = CGSize(width: 220, height: 271 + device_offset_bot)
            layout.sectionInset = UIEdgeInsetsMake(0, 1, 0, 1)
            
            cllcPhotoQuick = UICollectionView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height), collectionViewLayout: layout)
            cllcPhotoQuick.register(QuickPhotoPickerCollectionViewCell.self, forCellWithReuseIdentifier: photoQuickCollectionReuseIdentifier)
            cllcPhotoQuick.backgroundColor = UIColor.white
            cllcPhotoQuick.delegate = self
            cllcPhotoQuick.dataSource = self
            uiviewPhotoPicker.addSubview(cllcPhotoQuick)*/

            var configure = FaePhotoPickerConfigure()
            configure.boolFullPicker = false
            configure.sizeThumbnail = CGSize(width: 220, height: frame.height)
            
            faePhotoPicker = FaePhotoPicker(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height), with: configure)
            addSubview(faePhotoPicker)
            
            btnMoreImage = UIButton(frame: CGRect(x: 10, y: frame.height - 52 - device_offset_bot, width: 42, height: 42))
            btnMoreImage.setImage(UIImage(named: "moreImage"), for: UIControlState())
            btnMoreImage.addTarget(self, action: #selector(showFullAlbum), for: .touchUpInside)
            faePhotoPicker.addSubview(btnMoreImage)

            btnQuickSendImage = UIButton(frame: CGRect(x: frame.width - 52, y: frame.height - 52 - device_offset_bot, width: 42, height: 42))
            btnQuickSendImage.addTarget(self, action: #selector(sendImageFromQuickPicker), for: .touchUpInside)
            btnQuickSendImage.setImage(UIImage(named: "imageQuickSend"), for: UIControlState())
            btnQuickSendImage.setImage(UIImage(named: "imageQuickSend_disabled"), for: .disabled)
            faePhotoPicker.addSubview(btnQuickSendImage)
            
            //photoPicker = PhotoPicker.shared
            //updateSendButtonStatus()
            boolPhotoInitialized = true
        }
        
        func initializeMiniLocation() {
            viewMiniLoc = LocationPickerMini()
            viewMiniLoc.isHidden = true
            addSubview(viewMiniLoc)
            boolMiniMapInitialized = true
        }
        
        //MARK: voice helper function
        func initializeRecorder() {
            viewAudioRecorder = AudioRecorderView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
            viewAudioRecorder.delegate = self
            addSubview(viewAudioRecorder)
            viewAudioRecorder.isHidden = true
            boolAudioInitialized = true
        }
        
        backgroundColor = .white
        
        if (type & FaeChatToolBarContentView.STICKER > 0) && !boolStickerInitialized {
            initializeStickerView()
        }
        if (type & FaeChatToolBarContentView.PHOTO > 0) && !boolPhotoInitialized {
            initializePhotoQuickPicker()
        }
        if (type & FaeChatToolBarContentView.AUDIO > 0) && !boolAudioInitialized {
            initializeRecorder()
        }
        if (type & FaeChatToolBarContentView.MINIMAP > 0) && !boolMiniMapInitialized {
            initializeMiniLocation()
        }
    }
    
    // MARK: photoPicker Collection View Delegate
    //photoes preview layout
    /*@objc func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 10
    }
    
    @objc func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 10
    }*/
}

// MARK: switch between components
extension FaeChatToolBarContentView {
    func showKeyboard() {
        isHidden = true

        if boolStickerViewShow {
            viewStickerPicker.isHidden = true
            boolStickerViewShow = false
        }
        if boolImageQuickPickerShow {
            faePhotoPicker.isHidden = true
            boolImageQuickPickerShow = false
        }
        if boolRecordShow {
            viewAudioRecorder.isHidden = true
            boolRecordShow = false
        }
        if boolMiniLocationShow {
            viewMiniLoc.isHidden = true
            boolMiniLocationShow = false
        }
        //boolKeyboardShow = true
    }
    
    func showStikcer() {
        assert(viewStickerPicker != nil, "You must call setup() before call showSticker!")
        isHidden = false
        //show stick view, and dismiss all other views, like keyboard and photoes preview
        if !boolStickerViewShow {
            viewStickerPicker.isHidden = false
            if boolImageQuickPickerShow {
                faePhotoPicker.isHidden = true
                boolImageQuickPickerShow = false
            } else if boolRecordShow {
                viewAudioRecorder.isHidden = true
                boolRecordShow = false
            } else if boolMiniLocationShow {
                boolMiniLocationShow = false
                viewMiniLoc.isHidden = true
            } else if boolKeyboardShow {
                UIView.setAnimationsEnabled(false)
                delegate.endEdit()
                //self.boolKeyboardShow = false
                UIView.setAnimationsEnabled(true)
            }
            boolStickerViewShow = true
        }
    }
    
    func showMiniLocation() {
        assert(viewMiniLoc != nil, "You must call setup() before call showMiniLocation!")
        isHidden = false
        if !boolMiniLocationShow {
            viewMiniLoc.isHidden = false
            if boolImageQuickPickerShow {
                faePhotoPicker.isHidden = true
                boolImageQuickPickerShow = false
            } else if (boolRecordShow) {
                viewAudioRecorder.isHidden = true
                boolRecordShow = false
            } else if boolStickerViewShow {
                viewStickerPicker.isHidden = true
                boolStickerViewShow = false
            } else if (boolKeyboardShow){
                UIView.setAnimationsEnabled(false)
                delegate.endEdit()
                //self.boolKeyboardShow = false
                UIView.setAnimationsEnabled(true)
            }
            boolMiniLocationShow = true
        }
    }
    
    func showLibrary() {
        //assert(cllcPhotoQuick != nil, "You must call setup() before call showLibrary!")
        isHidden = false
        if !boolImageQuickPickerShow {
            /*cllcPhotoQuick?.reloadData()
            let indexPath = IndexPath(row: 0, section: 0)
            if photoPicker.currentAlbum != nil {
                cllcPhotoQuick?.scrollToItem(at: indexPath, at: UICollectionViewScrollPosition.left, animated: false)
            }*/
            faePhotoPicker.isHidden = false
            if boolStickerViewShow {
                viewStickerPicker.isHidden = true
                boolStickerViewShow = false
            } else if boolRecordShow {
                viewAudioRecorder.isHidden = true
                boolRecordShow = false
            } else if boolMiniLocationShow {
                boolMiniLocationShow = false
                viewMiniLoc.isHidden = true
            } else if (boolKeyboardShow){
                UIView.setAnimationsEnabled(false)
                delegate.endEdit()
                //self.boolKeyboardShow = false
                UIView.setAnimationsEnabled(true)
            }
            boolImageQuickPickerShow = true
        }
    }
    
    func showRecord() {
        assert(viewAudioRecorder != nil, "You must call setup() before call showRecord!")
        isHidden = false
        if !boolRecordShow {
            viewAudioRecorder.requireForPermission(nil)
            viewAudioRecorder.isHidden = false
            if boolStickerViewShow {
                viewStickerPicker.isHidden = true
                boolStickerViewShow = false
            } else if boolImageQuickPickerShow {
                faePhotoPicker.isHidden = true
                boolImageQuickPickerShow = false
            } else if (boolMiniLocationShow) {
                boolMiniLocationShow = false
                viewMiniLoc.isHidden = true
            } else if boolKeyboardShow {
                UIView.setAnimationsEnabled(false)
                delegate.endEdit()
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
        
        if faePhotoPicker != nil {
            faePhotoPicker.isHidden = true
        }
        boolImageQuickPickerShow = false
        
        if viewAudioRecorder != nil {
            viewAudioRecorder.isHidden = true
            viewAudioRecorder.switchToRecordMode()
        }
        boolRecordShow = false

        if viewMiniLoc != nil {
            viewMiniLoc.isHidden = true
        }
        boolMiniLocationShow = false
    }
    
    func clearToolBarViews() {
        viewStickerPicker = nil
        boolStickerViewShow = false
        
        /*if photoPicker != nil {
            photoPicker.cleanup()
        }*/
        faePhotoPicker = nil
        boolImageQuickPickerShow = false
        
        viewAudioRecorder = nil
        boolRecordShow = false
        
        viewMiniLoc = nil
        boolMiniLocationShow = false
        
        boolAudioInitialized = false
        boolPhotoInitialized = false
        boolStickerInitialized = false
        boolMiniMapInitialized = false
        felixprint("clear tool bar views")
    }
}
/*
// MARK: UICollectionViewDataSource
extension FaeChatToolBarContentView: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if photoPicker.cameraRoll == nil {
            photoPicker.getSmartAlbum()
        }
        if collectionView == cllcPhotoQuick && photoPicker.cameraRoll != nil {
            return photoPicker.cameraRoll.albumCount
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: photoQuickCollectionReuseIdentifier, for: indexPath) as! QuickPhotoPickerCollectionViewCell
        return cell
    }
}

// MARK: UICollectionViewDelegate
extension FaeChatToolBarContentView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if collectionView == self.cllcPhotoQuick {
            let cell = cell as! QuickPhotoPickerCollectionViewCell
            //get image from PHFetchResult
            if self.photoPicker.cameraRoll != nil {
                let asset : PHAsset = self.photoPicker.cameraRoll.albumContent[indexPath.section]
                if let duration = photoPicker.assetDurationDict[asset] {
                    cell.setVideoDurationLabel(withDuration: duration)
                }
                let orgFilename = asset.value(forKey: "filename") as! String
                if orgFilename.lowercased().contains(".gif") {
                    cell.setGifLabel()
                }
                cell.loadImage(asset, requestOption: requestOption)
                if photoPicker.assetIndexDict[asset] != nil {
                    cell.selectCell(photoPicker.assetIndexDict[asset]!)
                } else {
                    cell.deselectCell()
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == cllcPhotoQuick && self.photoPicker.cameraRoll != nil {
            let cell = collectionView.cellForItem(at: indexPath) as! QuickPhotoPickerCollectionViewCell
            let asset: PHAsset = self.photoPicker.cameraRoll.albumContent[indexPath.section]
            
            if !cell.photoSelected {
                if photoPicker.indexAssetDict.count == intMaxNumOfPhotos {
                    self.delegate.showAlertView(withWarning: "You can only select up to \(intMaxNumOfPhotos) images at the same time")
                } else {
                    if asset.mediaType == .image {
                        if photoPicker.videoAsset != nil {
                            self.delegate.showAlertView(withWarning: "Sorry, Videos must be sent alone!")
                            return
                        } else if photoPicker.gifAssetDict.count > 0 {
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
                                    self.photoPicker.gifAssetDict[asset] = data
                                }
                            })
                        }
                        photoPicker.assetIndexDict[asset] = photoPicker.indexImageDict.count
                        photoPicker.indexAssetDict[photoPicker.indexImageDict.count] = asset
                        photoPicker.assetIndexpath[asset] = indexPath
                        let count = self.photoPicker.indexImageDict.count
                        
                        let highQRequestOption = PHImageRequestOptions()
                        highQRequestOption.resizeMode = .none
                        highQRequestOption.deliveryMode = .highQualityFormat //high pixel
                        highQRequestOption.isSynchronous = true
                        PHCachingImageManager.default().requestImage(for: asset, targetSize: CGSize(width: 1500,height: 1500), contentMode: .aspectFill, options: highQRequestOption) { (result, info) in
                            self.photoPicker.indexImageDict[count] = result
                        }
                    } else{ // if is selecting video
                        if self.photoPicker.indexImageDict.count != 0 || photoPicker.gifAssetDict.count != 0 {
                            self.delegate.showAlertView(withWarning: "Sorry, Videos must be sent alone!")
                            return
                        } else if self.photoPicker.videoAsset != nil {
                            self.delegate.showAlertView(withWarning: "You can only send one video at one time")
                            return
                        } else if self.photoPicker.assetDurationDict[asset] > 60 {
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
                        PHCachingImageManager.default().requestImage(for: asset, targetSize: CGSize(width: asset.pixelWidth, height: asset.pixelHeight), contentMode: .aspectFill, options: highQRequestOption) { (result, info) in
                            if result != nil {
                                self.photoPicker.videoImage = result
                            }
                        }
                    }
                    cell.selectCell(max(photoPicker.indexImageDict.count - 1, 0))
                    self.cllcPhotoQuick.scrollToItem(at: indexPath, at: .left, animated: true)
                }
            } else {
                cell.deselectCell()
                if let deselectedIndex = photoPicker.assetIndexDict[asset]{
                    photoPicker.assetIndexDict.removeValue(forKey: asset)
                    photoPicker.indexAssetDict.removeValue(forKey: deselectedIndex)
                    photoPicker.indexImageDict.removeValue(forKey: deselectedIndex)
                    photoPicker.assetIndexpath.removeValue(forKey: asset)
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
    }
    
}

// MARK: Quick photo picker helpers
extension FaeChatToolBarContentView {
    // reload the photo album, called after take new photos
    func reloadPhotoAlbum() {
        if let photoPicker = photoPicker {
            photoPicker.getSmartAlbum()
            self.cllcPhotoQuick?.reloadData()
        }
    }
    
    // remove all selected photos, clean up the select frames
    func cleanUpSelectedPhotos() {
        if let photoPicker = photoPicker {
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
        //self.cllcPhotoQuick.reloadData()
        for (asset, indexPath) in photoPicker.assetIndexpath {
            let indicatorNum = photoPicker.assetIndexDict[asset]
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
        btnQuickSendImage.isEnabled = photoPicker.videoAsset != nil || photoPicker.assetIndexDict.count != 0
    }
}
*/
// MARK: Quick photo picker button action
extension FaeChatToolBarContentView {
    @objc func showFullAlbum() {
        self.delegate.showFullAlbum(with: faePhotoPicker)
    }
    
    @objc func sendImageFromQuickPicker() {
        /*if photoPicker.videoAsset != nil {
            sendVideoFromQuickPicker()
            return
        } else if photoPicker.gifAssetDict.count != 0 {
            if sendGifFromQuickPicker() {
                return
            }
        }
        var images = [UIImage]()
        
        for i in 0..<photoPicker.indexImageDict.count {
            images.append(photoPicker.indexImageDict[i]!)
        }
        self.delegate.sendImages(images)*/
        delegate.sendMediaMessage(with: faePhotoPicker.selectedAssets)
        faePhotoPicker.selectedAssets.removeAll()
        faePhotoPicker.updateSelectedOrder()
    }
    
    fileprivate func sendGifFromQuickPicker() -> Bool {
        /*if self.delegate.sendGifData != nil {
            for data in photoPicker.gifAssetDict.values {
                self.delegate.sendGifData!(data)
            }
            return true
        }*/
        return false
    }
    
    fileprivate func sendVideoFromQuickPicker() {
        /*UIScreenService.showActivityIndicator()
        
        let image = self.photoPicker.videoImage!
        let duration = photoPicker.assetDurationDict[photoPicker.indexAssetDict[0]!] ?? 0
        // asset is you AVAsset object
        let exportSession = AVAssetExportSession(asset:photoPicker.videoAsset!, presetName: AVAssetExportPresetMediumQuality)
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
            case AVAssetExportSessionStatus.cancelled:
                print("cancelled import video: \(String(describing: exportSession!.error))")
            default:
                print("completed import video")
                if let data = try? Data(contentsOf: fileUrl!){
                    self.delegate.sendVideoData?(data, snapImage:image ,duration:duration)
                }
            }
            UIScreenService.hideActivityIndicator()
        }*/
    }
}

// MARK: AudioRecorderViewDelegate
extension FaeChatToolBarContentView: AudioRecorderViewDelegate {
    func audioRecorderView(_ audioView: AudioRecorderView, needToSendAudioData data: Data) {
        self.delegate.sendAudioData(data)
    }
}

// MARK: SendStickerDelegate
extension FaeChatToolBarContentView: SendStickerDelegate {
    func sendStickerWithImageName(_ name : String) {
        self.delegate.sendStickerWithImageName(name)
        //self.viewStickerPicker.updateStickerHistory(name)
    }
    
    func appendEmojiWithImageName(_ name: String) {
        print("[appendEmojiWithImageName]")
        self.delegate.appendEmoji(name)
        if inputToolbar != nil {
            inputToolbar.contentView.textView.insertText("[\(name)]")
        }
    }
    
    func deleteEmoji() {
        print("[deleteEmoji]")
        self.delegate.deleteLastEmoji()
        if inputToolbar != nil {
            let previous = inputToolbar.contentView.textView.text!
            inputToolbar.contentView.textView.text = previous.stringByDeletingLastEmoji()
        }
    }
}


