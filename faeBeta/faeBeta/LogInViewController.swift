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
    // MARK: - Interface
    fileprivate var imgIcon: UIImageView!
    fileprivate var btnSupport: UIButton!
    fileprivate var btnLogin: UIButton!
    fileprivate var lblLoginResult: UILabel!
    fileprivate var txtUsername: FAETextField!
    fileprivate var txtPassword: FAETextField!
    fileprivate var indicatorActivity: UIActivityIndicatorView!
    
    var uiviewGrayBg: UIView!
    var uiviewChooseMethod: UIView!
    var lblChoose: UILabel!
    var btnPhone: UIButton!
    var btnEmail: UIButton!
    var btnCancel: UIButton!
    
    // Mark: - View did/will ..
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupNavigationBar()
        setupInterface()
        addObservers()
        createActivityIndicator()
        loadResetPassword()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        txtUsername.becomeFirstResponder()
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
        // icon
        imgIcon = UIImageView()
        imgIcon.frame = CGRect(x: screenWidth / 2 - 30, y: 70 * screenHeightFactor, width: 60 * screenHeightFactor, height: 60 * screenHeightFactor)
        imgIcon.image = #imageLiteral(resourceName: "Faevorite_icon")
        view.addSubview(imgIcon)
        
        // username textField
        txtUsername = FAETextField(frame: CGRect(x: 15, y: 174 * screenHeightFactor, width: screenWidth - 30, height: 34))
        txtUsername.placeholder = "Username/Email"
        txtUsername.adjustsFontSizeToFitWidth = true
        txtUsername.keyboardType = .emailAddress
        view.addSubview(txtUsername)
        
        // result label
        lblLoginResult = UILabel(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 36))
        lblLoginResult.font = UIFont(name: "AvenirNext-Medium", size: 13)
        lblLoginResult.text = "Oops… Can’t find any Accounts\nwith this Username/Email!"
        lblLoginResult.textColor = UIColor._2499090()
        lblLoginResult.numberOfLines = 2
        lblLoginResult.center = view.center
        lblLoginResult.textAlignment = .center
        lblLoginResult.isHidden = true
        view.addSubview(lblLoginResult)
        
        // password textField
        txtPassword = FAETextField(frame: CGRect(x: 15, y: 243 * screenHeightFactor, width: screenWidth - 30, height: 34))
        txtPassword.placeholder = "Password"
        txtPassword.isSecureTextEntry = true
        txtPassword.delegate = self
        view.addSubview(txtPassword)
        
        // support button
        btnSupport = UIButton(frame: CGRect(x: (screenWidth - 150) / 2, y: screenHeight - 50 * screenHeightFactor - 71, width: 150, height: 22))
        btnSupport.center.x = screenWidth / 2
        var font = UIFont(name: "AvenirNext-Bold", size: 13)
        btnSupport.setTitle("Sign In Support", for: .normal)
        btnSupport.setTitleColor(UIColor._2499090(), for: .normal)
        btnSupport.setTitleColor(.lightGray, for: .highlighted)
        btnSupport.titleLabel?.font = font!
        btnSupport.contentHorizontalAlignment = .center
        btnSupport.addTarget(self, action: #selector(LogInViewController.supportButtonTapped), for: .touchUpInside)
        view.insertSubview(btnSupport, at: 0)
        
        // log in button
        font = UIFont(name: "AvenirNext-DemiBold", size: 20)
        btnLogin = UIButton(frame: CGRect(x: 0, y: screenHeight - 30 - 50 * screenHeightFactor, width: screenWidth - 114 * screenWidthFactor * screenWidthFactor, height: 50 * screenHeightFactor))
        btnLogin.center.x = screenWidth / 2
        btnLogin.setTitle("Log in", for: .normal)
        btnLogin.setTitleColor(.white, for: .normal)
        btnLogin.setTitleColor(.lightGray, for: .highlighted)
        btnLogin.titleLabel?.font = font!
        btnLogin.layer.cornerRadius = 25 * screenHeightFactor
        btnLogin.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        btnLogin.backgroundColor = UIColor._255160160()
        btnLogin.isEnabled = false
        view.insertSubview(btnLogin, at: 0)
    }
    
    func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(tapGesture)
        txtUsername.addTarget(self, action: #selector(self.textfieldDidChange(_:)), for: .editingChanged)
        txtPassword.addTarget(self, action: #selector(self.textfieldDidChange(_:)), for: .editingChanged)
    }
    
    func createActivityIndicator() {
        indicatorActivity = UIActivityIndicatorView()
        indicatorActivity.activityIndicatorViewStyle = .whiteLarge
        indicatorActivity.center = view.center
        indicatorActivity.hidesWhenStopped = true
        indicatorActivity.color = UIColor._2499090()
        view.addSubview(indicatorActivity)
        view.bringSubview(toFront: indicatorActivity)
    }
    
    func loginButtonTapped() {
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
        user.whereKey("device_id", value: headerDeviceID)
        user.whereKey("is_mobile", value: "true")
        user.logInBackground { (status: Int, message: Any?) in
            if status / 100 == 2 {
                let vcNext = InitialPageController()
                self.navigationController?.pushViewController(vcNext, animated: true)
                self.navigationController?.viewControllers = [vcNext]
            } else {
                // Vicky 07/12/2017  - 把使用error message的判断改为使用error code判断
                print("[LOGIN STATUS]: \(status), [LOGIN ERROR MESSAGE]: \(message!)")
                
                if status == 500 {
                    self.setLoginResult("Internet Error!")
                }
                
                let loginJSONInfo = JSON(message!)
                if let errorCode = loginJSONInfo["error_code"].string {
                    if errorCode == "404-3" {
                        self.setLoginResult("Oops… Can’t find any Accounts\nwith this Username/Email!")
                    } else if errorCode == "401-1" {
                        self.setLoginResult("That’s not the Correct Password!\nPlease Check your Password!")
                    } else {
                        self.setLoginResult("Internet Error!")
                    }
                }
                self.indicatorActivity.stopAnimating()
                // Vicky 07/12/2017 End
            }
        }
    }
    
    func setLoginResult(_ result: String) {
        lblLoginResult.text = result
        lblLoginResult.isHidden = false
    }
    
    func supportButtonTapped() {
        animationShowSelf()
//        let vc = SignInSupportViewController()
//        vc.modalPresentationStyle = .overCurrentContext
//        present(vc, animated: false)
//        navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - Navigation
    func navBarLeftButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - keyboard
    // This is just a temporary method to make the login button clickable
    func keyboardWillShow(_ notification: Notification) {
        let info = notification.userInfo!
        let frameKeyboard: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.btnLogin.frame.origin.y += (screenHeight - frameKeyboard.height) - self.btnLogin.frame.origin.y - 50 * screenHeightFactor - 14
            self.btnSupport.frame.origin.y += (screenHeight - frameKeyboard.height) - self.btnSupport.frame.origin.y - 50 * screenHeightFactor - 14 - 22 - 19
            self.lblLoginResult.alpha = 0
        })
    }
    
    func keyboardWillHide(_ notification: Notification) {
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.btnLogin.frame.origin.y = screenHeight - 30 - 50 * screenHeightFactor
            self.btnSupport.frame.origin.y = screenHeight - 50 * screenHeightFactor - 71
            self.lblLoginResult.alpha = 1
        })
    }
    // MARK: - helper
    func handleTap() {
        view.endEditing(true)
    }
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
    // MARK: - textfield
    func textfieldDidChange(_ textfield: UITextField) {
        if txtUsername.text!.count > 0 && txtPassword.text?.count >= 8 {
            btnLogin.backgroundColor = UIColor._2499090()
            btnLogin.isEnabled = true
        } else {
            btnLogin.backgroundColor = UIColor._255160160()
            btnLogin.isEnabled = false
        }
    }
}

extension LogInViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentCharacterCount = textField.text?.count ?? 0
        if range.length + range.location > currentCharacterCount {
            return false
        }
        let newLength = currentCharacterCount + string.count - range.length
        return newLength <= 16
    }
}

// load choose reset password page
extension LogInViewController {
    func loadResetPassword() {
        uiviewGrayBg = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
        view.addSubview(uiviewGrayBg)
        uiviewGrayBg.backgroundColor = UIColor(r: 107, g: 105, b: 105, alpha: 70)
        loadContent()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(actionCancel(_:)))
        uiviewGrayBg.addGestureRecognizer(tapGesture)
        uiviewGrayBg.isHidden = true
    }
    
    fileprivate func loadContent() {
        uiviewChooseMethod = UIView(frame: CGRect(x: 0, y: 200, w: 290, h: 262))
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
    
    func actionCancel(_ sender: Any?) {
        animationHideSelf()
    }
    
    func actionChooseMethod(_ sender: UIButton) {
        if sender.tag == 0 {  // use phone
            let vc = SignInPhoneViewController()
            vc.enterMode = .signInSupport
            navigationController?.pushViewController(vc, animated: true)
        } else {  // use email
            let vc = SignInEmailViewController()
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    // animations
    func animationShowSelf() {
        uiviewGrayBg.isHidden = false
        uiviewGrayBg.alpha = 0
        uiviewChooseMethod.alpha = 0
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut, animations: {
            self.uiviewGrayBg.alpha = 1
            self.uiviewChooseMethod.alpha = 1
        }, completion: nil)
    }
    
    func animationHideSelf() {
        uiviewGrayBg.alpha = 1
        uiviewChooseMethod.alpha = 1
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut, animations: {
            self.uiviewChooseMethod.alpha = 0
            self.uiviewGrayBg.alpha = 0
        }, completion: nil)
    }
    // animations end
}
