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
    
    var passwordTableViewCell: RegisterTextfieldTableViewCell!
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
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        passwordTableViewCell.makeFirstResponder()
    }
    
    // MARK: - Functions
    
    override func backButtonPressed() {
        view.endEditing(true)
        navigationController?.popViewControllerAnimated(false)
    }
    
    override func continueButtonPressed() {
        view.endEditing(true)
        savePasswordInUser()
        jumpToRegisterInfo()
    }
    
    func jumpToRegisterInfo() {
        let vc = UIStoryboard(name: "Main", bundle: nil) .instantiateViewControllerWithIdentifier("RegisterInfoViewController") as! RegisterInfoViewController
        vc.faeUser = faeUser
        self.navigationController?.pushViewController(vc, animated: false)
    }
    
    func getInfoView() -> UIView {
        
        let infoView = UIView(frame: CGRectMake(0, 0, view.frame.size.width, 85 * screenHeightFactor))
        
        let imageView = UIImageView(frame: CGRectMake(view.frame.size.width/2.0 - 160 * screenWidthFactor, 0, 320 * screenWidthFactor , 85 * screenHeightFactor))
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
        tableView.registerNib(UINib(nibName: "RegisterTextfieldTableViewCell", bundle: nil), forCellReuseIdentifier: "RegisterTextfieldTableViewCellIdentifier")
        
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
                passwordTableViewCell = tableView.dequeueReusableCellWithIdentifier("RegisterTextfieldTableViewCellIdentifier") as! RegisterTextfieldTableViewCell
                
                passwordTableViewCell.setPlaceholderLabelText("New Password",indexPath: indexPath)
                passwordTableViewCell.setRightPlaceHolderDisplay(true)
                passwordTableViewCell.delegate = self
                passwordTableViewCell.setCharacterLimit(16)
            }
            return passwordTableViewCell
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

extension RegisterPasswordViewController: RegisterTextfieldProtocol {
    
    func textFieldDidBeginEditing(indexPath: NSIndexPath) {
        activeIndexPath = indexPath
    }
    
    func textFieldShouldReturn(indexPath: NSIndexPath) {
        switch indexPath.row {
        case 2:
            passwordTableViewCell.endAsResponder()
            break
        default: break
        }
    }
    
    func textFieldDidChange(text: String, indexPath: NSIndexPath) {
        switch indexPath.row {
        case 2:
            password = text
            passwordTableViewCell.updateTextColorAccordingToPassword(text)
            break
        default: break
        }
        validation()
    }
}

