//
//  NewUsernameVC.swift
//  faeBeta
//
//  Created by Jichao on 2018/7/11.
//  Copyright © 2018年 fae. All rights reserved.
//

import UIKit
import SwiftyJSON

class NewUsernameViewController: RegisterBaseViewController {
    // MARK: - Properties
    private var cellUsername: RegisterTextfieldTableViewCell!
    private var username: String?
    var faeUser: FaeUser!
    private var lblError: UILabel!
    private var lblAt: UILabel!
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        faeUser = FaeUser()
        createTopView("ProgressBar1")
        imgProgress.removeFromSuperview()
        createTableView(59 + 135 * screenHeightFactor)
        createBottomView(getErrorView())
        registerCell()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        validation()
    }
    
    private func getErrorView() -> UIView {
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
        navigationController?.popViewController(animated: false)
    }
    
    override func continueButtonPressed() {
        checkForUniqueUsername()
    }
    
    private func checkForUniqueUsername() {
        showActivityIndicator()
        var keyValue = [String: String]()
        keyValue["user_name"] = username!
        postToURL("users/account", parameter: keyValue, authentication: Key.shared.headerAuthentication(), completion: { [unowned self] (status, message) in
            self.hideActivityIndicator()
            if status / 100 == 2 {
                Key.shared.username = self.username!
                let date = Date()
                let calendar = Calendar.current
                let thisYear = calendar.component(.year, from: date)
                var remainingTimes = 2
                if Key.shared.otherSettings != "" {
                    var current = Key.shared.otherSettings.split(separator: ",")
                    if current.count == 2 {
                        if let count = Int(current[0]) {
                            remainingTimes = count
                        }
                        if let lastTime = Int(current[1]) {
                            if thisYear != lastTime {
                                remainingTimes = 2
                            }
                        }
                    }
                }
                remainingTimes -= 1
                let newUsernameCount = "\(remainingTimes),\(thisYear)"
                self.faeUser.clearKeyValue()
                self.faeUser.whereKey("others", value: newUsernameCount)
                self.faeUser.setUserSettings { (status, message) in
                    // TODO
                    if status / 100 == 2 {
                        
                    } else {
                        
                    }
                }
                Key.shared.otherSettings = newUsernameCount
                self.lblError.text = "You can use your Username for Log In, \nAdding People, and Starting Chats."
                self.lblError.textColor = UIColor._138138138()
                self.navigationController?.popViewController(animated: true)
            } else { // TODO: error code undecided
                self.hideActivityIndicator()
                let messageJSON = JSON(message!)
                if let error_code = messageJSON["error_code"].string {
                    handleErrorCode(.auth, error_code, { (prompt) in
                        // handle
                        felixprint("\(error_code)")
                        if error_code == "422-2" {
                            self.lblError.text = "This Username is currently Unavailable. \n Choose Another One!"
                            self.lblError.textColor = UIColor._2499090()
                        }
                    })
                } else {
                    if status == NSURLErrorTimedOut {
                        self.lblError.text = "Time out! Please try later!"
                        self.lblError.textColor = UIColor._2499090()
                    } else {
                        self.lblError.text = "Error! Please try later!"
                        self.lblError.textColor = UIColor._2499090()
                    }
                }
            }
        })
    }
}

// MARK: - UITableView
extension NewUsernameViewController: UITableViewDelegate, UITableViewDataSource {
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
                cellUsername.textfield.delegate = self
                
                let placeholderWidth = "NewUsername".boundingRect(with: CGSize(width: CGFloat(MAXFLOAT), height: 44), options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: UIFont(name: "AvenirNext-Medium", size: 22)!], context: nil).size.width
                let textfieldWidth = cellUsername.textfield.frame.width
                let atWidth = "@".boundingRect(with: CGSize(width: CGFloat(MAXFLOAT), height: 44), options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: UIFont(name: "AvenirNext-Medium", size: 22)!], context: nil).size.width
                lblAt = UILabel(frame: CGRect(x: cellUsername.textfield.frame.origin.x + (textfieldWidth - placeholderWidth) / 2 - atWidth - 2, y: cellUsername.textfield.frame.origin.y, width: atWidth, height: 44))
                lblAt.text = "@"
                lblAt.textColor = UIColor._155155155()
                lblAt.font = UIFont(name: "AvenirNext-Regular", size: 22)
                //cellUsername.textfield.leftView = lblAt
                cellUsername.addSubview(lblAt)
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

// MARK: - RegisterTextfieldProtocol
extension NewUsernameViewController: RegisterTextfieldProtocol, UITextFieldDelegate {
    func textFieldDidBeginEditing(_ indexPath: IndexPath) {
        activeIndexPath = indexPath
    }
    
    func textFieldShouldReturn(_ indexPath: IndexPath) {
        switch indexPath.row {
        case 2:
            cellUsername.endAsResponder()
        default: break
        }
    }
    
    func textFieldDidChange(_ text: String, indexPath: IndexPath) {
        switch indexPath.row {
        case 2:
            let parsedText = text.replacingOccurrences(of: "@", with: "")
            username = parsedText
            lblError.text = "You can use your Username for Log In, \nAdding People, and Starting Chats."
            lblError.textColor = UIColor._138138138()
            if parsedText == "" {
                cellUsername.textfield.text = ""
                lblAt.isHidden = false
            } else {
                let attrText = NSMutableAttributedString()
                let at = NSAttributedString(string: "@", attributes: [NSAttributedStringKey.foregroundColor: UIColor._155155155(), NSAttributedStringKey.font: UIFont(name: "AvenirNext-Regular", size: 22)!])
                let usrname = NSAttributedString(string: parsedText, attributes: [NSAttributedStringKey.foregroundColor: UIColor._898989(), NSAttributedStringKey.font: UIFont(name: "AvenirNext-Regular", size: 22)!])
                attrText.append(at)
                attrText.append(usrname)
                cellUsername.textfield.attributedText = attrText
                lblAt.isHidden = true
            }
        default: break
        }
        validation()
    }
    
    private func validation() {
        if username == nil { return }
        var boolIsValid = false
        let userNameRegEx = ".*[^a-zA-Z0-9_-.].*"
        let range = username!.range(of: userNameRegEx, options: .regularExpression)
        let result = range != nil ? false : true
        boolIsValid = username != nil && username!.count > 2 && result
        enableContinueButton(boolIsValid)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if let selectedRange = textField.selectedTextRange {
            
            // and only if the new position is valid
            if let newPosition = textField.position(from: selectedRange.start, offset: 1) {
                
                // set the new position
                textField.selectedTextRange = textField.textRange(from: newPosition, to: newPosition)
            }
        }
    }
    
    /*func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if range.length>0  && range.location == 0 {
            return false
        }
        return true
    }*/
}
