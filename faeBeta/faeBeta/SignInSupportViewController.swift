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
    
    private var activityIndicator: UIActivityIndicatorView!
    
    //MARK: - View did/will ...
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupInterface()
        addObservers()
        createActivityIndicator()
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
        titleLabel = UILabel(frame: CGRectMake(30, 72, screenWidth - 60, 60))
        titleLabel.numberOfLines = 2
        titleLabel.attributedText = NSAttributedString(string: "Enter your Email\nto Reset Password", attributes: [NSForegroundColorAttributeName: UIColor.faeAppInputTextGrayColor(), NSFontAttributeName: UIFont(name: "AvenirNext-Medium", size: 20)!])
        titleLabel.textAlignment = .Center
        //        titleLabel.sizeToFit()
        titleLabel.center.x = screenWidth / 2
        titleLabel.adjustsFontSizeToFitWidth = true
        self.view.addSubview(titleLabel)
        
        // set up the email/username text field
        emailTextField = FAETextField(frame: CGRectMake(15,171, screenWidth - 30, 30))
        emailTextField.placeholder = "Email Address"
        emailTextField.adjustsFontSizeToFitWidth = true
        self.view.addSubview(emailTextField)
        
        // set up the "We can’t find an account with this Email!" label
        infoButton = UIButton(frame: CGRectMake(87, screenHeight - 50 * screenHeightFactor - 67 , screenWidth - 175, 18))
        infoButton.setAttributedTitle(NSAttributedString(string: "We can’t find an account with this Email!", attributes: [NSForegroundColorAttributeName: UIColor.faeAppRedColor(), NSFontAttributeName: UIFont(name: "AvenirNext-Medium", size: 13)!]),
                                      forState: .Normal)
        infoButton.contentHorizontalAlignment = .Center
        infoButton.sizeToFit()
        infoButton.center.x = screenWidth / 2
        infoButton.alpha = 0
        self.view.addSubview(infoButton)
        
        // set up the send button
        sendCodeButton = UIButton(frame: CGRectMake(0, screenHeight - 30 - 50 * screenHeightFactor, screenWidth - 114 * screenWidthFactor * screenWidthFactor, 50 * screenHeightFactor))
        sendCodeButton.center.x = screenWidth / 2
        
        sendCodeButton.setAttributedTitle(NSAttributedString(string: "Send Code", attributes: [NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: UIFont(name: "AvenirNext-DemiBold", size: 20)!]), forState:.Normal)
        sendCodeButton.layer.cornerRadius = 25*screenHeightFactor
        sendCodeButton.enabled = false
        sendCodeButton.backgroundColor = UIColor.faeAppDisabledRedColor()
        sendCodeButton.addTarget(self, action: #selector(SignInSupportViewController.sendCodeButtonTapped), forControlEvents: .TouchUpInside)
        self.view.insertSubview(sendCodeButton, atIndex: 0)
        
    }
    
    func setupEnteringVerificationCode()
    {
        
        titleLabel.attributedText = NSAttributedString(string: "Enter the Code we just\nsent to your Email to continue", attributes: [NSForegroundColorAttributeName: UIColor.faeAppInputTextGrayColor(), NSFontAttributeName: UIFont(name: "AvenirNext-Medium", size: 20)!])
        titleLabel.sizeToFit()
        titleLabel.center.x = screenWidth / 2
        self.view.endEditing(true)
        
        // setup the fake keyboard for numbers input
        numberKeyboard = FAENumberKeyboard(frame:CGRectMake(0,screenHeight - 244 * screenHeightFactor ,screenWidth,244 * screenHeightFactor))
        self.view.addSubview(numberKeyboard)
        numberKeyboard.delegate = self
        numberKeyboard.transform = CGAffineTransformMakeTranslation(0, numberKeyboard.bounds.size.height)
        
        // setup the verification code screen
        verificationCodeView = FAEVerificationCodeView(frame:CGRectMake(85 * screenWidthFactor, 148, 244 * screenWidthFactor, 82))
        self.view.addSubview(verificationCodeView)
        verificationCodeView.alpha = 0
        
        sendCodeButton.enabled = false
        sendCodeButton.backgroundColor = UIColor.faeAppDisabledRedColor()
        
        // start transaction animation
        UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseInOut , animations: {
            
            self.infoButton.setAttributedTitle(NSAttributedString(string: "Resend Code 60", attributes: [NSForegroundColorAttributeName: UIColor.faeAppRedColor(), NSFontAttributeName: UIFont(name: "AvenirNext-Medium", size: 13)!]), forState: .Normal)
            self.sendCodeButton.setAttributedTitle(NSAttributedString(string: "Continue", attributes: [NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: UIFont(name: "AvenirNext-DemiBold", size: 20)!]), forState:.Normal)
            
            self.infoButton.frame = CGRectMake(87, screenHeight - 244 * screenHeightFactor - 21 - 50 * screenHeightFactor - 36, screenWidth - 175, 18)
            self.infoButton.alpha = 1

            self.sendCodeButton.frame = CGRectMake(57, screenHeight - 244 * screenHeightFactor - 21 - 50 * screenHeightFactor, screenWidth - 114 * screenWidthFactor * screenWidthFactor, 50 * screenHeightFactor)
            self.sendCodeButton.center.x = screenWidth / 2
            
            self.emailTextField.alpha = 0
            self.numberKeyboard.transform = CGAffineTransformMakeTranslation(0, 0)
            self.verificationCodeView.alpha = 1
            
            self.view.layoutIfNeeded()
            }, completion: { (Bool) in
                self.emailTextField.hidden = true
                self.startTimer()
        })
        
        pageState = .enteringCode

    }
    
    func createActivityIndicator()
    {
        activityIndicator = UIActivityIndicatorView()
        activityIndicator.activityIndicatorViewStyle = .WhiteLarge
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = UIColor.faeAppRedColor()
        
        view.addSubview(activityIndicator)
        view.bringSubviewToFront(activityIndicator)
    }
    
    func sendCodeButtonTapped()
    {
        activityIndicator.startAnimating()
        if(pageState == .enteringUserName){
            self.view.endEditing(true)
            postToURL("reset_login/code", parameter: ["email": emailTextField.text!], authentication: nil, completion: { (statusCode, result) in
                if(statusCode / 100 == 2 ){
                    self.setupEnteringVerificationCode()
                }else{
                    self.infoButton.alpha = 1
                }
                self.activityIndicator.stopAnimating()
            })
        }else{
            postToURL("reset_login/code/verify", parameter: ["email": emailTextField.text!, "code": verificationCodeView.displayValue], authentication: nil, completion: { (statusCode, result) in
                    if(statusCode / 100 == 2){
                        let controller = UIStoryboard(name: "Main",bundle: nil).instantiateViewControllerWithIdentifier("SignInSupportNewPassViewController") as! SignInSupportNewPassViewController
                        self.navigationController?.pushViewController(controller, animated: true)
                    }else{
                        for _ in 0..<6{
                            self.verificationCodeView.addDigit(-1)
                        }
                    }
                    self.activityIndicator.stopAnimating()
            })
        }
    }
    
    func addObservers(){
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name:UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name:UIKeyboardWillHideNotification, object: nil)
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(handleTap))
        self.view.addGestureRecognizer(tapGesture)
        emailTextField.addTarget(self, action: #selector(self.textfieldDidChange(_:)), forControlEvents:.EditingChanged )

    }
    
    //MARK: - FAENumberKeyboard delegate
    func keyboardButtonTapped(num:Int)
    {
        let num = verificationCodeView.addDigit(num)
        // means the user entered 6 digits
        if(num == 6){
            sendCodeButton.enabled = true
            sendCodeButton.backgroundColor = UIColor.faeAppRedColor()
        }else{
            sendCodeButton.enabled = false
            sendCodeButton.backgroundColor = UIColor.faeAppDisabledRedColor()
        }
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
        
        postToURL("reset_login/code", parameter: ["email": emailTextField.text!], authentication: nil, completion: { (statusCode, result) in
            })
        startTimer()
        infoButton.removeTarget(self, action: #selector(SignInSupportViewController.resendVerificationCode), forControlEvents: .TouchUpInside)
    }
    
    
    func navBarLeftButtonTapped()
    {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    // MARK: - keyboard
    
    // This is just a temporary method to make the login button clickable
    func keyboardWillShow(notification:NSNotification){
        let info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.sendCodeButton.frame.origin.y += (screenHeight - keyboardFrame.height) - self.sendCodeButton.frame.origin.y - 50 * screenHeightFactor - 14
            
            self.infoButton.frame.origin.y += (screenHeight - keyboardFrame.height) - self.infoButton.frame.origin.y - 50 * screenHeightFactor - 14 - 18 - 19
        })
    }
    
    func keyboardWillHide(notification:NSNotification){
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.sendCodeButton.frame.origin.y = screenHeight - 30 - 50 * screenHeightFactor
            self.infoButton.frame.origin.y = screenHeight - 50 * screenHeightFactor - 67
        })
    }
    
    //MARK: - helper
    
    func handleTap(){
        self.view.endEditing(true)
    }
    
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let range = testStr.rangeOfString(emailRegEx, options:.RegularExpressionSearch)
        let result = range != nil ? true : false
        return result
    }
    
    func textfieldDidChange(textfield: UITextField){
        if isValidEmail(textfield.text!) {
            sendCodeButton.enabled = true
            sendCodeButton.backgroundColor = UIColor.faeAppRedColor()
        }else{
            sendCodeButton.enabled = false
            sendCodeButton.backgroundColor = UIColor.faeAppDisabledRedColor()
        }
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
