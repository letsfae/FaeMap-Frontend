//
//  FaeChatToolBarContentView.swift
//  faeBeta
//
//  Created by YAYUAN SHI on 10/25/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

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
    func sendStickerWithImageName(_ name: String)
    func showFullAlbum(with photoPicker: FaePhotoPicker)
    func sendAudioData(_ data: Data)
    func endEdit()
    func appendEmoji(_ name: String)
    func deleteLastEmoji()
}

class FaeChatToolBarContentView: UIView {

    // MARK: - Properties
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
    private var faePhotoPicker: FaePhotoPicker!
    private var btnQuickSendImage: UIButton!
    private var btnMoreImage: UIButton!
    private var boolImageQuickPickerShow = false
    
    // Sticker
    private var viewStickerPicker: StickerKeyboardView!
    private var boolStickerViewShow = false
    
    // Location
    var viewMiniLoc: LocationPickerMini!
    private var boolMiniLocationShow = false
    
    // Record
    private var viewAudioRecorder: AudioRecorderView!
    private var boolRecordShow = false
    
    // Initialize marker
    private var boolPhotoInitialized = false
    private var boolStickerInitialized = false
    private var boolAudioInitialized = false
    private var boolMiniMapInitialized = false
    
    weak var delegate: FaeChatToolBarContentViewDelegate!
    weak var inputToolbar: JSQMessagesInputToolbarCustom!
    
    // MARK: - init & setup
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setup(_ type : Int) {
        func initializeStickerView() {
            viewStickerPicker = StickerKeyboardView(frame: CGRect(x: 0, y: 0, width: frame.width, height: self.frame.height))
            viewStickerPicker.delegate = self
            addSubview(viewStickerPicker)
            viewStickerPicker.isHidden = true
            boolStickerInitialized = true
        }
        
        func initializePhotoQuickPicker() {
            var configure = FaePhotoPickerConfigure()
            configure.boolFullPicker = false
            configure.sizeThumbnail = CGSize(width: 220, height: frame.height)
            
            faePhotoPicker = FaePhotoPicker(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height), with: configure)
            addSubview(faePhotoPicker)
            
            faePhotoPicker.selectHandler = observeOnSelectedCount
            
            btnMoreImage = UIButton(frame: CGRect(x: 10, y: frame.height - 52 - device_offset_bot, width: 42, height: 42))
            btnMoreImage.setImage(UIImage(named: "moreImage"), for: UIControlState())
            btnMoreImage.addTarget(self, action: #selector(showFullAlbum), for: .touchUpInside)
            faePhotoPicker.addSubview(btnMoreImage)

            btnQuickSendImage = UIButton(frame: CGRect(x: frame.width - 52, y: frame.height - 52 - device_offset_bot, width: 42, height: 42))
            btnQuickSendImage.addTarget(self, action: #selector(sendImageFromQuickPicker), for: .touchUpInside)
            btnQuickSendImage.setImage(UIImage(named: "imageQuickSend"), for: UIControlState())
            //btnQuickSendImage.setImage(UIImage(named: "imageQuickSend_disabled"), for: .disabled)
            faePhotoPicker.addSubview(btnQuickSendImage)
            btnQuickSendImage.isHidden = true
            boolPhotoInitialized = true
        }
        
        func initializeMiniLocation() {
            viewMiniLoc = LocationPickerMini()
            viewMiniLoc.isHidden = true
            addSubview(viewMiniLoc)
            boolMiniMapInitialized = true
        }
        
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
}

// MARK: - Switch between components
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
            } else if boolRecordShow {
                viewAudioRecorder.isHidden = true
                boolRecordShow = false
            } else if boolStickerViewShow {
                viewStickerPicker.isHidden = true
                boolStickerViewShow = false
            } else if boolKeyboardShow {
                UIView.setAnimationsEnabled(false)
                delegate.endEdit()
                UIView.setAnimationsEnabled(true)
            }
            boolMiniLocationShow = true
        }
    }
    
    func showLibrary() {
        //assert(cllcPhotoQuick != nil, "You must call setup() before call showLibrary!")
        isHidden = false
        if !boolImageQuickPickerShow {
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
            } else if boolKeyboardShow {
                UIView.setAnimationsEnabled(false)
                delegate.endEdit()
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
            } else if boolMiniLocationShow {
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
            faePhotoPicker.selectedAssets.removeAll()
            faePhotoPicker.updateSelectedOrder()
            btnQuickSendImage.isHidden = true
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

// MARK: - Quick photo picker button action
extension FaeChatToolBarContentView {
    @objc func showFullAlbum() {
        delegate.showFullAlbum(with: faePhotoPicker)
    }
    
    @objc func sendImageFromQuickPicker() {
        delegate.sendMediaMessage(with: faePhotoPicker.selectedAssets)
        faePhotoPicker.selectedAssets.removeAll()
        faePhotoPicker.updateSelectedOrder()
        btnQuickSendImage.isHidden = true
    }
    
    private func observeOnSelectedCount(_ count: Int) {
        btnQuickSendImage.isHidden = (count == 0)
    }
}

// MARK: - AudioRecorderViewDelegate
extension FaeChatToolBarContentView: AudioRecorderViewDelegate {
    func audioRecorderView(_ audioView: AudioRecorderView, needToSendAudioData data: Data) {
        delegate.sendAudioData(data)
    }
}

// MARK: - SendStickerDelegate
extension FaeChatToolBarContentView: SendStickerDelegate {
    func sendStickerWithImageName(_ name : String) {
        delegate.sendStickerWithImageName(name)
    }
    
    func appendEmojiWithImageName(_ name: String) {
        felixprint("[appendEmojiWithImageName]")
        delegate.appendEmoji(name)
        if inputToolbar != nil {
            inputToolbar.contentView.textView.insertText("[\(name)]")
        }
    }
    
    func deleteEmoji() {
        felixprint("[deleteEmoji]")
        delegate.deleteLastEmoji()
        if inputToolbar != nil {
            let previous = inputToolbar.contentView.textView.text!
            inputToolbar.contentView.textView.text = previous.stringByDeletingLastEmoji()
        }
    }
}
