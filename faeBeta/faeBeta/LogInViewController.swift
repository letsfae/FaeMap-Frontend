//
//  LogInViewController.swift
//  faeBeta
//
//  Created by blesssecret on 8/15/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
import SwiftyJSON
import Foundation
import RealmSwift

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func >= <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l >= r
    default:
        return !(lhs < rhs)
    }
}

class LogInViewController: UIViewController {
    // MARK: - Properties
    private var imgIcon: UIImageView!
    private var btnSupport: UIButton!
    private var btnLogin: UIButton!
    private var lblLoginResult: UILabel!
    fileprivate var txtUsername: FAETextField!
    private var txtPassword: FAETextField!
    private var indicatorActivity: UIActivityIndicatorView!
    private var btnClear: UIButton!
    
    fileprivate var uiviewGrayBg: UIView!
    fileprivate var uiviewChooseMethod: UIView!
    fileprivate var lblChoose: UILabel!
    fileprivate var btnPhone: UIButton!
    fileprivate var btnEmail: UIButton!
    fileprivate var btnCancel: UIButton!
    
    fileprivate var uiviewInput: UIView!
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupNavigationBar()
        setupInterface()
        createActivityIndicator()
        loadResetPassword()
        loadInputText()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        uiviewChooseMethod.alpha = 0
        uiviewGrayBg.alpha = 0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        addObservers()
        txtUsername.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeKeyboardObserver()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    private func setupNavigationBar() {
        let uiviewNavBar = FaeNavBar(frame: .zero)
        view.addSubview(uiviewNavBar)
        uiviewNavBar.loadBtnConstraints()
        uiviewNavBar.leftBtn.setImage(#imageLiteral(resourceName: "NavigationBackNew"), for: .normal)
        uiviewNavBar.leftBtn.addTarget(self, action: #selector(self.navBarLeftButtonTapped), for: .touchUpInside)
        uiviewNavBar.rightBtn.isHidden = true
        uiviewNavBar.bottomLine.isHidden = true
    }
    
    private func setupInterface() {
        imgIcon = UIImageView()
        imgIcon.frame = CGRect(x: screenWidth / 2 - 30, y: 70 * screenHeightFactor + device_offset_top, width: 60, height: 60)
        imgIcon.image = #imageLiteral(resourceName: "Faevorite_icon")
        view.addSubview(imgIcon)
        
        txtUsername = FAETextField(frame: CGRect(x: 15, y: 174 * screenHeightFactor + device_offset_top, width: screenWidth - 30, height: 34))
        txtUsername.placeholder = "Username/Email"
        txtUsername.adjustsFontSizeToFitWidth = true
        txtUsername.keyboardType = .emailAddress
        txtUsername.tag = 1
        txtUsername.delegate = self
        view.addSubview(txtUsername)
        
        btnClear = UIButton(frame: CGRect(x: 0, y: 0, width: 36.45, height: 36.45))
        btnClear.center.y = txtUsername.center.y
        btnClear.setImage(#imageLiteral(resourceName: "mainScreenSearchClearSearchBar"), for: .normal)
        btnClear.addTarget(self, action: #selector(clearUsername), for: .touchUpInside)
        txtUsername.rightView = btnClear
        btnClear.isHidden = true
        
        txtPassword = FAETextField(frame: CGRect(x: 15, y: 243 * screenHeightFactor + device_offset_top, width: screenWidth - 30, height: 34))
        txtPassword.placeholder = "Password"
        txtPassword.isSecureTextEntry = true
        txtPassword.tag = 2
        txtPassword.delegate = self
        view.addSubview(txtPassword)
        
        lblLoginResult = UILabel(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 36))
        lblLoginResult.font = UIFont(name: "AvenirNext-Medium", size: 13)
        lblLoginResult.text = "Oops… Can’t find any Accounts\nwith this Username/Email!"
        lblLoginResult.textColor = UIColor._2499090()
        lblLoginResult.numberOfLines = 2
        lblLoginResult.center = view.center
        lblLoginResult.textAlignment = .center
        lblLoginResult.isHidden = true
        view.addSubview(lblLoginResult)
        
        btnSupport = UIButton(frame: CGRect(x: (screenWidth - 150) / 2, y: screenHeight - 50 * screenHeightFactor - 71 - device_offset_bot, width: 150, height: 22))
        btnSupport.center.x = screenWidth / 2
        btnSupport.setTitle("Sign In Support", for: .normal)
        btnSupport.setTitleColor(UIColor._2499090(), for: .normal)
        btnSupport.setTitleColor(.lightGray, for: .highlighted)
        btnSupport.titleLabel?.font = UIFont(name: "AvenirNext-Bold", size: 13)
        btnSupport.contentHorizontalAlignment = .center
        btnSupport.addTarget(self, action: #selector(supportButtonTapped), for: .touchUpInside)
        view.insertSubview(btnSupport, at: 0)
        
        btnLogin = UIButton(frame: CGRect(x: 0, y: screenHeight - 30 - 50 * screenHeightFactor - device_offset_bot, width: screenWidth - 114 * screenWidthFactor * screenWidthFactor, height: 50 * screenHeightFactor))
        btnLogin.center.x = screenWidth / 2
        btnLogin.setTitle("Log in", for: .normal)
        btnLogin.setTitleColor(.white, for: .normal)
        btnLogin.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 20)
        btnLogin.layer.cornerRadius = 25 * screenHeightFactor
        btnLogin.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        btnLogin.backgroundColor = UIColor._255160160()
        btnLogin.isEnabled = false
        view.insertSubview(btnLogin, at: 0)
    }
    
    private func addObservers() {
        addKeyboardObserver()
        NotificationCenter.default.addObserver(self, selector: #selector(appBecomeActive), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(tapGesture)
        txtUsername.addTarget(self, action: #selector(textfieldDidChange(_:)), for: .editingChanged)
        txtPassword.addTarget(self, action: #selector(textfieldDidChange(_:)), for: .editingChanged)
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
        indicatorActivity = UIActivityIndicatorView()
        indicatorActivity.activityIndicatorViewStyle = .whiteLarge
        indicatorActivity.center = view.center
        indicatorActivity.hidesWhenStopped = true
        indicatorActivity.color = UIColor._2499090()
        view.addSubview(indicatorActivity)
        view.bringSubview(toFront: indicatorActivity)
    }
    
    // MARK: - Button actions
    @objc private func navBarLeftButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func clearUsername() {
        txtUsername.text = ""
        btnClear.isHidden = true
    }
    
    @objc private func loginButtonTapped() {
        indicatorActivity.startAnimating()
        view.endEditing(true)
        lblLoginResult.isHidden = true
        
        let user = FaeUser()
        if txtUsername.text!.range(of: "@") != nil {
            user.whereKey("email", value: txtUsername.text!)
        } else {
            user.whereKey("user_name", value: txtUsername.text!)
        }
        user.whereKey("password", value: txtPassword.text!)
        user.whereKey("device_id", value: Key.shared.headerDeviceID)
        user.whereKey("is_mobile", value: "true")
        user.logInBackground { (status: Int, message: Any?) in
//            guard let `self` = self else { return }
            if status / 100 == 2 {
                let vcNext = InitialPageController()
                self.navigationController?.pushViewController(vcNext, animated: true)
                self.navigationController?.viewControllers = [vcNext]
                for key in ["signup", "signup_first_name", "signup_last_name", "signup_username", "signup_password", "signup_gender", "signup_dateofbirth", "signup_email"] {
                    FaeCoreData.shared.removeByKey(key)
                }
            } else if status == 500 {
                self.setLoginResult("Internal Service Error!")
            } else if status == 403 {
                handleErrorCode(.auth, "403", { [weak self] (prompt) in
                    guard let `self` = self else { return }
                    self.setLoginResult(prompt)
                }, "login")
                self.indicatorActivity.stopAnimating()
            } else { // TODO: error code done
                print("[LOGIN STATUS]: \(status), [LOGIN ERROR MESSAGE]: \(message!)")
                let loginJSONInfo = JSON(message!)
                if let error_code = loginJSONInfo["error_code"].string {
                    handleErrorCode(.auth, error_code, { [weak self] (prompt) in
                        guard let `self` = self else { return }
                        self.setLoginResult(prompt)
                    }, "login")
                    /*if error_code == "404-3" {
                        self.setLoginResult("Oops… Can’t find any Accounts\nwith this Username!")
                    } else if error_code == "401-1" {
                        self.setLoginResult("That’s not the Correct Password!\nPlease Check your Password!")
                    } else if error_code == "401-2" {
                        self.setLoginResult("Oops… This Email has not\nbeen linked to an Account.")
                    } else {
                        self.setLoginResult("Internet Error!")
                    }*/
                }
                self.indicatorActivity.stopAnimating()
            }
        }
    }
    
    @objc private func supportButtonTapped() {
        view.endEditing(true)
        if txtUsername.text != "" {
            animationShowSelf()
        } else {
            animationShowInput()
        }
//        let vc = SignInSupportViewController()
//        vc.modalPresentationStyle = .overCurrentContext
//        present(vc, animated: false)
//        navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - Observer actions
    // Keyboard
    @objc private func keyboardWillShow(_ notification: Notification) {
        let info = notification.userInfo!
        let frameKeyboard: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardOriginY = screenHeight - frameKeyboard.height
        let btnLoginOffset = 50 * screenHeightFactor + 14
        let btnSupportOffset = 50 * screenHeightFactor + 14 + 22 + 19
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.btnLogin.frame.origin.y = keyboardOriginY - btnLoginOffset
            self.btnSupport.frame.origin.y = keyboardOriginY - btnSupportOffset
            self.lblLoginResult.alpha = 0
        })
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        let screenBottom = screenHeight - device_offset_bot
        let btnLoginOffset = 30 + 50 * screenHeightFactor
        let btnSupportOffset = 50 * screenHeightFactor + 71
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.btnLogin.frame.origin.y = screenBottom - btnLoginOffset
            self.btnSupport.frame.origin.y = screenBottom - btnSupportOffset
            self.lblLoginResult.alpha = 1
        })
    }
    
    // TapGesture
    @objc private func handleTap() {
        view.endEditing(true)
    }
    
    // UIApplicationWillEnterForeground
    @objc func appBecomeActive() {
        txtUsername.becomeFirstResponder()
    }
    
    // TextfieldDidChange
    @objc private func textfieldDidChange(_ textfield: UITextField) {
        if txtUsername.text!.count > 0 && txtPassword.text?.count >= 8 {
            btnLogin.backgroundColor = UIColor._2499090()
            btnLogin.isEnabled = true
        } else {
            btnLogin.backgroundColor = UIColor._255160160()
            btnLogin.isEnabled = false
        }
        if textfield == txtUsername {
            if textfield.text?.count != 0 {
                btnClear.isHidden = false
            } else {
                btnClear.isHidden = true
            }
        }
    }
    
    // MARK: - Helper method
    private func setLoginResult(_ result: String) {
        lblLoginResult.text = result
        lblLoginResult.isHidden = false
    }
}

// MARK: - UITextFieldDelegate
extension LogInViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.tag == 2 {
            let currentCharacterCount = textField.text?.count ?? 0
            if range.length + range.location > currentCharacterCount {
                return false
            }
            let newLength = currentCharacterCount + string.count - range.length
            return newLength <= 50
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.tag == 1 { // username/email
            txtPassword.becomeFirstResponder()
            return false
        } else { // password
            if txtUsername.text!.count > 0 && txtPassword.text?.count >= 8 {
                loginButtonTapped()
                return false
            }
            return true
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField != txtUsername {
            btnClear.isHidden = true
        } else if let count = textField.text?.count, count > 0 {
            btnClear.isHidden = false
        }
    }
}

// MARK: - Load options for resetting password
extension LogInViewController {
    fileprivate func loadResetPassword() {
        uiviewGrayBg = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
        view.addSubview(uiviewGrayBg)
        uiviewGrayBg.backgroundColor = UIColor._107105105_a50()
        loadContent()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(actionCancel(_:)))
        uiviewGrayBg.addGestureRecognizer(tapGesture)
        uiviewGrayBg.isHidden = true
    }
    
    private func loadContent() {
        uiviewChooseMethod = UIView(frame: CGRect(x: 0, y: alert_offset_top, w: 290, h: 262))
        uiviewChooseMethod.center.x = screenWidth / 2
        uiviewChooseMethod.backgroundColor = .white
        uiviewChooseMethod.layer.cornerRadius = 20
        uiviewGrayBg.addSubview(uiviewChooseMethod)
        
        lblChoose = UILabel(frame: CGRect(x: 0, y: 20, w: 290, h: 50))
        lblChoose.textAlignment = .center
        lblChoose.numberOfLines = 0
        lblChoose.text = "How do you want to \nReset your Password?"
        lblChoose.textColor = UIColor._898989()
        lblChoose.font = UIFont(name: "AvenirNext-Medium", size: 18 * screenHeightFactor)
        uiviewChooseMethod.addSubview(lblChoose)
        
        btnPhone = UIButton(frame: CGRect(x: 41, y: 90, w: 208, h: 50))
        btnPhone.setTitle("Use Phone", for: .normal)
        btnEmail = UIButton(frame: CGRect(x: 41, y: 155, w: 208, h: 50))
        btnEmail.setTitle("Use Email", for: .normal)
        
        var btnActions = [UIButton]()
        btnActions.append(btnPhone)
        btnActions.append(btnEmail)
        
        for i in 0..<btnActions.count {
            btnActions[i].tag = i
            btnActions[i].setTitleColor(UIColor._2499090(), for: .normal)
            btnActions[i].titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 18 * screenHeightFactor)
            btnActions[i].addTarget(self, action: #selector(actionChooseMethod(_:)), for: .touchUpInside)
            btnActions[i].layer.borderWidth = 2
            btnActions[i].layer.borderColor = UIColor._2499090().cgColor
            btnActions[i].layer.cornerRadius = 26 * screenWidthFactor
            uiviewChooseMethod.addSubview(btnActions[i])
        }
        
        btnCancel = UIButton()
        btnCancel.setTitle("Cancel", for: .normal)
        btnCancel.setTitleColor(UIColor._2499090(), for: .normal)
        btnCancel.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size: 18 * screenHeightFactor)
        btnCancel.addTarget(self, action: #selector(actionCancel(_:)), for: .touchUpInside)
        uiviewChooseMethod.addSubview(btnCancel)
        view.addConstraintsWithFormat("H:|-80-[v0]-80-|", options: [], views: btnCancel)
        view.addConstraintsWithFormat("V:[v0(25)]-\(15 * screenHeightFactor)-|", options: [], views: btnCancel)
    }
    
    fileprivate func loadInputText() {
        uiviewInput = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
        uiviewInput.backgroundColor = UIColor._107105105_a50()
        view.addSubview(uiviewInput)
        
        let uiviewBox = UIView(frame: CGRect(x: 0, y: alert_offset_top, w: 290, h: 139))
        uiviewBox.center.x = screenWidth / 2
        uiviewBox.backgroundColor = .white
        uiviewBox.layer.cornerRadius = 20
        uiviewInput.addSubview(uiviewBox)
        
        let lblTitle = UILabel(frame: CGRect(x: 0, y: 20, w: 290, h: 50))
        lblTitle.textAlignment = .center
        lblTitle.numberOfLines = 0
        lblTitle.text = "Please input your Username\nor Email"
        lblTitle.textColor = UIColor._898989()
        lblTitle.font = UIFont(name: "AvenirNext-Medium", size: 18 * screenHeightFactor)
        uiviewBox.addSubview(lblTitle)
        
        let btnCancel = UIButton(frame: CGRect(x: 80, y: 80, w: 130, h: 39))
        btnCancel.setTitle("Cancel", for: .normal)
        btnCancel.setTitleColor(UIColor.white, for: .normal)
        btnCancel.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size: 18 * screenHeightFactor)
        btnCancel.backgroundColor = UIColor._2499090()
        btnCancel.layer.borderWidth = 2
        btnCancel.layer.borderColor = UIColor._2499090().cgColor
        btnCancel.layer.cornerRadius = 19 * screenWidthFactor
        btnCancel.addTarget(self, action: #selector(actionCancel(_:)), for: .touchUpInside)
        uiviewBox.addSubview(btnCancel)
        
        uiviewInput.isHidden = true
    }
    
    @objc private func actionCancel(_ sender: Any?) {
        animationHideSelf()
        animationHideInput()
    }
    
    @objc private func actionChooseMethod(_ sender: UIButton) {
        if sender.tag == 0 {  // use phone
            let vc = SignInPhoneViewController()
            vc.enterMode = .signInSupport
            vc.enterFrom = .login
            vc.strVerified = txtUsername.text!
            navigationController?.pushViewController(vc, animated: true)
            /*let vc = SignInPhoneUsernameViewController()
            if !txtUsername.text!.contains("@") {
                vc.strUsername = txtUsername.text!
            }
            navigationController?.pushViewController(vc, animated: true)*/
        } else {  // use email
            let vc = SignInEmailViewController()
            vc.enterMode = .signInSupport
            vc.enterFrom = .login
            if let email = txtUsername.text, email.contains("@") {
                vc.strEmail = email
            }
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    // MARK: Animations
    fileprivate func animationShowInput() {
        uiviewInput.isHidden = false
        uiviewInput.alpha = 0
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut, animations: {
            self.uiviewInput.alpha = 1
        }, completion: nil)
    }
    
    private func animationHideInput() {
        uiviewInput.alpha = 1
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut, animations: {
            self.uiviewInput.alpha = 0
        }, completion: nil)
    }
    
    fileprivate func animationShowSelf() {
        uiviewGrayBg.isHidden = false
        uiviewGrayBg.alpha = 0
        uiviewChooseMethod.alpha = 0
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut, animations: {
            self.uiviewGrayBg.alpha = 1
            self.uiviewChooseMethod.alpha = 1
        }, completion: nil)
    }
    
    fileprivate func animationHideSelf() {
        uiviewGrayBg.alpha = 1
        uiviewChooseMethod.alpha = 1
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut, animations: {
            self.uiviewChooseMethod.alpha = 0
            self.uiviewGrayBg.alpha = 0
        }, completion: nil)
    }
}
