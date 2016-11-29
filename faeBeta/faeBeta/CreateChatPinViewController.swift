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
    
    
    //MARK: - life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCreateChatPinMainView()
        // Do any additional setup after loading the view.
    }
    
    //MARK: - setup
    private func setupUI()
    {
        self.titleImageView.image = #imageLiteral(resourceName: "chatPinTitleImage")
        self.titleLabel.isHidden = true
        setSubmitButton(withTitle: "Submit!", backgroundColor: UIColor(red: 194/255.0, green: 229/255.0, blue: 159/255.0, alpha: 0.65))
    }

    func setupCreateChatPinMainView()
    {
        createChatPinMainView = UIView(frame: CGRect(x: 0, y: 148, width: screenWidth, height: 225))
        self.view.addSubview(createChatPinMainView)
        self.view.addConstraintsWithFormat("V:[v0]-20-[v1(225)]", options: [], views: titleImageView, createChatPinMainView)
        self.view.addConstraintsWithFormat("H:|-0-[v0]-0-|", options: [], views: createChatPinMainView)
        
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
    
    
    //MARK: - button actions
    override func submitButtonTapped(_ sender: UIButton)
    {
        print("test")
    }
    
    @objc private func switchButtonLeftTapped(_ sender: UIButton)
    {
        self.switchButtonBackgroundImageView.image = #imageLiteral(resourceName: "createChatPinSwitch_pin")
    }
    
    @objc private func switchButtonRightTapped(_ sender: UIButton)
    {
        self.switchButtonBackgroundImageView.image = #imageLiteral(resourceName: "createChatPinSwitch_bubble")
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
