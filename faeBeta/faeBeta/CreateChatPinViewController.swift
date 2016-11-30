//
//  CreateChatPinViewController.swift
//  faeBeta
//
//  Created by YAYUAN SHI on 11/29/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

class CreateChatPinViewController: CreatePinBaseViewController {
    //MARK: - properties
    private var createChatPinMainView: UIView!
    private var switchButtonContentView: UIView!
    private var switchButtonBackgroundImageView: UIImageView!
    private var switchButtonLeft: UIButton!
    private var switchButtonRight: UIButton!
    
    private var createChatPinImageImageView: UIImageView!
    private var createChatPinImageButton: UIButton!
    
    private var createChatPinTextField: UITextField!
    
    private var createChatPinOptionsView: UITableView!
    
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
        setupCreateChatPinOptionsView()
        // Do any additional setup after loading the view.
    }
    
    //MARK: - setup
    private func setupBasicUI()
    {
        self.titleImageView.image = #imageLiteral(resourceName: "chatPinTitleImage")
        self.titleLabel.isHidden = true
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
            createChatPinTextField.attributedPlaceholder = NSAttributedString(string:            "Chat Pin Name", attributes: [NSForegroundColorAttributeName: UIColor.faeAppShadowGrayColor(), NSFontAttributeName: UIFont(name: "AvenirNext-Regular", size: 20)!])

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
        
        createMainView()
        
        createSwitchButton()

        createImagePlaceHolder()
        
        createInputTextField()
        
    }
    
    private func setupCreateChatPinOptionsView()
    {
        createChatPinOptionsView = CreatePinOptionsTableView(frame: CGRect(x: 0, y: screenHeight - CreatePinOptionsTableView.cellHeight * 3 - CGFloat(120), width: screenWidth, height: CreatePinOptionsTableView.cellHeight * 3))
        
        self.view.addSubview(createChatPinOptionsView)
//        self.view.addConstraintsWithFormat("H:|-[v0]-|", options: [], views: createChatPinOptionsView)
//        self.view.addConstraintsWithFormat("V:[v0(\(CreatePinOptionsTableView.cellHeight * 3))]-56-[v1]", options: [], views: createChatPinOptionsView, submitButton)
        
        createChatPinOptionsView.delegate = self
        createChatPinOptionsView.dataSource = self        
    }
    
    //MARK: - button actions
    override func submitButtonTapped(_ sender: UIButton)
    {
        print("test")
    }
    
    @objc private func switchButtonLeftTapped(_ sender: UIButton)
    {
        self.switchButtonBackgroundImageView.image = #imageLiteral(resourceName: "createChatPinSwitch_pin")
        optionViewMode = .pin
        self.createChatPinImageImageView.alpha = 1
        self.createChatPinImageButton.alpha = 1
        self.createChatPinTextField.alpha = 1
        self.createChatPinOptionsView.frame = CGRect(x: 0, y: screenHeight - CreatePinOptionsTableView.cellHeight * 3 - CGFloat(120), width: screenWidth, height: CreatePinOptionsTableView.cellHeight * 3)
        self.createChatPinOptionsView.reloadData()
    }
    
    @objc private func switchButtonRightTapped(_ sender: UIButton)
    {
        self.switchButtonBackgroundImageView.image = #imageLiteral(resourceName: "createChatPinSwitch_bubble")
        optionViewMode = .bubble

        self.createChatPinImageImageView.alpha = 0
        self.createChatPinImageButton.alpha = 0
        self.createChatPinTextField.alpha = 0
        self.createChatPinOptionsView.reloadData()
        self.createChatPinOptionsView.frame = CGRect(x: 0, y: screenHeight - CreatePinOptionsTableView.cellHeight * 2 - CGFloat(120), width: screenWidth, height: CreatePinOptionsTableView.cellHeight * 2)
        
    }
    
    @objc private func createChatPinImageButtonTapped(_ sender: UIButton)
    {
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
