//
//  RegisterNameViewController.swift
//  faeBeta
//
//  Created by blesssecret on 8/15/16.
//  Edited by Sophie Wang
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
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

class RegisterNameViewController: RegisterBaseViewController {
    var cellTxtFirstName: RegisterTextfieldTableViewCell!
    var cellTxtLastName: RegisterTextfieldTableViewCell!
    var firstName: String?
    var lastName: String?
    var faeUser: FaeUser?

    override func viewDidLoad() {
        super.viewDidLoad()
        createTableView(210 * screenHeightFactor + 59)
        createTopView("ProgressBar1")
        //createBottomView(createAlreadyGotAnAccountView())
        createBottomView(UIView())
        registerCell()
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
   
    func registerCell() {
        tableView.register(TitleTableViewCell.self, forCellReuseIdentifier: "TitleTableViewCellIdentifier")
        tableView.register(SubTitleTableViewCell.self, forCellReuseIdentifier: "SubTitleTableViewCellIdentifier")
        tableView.register(RegisterTextfieldTableViewCell.self, forCellReuseIdentifier: "RegisterTextfieldTableViewCellIdentifier")
    }
    
    func createAlreadyGotAnAccountView() -> UIView {
        let createAlreadyGotAnAccountView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 25))
        //Already got an Account? 
        let lblGotAccount = UILabel(frame: CGRect(x: view.frame.size.width/2.0 - 94, y: 0, width: 155, height: 25))
        lblGotAccount.attributedText = NSAttributedString(string: "Already got an Account? ", attributes: [NSAttributedStringKey.font: UIFont(name: "AvenirNext-Medium", size: 13)!,
            NSAttributedStringKey.foregroundColor: UIColor._138138138()]
        )
        createAlreadyGotAnAccountView.addSubview(lblGotAccount)
        
        let btnLogin = UIButton(frame: CGRect(x: view.frame.size.width/2.0 + 54, y: 0, width: 45, height: 25))
        let astrTitle = "Log In!"
        let attribute = [NSAttributedStringKey.font: UIFont(name: "AvenirNext-Bold", size: 13)!, NSAttributedStringKey.foregroundColor: UIColor._2499090()]
        let attrLogin = NSMutableAttributedString(string: astrTitle, attributes: attribute)
        
        btnLogin.setAttributedTitle(attrLogin, for: UIControlState())
        btnLogin.addTarget(self, action: #selector(self.loginButtonTapped), for: .touchUpInside)
        
        createAlreadyGotAnAccountView.addSubview(btnLogin)
        return createAlreadyGotAnAccountView
    }
    
    override func backButtonPressed() {
        view.endEditing(true)
        _ = navigationController?.popViewController(animated: true)
    }
    
    override func continueButtonPressed() {
        view.endEditing(true)
        createUser()
        jumpToRegisterNext()
    }
    
    func jumpToRegisterNext() {
        //let boardRegister = RegisterEmailViewController()
        //boardRegister.faeUser = faeUser
        //self.navigationController?.pushViewController(boardRegister, animated: false)
        let nextRegister = RegisterUsernameViewController()
        nextRegister.faeUser = faeUser
        navigationController?.pushViewController(nextRegister, animated: false)
    }
    
    func createUser() {
        faeUser = FaeUser()
        faeUser?.whereKey("first_name", value: firstName!)
        faeUser?.whereKey("last_name", value: lastName!)
    }
    
    @objc func loginButtonTapped() {
        let boardLoginController = LogInViewController()
        self.navigationController?.pushViewController(boardLoginController, animated: true)
    }
    
    func validation() {
        var boolIsValid = false
        boolIsValid = firstName != nil && firstName?.count > 0
        boolIsValid = boolIsValid && lastName != nil && lastName?.count > 0
        
        enableContinueButton(boolIsValid)
    }
    
    // MARK: Memory Management
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension RegisterNameViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TitleTableViewCellIdentifier") as! TitleTableViewCell
            cell.setTitleLabelText("Hi there! Great to see you! \nLet's create your Fae Account!")
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SubTitleTableViewCellIdentifier") as! SubTitleTableViewCell
            cell.setSubTitleLabelText("What’s your Name?")
            return cell
        case 2:
            if cellTxtFirstName == nil {
                cellTxtFirstName = tableView.dequeueReusableCell(withIdentifier: "RegisterTextfieldTableViewCellIdentifier") as! RegisterTextfieldTableViewCell
                cellTxtFirstName.setPlaceholderLabelText("First Name", indexPath: indexPath)
                cellTxtFirstName.textfield.autocapitalizationType = .words
                cellTxtFirstName.delegate = self
                cellTxtFirstName.makeFirstResponder()
            }
            return cellTxtFirstName
        case 3:
            if cellTxtLastName == nil {
                cellTxtLastName = tableView.dequeueReusableCell(withIdentifier: "RegisterTextfieldTableViewCellIdentifier") as! RegisterTextfieldTableViewCell
                cellTxtLastName.setPlaceholderLabelText("Last Name", indexPath: indexPath)
                cellTxtLastName.textfield.autocapitalizationType = .words
                cellTxtLastName.delegate = self
            }
            return cellTxtLastName
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
            case 3:
                return 75 * screenHeightFactor
            default:
                return 0
        }
    }
}

extension RegisterNameViewController: RegisterTextfieldProtocol {
    
    func textFieldDidBeginEditing(_ indexPath: IndexPath) {
        activeIndexPath = indexPath
    }
    
    func textFieldShouldReturn(_ indexPath: IndexPath) {
        switch indexPath.row {
        case 2:
            cellTxtLastName.makeFirstResponder()
        case 3:
            if btnContinue.isEnabled {
                cellTxtLastName.endAsResponder()
            } else {
                cellTxtFirstName.makeFirstResponder()
            }
        default: break
        }
    }
    
    func textFieldDidChange(_ text: String, indexPath: IndexPath) {
        switch indexPath.row {
        case 2:
            firstName = text
            break
        case 3:
            lastName = text
            break
        default: break
        }
        validation()
    }
}
