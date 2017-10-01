//
//  SignInPhoneViewController.swift
//  faeBeta
//
//  Created by Faevorite 2 on 2017-09-11.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit

protocol SignInPhoneDelegate: class {
    func verifyPhoneSucceed()
    func backToContacts()
}

class SignInPhoneViewController: UIViewController, FAENumberKeyboardDelegate, CountryCodeDelegate {
    enum EnterPhoneMode {
        case contacts
        case signInSupport
        case settings
        case settingsUpdate
    }
    
    fileprivate var lblTitle: UILabel!
    fileprivate var lblPhone: UILabel!
    fileprivate var btnCountryCode: UIButton!
    fileprivate var lblCannotFind: UILabel!
    fileprivate var btnResendCode: UIButton!
    fileprivate var lblPhoneNumber: UILabel!
    fileprivate var btnSendCode: UIButton!
    fileprivate var curtTitle = "United States +1"
    fileprivate var phoneNumber = ""
    fileprivate var pointer = 0
    fileprivate var phoneCode = "1"
    var enterMode: EnterPhoneMode!
    weak var delegate: SignInPhoneDelegate?
    let user = FaeUser()
    
    fileprivate enum pageStateType {
        case enteringPhoneNo
        case enteringCode
    }
    
    fileprivate var statePage = pageStateType.enteringPhoneNo
    fileprivate var numberKeyboard: FAENumberKeyboard!
    fileprivate var verificationCodeView: FAEVerificationCodeView!
    
    fileprivate var timer: Timer!
    fileprivate var remainingTime = 59
    
    fileprivate var indicatorView: UIActivityIndicatorView!
    
    //MARK: - View did/will ...
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        setupNavigationBar()
        setupInterface()
        createActivityIndicator()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func setupNavigationBar() {
        let uiviewNavBar = FaeNavBar(frame: .zero)
        view.addSubview(uiviewNavBar)
        if enterMode != .contacts {
            uiviewNavBar.leftBtn.setImage(#imageLiteral(resourceName: "NavigationBackNew"), for: .normal)
        } else {
            uiviewNavBar.leftBtn.setImage(nil, for: .normal)
            uiviewNavBar.setBtnTitle()
            uiviewNavBar.leftBtnWidth = 57
        }
        uiviewNavBar.loadBtnConstraints()
        uiviewNavBar.leftBtn.addTarget(self, action: #selector(self.navBarLeftButtonTapped), for: .touchUpInside)
        uiviewNavBar.rightBtn.isHidden = true
        uiviewNavBar.bottomLine.isHidden = true
    }
    
    fileprivate func setupInterface() {
        // set up the title label
        lblTitle = UILabel(frame: CGRect(x: 30, y: 72, width: screenWidth - 60, height: 60))
        lblTitle.numberOfLines = 2
        lblTitle.textColor = UIColor._898989()
        lblTitle.font = UIFont(name: "AvenirNext-Medium", size: 20)
        lblTitle.textAlignment = .center
        lblTitle.center.x = screenWidth / 2
        lblTitle.adjustsFontSizeToFitWidth = true
        self.view.addSubview(lblTitle)
        
        // set up the button of select area code
        btnCountryCode = UIButton(frame: CGRect(x: 15, y: 170, width: screenWidth - 30, height: 30))
        btnCountryCode.addTarget(self, action: #selector(actionSelectCountry(_:)), for: .touchUpInside)
        setCountryName()
        view.addSubview(btnCountryCode)
        
        // set up the email/username text field
        lblPhone = UILabel(frame: CGRect(x: 15, y: 250, width: screenWidth - 30, height: 34))
        lblPhone.text = "Phone Number"
        lblPhone.textAlignment = .center
        lblPhone.textColor = UIColor._155155155()
        lblPhone.font = UIFont(name: "AvenirNext-Regular", size: 25)
        lblPhone.adjustsFontSizeToFitWidth = true
        self.view.addSubview(lblPhone)
        
        // set up the "We could’t find an account linked \nwith this Phone Number!" label
        lblCannotFind = UILabel(frame: CGRect(x: 20, y: screenHeight - 244 * screenHeightFactor - 21 - 50 * screenHeightFactor - 55, width: screenWidth - 40, height: 36))
        lblCannotFind.numberOfLines = 0
        lblCannotFind.font = UIFont(name: "AvenirNext-Medium", size: 13)
        lblCannotFind.textAlignment = .center
        view.addSubview(lblCannotFind)
        
        btnResendCode = UIButton(frame: CGRect(x: 87, y: screenHeight - 244 * screenHeightFactor - 21 - 50 * screenHeightFactor - 67, width: screenWidth - 174, height: 18))
        btnResendCode.setAttributedTitle(NSAttributedString(string: "Resend Code 60", attributes: [NSForegroundColorAttributeName: UIColor._2499090(), NSFontAttributeName: UIFont(name: "AvenirNext-Medium", size: 13)!]), for: UIControlState())
        btnResendCode.contentHorizontalAlignment = .center
        btnResendCode.sizeToFit()
        btnResendCode.center.x = screenWidth / 2
        btnResendCode.alpha = 0
        self.view.addSubview(btnResendCode)
        
        lblPhoneNumber = UILabel(frame: CGRect(x: 87, y: screenHeight - 244 * screenHeightFactor - 21 - 50 * screenHeightFactor - 43, width: screenWidth - 174, height: 27))
        lblPhoneNumber.font = UIFont(name: "AvenirNext-Regular", size: 20)
        lblPhoneNumber.textColor = UIColor._155155155()
        lblPhoneNumber.textAlignment = .center
        lblPhoneNumber.alpha = 0
        view.addSubview(lblPhoneNumber)
        
        // set up the send button
        btnSendCode = UIButton(frame: CGRect(x: 57, y: screenHeight - 244 * screenHeightFactor - 21 - 50 * screenHeightFactor, width: screenWidth - 114 * screenWidthFactor * screenWidthFactor, height: 50 * screenHeightFactor))
        btnSendCode.center.x = screenWidth / 2
        btnSendCode.setTitleColor(.white, for: .normal)
        btnSendCode.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 20)
        btnSendCode.layer.cornerRadius = 25 * screenHeightFactor
        btnSendCode.isEnabled = false
        btnSendCode.backgroundColor = UIColor._255160160()
        btnSendCode.addTarget(self, action: #selector(sendCodeButtonTapped), for: .touchUpInside)
        view.insertSubview(btnSendCode, at: 0)
        
        // setup the fake keyboard for numbers input
        numberKeyboard = FAENumberKeyboard(frame: CGRect(x: 0, y: screenHeight - 244 * screenHeightFactor, width: screenWidth, height: 244 * screenHeightFactor))
        view.addSubview(numberKeyboard)
        numberKeyboard.delegate = self
        numberKeyboard.transform = CGAffineTransform(translationX: 0, y: 0)
        
        if enterMode == .signInSupport {
            lblTitle.text = "Enter your Phone Number\nto Reset Password"
            lblCannotFind.textColor = UIColor._2499090()
            lblCannotFind.text = "We could’t find an account linked \nwith this Phone Number!"
            lblCannotFind.alpha = 0
            btnSendCode.setTitle("Send Code", for: .normal)
        } else {
            lblCannotFind.textColor = UIColor._138138138()
            btnSendCode.setTitle("Link", for: .normal)
            if enterMode == .contacts {
                lblTitle.text = "Use Phone Number to Add\n& Invite your Friends"
                lblCannotFind.text = "Get convenient access to your Contacts to\nFind, Add and Invite your Friends!"
            } else if enterMode == .settings {
                lblTitle.text = "\nLink your Phone Number"
                lblCannotFind.text = "You can use your Phone Number for,\nAdding Contacts and Verifications."
            } else {
                lblTitle.text = "\nYour New Phone Number"
                lblCannotFind.text = "You can use your Phone Number for,\nAdding Contacts and Verifications."
            }
        }
    }
    
    fileprivate func setCountryName() {
        let curtTitleAttr = [NSFontAttributeName: UIFont(name: "AvenirNext-Medium", size: 22)!, NSForegroundColorAttributeName: UIColor._898989()]
        let curtTitleStr = NSMutableAttributedString(string: "", attributes: curtTitleAttr)
        
        let downAttachment = InlineTextAttachment()
        downAttachment.fontDescender = 1
        downAttachment.image = #imageLiteral(resourceName: "downArrow")
        
        curtTitleStr.append(NSAttributedString(attachment: downAttachment))
        curtTitleStr.append(NSAttributedString(string: " \(curtTitle)", attributes: curtTitleAttr))
        
        btnCountryCode.setAttributedTitle(curtTitleStr, for: .normal)
    }
    
    func setupEnteringVerificationCode() {
        lblPhoneNumber.text = "+" + phoneCode + " " + phoneNumber
        lblCannotFind.alpha = 0
        if enterMode == .signInSupport {
            lblTitle.text = "Enter the Code we just texted \nto your Number to Continue"
        } else {
            lblTitle.text = "Verify your Number with the \nCode we texted you."
        }
        self.view.endEditing(true)
        
        // setup the verification code screen
        verificationCodeView = FAEVerificationCodeView(frame: CGRect(x: 85 * screenWidthFactor, y: 148, width: 244 * screenWidthFactor, height: 82))
        self.view.addSubview(verificationCodeView)
        verificationCodeView.alpha = 0
        
        btnSendCode.isEnabled = false
        btnSendCode.backgroundColor = UIColor._255160160()
        
        // start transaction animation
        UIView.animate(withDuration: 0.3, delay: 0, options: UIViewAnimationOptions(), animations: {
            if self.enterMode == .signInSupport {
                self.btnSendCode.setTitle("Continue", for: .normal)
            } else {
                self.btnSendCode.setTitle("Verify", for: .normal)
            }
            
            self.btnResendCode.alpha = 1
            self.lblPhoneNumber.alpha = 1
            self.lblPhone.alpha = 0
            self.verificationCodeView.alpha = 1
            
            self.view.layoutIfNeeded()
        }, completion: {_ in
            self.btnCountryCode.isHidden = true
            self.lblPhone.isHidden = true
            self.startTimer()
        })
        statePage = .enteringCode
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
    
    func sendCodeButtonTapped() {
        indicatorView.startAnimating()
        if statePage == .enteringPhoneNo {
            self.view.endEditing(true)
            
            self.setupEnteringVerificationCode()
            self.indicatorView.stopAnimating()
            
            /*  API OK后用
            if enterMode == .signInSupport {
                let user = FaeUser()
                user.whereKey("phone", value: "(" + phoneCode + ")" + phoneNumber)
                user.updatePhoneNumber {(status, message) in
                    if(status / 100 == 2 ) {
                        self.setupEnteringVerificationCode()
                    } else {
                        self.lblCannotFind.alpha = 1
                    }
                    self.indicatorView.stopAnimating()
                }
            } else {
                user.whereKey("phone", value: "(" + phoneCode + ")" + phoneNumber)
                user.updatePhoneNumber {(status, message) in
                    if(status / 100 == 2 ) {
                        self.setupEnteringVerificationCode()
                    } else {
                        self.lblCannotFind.alpha = 1
                        self.lblCannotFind.textColor = UIColor._2499090()
                        self.lblCannotFind.text = "The Phone Number has already \nbeen linked with another account."
                    }
                    self.indicatorView.stopAnimating()
                }
            }
             */
        } else {
            if enterMode == .signInSupport {
                postToURL("reset_login/code/verify", parameter: ["email": lblPhone.text! as AnyObject, "code": verificationCodeView.displayValue as AnyObject], authentication: nil, completion: { (statusCode, result) in
                    if(statusCode / 100 == 2) {
                        let controller = SignInSupportNewPassViewController()
                        controller.email = self.lblPhone.text!
                        controller.code = self.verificationCodeView.displayValue
                        self.navigationController?.pushViewController(controller, animated: true)
                    } else {
                        for _ in 0..<6 {
                            _ = self.verificationCodeView.addDigit(-1)
                        }
                        self.lblTitle.text = "That's an Incorrect Code!\n Please Try Again!"
                        self.btnSendCode.isEnabled = false
                        self.btnSendCode.backgroundColor = UIColor._255160160()
                    }
                    self.indicatorView.stopAnimating()
                })
            } else {
//                user.whereKey("phone/verify", value: "(" + phoneCode + ")" + phoneNumber)
//                user.verifyPhoneNumber {(status, message) in
//                    if(status / 100 == 2 ) {
                        if self.enterMode == .settings {
//                            let vc = LinkPhoneSuccessViewController()
//                            vc.phone = self.lblPhone.text!
//                            self.navigationController?.pushViewController(vc, animated: true)
                        } else {
                            self.delegate?.verifyPhoneSucceed()
                            self.dismiss(animated: true)
                        }
//                    } else {
//                        for _ in 0..<6 {
//                            _ = self.verificationCodeView.addDigit(-1)
//                        }
//                        if self.enterMode == .signInSupport {
//                            self.lblTitle.text = "That's an Incorrect Code!\n Please Try Again!"
//                        } else {
//                            self.lblTitle.text = "Oops... That's not the right\ncode. Please try again!"
//                        }
//                        self.btnSendCode.isEnabled = false
//                        self.btnSendCode.backgroundColor = UIColor._255160160()
//                    }
                    self.indicatorView.stopAnimating()
//                }
            }
        }
    }
    
    //MARK: - FAENumberKeyboard delegate
    func keyboardButtonTapped(_ num:Int) {
        if btnResendCode.alpha == 0 {   // input phone number
            if num >= 0 && pointer < 12 {
                phoneNumber += "\(num)"
                pointer += 1
            } else if num < 0 && pointer > 0 {
                pointer -= 1
                phoneNumber = phoneNumber.substring(to: phoneNumber.index(phoneNumber.startIndex, offsetBy: pointer))
            }
            if phoneNumber == "" {
                lblPhone.text = "Phone Number"
                lblPhone.textColor = UIColor._155155155()
            } else {
                lblPhone.text = phoneNumber
                lblPhone.textColor = UIColor._898989()
            }
            
            let num = pointer
            if num >= 9 {
                btnSendCode.isEnabled = true
                btnSendCode.backgroundColor = UIColor._2499090()
            } else {
                btnSendCode.isEnabled = false
                btnSendCode.backgroundColor = UIColor._255160160()
            }
        } else {
            let num = verificationCodeView.addDigit(num)
            // means the user entered 6 digits
            if num == 6 {
                btnSendCode.isEnabled = true
                btnSendCode.backgroundColor = UIColor._2499090()
            }
            else {
                btnSendCode.isEnabled = false
                btnSendCode.backgroundColor = UIColor._255160160()
            }
        }
    }
    
    //MARK: helper
    func startTimer() {
        btnResendCode.setAttributedTitle(NSAttributedString(string: "Resend Code 60", attributes: [NSForegroundColorAttributeName: UIColor._2499090(), NSFontAttributeName: UIFont(name: "AvenirNext-Medium", size: 13)!]), for: UIControlState())
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
    }
    
    func updateTime()
    {
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
//        postToURL("reset_login/code", parameter: ["phone": lblPhone.text! as AnyObject], authentication: nil, completion: {(statusCode, result) in })
        startTimer()
        btnResendCode.removeTarget(self, action: #selector(resendVerificationCode), for: .touchUpInside)
    }
    
    func navBarLeftButtonTapped() {
        if enterMode == .contacts {
            delegate?.backToContacts()
            dismiss(animated: true)
        } else {
            _ = self.navigationController?.popViewController(animated: true)
        }
    }
    // MARK: - keyboard
    
    //MARK: - helper
    func isValidPhoneNumber(_ testStr:String) -> Bool {
        let result = testStr.count >= 10 ? true : false
        return result
    }
    
    func actionSelectCountry(_ sender: UIButton) {
        let vc = CountryCodeViewController()
        vc.delegate = self
        present(vc, animated: true)
    }
    
    // CountryCodeDelegate
    func sendSelectedCountry(country: CountryCodeStruct) {
        phoneCode = country.phoneCode
        curtTitle = country.countryName + " +" + country.phoneCode
        setCountryName()
    }
}
