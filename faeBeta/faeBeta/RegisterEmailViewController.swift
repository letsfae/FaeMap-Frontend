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
    var uiviewEmailExist: UIView!
    var imgError: UIImageView!
    var lblCont: UILabel!
    var lblAlreadyRegister: UILabel!
    var btnLogin: UIButton!
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        createTopView("ProgressBar2")
        createTableView(59 + 135 * screenHeightFactor)
        uiviewEmailExist = thisEmailIsAlreadyView()
        createBottomView(uiviewEmailExist)
        registerCell()
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    // MARK: - Functions
    func thisEmailIsAlreadyView() -> UIView {
        let uiviewEmailAlready = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 36))
        lblCont = UILabel(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 36))
        lblCont.numberOfLines = 2
        lblCont.textAlignment = .center
        lblCont.textColor = UIColor._138138138()
        lblCont.font = UIFont(name: "AvenirNext-Medium", size: 13)
        lblCont.text = "You need to Verify your Email in Account \nSettings to use it for Log In and more."
        uiviewEmailAlready.addSubview(lblCont)
        
        lblAlreadyRegister = UILabel(frame: CGRect(x: view.frame.size.width/2.0 - 118, y: 18, width: 190, height: 25))
        lblAlreadyRegister.attributedText = NSAttributedString(string: "This email is already registered! ", attributes: [NSFontAttributeName: UIFont(name: "AvenirNext-Medium", size: 13)!,
            NSForegroundColorAttributeName: UIColor._2499090()]
        )
        uiviewEmailAlready.addSubview(lblAlreadyRegister)
        
        btnLogin = UIButton(frame: CGRect(x: view.frame.size.width/2.0 + 73, y: 18, width: 45, height: 25))
        let astrTitle = "Log In!"
        let attribute = [ NSFontAttributeName: UIFont(name: "AvenirNext-Bold", size: 13)!, NSForegroundColorAttributeName: UIColor._2499090()]
        let attrLogin = NSMutableAttributedString(string: astrTitle, attributes: attribute)
        btnLogin.setAttributedTitle(attrLogin, for: UIControlState())
        btnLogin.addTarget(self, action: #selector(self.loginButtonTapped), for: .touchUpInside)
        
        lblAlreadyRegister.isHidden = true
        btnLogin.isHidden = true
        
        uiviewEmailAlready.addSubview(btnLogin)
        return uiviewEmailAlready
    }
    
    func loginButtonTapped() {
        let boardLoginController = LogInViewController()
        self.navigationController?.pushViewController(boardLoginController, animated: true)
    }
    
    override func backButtonPressed() {
        view.endEditing(true)
        _ = navigationController?.popViewController(animated: false)
    }
    
    override func continueButtonPressed() {
        checkForUniqueEmail()
    }
    
    func jumpToRegisterUsername() {
        let boardRegister = RegisterUsernameViewController()
        boardRegister.faeUser = faeUser!
        self.navigationController?.pushViewController(boardRegister, animated: false)
    }
    
    func validation() {
        var boolIsValid = false
        boolIsValid = email != nil && email?.count > 0 && isValidEmail(email!)
        enableContinueButton(boolIsValid)
    }
    
    func checkForUniqueEmail() {
        faeUser.whereKey("email", value: email!)
        showActivityIndicator()
        faeUser.checkEmailExistence {(status, message) in DispatchQueue.main.async(execute: {
            if status/100 == 2 {
                    let value = (message as! NSDictionary).value(forKey: "existence")
                    if (value != nil) {
                        if value as! NSNumber == 0 {
                            self.lblCont.isHidden = false
                            self.lblAlreadyRegister.isHidden = true
                            self.btnLogin.isHidden = true
                            self.checkForValidEmail(self.email!, completion: self.jumpToRegisterUsername)
                        } else {
                            self.lblCont.isHidden = true
                            self.lblAlreadyRegister.isHidden = false
                            self.btnLogin.isHidden = false
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
    
    func isValidEmail(_ testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let range = testStr.range(of: emailRegEx, options:.regularExpression)
        let result = range != nil ? true : false
        return result
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
            cell.setTitleLabelText("Use your Email to Log In \nand Verifications")
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SubTitleTableViewCellIdentifier") as! SubTitleTableViewCell
            cell.setSubTitleLabelText("Enter your Email Address")
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
            lblAlreadyRegister.isHidden = true
            btnLogin.isHidden = true
            imgError.isHidden = true
            lblCont.isHidden = false
            break
        default: break
        }
        validation()
    }
}
