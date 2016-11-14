//
//  RegisterEmailViewController.swift
//  faeBeta
//
//  Created by blesssecret on 8/15/16.
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
    
    // MARK: - Variables
    
    var emailTableViewCell: RegisterTextfieldTableViewCell!
    var email: String?
    var faeUser: FaeUser!
    var emailExistLabel: UIView!
    var errorImage: UIImageView!
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        createTopView("ProgressBar2")
        createTableView(59 + 135 * screenHeightFactor)
        emailExistLabel = thisEmailIsAlreadyView()
        createBottomView(emailExistLabel)
        
        registerCell()
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        emailTableViewCell.makeFirstResponder()
    }
    
    // MARK: - Functions
    
    func thisEmailIsAlreadyView() -> UIView {
        let thisEmailIsAlreadyView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 25))
        
        let label = UILabel(frame: CGRect(x: view.frame.size.width/2.0 - 118, y: 0, width: 190, height: 25))
        label.attributedText = NSAttributedString(string: "This email is already registered! ", attributes: [NSFontAttributeName: UIFont(name: "AvenirNext-Medium", size: 13)!,
            NSForegroundColorAttributeName: UIColor.faeAppRedColor()]
        )
        thisEmailIsAlreadyView.addSubview(label)
        
        let button = UIButton(frame: CGRect(x: view.frame.size.width/2.0 + 73, y: 0, width: 45, height: 25))
        let titleString = "Log In!"
        let attribute = [ NSFontAttributeName: UIFont(name: "AvenirNext-Bold", size: 13)!,
                          NSForegroundColorAttributeName: UIColor.faeAppRedColor()]
        let myAttrString = NSMutableAttributedString(string: titleString, attributes: attribute)
        
        button.setAttributedTitle(myAttrString, for: UIControlState())
        button.addTarget(self, action: #selector(self.loginButtonTapped), for: .touchUpInside)
        

        thisEmailIsAlreadyView.addSubview(button)
        thisEmailIsAlreadyView.isHidden = true
        return thisEmailIsAlreadyView
    }
    
    func loginButtonTapped() {
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LogInViewController")as! LogInViewController
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    override func backButtonPressed() {
        view.endEditing(true)
        _ = navigationController?.popViewController(animated: false)
    }
    
    override func continueButtonPressed() {
        checkForUniqueEmail()
    }
    
    func jumpToRegisterUsername() {
        let vc = UIStoryboard(name: "Main", bundle: nil) .instantiateViewController(withIdentifier: "RegisterUsernameViewController")as! RegisterUsernameViewController
        vc.faeUser = faeUser!
        self.navigationController?.pushViewController(vc, animated: false)
    }
    
    func validation() {
        var isValid = false
        
        isValid = email != nil && email?.characters.count > 0 && isValidEmail(email!)
        enableContinueButton(isValid)
    }
    
    func checkForUniqueEmail() {
        faeUser.whereKey("email", value: email!)
        showActivityIndicator()
        faeUser.checkEmailExistence { (status, message) in
            DispatchQueue.main.async(execute: {
                
                if status/100 == 2 {
                    let value = (message as AnyObject).value(forKey: "existence")
                    if (value != nil) {
                        if value! as! Int == 0 {
                            self.emailExistLabel.isHidden = true
                            self.checkForValidEmail(self.email!, completion: self.jumpToRegisterUsername)
//                            self.jumpToRegisterUsername()
                        } else {
                            self.emailExistLabel.isHidden = false
                            self.hideActivityIndicator()
                        }
                    }
                }else{
                    self.hideActivityIndicator()
                }
            })
            
        }
    }
    
    func checkForValidEmail(_ email: String, completion: @escaping () -> Void){
        let URL = "https://apilayer.net/api/check?access_key=6f981d91c2bc1196705ae37e32606c32&email=" + email + "&smtp=1&format=1"
        Alamofire.request(URL).responseJSON{
            response in
            self.hideActivityIndicator()
            if response.response != nil{
                let json = JSON(response.result.value!)
                if(json["mx_found"].bool != nil && json["mx_found"].bool!){
                    completion()
                }else{
                    self.errorImage.isHidden = false
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
        
        tableView.register(UINib(nibName: "TitleTableViewCell", bundle: nil), forCellReuseIdentifier: "TitleTableViewCellIdentifier")
        tableView.register(UINib(nibName: "SubTitleTableViewCell", bundle: nil), forCellReuseIdentifier: "SubTitleTableViewCellIdentifier")
        tableView.register(UINib(nibName: "RegisterTextfieldTableViewCell", bundle: nil), forCellReuseIdentifier: "RegisterTextfieldTableViewCellIdentifier")
        
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
            cell.setTitleLabelText("Use your Email to Log In and \nEasily Connect to People!")
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SubTitleTableViewCellIdentifier") as! SubTitleTableViewCell
            cell.setSubTitleLabelText("Enter your Email Address")
            return cell
        case 2:
            if emailTableViewCell == nil {
                emailTableViewCell = tableView.dequeueReusableCell(withIdentifier: "RegisterTextfieldTableViewCellIdentifier") as! RegisterTextfieldTableViewCell
                emailTableViewCell.setPlaceholderLabelText("Email Address", indexPath: indexPath)
                emailTableViewCell.delegate = self
                emailTableViewCell.textfield.keyboardType = .emailAddress
                errorImage = UIImageView(frame: CGRect(x: screenWidth - 30, y: 37 * screenHeightFactor - 9, width: 6, height: 17))
                errorImage.image = UIImage(named:"exclamation_red_new")
                errorImage.isHidden = true
                emailTableViewCell.contentView.addSubview(errorImage)
                
            }
            return emailTableViewCell
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
            emailTableViewCell.endAsResponder()
            break
        default: break
        }
    }
    
    func textFieldDidChange(_ text: String, indexPath: IndexPath) {
        switch indexPath.row {
        case 2:
            email = text
            emailExistLabel.isHidden = true
            errorImage.isHidden = true
            break
        default: break
        }
        validation()
    }
}

