//
//  CreateChatPinViewController.swift
//  faeBeta
//
//  Created by YAYUAN SHI on 11/29/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

class CreateChatPinViewController: CreatePinBaseViewController, SelectLocationViewControllerDelegate, SendMutipleImagesDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    //MARK: - properties
    private var createChatPinMainView: UIView!// this view contains the switch button, the round "add cover image" imageView, and the pin name textField
    private var switchButtonContentView: UIView!
    private var switchButtonBackgroundImageView: UIImageView!
    private var switchButtonLeft: UIButton!
    private var switchButtonRight: UIButton!
    private var createChatPinImageImageView: UIImageView!
    private var createChatPinImageButton: UIButton!
    private var createChatPinTextField: UITextField!
    private var createChatPinOptionsTableView: CreatePinOptionsTableView!
    private var bubbleTextView: CreatePinTextView!
    var descriptionTextView: CreatePinTextView!
    var addTagsTextView: CreatePinAddTagsTextView!
    private var moreOptionsTableView: CreatePinOptionsTableView!
    var labelSelectLocationContent: String!
    private var submitButtonEnabled: Bool = false
    var currentLocation2D = CLLocationCoordinate2DMake(34.0205378, -118.2854081)
    var zoomLevel: Float = 13.8
    var zoomLevelCallBack: Float = 13.8
    
    enum OptionViewMode{
        case pin
        case bubble
        case more
    }
    
    var optionViewMode: OptionViewMode = .pin
    
    //MARK: - life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBasicUI()
        setupCreateChatPinMainView()
        setupcreateChatPinOptionsTableView()
        self.view.alpha = 0.0
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
            self.view.alpha = 1.0
        }, completion: nil)
    }
    
    //MARK: - setup
    private func setupBasicUI()
    {
        self.titleImageView.image = #imageLiteral(resourceName: "chatPinTitleImage")
        self.titleLabel.text = ""
        setSubmitButton(withTitle: "Submit!", backgroundColor: UIColor(red: 194/255.0, green: 229/255.0, blue: 159/255.0, alpha: 1), isEnabled : false)
    }

    private func setupCreateChatPinMainView() {
        func createMainView() {
            createChatPinMainView = UIView(frame: CGRect(x: 0, y: 148, width: screenWidth, height: 225))
            self.view.addSubview(createChatPinMainView)
            self.view.addConstraintsWithFormat("V:[v0]-20-[v1(225)]", options: [], views: titleImageView, createChatPinMainView)
            self.view.addConstraintsWithFormat("H:|-0-[v0]-0-|", options: [], views: createChatPinMainView)
        }
        
        func createSwitchButton() {
            switchButtonContentView = UIView(frame: CGRect(x: 0, y: 0, width: 158, height: 29))
            createChatPinMainView.addSubview(switchButtonContentView)
            createChatPinMainView.addConstraintsWithFormat("V:|-0-[v0(29)]", options: [], views: switchButtonContentView)
            createChatPinMainView.addConstraintsWithFormat("H:[v0(158)]", options: [], views: switchButtonContentView)
            NSLayoutConstraint(item: switchButtonContentView, attribute: .centerX, relatedBy: .equal, toItem: createChatPinMainView, attribute: .centerX, multiplier: 1.0, constant: 0).isActive = true
            
            
            switchButtonBackgroundImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 158, height: 29))
            switchButtonBackgroundImageView.image = #imageLiteral(resourceName: "createChatPinSwitch_pin")
            switchButtonContentView.addSubview(switchButtonBackgroundImageView)
            switchButtonContentView.addConstraintsWithFormat("V:|-0-[v0]-0-|", options: [], views: switchButtonBackgroundImageView)
            switchButtonContentView.addConstraintsWithFormat("H:|-0-[v0]-0-|", options: [], views: switchButtonBackgroundImageView)
            
            switchButtonLeft = UIButton(frame: CGRect(x: 0, y: 0, width: 79, height: 29))
            switchButtonLeft.addTarget(self, action: #selector(self.switchButtonLeftTapped(_:)), for: .touchUpInside)
            switchButtonContentView.addSubview(switchButtonLeft)
            switchButtonContentView.bringSubview(toFront: switchButtonLeft)
            
            switchButtonRight = UIButton(frame: CGRect(x: 79, y: 0, width: 79, height: 29))
            switchButtonRight.addTarget(self, action: #selector(self.switchButtonRightTapped(_:)), for: .touchUpInside)
            switchButtonContentView.addSubview(switchButtonRight)
            switchButtonContentView.bringSubview(toFront: switchButtonRight)
            
            switchButtonContentView.addConstraintsWithFormat("H:|-0-[v0(79)]-0-[v1(79)]-0-|", options: [], views: switchButtonLeft, switchButtonRight)
            
            switchButtonContentView.addConstraintsWithFormat("V:|-0-[v0(29)]-0-|", options: [], views: switchButtonLeft)
            switchButtonContentView.addConstraintsWithFormat("V:|-0-[v0(29)]-0-|", options: [], views: switchButtonRight)
        }
        
        func createImagePlaceHolder() {
            
            createChatPinImageImageView = UIImageView(image: #imageLiteral(resourceName: "createChatPinImagePlaceHolder"))
            createChatPinImageImageView.layer.cornerRadius = 50
            createChatPinImageImageView.contentMode = .scaleAspectFill
            createChatPinMainView.addSubview(createChatPinImageImageView)
            createChatPinImageImageView.frame = CGRect(x: (screenWidth - 100) / 2, y: 60, width: 100, height: 100)
//            createChatPinMainView.addConstraintsWithFormat("V:[v0]-30-[v1(100)]", options: [], views: switchButtonContentView, createChatPinImageImageView)
//            createChatPinMainView.addConstraintsWithFormat("H:[v0(100)]", options: [], views: createChatPinMainView)
//            NSLayoutConstraint(item: createChatPinImageImageView, attribute: .centerX, relatedBy: .equal, toItem: createChatPinMainView, attribute: .centerX, multiplier: 1.0, constant: 0).isActive = true
            
            createChatPinImageButton = UIButton()
            createChatPinMainView.addSubview(createChatPinImageButton)
            createChatPinImageButton.addTarget(self, action: #selector(self.createChatPinImageButtonTapped(_:)), for: .touchUpInside)
            createChatPinMainView.addConstraintsWithFormat("V:[v0]-30-[v1(100)]", options: [], views: switchButtonContentView, createChatPinImageButton)
            createChatPinMainView.addConstraintsWithFormat("H:[v0(100)]", options: [], views: createChatPinImageButton)
            NSLayoutConstraint(item: createChatPinImageButton, attribute: .centerX, relatedBy: .equal, toItem: createChatPinMainView, attribute: .centerX, multiplier: 1.0, constant: 0).isActive = true
        }
        
        func createInputTextField() {
            createChatPinTextField = UITextField()
            createChatPinTextField.attributedPlaceholder = NSAttributedString(string:            "Chat Pin Name", attributes: [NSForegroundColorAttributeName: UIColor.faeAppTextViewPlaceHolderGrayColor(), NSFontAttributeName: UIFont(name: "AvenirNext-Regular", size: 20)!])

            createChatPinTextField.backgroundColor = UIColor.clear
            createChatPinTextField.textColor = UIColor.white
            createChatPinTextField.font = UIFont(name: "AvenirNext-Regular", size: 20)
            createChatPinTextField.textAlignment = .center
            
            
            createChatPinMainView.addSubview(createChatPinTextField)
            createChatPinMainView.addConstraintsWithFormat("V:[v0]-30-[v1(27)]", options: [], views: createChatPinImageButton, createChatPinTextField)
            createChatPinMainView.addConstraintsWithFormat("H:[v0(300)]", options: [], views: createChatPinTextField)
            NSLayoutConstraint(item: createChatPinTextField, attribute: .centerX, relatedBy: .equal, toItem: createChatPinMainView, attribute: .centerX, multiplier: 1.0, constant: 0).isActive = true
            createChatPinTextField.delegate = self
        }
        
        func createInputTextView() {
            bubbleTextView = CreatePinTextView(frame: CGRect(x: (screenWidth - 290) / 2, y: 50, width: 290, height: 35), textContainer:nil)
            bubbleTextView.placeHolder = "Say Something…"
            createChatPinMainView.addSubview(bubbleTextView)
            bubbleTextView.alpha = 0
            bubbleTextView.observerDelegate = self
        }
        
        createMainView()
        createSwitchButton()
        createImagePlaceHolder()
        createInputTextField()
        createInputTextView()
    }
    
    private func setupcreateChatPinOptionsTableView() {
        createChatPinOptionsTableView = CreatePinOptionsTableView(frame: CGRect(x: 0, y: screenHeight - CreatePinOptionsTableView.cellHeight * 3 - CGFloat(120), width: screenWidth, height: CreatePinOptionsTableView.cellHeight * 3))
        
        self.view.addSubview(createChatPinOptionsTableView)
        createChatPinOptionsTableView.delegate = self
        createChatPinOptionsTableView.dataSource = self
    }
    
    //MARK: - button actions
    override func submitButtonTapped(_ sender: UIButton) {
        if optionViewMode == .more {
            switch currentViewingContent! {
            case .description:
                leaveDescription()
                break
            case .moreOptionsTable:
                leaveMoreOptions()
                break
            case .addTags:
                leaveAddTags()
                break
            }
        }
        // create a pin
        else if optionViewMode == .pin {
            createChatPin()
        }
    }
    
    @objc private func switchButtonLeftTapped(_ sender: UIButton) {
        self.view.endEditing(true)
        self.switchButtonBackgroundImageView.image = #imageLiteral(resourceName: "createChatPinSwitch_pin")
        optionViewMode = .pin
        
        self.createChatPinImageImageView.alpha = 1
        self.createChatPinImageButton.alpha = 1
        self.createChatPinTextField.alpha = 1
        self.createChatPinOptionsTableView.frame = CGRect(x: 0, y: screenHeight - CreatePinOptionsTableView.cellHeight * 3 - CGFloat(120), width: screenWidth, height: CreatePinOptionsTableView.cellHeight * 3)
        self.createChatPinOptionsTableView.reloadData()
        self.bubbleTextView.alpha = 0
    }
    
    @objc private func switchButtonRightTapped(_ sender: UIButton) {
        self.view.endEditing(true)
        self.switchButtonBackgroundImageView.image = #imageLiteral(resourceName: "createChatPinSwitch_bubble")
        optionViewMode = .bubble

        self.createChatPinImageImageView.alpha = 0
        self.createChatPinImageButton.alpha = 0
        self.createChatPinTextField.alpha = 0
        self.createChatPinOptionsTableView.reloadData()
        self.createChatPinOptionsTableView.frame = CGRect(x: 0, y: screenHeight - CreatePinOptionsTableView.cellHeight * 2 - CGFloat(120), width: screenWidth, height: CreatePinOptionsTableView.cellHeight * 2)
        self.bubbleTextView.alpha = 1
    }
    
    @objc private func createChatPinImageButtonTapped(_ sender: UIButton) {
        let alertC = FAEAlertController(title: "Action", message: nil, preferredStyle: .actionSheet)
        var action = UIAlertAction(title: "Camera", style: .default, handler: {
            Action in
                self.showCamera()
            }
        )
        alertC.addAction(action)

        action = UIAlertAction(title: "Albums", style: .default, handler: {
            Action in
                self.actionSelectMedia()
            }
        )
        alertC.addAction(action)

        action = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            Action in
            
            }
        )
        alertC.addAction(action)
        
        self.present(alertC, animated: true, completion: nil)
    }
    
    func actionSelectLocation() {
        let selectLocationVC = SelectLocationViewController()
        selectLocationVC.modalPresentationStyle = .overCurrentContext
        selectLocationVC.delegate = self
        selectLocationVC.pinType = "chat"
        selectLocationVC.currentLocation2D = self.currentLocation2D
        selectLocationVC.zoomLevel = self.zoomLevel
        self.present(selectLocationVC, animated: false, completion: nil)
    }
    
    func actionSelectMedia() {
        let nav = UIStoryboard(name: "Chat", bundle: nil).instantiateViewController(withIdentifier: "FullAlbumNavigationController")
        let imagePicker = nav.childViewControllers.first as! FullAlbumCollectionViewController
        imagePicker.imageDelegate = self
        imagePicker.maximumSelectedPhotoNum = 1
        self.present(nav, animated: true, completion: nil)
    }
    
    func showCamera() {
        view.endEditing(true)
        let camera = Camera(delegate_: self)
        camera.presentPhotoCamera(self, canEdit: false)
    }
    
    // MARK: - helper
    
    func randomLocation() -> CLLocationCoordinate2D {
        let lat = currentLocation2D.latitude
        let lon = currentLocation2D.longitude
        let random_lat = Double.random(min: -0.01, max: 0.01)
        let random_lon = Double.random(min: -0.01, max: 0.01)
        return CLLocationCoordinate2DMake(lat+random_lat, lon+random_lon)
    }
    
    func switchToDescription() {
        self.currentViewingContent = .description
        if descriptionTextView == nil {
            descriptionTextView = CreatePinTextView(frame: CGRect(x: (screenWidth - 290) / 2, y: 195, width: 290, height: 35), textContainer: nil)
            descriptionTextView.placeHolder = "Add Description..."
            descriptionTextView.observerDelegate = self
            self.view.addSubview(descriptionTextView)
        }
        descriptionTextView.alpha = 0
        optionViewMode = .more
        
        UIView.animate(withDuration: 0.3, animations: {
            Void in
            self.createChatPinMainView.alpha = 0
            self.createChatPinOptionsTableView.alpha = 0
            self.descriptionTextView.alpha = 1
            self.titleLabel.text = "Add Description"
            self.setSubmitButton(withTitle: "Back", backgroundColor: UIColor(red: 194/255.0, green: 229/255.0, blue: 159/255.0, alpha: 1), isEnabled: true)
        }, completion:{
            Complete in
            self.descriptionTextView.becomeFirstResponder()
        })
    }
    
    func leaveDescription() {
        optionViewMode = .pin

        if self.descriptionTextView != nil {
            self.descriptionTextView.resignFirstResponder()
        }
        
        UIView.animate(withDuration: 0.3, animations: {
            Void in
            self.createChatPinMainView.alpha = 1
            self.createChatPinOptionsTableView.alpha = 1
            self.createChatPinOptionsTableView.reloadData()
            if self.descriptionTextView != nil {
                self.descriptionTextView.alpha = 0
            }
            self.titleLabel.text = ""
            self.setSubmitButton(withTitle: "Submit!", backgroundColor: UIColor(red: 194/255.0, green: 229/255.0, blue: 159/255.0, alpha: 1), isEnabled: self.submitButtonEnabled)
        }, completion:{
            Complete in
        })
    }
    
    func switchToMoreOptions() {
        self.currentViewingContent = .moreOptionsTable
        optionViewMode = .more
        if moreOptionsTableView == nil {
            moreOptionsTableView = CreatePinOptionsTableView(frame: CGRect(x: 0, y: 195, width: screenWidth, height: CreatePinOptionsTableView.cellHeight * 5))
            moreOptionsTableView.delegate = self
            moreOptionsTableView.dataSource = self
            self.view.addSubview(moreOptionsTableView)
        }
        moreOptionsTableView.alpha = 0
        UIView.animate(withDuration: 0.3, animations: {
            Void in
            self.createChatPinMainView.alpha = 0
            self.createChatPinOptionsTableView.alpha = 0
            self.moreOptionsTableView.alpha = 1
            self.titleLabel.text = "More Options"
            self.setSubmitButton(withTitle: "Back", backgroundColor: UIColor(red: 194/255.0, green: 229/255.0, blue: 159/255.0, alpha: 1), isEnabled: true)
        }, completion:{
            Complete in
        })
    }
    
    func leaveMoreOptions() {
        optionViewMode = .pin
        
        UIView.animate(withDuration: 0.3, animations: {
            Void in
            self.createChatPinMainView.alpha = 1
            self.createChatPinOptionsTableView.alpha = 1
            self.createChatPinOptionsTableView.reloadData()

            if self.moreOptionsTableView != nil{
                self.moreOptionsTableView.alpha = 0
            }
            
            self.titleLabel.text = ""
            self.setSubmitButton(withTitle: "Submit!", backgroundColor: UIColor(red: 194/255.0, green: 229/255.0, blue: 159/255.0, alpha: 1), isEnabled: self.submitButtonEnabled)
        }, completion:{
            Complete in
        })
    }
    
    func swtichToAddTags() {
        self.currentViewingContent = .addTags
        if (addTagsTextView == nil) {
            addTagsTextView = CreatePinAddTagsTextView(frame: CGRect(x: (screenWidth - 290) / 2, y: 195, width: 290, height: 35), textContainer: nil)
            addTagsTextView.placeHolder = "Add Tags to promote your pin in searches..."
            addTagsTextView.observerDelegate = self
            self.view.addSubview(addTagsTextView)
        }
        addTagsTextView.alpha = 0
        inputToolbar.mode = .tag
        UIView.animate(withDuration: 0.3, animations: {
            Void in
            self.moreOptionsTableView.alpha = 0
            self.titleLabel.text = "Add Tags"
            self.addTagsTextView.alpha = 1
        }, completion:{
            Complete in
        })
    }
    
    func leaveAddTags() {
        self.currentViewingContent = .moreOptionsTable
        if addTagsTextView != nil {
            addTagsTextView.resignFirstResponder()
        }
        self.moreOptionsTableView.reloadData()
        UIView.animate(withDuration: 0.3, animations: {
            Void in
            self.moreOptionsTableView.alpha = 1
            self.titleLabel.text = "More Options"
            self.addTagsTextView.alpha = 0
        }, completion:{
            Complete in
            self.inputToolbar.mode = .emoji
        })
    }
    
    /// This is a method to set the image for createChatPinImageImageView
    ///
    /// - Parameter image: the image for createChatPinImageImageView, if nil, then use default image(the placeholder)
    private func setPinImageView(withImage image:UIImage?) {
        if let image = image {
            createChatPinImageImageView.image = image
            createChatPinImageImageView.layer.borderWidth = 3
            createChatPinImageImageView.layer.borderColor = UIColor.white.cgColor
            createChatPinImageImageView.layer.masksToBounds = true
        }
        else{
            createChatPinImageImageView.image = #imageLiteral(resourceName: "createChatPinImagePlaceHolder")
            createChatPinImageImageView.layer.borderWidth = 0
            createChatPinImageImageView.layer.masksToBounds = false
        }
        updateSubmitButton()
    }
    
    func updateSubmitButton() {
        submitButtonEnabled = createChatPinImageImageView.image != #imageLiteral(resourceName: "createChatPinImagePlaceHolder") && (createChatPinTextField.text?.characters.count)! > 0
        setSubmitButton(withTitle: "Submit!", backgroundColor: UIColor(red: 194/255.0, green: 229/255.0, blue: 159/255.0, alpha: 1), isEnabled : submitButtonEnabled)
    }
    
    func createChatPin() {
        UIScreenService.showActivityIndicator()
        let postSingleChatPin = FaeMap()
        
        var submitLatitude = selectedLatitude
        var submitLongitude = selectedLongitude
        
        if labelSelectLocationContent == nil || labelSelectLocationContent == "" {
            submitLatitude = "\(currentLocation.coordinate.latitude)"
            submitLongitude = "\(currentLocation.coordinate.longitude)"
        }
        
        postSingleChatPin.whereKey("geo_latitude", value: submitLatitude)
        postSingleChatPin.whereKey("geo_longitude", value: submitLongitude)
        
        if descriptionTextView != nil && descriptionTextView.text! != ""{
            let des = descriptionTextView.text
            postSingleChatPin.whereKey("description", value: des)
        }
        postSingleChatPin.whereKey("interaction_radius", value: "99999999")
        postSingleChatPin.whereKey("duration", value: "1440")
        postSingleChatPin.whereKey("title", value: createChatPinTextField.text!)
        
        TagCreator.uploadTags(addTagsTextView != nil ? addTagsTextView.tagNames : [], completion: { (tagNames) in
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
                            self.uploadChatRoomCoverImage(chatRoomId: getMessageID as! NSNumber, image: self.createChatPinImageImageView.image!)
                            
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
    
    //MARK: - SelectLocationViewControllerDelegate
    func sendAddress(_ value: String) {
        labelSelectLocationContent = value
        createChatPinOptionsTableView.reloadData()
    }
    
    func sendGeoInfo(_ latitude: String, longitude: String, zoom: Float) {
        selectedLatitude = latitude
        selectedLongitude = longitude
        createChatPinOptionsTableView.reloadData()
        zoomLevelCallBack = zoom
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
        if textField == createChatPinTextField {
            inputToolbar.countCharsLabelHidden = true
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == createChatPinTextField {
            updateSubmitButton()
        }
    }
    
    //MARK: - add tags related
    override func inputToolbarEmojiButtonTapped(inputToolbar: CreatePinInputToolbar) {
        if !(previousFirstResponder is CreatePinAddTagsTextView){
            super.inputToolbarEmojiButtonTapped(inputToolbar: inputToolbar)
        }else{
            addTagsTextView.addLastInputTag()
        }
    }
    
}
