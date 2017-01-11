
//  EditCommentPinViewController.swift
//  faeBeta
//
//  Created by Yue on 10/30/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
import SwiftyJSON
import SDWebImage
import RealmSwift
import IDMPhotoBrowser

protocol EditCommentPinViewControllerDelegate: class {
    func reloadCommentContent()
}

class EditCommentPinViewController: UIViewController, UITextViewDelegate, CreatePinInputToolbarDelegate, SendStickerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, SendMutipleImagesDelegate, EditMediaCollectionCellDelegate {
    
    weak var delegate: EditCommentPinViewControllerDelegate?
    
    let screenWidth = UIScreen.main.bounds.width
    let screenHeight = UIScreen.main.bounds.height
    let colorPlaceHolder = UIColor(red: 234/255, green: 234/255, blue: 234/255, alpha: 1.0)
    
    //Base View
    var buttonCancel: UIButton!
    var buttonSave: UIButton!
    var labelTitle: UILabel!
    var uiviewLine: UIView!
    var textViewUpdateComment: UITextView!
    var labelTextViewPlaceholder: UILabel!
    var imageViewForChat: UIImageView!
    var collectionViewMedia: UICollectionView!
    var activityIndicator: UIActivityIndicatorView!
    
    //Parameter passed by parent view
    var pinID = ""
    var previousCommentContent = ""
    var pinGeoLocation: CLLocationCoordinate2D!
    var pinType = ""
    var imageForChat: UIImage!
    var pinMediaImageArray: [UIImageView] = []
    var editPinMode: PinDetailViewController.PinType = .media
    var mediaIdArray: [Int] = []
    
    //input toolbar
    var inputToolbar: CreatePinInputToolbar!
    var buttonOpenFaceGesPanel: UIButton!
    var buttonFinishEdit: UIButton!
    var labelCountChars: UILabel!
    var editOption: UIButton!
    var lineOnToolbar: UIView!
    
    //Emoji View
    var emojiView: StickerPickView!
    var isShowingEmoji: Bool = false
    
    
    //New Added ID array
    var newAddedImageArray: [UIImage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        loadEditCommentPinItems()
        addObservers()
        loadKeyboardToolBar()
        loadEmojiView()
        textViewDidChange(textViewUpdateComment)
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        textViewUpdateComment.becomeFirstResponder()
        
    }
    override func viewDidLayoutSubviews() {
        print("[viewDidLayoutSubviews]")
        super.viewDidLayoutSubviews()
        if collectionViewMedia != nil {
            var insets = self.collectionViewMedia.contentInset
            insets.left = 15
            insets.right = 15
            self.collectionViewMedia.contentInset = insets
            self.collectionViewMedia.decelerationRate = UIScrollViewDecelerationRateFast
        }
    }
    
    func loadEditCommentPinItems() {
        buttonCancel = UIButton()
        buttonCancel.setImage(UIImage(named: "cancelEditCommentPin"), for: UIControlState())
        self.view.addSubview(buttonCancel)
        self.view.addConstraintsWithFormat("H:|-15-[v0(54)]", options: [], views: buttonCancel)
        self.view.addConstraintsWithFormat("V:|-28-[v0(25)]", options: [], views: buttonCancel)
        buttonCancel.addTarget(self,
                               action: #selector(self.actionCancelCommentPinEditing(_:)),
                               for: .touchUpInside)
        
        buttonSave = UIButton()
        buttonSave.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size: 18)
        buttonSave.setTitle("Save", for: .normal)
        let buttonTitle = buttonSave.title(for: .normal)
        let attributedString = NSMutableAttributedString(string: buttonTitle!)
        attributedString.addAttribute(NSKernAttributeName, value: CGFloat(-0.46), range: NSRange(location: 0, length: buttonTitle!.characters.count))
        buttonSave.setAttributedTitle(attributedString, for: .normal)
        
        checkButtonState()
        self.view.addSubview(buttonSave)
        self.view.addConstraintsWithFormat("H:[v0(38)]-15-|", options: [], views: buttonSave)
        self.view.addConstraintsWithFormat("V:|-28-[v0(25)]", options: [], views: buttonSave)
        buttonSave.addTarget(self,
                               action: #selector(self.actionUpdateCommentPinEditing(_:)),
                               for: .touchUpInside)
        
        labelTitle = UILabel()
        labelTitle.font = UIFont(name: "AvenirNext-Medium", size: 20)
        labelTitle.text = "Edit Comment"
        labelTitle.textColor = UIColor(red: 89/255, green: 89/255, blue: 89/255, alpha: 1.0)
        self.view.addSubview(labelTitle)
        self.view.addConstraintsWithFormat("H:[v0(133)]", options: [], views: labelTitle)
        self.view.addConstraintsWithFormat("V:|-28-[v0(27)]", options: [], views: labelTitle)
        NSLayoutConstraint(item: labelTitle, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1.0, constant: 0).isActive = true
        
        uiviewLine = UIView(frame: CGRect(x: 0, y: 64, width: screenWidth, height: 1))
        uiviewLine.layer.borderWidth = screenWidth
        uiviewLine.layer.borderColor = UIColor(red: 200/255, green: 199/255, blue: 204/255, alpha: 1.0).cgColor
        self.view.addSubview(uiviewLine)
        
        var textViewWidth: CGFloat = 0
        if screenWidth == 414 { // 5.5
            textViewWidth = 360
        }
        else if screenWidth == 320 { // 4.0
            textViewWidth = 266
        }
        else if screenWidth == 375 { // 4.7
            textViewWidth = 321
        }
        textViewUpdateComment = UITextView(frame: CGRect(x: 27, y: 84, width: textViewWidth, height: 100))
        textViewUpdateComment.text = ""
        textViewUpdateComment.font = UIFont(name: "AvenirNext-Regular", size: 18)
        textViewUpdateComment.textColor = UIColor(red: 89/255, green: 89/255, blue: 89/255, alpha: 1.0)
        textViewUpdateComment.textContainerInset = UIEdgeInsets.zero
        textViewUpdateComment.indicatorStyle = UIScrollViewIndicatorStyle.white
        textViewUpdateComment.text = previousCommentContent
        textViewUpdateComment.delegate = self
        self.view.addSubview(textViewUpdateComment)
        UITextView.appearance().tintColor = UIColor.faeAppRedColor()
        
        labelTextViewPlaceholder = UILabel(frame: CGRect(x: 2, y: 0, width: 171, height: 27))
        labelTextViewPlaceholder.font = UIFont(name: "AvenirNext-Regular", size: 18)
        labelTextViewPlaceholder.textColor = colorPlaceHolder
        labelTextViewPlaceholder.text = "Type a comment..."
        textViewUpdateComment.addSubview(labelTextViewPlaceholder)
        
        switch editPinMode {
        case .comment:
            loadViewForComment()
            break
        case .chat_room:
            loadViewForChat()
            break
        case .media:
            loadViewForMoment()
            break
        }

    }
    
    func loadViewForComment() {
        textViewUpdateComment.frame.origin.x = 27
        textViewUpdateComment.frame.origin.y = 84
        
        labelTextViewPlaceholder.text = "Type a comment..."
    }
    func loadViewForMoment() {
        textViewUpdateComment.frame.origin.x = 27
        textViewUpdateComment.frame.origin.y = 196
        
        labelTextViewPlaceholder.text = "Type a comment..."
        
        let layout = CenterCellCollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 100, height: 100)
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 5
        
        collectionViewMedia = UICollectionView(frame: CGRect(x: 0, y: 81, width: screenWidth, height: 100), collectionViewLayout: layout)
        collectionViewMedia.register(EditPinCollectionViewCell.self, forCellWithReuseIdentifier: "pinMedia")
        collectionViewMedia.delegate = self
        collectionViewMedia.dataSource = self
        collectionViewMedia.isPagingEnabled = false
        collectionViewMedia.backgroundColor = UIColor.clear
        collectionViewMedia.showsHorizontalScrollIndicator = false
        self.view.addSubview(collectionViewMedia)
    }
    func loadViewForChat() {
        imageViewForChat = UIImageView(frame: CGRect(x: 162, y: 76, width: 90, height: 90))
        imageViewForChat.image = imageForChat
        self.view.addSubview(imageViewForChat)
        
        //Line below the image
        let line = UIView(frame: CGRect(x: 0, y: 213, width: screenWidth, height: 12))
        line.backgroundColor = UIColor(red: 241/255, green: 241/255, blue: 241/255, alpha: 1)
        self.view.addSubview(line)
        
        let descriptionTitle = UILabel(frame: CGRect(x: 15, y: 239, width: 200, height: 22))
        descriptionTitle.textColor = UIColor(red: 89/255, green: 89/255, blue: 89/255, alpha: 1)
        descriptionTitle.font = UIFont(name: "AvenirNext-Medium", size: 16)
        descriptionTitle.text = "Description"
        self.view.addSubview(descriptionTitle)
        
        textViewUpdateComment.frame.origin.x = 27
        textViewUpdateComment.frame.origin.y = 266
        
        labelTextViewPlaceholder.text = "Type a chat decription"
    }
    
    private func loadKeyboardToolBar() {
        inputToolbar = CreatePinInputToolbar()
        inputToolbar.delegate = self
        inputToolbar.darkBackgroundView.backgroundColor = UIColor.white
        inputToolbar.buttonOpenFaceGesPanel.setImage(#imageLiteral(resourceName: "faeGestureFilledRed"), for: UIControlState())
        inputToolbar.buttonOpenFaceGesPanel.setTitle("", for: UIControlState())
        inputToolbar.buttonFinishEdit.setImage(UIImage(), for: UIControlState())
        
        //Line on the toolbar
        lineOnToolbar = UIView(frame: CGRect(x: 0, y: 1, width: screenWidth, height: 1))
        lineOnToolbar.layer.borderWidth = screenWidth
        lineOnToolbar.layer.borderColor = UIColor(red: 200/255, green: 199/255, blue: 204/255, alpha: 1.0).cgColor
        inputToolbar.darkBackgroundView.addSubview(lineOnToolbar)
        
        inputToolbar.buttonFinishEdit.isHidden = true
        buttonFinishEdit = UIButton()
        buttonFinishEdit.setTitle("Edit Options", for: UIControlState())
        buttonFinishEdit.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 18)
        inputToolbar.addSubview(buttonFinishEdit)
        inputToolbar.addConstraintsWithFormat("H:[v0(105)]-14-|", options: [], views: buttonFinishEdit)
        inputToolbar.addConstraintsWithFormat("V:[v0(25)]-11-|", options: [], views: buttonFinishEdit)
        buttonFinishEdit.addTarget(self, action: #selector(self.moreOptions(_ :)), for: .touchUpInside)
        buttonFinishEdit.setTitleColor(UIColor(red: 155/255, green: 155/255, blue:155/255, alpha: 1), for: UIControlState())
        inputToolbar.darkBackgroundView.addSubview(buttonFinishEdit)

        inputToolbar.labelCountChars.textColor = UIColor(red: 155/255, green: 155/255, blue:155/255, alpha: 1)
        
        self.view.addSubview(inputToolbar)
        
        inputToolbar.alpha = 1
        self.view.layoutIfNeeded()
    }
    
    private func loadEmojiView(){
        emojiView = StickerPickView(frame: CGRect(x: 0, y: screenHeight, width: screenWidth, height: 271), emojiOnly: true)
        emojiView.sendStickerDelegate = self
        self.view.addSubview(emojiView)
    }
    
    func actionCancelCommentPinEditing(_ sender: UIButton) {
        textViewUpdateComment.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }
    
    func actionUpdateCommentPinEditing(_ sender: UIButton) {
//        if previousCommentContent == textViewUpdateComment.text && newAddedFileIDs =={
//            textViewUpdateComment.endEditing(true)
//            self.dismiss(animated: true, completion: nil)
//        }
//        else {
            let updateComment = FaeMap()
            print("[updatePin] \(pinGeoLocation.latitude), \(pinGeoLocation.longitude)")
            updateComment.whereKey("geo_latitude", value: "\(pinGeoLocation.latitude)")
            updateComment.whereKey("geo_longitude", value: "\(pinGeoLocation.longitude)")
            if pinType == "comment" {
                updateComment.whereKey("content", value: textViewUpdateComment.text) //content or description
            }else if pinType == "media" {
                updateComment.whereKey("description", value: textViewUpdateComment.text)
                var fileIdString = ""
                for ID in mediaIdArray {
                    if fileIdString == "" {
                        fileIdString = "\(ID)"
                    }else {
                        fileIdString = "\(fileIdString);\(ID)"
                    }
                }
                updateComment.whereKey("file_ids", value: fileIdString)
                print("newAddedFileIDs: \(fileIdString)")
            }else if pinType == "chat_room"{
                
            }
            updateComment.updatePin(pinType, pinId: pinID) {(status: Int, message: Any?) in
                if status / 100 == 2 {
                    print("Success -> Update \(self.pinType)")
                    self.delegate?.reloadCommentContent()
                    self.textViewUpdateComment.endEditing(true)
                    self.dismiss(animated: true, completion: nil)
                }
                else {
                    print("Fail -> Update \(self.pinType)")
                }
            }
        //}
    }
    
    private func addObservers() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardWillShow(_:)),
                                               name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardWillHide(_:)),
                                               name:NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func keyboardWillShow(_ notification:Notification)
    {
        
        let userInfo:NSDictionary = notification.userInfo! as NSDictionary
        let keyboardFrame:NSValue = userInfo.value(forKey: UIKeyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue
        let keyboardHeight = keyboardRectangle.height
        inputToolbar.alpha = 1
        UIView.animate(withDuration: 0.3,delay: 0, options: .curveLinear, animations:{
            Void in
            self.inputToolbar.frame.origin.y = self.screenHeight - keyboardHeight - 100
        }, completion: nil)
    }
    
    func keyboardWillHide(_ notification: Notification)
    {
        if(!isShowingEmoji){
            UIView.animate(withDuration: 0.3,delay: 0, options: .curveLinear, animations:{
                Void in
                self.inputToolbar.frame.origin.y = self.screenHeight - 100
                self.inputToolbar.alpha = 0
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
    }
    
    func inputToolbarFinishButtonTapped(inputToolbar: CreatePinInputToolbar)
    {
        self.view.endEditing(true)
        if(isShowingEmoji){
            isShowingEmoji = false
            hideEmojiViewAnimated(animated: true)
        }
    }
    
    func inputToolbarEmojiButtonTapped(inputToolbar: CreatePinInputToolbar) {
        if(!isShowingEmoji){
            isShowingEmoji = true
            self.view.endEditing(true)
            showEmojiViewAnimated(animated: true)
        }else{
            isShowingEmoji = false
            hideEmojiViewAnimated(animated: false)
        }
    }
    
    func moreOptions(_ sender: UIButton) {
        let editMoreOptions = EditMoreOptionsViewController()
        editMoreOptions.pinID = pinID
        editMoreOptions.pinType = pinType
        editMoreOptions.pinGeoLocation = pinGeoLocation
        self.present(editMoreOptions, animated: true, completion: nil)
    }
    
    func sendStickerWithImageName(_ name : String)
    {
        // do nothing here, won't send sticker
    }
    func appendEmojiWithImageName(_ name: String)
    {
        self.textViewUpdateComment.text = self.textViewUpdateComment.text + "[\(name)]"
        self.textViewDidChange(textViewUpdateComment) //Don't forget adding this line, otherwise there will be a little bug if textfield is null while appending Emoji
    }
    func deleteEmoji()
    {
        self.textViewUpdateComment.text = self.textViewUpdateComment.text.stringByDeletingLastEmoji()
        self.textViewDidChange(self.textViewUpdateComment)
    }
    
    func showEmojiViewAnimated(animated: Bool)
    {
        if(animated){
            UIView.animate(withDuration: 0.3, animations: {
                self.inputToolbar.frame.origin.y = self.screenHeight - 271 - 100
                self.emojiView.frame.origin.y = self.screenHeight - 271
            }, completion: { (Completed) in
                self.inputToolbar.buttonOpenFaceGesPanel.setImage(#imageLiteral(resourceName: "keyboardIconFilledRed"), for: UIControlState())
            })
        }else{
            self.inputToolbar.frame.origin.y = screenHeight - 271 - 100
            self.emojiView.frame.origin.y = screenHeight - 271
            self.inputToolbar.buttonOpenFaceGesPanel.setImage(#imageLiteral(resourceName: "keyboardIconFilledRed"), for: UIControlState())
        }
    }
    
    func hideEmojiViewAnimated(animated: Bool)
    {
        if(animated){
            UIView.animate(withDuration: 0.3, animations: {
                self.inputToolbar.frame.origin.y = self.screenHeight - 100
                self.inputToolbar.alpha = 0
                self.emojiView.frame.origin.y = self.screenHeight
            }, completion: { (Completed) in
                self.inputToolbar.buttonOpenFaceGesPanel.setImage(#imageLiteral(resourceName: "faeGestureFilledRed"), for: UIControlState())
            })
        }else{
            self.inputToolbar.frame.origin.y = screenHeight - 100
            self.inputToolbar.alpha = 0
            self.emojiView.frame.origin.y = screenHeight
            self.inputToolbar.buttonOpenFaceGesPanel.setImage(#imageLiteral(resourceName: "faeGestureFilledRed"), for: UIControlState())
        }
        self.textViewUpdateComment.becomeFirstResponder()
    }
    
    func tapOutsideToDismissKeyboard(_ sender: UITapGestureRecognizer) {
        textViewUpdateComment.endEditing(true)
    }
    
    func pickMedia() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        let menu = UIAlertController(title: nil, message: "Choose image", preferredStyle: .actionSheet)
        menu.view.tintColor = UIColor.faeAppRedColor()
        let showLibrary = UIAlertAction(title: "Choose from library", style: .default) { (alert: UIAlertAction) in
            self.actionTakeMedia()
        }
        let showCamera = UIAlertAction(title: "Take photos", style: .default) { (alert: UIAlertAction) in
            imagePicker.sourceType = .camera
            menu.removeFromParentViewController()
            self.present(imagePicker,animated:true,completion:nil)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (alert: UIAlertAction) in
            
        }
        menu.addAction(showLibrary)
        menu.addAction(showCamera)
        menu.addAction(cancel)
        self.present(menu,animated:true,completion: nil)
    }
    
    func actionTakeMedia() {
        let numMediaLeft = 6 - pinMediaImageArray.count
        if numMediaLeft == 0 {
            self.showAlert(title: "Up to 6 pictures can be uploaded at the same time", message: "please try again")
            return
        }
        let nav = UIStoryboard(name: "Chat", bundle: nil).instantiateViewController(withIdentifier: "FullAlbumNavigationController")
        let imagePicker = nav.childViewControllers.first as! FullAlbumCollectionViewController
        imagePicker.imageDelegate = self
        imagePicker._maximumSelectedPhotoNum = numMediaLeft
        self.present(nav, animated: true, completion: {
            UIApplication.shared.statusBarStyle = .default
        })
    }
    
    func deleteMedia(cell: EditPinCollectionViewCell){
        if let indexPath = collectionViewMedia.indexPath(for: cell) {
            print("before mediaIDarray: \(mediaIdArray)")
            pinMediaImageArray.remove(at: indexPath.row-1)
            collectionViewMedia.deleteItems(at: [indexPath])
            mediaIdArray.remove(at: indexPath.row-1)
            checkButtonState()
            print("After mediaIDarray: \(mediaIdArray)")
        }
    }
    
    func loadIndicator() {
        self.textViewUpdateComment.resignFirstResponder() //Doesn't work
        activityIndicator = UIActivityIndicatorView()
        activityIndicator.activityIndicatorViewStyle = .whiteLarge
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = UIColor(red: 149/255, green: 207/255, blue: 246/255, alpha: 1.0)
        self.view.addSubview(activityIndicator)
        activityIndicator.bringSubview(toFront: activityIndicator)
        activityIndicator.startAnimating()
        self.textViewUpdateComment.resignFirstResponder()
    }
    
    private func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.destructive)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func uploadFile(image: UIImage, count: Int, total: Int) {
        let mediaImage = FaeImage()
        mediaImage.type = "image"
        mediaImage.image = image
        mediaImage.faeUploadFile { (status: Int, message: Any?) in
            if status / 100 == 2 {
                print("[uploadFile] Successfully upload Image File")
                let fileIDJSON = JSON(message!)
                if let file_id = fileIDJSON["file_id"].int {
                    print("newID is: \(file_id)")
                    self.mediaIdArray.append(file_id)
                }
                else {
                    print("[uploadFile] Fail to process file_id")
                }
                if count + 1 >= total {
                    self.collectionViewMedia.reloadData()
                    self.activityIndicator.stopAnimating()
                    self.textViewUpdateComment.becomeFirstResponder()
                    return
                }
                self.uploadFile(image: self.newAddedImageArray[count+1],
                                   count: count+1,
                                   total: total)
            } else {
                print("[uploadFile] Fail to upload Image File")
            }
        }
    }
    
    func checkButtonState() {
        let main_string = "Save"
        let string_to_color = "Save"
        let range = (main_string as NSString).range(of: string_to_color)
        if pinMediaImageArray.count < 1 {
            self.buttonSave.isEnabled = false
            let attribute = NSMutableAttributedString.init(string: main_string)
            attribute.addAttributes([NSForegroundColorAttributeName: UIColor.faeAppDisabledRedColor(), NSKernAttributeName: CGFloat(-0.46)], range: range)
            self.buttonSave.setAttributedTitle(attribute, for: .normal)
        }else {
            self.buttonSave.isEnabled = true
            let attribute = NSMutableAttributedString.init(string: main_string)
            attribute.addAttributes([NSForegroundColorAttributeName: UIColor.faeAppRedColor(), NSKernAttributeName: CGFloat(-0.46)], range: range)
            self.buttonSave.setAttributedTitle(attribute, for: .normal)
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView == textViewUpdateComment {
            let spacing = CharacterSet.whitespacesAndNewlines
            print(textViewUpdateComment.text)
            if textViewUpdateComment.text.trimmingCharacters(in: spacing).isEmpty == false {
                buttonSave.isEnabled = true
                labelTextViewPlaceholder.isHidden = true
            }else {
                buttonSave.isEnabled = false
                labelTextViewPlaceholder.isHidden = false
            }
            let numLines = Int(textView.contentSize.height / textView.font!.lineHeight)
            var numlineOnDevice = 3
            if screenWidth == 375 {
                numlineOnDevice = 4
            }
            else if screenWidth == 414 {
                numlineOnDevice = 7
            }
            if numLines <= numlineOnDevice {
                let fixedWidth = textView.frame.size.width
                textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
                let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
                var newFrame = textView.frame
                newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
                textView.frame = newFrame
                textView.isScrollEnabled = false
            }
            else if numLines > numlineOnDevice {
                textView.isScrollEnabled = true
            }
            inputToolbar.numberOfCharactersEntered = max(0,textView.text.characters.count)
        }
        
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        inputToolbar.numberOfCharactersEntered = max(0,textView.text.characters.count)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if textView == textViewUpdateComment {
            if (text == "\n")  {
                textViewUpdateComment.resignFirstResponder()
                return false
            }
            let countChars = textView.text.characters.count + (text.characters.count - range.length)
            return countChars <= 200
        }
        return true
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pinMediaImageArray.count+1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "pinMedia", for: indexPath) as! EditPinCollectionViewCell
        if indexPath.row == 0 {
            cell.media.image = #imageLiteral(resourceName: "AddMoreImage")
            cell.buttonCancel.isHidden = true
        }else {
            cell.media.image = pinMediaImageArray[indexPath.row-1].image
            cell.buttonCancel.isHidden = false
        }
        cell.delegate = self
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! EditPinCollectionViewCell
        if indexPath.row == 0 {
            pickMedia()
        }else {
            let image = cell.media.image
            let photos = IDMPhoto.photos(withImages: [image!])
            let browser = IDMPhotoBrowser(photos: photos)
            self.present(browser!, animated: true, completion: nil)
        }
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        let newAddedImage = UIImageView(frame: CGRect(x: 0, y: 0, width: 95, height: 95))
        newAddedImage.image = image
        self.pinMediaImageArray.append(newAddedImage)
        self.newAddedImageArray.append(image)
        loadIndicator()
        checkButtonState()
        uploadFile(image: newAddedImageArray[0], count: 0, total: 1)
        picker.dismiss(animated: true, completion: nil)
    }
    
    func sendImages(_ images: [UIImage]) {
        newAddedImageArray.removeAll()
        for image in images {
            let newAddedView = UIImageView(frame: CGRect(x: 0, y: 0, width: 95, height: 95))
            newAddedView.image = image
            pinMediaImageArray.append(newAddedView)
            newAddedImageArray.append(image)
        }
        if images.count > 0 {
            loadIndicator()
            uploadFile(image: newAddedImageArray[0], count: 0, total: images.count)
            checkButtonState()
        }
    }
}
