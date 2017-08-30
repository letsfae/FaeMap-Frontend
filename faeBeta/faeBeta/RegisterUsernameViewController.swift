//
//  RegisterUsernameViewController.swift
//  faeBeta
//
//  Created by blesssecret on 8/15/16.
//  Edited by Sophie Wang
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

    var cellUsername: RegisterTextfieldTableViewCell!
    var username: String?
    var faeUser: FaeUser!
    var lblError: UILabel!
    
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
        let boardRegister = RegisterPasswordViewController()
        boardRegister.faeUser = faeUser
        self.navigationController?.pushViewController(boardRegister, animated: false)
    }
    
    func getErrorView() -> UIView {
        let uiviewError = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 40))
        lblError = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 40))
        lblError.font = UIFont(name: "AvenirNext-Medium", size: 13)
        lblError.numberOfLines = 2
        lblError.textAlignment = .center
        lblError.text = "You can use your Username for Log In, \nAdding People, and Starting Chats."
        lblError.textColor = UIColor._138138138()
        
        uiviewError.addSubview(lblError)
        return uiviewError
    }
    
    func validation() {
        var boolIsValid = false
        let userNameRegEx = ".*[^a-zA-Z0-9_-.].*"
        let range = username!.range(of: userNameRegEx, options: .regularExpression)
        let result = range != nil ? false : true
        boolIsValid = username != nil && username?.characters.count > 2 && result
        self.enableContinueButton(boolIsValid)
    }
    
    func checkForUniqueUsername() {
        faeUser.whereKey("user_name", value: username!)
        showActivityIndicator()
        faeUser.checkUserExistence {(status, message) in DispatchQueue.main.async(execute: {
                self.hideActivityIndicator()
                if status/100 == 2 {
                    let valueInfo = JSON(message!)
                    if let value = valueInfo["existence"].int {
                        if value == 0 {
                            self.jumpToRegisterPassword()
                            self.lblError.text = "You can use your Username for Log In, \nAdding People, and Starting Chats."
                            self.lblError.textColor = UIColor._138138138()
                        } else {
                            self.lblError.text = "This Username is currently Unavailable. \n Choose Another One!"
                            self.lblError.textColor = UIColor._2499090()
                        }
                    }
                }
            })
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
            if cellUsername == nil {
                cellUsername = tableView.dequeueReusableCell(withIdentifier: "RegisterTextfieldTableViewCellIdentifier") as! RegisterTextfieldTableViewCell
                cellUsername.setPlaceholderLabelText("NewUsername", indexPath: indexPath)
                cellUsername.setTextFieldForUsernameConfiguration()
                cellUsername.isUsernameField = true
                cellUsername.setCharacterLimit(20)
                cellUsername.setLeftPlaceHolderDisplay(true)
                cellUsername.delegate = self
                cellUsername.textfield.keyboardType = .asciiCapable
                cellUsername.makeFirstResponder()
            }
            return cellUsername
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
            cellUsername.endAsResponder()
            break
        default: break
        }
    }
    
    func textFieldDidChange(_ text: String, indexPath: IndexPath) {
        switch indexPath.row {
        case 2:
            username = text
            lblError.text = "You can use your Username for Log In, \nAdding People, and Starting Chats."
            lblError.textColor = UIColor._138138138()
            break
        default: break
        }
        validation()
    }
}
