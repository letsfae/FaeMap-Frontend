//
//  RegisterPasswordViewController.swift
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


class RegisterPasswordViewController: RegisterBaseViewController {
    // MARK: - Properties
    private var cellPassword: RegisterTextfieldTableViewCell!
    private var password: String?
    var faeUser: FaeUser!
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        createBottomView(getInfoView())
        createTableView(59 + 135 * screenHeightFactor)
        createTopView("ProgressBar3")
        registerCell()
        tableView.delegate = self
        tableView.dataSource = self
        if let savedPassword = FaeCoreData.shared.readByKey("signup_password") {            
            password = savedPassword as? String
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        validation()
        FaeCoreData.shared.save("signup", value: "password")
    }
    
    private func getInfoView() -> UIView {
        let uiviewInfo = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 85 * screenHeightFactor))
        let imgInfoPwd = UIImageView(frame: CGRect(x: view.frame.size.width/2.0 - 160 * screenWidthFactor, y: 0, width: 320 * screenWidthFactor, height: 85 * screenHeightFactor))
        imgInfoPwd.image = UIImage(named: "InfoPassword")
        
        uiviewInfo.addSubview(imgInfoPwd)
        return uiviewInfo
    }
    
    private func registerCell() {
        tableView.register(TitleTableViewCell.self, forCellReuseIdentifier: "TitleTableViewCellIdentifier")
        tableView.register(SubTitleTableViewCell.self, forCellReuseIdentifier: "SubTitleTableViewCellIdentifier")
        tableView.register(RegisterTextfieldTableViewCell.self, forCellReuseIdentifier: "RegisterTextfieldTableViewCellIdentifier")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Button actions
    override func backButtonPressed() {
        view.endEditing(true)
        if password != nil {
            FaeCoreData.shared.save("signup_password", value: password!)
        }
        navigationController?.popViewController(animated: false)
    }
    
    override func continueButtonPressed() {
        view.endEditing(true)
        if let savedPassword = FaeCoreData.shared.readByKey("signup_password") {
            if (savedPassword as? String) != password! && Key.shared.is_Login {
                faeUser.whereKey("old_password", value: (savedPassword as? String)!)
                faeUser.whereKey("new_password", value: password!)
                faeUser.updatePassword({ (_, _) in
                    self.savePasswordInUser()
                    self.jumpToRegisterNext()
                })
            } else {
                jumpToRegisterNext()
            }
        } else {
            savePasswordInUser()
            jumpToRegisterNext()
        }
        FaeCoreData.shared.save("signup_password", value: password!)
    }
    private func jumpToRegisterNext() {
        let nextRegister = RegisterInfoViewController()
        nextRegister.faeUser = faeUser
        self.navigationController?.pushViewController(nextRegister, animated: false)
    }
    
    private func savePasswordInUser() {
        faeUser.whereKey("password", value: password!)
    }
}

// MARK: - UITableView
extension RegisterPasswordViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TitleTableViewCellIdentifier") as! TitleTableViewCell
            cell.setTitleLabelText("Protect your Account \n with a Strong Password!")
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SubTitleTableViewCellIdentifier") as! SubTitleTableViewCell
            cell.setSubTitleLabelText("Must be at least 8 characters!")
            return cell
        case 2:
            if cellPassword == nil {
                cellPassword = tableView.dequeueReusableCell(withIdentifier: "RegisterTextfieldTableViewCellIdentifier") as! RegisterTextfieldTableViewCell
                cellPassword.setPlaceholderLabelText("New Password", indexPath: indexPath)
                cellPassword.setRightPlaceHolderDisplay(true)
                cellPassword.delegate = self
                cellPassword.setCharacterLimit(50)
                if password != nil {
                    cellPassword.textfield.text = password
                }
                cellPassword.makeFirstResponder()
            }
            return cellPassword
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

// MARK: - RegisterTextfieldProtocol
extension RegisterPasswordViewController: RegisterTextfieldProtocol {
    func textFieldDidBeginEditing(_ indexPath: IndexPath) {
        activeIndexPath = indexPath
    }
    
    func textFieldShouldReturn(_ indexPath: IndexPath) {
        switch indexPath.row {
        case 2:
            cellPassword.endAsResponder()
        default: break
        }
    }
    
    func textFieldDidChange(_ text: String, indexPath: IndexPath) {
        switch indexPath.row {
        case 2:
            password = text
            cellPassword.updateTextColorAccordingToPassword(text)
        default: break
        }
        validation()
    }
    
    private func validation() {
        var boolIsValid = false
        boolIsValid = password != nil && password?.count > 7
        enableContinueButton(boolIsValid)
    }
}
