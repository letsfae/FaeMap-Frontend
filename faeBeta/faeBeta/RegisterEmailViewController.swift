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
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        createTopView("Progress2")
        createTableView(view.frame.size.height - 175)
        createBottomView(thisEmailIsAlreadyView())
        
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
        
        let button = UIButton(frame: CGRectMake(view.frame.size.width/2.0 - 125, 0, 250, 25))
        
        let titleString = "This email is already registered! Log In!"
        let attribute = [ NSFontAttributeName: UIFont(name: "AvenirNext-Medium", size: 13)!]
        let myAttrString = NSMutableAttributedString(string: titleString, attributes: attribute)
        myAttrString.addAttribute(NSForegroundColorAttributeName, value: UIColor(red: 249/255.0, green: 90/255.0, blue: 90/255.0, alpha: 1.0), range: NSRange(location: 0, length: 33))
        
        
        let myRange1 = NSRange(location: 33, length: 8)
        
        myAttrString.addAttribute(NSForegroundColorAttributeName, value: UIColor.init(red: 249/255.0, green: 90/255.0, blue: 90/255.0, alpha: 1.0), range: myRange1)
        
        myAttrString.addAttribute(NSFontAttributeName, value:UIFont(name: "AvenirNext-Bold", size: 13)!, range: myRange1)
        
        
        //        button.setImage(UIImage(named: "ThisEmailIsAlready"), forState: .Normal)
        button.setAttributedTitle(myAttrString, forState: .Normal)
        button.addTarget(self, action: #selector(self.loginButtonTapped), forControlEvents: .TouchUpInside)
        
        thisEmailIsAlreadyView.addSubview(button)
        
        return thisEmailIsAlreadyView
    }
    
    func loginButtonTapped()
    {
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("LogInViewController")as! LogInViewController
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    override func backButtonPressed() {
        view.endEditing(true)
        navigationController?.popViewControllerAnimated(true)
    }
    
    override func continueButtonPressed() {
        view.endEditing(true)
        jumpToRegisterUsername()
    }
    
    func jumpToRegisterUsername() {
        let vc:UIViewController = UIStoryboard(name: "Main", bundle: nil) .instantiateViewControllerWithIdentifier("RegisterUsernameViewController")as! RegisterUsernameViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func validation() {
        var isValid = false
        
        isValid = email != nil && email?.characters.count > 0 && isValidEmail(email!)
        
        enableContinueButton(isValid)
    }
    
    
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(testStr)
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
            break
        default: break
        }
        validation()
    }
}

