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
    fileprivate var titleLabel: UILabel!
    fileprivate var emailTextField: FAETextField!
    fileprivate var infoButton: UIButton!
    fileprivate var sendCodeButton: UIButton!
    
    fileprivate enum pageStateType {
        case enteringUserName
        case enteringCode
    }
    
    fileprivate var pageState = pageStateType.enteringUserName
    fileprivate var numberKeyboard: FAENumberKeyboard!
    fileprivate var verificationCodeView: FAEVerificationCodeView!
    
    fileprivate var timer: Timer!
    fileprivate var remainingTime = 59
    
    fileprivate var activityIndicator: UIActivityIndicatorView!
    
    //MARK: - View did/will ...
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupInterface()
        addObservers()
        createActivityIndicator()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
        
        //if it's back from set password
        if numberKeyboard != nil{
            self.infoButton.frame = CGRect(x: 87, y: screenHeight - 244 * screenHeightFactor - 21 - 50 * screenHeightFactor - 36, width: screenWidth - 175, height: 18)
            self.infoButton.alpha = 1
            
            self.sendCodeButton.frame = CGRect(x: 57, y: screenHeight - 244 * screenHeightFactor - 21 - 50 * screenHeightFactor, width: screenWidth - 114 * screenWidthFactor * screenWidthFactor, height: 50 * screenHeightFactor)
            self.sendCodeButton.center.x = screenWidth / 2
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func setupNavigationBar()
    {
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.tintColor = UIColor.faeAppRedColor()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "NavigationBackNew"), style: UIBarButtonItemStyle.plain, target: self, action:#selector(SignInSupportViewController.navBarLeftButtonTapped))
        self.navigationController?.isNavigationBarHidden = false
    }
    
    fileprivate func setupInterface()
    {
        
        // set up the title label
        titleLabel = UILabel(frame: CGRect(x: 30, y: 72, width: screenWidth - 60, height: 60))
        titleLabel.numberOfLines = 2
        titleLabel.attributedText = NSAttributedString(string: "Enter your Email\nto Reset Password", attributes: [NSForegroundColorAttributeName: UIColor.faeAppInputTextGrayColor(), NSFontAttributeName: UIFont(name: "AvenirNext-Medium", size: 20)!])
        titleLabel.textAlignment = .center
        //        titleLabel.sizeToFit()
        titleLabel.center.x = screenWidth / 2
        titleLabel.adjustsFontSizeToFitWidth = true
        self.view.addSubview(titleLabel)
        
        // set up the email/username text field
        emailTextField = FAETextField(frame: CGRect(x: 15,y: 171, width: screenWidth - 30, height: 30))
        emailTextField.placeholder = "Email Address"
        emailTextField.adjustsFontSizeToFitWidth = true
        self.view.addSubview(emailTextField)
        
        // set up the "We can’t find an account with this Email!" label
        infoButton = UIButton(frame: CGRect(x: 87, y: screenHeight - 50 * screenHeightFactor - 67 , width: screenWidth - 175, height: 18))
        infoButton.setAttributedTitle(NSAttributedString(string: "We can’t find an account with this Email!", attributes: [NSForegroundColorAttributeName: UIColor.faeAppRedColor(), NSFontAttributeName: UIFont(name: "AvenirNext-Medium", size: 13)!]),
                                      for: UIControlState())
        infoButton.contentHorizontalAlignment = .center
        infoButton.sizeToFit()
        infoButton.center.x = screenWidth / 2
        infoButton.alpha = 0
        self.view.addSubview(infoButton)
        
        // set up the send button
        sendCodeButton = UIButton(frame: CGRect(x: 0, y: screenHeight - 30 - 50 * screenHeightFactor, width: screenWidth - 114 * screenWidthFactor * screenWidthFactor, height: 50 * screenHeightFactor))
        sendCodeButton.center.x = screenWidth / 2
        
        sendCodeButton.setAttributedTitle(NSAttributedString(string: "Send Code", attributes: [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: UIFont(name: "AvenirNext-DemiBold", size: 20)!]), for:UIControlState())
        sendCodeButton.layer.cornerRadius = 25*screenHeightFactor
        sendCodeButton.isEnabled = false
        sendCodeButton.backgroundColor = UIColor.faeAppDisabledRedColor()
        sendCodeButton.addTarget(self, action: #selector(SignInSupportViewController.sendCodeButtonTapped), for: .touchUpInside)
        self.view.insertSubview(sendCodeButton, at: 0)
        
    }
    
    func setupEnteringVerificationCode()
    {
        
        titleLabel.attributedText = NSAttributedString(string: "Enter the Code we just\nsent to your Email to continue", attributes: [NSForegroundColorAttributeName: UIColor.faeAppInputTextGrayColor(), NSFontAttributeName: UIFont(name: "AvenirNext-Medium", size: 20)!])
        titleLabel.sizeToFit()
        titleLabel.center.x = screenWidth / 2
        self.view.endEditing(true)
        
        // setup the fake keyboard for numbers input
        numberKeyboard = FAENumberKeyboard(frame:CGRect(x: 0,y: screenHeight - 244 * screenHeightFactor ,width: screenWidth,height: 244 * screenHeightFactor))
        self.view.addSubview(numberKeyboard)
        numberKeyboard.delegate = self
        numberKeyboard.transform = CGAffineTransform(translationX: 0, y: numberKeyboard.bounds.size.height)
        
        // setup the verification code screen
        verificationCodeView = FAEVerificationCodeView(frame:CGRect(x: 85 * screenWidthFactor, y: 148, width: 244 * screenWidthFactor, height: 82))
        self.view.addSubview(verificationCodeView)
        verificationCodeView.alpha = 0
        
        sendCodeButton.isEnabled = false
        sendCodeButton.backgroundColor = UIColor.faeAppDisabledRedColor()
        
        // start transaction animation
        UIView.animate(withDuration: 0.3, delay: 0, options: UIViewAnimationOptions() , animations: {
            
            self.infoButton.setAttributedTitle(NSAttributedString(string: "Resend Code 60", attributes: [NSForegroundColorAttributeName: UIColor.faeAppRedColor(), NSFontAttributeName: UIFont(name: "AvenirNext-Medium", size: 13)!]), for: UIControlState())
            self.sendCodeButton.setAttributedTitle(NSAttributedString(string: "Continue", attributes: [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: UIFont(name: "AvenirNext-DemiBold", size: 20)!]), for:UIControlState())
            
            self.infoButton.frame = CGRect(x: 87, y: screenHeight - 244 * screenHeightFactor - 21 - 50 * screenHeightFactor - 36, width: screenWidth - 175, height: 18)
            self.infoButton.alpha = 1

            self.sendCodeButton.frame = CGRect(x: 57, y: screenHeight - 244 * screenHeightFactor - 21 - 50 * screenHeightFactor, width: screenWidth - 114 * screenWidthFactor * screenWidthFactor, height: 50 * screenHeightFactor)
            self.sendCodeButton.center.x = screenWidth / 2
            
            self.emailTextField.alpha = 0
            self.numberKeyboard.transform = CGAffineTransform(translationX: 0, y: 0)
            self.verificationCodeView.alpha = 1
            
            self.view.layoutIfNeeded()
            }, completion: { (Bool) in
                self.emailTextField.isHidden = true
                self.startTimer()
        })
        
        pageState = .enteringCode

    }
    
    func createActivityIndicator()
    {
        activityIndicator = UIActivityIndicatorView()
        activityIndicator.activityIndicatorViewStyle = .whiteLarge
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = UIColor.faeAppRedColor()
        
        view.addSubview(activityIndicator)
        view.bringSubview(toFront: activityIndicator)
    }
    
    func sendCodeButtonTapped()
    {
        activityIndicator.startAnimating()
        if(pageState == .enteringUserName){
            self.view.endEditing(true)
            postToURL("reset_login/code", parameter: ["email": emailTextField.text! as AnyObject], authentication: nil, completion: { (statusCode, result) in
                if(statusCode / 100 == 2 ){
                    self.setupEnteringVerificationCode()
                }else{
                    self.infoButton.alpha = 1
                }
                self.activityIndicator.stopAnimating()
            })
        }else{
            postToURL("reset_login/code/verify", parameter: ["email": emailTextField.text! as AnyObject, "code": verificationCodeView.displayValue as AnyObject], authentication: nil, completion: { (statusCode, result) in
                    if(statusCode / 100 == 2){
                        let controller = UIStoryboard(name: "Main",bundle: nil).instantiateViewController(withIdentifier: "SignInSupportNewPassViewController") as! SignInSupportNewPassViewController
                        controller.email = self.emailTextField.text!
                        controller.code = self.verificationCodeView.displayValue
                        self.navigationController?.pushViewController(controller, animated: true)
                    }else{
                        for _ in 0..<6{
                            _ = self.verificationCodeView.addDigit(-1)
                        }
                    }
                    self.activityIndicator.stopAnimating()
            })
        }
    }
    
    func addObservers(){
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(handleTap))
        self.view.addGestureRecognizer(tapGesture)
        emailTextField.addTarget(self, action: #selector(self.textfieldDidChange(_:)), for:.editingChanged )

    }
    
    //MARK: - FAENumberKeyboard delegate
    func keyboardButtonTapped(_ num:Int)
    {
        let num = verificationCodeView.addDigit(num)
        // means the user entered 6 digits
        if(num == 6){
            sendCodeButton.isEnabled = true
            sendCodeButton.backgroundColor = UIColor.faeAppRedColor()
        }else{
            sendCodeButton.isEnabled = false
            sendCodeButton.backgroundColor = UIColor.faeAppDisabledRedColor()
        }
    }
    
    //MARK: helper
    func startTimer()
    {
        infoButton.setAttributedTitle(NSAttributedString(string: "Resend Code 60", attributes: [NSForegroundColorAttributeName: UIColor.faeAppRedColor(), NSFontAttributeName: UIFont(name: "AvenirNext-Medium", size: 13)!]), for: UIControlState())
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(SignInSupportViewController.updateTime), userInfo: nil, repeats: true)
    }
    
    func updateTime()
    {
        if(remainingTime > 0){
            self.infoButton.setAttributedTitle(NSAttributedString(string: "Resend Code \(remainingTime)", attributes: [NSForegroundColorAttributeName: UIColor.faeAppRedColor(), NSFontAttributeName: UIFont(name: "AvenirNext-Medium", size: 13)!]), for: UIControlState())
            remainingTime = remainingTime - 1
        }
        else{
            remainingTime = 59
            timer.invalidate()
            timer = nil
            self.infoButton.setAttributedTitle(NSAttributedString(string: "Resend Code", attributes: [NSForegroundColorAttributeName: UIColor.faeAppRedColor(), NSFontAttributeName: UIFont(name: "AvenirNext-Bold", size: 13)!]), for: UIControlState())
            self.infoButton.addTarget(self, action: #selector(SignInSupportViewController.resendVerificationCode), for: .touchUpInside )
        }
    }
    
    func resendVerificationCode()
    {
        
        postToURL("reset_login/code", parameter: ["email": emailTextField.text! as AnyObject], authentication: nil, completion: { (statusCode, result) in
            })
        startTimer()
        infoButton.removeTarget(self, action: #selector(SignInSupportViewController.resendVerificationCode), for: .touchUpInside)
    }
    
    
    func navBarLeftButtonTapped()
    {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - keyboard
    
    // This is just a temporary method to make the login button clickable
    func keyboardWillShow(_ notification:Notification){
        let info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.sendCodeButton.frame.origin.y += (screenHeight - keyboardFrame.height) - self.sendCodeButton.frame.origin.y - 50 * screenHeightFactor - 14
            
            self.infoButton.frame.origin.y += (screenHeight - keyboardFrame.height) - self.infoButton.frame.origin.y - 50 * screenHeightFactor - 14 - 18 - 19
        })
    }
    
    func keyboardWillHide(_ notification:Notification){
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.sendCodeButton.frame.origin.y = screenHeight - 30 - 50 * screenHeightFactor
            self.infoButton.frame.origin.y = screenHeight - 50 * screenHeightFactor - 67
        })
    }
    
    //MARK: - helper
    
    func handleTap(){
        self.view.endEditing(true)
    }
    
    func isValidEmail(_ testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let range = testStr.range(of: emailRegEx, options:.regularExpression)
        let result = range != nil ? true : false
        return result
    }
    
    func textfieldDidChange(_ textfield: UITextField){
        if isValidEmail(textfield.text!) {
            sendCodeButton.isEnabled = true
            sendCodeButton.backgroundColor = UIColor.faeAppRedColor()
        }else{
            sendCodeButton.isEnabled = false
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
