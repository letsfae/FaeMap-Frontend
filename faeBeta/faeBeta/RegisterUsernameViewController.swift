//
//  RegisterUsernameViewController.swift
//  faeBeta
//
//  Created by blesssecret on 8/15/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
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


class RegisterUsernameViewController: RegisterBaseViewController {
    
    // Variables
    
    var usernameTableViewCell: RegisterTextfieldTableViewCell!
    var username: String?
    var faeUser: FaeUser!
    var usernameExistLabel: UILabel!
    
    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        createTopView("ProgressBar3")
        createTableView(59 + 135 * screenHeightFactor)
        createBottomView(getErrorView())
        
        registerCell()
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        usernameTableViewCell.makeFirstResponder()
    }
    
    // MARK: - Functions
    
    override func backButtonPressed() {
        view.endEditing(true)
        _ = navigationController?.popViewController(animated: false)
    }
    
    override func continueButtonPressed() {
        checkForUniqueUsername()
    }
    
    func jumpToRegisterPassword() {
        let vc = UIStoryboard(name: "Register", bundle: nil) .instantiateViewController(withIdentifier: "RegisterPasswordViewController") as! RegisterPasswordViewController
        vc.faeUser = faeUser
        self.navigationController?.pushViewController(vc, animated: false)
    }
    
    func getErrorView() -> UIView {
        let errorView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 40))
        
        let errorLabel = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 40))
        errorLabel.textColor = UIColor.init(red: 249/255.0, green: 90/255.0, blue: 90/255.0, alpha: 1.0)
        errorLabel.font = UIFont(name: "AvenirNext-Medium", size: 13)
        errorLabel.numberOfLines = 2
        errorLabel.textAlignment = .center
        errorLabel.text = "This Username is currently Unavailable. \n Choose another One!"
        errorLabel.isHidden = true
        
        usernameExistLabel = errorLabel
        errorView.addSubview(errorLabel)
        
        return errorView
    }
    
    
    func validation() {
        var isValid = false
        
        let userNameRegEx = ".*[^a-zA-Z0-9_-.].*"
        let range = username!.range(of: userNameRegEx, options:.regularExpression)
        let result = range != nil ? false : true
        
        isValid = username != nil && username?.characters.count > 2 && result
        
        self.enableContinueButton(isValid)
        
    }
    
    func checkForUniqueUsername() {
        faeUser.whereKey("user_name", value: username!)
        showActivityIndicator()
        faeUser.checkUserExistence { (status, message) in
            DispatchQueue.main.async(execute: {
                self.hideActivityIndicator()
                if status/100 == 2 {
                    let valueInfo = JSON(message!)
                    if let value = valueInfo["existence"].int {
                        if value == 0 {
                            self.jumpToRegisterPassword()
                            self.usernameExistLabel.isHidden = true
                        } else {
                            self.usernameExistLabel.isHidden = false
                        }
                    }
                }
            })
        }
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


extension RegisterUsernameViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TitleTableViewCellIdentifier") as! TitleTableViewCell
            cell.setTitleLabelText("Choose a Unique Username \nto Represent You!")
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SubTitleTableViewCellIdentifier") as! SubTitleTableViewCell
            cell.setSubTitleLabelText("Letters, Numbers & One Symbol ( ‘-’ ‘_’ or ‘.’ )")
            return cell
        case 2:
            if usernameTableViewCell == nil {
                usernameTableViewCell = tableView.dequeueReusableCell(withIdentifier: "RegisterTextfieldTableViewCellIdentifier") as! RegisterTextfieldTableViewCell
                usernameTableViewCell.setPlaceholderLabelText("NewUsername", indexPath: indexPath)
                usernameTableViewCell.setTextFieldForUsernameConfiguration()
                usernameTableViewCell.isUsernameField = true
                usernameTableViewCell.setCharacterLimit(20)
                usernameTableViewCell.setLeftPlaceHolderDisplay(true)
                usernameTableViewCell.delegate = self
                usernameTableViewCell.textfield.keyboardType = .asciiCapable
            }
            return usernameTableViewCell
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

extension RegisterUsernameViewController: RegisterTextfieldProtocol {
    
    func textFieldDidBeginEditing(_ indexPath: IndexPath) {
        activeIndexPath = indexPath
    }
    
    func textFieldShouldReturn(_ indexPath: IndexPath) {
        switch indexPath.row {
        case 2:
            usernameTableViewCell.endAsResponder()
            break
        default: break
        }
    }
    
    func textFieldDidChange(_ text: String, indexPath: IndexPath) {
        switch indexPath.row {
        case 2:
            username = text
            self.usernameExistLabel.isHidden = true
            break
        default: break
        }
        validation()
    }

}
