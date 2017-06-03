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
  
    var cellPassword: RegisterTextfieldTableViewCell!
    var password: String?
    var faeUser: FaeUser!
    
    // MARK: - View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        createBottomView(getInfoView())
        createTableView(59 + 135 * screenHeightFactor)
        createTopView("ProgressBar4")
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
        navigationController?.popViewController(animated: false)
    }
    
    override func continueButtonPressed() {
        view.endEditing(true)
        savePasswordInUser()
        jumpToRegisterInfo()
    }
    
    func jumpToRegisterInfo() {
        let boardRegister = RegisterInfoViewController()
        boardRegister.faeUser = faeUser
        self.navigationController?.pushViewController(boardRegister, animated: false)
    }
    
    func getInfoView() -> UIView {
        let uiviewInfo = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 85 * screenHeightFactor))
        let imgInfoPwd = UIImageView(frame: CGRect(x: view.frame.size.width/2.0 - 160 * screenWidthFactor, y: 0, width: 320 * screenWidthFactor, height: 85 * screenHeightFactor))
        imgInfoPwd.image = UIImage(named: "InfoPassword")
        
        uiviewInfo.addSubview(imgInfoPwd)
        return uiviewInfo
    }
    
    func validation() {
        var boolIsValid = false
        boolIsValid = password != nil && password?.characters.count > 7
        enableContinueButton(boolIsValid)
    }
    
    func savePasswordInUser() {
        faeUser.whereKey("password", value: password!)
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
                cellPassword.setCharacterLimit(16)
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

extension RegisterPasswordViewController: RegisterTextfieldProtocol {
    func textFieldDidBeginEditing(_ indexPath: IndexPath) {
        activeIndexPath = indexPath
    }
    
    func textFieldShouldReturn(_ indexPath: IndexPath) {
        switch indexPath.row {
        case 2:
            cellPassword.endAsResponder()
            break
        default: break
        }
    }
    
    func textFieldDidChange(_ text: String, indexPath: IndexPath) {
        switch indexPath.row {
        case 2:
            password = text
            cellPassword.updateTextColorAccordingToPassword(text)
            break
        default: break
        }
        validation()
    }
}
