//
//  LogInViewController.swift
//  faeBeta
//
//  Created by blesssecret on 8/15/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
import Foundation

class LogInViewController: UIViewController {
    //MARK: - Interface
    
    private var iconImageView: UIImageView!
    private var supportButton: UIButton!
    private var loginButton: UIButton!
    private var usernameTextField: FAETextField!
    private var passwordTextField: FAETextField!
    // Mark: - View did/will ..
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupInterface()
        addObservers()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setupNavigationBar()
    {
        self.navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.tintColor = UIColor.faeAppRedColor()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "NavigationBackNew"), style: UIBarButtonItemStyle.Plain, target: self, action:#selector(LogInViewController.navBarLeftButtonTapped))
        self.navigationController?.navigationBarHidden = false
    }
    
    private func setupInterface()
    {
        //icon
        iconImageView = UIImageView(image:UIImage(named: "faeWingIcon"))
        iconImageView.frame = CGRectMake(screenWidth/2-30, 70 * screenHeightFactor, 60 * screenHeightFactor, 60 * screenHeightFactor)
        self.view.addSubview(iconImageView)
        
        
        // username textField
        usernameTextField = FAETextField(frame: CGRectMake(15, 174 * screenHeightFactor, screenWidth - 30, 34))
        usernameTextField.placeholder = "Username/Email"
        usernameTextField.adjustsFontSizeToFitWidth = true
        usernameTextField.minimumFontSize = 18
        self.view.addSubview(usernameTextField)
        
        // password textField
        passwordTextField = FAETextField(frame: CGRectMake(15, 243 * screenHeightFactor, screenWidth - 30, 34))
        passwordTextField.placeholder = "Password"
        passwordTextField.secureTextEntry = true
        passwordTextField.minimumFontSize = 18
        self.view.addSubview(passwordTextField)
        
        //support button
        supportButton = UIButton(frame: CGRectMake((screenWidth - 150)/2, screenHeight - 50 * screenHeightFactor - 71 ,150,22))
        supportButton.center.x = screenWidth / 2
        var font = UIFont(name: "AvenirNext-Bold", size: 16)
        
        supportButton.setAttributedTitle(NSAttributedString(string: "Sign In Support", attributes: [NSForegroundColorAttributeName: UIColor.faeAppRedColor(), NSFontAttributeName: font! ]), forState: .Normal)
        supportButton.contentHorizontalAlignment = .Center
        supportButton.addTarget(self, action: #selector(LogInViewController.supportButtonTapped), forControlEvents: .TouchUpInside)
        self.view.insertSubview(supportButton, atIndex: 0)
        
        // log in button
        font = UIFont(name: "AvenirNext-DemiBold", size: 20)
        
        loginButton = UIButton(frame: CGRectMake(0, screenHeight - 30 - 50 * screenHeightFactor, screenWidth - 114 * screenWidthFactor * screenWidthFactor, 50 * screenHeightFactor))
        loginButton.center.x = screenWidth / 2
        loginButton.setAttributedTitle(NSAttributedString(string: "Log in", attributes: [NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: font! ]), forState: .Normal)
        loginButton.layer.cornerRadius = 25*screenHeightFactor
        loginButton.backgroundColor = UIColor.faeAppRedColor()
        loginButton.addTarget(self, action: #selector(LogInViewController.loginButtonTapped), forControlEvents: .TouchUpInside)
        self.view.insertSubview(loginButton, atIndex: 0)
    }
    
    func addObservers(){
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name:UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name:UIKeyboardWillHideNotification, object: nil)
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(handleTap))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    func loginButtonTapped()
    {
        let user = FaeUser()
        user.whereKey("email", value: usernameTextField.text!)
        user.whereKey("password", value: passwordTextField.text!)
//        user.whereKey("user_name", value: "heheda")
        // for iphone: device_id is required and is_mobile should set to true
        user.whereKey("device_id", value: headerDeviceID)
        user.whereKey("is_mobile", value: "true")
        user.logInBackground { (status:Int?, message:AnyObject?) in
            if ( status! / 100 == 2 ){
                //success
//                self.testLabel.text = "login success
                self.dismissViewControllerAnimated(true, completion: nil)
            }
            else{
                //failure
//                self.testLabel.text = "login failure"
            }
        }
    }
    
    func supportButtonTapped()
    {
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("SignInSupportViewController") as! SignInSupportViewController
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    // MARK: - Navigation
    func navBarLeftButtonTapped()
    {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    // MARK: - keyboard 
    
    // This is just a temporary method to make the login button clickable
    func keyboardWillShow(notification:NSNotification){
        let info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.loginButton.frame.origin.y += (screenHeight - keyboardFrame.height) - self.loginButton.frame.origin.y - 50 * screenHeightFactor - 14
            
            self.supportButton.frame.origin.y += (screenHeight - keyboardFrame.height) - self.supportButton.frame.origin.y - 50 * screenHeightFactor - 14 - 22 - 19
        })
    }
    
    func keyboardWillHide(notification:NSNotification){
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.loginButton.frame.origin.y = screenHeight - 30 - 50 * screenHeightFactor
            self.supportButton.frame.origin.y = screenHeight - 50 * screenHeightFactor - 71
        })
    }
    
    func handleTap(){
        self.view.endEditing(true)
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
}
