//
//  VerifyCodeViewController.swift
//  faeBeta
//
//  Created by Faevorite 2 on 2017-10-23.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit
import SwiftyJSON

@objc protocol VerifyCodeDelegate {
    @objc optional func verifyPhoneSucceed()
    @objc optional func verifyEmailSucceed()
}

enum EnterVerifyCodeMode {
    case email, phone, oldPswd
}

enum EnterEmailMode {
    case signInSupport, settings, signup
}

class VerifyCodeViewController: UIViewController, FAENumberKeyboardDelegate {
    // MARK: - Properties
    var enterMode: EnterVerifyCodeMode = .email
    var enterPhoneMode: EnterPhoneMode = .settings
    var enterEmailMode: EnterEmailMode = .settings
    var enterFrom: EnterFromMode!
    private var lblTitle: UILabel!
    private var lblPhoneNumber: UILabel!
    private var btnResendCode: UIButton!
    private var btnContinue: UIButton!
    private var verificationCodeView: FAEVerificationCodeView!
    private var indicatorView: UIActivityIndicatorView!
    private var numberKeyboard: FAENumberKeyboard!
    private var uiviewAlert: UIView!
    private var timer: Timer!
    private var remainingTime = 59
    
    var strCountry = ""
    var strCountryCode = ""
    var strPhoneNumber = ""
    var strVerified = ""
    var boolUpdateEmail = false
    weak var delegate: VerifyCodeDelegate?
    var faeUser = FaeUser()
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        loadNavBar()
        loadContent()
        createActivityIndicator()
        startTimer()
    }
    
    private func loadNavBar() {
        let uiviewNavBar = FaeNavBar(frame: .zero)
        view.addSubview(uiviewNavBar)
        uiviewNavBar.leftBtn.setImage(#imageLiteral(resourceName: "NavigationBackNew"), for: .normal)

        uiviewNavBar.loadBtnConstraints()
        if enterEmailMode == .signup || enterPhoneMode == .signup {
            uiviewNavBar.rightBtn.setImage(UIImage(), for: .normal)
            uiviewNavBar.rightBtn.setTitle("Later  ", for: .normal)
            uiviewNavBar.rightBtn.setTitleColor(UIColor._182182182(), for: .normal)
            setupLater()
        } else {
            uiviewNavBar.rightBtn.isHidden = true
        }
        uiviewNavBar.leftBtn.addTarget(self, action: #selector(actionBack(_:)), for: .touchUpInside)
        uiviewNavBar.rightBtn.addTarget(self, action: #selector(actionLater(_:)), for: .touchUpInside)
        uiviewNavBar.bottomLine.isHidden = true
    }
    
    private func loadContent() {
        lblTitle = FaeLabel(CGRect(x: 30, y: 75, width: screenWidth - 60, height: 60), .center, .medium, 18, UIColor._898989())
        lblTitle.numberOfLines = 2
        lblTitle.center.x = screenWidth / 2
        lblTitle.adjustsFontSizeToFitWidth = true
        view.addSubview(lblTitle)
        
        verificationCodeView = FAEVerificationCodeView(frame: CGRect(x: 85 * screenWidthFactor, y: 148, width: 244 * screenWidthFactor, height: 82))
        view.addSubview(verificationCodeView)
        
        btnResendCode = UIButton(frame: CGRect(x: 87, y: screenHeight - 244 * screenHeightFactor - 21 - 50 * screenHeightFactor - 67 - device_offset_bot, width: screenWidth - 174, height: 18))
        btnResendCode.setAttributedTitle(NSAttributedString(string: "Resend Code 60", attributes: [NSAttributedStringKey.foregroundColor: UIColor._2499090(), NSAttributedStringKey.font: UIFont(name: "AvenirNext-Medium", size: 13)!]), for: UIControlState())
        btnResendCode.contentHorizontalAlignment = .center
        btnResendCode.sizeToFit()
        btnResendCode.center.x = screenWidth / 2
        view.addSubview(btnResendCode)
        
        // set up the send button
        btnContinue = UIButton(frame: CGRect(x: 57, y: screenHeight - 244 * screenHeightFactor - 21 - 50 * screenHeightFactor - device_offset_bot, width: screenWidth - 114 * screenWidthFactor * screenWidthFactor, height: 50 * screenHeightFactor))
        btnContinue.center.x = screenWidth / 2
        btnContinue.setTitleColor(.white, for: .normal)
        btnContinue.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 20)
        btnContinue.layer.cornerRadius = 25 * screenHeightFactor
        btnContinue.isEnabled = false
        btnContinue.backgroundColor = UIColor._255160160()
        btnContinue.addTarget(self, action: #selector(actionVerifyCode(_:)), for: .touchUpInside)
        view.addSubview(btnContinue)
        
        lblPhoneNumber = UILabel(frame: CGRect(x: 87, y: screenHeight - 244 * screenHeightFactor - 21 - 50 * screenHeightFactor - 43 - device_offset_bot, width: screenWidth - 174, height: 27))
        lblPhoneNumber.font = UIFont(name: "AvenirNext-Regular", size: 20)
        lblPhoneNumber.textColor = UIColor._155155155()
        lblPhoneNumber.textAlignment = .center
        lblPhoneNumber.text = "+" + strCountryCode + " " + strPhoneNumber
        view.addSubview(lblPhoneNumber)
        
        // setup the fake keyboard for numbers input
        numberKeyboard = FAENumberKeyboard(frame: CGRect(x: 0, y: screenHeight - 244 * screenHeightFactor - device_offset_bot, width: screenWidth, height: 244 * screenHeightFactor))
        view.addSubview(numberKeyboard)
        numberKeyboard.delegate = self
        numberKeyboard.transform = CGAffineTransform(translationX: 0, y: 0)
        
        getTitle()
    }
    
    private func getTitle() {
        if enterMode == .email {
            btnResendCode.frame.origin.y = screenHeight - 244 * screenHeightFactor - 21 - 50 * screenHeightFactor - 36 - device_offset_bot
            lblPhoneNumber.isHidden = true
            switch enterEmailMode {
            case .signInSupport:
                lblTitle.text = "Enter the Code we just sent\nto your Email to Continue."
                btnContinue.setTitle("Continue", for: .normal)
            case .settings:
                lblTitle.text = "Enter the Code we just sent\nto your Email to Verify."
                btnContinue.setTitle("Verify", for: .normal)
            case .signup:
                lblTitle.text = "Verify your Email with the\nCode we sent you."
                btnContinue.setTitle("Finish!", for: .normal)
            }
        } else {
            btnResendCode.frame.origin.y = screenHeight - 244 * screenHeightFactor - 21 - 50 * screenHeightFactor - 67 - device_offset_bot
            switch enterPhoneMode {
            case .signInSupport:
                lblTitle.text = "Enter the Code we just texted\nto your Number to Continue."
                btnContinue.setTitle("Continue", for: .normal)
            case .signup:
                lblTitle.text = "Verify your Phone with the \nCode we texted you."
                btnContinue.setTitle("Finish!", for: .normal)
            default:
                lblTitle.text = "Verify your Number with the \nCode we texted you."
                btnContinue.setTitle("Verify", for: .normal)
            }
        }
    }
    
    private func setupLater() {
        uiviewAlert = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
        uiviewAlert.backgroundColor  = UIColor._107105105_a50()
        uiviewAlert.layer.zPosition = 1
        
        let uiviewLater = UIView(frame: CGRect(x: 0, y: 200, w: 290, h: 208))
        uiviewLater.center.x = screenWidth / 2
        uiviewLater.backgroundColor = .white
        uiviewLater.layer.cornerRadius = 21 * screenWidthFactor
        uiviewAlert.addSubview(uiviewLater)
        
        let lblLaterLine1 = UILabel(frame: CGRect(x: 0, y: 30, w: 185, h: 50))
        lblLaterLine1.center.x = uiviewLater.frame.width / 2
        lblLaterLine1.textAlignment = .center
        lblLaterLine1.lineBreakMode = .byWordWrapping
        lblLaterLine1.numberOfLines = 2
        lblLaterLine1.text = "You can verify your\nEmail later in Settings"
        lblLaterLine1.textColor = UIColor._898989()
        lblLaterLine1.font = UIFont(name: "AvenirNext-Medium", size: 18 * screenHeightFactor)
        uiviewLater.addSubview(lblLaterLine1)
        
        let lblLaterLine2 = UILabel(frame: CGRect(x: 0, y: 93, w: 206, h: 36))
        lblLaterLine2.center.x = uiviewLater.frame.width / 2
        lblLaterLine2.textAlignment = .center
        lblLaterLine2.lineBreakMode = .byWordWrapping
        lblLaterLine2.numberOfLines = 2
        lblLaterLine2.text = "You need a verified Email to use it\nfor Log In and Password Reset."
        lblLaterLine2.textColor = UIColor._138138138()
        lblLaterLine2.font = UIFont(name: "AvenirNext-Medium", size: 13 * screenHeightFactor)
        uiviewLater.addSubview(lblLaterLine2)
        
        let btnContinue = UIButton(frame: CGRect(x: 0, y: 149, w: 208, h: 39))
        btnContinue.center.x = uiviewLater.frame.width / 2
        btnContinue.setTitle("Continue", for: .normal)
        btnContinue.setTitleColor(UIColor.white, for: .normal)
        btnContinue.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 18 * screenHeightFactor)
        btnContinue.backgroundColor = UIColor._2499090()
        btnContinue.addTarget(self, action: #selector(laterContinue), for: .touchUpInside)
        btnContinue.layer.borderWidth = 2
        btnContinue.layer.borderColor = UIColor._2499090().cgColor
        btnContinue.layer.cornerRadius = 19 * screenWidthFactor
        uiviewLater.addSubview(btnContinue)
        
        let btnDismiss = UIButton(frame: CGRect(x: 15, y: 15, w: 17, h: 17))
        btnDismiss.setImage(UIImage.init(named: "btn_close"), for: .normal)
        btnDismiss.addTarget(self, action: #selector(laterDismiss), for: .touchUpInside)
        uiviewLater.addSubview(btnDismiss)
        
        view.addSubview(uiviewAlert)
        uiviewAlert.isHidden = true
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
    private func actionSendCode() {
        indicatorView.startAnimating()
        view.endEditing(true)
        let user = FaeUser()
        user.whereKey("phone", value: "(" + strCountryCode + ")" + strPhoneNumber)
        user.updatePhoneNumber {(status, message) in
            print("[UPDATE PHONE] \(status) \(message!)")
            if status / 100 == 2 {
                
            } else {// TODO: error code undecided
                
            }
            self.indicatorView.stopAnimating()
        }
    }
    
    @objc private func actionBack(_ sender: UIButton) {
        if enterMode == .phone && enterPhoneMode == .contacts {
            dismiss(animated: false)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    @objc private func actionLater(_ sender: UIButton) {
        uiviewAlert.isHidden = false
    }
    
    @objc private func laterContinue() {
        let nextRegister = RegisterConfirmViewController()
        nextRegister.faeUser = self.faeUser
        navigationController?.pushViewController(nextRegister, animated: true)
    }
    
    @objc private func laterDismiss() {
        uiviewAlert.isHidden = true
    }
    
    @objc private func actionVerifyCode(_ sender: UIButton) {
        indicatorView.startAnimating()
        if enterMode == .email {
            faeUser.whereKey("email", value: strVerified)
            faeUser.whereKey("code", value: verificationCodeView.displayValue)
            print("email: \(strVerified) code: \(verificationCodeView.displayValue)")
            // reset_login veify
            switch enterEmailMode {
            case .signInSupport:
                faeUser.validateCode{ (statusCode, result) in
                    if statusCode / 100 == 2 {
                        let controller = SignInSupportNewPassViewController()
                        controller.enterMode = self.enterMode
                        controller.enterFrom = self.enterFrom
                        controller.email = self.strVerified
                        controller.code = self.verificationCodeView.displayValue
                        self.navigationController?.pushViewController(controller, animated: true)
                    } else if statusCode == 500 {
                        self.setVerifyResult("Internal Service Error!", resetCodeView: false)
                    } else { // TODO: error code undecided, 403-4 time out
                        let resultJSON = JSON(result!)
                        if let error_code = resultJSON["error_code"].string {
                            handleErrorCode(.auth, error_code, { (prompt) in
                                self.setVerifyResult(prompt)
                            })
                        }
                    }
                    self.indicatorView.stopAnimating()
                }
            case .settings, .signup:
                faeUser.verifyEmail {(status: Int, message: Any?) in
                    if status / 100 == 2 {
                        if self.enterEmailMode == .settings {
                            Key.shared.userEmailVerified = true
                            if self.boolUpdateEmail {
                                let vc = UpdateUsrnameEmailViewController()
                                vc.enterMode = .email
                                vc.strEmail = self.strVerified
                                var arrViewControllers = self.navigationController?.viewControllers
                                arrViewControllers?.removeLast()
                                arrViewControllers?.removeLast()
                                arrViewControllers?.removeLast()
                                vc.delegate = arrViewControllers?.last as! SetAccountViewController
                                arrViewControllers?.append(vc)
                                self.navigationController?.setViewControllers(arrViewControllers!, animated: true)
                            } else {
                                self.delegate?.verifyEmailSucceed!()
                                self.navigationController?.popViewController(animated: true)
                            }
                        } else {
                            Key.shared.userEmailVerified = true
                            let nextRegister = RegisterConfirmViewController()
                            nextRegister.faeUser = self.faeUser
                            self.navigationController?.pushViewController(nextRegister, animated: true)
                        }
                    } else if status == 500 {
                        self.setVerifyResult("Internal Service Error!", resetCodeView: false)
                    } else { // TODO: error code done
                        let messageJSON = JSON(message!)
                        if let error_code = messageJSON["error_code"].string {
                            handleErrorCode(.auth, error_code, { (prompt) in
                                self.setVerifyResult(prompt)
                            })
                        }
                    }
                    self.indicatorView.stopAnimating()
                }
            }
        } else {
            faeUser.whereKey("phone", value: "(" + strCountryCode + ")" + strPhoneNumber)
            faeUser.whereKey("code", value: verificationCodeView.displayValue)
            switch enterPhoneMode {
            case .signInSupport, .signup:
                if enterPhoneMode == .signInSupport {
                    strVerified.contains("@") ? faeUser.whereKey("email", value: strVerified) : faeUser.whereKey("user_name", value: strVerified)
                }
                faeUser.validateCode {(status: Int, message: Any?) in
                    if status / 100 == 2 {
                        if self.enterPhoneMode == .signInSupport {
                            let controller = SignInSupportNewPassViewController()
                            controller.enterMode = self.enterMode
                            controller.phone = "(" + self.strCountryCode + ")" + self.strPhoneNumber
                            controller.code = self.verificationCodeView.displayValue
                            controller.strVerified = self.strVerified
                            self.navigationController?.pushViewController(controller, animated: true)
                        } else {
                            let nextRegister = RegisterConfirmViewController()
                            nextRegister.faeUser = self.faeUser
                            self.navigationController?.pushViewController(nextRegister, animated: true)
                        }
                    } else if status == 500 {
                        self.setVerifyResult("Internal Service Error!", resetCodeView: false)
                    } else { // TODO: error code undecided
                        let messageJSON = JSON(message!)
                        if let error_code = messageJSON["error_code"].string {
                            handleErrorCode(.auth, error_code, { (prompt) in
                                self.setVerifyResult(prompt)
                            })
                        }
                    }
                    self.indicatorView.stopAnimating()
                }
            case .settings, .settingsUpdate, .contacts:
                faeUser.verifyPhoneNumber {(status, message) in
                    if status / 100 == 2 {
                        switch self.enterPhoneMode {
                        case .settings:
                            let vc = UpdateUsrnameEmailViewController()
                            vc.enterMode = .phone
                            vc.strCountry = self.strCountry + " +" + self.strCountryCode
                            vc.strPhone = self.strPhoneNumber
                            var arrViewControllers = self.navigationController?.viewControllers
                            arrViewControllers?.removeLast()
                            arrViewControllers?.removeLast()
                            vc.delegate = arrViewControllers?.last as! SetAccountViewController
                            arrViewControllers?.append(vc)
                            self.navigationController?.setViewControllers(arrViewControllers!, animated: true)
                        case .settingsUpdate:
                            let vc = UpdateUsrnameEmailViewController()
                            vc.enterMode = .phone
                            vc.strCountry = self.strCountry + " +" + self.strCountryCode
                            vc.strPhone = self.strPhoneNumber
                            var arrViewControllers = self.navigationController?.viewControllers
                            arrViewControllers?.removeLast()
                            arrViewControllers?.removeLast()
                            arrViewControllers?.removeLast()
                            vc.delegate = arrViewControllers?.last as! SetAccountViewController
                            arrViewControllers?.append(vc)
                            self.navigationController?.setViewControllers(arrViewControllers!, animated: true)
                        case .contacts:
                            self.delegate?.verifyPhoneSucceed!()
                            self.dismiss(animated: false)
                        default: break
                        }
                    } else if status == 500 {
                        self.setVerifyResult("Internal Service Error!", resetCodeView: false)
                    } else { // TODO: error code undecided, error message
                        let messageJSON = JSON(message!)
                        if let error_code = messageJSON["error_code"].string {
                            handleErrorCode(.auth, error_code, { (prompt) in
                                self.setVerifyResult(prompt)
                            })
                                /*if self.enterPhoneMode == .contacts {
                                    self.lblTitle.text = "Oops... That's not the right\ncode. Please try again!"
                                } else {
                                    self.lblTitle.text = "That's an Incorrect Code!\n Please Try Again!"
                                }*/
                        }
                    }
                    self.indicatorView.stopAnimating()
                }
            }
        }
    }
    
    // MARK: - Helper methods
    private func setVerifyResult(_ prompt: String, resetCodeView isReset: Bool = true) {
        lblTitle.text = prompt
        if isReset {
            for _ in 0..<6 { verificationCodeView.addDigit(-1) }
            btnContinue.isEnabled = false
            btnContinue.backgroundColor = UIColor._255160160()
        }
    }

    private func startTimer() {
        btnResendCode.setAttributedTitle(NSAttributedString(string: "Resend Code 60", attributes: [NSAttributedStringKey.foregroundColor: UIColor._2499090(), NSAttributedStringKey.font: UIFont(name: "AvenirNext-Medium", size: 13)!]), for: UIControlState())
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
    }
    
    @objc private func updateTime() {
        if remainingTime > 0 {
            self.btnResendCode.setAttributedTitle(NSAttributedString(string: "Resend Code \(remainingTime)", attributes: [NSAttributedStringKey.foregroundColor: UIColor._2499090(), NSAttributedStringKey.font: UIFont(name: "AvenirNext-Medium", size: 13)!]), for: UIControlState())
            remainingTime = remainingTime - 1
        } else {
            remainingTime = 59
            timer.invalidate()
            timer = nil
            btnResendCode.setAttributedTitle(NSAttributedString(string: "Resend Code", attributes: [NSAttributedStringKey.foregroundColor: UIColor._2499090(), NSAttributedStringKey.font: UIFont(name: "AvenirNext-Bold", size: 13)!]), for: UIControlState())
            btnResendCode.removeTarget(nil, action: nil, for: .touchUpInside)
            btnResendCode.addTarget(self, action: #selector(resendVerificationCode), for: .touchUpInside)
        }
    }
    
    @objc private func resendVerificationCode() {
        if enterMode == .email { // TODO: error code undecided
            postToURL("reset_login/code", parameter: ["email": strVerified], authentication: nil, completion: {(statusCode, result) in })
        } else {
            actionSendCode()
        }
        startTimer()
        btnResendCode.removeTarget(self, action: #selector(resendVerificationCode), for: .touchUpInside)
    }
    
    // MARK: - FAENumberKeyboardDelegate
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
}
