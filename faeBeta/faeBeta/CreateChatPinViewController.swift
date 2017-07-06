//
//  CreateChatPinViewController.swift
//  faeBeta
//
//  Created by YAYUAN SHI on 11/29/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
import Photos

class CreateChatPinViewController: CreatePinBaseViewController, SendMutipleImagesDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    private var uiviewSwitchButtonCont: UIView!
    private var imgSwitchButtonBg: UIImageView!
    private var btnSwitchLeft: UIButton!
    private var btnSwitchRight: UIButton!
    private var imgCreateChatPinImage: UIImageView!
    private var textChatPinName: UITextField!
    private var textviewBubble: CreatePinTextView!

    override func viewDidLoad() {
        pinType = .chat
        super.viewDidLoad()
    }  
    
    //MARK: - setup
    override func setupBaseUI()
    {
        super.setupBaseUI()
        imgTitle.image = #imageLiteral(resourceName: "chatPinTitleImage")
        btnSubmit.backgroundColor = UIColor(red: 194/255.0, green: 229/255.0, blue: 159/255.0, alpha: 0.65)
        switchAnony.onTintColor = UIColor(red: 194/255.0, green: 229/255.0, blue: 159/255.0, alpha: 1)
        
//        self.lblTitle.text = ""
        textviewDescrip.placeHolder = "Add Description..."
        setupMainView()
    }

    fileprivate func setupMainView() {
        func createMainView() {
            uiviewMain = UIView(frame: CGRect(x: 0, y: 150, width: screenWidth, height: 214))
            self.view.addSubview(uiviewMain)
        }
        
        func createSwitchButton() {
            uiviewSwitchButtonCont = UIView(frame: CGRect(x: (screenWidth - 158) / 2, y: 0, width: 158, height: 29))
            uiviewMain.addSubview(uiviewSwitchButtonCont)
            
            imgSwitchButtonBg = UIImageView(frame: CGRect(x: 0, y: 0, width: 158, height: 29))
            imgSwitchButtonBg.image = #imageLiteral(resourceName: "createChatPinSwitch_pin")
            uiviewSwitchButtonCont.addSubview(imgSwitchButtonBg)
            
            btnSwitchLeft = UIButton(frame: CGRect(x: 0, y: 0, width: 79, height: 29))
            btnSwitchLeft.tag = 0
            btnSwitchLeft.addTarget(self, action: #selector(self.switchButtonTapped(_:)), for: .touchUpInside)
            uiviewSwitchButtonCont.addSubview(btnSwitchLeft)
            
            btnSwitchRight = UIButton(frame: CGRect(x: 79, y: 0, width: 79, height: 29))
            btnSwitchRight.tag = 1
            btnSwitchRight.addTarget(self, action: #selector(self.switchButtonTapped(_:)), for: .touchUpInside)
            uiviewSwitchButtonCont.addSubview(btnSwitchRight)
        }
        
        func createChatPinImage() {
            imgCreateChatPinImage = UIImageView(frame: CGRect(x: (screenWidth - 100) / 2, y: 55, width: 100, height: 100))
            imgCreateChatPinImage.image = #imageLiteral(resourceName: "createChatPinImagePlaceHolder")
            imgCreateChatPinImage.layer.cornerRadius = 50
            imgCreateChatPinImage.contentMode = .scaleAspectFill
            uiviewMain.addSubview(imgCreateChatPinImage)

            let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.selectImage(_:)))
            imgCreateChatPinImage.addGestureRecognizer(tapRecognizer)
            imgCreateChatPinImage.isUserInteractionEnabled = true
        }
        
        func createInputTextField() {
            textChatPinName = UITextField(frame: CGRect(x: (screenWidth - 300) / 2, y: 180, width: 300, height: 27))
            textChatPinName.attributedPlaceholder = NSAttributedString(string:            "Chat Pin Name", attributes: [NSForegroundColorAttributeName: UIColor.faeAppTextViewPlaceHolderGrayColor(), NSFontAttributeName: UIFont(name: "AvenirNext-Regular", size: 20)!])

            textChatPinName.backgroundColor = .clear
            textChatPinName.textColor = .white
            textChatPinName.font = UIFont(name: "AvenirNext-Regular", size: 20)
            textChatPinName.textAlignment = .center
            
            uiviewMain.addSubview(textChatPinName)
            textChatPinName.delegate = self
        }
        
        func createInputTextView() {
            textviewBubble = CreatePinTextView(frame: CGRect(x: (screenWidth - 290) / 2, y: 50, width: 290, height: 35), textContainer:nil)
            textviewBubble.placeHolder = "Say Something…"
            uiviewMain.addSubview(textviewBubble)
            textviewBubble.isHidden = true
            textviewBubble.observerDelegate = self
        }
        
        createMainView()
        createSwitchButton()
        createChatPinImage()
        createInputTextField()
        createInputTextView()
    }
    
    func switchButtonTapped(_ sender: UIButton) {
        self.view.endEditing(true)
        if isShowingEmoji {
            isShowingEmoji = false
            hideEmojiViewAnimated(animated: true)
        }
        
        if sender.tag == 0 {
            self.imgSwitchButtonBg.image = #imageLiteral(resourceName: "createChatPinSwitch_pin")
            optionViewMode = .pin
            self.tblPinOptions.frame = CGRect(x: 0, y: screenHeight - CreatePinOptionsTableView.cellHeight * 3 - CGFloat(120), width: screenWidth, height: CreatePinOptionsTableView.cellHeight * 3)
            self.tblPinOptions.reloadData()
            
            self.imgCreateChatPinImage.isHidden = false
            self.textChatPinName.isHidden = false
            self.textviewBubble.isHidden = true
        } else {
            self.imgSwitchButtonBg.image = #imageLiteral(resourceName: "createChatPinSwitch_bubble")
            optionViewMode = .bubble
            
            self.tblPinOptions.reloadData()
            self.tblPinOptions.frame = CGRect(x: 0, y: screenHeight - CreatePinOptionsTableView.cellHeight * 2 - CGFloat(120), width: screenWidth, height: CreatePinOptionsTableView.cellHeight * 2)
            
            self.imgCreateChatPinImage.isHidden = true
            self.textChatPinName.isHidden = true
            self.textviewBubble.isHidden = false
        }
    }
    
    func selectImage(_ sender: UITapGestureRecognizer) {
//        let alertC = FAEAlertController(title: "Action", message: nil, preferredStyle: .actionSheet)
        self.view.endEditing(true)
        if isShowingEmoji {
            isShowingEmoji = false
            hideEmojiViewAnimated(animated: true)
        }
        
        let alertMenu = UIAlertController(title: nil, message: "Action", preferredStyle: .actionSheet)
        alertMenu.view.tintColor = UIColor.faeAppRedColor()
        let showCamera = UIAlertAction(title: "Camera", style: .destructive) { (_: UIAlertAction) in
            self.checkCameraAccessStatus()
        }
        let showLibrary = UIAlertAction(title: "Albums", style: .destructive) { (_: UIAlertAction) in
            self.checkLibraryAccessStatus()
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        alertMenu.addAction(showCamera)
        alertMenu.addAction(showLibrary)
        alertMenu.addAction(cancel)
        
        self.present(alertMenu, animated: true, completion: nil)
    }
    
    override func switchToDescription() {
        super.switchToDescription()
        
        UIView.animate(withDuration: 0.3, animations: {
            Void in
            self.uiviewMain.alpha = 0
            self.tblPinOptions.alpha = 0
            self.textviewDescrip.alpha = 1
            self.lblTitle.text = "Add Description"
            self.setSubmitButton(withTitle: "Back", isEnabled: true)
        }, completion:{
            Complete in
            self.textviewDescrip.becomeFirstResponder()
        })
    }
    
    override func leaveDescription() {
        super.leaveDescription()
        if self.textviewDescrip != nil {
            self.textviewDescrip.resignFirstResponder()
        }
        
        UIView.animate(withDuration: 0.3, animations: {
            Void in
            self.uiviewMain.alpha = 1
            self.tblPinOptions.alpha = 1
            self.tblPinOptions.reloadData()
            if self.textviewDescrip != nil {
                self.textviewDescrip.alpha = 0
            }
            self.lblTitle.text = ""
            self.setSubmitButton(withTitle: "Submit!", isEnabled: self.boolBtnSubmitEnabled)
        }, completion:{
            Complete in
            self.textviewDescrip.resignFirstResponder()
        })
    }
    
    override func switchToMoreOptions() {
        super.switchToMoreOptions()
        UIView.animate(withDuration: 0.4, animations: {
            Void in
            self.uiviewMain.alpha = 0
            self.tblPinOptions.alpha = 0
            self.tblMoreOptions.alpha = 1
            self.lblTitle.text = "More Options"
            self.setSubmitButton(withTitle: "Back", isEnabled: true)
        })
    }
    
    override func leaveMoreOptions() {
        super.leaveMoreOptions()
        UIView.animate(withDuration: 0.4, animations: {
            Void in
            self.uiviewMain.alpha = 1
            self.tblPinOptions.alpha = 1
            self.tblMoreOptions.alpha = 0
            
            self.lblTitle.text = ""
            self.setSubmitButton(withTitle: "Submit!", isEnabled: self.boolBtnSubmitEnabled)
        }, completion:{
            Complete in
        })
    }
    
    override func switchToAddTags() {
        super.switchToAddTags()
        if (textviewAddTags == nil) {
            textviewAddTags = CreatePinAddTagsTextView(frame: CGRect(x: (screenWidth - 290) / 2, y: 195, width: 290, height: 35), textContainer: nil)
            textviewAddTags.placeHolder = "Add Tags to promote your pin in searches..."
            textviewAddTags.observerDelegate = self
            self.view.addSubview(textviewAddTags)
        }
        textviewAddTags.alpha = 0
        inputToolbar.mode = .tag
        UIView.animate(withDuration: 0.3, animations: {
            Void in
            self.tblMoreOptions.alpha = 0
            self.lblTitle.text = "Add Tags"
            self.textviewAddTags.alpha = 1
        }, completion:{
            Complete in
        })
    }
    
    override func leaveAddTags() {
        super.leaveAddTags()
        strTags = "Add Tags"
        if(textviewAddTags != nil && textviewAddTags.tagNames.count != 0){
            strTags = ""
            for tag in textviewAddTags.tagNames{
                strTags.append("\(tag), ")
            }
            strTags = strTags.substring(to: strTags.characters.index(strTags.endIndex, offsetBy: -2))
            
            textviewAddTags.resignFirstResponder()
        }
//        if textviewAddTags != nil {
//            textviewAddTags.resignFirstResponder()
//        }
        self.tblMoreOptions.reloadData()
        UIView.animate(withDuration: 0.3, animations: {
            Void in
            self.tblMoreOptions.alpha = 1
            self.lblTitle.text = "More Options"
            self.textviewAddTags.alpha = 0
        }, completion:{
            Complete in
            self.inputToolbar.mode = .emoji
        })
    }
    
    /// This is a method to set the image for imgCreateChatPinImage
    ///
    /// - Parameter image: the image for imgCreateChatPinImage, if nil, then use default image(the placeholder)
    private func setPinImageView(withImage image:UIImage?) {
        if let image = image {
            imgCreateChatPinImage.image = image
            imgCreateChatPinImage.layer.borderWidth = 3
            imgCreateChatPinImage.layer.borderColor = UIColor.white.cgColor
            imgCreateChatPinImage.layer.masksToBounds = true
        }
        else{
            imgCreateChatPinImage.image = #imageLiteral(resourceName: "createChatPinImagePlaceHolder")
            imgCreateChatPinImage.layer.borderWidth = 0
            imgCreateChatPinImage.layer.masksToBounds = false
        }
        updateSubmitButton()
    }
    
    fileprivate func updateSubmitButton() {
        boolBtnSubmitEnabled = imgCreateChatPinImage.image != #imageLiteral(resourceName: "createChatPinImagePlaceHolder") && (textChatPinName.text?.characters.count)! > 0
        setSubmitButton(withTitle: "Submit!", isEnabled : boolBtnSubmitEnabled)
    }
    
    override func actionSubmit() {
        UIScreenService.showActivityIndicator()
        let postSingleChatPin = FaeMap()
        
        var submitLatitude = selectedLatitude
        var submitLongitude = selectedLongitude
        
        if strSelectedLocation == nil || strSelectedLocation == "" {
            let defaultLoc = randomLocation()
            submitLatitude = "\(defaultLoc.latitude)"
            submitLongitude = "\(defaultLoc.longitude)"
        }
        
        postSingleChatPin.whereKey("geo_latitude", value: submitLatitude)
        postSingleChatPin.whereKey("geo_longitude", value: submitLongitude)
        
        if textviewDescrip != nil && textviewDescrip.text! != ""{
            let des = textviewDescrip.text
            postSingleChatPin.whereKey("description", value: des)
        }
        postSingleChatPin.whereKey("interaction_radius", value: "99999999")
        postSingleChatPin.whereKey("duration", value: "1440")
        postSingleChatPin.whereKey("title", value: textChatPinName.text!)
        
        TagCreator.uploadTags(textviewAddTags != nil ? textviewAddTags.tagNames : [], completion: { (tagNames) in
            var tagIdString = ""
            for tag in tagNames{
                tagIdString = tagIdString == "" ? tag.stringValue : "\(tagIdString);\(tag.stringValue)"
            }
            if tagIdString != ""{
                postSingleChatPin.whereKey("tag_ids", value: tagIdString)
            }
            
            postSingleChatPin.postPin(type: "chat_room") {(status: Int, message: Any?) in
                if let getMessage = message as? NSDictionary{
                    if let getMessageID = getMessage["chat_room_id"] {
                        let getJustPostedChatPin = FaeMap()
                        getJustPostedChatPin.getPin(type: "chat_room", pinId: "\(getMessageID)"){(status: Int, message: Any?) in
                            
                            //upload cover image
                            self.uploadChatRoomCoverImage(chatRoomId: getMessageID as! NSNumber, image: self.imgCreateChatPinImage.image!)
                            
                            let latDouble = Double(submitLatitude!)
                            let longDouble = Double(submitLongitude!)
                            let lat = CLLocationDegrees(latDouble!)
                            let long = CLLocationDegrees(longDouble!)
                            UIScreenService.hideActivityIndicator()
                            self.dismiss(animated: false, completion: {
                                self.delegate?.sendGeoInfo(pinID: "\(getMessageID)", type: "chat_room", latitude: lat, longitude: long, zoom: self.zoomLevelCallBack)
                            })
                        }
                    }
                    else {
                        print("Cannot get comment_id of this posted comment")
                    }
                }
                else {
                    print("Post Comment Fail")
                }
            }
        })
    }
    
    func uploadChatRoomCoverImage(chatRoomId: NSNumber, image: UIImage){
        let imageData = compressImage(image,max_image_bytes: 1024)
        postChatRoomCoverImageToURL("files/chat_rooms/cover_image", parameter: ["chat_room_id": chatRoomId, "cover_image" : imageData as AnyObject], authentication: headerAuthentication(), completion: { (status:Int, message:Any?) in
            
        })
    }
    
    //MARK: - SendMutipleImagesDelegate
    func sendImages(_ images: [UIImage]) {
        assert(images.count == 1, "The number of image in the array should be exactly one!")
        for image in images {
            setPinImageView(withImage: image)
        }
    }
    
    func sendVideoData(_ video: Data, snapImage: UIImage, duration: Int) {
        print("Debug sendVideo")
    }
    
    //MARK: -  UIImagePickerController
    // handle events after user took a photo/video
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    }
    
    //MARK: - text field delegate
    override func textFieldDidBeginEditing(_ textField: UITextField) {
        super.textFieldDidBeginEditing(textField)
        if textField == textChatPinName {
            inputToolbar.countCharsLabelHidden = true
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == textChatPinName {
            updateSubmitButton()
        }
    }
    
    //MARK: - add tags related
    override func inputToolbarEmojiButtonTapped(inputToolbar: CreatePinInputToolbar) {
        if !(prevFirstResponder is CreatePinAddTagsTextView){
            super.inputToolbarEmojiButtonTapped(inputToolbar: inputToolbar)
        }else{
            textviewAddTags.addLastInputTag()
        }
    }
    
    
    // MARK: - select photos from camera / library as image
    fileprivate func checkLibraryAccessStatus() {
        let photoStatus = PHPhotoLibrary.authorizationStatus()
        switch photoStatus {
        case .authorized:
            let nav = UIStoryboard(name: "Chat", bundle: nil).instantiateViewController(withIdentifier: "FullAlbumNavigationController")
            let imagePicker = nav.childViewControllers.first as! FullAlbumCollectionViewController
            imagePicker.imageDelegate = self
            imagePicker.isSelectAvatar = true
            imagePicker._maximumSelectedPhotoNum = 1
            self.present(nav, animated: true, completion: {
                UIApplication.shared.statusBarStyle = .default
            })
        case .denied:
            self.alertToEncourageAccess("library")
            return
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization({ _ in
                self.checkLibraryAccessStatus()
            })
            return
        case .restricted:
            self.showAlert(title: "Photo library not allowed", message: "You're not allowed to access photo library")
            return
        }
    }
    
    fileprivate func checkCameraAccessStatus() {
        let cameraStatus = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
        switch cameraStatus {
        case .authorized:
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            self.present(imagePicker, animated: true, completion: nil)
        case .denied:
            self.alertToEncourageAccess("camera")
            return
        case .notDetermined:
            if AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo).count > 0 {
                AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo) { _ in
                    DispatchQueue.main.async() {
                        self.checkCameraAccessStatus()
                    }
                }
            }
            return
        case .restricted:
            self.showAlert(title: "Camera not allowed", message: "You're not allowed to capture camera devices")
            return
        }
    }
    
    // MARK: - CAMERA & GALLERY NOT ALLOWING ACCESS - ALERT
    fileprivate func alertToEncourageAccess(_ accessType: String) {
        // Camera or photo library not available - Alert
        var title: String!
        var message: String!
        if accessType == "camera" {
            title = "Cannot access camera"
            message = "Open System Settings -> Fae Map to turn on the camera access"
        } else {
            title = "Cannot access photo library"
            message = "Open System Settings -> Fae Map to turn on the photo library access"
        }
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let settingsAction = UIAlertAction(title: "Settings", style: .destructive) { (_) -> Void in
            let settingsUrl = NSURL(string: UIApplicationOpenSettingsURLString)
            if let url = settingsUrl {
                if accessType == "camera" {
                    DispatchQueue.main.async {
                        UIApplication.shared.openURL(url as URL)
                    }
                } else {
                    UIApplication.shared.openURL(url as URL)
                    // UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
                }
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        alertController.addAction(settingsAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
}
