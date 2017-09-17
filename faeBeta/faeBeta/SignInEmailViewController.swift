//
//  SignInEmailViewController.swift
//  faeBeta
//
//  Created by blesssecret on 8/15/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

class SignInEmailViewController: UIViewController, FAENumberKeyboardDelegate {
    
    //MARK: - Interface
    fileprivate var lblTitle: UILabel!
    fileprivate var txtEmail: FAETextField!
    fileprivate var btnInfo: UIButton!
    fileprivate var btnSendCode: UIButton!
    
    fileprivate enum pageStateType {
        case enteringUserName
        case enteringCode
    }
    
    fileprivate var statePage = pageStateType.enteringUserName
    fileprivate var numberKeyboard: FAENumberKeyboard!
    fileprivate var verificationCodeView: FAEVerificationCodeView!
    
    fileprivate var timer: Timer!
    fileprivate var remainingTime = 59
    
    fileprivate var indicatorView: UIActivityIndicatorView!
    
    //MARK: - View did/will ...
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        setupNavigationBar()
        setupInterface()
        addObservers()
        createActivityIndicator()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //if it's back from set password
        if numberKeyboard != nil {
            self.btnInfo.frame = CGRect(x: 87, y: screenHeight - 244 * screenHeightFactor - 21 - 50 * screenHeightFactor - 36, width: screenWidth - 175, height: 18)
            self.btnInfo.alpha = 1
            self.btnSendCode.frame = CGRect(x: 57, y: screenHeight - 244 * screenHeightFactor - 21 - 50 * screenHeightFactor, width: screenWidth - 114 * screenWidthFactor * screenWidthFactor, height: 50 * screenHeightFactor)
            self.btnSendCode.center.x = screenWidth / 2
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func setupNavigationBar() {
        let uiviewNavBar = FaeNavBar(frame: .zero)
        view.addSubview(uiviewNavBar)
        uiviewNavBar.loadBtnConstraints()
        uiviewNavBar.leftBtn.setImage(#imageLiteral(resourceName: "NavigationBackNew"), for: .normal)
        uiviewNavBar.leftBtn.addTarget(self, action: #selector(self.navBarLeftButtonTapped), for: .touchUpInside)
        uiviewNavBar.rightBtn.isHidden = true
        uiviewNavBar.bottomLine.isHidden = true
    }
    
    fileprivate func setupInterface() {
        // set up the title label
        lblTitle = UILabel(frame: CGRect(x: 30, y: 72, width: screenWidth - 60, height: 60))
        lblTitle.numberOfLines = 2
        lblTitle.text = "Enter your Email\nto Reset Password"
        lblTitle.textColor = UIColor._898989()
        lblTitle.font = UIFont(name: "AvenirNext-Medium", size: 20)
        //        lblTitle.attributedText = NSAttributedString(string: "Enter your Email\nto Reset Password", attributes: [NSForegroundColorAttributeName: UIColor._898989(), NSFontAttributeName: UIFont(name: "AvenirNext-Medium", size: 20)!])
        lblTitle.textAlignment = .center
        lblTitle.center.x = screenWidth / 2
        lblTitle.adjustsFontSizeToFitWidth = true
        self.view.addSubview(lblTitle)
        
        // set up the email/username text field
        txtEmail = FAETextField(frame: CGRect(x: 15, y: 171, width: screenWidth - 30, height: 30))
        txtEmail.placeholder = "Email Address"
        txtEmail.adjustsFontSizeToFitWidth = true
        txtEmail.becomeFirstResponder()
        self.view.addSubview(txtEmail)
        
        // set up the "We can’t find an account with this Email!" label
        btnInfo = UIButton(frame: CGRect(x: 87, y: screenHeight - 50 * screenHeightFactor - 67 , width: screenWidth - 175, height: 18))
        btnInfo.setAttributedTitle(NSAttributedString(string: "We could’t find an account with this Email!", attributes: [NSForegroundColorAttributeName: UIColor._2499090(), NSFontAttributeName: UIFont(name: "AvenirNext-Medium", size: 13)!]), for: UIControlState())
        btnInfo.contentHorizontalAlignment = .center
        btnInfo.sizeToFit()
        btnInfo.center.x = screenWidth / 2
        btnInfo.alpha = 0
        self.view.addSubview(btnInfo)
        
        // set up the send button
        btnSendCode = UIButton(frame: CGRect(x: 0, y: screenHeight - 30 - 50 * screenHeightFactor, width: screenWidth - 114 * screenWidthFactor * screenWidthFactor, height: 50 * screenHeightFactor))
        btnSendCode.center.x = screenWidth / 2
        btnSendCode.setAttributedTitle(NSAttributedString(string: "Send Code", attributes: [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: UIFont(name: "AvenirNext-DemiBold", size: 20)!]), for:UIControlState())
        btnSendCode.layer.cornerRadius = 25 * screenHeightFactor
        btnSendCode.isEnabled = false
        btnSendCode.backgroundColor = UIColor._255160160()
        btnSendCode.addTarget(self, action: #selector(sendCodeButtonTapped), for: .touchUpInside)
        self.view.insertSubview(btnSendCode, at: 0)
        
    }
    
    func setupEnteringVerificationCode() {
        lblTitle.text = "Enter the Code we just sent \nto your Email to Continue"
        self.view.endEditing(true)
        
        // setup the fake keyboard for numbers input
        numberKeyboard = FAENumberKeyboard(frame: CGRect(x: 0, y: screenHeight - 244 * screenHeightFactor, width: screenWidth, height: 244 * screenHeightFactor))
        self.view.addSubview(numberKeyboard)
        numberKeyboard.delegate = self
        numberKeyboard.transform = CGAffineTransform(translationX: 0, y: numberKeyboard.bounds.size.height)
        
        // setup the verification code screen
        verificationCodeView = FAEVerificationCodeView(frame: CGRect(x: 85 * screenWidthFactor, y: 148, width: 244 * screenWidthFactor, height: 82))
        self.view.addSubview(verificationCodeView)
        verificationCodeView.alpha = 0
        
        btnSendCode.isEnabled = false
        btnSendCode.backgroundColor = UIColor._255160160()
        
        // start transaction animation
        UIView.animate(withDuration: 0.3, delay: 0, options: UIViewAnimationOptions(), animations: {
            self.btnInfo.setAttributedTitle(NSAttributedString(string: "Resend Code 60", attributes: [NSForegroundColorAttributeName: UIColor._2499090(), NSFontAttributeName: UIFont(name: "AvenirNext-Medium", size: 13)!]), for: UIControlState())
            self.btnSendCode.setAttributedTitle(NSAttributedString(string: "Continue", attributes: [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: UIFont(name: "AvenirNext-DemiBold", size: 20)!]), for:UIControlState())
            
            self.btnInfo.frame = CGRect(x: 87, y: screenHeight - 244 * screenHeightFactor - 21 - 50 * screenHeightFactor - 36, width: screenWidth - 175, height: 18)
            self.btnInfo.alpha = 1
            
            self.btnSendCode.frame = CGRect(x: 57, y: screenHeight - 244 * screenHeightFactor - 21 - 50 * screenHeightFactor, width: screenWidth - 114 * screenWidthFactor * screenWidthFactor, height: 50 * screenHeightFactor)
            self.btnSendCode.center.x = screenWidth / 2
            
            self.txtEmail.alpha = 0
            self.numberKeyboard.transform = CGAffineTransform(translationX: 0, y: 0)
            self.verificationCodeView.alpha = 1
            
            self.view.layoutIfNeeded()
        }, completion: {(Bool) in
            self.txtEmail.isHidden = true
            self.startTimer()
        })
        statePage = .enteringCode
    }
    
    func createActivityIndicator() {
        indicatorView = UIActivityIndicatorView()
        indicatorView.activityIndicatorViewStyle = .whiteLarge
        indicatorView.center = view.center
        indicatorView.hidesWhenStopped = true
        indicatorView.color = UIColor._2499090()
        
        view.addSubview(indicatorView)
        view.bringSubview(toFront: indicatorView)
    }
    
    func sendCodeButtonTapped() {
        indicatorView.startAnimating()
        if(statePage == .enteringUserName) {
            self.view.endEditing(true)
            postToURL("reset_login/code", parameter: ["email": txtEmail.text! as AnyObject], authentication: nil, completion: { (statusCode, result) in
                if(statusCode / 100 == 2 ) {
                    self.setupEnteringVerificationCode()
                }
                else {
                    self.btnInfo.alpha = 1
                }
                self.indicatorView.stopAnimating()
            })
        }
        else {
            postToURL("reset_login/code/verify", parameter: ["email": txtEmail.text! as AnyObject, "code": verificationCodeView.displayValue as AnyObject], authentication: nil, completion: { (statusCode, result) in
                if(statusCode / 100 == 2) {
                    let controller = SignInSupportNewPassViewController()
                    controller.email = self.txtEmail.text!
                    controller.code = self.verificationCodeView.displayValue
                    self.navigationController?.pushViewController(controller, animated: true)
                } else {
                    for _ in 0..<6 {
                        _ = self.verificationCodeView.addDigit(-1)
                    }
                    self.lblTitle.text = "That's an Incorrect Code!\n Please Try Again!"
                    self.btnSendCode.isEnabled = false
                    self.btnSendCode.backgroundColor = UIColor._255160160()
                }
                self.indicatorView.stopAnimating()
            })
        }
    }
    
    func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(handleTap))
        self.view.addGestureRecognizer(tapGesture)
        txtEmail.addTarget(self, action: #selector(self.textfieldDidChange(_:)), for: .editingChanged)
    }
    
    //MARK: - FAENumberKeyboard delegate
    func keyboardButtonTapped(_ num:Int) {
        let num = verificationCodeView.addDigit(num)
        // means the user entered 6 digits
        if(num == 6) {
            btnSendCode.isEnabled = true
            btnSendCode.backgroundColor = UIColor._2499090()
        }
        else {
            btnSendCode.isEnabled = false
            btnSendCode.backgroundColor = UIColor._255160160()
        }
    }
    
    //MARK: helper
    func startTimer() {
        btnInfo.setAttributedTitle(NSAttributedString(string: "Resend Code 60", attributes: [NSForegroundColorAttributeName: UIColor._2499090(), NSFontAttributeName: UIFont(name: "AvenirNext-Medium", size: 13)!]), for: UIControlState())
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
    }
    
    func updateTime()
    {
        if(remainingTime > 0) {
            self.btnInfo.setAttributedTitle(NSAttributedString(string: "Resend Code \(remainingTime)", attributes: [NSForegroundColorAttributeName: UIColor._2499090(), NSFontAttributeName: UIFont(name: "AvenirNext-Medium", size: 13)!]), for: UIControlState())
            remainingTime = remainingTime - 1
        }
        else {
            remainingTime = 59
            timer.invalidate()
            timer = nil
            self.btnInfo.setAttributedTitle(NSAttributedString(string: "Resend Code", attributes: [NSForegroundColorAttributeName: UIColor._2499090(), NSFontAttributeName: UIFont(name: "AvenirNext-Bold", size: 13)!]), for: UIControlState())
            self.btnInfo.addTarget(self, action: #selector(resendVerificationCode), for: .touchUpInside )
        }
    }
    
    func resendVerificationCode() {
        postToURL("reset_login/code", parameter: ["email": txtEmail.text! as AnyObject], authentication: nil, completion: {(statusCode, result) in })
        startTimer()
        btnInfo.removeTarget(self, action: #selector(resendVerificationCode), for: .touchUpInside)
    }
    
    func navBarLeftButtonTapped() {
        _ = self.navigationController?.popViewController(animated: true)
    }
    // MARK: - keyboard
    
    // This is just a temporary method to make the login button clickable
    func keyboardWillShow(_ notification: Notification) {
        let info = notification.userInfo!
        let frameKeyboard: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        UIView.animate(withDuration: 0.3, animations: {() -> Void in
            self.btnSendCode.frame.origin.y += (screenHeight - frameKeyboard.height) - self.btnSendCode.frame.origin.y - 50 * screenHeightFactor - 14
            self.btnInfo.frame.origin.y += (screenHeight - frameKeyboard.height) - self.btnInfo.frame.origin.y - 50 * screenHeightFactor - 14 - 18 - 19
        })
    }
    
    func keyboardWillHide(_ notification:Notification) {
        UIView.animate(withDuration: 0.3, animations: {() -> Void in
            self.btnSendCode.frame.origin.y = screenHeight - 30 - 50 * screenHeightFactor
            self.btnInfo.frame.origin.y = screenHeight - 50 * screenHeightFactor - 67
        })
    }
    
    //MARK: - helper
    func handleTap() {
        self.view.endEditing(true)
    }
    
    func isValidEmail(_ testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let range = testStr.range(of: emailRegEx, options: .regularExpression)
        let result = range != nil ? true : false
        return result
    }
    
    func textfieldDidChange(_ textfield: UITextField) {
        if isValidEmail(textfield.text!) {
            btnSendCode.isEnabled = true
            btnSendCode.backgroundColor = UIColor._2499090()
        }
        else {
            btnSendCode.isEnabled = false
            btnSendCode.backgroundColor = UIColor._255160160()
        }
    }
}

