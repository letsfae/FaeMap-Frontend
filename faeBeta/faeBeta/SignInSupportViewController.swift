//
//  SignInSupportViewController.swift
//  faeBeta
//
//  Created by blesssecret on 8/15/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

class SignInSupportViewController: UIViewController, FAENumberKeyboardDelegate {
    
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
    private var titleLabel: UILabel!
    private var emailTextField: FAETextField!
    private var infoButton: UIButton!
    private var sendCodeButton: UIButton!
    
    private enum pageStateType {
        case enteringUserName
        case enteringCode
    }
    
    private var pageState = pageStateType.enteringUserName
    private var numberKeyboard: FAENumberKeyboard!
    private var verificationCodeView: FAEVerificationCodeView!
    
    private var timer: NSTimer!
    private var remainingTime = 59
    
    //MARK: - View did/will ...
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
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "NavigationBackNew"), style: UIBarButtonItemStyle.Plain, target: self, action:#selector(SignInSupportViewController.navBarLeftButtonTapped))
        self.navigationController?.navigationBarHidden = false
    }
    
    private func setupInterface()
    {
        
        // set up the title label
        titleLabel = UILabel(frame: CGRectMake(30, 72, self.screenWidth - 60, 60))
        titleLabel.numberOfLines = 2
        titleLabel.attributedText = NSAttributedString(string: "Enter your Email\nto Reset Password", attributes: [NSForegroundColorAttributeName: UIColor.faeAppInputTextGrayColor(), NSFontAttributeName: UIFont(name: "AvenirNext-Medium", size: 20)!])
        titleLabel.textAlignment = .Center
        //        titleLabel.sizeToFit()
        titleLabel.center.x = self.screenWidth / 2
        self.view.addSubview(titleLabel)
        
        // set up the email/username text field
        emailTextField = FAETextField(frame: CGRectMake(15,171, screenWidth - 30, 30))
        emailTextField.placeholder = "Email Address"
        self.view.addSubview(emailTextField)
        
        // set up the "We can’t find an account with this Email!" label
        infoButton = UIButton(frame: CGRectMake(87, 407, screenWidth - 175, 18))
        infoButton.setAttributedTitle(NSAttributedString(string: "We can’t find an account with this Email!", attributes: [NSForegroundColorAttributeName: UIColor.faeAppRedColor(), NSFontAttributeName: UIFont(name: "AvenirNext-Medium", size: 13)!]),
                                      forState: .Normal)
        infoButton.contentHorizontalAlignment = .Center
        infoButton.sizeToFit()
        infoButton.center.x = self.screenWidth / 2
        self.view.addSubview(infoButton)
        
        // set up the send button
        sendCodeButton = UIButton(frame: CGRectMake(57, 444, 300, 50))
        sendCodeButton.setAttributedTitle(NSAttributedString(string: "Send Code", attributes: [NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: UIFont(name: "AvenirNext-DemiBold", size: 20)!]), forState:.Normal)
        sendCodeButton.layer.cornerRadius = 25
        sendCodeButton.backgroundColor = UIColor.faeAppRedColor()
        sendCodeButton.addTarget(self, action: #selector(SignInSupportViewController.sendCodeButtonTapped), forControlEvents: .TouchUpInside)
        self.view.insertSubview(sendCodeButton, atIndex: 0)
        
    }
    
    func sendCodeButtonTapped()
    {
        if(pageState == .enteringUserName){
            titleLabel.attributedText = NSAttributedString(string: "Enter the Code we just\nsent to your Email to continue", attributes: [NSForegroundColorAttributeName: UIColor.faeAppInputTextGrayColor(), NSFontAttributeName: UIFont(name: "AvenirNext-Medium", size: 20)!])
            titleLabel.sizeToFit()
            titleLabel.center.x = self.screenWidth / 2
            self.view.endEditing(true)
            
            // setup the fake keyboard for numbers input
            numberKeyboard = FAENumberKeyboard(frame:CGRectMake(57,480,300,244))
            self.view.addSubview(numberKeyboard)
            numberKeyboard.delegate = self
            numberKeyboard.transform = CGAffineTransformMakeTranslation(0, numberKeyboard.bounds.size.height)
            
            // setup the verification code screen
            verificationCodeView = FAEVerificationCodeView(frame:CGRectMake(85, 148, 244, 82))
            self.view.addSubview(verificationCodeView)
            verificationCodeView.alpha = 0
            
            // start transaction animation
            UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseInOut , animations: {
                
                self.infoButton.setAttributedTitle(NSAttributedString(string: "Resend Code 60", attributes: [NSForegroundColorAttributeName: UIColor.faeAppRedColor(), NSFontAttributeName: UIFont(name: "AvenirNext-Medium", size: 13)!]), forState: .Normal)
                self.sendCodeButton.setAttributedTitle(NSAttributedString(string: "Continue", attributes: [NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: UIFont(name: "AvenirNext-DemiBold", size: 20)!]), forState:.Normal)
                
                self.infoButton.frame = CGRectMake(87, 373, self.screenWidth - 175, 18)
                self.sendCodeButton.frame = CGRectMake(57, 409, 300, 50)
                
                self.emailTextField.alpha = 0
                self.numberKeyboard.transform = CGAffineTransformMakeTranslation(0, 0)
                self.verificationCodeView.alpha = 1
                
                self.view.layoutIfNeeded()
                }, completion: { (Bool) in
                    self.emailTextField.hidden = true
                    self.startTimer()
            })
            
            pageState = .enteringCode
        }else{
            let controller = UIStoryboard(name: "Main",bundle: nil).instantiateViewControllerWithIdentifier("SignInSupportNewPassViewController") as! SignInSupportNewPassViewController
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    
    //MARK: - FAENumberKeyboard delegate
    func keyboardButtonTapped(num:Int)
    {
        verificationCodeView.addDigit(num)
    }
    
    //MARK: helper
    func startTimer()
    {
        infoButton.setAttributedTitle(NSAttributedString(string: "Resend Code 60", attributes: [NSForegroundColorAttributeName: UIColor.faeAppRedColor(), NSFontAttributeName: UIFont(name: "AvenirNext-Medium", size: 13)!]), forState: .Normal)
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(SignInSupportViewController.updateTime), userInfo: nil, repeats: true)
    }
    
    func updateTime()
    {
        if(remainingTime > 0){
            self.infoButton.setAttributedTitle(NSAttributedString(string: "Resend Code \(remainingTime)", attributes: [NSForegroundColorAttributeName: UIColor.faeAppRedColor(), NSFontAttributeName: UIFont(name: "AvenirNext-Medium", size: 13)!]), forState: .Normal)
            remainingTime = remainingTime - 1
        }
        else{
            remainingTime = 59
            timer.invalidate()
            timer = nil
            self.infoButton.setAttributedTitle(NSAttributedString(string: "Resend Code", attributes: [NSForegroundColorAttributeName: UIColor.faeAppRedColor(), NSFontAttributeName: UIFont(name: "AvenirNext-Bold", size: 13)!]), forState: .Normal)
            self.infoButton.addTarget(self, action: #selector(SignInSupportViewController.resendVerificationCode), forControlEvents: .TouchUpInside )
        }
    }
    
    func resendVerificationCode()
    {
        startTimer()
        infoButton.removeTarget(self, action: #selector(SignInSupportViewController.resendVerificationCode), forControlEvents: .TouchUpInside)
    }
    
    
    func navBarLeftButtonTapped()
    {
        self.navigationController?.popViewControllerAnimated(true)
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
