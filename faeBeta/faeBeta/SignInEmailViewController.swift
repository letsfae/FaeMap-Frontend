//
//  SignInEmailViewController.swift
//  faeBeta
//
//  Created by blesssecret on 8/15/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

class SignInEmailViewController: UIViewController {
    enum EnterEmailMode {
        case signInSupport
        case settings
    }
    
    var enterMode: EnterEmailMode!
    var enterFrom: EnterFromMode!
    //MARK: - Interface
    fileprivate var lblTitle: UILabel!
    fileprivate var txtEmail: FAETextField!
    fileprivate var lblInfo: UILabel!
    fileprivate var btnSendCode: UIButton!
    
    fileprivate enum pageStateType {
        case enteringUserName
        case enteringCode
    }
    
    fileprivate var statePage = pageStateType.enteringUserName
    fileprivate var numberKeyboard: FAENumberKeyboard!
    fileprivate var verificationCodeView: FAEVerificationCodeView!
    
    fileprivate var timer: Timer!
    fileprivate var remainingTime = 59
    fileprivate var boolWillDisappear = false
    
    fileprivate var indicatorView: UIActivityIndicatorView!
    var faeUser = FaeUser()
    
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
        if enterMode == .signInSupport {
            txtEmail.becomeFirstResponder()
        }

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
        lblTitle.text = "Enter your Email\nto Reset Password"
        lblTitle.textColor = UIColor._898989()
        lblTitle.font = UIFont(name: "AvenirNext-Medium", size: 20)
        lblTitle.textAlignment = .center
        lblTitle.center.x = screenWidth / 2
        lblTitle.adjustsFontSizeToFitWidth = true
        self.view.addSubview(lblTitle)
        
        // set up the email/username text field
        txtEmail = FAETextField(frame: CGRect(x: 15, y: 171 + device_offset_top, width: screenWidth - 30, height: 30))
        txtEmail.placeholder = "Email Address"
        txtEmail.adjustsFontSizeToFitWidth = true
//        if enterMode == .signInSupport {
//            txtEmail.becomeFirstResponder()
//        }
        self.view.addSubview(txtEmail)
        
        // set up the "We can’t find an account with this Email!" label
        lblInfo = UILabel(frame: CGRect(x: 87, y: screenHeight - 50 * screenHeightFactor - 90  - device_offset_bot, width: screenWidth - 175, height: 36))
        //btnInfo.setAttributedTitle(NSAttributedString(string: "We could’t find an account with this Email!", attributes: [NSAttributedStringKey.foregroundColor: UIColor._2499090(), NSAttributedStringKey.font: UIFont(name: "AvenirNext-Medium", size: 13)!]), for: UIControlState())
        lblInfo.attributedText = NSAttributedString(string: "Oops… This Email has not\nbeen linked to an Account.", attributes: [NSAttributedStringKey.foregroundColor: UIColor._2499090(), NSAttributedStringKey.font: UIFont(name: "AvenirNext-Medium", size: 13)!])
        //lblInfo.contentHorizontalAlignment = .center
        //lblInfo.sizeToFit()
        lblInfo.textAlignment = .center
        lblInfo.numberOfLines = 2
        lblInfo.center.x = screenWidth / 2
        lblInfo.alpha = 0
        self.view.addSubview(lblInfo)
        
        // set up the send button
        btnSendCode = UIButton(frame: CGRect(x: 0, y: screenHeight - 30 - 50 * screenHeightFactor - device_offset_bot, width: screenWidth - 114 * screenWidthFactor * screenWidthFactor, height: 50 * screenHeightFactor))
        btnSendCode.center.x = screenWidth / 2
        btnSendCode.setTitleColor(.white, for: .normal)
        btnSendCode.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 20)
        btnSendCode.setTitle("Send Code", for: .normal)
        btnSendCode.layer.cornerRadius = 25 * screenHeightFactor
        btnSendCode.isEnabled = false
        btnSendCode.backgroundColor = UIColor._255160160()
        btnSendCode.addTarget(self, action: #selector(sendCodeButtonTapped), for: .touchUpInside)
        self.view.insertSubview(btnSendCode, at: 0)
        
    }
    
    func setupEnteringVerificationCode() {
        let vc = VerifyCodeViewController()
        vc.enterMode = .email
        vc.enterFrom = enterFrom
        vc.enterEmailMode = .signInSupport
        vc.enterPhoneMode = .signInSupport
        vc.strEmail = txtEmail.text!
        //self.view.endEditing(true)
        navigationController?.pushViewController(vc, animated: true)
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
    
    @objc func sendCodeButtonTapped() {
        indicatorView.startAnimating()
        //self.view.endEditing(true)

        faeUser.whereKey("email", value: txtEmail.text!)
        faeUser.sendCodeToEmail{ (statusCode, result) in
            if(statusCode / 100 == 2 ) {
                self.setupEnteringVerificationCode()
            }
            else {
                self.lblInfo.alpha = 1
            }
            self.indicatorView.stopAnimating()
        }
    }
    
    func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(handleTap))
        self.view.addGestureRecognizer(tapGesture)
        txtEmail.addTarget(self, action: #selector(self.textfieldDidChange(_:)), for: .editingChanged)
    }

    @objc func navBarLeftButtonTapped() {
        _ = self.navigationController?.popViewController(animated: true)
    }
    // MARK: - keyboard
    
    // This is just a temporary method to make the login button clickable
    @objc func keyboardWillShow(_ notification: Notification) {
        let info = notification.userInfo!
        let frameKeyboard: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        var y_offset_0 = (screenHeight - frameKeyboard.height)
        y_offset_0 += -self.btnSendCode.frame.origin.y
        y_offset_0 +=  -50 * screenHeightFactor - 14
        var y_offset_1 = (screenHeight - frameKeyboard.height)
        y_offset_1 += -self.lblInfo.frame.origin.y
        y_offset_1 += -50 * screenHeightFactor - 14 - 18 - 19
        
        UIView.animate(withDuration: 0.3, animations: {() -> Void in
            self.btnSendCode.frame.origin.y += y_offset_0
            self.lblInfo.frame.origin.y += y_offset_1
        })
    }
    
    @objc func keyboardWillHide(_ notification:Notification) {
        if boolWillDisappear {
            return
        }
        UIView.animate(withDuration: 0.3, animations: {() -> Void in
            self.btnSendCode.frame.origin.y = screenHeight - 30 - 50 * screenHeightFactor - device_offset_bot
            self.lblInfo.frame.origin.y = screenHeight - 50 * screenHeightFactor - 90 - device_offset_bot
        })
    }
    
    //MARK: - helper
    @objc func handleTap() {
        self.view.endEditing(true)
    }
    
    func isValidEmail(_ testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let range = testStr.range(of: emailRegEx, options: .regularExpression)
        let result = range != nil ? true : false
        return result
    }
    
    @objc func textfieldDidChange(_ textfield: UITextField) {
        if isValidEmail(textfield.text!) {
            btnSendCode.isEnabled = true
            btnSendCode.backgroundColor = UIColor._2499090()
        }
        else {
            btnSendCode.isEnabled = false
            btnSendCode.backgroundColor = UIColor._255160160()
        }
    }
}

