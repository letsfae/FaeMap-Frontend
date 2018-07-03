//
//  ChatViewController.swift
//  quickChat
//
//  Created by User on 6/6/16.
//  Copyright © 2016 User. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import Photos
import MobileCoreServices
import CoreMedia
import AVFoundation
import RealmSwift

class ChatViewController: JSQMessagesViewControllerCustom, UINavigationControllerDelegate {
    // MARK: - Properties
    
    /// Views
    var faeInputBar = FaeInputBar()
    private var uiviewNavBar: FaeNavBar!
    var uiviewNameCard: FMNameCardView!
    
    /// Chat info & data source
    var strChatId: String = ""
    var intIsGroup: Int = 0
    var arrUserIDs: [String] = []
    var arrRealmUsers: [RealmUser] = []
    var arrFaeMessages: [FaeMessage] = [] /// data source of collectionView
    var resultRealmMessages: Results<RealmMessage>!
    var notificationToken: NotificationToken?
    let intNumberOfMessagesOneTime = 15
    
    var boolLoadingPreviousMessages = false
    var boolJustSentHeart = false // avoid sending heart continuously
    var avatarDictionary: NSMutableDictionary = [:]
    private var playingAudio: JSQAudioMediaItemCustom?
    weak var mapDelegate: LocDetailDelegate?
    
    override var inputAccessoryView: UIView? {
        return faeInputBar
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    var isFirstLayout: Bool = true
    var collectionViewBottomInset: CGFloat = 0 {
        didSet {
            collectionView.contentInset.bottom = collectionViewBottomInset + device_offset_bot
            collectionView.scrollIndicatorInsets.bottom = collectionViewBottomInset + device_offset_bot
        }
    }
    
    var boolIsDisappearing: Bool = false
    
    // iOS Geocoder
    let clgeocoder = CLGeocoder()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionView()
        setUserInfo()
        setupNameCard()
        loadLatestMessagesFromRealm()
        navigationBarSet()
        collectionView.becomeFirstResponder()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //view.layoutIfNeeded()
        //collectionView.collectionViewLayout.invalidateLayout()
        if !isFirstLayout {
            //scrollToBottom(animated: false)
        }
        //collectionView.becomeFirstResponder()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        boolIsDisappearing = false
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        //collectionViewBottomInset = 86 // TODO: bug topStackView
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        boolIsDisappearing = true
        playingAudio?.finishPlaying()
    }
    
    override func viewDidLayoutSubviews() {
        if isFirstLayout {
            defer { isFirstLayout = false }
            addKeyboardObservers()
            //collectionViewBottomInset = 86
            collectionViewBottomInset = keyboardOffsetFrame.height
            let collectionViewContentHeight = collectionView.collectionViewLayout.collectionViewContentSize.height
            collectionView.setContentOffset(CGPoint(x: collectionView.contentOffset.x, y: collectionViewContentHeight), animated: false)
        }
    }
    
    deinit {
        removeKeyboardObservers()
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "appWillEnterForeground"), object: nil)
    }
    
    // MARK: - Setup
    private func setupCollectionView() {
        collectionView.backgroundColor = UIColor._241241241()
        collectionView.keyboardDismissMode = .interactive
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        collectionView.contentInset.top = device_offset_top
        faeInputBar.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterForeground), name: NSNotification.Name(rawValue: "appWillEnterForeground"), object: nil)
    }
    
    private func setUserInfo() {
        senderId = "\(Key.shared.user_id)"
        let realm = try! Realm()
        for user_id in arrUserIDs {
            if let user = realm.filterUser(id: "\(user_id)") {
                arrRealmUsers.append(user)
            }
        }
        senderDisplayName = arrRealmUsers[1].display_name
        createAvatars()
        collectionView.collectionViewLayout.incomingAvatarViewSize = CGSize(width: 39, height: 39)
        collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSize(width: 39, height: 39)
    }
    
    private func createAvatars() {
        for user in arrRealmUsers {
            var avatarJSQ: JSQMessagesAvatarImage
            if let avatarData = user.avatar?.userSmallAvatar {
                let avatarImg = UIImage(data: avatarData as Data)
                avatarJSQ = JSQMessagesAvatarImage(avatarImage: avatarImg, highlightedImage: avatarImg, placeholderImage: avatarImg)
            } else {
                avatarJSQ = JSQMessagesAvatarImageFactory.avatarImage(with: UIImage(named: "avatarPlaceholder"), diameter: 70)
            }
            avatarDictionary.addEntries(from: [user.id : avatarJSQ])
        }
    }
    
    private func setupNameCard() {
        uiviewNameCard = FMNameCardView()
        uiviewNameCard.delegate = self
        let rootViewController: UIViewController = UIApplication.shared.windows.last!.rootViewController!
        rootViewController.view.addSubview(uiviewNameCard)
    }
    
    private func navigationBarSet() {
        uiviewNavBar = FaeNavBar(frame: CGRect.zero)
        view.addSubview(uiviewNavBar)
        uiviewNavBar.loadBtnConstraints()
        uiviewNavBar.rightBtn.setImage(nil, for: .normal)
        uiviewNavBar.leftBtn.addTarget(self, action: #selector(navigationLeftItemTapped), for: .touchUpInside)
        uiviewNavBar.lblTitle.text = arrRealmUsers[1].display_name
    }
    
    private func addKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardDidChangeState(_:)), name: .UIKeyboardWillChangeFrame, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleTextViewDidBeginEditing(_:)), name: .UITextViewTextDidBeginEditing, object: nil)
    }
    
    private func removeKeyboardObservers() {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillChangeFrame, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UITextViewTextDidBeginEditing, object: nil)
    }
    
    // MARK: - Button actions & notification
    @objc private func navigationLeftItemTapped() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc
    private func handleKeyboardDidChangeState(_ notification: Notification) {
        if boolIsDisappearing { return }
        guard let userInfo = notification.userInfo else { return }
        guard let keyboardEndFrame = userInfo[UIKeyboardFrameEndUserInfoKey] as? CGRect else { return }
        let duration:TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
        let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
        let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIViewAnimationOptions.curveEaseInOut.rawValue
        let animationCurve: UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
        
        let newBottomInset = view.frame.height - keyboardEndFrame.minY - iPhoneXBottomInset
        let differenceOfBottomInset = newBottomInset - collectionViewBottomInset
        if differenceOfBottomInset != 0 {
            let contentOffset = CGPoint(x: collectionView.contentOffset.x, y: collectionView.contentOffset.y + differenceOfBottomInset)
            collectionView.setContentOffset(contentOffset, animated: false)
        }
        
        collectionViewBottomInset = newBottomInset
        
        /*if (keyboardEndFrame.origin.y + keyboardEndFrame.size.height) > UIScreen.main.bounds.height {
            collectionViewBottomInset = view.frame.size.height - keyboardEndFrame.origin.y - iPhoneXBottomInset
        } else {
            let afterBottomInset = keyboardEndFrame.height > keyboardOffsetFrame.height ? (keyboardEndFrame.height - iPhoneXBottomInset) : keyboardOffsetFrame.height
            let differenceOfBottomInset = afterBottomInset - collectionViewBottomInset
            if differenceOfBottomInset != 0 {
                let contentOffset = CGPoint(x: collectionView.contentOffset.x, y: collectionView.contentOffset.y + differenceOfBottomInset)
                UIView.animate(withDuration: duration, delay: 0, options: animationCurve, animations: {
                    self.collectionView.setContentOffset(contentOffset, animated: false)
                }, completion: nil)
            }
            UIView.animate(withDuration: duration, delay: 0, options: animationCurve, animations: {
                self.collectionViewBottomInset = afterBottomInset
                self.collectionView.layoutIfNeeded()
            }, completion: nil)
        }*/
    }
    
    @objc
    private func handleTextViewDidBeginEditing(_ notification: Notification) {
        guard let inputTextView = notification.object as? ChatInputTextView, inputTextView == faeInputBar.inputTextView else { return }
        //scrollDialogToBottom()
        scrollToBottom(animated: false)
    }
    
    @objc
    private func appWillEnterForeground() {
        faeInputBar.inputTextView.resignFirstResponder()
    }
    
    // MARK: - Layout helper
    func scrollDialogToBottom(animated: Bool = false) {
        let collectionViewContentHeight = collectionView.collectionViewLayout.collectionViewContentSize.height
        collectionView.performBatchUpdates(nil) { _ in
            self.collectionView.scrollRectToVisible(CGRect(x: 0.0, y: collectionViewContentHeight - 1.0, width: 1.0, height: 1.0), animated: animated)
        }
    }
    
    var keyboardOffsetFrame: CGRect {
        guard let inputFrame = inputAccessoryView?.frame else { return .zero }
        return CGRect(origin: inputFrame.origin, size: CGSize(width: inputFrame.width, height: inputFrame.height - iPhoneXBottomInset))
    }
    
    private var iPhoneXBottomInset: CGFloat {
        if #available(iOS 11.0, *) {
            guard UIScreen.main.nativeBounds.height == 2436 else { return 0 }
            return view.safeAreaInsets.bottom
        }
        return 0
    }
    
    func showAlertView(withWarning text: String) {
        let alert = UIAlertController(title: text, message: "", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { _ in
            //if self.faeInputBar.inputTextView.isFirstResponder {
                //self.faeInputBar.inputTextView.becomeFirstResponder()
                //self.faeInputBar.inputTextView.resignFirstResponder()
            //}
        }))
        alert.modalPresentationStyle = .currentContext
        let rootViewController: UIViewController =
            UIApplication.shared.windows.last!.rootViewController!
        rootViewController.present(alert, animated: true, completion: nil)
    }
}

extension ChatViewController {
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == collectionView {
            let currentOffset = scrollView.contentOffset.y
            if currentOffset < 1 && !boolLoadingPreviousMessages && !isFirstLayout {
                loadPrevMessagesFromRealm()
            }
        }
    }
}

// MARK: - FaeInputBarDelegate & InputView related delegates
extension ChatViewController: FaeInputBarDelegate, FullAlbumSelectionDelegate, SelectLocationDelegate, MapSearchDelegate {
    // MARK: FaeInputBarDelegate
    func faeInputBar(_ inputBar: FaeInputBar, didPressSendButtonWith text: String, with pinView: InputBarTopPinView?) {
        if let pinView = pinView {
            if let location = pinView.location {
                let locDetail = "{\"latitude\":\"\(location.coordinate.latitude)\", \"longitude\":\"\(location.coordinate.longitude)\", \"address1\":\"\(pinView.lblLine1.text!)\", \"address2\":\"\(pinView.lblLine2.text!)\", \"address3\":\"\(pinView.lblLine3.text!)\", \"comment\":\"\(text)\"}"
                storeChatMessageToRealm(type: "[Location]", text: locDetail, media: pinView.getImageData())
            } else if let place = pinView.placeData {
                let placeDetail = "{\"id\":\"\(place.id)\", \"name\":\"\(place.name)\", \"address\":\"\(place.address1),\(place.address2)\", \"imageURL\":\"\(place.imageURL)\", \"comment\":\"\(text)\"}"
                storeChatMessageToRealm(type: "[Place]", text: placeDetail, media: pinView.getImageData())
            }
        } else {
            storeChatMessageToRealm(type: "text", text: text)
        }
        inputBar.inputTextView.text = String()
    }
    
    func faeInputBar(_ inputBar: FaeInputBar, didChangeIntrinsicContentTo size: CGSize) {
        
    }
    
    func faeInputBar(_ inputBar: FaeInputBar, textViewTextDidChangeTo text: String) {
        
    }
    
    func faeInputBar(_ inputBar: FaeInputBar, didSendStickerWith name: String, isFaeHeart faeHeart: Bool) {
        if faeHeart {
            if !boolJustSentHeart {
                storeChatMessageToRealm(type: "[Heart]", text: "pinDetailLikeHeartFullLarge")
                boolJustSentHeart = true
            }
        } else {
            storeChatMessageToRealm(type: "[Sticker]", text: name)
        }
    }
    
    func faeInputBar(_ inputBar: FaeInputBar, didPressQuickSendImages images: [FaePHAsset]) {
        sendMediaMessage(images)
    }
    
    func faeInputBar(_ inputBar: FaeInputBar, needToSendAudioData data: Data) {
        storeChatMessageToRealm(type: "[Audio]", text: "[Audio]", media: data)
    }
    
    func faeInputBar(_ inputBar: FaeInputBar, showFullView type: String, with object: Any?) {
        faeInputBar.inputTextView.resignFirstResponder()
        switch type {
        case "photo":
            let vcFullAlbum = FullAlbumViewController()
            vcFullAlbum.prePhotoPicker = object as? FaePhotoPicker
            vcFullAlbum.delegate = self
            boolIsDisappearing = true
            navigationController?.pushViewController(vcFullAlbum, animated: true)
        case "camera":
            let camera = Camera(delegate_: self)
            boolIsDisappearing = true
            camera.presentPhotoCamera(self, canEdit: false)
        case "map":
            let vc = SelectLocationViewController()
            vc.boolFromChat = true
            vc.boolSearchEnabled = true
            vc.previousVC = .chat
            vc.delegate = self
            Key.shared.selectedLoc = LocManager.shared.curtLoc.coordinate
            boolIsDisappearing = true
            navigationController?.pushViewController(vc, animated: false)
        default: break
        }
    }
    
    // MARK: - MapSearchDelegate
    func selectPlace(place: PlacePin) {
        faeInputBar.setupTopStackView(place: place)
        collectionViewBottomInset = faeInputBar.intrinsicContentSize.height
        scrollToBottom(animated: false)
    }
    
    // MARK: FullAlbumSelectionDelegate
    func finishChoosing(with faePHAssets: [FaePHAsset]) {
        sendMediaMessage(faePHAssets)
    }
    
    private func sendMediaMessage(_ faePHAssets: [FaePHAsset]) {
        for faePHAsset in faePHAssets {
            switch faePHAsset.assetType {
            case .photo, .livePhoto:
                var messageType = ""
                messageType = faePHAsset.fileFormat() == .gif ? "[Gif]" : "[Picture]"
                storeChatMessageToRealm(type: messageType, text: messageType, faePHAsset: faePHAsset)
            case .video:
                storeChatMessageToRealm(type: "[Video]", text: "\(faePHAsset.phAsset?.duration ?? 0.0)", faePHAsset: faePHAsset)
            }
        }
    }
    
    // MARK: SelectLocationDelegate
    func sendLocationBack(address: RouteAddress) {
        let location = CLLocation(latitude: address.coordinate.latitude, longitude: address.coordinate.longitude)
        clgeocoder.cancelGeocode()
        clgeocoder.reverseGeocodeLocation(location, completionHandler: {
            (placemarks, error) -> Void in
            guard let response = placemarks?[0] else { return }
            AddPinToCollectionView().mapScreenShot(coordinate: CLLocationCoordinate2D(latitude: address.coordinate.latitude, longitude: address.coordinate.longitude)) { [weak self] (snapShotImage) in
                self?.faeInputBar.setupTopStackView(placemark: response, thumbnail: snapShotImage)
            }
        })
    }
    
    func sendPlaceBack(placeData: PlacePin) {
        joshprint("[sendPlaceBack] called")
        faeInputBar.setupTopStackView(place: placeData)
        collectionViewBottomInset = faeInputBar.intrinsicContentSize.height
        scrollToBottom(animated: false)
        /*let collectionViewContentHeight = collectionView.collectionViewLayout.collectionViewContentSize.height
         collectionView.setContentOffset(CGPoint(x: collectionView.contentOffset.x, y: collectionViewContentHeight), animated: false)*/
    }
}

// MARK: - UIImagePickerControllerDelegate
extension ChatViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        let type = info[UIImagePickerControllerMediaType] as! String
        switch type {
        case (kUTTypeImage as String as String):
            let picture = info[UIImagePickerControllerOriginalImage] as! UIImage
            storeChatMessageToRealm(type: "[Picture]", text: "[Picture]", media: RealmChat.compressImageToData(picture))
            //sendMessage(picture: picture, date: Date())
            if PHPhotoLibrary.authorizationStatus() == .authorized {
                UIImageWriteToSavedPhotosAlbum(picture, self, #selector(ChatViewController.image(_:didFinishSavingWithError:contextInfo:)), nil)
            }
        case (kUTTypeMovie as String as String):
            let movieURL = info[UIImagePickerControllerMediaURL] as! URL
            
            //get duration of the video
            let asset = AVURLAsset(url: movieURL)
            let duration = CMTimeGetSeconds(asset.duration)
            let seconds = Int(ceil(duration))
            
            /*let imageGenerator = AVAssetImageGenerator(asset: asset)
             var time = asset.duration
             time.value = 0
             
             //get snapImage
             var snapImage = UIImage()
             do {
             let imageRef = try imageGenerator.copyCGImage(at: time, actualTime: nil)
             snapImage = UIImage(cgImage: imageRef)
             } catch {
             //Handle failure
             }
             
             var imageData = UIImageJPEGRepresentation(snapImage, 1)
             let factor = min(5000000.0 / CGFloat(imageData!.count), 1.0)
             imageData = UIImageJPEGRepresentation(snapImage, factor)*/
            
            //let path = movieURL.path
            //let data = FileManager.default.contents(atPath: path)
            //sendMessage(video: data, videoDuration: seconds, snapImage: imageData, date: Date())
            var faePHAsset = FaePHAsset(asset: nil)
            faePHAsset.localURL = movieURL
            storeChatMessageToRealm(type: "[Video]", text: "\(seconds)", faePHAsset: faePHAsset)
        default: break
        }
        
        picker.dismiss(animated: true, completion: nil)
        
    }
    
    /*func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
     faeInputBar.setNeedsLayout()
     faeInputBar.layoutIfNeeded()
     picker.dismiss(animated: true, completion: nil)
     }*/
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: NSError, contextInfo: AnyObject?) {
        //appWillEnterForeground()
    }
}

// MARK: - JSQAudioMediaItemDelegateCustom
extension ChatViewController: JSQAudioMediaItemDelegateCustom {
    func audioMediaItem(_ audioMediaItem: JSQAudioMediaItemCustom, didChangeAudioCategory category: String, options: AVAudioSessionCategoryOptions = [], error: Error?) {
    }
    
    func audioMediaItemDidStartPlayingAudio(_ audioMediaItem: JSQAudioMediaItemCustom, audioButton sender: UIButton) {
        if let current = playingAudio {
            if current != audioMediaItem {
                current.finishPlaying()
            }
        }
        playingAudio = audioMediaItem
    }
}

