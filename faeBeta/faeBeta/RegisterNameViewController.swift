//
//  RegisterNameViewController.swift
//  faeBeta
//
//  Created by blesssecret on 8/15/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

class RegisterNameViewController: RegisterBaseViewController {
    
    // MARK: Variables
    
    var firstNameTableViewCell: RegisterTextfieldTableViewCell!
    var lastNameTableViewCell: RegisterTextfieldTableViewCell!
    var firstName: String?
    var lastName: String?
    
    // MARK: View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        createTopView("Progress1")
        createTableView(view.frame.size.height - 175)
        createBottomView(createAlreadyGotAnAccountView())
        
        registerCell()
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        firstNameTableViewCell.makeFirstResponder()
    }
    
    // MARK: - Functions
    
    func registerCell() {
        
        tableView.registerNib(UINib(nibName: "TitleTableViewCell", bundle: nil), forCellReuseIdentifier: "TitleTableViewCellIdentifier")
        tableView.registerNib(UINib(nibName: "SubTitleTableViewCell", bundle: nil), forCellReuseIdentifier: "SubTitleTableViewCellIdentifier")
        tableView.registerNib(UINib(nibName: "RegisterTextfieldTableViewCell", bundle: nil), forCellReuseIdentifier: "RegisterTextfieldTableViewCellIdentifier")
        
    }
    
    
    func createAlreadyGotAnAccountView() -> UIView {
        let createAlreadyGotAnAccountView = UIView(frame: CGRectMake(0, 0, view.frame.size.width, 25))
        
        let button = UIButton(frame: CGRectMake(view.frame.size.width/2.0 - 100, 0, 200, 25))
        
        button.setImage(UIImage(named: "AlreadyGotAnAccount"), forState: .Normal)
        button.addTarget(self, action: #selector(self.loginButtonPressed), forControlEvents: .TouchUpInside)
        
        createAlreadyGotAnAccountView.addSubview(button)
        
        return createAlreadyGotAnAccountView
    }
    
    func loginButtonPressed() {
        
    }
    
    override func backButtonPressed() {
        
    }
    
    override func continueButtonPressed() {
        view.endEditing(true)
        jumpToRegisterEmail()
    }
    
    func jumpToRegisterEmail() {
        let vc:UIViewController = UIStoryboard(name: "Registration", bundle: nil) .instantiateViewControllerWithIdentifier("RegisterEmailViewController")as! RegisterEmailViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func validation() {
        var isValid = false
        
        isValid = firstName != nil && firstName?.characters.count > 0
        isValid = isValid && lastName != nil && lastName?.characters.count > 0
        
        enableContinueButton(isValid)
    }
    
    // MARK: Memory Management
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension RegisterNameViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCellWithIdentifier("TitleTableViewCellIdentifier") as! TitleTableViewCell
            cell.setTitleLabelText("Hi there! Great to see you! \nLet's create your Fae Account!")
            return cell
        case 1:
            let cell = tableView.dequeueReusableCellWithIdentifier("SubTitleTableViewCellIdentifier") as! SubTitleTableViewCell
            cell.setSubTitleLabelText("Enter your Full Name")
            return cell
        case 2:
            if firstNameTableViewCell == nil {
                firstNameTableViewCell = tableView.dequeueReusableCellWithIdentifier("RegisterTextfieldTableViewCellIdentifier") as! RegisterTextfieldTableViewCell
                firstNameTableViewCell.setPlaceholderLabelText("First Name", indexPath: indexPath)
                firstNameTableViewCell.delegate = self
            }
            return firstNameTableViewCell
        case 3:
            if lastNameTableViewCell == nil {
                lastNameTableViewCell = tableView.dequeueReusableCellWithIdentifier("RegisterTextfieldTableViewCellIdentifier") as! RegisterTextfieldTableViewCell
                lastNameTableViewCell.setPlaceholderLabelText("Last Name", indexPath: indexPath)
                lastNameTableViewCell.delegate = self
            }
            return lastNameTableViewCell
        default:
            let cell = tableView.dequeueReusableCellWithIdentifier("TitleTableViewCellIdentifier") as! TitleTableViewCell
            return cell
            
        }
    }
}

extension RegisterNameViewController: RegisterTextfieldProtocol {
    
    func textFieldDidBeginEditing(indexPath: NSIndexPath) {
        activeIndexPath = indexPath
    }
    
    func textFieldShouldReturn(indexPath: NSIndexPath) {
        switch indexPath.row {
        case 2:
            firstNameTableViewCell.endAsResponder()
            lastNameTableViewCell.makeFirstResponder()
            break
        case 3:
            if continueButton.enabled {
                lastNameTableViewCell.endAsResponder()
            } else {
                lastNameTableViewCell.endAsResponder()
                firstNameTableViewCell.makeFirstResponder()
            }
        default: break
        }
    }
    
    func textFieldDidChange(text: String, indexPath: NSIndexPath) {
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
