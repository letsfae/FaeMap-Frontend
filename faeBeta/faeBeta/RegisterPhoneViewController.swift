//
//  RegisterPhoneViewController.swift
//  faeBeta
//
//  Created by Jichao on 2017/11/14.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
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
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l > r
    default:
        return rhs < lhs
    }
}


class RegisterPhoneViewController: RegisterBaseViewController {
    
    var faeUser: FaeUser!
    var uiviewAtBottom: UIView!
    var imgError: UIImageView!
    var lblCont: UILabel!
    var lblSecure: UILabel!
    var btnOtherMethod: UIButton!
    var numKeyPad: FAENumberKeyboard!
    var btnCountryCode: UIButton!
    var lblPhone: UILabel!
    var curtCountry: String = "United States +1"
    var strCountryName: String = "United States"
    var phoneNumber: String = ""
    var pointer: Int = 0
    var phoneCode: String = "1"
    var boolClosePage: Bool = false
    let user = FaeUser()
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        createTopView("ProgressBar5")
        createTableView(59)
        registerCell()
        tableView.delegate = self
        tableView.dataSource = self
        
        uiviewAtBottom = setupBottomView()
        createBottomView(uiviewAtBottom)
        
        setupPhoneInput()
        setUsingEmail()
        setupBtmBtn()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        numKeyPad = FAENumberKeyboard(frame: CGRect(x: 0, y: view.frame.size.height - 244 * screenHeightFactor - device_offset_bot, width: view.frame.size.width, height: 244 * screenHeightFactor))
        view.addSubview(numKeyPad)
        numKeyPad.delegate = self
        uiviewBottom.frame.origin.y = view.frame.height - 244 * screenHeightFactor - uiviewBottom.frame.size.height + 15 - device_offset_bot
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func keyboardWillHide(_ notification: Notification) {
    }
    
    func setupPhoneInput() {
        // set up the button of select area code
        btnCountryCode = UIButton(frame: CGRect(x: 15, y: 170, width: screenWidth - 30, height: 30))
        btnCountryCode.addTarget(self, action: #selector(actionSelectCountry(_:)), for: .touchUpInside)
        setCountryName()
        view.addSubview(btnCountryCode)
        
        // set up the phone label
        lblPhone = FaeLabel(CGRect(x: 15, y: 250, width: screenWidth - 30, height: 34), .center, .regular, 25, UIColor._155155155())
        lblPhone.text = "Phone Number"
        lblPhone.adjustsFontSizeToFitWidth = true
        self.view.addSubview(lblPhone)
    }
    
    func setCountryName() {
        let curtCountryAttr = [NSAttributedStringKey.font: UIFont(name: "AvenirNext-Medium", size: 22)!, NSAttributedStringKey.foregroundColor: UIColor._898989()]
        let curtCountryStr = NSMutableAttributedString(string: "", attributes: curtCountryAttr)
        
        let downAttachment = InlineTextAttachment()
        downAttachment.fontDescender = 1
        downAttachment.image = #imageLiteral(resourceName: "downArrow")
        
        curtCountryStr.append(NSAttributedString(attachment: downAttachment))
        curtCountryStr.append(NSAttributedString(string: " \(curtCountry)", attributes: curtCountryAttr))
        
        btnCountryCode.setAttributedTitle(curtCountryStr, for: .normal)
    }
    
    @objc func actionSelectCountry(_ sender: UIButton) {
        let vc = CountryCodeViewController()
        vc.delegate = self
        present(vc, animated: true)
    }
    
    // MARK: - Functions
    
    func setupBottomView() -> UIView {
        let uiviewBtm = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 36))
        lblSecure = UILabel()
        uiviewBtm.addSubview(lblSecure)
        btnOtherMethod = UIButton()
        uiviewBtm.addSubview(btnOtherMethod)
        return uiviewBtm
    }
    
    func setUsingEmail() {
        lblSecure.frame = CGRect(x: screenWidth / 2 - 74.5, y: 18, width: 109, height: 25)
        lblSecure.attributedText = NSAttributedString(string: "Secure using your ", attributes: [NSAttributedStringKey.font: UIFont(name: "AvenirNext-Medium", size: 13)!, NSAttributedStringKey.foregroundColor: UIColor._138138138()])
        
        btnOtherMethod.frame = CGRect(x: screenWidth / 2 + 34.5, y: 18, width: 40, height: 25)
        let attributedTitle = NSAttributedString(string: "Email.", attributes: [NSAttributedStringKey.font: UIFont(name: "AvenirNext-Bold", size: 13)!, NSAttributedStringKey.foregroundColor: UIColor._2499090()])
        btnOtherMethod.setAttributedTitle(attributedTitle, for: UIControlState())
        btnOtherMethod.addTarget(self, action: #selector(usingEmailTapped), for: .touchUpInside)
    }
    
    func setPhoneExists() {
        lblSecure.frame = CGRect(x: screenWidth / 2 - 118, y: 18, width: 190, height: 25)
        lblSecure.attributedText = NSAttributedString(string: "This Phone is already registered! ", attributes: [NSAttributedStringKey.font: UIFont(name: "AvenirNext-Medium", size: 13)!, NSAttributedStringKey.foregroundColor: UIColor._2499090()])
        
        btnOtherMethod.frame = CGRect(x: screenWidth / 2 + 73, y: 18, width: 45, height: 25)
        let attributedTitle = NSAttributedString(string: "Log In!", attributes: [NSAttributedStringKey.font: UIFont(name: "AvenirNext-Bold", size: 13)!, NSAttributedStringKey.foregroundColor: UIColor._2499090()])
        btnOtherMethod.setAttributedTitle(attributedTitle, for: UIControlState())
        btnOtherMethod.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
    }
    
    func setupBtmBtn() {
        uiviewBottom.frame = CGRect(x: 0, y: screenHeight - 48 - uiviewAtBottom.frame.size.height - 294 * screenHeightFactor, width: screenWidth, height: uiviewAtBottom.frame.size.height + 50 * screenHeightFactor + 48)
        btnContinue.setTitle("Vevify", for: UIControlState())
    }
    
    @objc func usingEmailTapped() {
        var arrControllers = navigationController?.viewControllers
        arrControllers?.removeLast()
        let vcEmail = RegisterEmailViewController()
        vcEmail.faeUser = faeUser
        arrControllers?.append(vcEmail)
        navigationController?.setViewControllers(arrControllers!, animated: true)
    }
    
    @objc func loginButtonTapped() {
        let vcLogin = LogInViewController()
        self.navigationController?.pushViewController(vcLogin, animated: true)
    }
    
    override func backButtonPressed() {
        view.endEditing(true)
        navigationController?.popViewController(animated: false)
    }
    
    override func continueButtonPressed() {
        activityIndicator.startAnimating()
        self.view.endEditing(true)
        user.whereKey("phone", value: "(" + phoneCode + ")" + phoneNumber)
        user.checkPhoneExistence{(status, message) in
            felixprint("\(status) \(message!)")
            if status / 100 == 2 {
                if let numbers = message as? NSArray {
                    if numbers.count == 0 {
                        // this number has no linked account
                        let vc = VerifyCodeViewController()
                        vc.delegate = self
                        vc.enterMode = .phone
                        vc.enterPhoneMode = .signup
                        vc.strCountry = self.strCountryName
                        vc.strCountryCode = self.phoneCode
                        vc.strPhoneNumber = self.phoneNumber
                        vc.faeUser = self.faeUser
                        self.navigationController?.pushViewController(vc, animated: true)
                    } else {
                        self.setPhoneExists()
                    }
                }
            } else {
                felixprint("checkPhoneNumExist failed")
            }
            self.activityIndicator.stopAnimating()
        }
    }
    
    func jumpToRegisterUsername() {
        let boardRegister = RegisterUsernameViewController()
        boardRegister.faeUser = faeUser!
        self.navigationController?.pushViewController(boardRegister, animated: false)
    }

    func registerCell() {
        tableView.register(TitleTableViewCell.self, forCellReuseIdentifier: "TitleTableViewCellIdentifier")
    }
    
    // MARK: - Memory Management
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension RegisterPhoneViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TitleTableViewCellIdentifier") as! TitleTableViewCell
            cell.setTitleLabelText("Use your Phone to Secure\nyour Account.")
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TitleTableViewCellIdentifier") as! TitleTableViewCell
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:
            return 59
        default:
            return 0
        }
    }
}

extension RegisterPhoneViewController: FAENumberKeyboardDelegate {
    func keyboardButtonTapped(_ num: Int) {
        // input phone number
        if num >= 0 && pointer < 12 {
            phoneNumber += "\(num)"
            pointer += 1
        } else if num < 0 && pointer > 0 {
            pointer -= 1
            phoneNumber = String(phoneNumber[...phoneNumber.index(phoneNumber.startIndex, offsetBy: pointer)])
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
            btnContinue.isEnabled = true
            btnContinue.backgroundColor = UIColor._2499090()
        } else {
            btnContinue.isEnabled = false
            btnContinue.backgroundColor = UIColor._255160160()
        }
    }
}

extension RegisterPhoneViewController: CountryCodeDelegate {
    func sendSelectedCountry(country: CountryCodeStruct) {
        phoneCode = country.phoneCode
        strCountryName = country.countryName
        curtCountry = strCountryName + " +" + country.phoneCode
        setCountryName()
    }
}

extension RegisterPhoneViewController: VerifyCodeDelegate {
    // VerifyCodeDelegate
    func verifyPhoneSucceed() {
        boolClosePage = true
    }
    
    func verifyEmailSucceed() {}
}

