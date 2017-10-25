//
//  VerifyCodeViewController.swift
//  faeBeta
//
//  Created by Faevorite 2 on 2017-10-23.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit


protocol VerifyCodeDelegate {
    func verifyPhoneSucceed()
    func verifyEmailSucceed()
}

enum EnterVerifyCodeMode {
    case email
    case phone
}

enum EnterEmailMode {
    case signInSupport
    case settings
}

class VerifyCodeViewController: UIViewController, FAENumberKeyboardDelegate { //}, UpdateUsrnameEmailDelegate {
    var enterMode: EnterVerifyCodeMode!
    var enterPhoneMode: EnterPhoneMode!
    var enterEmailMode: EnterEmailMode!
    var lblTitle: UILabel!
    var lblPhoneNumber: UILabel!
    var btnResendCode: UIButton!
    var btnContinue: UIButton!
    var strCountry = ""
    var strCountryCode = ""
    var strPhoneNumber = ""
    var strEmail = ""
    var delegate: VerifyCodeDelegate!
    var updatePhoneDelegate: UpdateUsrnameEmailDelegate!
    let faeUser = FaeUser()
    fileprivate var verificationCodeView: FAEVerificationCodeView!
    fileprivate var timer: Timer!
    fileprivate var remainingTime = 59
    fileprivate var indicatorView: UIActivityIndicatorView!
    fileprivate var numberKeyboard: FAENumberKeyboard!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        loadNavBar()
        loadContent()
        createActivityIndicator()
        
        self.startTimer()
    }
    
    fileprivate func loadNavBar() {
        let uiviewNavBar = FaeNavBar(frame: .zero)
        view.addSubview(uiviewNavBar)
        uiviewNavBar.leftBtn.setImage(#imageLiteral(resourceName: "NavigationBackNew"), for: .normal)

        uiviewNavBar.loadBtnConstraints()
        uiviewNavBar.leftBtn.addTarget(self, action: #selector(self.actionBack(_:)), for: .touchUpInside)
        uiviewNavBar.rightBtn.isHidden = true
        uiviewNavBar.bottomLine.isHidden = true
    }
    
    fileprivate func loadContent() {
        lblTitle = FaeLabel(CGRect(x: 30, y: 72, width: screenWidth - 60, height: 60), .center, .medium, 20, UIColor._898989())
        lblTitle.numberOfLines = 2
        lblTitle.center.x = screenWidth / 2
        lblTitle.adjustsFontSizeToFitWidth = true
        view.addSubview(lblTitle)
        
        verificationCodeView = FAEVerificationCodeView(frame: CGRect(x: 85 * screenWidthFactor, y: 148, width: 244 * screenWidthFactor, height: 82))
        view.addSubview(verificationCodeView)
        
        btnResendCode = UIButton(frame: CGRect(x: 87, y: screenHeight - 244 * screenHeightFactor - 21 - 50 * screenHeightFactor - 67, width: screenWidth - 174, height: 18))
        btnResendCode.setAttributedTitle(NSAttributedString(string: "Resend Code 60", attributes: [NSForegroundColorAttributeName: UIColor._2499090(), NSFontAttributeName: UIFont(name: "AvenirNext-Medium", size: 13)!]), for: UIControlState())
        btnResendCode.contentHorizontalAlignment = .center
        btnResendCode.sizeToFit()
        btnResendCode.center.x = screenWidth / 2
        view.addSubview(btnResendCode)
        
        // set up the send button
        btnContinue = UIButton(frame: CGRect(x: 57, y: screenHeight - 244 * screenHeightFactor - 21 - 50 * screenHeightFactor, width: screenWidth - 114 * screenWidthFactor * screenWidthFactor, height: 50 * screenHeightFactor))
        btnContinue.center.x = screenWidth / 2
        btnContinue.setTitleColor(.white, for: .normal)
        btnContinue.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 20)
        btnContinue.layer.cornerRadius = 25 * screenHeightFactor
        btnContinue.isEnabled = false
        btnContinue.backgroundColor = UIColor._255160160()
        btnContinue.addTarget(self, action: #selector(actionVerifyCode(_:)), for: .touchUpInside)
        view.addSubview(btnContinue)
        
        lblPhoneNumber = UILabel(frame: CGRect(x: 87, y: screenHeight - 244 * screenHeightFactor - 21 - 50 * screenHeightFactor - 43, width: screenWidth - 174, height: 27))
        lblPhoneNumber.font = UIFont(name: "AvenirNext-Regular", size: 20)
        lblPhoneNumber.textColor = UIColor._155155155()
        lblPhoneNumber.textAlignment = .center
        lblPhoneNumber.text = "+" + strCountryCode + " " + strPhoneNumber
        view.addSubview(lblPhoneNumber)
        
        // setup the fake keyboard for numbers input
        numberKeyboard = FAENumberKeyboard(frame: CGRect(x: 0, y: screenHeight - 244 * screenHeightFactor, width: screenWidth, height: 244 * screenHeightFactor))
        view.addSubview(numberKeyboard)
        numberKeyboard.delegate = self
        numberKeyboard.transform = CGAffineTransform(translationX: 0, y: 0)
        
        getTitle()
    }
    
    fileprivate func getTitle() {
        if enterMode == .email {
            btnResendCode.frame.origin.y = screenHeight - 244 * screenHeightFactor - 21 - 50 * screenHeightFactor - 36
            lblPhoneNumber.isHidden = true
            if enterEmailMode == .signInSupport {
                lblTitle.text = "Enter the Code we just sent\nto your Email to Continue"
                btnContinue.setTitle("Continue", for: .normal)
            } else {
                lblTitle.text = "Enter the Code we just sent\nto your Email to Verify"
                btnContinue.setTitle("Verify", for: .normal)
            }
        } else {
            btnResendCode.frame.origin.y = screenHeight - 244 * screenHeightFactor - 21 - 50 * screenHeightFactor - 67
            if enterPhoneMode == .signInSupport {
                lblTitle.text = "Enter the Code we just texted\nto your Number to Continue"
                btnContinue.setTitle("Continue", for: .normal)
            } else {
                lblTitle.text = "Verify your Number with the \nCode we texted you."
                btnContinue.setTitle("Verify", for: .normal)
            }
        }
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
    
    func actionBack(_ sender: UIButton) {
        if enterPhoneMode == .contacts {
            dismiss(animated: false)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    func actionVerifyCode(_ sender: UIButton) {
        indicatorView.startAnimating()
        if enterMode == .email {
            faeUser.whereKey("email", value: strEmail)
            faeUser.whereKey("code", value: verificationCodeView.displayValue)
            faeUser.validateCode{ (statusCode, result) in
                if(statusCode / 100 == 2) {
                    if self.enterEmailMode == .signInSupport {
                        let controller = SignInSupportNewPassViewController()
                        controller.enterMode = self.enterMode
                        controller.email = self.strEmail
                        controller.code = self.verificationCodeView.displayValue
                        self.navigationController?.pushViewController(controller, animated: true)
                    } else {  // verify email - settings
                        self.faeUser.getAccountBasicInfo{ (statusCode: Int, result: Any?) in
                            if(statusCode / 100 == 2) {
                                print("Successfully get account info \(statusCode) \(result!)")
                                Key.shared.userEmailVerified = true
                                self.delegate?.verifyEmailSucceed()
                                self.navigationController?.popViewController(animated: true)
                            } else {
                                print("Fail to get account info \(statusCode) \(result!)")
                            }
                        }
                    }
                } else {
                    for _ in 0..<6 {
                        _ = self.verificationCodeView.addDigit(-1)
                    }
                    self.lblTitle.text = "That's an Incorrect Code!\n Please Try Again!"
                    self.btnContinue.isEnabled = false
                    self.btnContinue.backgroundColor = UIColor._255160160()
                }
                self.indicatorView.stopAnimating()
            }
        } else {
            faeUser.whereKey("phone", value: "(" + strCountryCode + ")" + strPhoneNumber)
            faeUser.whereKey("code", value: verificationCodeView.displayValue)
            faeUser.verifyPhoneNumber {(status, message) in
                print("[verify phone] \(status) \(message!)")
                if(status / 100 == 2 ) {
                    if self.enterPhoneMode == .signInSupport {
                        let controller = SignInSupportNewPassViewController()
                        controller.enterMode = self.enterMode
                        controller.phone = "(" + self.strCountryCode + ")" + self.strPhoneNumber
                        controller.code = self.verificationCodeView.displayValue
                        self.navigationController?.pushViewController(controller, animated: true)
                    } else {
//                        self.faeUser.getAccountBasicInfo{ (statusCode: Int, result: Any?) in
//                            if(statusCode / 100 == 2) {
//                                print("Successfully get account info \(statusCode) \(result!)")
//                                Key.shared.userPhoneVerified = true
//                                self.updatePhoneDelegate?.updatePhone()
//                            } else {
//                                print("Fail to get account info \(statusCode) \(result!)")
//                            }
//                        }
                        if self.enterPhoneMode == .settings {
                            let vc = UpdateUsrnameEmailViewController()
//                            vc.delegate =
                            vc.enterMode = .phone
                            vc.strCountry = self.strCountry + " +" + self.strCountryCode
                            vc.strPhone = self.strPhoneNumber
                            var arrViewControllers = self.navigationController?.viewControllers
                            arrViewControllers?.removeLast()
                            arrViewControllers?.removeLast()
                            arrViewControllers?.append(vc)
                            self.navigationController?.setViewControllers(arrViewControllers!, animated: true)
                        } else if self.enterPhoneMode == .settingsUpdate {
                            let vc = UpdateUsrnameEmailViewController()
                            // vc.delgate
                            vc.enterMode = .phone
                            vc.strCountry = self.strCountry + " +" + self.strCountryCode
                            vc.strPhone = self.strPhoneNumber
                            var arrViewControllers = self.navigationController?.viewControllers
                            arrViewControllers?.removeLast()
                            arrViewControllers?.removeLast()
                            arrViewControllers?.removeLast()
                            arrViewControllers?.append(vc)
                            self.navigationController?.setViewControllers(arrViewControllers!, animated: true)
                        } else {  // from contacts
                            self.delegate?.verifyPhoneSucceed()
                            self.dismiss(animated: false)
                        }
                    }
                } else {
                    for _ in 0..<6 {
                        _ = self.verificationCodeView.addDigit(-1)
                    }
                    if self.enterPhoneMode == .contacts {
                        self.lblTitle.text = "Oops... That's not the right\ncode. Please try again!"
                    } else {
                        self.lblTitle.text = "That's an Incorrect Code!\n Please Try Again!"
                    }
                    self.btnContinue.isEnabled = false
                    self.btnContinue.backgroundColor = UIColor._255160160()
                }
                self.indicatorView.stopAnimating()
            }
        }
    }
    
    // FAENumberKeyboardDelegate
    func keyboardButtonTapped(_ num: Int) {
        let num = verificationCodeView.addDigit(num)
        // means the user entered 6 digits
        if num == 6 {
            btnContinue.isEnabled = true
            btnContinue.backgroundColor = UIColor._2499090()
        }
        else {
            btnContinue.isEnabled = false
            btnContinue.backgroundColor = UIColor._255160160()
        }
    }

    func startTimer() {
        btnResendCode.setAttributedTitle(NSAttributedString(string: "Resend Code 60", attributes: [NSForegroundColorAttributeName: UIColor._2499090(), NSFontAttributeName: UIFont(name: "AvenirNext-Medium", size: 13)!]), for: UIControlState())
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
    }
    
    func updateTime() {
        if(remainingTime > 0) {
            self.btnResendCode.setAttributedTitle(NSAttributedString(string: "Resend Code \(remainingTime)", attributes: [NSForegroundColorAttributeName: UIColor._2499090(), NSFontAttributeName: UIFont(name: "AvenirNext-Medium", size: 13)!]), for: UIControlState())
            remainingTime = remainingTime - 1
        }
        else {
            remainingTime = 59
            timer.invalidate()
            timer = nil
            self.btnResendCode.setAttributedTitle(NSAttributedString(string: "Resend Code", attributes: [NSForegroundColorAttributeName: UIColor._2499090(), NSFontAttributeName: UIFont(name: "AvenirNext-Bold", size: 13)!]), for: UIControlState())
            self.btnResendCode.addTarget(self, action: #selector(resendVerificationCode), for: .touchUpInside )
        }
    }
    
    func resendVerificationCode() {
        if enterMode == .email {
            postToURL("reset_login/code", parameter: ["email": strEmail as AnyObject], authentication: nil, completion: {(statusCode, result) in })
        } else {
            postToURL("reset_login/code", parameter: ["phone": "(" + strCountryCode + ")" + strPhoneNumber as AnyObject], authentication: nil, completion: {(statusCode, result) in })
        }
        startTimer()
        btnResendCode.removeTarget(self, action: #selector(resendVerificationCode), for: .touchUpInside)
    }
    
    // UpdateUsrnameEmailDelegate
    func updateEmail() {}
    
    func updatePhone() {

    }
}
