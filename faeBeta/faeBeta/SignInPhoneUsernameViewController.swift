//
//  SignInPhoneUsernameViewController.swift
//  faeBeta
//
//  Created by Jichao on 2018/4/26.
//  Copyright © 2018年 fae. All rights reserved.
//

import UIKit
import SwiftyJSON

class SignInPhoneUsernameViewController: UIViewController {
    
    //MARK: - Interface
    fileprivate var lblTitle: UILabel!
    fileprivate var txtUsername: FAETextField!
    fileprivate var lblInfo: UILabel!
    fileprivate var btnContinue: UIButton!
    
    fileprivate var boolWillDisappear = false
    
    fileprivate var indicatorView: UIActivityIndicatorView!
    var faeUser = FaeUser()
    var strUsername: String = ""
    
    //MARK: - View did/will ...
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        setupNavigationBar()
        setupInterface()
        addObservers()
        createActivityIndicator()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        boolWillDisappear = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        txtUsername.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        boolWillDisappear = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func setupNavigationBar() {
        let uiviewNavBar = FaeNavBar(frame: .zero)
        view.addSubview(uiviewNavBar)
        uiviewNavBar.loadBtnConstraints()
        uiviewNavBar.leftBtn.setImage(#imageLiteral(resourceName: "NavigationBackNew"), for: .normal)
        uiviewNavBar.leftBtn.addTarget(self, action: #selector(self.navBarLeftButtonTapped), for: .touchUpInside)
        uiviewNavBar.rightBtn.isHidden = true
        uiviewNavBar.bottomLine.isHidden = true
    }
    
    fileprivate func setupInterface() {
        // set up the title label
        lblTitle = UILabel(frame: CGRect(x: 30, y: 72 + device_offset_top, width: screenWidth - 60, height: 60))
        lblTitle.numberOfLines = 2
        lblTitle.text = "Enter your Username\nto Proceed"
        lblTitle.textColor = UIColor._898989()
        lblTitle.font = UIFont(name: "AvenirNext-Medium", size: 20)
        lblTitle.textAlignment = .center
        lblTitle.center.x = screenWidth / 2
        lblTitle.adjustsFontSizeToFitWidth = true
        view.addSubview(lblTitle)
        
        // set up the email/username text field
        txtUsername = FAETextField(frame: CGRect(x: 15, y: 171 + device_offset_top, width: screenWidth - 30, height: 30))
        txtUsername.placeholder = "Username"
        txtUsername.adjustsFontSizeToFitWidth = true
        //        if enterMode == .signInSupport {
        //            txtUsername.becomeFirstResponder()
        //        }
        view.addSubview(txtUsername)
        if strUsername != "" {
            txtUsername.text = strUsername
        }
        
        // set up the "We can’t find an account with this Email!" label
        lblInfo = UILabel(frame: CGRect(x: 87, y: screenHeight - 50 * screenHeightFactor - 90  - device_offset_bot, width: screenWidth - 175, height: 36))
        lblInfo.attributedText = NSAttributedString(string: "Oops… Can’t find any Accounts\nwith this Username!", attributes: [NSAttributedStringKey.foregroundColor: UIColor._2499090(), NSAttributedStringKey.font: UIFont(name: "AvenirNext-Medium", size: 13)!])
        lblInfo.textAlignment = .center
        lblInfo.numberOfLines = 2
        lblInfo.center.x = screenWidth / 2
        lblInfo.alpha = 0
        view.addSubview(lblInfo)
        
        // set up the send button
        btnContinue = UIButton(frame: CGRect(x: 0, y: screenHeight - 30 - 50 * screenHeightFactor - device_offset_bot, width: screenWidth - 114 * screenWidthFactor * screenWidthFactor, height: 50 * screenHeightFactor))
        btnContinue.center.x = screenWidth / 2
        btnContinue.setTitleColor(.white, for: .normal)
        btnContinue.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 20)
        btnContinue.setTitle("Continue", for: .normal)
        btnContinue.layer.cornerRadius = 25 * screenHeightFactor
        btnContinue.isEnabled = strUsername != ""
        btnContinue.backgroundColor = strUsername != "" ? UIColor._2499090() : UIColor._255160160()
        btnContinue.addTarget(self, action: #selector(continueBtnAction), for: .touchUpInside)
        view.insertSubview(btnContinue, at: 0)
        
    }
    
    func setupEnteringVerificationCode() {
    }
    
    func createActivityIndicator() {
        indicatorView = UIActivityIndicatorView()
        indicatorView.activityIndicatorViewStyle = .whiteLarge
        indicatorView.center = view.center
        indicatorView.hidesWhenStopped = true
        indicatorView.color = UIColor._2499090()
        
        view.addSubview(indicatorView)
        view.bringSubview(toFront: indicatorView)
    }
    
    @objc func continueBtnAction() {
        indicatorView.startAnimating()
        
        faeUser.whereKey("user_name", value: txtUsername.text!)
        faeUser.checkUserExistence {(status, message) in
            if status / 100 == 2 {
                let valueInfo = JSON(message!)
                if let value = valueInfo["existence"].int {
                    self.indicatorView.stopAnimating()
                    if value == 0 {
                        self.setResetResult("Oops… Can’t find any Accounts\nwith this Username!")
                        self.btnContinue.isEnabled = false
                        self.btnContinue.backgroundColor = UIColor._255160160()
                    } else {
                        let vc = SignInPhoneViewController()
                        vc.enterMode = .signInSupport
                        vc.enterFrom = .login
                        vc.strUsername = self.txtUsername.text!
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
            } else {
                let messageJSON = JSON(message!)
                if let error_code = messageJSON["error_code"].string {
                    handleErrorCode(.auth, error_code, { (prompt) in
                        // handle
                        felixprint("\(error_code)")
                    })
                }
            }
        }
    }
    
    func setResetResult(_ prompt: String) {
        lblInfo.text = prompt
        lblInfo.alpha = 1
    }
    
    func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(tapGesture)
        txtUsername.addTarget(self, action: #selector(self.textfieldDidChange(_:)), for: .editingChanged)
    }
    
    @objc func navBarLeftButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    // MARK: - keyboard
    
    // This is just a temporary method to make the login button clickable
    @objc func keyboardWillShow(_ notification: Notification) {
        let info = notification.userInfo!
        let frameKeyboard: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        var y_offset_0 = (screenHeight - frameKeyboard.height)
        y_offset_0 += -self.btnContinue.frame.origin.y
        y_offset_0 +=  -50 * screenHeightFactor - 14
        var y_offset_1 = (screenHeight - frameKeyboard.height)
        y_offset_1 += -self.lblInfo.frame.origin.y
        y_offset_1 += -50 * screenHeightFactor - 14 - 18 - 19
        
        UIView.animate(withDuration: 0.3, animations: {() -> Void in
            self.btnContinue.frame.origin.y += y_offset_0
            self.lblInfo.frame.origin.y += y_offset_1
        })
    }
    
    @objc func keyboardWillHide(_ notification:Notification) {
        if boolWillDisappear {
            return
        }
        UIView.animate(withDuration: 0.3, animations: {() -> Void in
            self.btnContinue.frame.origin.y = screenHeight - 30 - 50 * screenHeightFactor - device_offset_bot
            self.lblInfo.frame.origin.y = screenHeight - 50 * screenHeightFactor - 90 - device_offset_bot
        })
    }
    
    //MARK: - helper
    @objc func handleTap() {
        self.view.endEditing(true)
    }
    
    @objc func textfieldDidChange(_ textfield: UITextField) {
        if textfield.text!.count > 0 {
            btnContinue.isEnabled = true
            btnContinue.backgroundColor = UIColor._2499090()
        } else {
            btnContinue.isEnabled = false
            btnContinue.backgroundColor = UIColor._255160160()
        }
    }
}


