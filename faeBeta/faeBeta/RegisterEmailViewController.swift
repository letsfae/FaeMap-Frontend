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
    
    var cellTxtEmail: RegisterTextfieldTableViewCell!
    var email: String?
    var faeUser: FaeUser!
    var uiviewAtBottom: UIView!
    var imgError: UIImageView!
    var lblCont: UILabel!
    var lblSecure: UILabel!
    var btnOtherMethod: UIButton!
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        createTopView("ProgressBar5")
        
        createTableView(59 + 135 * screenHeightFactor)
        registerCell()
        tableView.delegate = self
        tableView.dataSource = self
        
        uiviewAtBottom = setupBottomView()
        createBottomView(uiviewAtBottom)
        setUsingPhone()
        
        btnContinue.setTitle("Vevify", for: UIControlState())
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    // MARK: - Functions
    func setupBottomView() -> UIView {
        let uiviewBtm = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 36))
        lblCont = UILabel(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 36))
        lblCont.numberOfLines = 2
        lblCont.textAlignment = .center
        lblCont.textColor = UIColor._138138138()
        lblCont.font = UIFont(name: "AvenirNext-Medium", size: 13)
        //lblCont.text = "You need to Verify your Email in Account \nSettings to use it for Log In and more."
        
        //uiviewEmailAlready.addSubview(lblCont)
        
        lblSecure = UILabel()
        //lblAlreadyRegister = UILabel(frame: CGRect(x: view.frame.size.width/2.0 - 118, y: 18, width: 190, height: 25))
        //lblAlreadyRegister.attributedText = NSAttributedString(string: "Secure using your ", attributes: [NSAttributedStringKey.font: UIFont(name: "AvenirNext-Medium", size: 13)!,
            //NSAttributedStringKey.foregroundColor: UIColor._2499090()]
        //)
        uiviewBtm.addSubview(lblSecure)
        
        //btnLogin = UIButton(frame: CGRect(x: view.frame.size.width/2.0 + 73, y: 18, width: 45, height: 25))
        //let astrTitle = "Phone."
        //let attribute = [ NSAttributedStringKey.font: UIFont(name: "AvenirNext-Bold", size: 13)!, NSAttributedStringKey.foregroundColor: UIColor._2499090()]
        //let attrLogin = NSMutableAttributedString(string: astrTitle, attributes: attribute)
        //btnLogin.setAttributedTitle(attrLogin, for: UIControlState())
        //btnLogin.addTarget(self, action: #selector(self.loginButtonTapped), for: .touchUpInside)
        
        //lblAlreadyRegister.isHidden = true
        //btnLogin.isHidden = true
        btnOtherMethod = UIButton()
        uiviewBtm.addSubview(btnOtherMethod)
        return uiviewBtm
    }
    
    func setUsingPhone() {
        lblSecure.frame = CGRect(x: screenWidth / 2 - 77, y: 18, width: 109, height: 25)
        lblSecure.attributedText = NSAttributedString(string: "Secure using your ", attributes: [NSAttributedStringKey.font: UIFont(name: "AvenirNext-Medium", size: 13)!, NSAttributedStringKey.foregroundColor: UIColor._138138138()])
        
        btnOtherMethod.frame = CGRect(x: screenWidth / 2 + 32, y: 18, width: 47, height: 25)
        let attributedTitle = NSAttributedString(string: "Phone.", attributes: [NSAttributedStringKey.font: UIFont(name: "AvenirNext-Bold", size: 13)!, NSAttributedStringKey.foregroundColor: UIColor._2499090()])
        btnOtherMethod.setAttributedTitle(attributedTitle, for: UIControlState())
        btnOtherMethod.addTarget(self, action: #selector(usingPhoneTapped), for: .touchUpInside)
    }
    
    func setEmailExists() {
        lblSecure.frame = CGRect(x: screenWidth / 2 - 118, y: 18, width: 190, height: 25)
        lblSecure.attributedText = NSAttributedString(string: "This Email is already registered! ", attributes: [NSAttributedStringKey.font: UIFont(name: "AvenirNext-Medium", size: 13)!, NSAttributedStringKey.foregroundColor: UIColor._2499090()])
        
        btnOtherMethod.frame = CGRect(x: screenWidth / 2 + 73, y: 18, width: 45, height: 25)
        let attributedTitle = NSAttributedString(string: "Log In!", attributes: [NSAttributedStringKey.font: UIFont(name: "AvenirNext-Bold", size: 13)!, NSAttributedStringKey.foregroundColor: UIColor._2499090()])
        btnOtherMethod.setAttributedTitle(attributedTitle, for: UIControlState())
        btnOtherMethod.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
    }
    
    @objc func usingPhoneTapped() {
        var arrControllers = navigationController?.viewControllers
        arrControllers?.removeLast()
        let vcPhone = RegisterPhoneViewController()
        vcPhone.faeUser = faeUser
        arrControllers?.append(vcPhone)
        navigationController?.setViewControllers(arrControllers!, animated: true)
    }
    
    @objc func loginButtonTapped() {
        let vcLogin = LogInViewController()
        navigationController?.pushViewController(vcLogin, animated: true)
    }
    
    override func backButtonPressed() {
        view.endEditing(true)
        navigationController?.popViewController(animated: false)
    }
    
    override func continueButtonPressed() {
        checkForUniqueEmail()
    }

    func checkForUniqueEmail() {
        faeUser.whereKey("email", value: email!)
        showActivityIndicator()
        faeUser.checkEmailExistence {(status, message) in DispatchQueue.main.async(execute: {
            if status/100 == 2 {
                    let value = (message as! NSDictionary).value(forKey: "existence")
                    if (value != nil) {
                        if value as! NSNumber == 0 {
                            self.checkForValidEmail(self.email!, completion: self.jumpToEnterCode)
                        } else {
                            self.setEmailExists()
                            self.hideActivityIndicator()
                        }
                    }
                } else {
                    self.hideActivityIndicator()
                }
            })
        }
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
    
    func jumpToEnterCode() {
        //let boardRegister = RegisterUsernameViewController()
        //boardRegister.faeUser = faeUser!
        //self.navigationController?.pushViewController(boardRegister, animated: false)
        self.faeUser.updateEmail {(status: Int, message: Any?) in
            if status / 100 == 2 {
                let vc = VerifyCodeViewController()
                vc.enterMode = .email
                vc.enterEmailMode = .signup
                vc.faeUser = self.faeUser
                self.navigationController?.pushViewController(vc, animated: true)
            } else {
                print("[Update Email Fail] \(status) \(message!)")
            }
            self.hideActivityIndicator()
        }
    }
    
    func registerCell() {
        tableView.register(TitleTableViewCell.self, forCellReuseIdentifier: "TitleTableViewCellIdentifier")
        tableView.register(SubTitleTableViewCell.self, forCellReuseIdentifier: "SubTitleTableViewCellIdentifier")
        tableView.register(RegisterTextfieldTableViewCell.self, forCellReuseIdentifier: "RegisterTextfieldTableViewCellIdentifier")
    }
    
    // MARK: - Memory Management
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension RegisterEmailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TitleTableViewCellIdentifier") as! TitleTableViewCell
            //cell.setTitleLabelText("Use your Email to Log In \nand Verifications")
            cell.setTitleLabelText("Use your Email to Secure\nyour Account.")
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SubTitleTableViewCellIdentifier") as! SubTitleTableViewCell
            //cell.setSubTitleLabelText("Enter your Email Address")
            return cell
        case 2:
            if cellTxtEmail == nil {
                cellTxtEmail = tableView.dequeueReusableCell(withIdentifier: "RegisterTextfieldTableViewCellIdentifier") as! RegisterTextfieldTableViewCell
                cellTxtEmail.setPlaceholderLabelText("Email Address", indexPath: indexPath)
                cellTxtEmail.delegate = self
                cellTxtEmail.textfield.keyboardType = .emailAddress
                imgError = UIImageView(frame: CGRect(x: screenWidth - 30, y: 37 * screenHeightFactor - 9, width: 6, height: 17))
                imgError.image = UIImage(named:"exclamation_red_new")
                imgError.isHidden = true
                cellTxtEmail.contentView.addSubview(imgError)
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
            return 60 * screenHeightFactor
        case 2:
            return 75 * screenHeightFactor
        default:
            return 0
        }
    }
}

extension RegisterEmailViewController: RegisterTextfieldProtocol {
    func textFieldDidBeginEditing(_ indexPath: IndexPath) {
        activeIndexPath = indexPath
    }
    
    func textFieldShouldReturn(_ indexPath: IndexPath) {
        switch indexPath.row {
        case 2:
            cellTxtEmail.endAsResponder()
            break
        default: break
        }
    }
    
    func textFieldDidChange(_ text: String, indexPath: IndexPath) {
        switch indexPath.row {
        case 2:
            email = text
            setUsingPhone()
            break
        default: break
        }
        validation()
    }
    
    func validation() {
        var boolIsValid = false
        boolIsValid = email != nil && email?.count > 0 && isValidEmail(email!)
        enableContinueButton(boolIsValid)
    }
    
    func isValidEmail(_ testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let range = testStr.range(of: emailRegEx, options:.regularExpression)
        let result = range != nil ? true : false
        return result
    }
}
