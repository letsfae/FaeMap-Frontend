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
    var screenWidth : CGFloat {
        get{
            return UIScreen.mainScreen().bounds.width
        }
    }
    var screenHeight : CGFloat {
        get{
            return UIScreen.mainScreen().bounds.height
        }
    }
    
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
        iconImageView = UIImageView(image:UIImage(named: "middleTopButton"))
        iconImageView.frame = CGRectMake(screenWidth/2-30, 70, 60, 60)
        self.view.addSubview(iconImageView)
        
        
        // username textField
        usernameTextField = FAETextField(frame: CGRectMake(15, 174, screenWidth - 30, 34))
        usernameTextField.placeholder = "Username/Email"
        self.view.addSubview(usernameTextField)
        
        // password textField
        passwordTextField = FAETextField(frame: CGRectMake(15, 243, screenWidth - 30, 34))
        passwordTextField.placeholder = "Password"
        passwordTextField.secureTextEntry = true
        self.view.addSubview(passwordTextField)
        
        //support button
        supportButton = UIButton(frame: CGRectMake((screenWidth - 150)/2,407,150,22))
        supportButton.center.x = self.screenWidth / 2
        var font = UIFont(name: "AvenirNext-Bold", size: 16)
        
        supportButton.setAttributedTitle(NSAttributedString(string: "Sign In Support", attributes: [NSForegroundColorAttributeName: UIColor.faeAppRedColor(), NSFontAttributeName: font! ]), forState: .Normal)
        supportButton.contentHorizontalAlignment = .Center
        supportButton.addTarget(self, action: #selector(LogInViewController.supportButtonTapped), forControlEvents: .TouchUpInside)
        self.view.insertSubview(supportButton, atIndex: 0)
        
        // log in button
        font = UIFont(name: "AvenirNext-DemiBold", size: 20)
        
        loginButton = UIButton(frame: CGRectMake(0, 444, 300, 50))
        loginButton.center.x = self.screenWidth / 2
        loginButton.setAttributedTitle(NSAttributedString(string: "Log in", attributes: [NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: font! ]), forState: .Normal)
        loginButton.layer.cornerRadius = 25
        loginButton.backgroundColor = UIColor.faeAppRedColor()
        loginButton.addTarget(self, action: #selector(LogInViewController.loginButtonTapped), forControlEvents: .TouchUpInside)
        self.view.insertSubview(loginButton, atIndex: 0)
    }
    
    func loginButtonTapped()
    {
        
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
    
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
}
