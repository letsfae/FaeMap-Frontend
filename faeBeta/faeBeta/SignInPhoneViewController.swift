//
//  SignInPhoneViewController.swift
//  faeBeta
//
//  Created by Faevorite 2 on 2017-09-11.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit
import SwiftyJSON

protocol SignInPhoneDelegate: class {
    func backToContacts()
    func backToAddFromContacts()
}

enum EnterPhoneMode {
    case contacts
    case signInSupport
    case settings
    case settingsUpdate
    case signup
}

class SignInPhoneViewController: UIViewController, FAENumberKeyboardDelegate, CountryCodeDelegate, VerifyCodeDelegate {
    fileprivate var lblTitle: UILabel!
    fileprivate var lblPhone: UILabel!
    fileprivate var btnCountryCode: UIButton!
    fileprivate var lblCannotFind: UILabel!
    fileprivate var btnResendCode: UIButton!
    fileprivate var btnSendCode: UIButton!
    fileprivate var curtCountry = "United States +1"
    fileprivate var strCountryName = "United States"
    fileprivate var phoneNumber = ""
    fileprivate var pointer = 0
    fileprivate var phoneCode = "1"
    var boolClosePage: Bool = false
    var enterMode: EnterPhoneMode!
    weak var delegate: SignInPhoneDelegate?
    let user = FaeUser()
    var enterFrom: EnterFromMode!
    
    fileprivate var numberKeyboard: FAENumberKeyboard!
    fileprivate var indicatorView: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        setupNavigationBar()
        setupInterface()
        createActivityIndicator()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if boolClosePage {
            dismiss(animated: false)
            delegate?.backToAddFromContacts()
        }
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
        uiviewNavBar.leftBtn.addTarget(self, action: #selector(self.actionBack(_:)), for: .touchUpInside)
        uiviewNavBar.rightBtn.isHidden = true
        uiviewNavBar.bottomLine.isHidden = true
    }
    
    fileprivate func setupInterface() {
        // set up the title label
        lblTitle = FaeLabel(CGRect(x: 30, y: 72 + device_offset_top, width: screenWidth - 60, height: 60), .center, .medium, 20, UIColor._898989())
        lblTitle.numberOfLines = 2
        lblTitle.center.x = screenWidth / 2
        lblTitle.adjustsFontSizeToFitWidth = true
        view.addSubview(lblTitle)
        
        // set up the button of select area code
        btnCountryCode = UIButton(frame: CGRect(x: 15, y: 170 + device_offset_top, width: screenWidth - 30, height: 30))
        btnCountryCode.addTarget(self, action: #selector(actionSelectCountry(_:)), for: .touchUpInside)
        setCountryName()
        view.addSubview(btnCountryCode)
        
        // set up the phone label
        lblPhone = FaeLabel(CGRect(x: 15, y: 250 + device_offset_top, width: screenWidth - 30, height: 34), .center, .regular, 25, UIColor._155155155())
        lblPhone.text = "Phone Number"
        lblPhone.adjustsFontSizeToFitWidth = true
        view.addSubview(lblPhone)
        
        // set up the "We could’t find an account linked \nwith this Phone Number!" label
        lblCannotFind = FaeLabel(CGRect(x: 20, y: screenHeight - 244 * screenHeightFactor - 21 - 50 * screenHeightFactor - 55 - device_offset_bot, width: screenWidth - 40, height: 36), .center, .medium, 13, UIColor._2499090())
        lblCannotFind.numberOfLines = 0
        view.addSubview(lblCannotFind)
        
        // set up the send button
        btnSendCode = UIButton(frame: CGRect(x: 57, y: screenHeight - 244 * screenHeightFactor - 21 - 50 * screenHeightFactor - device_offset_bot, width: screenWidth - 114 * screenWidthFactor * screenWidthFactor, height: 50 * screenHeightFactor))
        btnSendCode.center.x = screenWidth / 2
        btnSendCode.setTitleColor(.white, for: .normal)
        btnSendCode.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 20)
        btnSendCode.layer.cornerRadius = 25 * screenHeightFactor
        btnSendCode.isEnabled = false
        btnSendCode.backgroundColor = UIColor._255160160()
        btnSendCode.addTarget(self, action: #selector(actionSendCode), for: .touchUpInside)
        view.insertSubview(btnSendCode, at: 0)
        
        // setup the fake keyboard for numbers input
        numberKeyboard = FAENumberKeyboard(frame: CGRect(x: 0, y: screenHeight - 244 * screenHeightFactor - device_offset_bot, width: screenWidth, height: 244 * screenHeightFactor))
        view.addSubview(numberKeyboard)
        numberKeyboard.delegate = self
        numberKeyboard.numMode = "phoneNum"
        numberKeyboard.transform = CGAffineTransform(translationX: 0, y: 0)
        
        if enterMode == .signInSupport {
            lblTitle.text = "Enter your Phone Number\nto Reset Password"
            btnSendCode.setTitle("Send Code", for: .normal)
            lblCannotFind.text = "We could’t find an account linked \nwith this Phone Number!"
            lblCannotFind.alpha = 0
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
        let curtCountryAttr = [NSAttributedStringKey.font: UIFont(name: "AvenirNext-Medium", size: 22)!, NSAttributedStringKey.foregroundColor: UIColor._898989()]
        let curtCountryStr = NSMutableAttributedString(string: "", attributes: curtCountryAttr)
        
        let downAttachment = InlineTextAttachment()
        downAttachment.fontDescender = 1
        downAttachment.image = #imageLiteral(resourceName: "downArrow")
        
        curtCountryStr.append(NSAttributedString(attachment: downAttachment))
        curtCountryStr.append(NSAttributedString(string: " \(curtCountry)", attributes: curtCountryAttr))
        
        btnCountryCode.setAttributedTitle(curtCountryStr, for: .normal)
    }
    
    func setupEnteringVerificationCode() {
        let vc = VerifyCodeViewController()
        vc.delegate = self
        vc.enterMode = .phone
        vc.enterPhoneMode = self.enterMode
        vc.enterFrom = enterFrom
        vc.strCountry = strCountryName
        vc.strCountryCode = phoneCode
        vc.strPhoneNumber = phoneNumber
        if self.enterMode == .contacts {
            self.present(vc, animated: false)
        } else {
            self.navigationController?.pushViewController(vc, animated: true)
        }
        self.view.endEditing(true)
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
    
    func setRequestResult(_ prompt: String) {
        lblCannotFind.text = prompt
        lblCannotFind.textColor = UIColor._2499090()
        lblCannotFind.alpha = 1
    }
    
    @objc func actionSendCode() {
        indicatorView.startAnimating()
        self.view.endEditing(true)
        user.whereKey("phone", value: "(" + phoneCode + ")" + phoneNumber)
        if enterMode != .signInSupport {
            user.updatePhoneNumber {(status, message) in
                print("[UPDATE PHONE] \(status) \(message!)")
                if status / 100 == 2 {
                    self.setupEnteringVerificationCode()
                } else if status == 500 {
                    self.setRequestResult("Internal Service Error!")
                } else { // TODO: error code done
                    // no 400 error for now
                    /*let messageJSON = JSON(message!)
                    if let error_code = messageJSON["error_code"].string {
                        if error_code == "" {
                            self.lblCannotFind.text = "The phone number is invalid"
                            self.lblCannotFind.textColor = UIColor._2499090()
                        }
                    }*/
                }
                self.indicatorView.stopAnimating()
            }
        } else {
            user.checkPhoneExistence{(status: Int, message: Any?) in
                if status / 100 == 2 {
                    let phoneJSON = JSON(message!)
                    if phoneJSON.count == 0 {
                        self.indicatorView.stopAnimating()
                        self.setRequestResult("We could’t find an account linked \nwith this Phone Number!")
                    } else {
                        self.user.whereKey("phone", value: "(" + self.phoneCode + ")" + self.phoneNumber)
                        self.user.whereKey("user_name", value: "username23") //TODO jichao: username
                        self.user.resetPassword {(status: Int, message: Any?) in
                            if status / 100 == 2 {
                                self.setupEnteringVerificationCode()
                            } else if status == 500 {
                                self.setRequestResult("Internal Service Error!")
                            } else { // TODO: error code undecided
                                let messageJSON = JSON(message!)
                                if let error_code = messageJSON["error_code"].string {
                                    handleErrorCode(.auth, error_code, { (prompt) in
                                        self.setRequestResult(prompt)
                                    }, "resetByPhone")
                                }
                                print("[SendCodeToPhone Fail] \(status) \(message!)")
                            }
                            self.indicatorView.stopAnimating()
                        }
                    }
                } else if status == 500 { // TODO: error code done
                    self.setRequestResult("Internal Service Error!")
                    self.indicatorView.stopAnimating()
                    print("checkPhoneNumExist failed")
                    // internal service error
                } // no 400 error for now
            }
        }
    }
    
    //MARK: - FAENumberKeyboard delegate
    func keyboardButtonTapped(_ num:Int) {
        // input phone number
        if num >= 0 && pointer < 12 {
            phoneNumber += "\(num)"
            pointer += 1
        } else if num < 0 && pointer > 0 {
            pointer -= 1
            phoneNumber = (phoneNumber as NSString).substring(to: pointer)
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
        lblCannotFind.alpha = 0
    }
    
    func deleteAll() {
        if phoneNumber != "" {
            phoneNumber = ""
            pointer = 0
            lblPhone.text = "Phone Number"
            lblPhone.textColor = UIColor._155155155()
            btnSendCode.isEnabled = false
            btnSendCode.backgroundColor = UIColor._255160160()
        }
    }
    
    @objc func actionBack(_ sender: UIButton) {
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
    
    @objc func actionSelectCountry(_ sender: UIButton) {
        let vc = CountryCodeViewController()
        vc.delegate = self
        present(vc, animated: true)
    }
    
    // CountryCodeDelegate
    func sendSelectedCountry(country: CountryCodeStruct) {
        phoneCode = country.phoneCode
        strCountryName = country.countryName
        curtCountry = strCountryName + " +" + country.phoneCode
        setCountryName()
    }
    
    // VerifyCodeDelegate
    func verifyPhoneSucceed() {
        boolClosePage = true
    }
}
