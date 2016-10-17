//
//  RegisterUsernameViewController.swift
//  faeBeta
//
//  Created by blesssecret on 8/15/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

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
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        usernameTableViewCell.makeFirstResponder()
    }
    
    // MARK: - Functions
    
    override func backButtonPressed() {
        view.endEditing(true)
        navigationController?.popViewControllerAnimated(false)
    }
    
    override func continueButtonPressed() {
        view.endEditing(true)
        checkForUniqueUsername()
    }
    
    func jumpToRegisterPassword() {
        let vc = UIStoryboard(name: "Main", bundle: nil) .instantiateViewControllerWithIdentifier("RegisterPasswordViewController") as! RegisterPasswordViewController
        vc.faeUser = faeUser
        self.navigationController?.pushViewController(vc, animated: false)
    }
    
    func getErrorView() -> UIView {
        let errorView = UIView(frame: CGRectMake(0, 0, view.frame.size.width, 40))
        
        let errorLabel = UILabel(frame: CGRectMake(0, 0, view.frame.size.width, 40))
        errorLabel.textColor = UIColor.init(red: 249/255.0, green: 90/255.0, blue: 90/255.0, alpha: 1.0)
        errorLabel.font = UIFont(name: "AvenirNext-Medium", size: 13)
        errorLabel.numberOfLines = 2
        errorLabel.textAlignment = .Center
        errorLabel.text = "This Username is currently Unavailable. \n Choose another One!"
        errorLabel.hidden = true
        
        usernameExistLabel = errorLabel
        errorView.addSubview(errorLabel)
        
        return errorView
    }
    
    
    func validation() {
        var isValid = false
        
        let userNameRegEx = ".*[^A-Za-z0-9].*"
        let range = username!.rangeOfString(userNameRegEx, options:.RegularExpressionSearch)
        let result = range != nil ? false : true
        
        isValid = username != nil && username?.characters.count > 0 && result
        
        self.enableContinueButton(isValid)
        
    }
    
    func checkForUniqueUsername() {
        faeUser.whereKey("user_name", value: username!)
        showActivityIndicator()
        faeUser.checkUserExistence { (status, message) in
            dispatch_async(dispatch_get_main_queue(), {
                self.hideActivityIndicator()
                if status/100 == 2 {
                    let value = message?.valueForKey("existence")
                    if (value != nil) {
                        if value! as! Int == 0 {
                            self.jumpToRegisterPassword()
                            self.usernameExistLabel.hidden = true
                        } else {
                            self.usernameExistLabel.hidden = false
                        }
                    }
                }
            })
        }
    }
    
    func registerCell() {
        
        tableView.registerNib(UINib(nibName: "TitleTableViewCell", bundle: nil), forCellReuseIdentifier: "TitleTableViewCellIdentifier")
        tableView.registerNib(UINib(nibName: "SubTitleTableViewCell", bundle: nil), forCellReuseIdentifier: "SubTitleTableViewCellIdentifier")
        tableView.registerNib(UINib(nibName: "RegisterTextfieldTableViewCell", bundle: nil), forCellReuseIdentifier: "RegisterTextfieldTableViewCellIdentifier")
        
    }
    
    // MARK: - Memory Management
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}


extension RegisterUsernameViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCellWithIdentifier("TitleTableViewCellIdentifier") as! TitleTableViewCell
            cell.setTitleLabelText("Choose a Unique Username \nto Represent You!")
            return cell
        case 1:
            let cell = tableView.dequeueReusableCellWithIdentifier("SubTitleTableViewCellIdentifier") as! SubTitleTableViewCell
            cell.setSubTitleLabelText("Letters & Numbers Only")
            return cell
        case 2:
            if usernameTableViewCell == nil {
                usernameTableViewCell = tableView.dequeueReusableCellWithIdentifier("RegisterTextfieldTableViewCellIdentifier") as! RegisterTextfieldTableViewCell
                usernameTableViewCell.setPlaceholderLabelText("NewUsername", indexPath: indexPath)
                usernameTableViewCell.setTextFieldForUsernameConfiguration()
                usernameTableViewCell.isUsernameField = true
                usernameTableViewCell.setCharacterLimit(20)
                usernameTableViewCell.setLeftPlaceHolderDisplay(true)
                usernameTableViewCell.delegate = self
            }
            return usernameTableViewCell
        default:
            let cell = tableView.dequeueReusableCellWithIdentifier("TitleTableViewCellIdentifier") as! TitleTableViewCell
            return cell
            
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
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
    
    func textFieldDidBeginEditing(indexPath: NSIndexPath) {
        activeIndexPath = indexPath
    }
    
    func textFieldShouldReturn(indexPath: NSIndexPath) {
        switch indexPath.row {
        case 2:
            usernameTableViewCell.endAsResponder()
            break
        default: break
        }
    }
    
    func textFieldDidChange(text: String, indexPath: NSIndexPath) {
        switch indexPath.row {
        case 2:
            username = text
            self.usernameExistLabel.hidden = true
            break
        default: break
        }
        validation()
    }

}
