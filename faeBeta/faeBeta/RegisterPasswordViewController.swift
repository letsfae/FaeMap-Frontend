//
//  RegisterPasswordViewController.swift
//  faeBeta
//
//  Created by blesssecret on 8/15/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

class RegisterPasswordViewController: RegisterBaseViewController {
    
    
    // MARK: - Variables
    
    var passwordTableViewCell: PasswordTableViewCell!
    var password: String?
    var faeUser: FaeUser!
    
    // MARK: - View LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        createTopView("ProgressBar4")
        createTableView(view.frame.size.height - 175)
        createBottomView(getInfoView())
        
        registerCell()
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        passwordTableViewCell.makeFirstResponder()
    }
    
    // MARK: - Functions
    
    override func backButtonPressed() {
        view.endEditing(true)
        navigationController?.popViewControllerAnimated(true)
    }
    
    override func continueButtonPressed() {
        view.endEditing(true)
        savePasswordInUser()
        jumpToRegisterInfo()
    }
    
    func jumpToRegisterInfo() {
        let vc = UIStoryboard(name: "Main", bundle: nil) .instantiateViewControllerWithIdentifier("RegisterInfoViewController") as! RegisterInfoViewController
        vc.faeUser = faeUser
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func getInfoView() -> UIView {
        
        let infoView = UIView(frame: CGRectMake(0, 0, view.frame.size.width, 79))
        
        let imageView = UIImageView(frame: CGRectMake(view.frame.size.width/2.0 - 150, 0, 292, 79))
        imageView.image = UIImage(named: "InfoPassword")
        
        infoView.addSubview(imageView)
        
        return infoView
    }
    
    
    func validation() {
        var isValid = false
        
        isValid = password != nil && password?.characters.count > 7
        
        enableContinueButton(isValid)
    }
    
    func savePasswordInUser() {
        faeUser.whereKey("password", value: password!)
    }
    
    func registerCell() {
        
        tableView.registerNib(UINib(nibName: "TitleTableViewCell", bundle: nil), forCellReuseIdentifier: "TitleTableViewCellIdentifier")
        tableView.registerNib(UINib(nibName: "SubTitleTableViewCell", bundle: nil), forCellReuseIdentifier: "SubTitleTableViewCellIdentifier")
        tableView.registerNib(UINib(nibName: "PasswordTableViewCell", bundle: nil), forCellReuseIdentifier: "PasswordTableViewCellIdentifier")
        
    }
    
    // MARK: - Memory Management
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension RegisterPasswordViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCellWithIdentifier("TitleTableViewCellIdentifier") as! TitleTableViewCell
            cell.setTitleLabelText("Protect your Account \n with a Strong Password!")
            return cell
        case 1:
            let cell = tableView.dequeueReusableCellWithIdentifier("SubTitleTableViewCellIdentifier") as! SubTitleTableViewCell
            cell.setSubTitleLabelText("Must be at least 8 characters!")
            return cell
        case 2:
            if passwordTableViewCell == nil {
                passwordTableViewCell = tableView.dequeueReusableCellWithIdentifier("PasswordTableViewCellIdentifier") as! PasswordTableViewCell
                
                passwordTableViewCell.setPlaceholderLabelText(indexPath)
                passwordTableViewCell.delegate = self
            }
            return passwordTableViewCell
        default:
            let cell = tableView.dequeueReusableCellWithIdentifier("TitleTableViewCellIdentifier") as! TitleTableViewCell
            return cell
            
        }
    }
}

extension RegisterPasswordViewController: PasswordCellProtocol {
    
    func textViewDidBeginEditing(indexPath: NSIndexPath) {
        activeIndexPath = indexPath
    }
    
    func textViewShouldReturn(indexPath: NSIndexPath) {
        switch indexPath.row {
        case 2:
            passwordTableViewCell.endAsResponder()
            break
        default: break
        }
    }
    
    func textViewDidChange(text: String, indexPath: NSIndexPath) {
        switch indexPath.row {
        case 2:
            password = text
            break
        default: break
        }
        validation()
    }
}

