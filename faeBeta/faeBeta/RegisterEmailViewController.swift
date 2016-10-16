//
//  RegisterEmailViewController.swift
//  faeBeta
//
//  Created by blesssecret on 8/15/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

class RegisterEmailViewController: RegisterBaseViewController {
    
    // MARK: - Variables
    
    var emailTableViewCell: RegisterTextfieldTableViewCell!
    var email: String?
    var faeUser: FaeUser!
    var emailExistLabel: UIView!
    
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
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        emailTableViewCell.makeFirstResponder()
    }
    
    // MARK: - Functions
    
    func thisEmailIsAlreadyView() -> UIView {
        let thisEmailIsAlreadyView = UIView(frame: CGRectMake(0, 0, view.frame.size.width, 25))
        
        let label = UILabel(frame: CGRectMake(view.frame.size.width/2.0 - 118, 0, 190, 25))
        label.attributedText = NSAttributedString(string: "This email is already registered! ", attributes: [NSFontAttributeName: UIFont(name: "AvenirNext-Medium", size: 13)!,
            NSForegroundColorAttributeName: UIColor.faeAppRedColor()]
        )
        thisEmailIsAlreadyView.addSubview(label)
        
        let button = UIButton(frame: CGRectMake(view.frame.size.width/2.0 + 73, 0, 45, 25))
        let titleString = "Log In!"
        let attribute = [ NSFontAttributeName: UIFont(name: "AvenirNext-Bold", size: 13)!,
                          NSForegroundColorAttributeName: UIColor.faeAppRedColor()]
        let myAttrString = NSMutableAttributedString(string: titleString, attributes: attribute)
        
        button.setAttributedTitle(myAttrString, forState: .Normal)
        button.addTarget(self, action: #selector(self.loginButtonTapped), forControlEvents: .TouchUpInside)
        

        thisEmailIsAlreadyView.addSubview(button)
        thisEmailIsAlreadyView.hidden = true
        return thisEmailIsAlreadyView
    }
    
    func loginButtonTapped() {
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("LogInViewController")as! LogInViewController
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    override func backButtonPressed() {
        view.endEditing(true)
        navigationController?.popViewControllerAnimated(false)
    }
    
    override func continueButtonPressed() {
        view.endEditing(true)
        checkForUniqueEmail()
    }
    
    func jumpToRegisterUsername() {
        let vc = UIStoryboard(name: "Main", bundle: nil) .instantiateViewControllerWithIdentifier("RegisterUsernameViewController")as! RegisterUsernameViewController
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
            dispatch_async(dispatch_get_main_queue(), {
                
                self.hideActivityIndicator()
                if status/100 == 2 {
                    let value = message?.valueForKey("existence")
                    if (value != nil) {
                        if value! as! Int == 0 {
                            self.emailExistLabel.hidden = true
                            self.jumpToRegisterUsername()
                        } else {
                            self.emailExistLabel.hidden = false
                        }
                    }
                }
            })
            
        }
    }
    
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let range = testStr.rangeOfString(emailRegEx, options:.RegularExpressionSearch)
        let result = range != nil ? true : false
        return result
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


extension RegisterEmailViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCellWithIdentifier("TitleTableViewCellIdentifier") as! TitleTableViewCell
            cell.setTitleLabelText("Use your Email to Log In and \nEasily Connect to People!")
            return cell
        case 1:
            let cell = tableView.dequeueReusableCellWithIdentifier("SubTitleTableViewCellIdentifier") as! SubTitleTableViewCell
            cell.setSubTitleLabelText("Enter your Email Address")
            return cell
        case 2:
            if emailTableViewCell == nil {
                emailTableViewCell = tableView.dequeueReusableCellWithIdentifier("RegisterTextfieldTableViewCellIdentifier") as! RegisterTextfieldTableViewCell
                emailTableViewCell.setPlaceholderLabelText("Email Address", indexPath: indexPath)
                emailTableViewCell.delegate = self
            }
            return emailTableViewCell
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

extension RegisterEmailViewController: RegisterTextfieldProtocol {
    
    func textFieldDidBeginEditing(indexPath: NSIndexPath) {
        activeIndexPath = indexPath
    }
    
    func textFieldShouldReturn(indexPath: NSIndexPath) {
        switch indexPath.row {
        case 2:
            emailTableViewCell.endAsResponder()
            break
        default: break
        }
    }
    
    func textFieldDidChange(text: String, indexPath: NSIndexPath) {
        switch indexPath.row {
        case 2:
            email = text
            emailExistLabel.hidden = true
            break
        default: break
        }
        validation()
    }
}

