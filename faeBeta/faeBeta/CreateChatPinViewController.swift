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
    private var createChatPinMainView: UIView!
    private var switchButtonContentView: UIView!
    private var switchButtonBackgroundImageView: UIImageView!
    private var switchButtonLeft: UIButton!
    private var switchButtonRight: UIButton!
    
    private var createChatPinImageImageView: UIImageView!
    private var createChatPinImageButton: UIButton!
    
    private var createChatPinTextField: UITextField!
    
    private var createChatPinOptionsTableView: CreatePinOptionsTableView!
    
    private var bubbleTextView: CreatePinTextView!
    
    private var descriptionTextView: CreatePinTextView!
    private var moreOptionsTableView: CreatePinOptionsTableView!
    
    //pin location
    private var selectedLatitude: String!
    private var selectedLongitude: String!
    var labelSelectLocationContent: String!
    
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
        // Do any additional setup after loading the view.
    }
    
    //MARK: - setup
    private func setupBasicUI()
    {
        self.titleImageView.image = #imageLiteral(resourceName: "chatPinTitleImage")
        self.titleLabel.text = ""
        setSubmitButton(withTitle: "Submit!", backgroundColor: UIColor(red: 194/255.0, green: 229/255.0, blue: 159/255.0, alpha: 0.65))
    }

    private func setupCreateChatPinMainView()
    {
        func createMainView()
        {
            createChatPinMainView = UIView(frame: CGRect(x: 0, y: 148, width: screenWidth, height: 225))
            self.view.addSubview(createChatPinMainView)
            self.view.addConstraintsWithFormat("V:[v0]-20-[v1(225)]", options: [], views: titleImageView, createChatPinMainView)
            self.view.addConstraintsWithFormat("H:|-0-[v0]-0-|", options: [], views: createChatPinMainView)
        }
        
        func createSwitchButton()
        {
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
        
        func createImagePlaceHolder()
        {
            
            createChatPinImageImageView = UIImageView(image: #imageLiteral(resourceName: "createChatPinImagePlaceHolder"))
            createChatPinImageImageView.contentMode = .scaleToFill
            createChatPinMainView.addSubview(createChatPinImageImageView)
            createChatPinMainView.addConstraintsWithFormat("V:[v0]-30-[v1(100)]", options: [], views: switchButtonContentView, createChatPinImageImageView)
            createChatPinMainView.addConstraintsWithFormat("H:[v0(100)]", options: [], views: createChatPinMainView)
            NSLayoutConstraint(item: createChatPinImageImageView, attribute: .centerX, relatedBy: .equal, toItem: createChatPinMainView, attribute: .centerX, multiplier: 1.0, constant: 0).isActive = true
            
            createChatPinImageButton = UIButton()
            createChatPinMainView.addSubview(createChatPinImageButton)
            createChatPinImageButton.addTarget(self, action: #selector(self.createChatPinImageButtonTapped(_:)), for: .touchUpInside)
            createChatPinMainView.addConstraintsWithFormat("V:[v0]-30-[v1(100)]", options: [], views: switchButtonContentView, createChatPinImageButton)
            createChatPinMainView.addConstraintsWithFormat("H:[v0(100)]", options: [], views: createChatPinImageButton)
            NSLayoutConstraint(item: createChatPinImageButton, attribute: .centerX, relatedBy: .equal, toItem: createChatPinMainView, attribute: .centerX, multiplier: 1.0, constant: 0).isActive = true
        }
        
        func createInputTextField()
        {
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
            createChatPinTextField.inputAccessoryView = inputToolbar
        }
        
        func createInputTextView()
        {
            bubbleTextView = CreatePinTextView(frame: CGRect(x: (screenWidth - 290) / 2, y: 50, width: 290, height: 35), textContainer:nil)
            bubbleTextView.placeHolder = "Say Something…"
            createChatPinMainView.addSubview(bubbleTextView)
            bubbleTextView.alpha = 0
            bubbleTextView.inputAccessoryView = inputToolbar
        }
        
        createMainView()
        
        createSwitchButton()

        createImagePlaceHolder()
        
        createInputTextField()
        
        createInputTextView()
        
    }
    
    private func setupcreateChatPinOptionsTableView()
    {
        createChatPinOptionsTableView = CreatePinOptionsTableView(frame: CGRect(x: 0, y: screenHeight - CreatePinOptionsTableView.cellHeight * 3 - CGFloat(120), width: screenWidth, height: CreatePinOptionsTableView.cellHeight * 3))
        
        self.view.addSubview(createChatPinOptionsTableView)
//        self.view.addConstraintsWithFormat("H:|-[v0]-|", options: [], views: createChatPinOptionsTableView)
//        self.view.addConstraintsWithFormat("V:[v0(\(CreatePinOptionsTableView.cellHeight * 3))]-56-[v1]", options: [], views: createChatPinOptionsTableView, submitButton)
        
        createChatPinOptionsTableView.delegate = self
        createChatPinOptionsTableView.dataSource = self
    }
    
    //MARK: - button actions
    override func submitButtonTapped(_ sender: UIButton)
    {
        if(optionViewMode == .more){
            leaveDescription()
        }
    }
    
    @objc private func switchButtonLeftTapped(_ sender: UIButton)
    {
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
    
    @objc private func switchButtonRightTapped(_ sender: UIButton)
    {
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
    
    @objc private func createChatPinImageButtonTapped(_ sender: UIButton)
    {
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
    
    func actionSelectLocation()
    {
        let selectLocationVC = SelectLocationViewController()
        selectLocationVC.modalPresentationStyle = .overCurrentContext
        selectLocationVC.delegate = self
        self.present(selectLocationVC, animated: false, completion: nil)
    }
    
    func actionSelectMedia() {
        let nav = UIStoryboard(name: "Chat", bundle: nil).instantiateViewController(withIdentifier: "FullAlbumNavigationController")
        let imagePicker = nav.childViewControllers.first as! FullAlbumCollectionViewController
        imagePicker.imageDelegate = self
        imagePicker.maximumSelectedPhotoNum = 1
        self.present(nav, animated: true, completion: nil)
    }
    
    func showCamera()
    {
        view.endEditing(true)
        let camera = Camera(delegate_: self)
        camera.presentPhotoCamera(self, canEdit: false)
    }
    
    // MARK: - helper
    func switchToDescription()
    {
        if (descriptionTextView == nil) {
            descriptionTextView = CreatePinTextView(frame: CGRect(x: (screenWidth - 290) / 2, y: 195, width: 290, height: 35), textContainer: nil)
            descriptionTextView.placeHolder = "Add Description..."
            descriptionTextView.inputAccessoryView = inputToolbar
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
            self.setSubmitButton(withTitle: "Back", backgroundColor: UIColor(red: 194/255.0, green: 229/255.0, blue: 159/255.0, alpha: 1))
        }, completion:{
            Complete in
            self.descriptionTextView.becomeFirstResponder()
        })
    }
    
    func leaveDescription()
    {
        optionViewMode = .pin

        if self.descriptionTextView != nil {
            self.descriptionTextView.resignFirstResponder()
        }
        
        UIView.animate(withDuration: 0.3, animations: {
            Void in
            self.createChatPinMainView.alpha = 1
            self.createChatPinOptionsTableView.alpha = 1
            if self.descriptionTextView != nil {
                self.descriptionTextView.alpha = 0
            }
            if self.moreOptionsTableView != nil{
                self.moreOptionsTableView.alpha = 0
            }
            self.titleLabel.text = ""
            self.setSubmitButton(withTitle: "Submit!", backgroundColor: UIColor(red: 194/255.0, green: 229/255.0, blue: 159/255.0, alpha: 0.65))
        }, completion:{
            Complete in
        })
    }
    
    func switchToMoreOptions()
    {
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
            self.setSubmitButton(withTitle: "Back", backgroundColor: UIColor(red: 194/255.0, green: 229/255.0, blue: 159/255.0, alpha: 1))
        }, completion:{
            Complete in
        })
    }
    
    //MARK: - SelectLocationViewControllerDelegate
    func sendAddress(_ value: String) {
        labelSelectLocationContent = value
        createChatPinOptionsTableView.reloadData()
    }
    
    func sendGeoInfo(_ latitude: String, longitude: String) {
        selectedLatitude = latitude
        selectedLongitude = longitude
        createChatPinOptionsTableView.reloadData()
    }
    
    //MARK: - SendMutipleImagesDelegate
    func sendImages(_ images: [UIImage]) {
        print("Debug sendImages")
        for image in images {
//            addNewMediaToSubmit(image: image)
        }
    }
    
    func sendVideoData(_ video: Data, snapImage: UIImage, duration: Int) {
        print("Debug sendVideo")
    }
    
    //MARK: -  UIImagePickerController
    // handle events after user took a photo/video
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    }
}
