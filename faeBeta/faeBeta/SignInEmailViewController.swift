//
//  SignInEmailViewController.swift
//  faeBeta
//
//  Created by blesssecret on 8/15/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
import SwiftyJSON

class SignInEmailViewController: UIViewController {
    // MARK: - Properties
    enum EnterEmailMode {
        case signInSupport, settings
    }
    
    var enterMode: EnterEmailMode!
    var enterFrom: EnterFromMode!
    private var lblTitle: UILabel!
    private var txtEmail: FAETextField!
    private var lblInfo: UILabel!
    private var btnSendCode: UIButton!
    var strEmail: String?
    
    private enum pageStateType {
        case enteringUserName, enteringCode
    }
    
    private var statePage = pageStateType.enteringUserName
    private var numberKeyboard: FAENumberKeyboard!
    private var verificationCodeView: FAEVerificationCodeView!
    
    private var timer: Timer!
    private var remainingTime = 59
    
    private var indicatorView: UIActivityIndicatorView!
    private var faeUser = FaeUser()
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupNavigationBar()
        setupInterface()
        createActivityIndicator()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let email = strEmail, isValidEmail(email) {
            btnSendCode.isEnabled = true
            btnSendCode.backgroundColor = UIColor._2499090()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        addObservers()
        if enterMode == .signInSupport {
            txtEmail.becomeFirstResponder()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeKeyboardObserver()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setupNavigationBar() {
        let uiviewNavBar = FaeNavBar(frame: .zero)
        view.addSubview(uiviewNavBar)
        uiviewNavBar.loadBtnConstraints()
        uiviewNavBar.leftBtn.setImage(#imageLiteral(resourceName: "NavigationBackNew"), for: .normal)
        uiviewNavBar.leftBtn.addTarget(self, action: #selector(navBarLeftButtonTapped), for: .touchUpInside)
        uiviewNavBar.rightBtn.isHidden = true
        uiviewNavBar.bottomLine.isHidden = true
    }
    
    private func setupInterface() {
        lblTitle = UILabel(frame: CGRect(x: 30, y: 72 + device_offset_top, width: screenWidth - 60, height: 60))
        lblTitle.numberOfLines = 2
        lblTitle.text = "Enter your Email\nto Reset Password"
        lblTitle.textColor = UIColor._898989()
        lblTitle.font = UIFont(name: "AvenirNext-Medium", size: 20)
        lblTitle.textAlignment = .center
        lblTitle.center.x = screenWidth / 2
        lblTitle.adjustsFontSizeToFitWidth = true
        view.addSubview(lblTitle)
        
        txtEmail = FAETextField(frame: CGRect(x: 15, y: 171 + device_offset_top, width: screenWidth - 30, height: 30))
        txtEmail.placeholder = "Email Address"
        txtEmail.adjustsFontSizeToFitWidth = true
        txtEmail.keyboardType = .emailAddress
        view.addSubview(txtEmail)
        if let email = strEmail, email != "" {
            txtEmail.text = email
        }
        
        lblInfo = UILabel(frame: CGRect(x: 87, y: screenHeight - 50 * screenHeightFactor - 90  - device_offset_bot, width: screenWidth - 175, height: 36))
        lblInfo.attributedText = NSAttributedString(string: "Oops… This Email has not\nbeen linked to an Account.", attributes: [NSAttributedStringKey.foregroundColor: UIColor._2499090(), NSAttributedStringKey.font: UIFont(name: "AvenirNext-Medium", size: 13)!])
        lblInfo.textAlignment = .center
        lblInfo.numberOfLines = 2
        lblInfo.center.x = screenWidth / 2
        lblInfo.alpha = 0
        view.addSubview(lblInfo)
        
        btnSendCode = UIButton(frame: CGRect(x: 0, y: screenHeight - 30 - 50 * screenHeightFactor - device_offset_bot, width: screenWidth - 114 * screenWidthFactor * screenWidthFactor, height: 50 * screenHeightFactor))
        btnSendCode.center.x = screenWidth / 2
        btnSendCode.setTitleColor(.white, for: .normal)
        btnSendCode.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 20)
        btnSendCode.setTitle("Send Code", for: .normal)
        btnSendCode.layer.cornerRadius = 25 * screenHeightFactor
        btnSendCode.isEnabled = false
        btnSendCode.backgroundColor = UIColor._255160160()
        btnSendCode.addTarget(self, action: #selector(sendCodeButtonTapped), for: .touchUpInside)
        view.insertSubview(btnSendCode, at: 0)
    }
    
    private func addObservers() {
        addKeyboardObserver()
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(tapGesture)
        txtEmail.addTarget(self, action: #selector(textfieldDidChange(_:)), for: .editingChanged)
    }
    
    private func addKeyboardObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    private func removeKeyboardObserver() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    private func createActivityIndicator() {
        indicatorView = UIActivityIndicatorView()
        indicatorView.activityIndicatorViewStyle = .whiteLarge
        indicatorView.center = view.center
        indicatorView.hidesWhenStopped = true
        indicatorView.color = UIColor._2499090()
        view.addSubview(indicatorView)
        view.bringSubview(toFront: indicatorView)
    }
    
    // MARK: - Button actions
    @objc private func navBarLeftButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func sendCodeButtonTapped() {
        indicatorView.startAnimating()

        faeUser.whereKey("email", value: txtEmail.text!)
        faeUser.resetPassword{ [weak self] (statusCode, result) in
            guard let `self` = self else { return }
            if statusCode / 100 == 2 {
                self.setupEnteringVerificationCode()
            } else if statusCode == 500 {
                self.setResetResult("Internal Service Error!")
            } else { // TODO: error code done
                let messageJSON = JSON(result!)
                if let error_code = messageJSON["error_code"].string {
                    handleErrorCode(.auth, error_code, { [weak self] (prompt) in
                        guard let `self` = self else { return }
                        self.setResetResult(prompt)
                    }, "resetByEmail")
                }
            }
            self.indicatorView.stopAnimating()
        }
    }
    
    // MARK: - Observer actions
    // Keyboard
    @objc private func keyboardWillShow(_ notification: Notification) {
        let info = notification.userInfo!
        let frameKeyboard: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardOriginY = screenHeight - frameKeyboard.height
        let btnSendCodeOffset = 50 * screenHeightFactor + 14
        let lblInfoOffset =  50 * screenHeightFactor + 74
        UIView.animate(withDuration: 0.3, animations: {() -> Void in
            self.btnSendCode.frame.origin.y = keyboardOriginY - btnSendCodeOffset
            self.lblInfo.frame.origin.y = keyboardOriginY - lblInfoOffset
        })
    }
    
    @objc private func keyboardWillHide(_ notification:Notification) {
        let screenBottom = screenHeight - device_offset_bot
        let btnSendCodeOffset = 50 * screenHeightFactor + 30
        let lblInfoOffset =  50 * screenHeightFactor + 90
        UIView.animate(withDuration: 0.3, animations: {() -> Void in
            self.btnSendCode.frame.origin.y = screenBottom - btnSendCodeOffset
            self.lblInfo.frame.origin.y = screenBottom - lblInfoOffset
        })
    }
    
    // TapGesture
    @objc private func handleTap() {
        view.endEditing(true)
    }
    
    // TextfieldDidChange
    @objc private func textfieldDidChange(_ textfield: UITextField) {
        if isValidEmail(textfield.text!) {
            btnSendCode.isEnabled = true
            btnSendCode.backgroundColor = UIColor._2499090()
        } else {
            btnSendCode.isEnabled = false
            btnSendCode.backgroundColor = UIColor._255160160()
        }
    }
    
    // MARK: - Helper methods
    private func setupEnteringVerificationCode() {
        let vc = VerifyCodeViewController()
        vc.enterMode = .email
        vc.enterFrom = enterFrom
        vc.enterEmailMode = .signInSupport
        vc.enterPhoneMode = .signInSupport
        vc.strVerified = txtEmail.text!
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func setResetResult(_ prompt: String) {
        lblInfo.text = prompt
        lblInfo.alpha = 1
    }
    
    private func isValidEmail(_ testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let range = testStr.range(of: emailRegEx, options: .regularExpression)
        let result = range != nil ? true : false
        return result
    }
}

