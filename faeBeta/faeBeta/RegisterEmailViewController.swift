//
//  RegisterEmailViewController.swift
//  faeBeta
//
//  Created by blesssecret on 8/15/16.
//  Edited by Sophie Wang
//  Copyright © 2016 fae. All rights reserved.
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

class RegisterEmailViewController: RegisterBaseViewController {
    // MARK: - Properties
    private var cellTxtEmail: RegisterTextfieldTableViewCell!
    private var email: String?
    private var uiviewAtBottom: UIView!
    private var imgError: UIImageView!
    private var lblCont: UILabel!
    private var btnClear: UIButton!
    var boolSavedSignup: Bool! = false
    var faeUser: FaeUser!
    
    private var uiviewBackground: UIView!
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        createTopView("ProgressBar5")
        
        createTableView(59 + 135 * screenHeightFactor)
        registerCell()
        tableView.delegate = self
        tableView.dataSource = self
        
        uiviewAtBottom = setupBottomView()
        createBottomView(uiviewAtBottom)
        setupBackConfirm()
        btnContinue.setTitle("Continue", for: UIControlState())
        if let savedEmail = FaeCoreData.shared.readByKey("signup_email") {            
            email = savedEmail as? String
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        validation()
        FaeCoreData.shared.save("signup", value: "email")
    }
    
    func registerCell() {
        tableView.register(TitleTableViewCell.self, forCellReuseIdentifier: "TitleTableViewCellIdentifier")
        tableView.register(SubTitleTableViewCell.self, forCellReuseIdentifier: "SubTitleTableViewCellIdentifier")
        tableView.register(RegisterTextfieldTableViewCell.self, forCellReuseIdentifier: "RegisterTextfieldTableViewCellIdentifier")
    }
    
    func setupBottomView() -> UIView {
        let uiviewBtm = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 36))
        lblCont = UILabel(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 36))
        lblCont.numberOfLines = 2
        lblCont.textAlignment = .center
        lblCont.textColor = UIColor._138138138()
        lblCont.font = UIFont(name: "AvenirNext-Medium", size: 13)
        lblCont.text = "After Verification, you can use your Email\nfor Log In, Sign In Support, and more."
        uiviewBtm.addSubview(lblCont)
        return uiviewBtm
    }
    
    private func setupBackConfirm() {
        uiviewBackground = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
        uiviewBackground.backgroundColor = UIColor._107105105_a50()
        
        let uiviewBackConfirm = UIView(frame: CGRect(x: 0, y: alert_offset_top, w: 290, h: 208))
        uiviewBackConfirm.center.x = screenWidth / 2
        uiviewBackConfirm.backgroundColor = .white
        uiviewBackConfirm.layer.cornerRadius = 21 * screenWidthFactor
        uiviewBackground.addSubview(uiviewBackConfirm)
        
        let lblConfirmLine1 = UILabel(frame: CGRect(x: 0, y: 30, w: 185, h: 50))
        lblConfirmLine1.center.x = uiviewBackConfirm.frame.width / 2
        lblConfirmLine1.textAlignment = .center
        lblConfirmLine1.lineBreakMode = .byWordWrapping
        lblConfirmLine1.numberOfLines = 2
        lblConfirmLine1.text = "Are you sure you want to exit signup?"
        lblConfirmLine1.textColor = UIColor._898989()
        lblConfirmLine1.font = UIFont(name: "AvenirNext-Medium", size: 18 * screenHeightFactor)
        uiviewBackConfirm.addSubview(lblConfirmLine1)
        
        let lblConfirmLine2 = UILabel(frame: CGRect(x: 0, y: 93, w: 185, h: 36))
        lblConfirmLine2.center.x = uiviewBackConfirm.frame.width / 2
        lblConfirmLine2.textAlignment = .center
        lblConfirmLine2.lineBreakMode = .byWordWrapping
        lblConfirmLine2.numberOfLines = 2
        lblConfirmLine2.text = "You may lose access to the account you have begun creating."
        lblConfirmLine2.textColor = UIColor._138138138()
        lblConfirmLine2.font = UIFont(name: "AvenirNext-Medium", size: 13 * screenHeightFactor)
        uiviewBackConfirm.addSubview(lblConfirmLine2)
        
        let btnBackConfirm = UIButton(frame: CGRect(x: 0, y: 149, w: 208, h: 39))
        btnBackConfirm.center.x = uiviewBackConfirm.frame.width / 2
        btnBackConfirm.setTitle("Yes", for: .normal)
        btnBackConfirm.setTitleColor(UIColor.white, for: .normal)
        btnBackConfirm.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 18 * screenHeightFactor)
        btnBackConfirm.backgroundColor = UIColor._2499090()
        btnBackConfirm.addTarget(self, action: #selector(confirmBack), for: .touchUpInside)
        btnBackConfirm.layer.borderWidth = 2
        btnBackConfirm.layer.borderColor = UIColor._2499090().cgColor
        btnBackConfirm.layer.cornerRadius = 19 * screenWidthFactor
        uiviewBackConfirm.addSubview(btnBackConfirm)
        
        let btnDismiss = UIButton(frame: CGRect(x: 15, y: 15, w: 17, h: 17))
        btnDismiss.setImage(UIImage.init(named: "btn_close"), for: .normal)
        btnDismiss.addTarget(self, action: #selector(dismissBack), for: .touchUpInside)
        uiviewBackConfirm.addSubview(btnDismiss)
        
        view.addSubview(uiviewBackground)
        uiviewBackground.isHidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Button actions
    override func backButtonPressed() {
        view.endEditing(true)
        if boolSavedSignup {
            // alert
            uiviewBackground.isHidden = false
        } else {
            if email != nil {
                FaeCoreData.shared.save("signup_email", value: email!)
            }
            navigationController?.popViewController(animated: false)
        }
    }
    
    override func continueButtonPressed() {
        if let savedEmail = FaeCoreData.shared.readByKey("signup_email") {
            if (savedEmail as? String) != email! && Key.shared.is_Login {
                faeUser.whereKey("email", value: email!)
                faeUser.updateEmail({ [weak self] (_, _) in
                    guard let `self` = self else { return }
                    let vc = VerifyCodeViewController()
                    vc.enterMode = .email
                    vc.enterEmailMode = .signup
                    vc.strVerified = self.email!
                    vc.faeUser = self.faeUser
                    self.navigationController?.pushViewController(vc, animated: false)
                })
            } else {
                let vc = VerifyCodeViewController()
                vc.enterMode = .email
                vc.enterEmailMode = .signup
                vc.strVerified = email!
                vc.faeUser = faeUser
                navigationController?.pushViewController(vc, animated: false)
            }
        } else {
            jumpToEnterCode()
        }
    }
    
    private func jumpToEnterCode() {
        faeUser.whereKey("email", value: email!)
        showActivityIndicator()
        faeUser.signUpInBackground { [weak self] (status, message) in
            guard let `self` = self else { return }
            if status / 100 == 2 {
                self.faeUser.keyValue.removeValue(forKey: "email")
                self.faeUser.logInBackground({ (status, message) in
                    //guard let `self` = self else { return }
                    if status / 100 == 2 {
                        self.faeUser.whereKey("email", value: self.email!)
                        self.faeUser.updateEmail { (status, message) in
                            //guard let `self` = self else { return }
                            if status / 100 == 2 {
                                FaeCoreData.shared.save("signup_email", value: self.email!)
                                let vc = VerifyCodeViewController()
                                vc.enterMode = .email
                                vc.enterEmailMode = .signup
                                vc.strVerified = self.email!
                                vc.faeUser = self.faeUser
                                self.navigationController?.pushViewController(vc, animated: false)
                            } else {
                                print("[Update Email Fail] \(status) \(message!)")
                                let messageJSON = JSON(message!)
                                if let error_code = messageJSON["error_code"].string {
                                    handleErrorCode(.auth, error_code, { (prompt) in
                                        // handle
                                        //guard let `self` = self else { return }
                                        self.setErrorMessage("Error! Please try later!")
                                        self.hideActivityIndicator()
                                    })
                                } else {
                                    if status == NSURLErrorTimedOut {
                                        self.setErrorMessage("Time out! Please try later!")
                                    } else {
                                        self.setErrorMessage("Error! Please try later!")
                                    }
                                }
                            }
                            self.hideActivityIndicator()
                        }
                    } else {
                        if status == NSURLErrorTimedOut {
                            self.setErrorMessage("Time out! Please try later!")
                        } else {
                            self.setErrorMessage("Error! Please try later!")
                        }
                        self.hideActivityIndicator()
                    }
                })
            } else {
                let messageJSON = JSON(message!)
                if let error_code = messageJSON["error_code"].string {
                    handleErrorCode(.auth, error_code, { (prompt) in
                        // handle
                        if error_code == "422-3" {
                            self.setEmailExists()
                        } else if error_code == "422-2" {
                            self.setErrorMessage("Error! Please discard this register!\nTry it from the beginning!")
                        } else {
                            self.setErrorMessage("Error! Please try later!")
                        }
                    })
                } else {
                    if status == NSURLErrorTimedOut {
                        self.setErrorMessage("Time out! Please try later!")
                    } else {
                        self.setErrorMessage("Error! Please try later!")
                    }
                }
                self.hideActivityIndicator()
            }
        }
    }
    
    @objc private func clearEmail() {
        cellTxtEmail.clearTextFiled()
        email = ""
        btnClear.isHidden = true
        imgError.isHidden = true
    }
    
    @objc private func confirmBack() {
        FaeCoreData.shared.removeByKey("signup")
        FaeCoreData.shared.removeByKey("signup_first_name")
        FaeCoreData.shared.removeByKey("signup_last_name")
        FaeCoreData.shared.removeByKey("signup_username")
        FaeCoreData.shared.removeByKey("signup_password")
        FaeCoreData.shared.removeByKey("signup_gender")
        FaeCoreData.shared.removeByKey("signup_dateofbirth")
        FaeCoreData.shared.removeByKey("signup_email")
        navigationController?.popViewController(animated: false)
    }
    
    @objc private func dismissBack() {
        uiviewBackground.isHidden = true
    }
    
    // MARK: - Helper methods
    private func setBtmContent() {
        lblCont.text = "After Verification, you can use your Email\nfor Log In, Sign In Support, and more."
        lblCont.textColor = UIColor._138138138()
    }
    
    private func setEmailExists() {
        lblCont.text = "Oops… This Email is already being\nused to Secure an Account."
        lblCont.textColor = UIColor._2499090()
    }
    
    private func setErrorMessage(_ error: String) {
        lblCont.text = error
        lblCont.textColor = UIColor._2499090()
    }
    
    func checkForValidEmail(_ email: String, completion: @escaping () -> Void) {
        let URL = "https://apilayer.net/api/check?access_key=6f981d91c2bc1196705ae37e32606c32&email=" + email + "&smtp=1&format=1"
        Alamofire.request(URL).responseJSON {
            response in
            self.hideActivityIndicator()
            if response.response != nil {
                let json = JSON(response.result.value!)
                if (json["mx_found"].bool != nil && json["mx_found"].bool!) {
                    completion()
                } else {
                    self.imgError.isHidden = false
                }
            }
        }
    }
}

// MARK: - UITableView
extension RegisterEmailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TitleTableViewCellIdentifier") as! TitleTableViewCell
            cell.setTitleLabelText("Use your Email to Secure\nyour Account.")
            return cell
        case 1:
            if cellTxtEmail == nil {
                cellTxtEmail = tableView.dequeueReusableCell(withIdentifier: "RegisterTextfieldTableViewCellIdentifier") as! RegisterTextfieldTableViewCell
                cellTxtEmail.setPlaceholderLabelText("Email Address", indexPath: indexPath)
                cellTxtEmail.delegate = self
                cellTxtEmail.textfield.keyboardType = .emailAddress
                imgError = UIImageView(frame: CGRect(x: 45, y: 0, width: 6, height: 20))
                imgError.center.y = cellTxtEmail.textfield.center.y
                imgError.image = UIImage(named:"exclamation_red_new")
                imgError.isHidden = true
                cellTxtEmail.contentView.addSubview(imgError)
                
                btnClear = UIButton(frame: CGRect(x: screenWidth - 40, y: 0, width: 36.45, height: 36.45))
                btnClear.center.y = cellTxtEmail.textfield.center.y
                btnClear.setImage(#imageLiteral(resourceName: "mainScreenSearchClearSearchBar"), for: .normal)
                btnClear.isHidden = true
                btnClear.addTarget(self, action: #selector(clearEmail), for: .touchUpInside)
                cellTxtEmail.addSubview(btnClear)
                
                if email != nil {
                    cellTxtEmail.textfield.text = email
                }
                
                cellTxtEmail.makeFirstResponder()
            }
            return cellTxtEmail
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TitleTableViewCellIdentifier") as! TitleTableViewCell
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:
            return 59
        case 1:
            return 75 * screenHeightFactor
        default:
            return 0
        }
    }
}

// MARK: - RegisterTextfieldProtocol
extension RegisterEmailViewController: RegisterTextfieldProtocol {
    func textFieldDidBeginEditing(_ indexPath: IndexPath) {
        activeIndexPath = indexPath
    }
    
    func textFieldShouldReturn(_ indexPath: IndexPath) {
        switch indexPath.row {
        case 2:
            cellTxtEmail.endAsResponder()
        default: break
        }
    }
    
    func textFieldDidChange(_ text: String, indexPath: IndexPath) {
        switch indexPath.row {
        case 1:
            email = text
            setBtmContent()
            if text.count != 0 {
                btnClear.isHidden = false
            } else {
                btnClear.isHidden = true
            }
        default: break
        }
        validation()
    }
    
    private func validation() {
        var boolIsValid = false
        boolIsValid = email != nil && email?.count > 0 && isValidEmail(email!)
        enableContinueButton(boolIsValid)
    }
    
    private func isValidEmail(_ testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let range = testStr.range(of: emailRegEx, options:.regularExpression)
        let result = range != nil ? true : false
        return result
    }
}
