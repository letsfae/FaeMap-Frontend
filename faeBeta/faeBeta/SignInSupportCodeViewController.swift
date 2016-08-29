//
//  SignInSupportCodeViewController.swift
//  faeBeta
//
//  Created by Yash on 28/08/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

class SignInSupportCodeViewController: RegisterBaseViewController {
    
    // MARK: - Variables
    
    var enterCodeTableViewCell: EnterCodeTableViewCell!
    var code = ""
    var numKeyPad: FAENumberKeyboard!

    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        // Do any additional setup after loading the view.
        createTopView("")
        createTableView(view.frame.size.height - 175)
        createBottomView(resendCodeView())
        
        registerCell()
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        enterCodeTableViewCell.makeFirstResponder()
    }
    
    // MARK: - Functions
    
    func resendCodeView() -> UIView {
        let resendCodeView = UIView(frame: CGRectMake(0, 0, view.frame.size.width, 25))
        
        let label = UILabel(frame: CGRectMake(view.frame.size.width/2.0 - 125, 0, 250, 25))
        label.textAlignment = .Center
        label.font = UIFont(name: "AvenirNext-Medium", size: 13)
        label.textColor = UIColor.init(red: 249/255.0, green: 90/255.0, blue: 90/255.0, alpha: 1.0)
        label.text = "Resend Code."
        
        resendCodeView.addSubview(label)
        
        return resendCodeView
    }
    
    func loginButtonPressed() {
        
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
        let vc:UIViewController = UIStoryboard(name: "Registration", bundle: nil) .instantiateViewControllerWithIdentifier("RegisterUsernameViewController")as! RegisterUsernameViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func validation() {
        var isValid = false
        
        isValid = code.characters.count == 6
        
        enableContinueButton(isValid)
    }
    
    func registerCell() {
        
        tableView.registerNib(UINib(nibName: "TitleTableViewCell", bundle: nil), forCellReuseIdentifier: "TitleTableViewCellIdentifier")
        tableView.registerNib(UINib(nibName: "SpacerTableViewCell", bundle: nil), forCellReuseIdentifier: "SpacerTableViewCellIdentifier")
        tableView.registerNib(UINib(nibName: "EnterCodeTableViewCell", bundle: nil), forCellReuseIdentifier: "EnterCodeTableViewCellIdentifier")
        
    }
    
    // MARK: - Memory Management
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension SignInSupportCodeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCellWithIdentifier("TitleTableViewCellIdentifier") as! TitleTableViewCell
            cell.setTitleLabelText("Enter the Code we just \nsent to your Email to continue")
            return cell
        case 1:
            let cell = tableView.dequeueReusableCellWithIdentifier("SpacerTableViewCellIdentifier") as! SpacerTableViewCell
            return cell
        case 2:
            if enterCodeTableViewCell == nil {
                enterCodeTableViewCell = tableView.dequeueReusableCellWithIdentifier("EnterCodeTableViewCellIdentifier") as! EnterCodeTableViewCell
            }
            return enterCodeTableViewCell
        default:
            let cell = tableView.dequeueReusableCellWithIdentifier("TitleTableViewCellIdentifier") as! TitleTableViewCell
            return cell
            
        }
    }
}

extension SignInSupportCodeViewController: FAENumberKeyboardDelegate {
    func keyboardButtonTapped(num: Int) {
        if num != -1 {
            if code.characters.count < 6 {
                code = "\(code)\(num)"
            }
        } else {
            if code.characters.count >= 0 {
                code = String(code.characters.dropLast())
            }
        }
        enterCodeTableViewCell.showText(code)
        validation()
    }
}

extension SignInSupportCodeViewController {
    
    override func keyboardWillShow(notification: NSNotification) {
        view.endEditing(true)
        if numKeyPad == nil {
            numKeyPad = FAENumberKeyboard(frame:CGRectMake(57,view.frame.size.height, 300, 244))
            self.view.addSubview(numKeyPad)
            numKeyPad.delegate = self
        }
        
        UIView .animateWithDuration(0.3) {
            var frame = self.numKeyPad!.frame
            
            self.bottomView.frame.origin.y = self.view.frame.height - 244 - self.bottomView.frame.size.height
            frame.origin.y = self.view.frame.size.height - 244
            self.numKeyPad.frame = frame
        }
    }
    
    func hideNumKeyboard() {
        var bottomViewFrame = bottomView.frame
        bottomViewFrame.origin.y = view.frame.height - bottomViewFrame.size.height
        
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.bottomView.frame = bottomViewFrame
        })
        
    }
    
}
