//
//  SignInSupportViewController.swift
//  faeBeta
//
//  Created by blesssecret on 8/15/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

class SignInSupportViewController: RegisterBaseViewController {
    
    // MARK: - Variables
    
    var emailTableViewCell: RegisterTextfieldTableViewCell!
    var email: String?
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        createTopView("")
        createTableView(view.frame.size.height - 175)
        createBottomView(noAccountView())
        
        registerCell()
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        emailTableViewCell.makeFirstResponder()
    }
    
    // MARK: - Functions
    
    func noAccountView() -> UIView {
        let noAccountView = UIView(frame: CGRectMake(0, 0, view.frame.size.width, 25))
        
        let label = UILabel(frame: CGRectMake(view.frame.size.width/2.0 - 125, 0, 250, 25))
        label.textAlignment = .Center
        label.font = UIFont(name: "AvenirNext-Medium", size: 13)
        label.textColor = UIColor.init(red: 249/255.0, green: 90/255.0, blue: 90/255.0, alpha: 1.0)
        label.text = "We can't find an account with this Email."
        
        noAccountView.addSubview(label)
        
        return noAccountView
    }
    
    func loginButtonPressed() {
        
    }
    
    override func backButtonPressed() {
        view.endEditing(true)
        navigationController?.popViewControllerAnimated(true)
    }
    
    override func continueButtonPressed() {
        view.endEditing(true)
        jumpToSignInSupportCode()
    }
    
    func jumpToSignInSupportCode() {
        let vc:UIViewController = UIStoryboard(name: "Registration", bundle: nil) .instantiateViewControllerWithIdentifier("SignInSupportCodeViewController")as! SignInSupportCodeViewController
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
        tableView.registerNib(UINib(nibName: "SpacerTableViewCell", bundle: nil), forCellReuseIdentifier: "SpacerTableViewCellIdentifier")
        tableView.registerNib(UINib(nibName: "RegisterTextfieldTableViewCell", bundle: nil), forCellReuseIdentifier: "RegisterTextfieldTableViewCellIdentifier")
        
    }
    
    override func createBottomView(subview: UIView) {
        
        bottomView = UIView(frame: CGRectMake(0, view.frame.size.height - 80 - subview.frame.size.height, view.frame.size.width, subview.frame.size.height + 80))
        
        continueButton = UIButton(frame: CGRectMake(view.frame.size.width/2.0 - 150, subview.frame.size.height + 15, 300, 50))
        continueButton.setImage(UIImage(named: "SendCodeDisabled"), forState: .Normal)
        continueButton.enabled = false
        continueButton.addTarget(self, action: #selector(self.continueButtonPressed), forControlEvents: .TouchUpInside)
        
        bottomView.addSubview(subview)
        bottomView.addSubview(continueButton)
        
        view.addSubview(bottomView)
    }
    
    override func enableContinueButton(enable: Bool) {
        continueButton.enabled = enable
        continueButton.setImage(UIImage(named: enable ? "SendCodeEnabled" : "SendCodeDisabled"), forState: .Normal)
    }
    
    // MARK: - Memory Management
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension SignInSupportViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCellWithIdentifier("TitleTableViewCellIdentifier") as! TitleTableViewCell
            cell.setTitleLabelText("Enter your Email \nto Reset Password")
            return cell
        case 1:
            let cell = tableView.dequeueReusableCellWithIdentifier("SpacerTableViewCellIdentifier") as! SpacerTableViewCell
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

extension SignInSupportViewController: RegisterTextfieldProtocol {
    
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

