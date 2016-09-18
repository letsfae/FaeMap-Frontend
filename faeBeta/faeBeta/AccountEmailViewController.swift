//
//  AccountEmailViewController.swift
//  faeBeta
//
//  Created by blesssecret on 7/5/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

class AccountEmailViewController: UIViewController {
    let screenWidth = UIScreen.mainScreen().bounds.width
    let screenHeight = UIScreen.mainScreen().bounds.height
    // label and button
    var labelTitle : UILabel!
    var labelEmail : UILabel!
    var buttonVerify : UIButton!
    var buttonChange : UIButton!
    //change email view
    var viewBackgroundChangeEmail : UIView!
    var buttonBackgroundChangeEmail : UIButton!
    var viewChangeEmail : UIView!
    var buttonCloseChangeEmail : UIButton!
    var labelTitleChangeEmail : UILabel!
    var labelEmailNow : UILabel!
    var textFieldChangeEmail : UITextField!
    var viewUnderlineChangeEmail : UIView!
    var buttonSaveChangeEmail : UIButton!
    
    //send code info view
    var viewBackgroundSendCodeInfo : UIView!
    var buttonBackgroundSendCodeInfo : UIButton!
    var viewSendCodeInfo : UIView!
    var labelTitleSendCodeInfo : UILabel!
    var buttonGot : UIButton!
    
    //email verify view
    var viewBackgroundEmailVerify : UIView!
    var buttonBackgroundCloseEmailVerify : UIButton!
    var viewEmailVerify : UIView!
    var buttonCloseEmailVerify : UIButton!
    var labelTitleEmailVerify : UILabel!
    var buttonResend : UIButton!
    var buttonProceed : UIButton!
    var TextFieldDummy = UITextField(frame: CGRectZero)
    var imageCodeDotArray = [UIImageView!]()
    var labelVerificationCode = [UILabel!]()
    var index : Int = 0
    var countDown : Int = 60
    //enter password 
    var viewBackgroundEnterPassword : UIView!
    var buttonBackgroundEnterPassword : UIButton!
    var viewEnterPassword : UIView!
    var buttonCloseEnterPassword : UIButton!
    var labelTitleEnterPassword : UILabel!
    var labelSubtitleEnterPassword : UILabel!
    var textFieldEnterPassword : UITextField!
    var viewUnderlineEnterPassword : UIView!
    var buttonContinuePassword : UIButton!
    var buttonForgotPassword : UIButton!
    var passwordTryLeft : Int = 6
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Account Emails"
        initialAllView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func initialAllView(){
        self.initialView()
        initialChangeEmail()
        initialSendCodeInfo()
        initialEmaiVerify()
        intialEnterPassword()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AccountEmailViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(AccountEmailViewController.update), userInfo: nil, repeats: true)
    }
    func initialView(){
        labelTitle = UILabel(frame: CGRectMake(0,89,screenWidth,25))
        labelTitle.textAlignment = .Center
        labelTitle.text = "Your Primary/Log In Email"
        self.view.addSubview(labelTitle)
        
        labelEmail = UILabel(frame: CGRectMake(0,122,screenWidth,30))
        labelEmail.textAlignment = .Center
        labelEmail.text = userEmail
        self.view.addSubview(labelEmail)
        
        buttonVerify = UIButton(frame: CGRectMake(99,213,217,39))
        buttonVerify.setTitle("Verify", forState: .Normal)
        buttonVerify.backgroundColor = UIColor(colorLiteralRed: 249/255, green: 90/255, blue: 90/255, alpha: 1)
        buttonVerify.layer.cornerRadius = 7
        buttonVerify.addTarget(self, action: #selector(AccountEmailViewController.showSendCodeInfo), forControlEvents: .TouchUpInside)
        self.view.addSubview(buttonVerify)
        
        buttonChange = UIButton(frame: CGRectMake(99,283,217,39))
        buttonChange.setTitle("Change", forState: .Normal)
        buttonChange.backgroundColor = UIColor(colorLiteralRed: 249/255, green: 90/255, blue: 90/255, alpha: 1)
        buttonChange.layer.cornerRadius = 7
        buttonChange.addTarget(self, action: #selector(AccountEmailViewController.showChangeEmailView), forControlEvents: .TouchUpInside)
        self.view.addSubview(buttonChange)
    }
    func keyboardWillShow(notification:NSNotification) {
        let userInfo:NSDictionary = notification.userInfo!
        let keyboardFrame:NSValue = userInfo.valueForKey(UIKeyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.CGRectValue()
        let keyboardHeight = keyboardRectangle.height
        if buttonProceed != nil {
            buttonProceed.frame = CGRectMake(0, screenHeight - 56 - keyboardHeight, screenWidth, 56)
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
//MARK: enter password
extension AccountEmailViewController {
    
    func intialEnterPassword(){
        let x : CGFloat = 32
        let y : CGFloat = 160
        viewBackgroundEnterPassword = UIView(frame:CGRectMake(0,0,screenWidth,screenHeight))
        viewBackgroundEnterPassword.backgroundColor = UIColor(colorLiteralRed: 107/255, green: 105/255, blue: 105/255, alpha: 0.5)
        
        buttonBackgroundEnterPassword = UIButton(frame: CGRectMake(0,0,screenWidth,screenHeight))
        buttonBackgroundEnterPassword.addTarget(self, action: #selector(AccountEmailViewController.removeEnterPassword), forControlEvents: .TouchUpInside)
        viewBackgroundEnterPassword.addSubview(buttonBackgroundEnterPassword)
        
        viewEnterPassword = UIView(frame: CGRectMake(x,y,350,229))
        viewEnterPassword.backgroundColor = UIColor.whiteColor()
        viewEnterPassword.layer.cornerRadius = 21
        viewBackgroundEnterPassword.addSubview(viewEnterPassword)
        
        buttonCloseEnterPassword = UIButton(frame: CGRectMake(47-x,175-y,17,17))
        buttonCloseEnterPassword.addTarget(self, action: #selector(AccountEmailViewController.removeEnterPassword), forControlEvents: .TouchUpInside)
        buttonCloseEnterPassword.setImage(UIImage(named: "accountCloseFirstLast"), forState: .Normal)
        viewEnterPassword.addSubview(buttonCloseEnterPassword)
        
        labelTitleEnterPassword = UILabel(frame: CGRectMake(0,190-y,350,21))
        labelTitleEnterPassword.text = "Enter your Password"
        labelTitleEnterPassword.textAlignment = .Center
        labelTitleEnterPassword.font = UIFont(name: "AvenirNext-Medium", size: 20)
        viewEnterPassword.addSubview(labelTitleEnterPassword)
        
        labelSubtitleEnterPassword = UILabel(frame: CGRectMake(160-x,211-y,97,18))
//        labelSubtitleEnterPassword.hidden = true
        labelSubtitleEnterPassword.textAlignment = .Center
        labelSubtitleEnterPassword.font = UIFont(name: "AvenirNext-Medium", size: 13)
        viewEnterPassword.addSubview(labelSubtitleEnterPassword)
        
        textFieldEnterPassword = UITextField(frame: CGRectMake(74-x,255-y,266,21))
        textFieldEnterPassword.textAlignment = .Center
        viewEnterPassword.addSubview(textFieldEnterPassword)
        
        viewUnderlineEnterPassword = UIView(frame: CGRectMake(74-x,278-y,266,2))
        viewUnderlineEnterPassword.backgroundColor = UIColor(colorLiteralRed: 182/255, green: 182/255, blue: 182/255, alpha: 1)
        viewEnterPassword.addSubview(viewUnderlineEnterPassword)
        
        buttonContinuePassword = UIButton(frame: CGRectMake(139-x,304-y,137,39))
        buttonContinuePassword.layer.cornerRadius = 7
        buttonContinuePassword.backgroundColor = UIColor(colorLiteralRed: 255/255, green: 160/255, blue: 160/255, alpha: 1)
        buttonContinuePassword.setTitle("Continue", forState: .Normal)
        buttonContinuePassword.addTarget(self, action: #selector(AccountEmailViewController.continuePassword), forControlEvents: .TouchUpInside)
        viewEnterPassword.addSubview(buttonContinuePassword)
        
        buttonForgotPassword = UIButton(frame: CGRectMake(158-x,357-y,100,18))
        buttonForgotPassword.setTitle("Forgot Password", forState: .Normal)
        buttonForgotPassword.tintColor = UIColor(colorLiteralRed: 138/255, green: 138/255, blue: 138/255, alpha: 1)
        buttonForgotPassword.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size: 13)
        buttonForgotPassword.addTarget(self, action: #selector(AccountEmailViewController.forgotPassword), forControlEvents: .TouchUpInside)
        viewEnterPassword.addSubview(buttonForgotPassword)
    }
    func forgotPassword(){
        //MARK: error how to connect?
    }
    func continuePassword(){
        //if is right
        if textFieldEnterPassword.text == userPassword {
            removeEnterPassword()
            self.view.addSubview(viewBackgroundChangeEmail)
        } else {
            textFieldEnterPassword.text = ""
            labelTitleEnterPassword.text = "Oops...Wrong Password!"
            if passwordTryLeft > 0 {
                passwordTryLeft -= 1
            }
            labelSubtitleEnterPassword.text = "\(passwordTryLeft) more tries left"
        }
    }
    func removeEnterPassword(){
        viewBackgroundEnterPassword.removeFromSuperview()
        
    }
    func showEnterPassword(){
        self.view.addSubview(viewBackgroundEnterPassword)
    }
}
//MARK: email verify view
extension AccountEmailViewController {
    func initialEmaiVerify(){
        let x : CGFloat = 32
        let y : CGFloat = 139
        countDown = 60
        viewBackgroundEmailVerify = UIView(frame: CGRectMake(0,0,screenWidth,screenHeight))
        viewBackgroundEmailVerify.backgroundColor = UIColor(colorLiteralRed: 107/255, green: 105/255, blue: 105/255, alpha: 0.5)
        
        buttonBackgroundCloseEmailVerify = UIButton(frame: CGRectMake(0,0,screenWidth,screenHeight))
        buttonBackgroundCloseEmailVerify.addTarget(self, action: #selector(AccountEmailViewController.removeEmailVerify), forControlEvents: .TouchUpInside)
        viewBackgroundEmailVerify.addSubview(buttonBackgroundCloseEmailVerify)
        
        viewEmailVerify = UIView(frame: CGRectMake(x,y,350,239))
        viewEmailVerify.backgroundColor = UIColor.whiteColor()
        viewEmailVerify.layer.cornerRadius = 21
        viewBackgroundEmailVerify.addSubview(viewEmailVerify)
        
        buttonCloseEmailVerify = UIButton(frame: CGRectMake(47-x,154-y,17,17))
        buttonCloseEmailVerify.setImage(UIImage(named: "accountCloseFirstLast"), forState: .Normal)
        buttonCloseEmailVerify.addTarget(self, action: #selector(AccountEmailViewController.removeEmailVerify), forControlEvents: .TouchUpInside)
        viewEmailVerify.addSubview(buttonCloseEmailVerify)
        
        labelTitleEmailVerify = UILabel(frame: CGRectMake(85-x,163-y,244,54))
        labelTitleEmailVerify.text = "Please verify your email using the code we sent you"
        labelTitleEmailVerify.font = UIFont(name: "AvenirNext-Medium", size: 20)
        labelTitleEmailVerify.textColor = UIColor(colorLiteralRed: 107/255, green: 105/255, blue: 105/255, alpha: 1)
        labelTitleEmailVerify.numberOfLines = 0
        labelTitleEmailVerify.textAlignment = .Center
        viewEmailVerify.addSubview(labelTitleEmailVerify)
        
        let imageX = 95 - x
        let imageY = 260 - y
        let distance : CGFloat = 42
        for i in 0...5 {
            imageCodeDotArray.append(UIImageView(frame: CGRectMake(imageX + distance * CGFloat(i), imageY, 13, 13)))
            imageCodeDotArray[i].image = UIImage(named: "verification_dot")
            viewEmailVerify.addSubview(imageCodeDotArray[i])
        }
        
        let labelX = 87 - x
        let labelY = 223 - y
//        var distance : CGFloat = 42
        for i in 0...5 {
            labelVerificationCode.append(UILabel(frame: CGRectMake(labelX + CGFloat(i) * distance,labelY,35,82)))
            labelVerificationCode[i].hidden = true
            labelVerificationCode[i].font = UIFont(name: "AvenirNext-Regular", size: 60)
            labelVerificationCode[i].textAlignment = .Center
            labelVerificationCode[i].textColor = UIColor(colorLiteralRed: 249/255, green: 90/255, blue: 90/255, alpha: 1)
            let attributedString = NSMutableAttributedString(string: "\(i)")
            attributedString.addAttribute(NSKernAttributeName, value: CGFloat(-0.6), range: NSRange(location: 0, length: attributedString.length))
            labelVerificationCode[i].attributedText = attributedString
            viewEmailVerify.addSubview(labelVerificationCode[i])
        }
        
        buttonResend = UIButton(frame: CGRectMake(107-x,318-y,200,39))
        buttonResend.setTitle("Resend Code", forState: .Normal)
        buttonResend.layer.cornerRadius = 7
        buttonResend.backgroundColor = UIColor(colorLiteralRed: 249/255, green: 90/255, blue: 90/255, alpha: 1)
        buttonResend.addTarget(self, action: #selector(AccountEmailViewController.resendButtonDidPressed), forControlEvents: .TouchUpInside)
        disableButton(buttonResend)
        viewEmailVerify.addSubview(buttonResend)
        
        buttonProceed = UIButton (frame: CGRectMake(0,441,screenWidth,56))
        buttonProceed.setTitle("Proceed", forState: .Normal)
        buttonProceed.backgroundColor = UIColor(colorLiteralRed: 249/255, green: 90/255, blue: 90/255, alpha: 1)
        buttonProceed.addTarget(self, action: #selector(AccountEmailViewController.proceedCode), forControlEvents: .TouchUpInside)
        disableButton(buttonProceed)
        viewBackgroundEmailVerify.addSubview(buttonProceed)
        
        viewEmailVerify.addSubview(TextFieldDummy)
        TextFieldDummy.keyboardType = UIKeyboardType.NumberPad
        TextFieldDummy.addTarget(self, action: #selector(AccountEmailViewController.textFieldValueDidChanged(_:)), forControlEvents: UIControlEvents.EditingChanged)
        TextFieldDummy.becomeFirstResponder()
        
        
    }
    func proceedCode(){
        verifyCode(TextFieldDummy.text!, email: userEmail)
    }
    func textFieldValueDidChanged(textField: UITextField) {
        
        let buffer = textField.text!
        if(buffer.characters.count<index) {
            index -= 1;
            imageCodeDotArray[index].hidden = false
            labelVerificationCode[index].hidden = true
            disableButton(buttonProceed)
        } else if (buffer.characters.count > index) {
            if(buffer.characters.count >= 6 && !buttonProceed.enabled) {
                enableButton(buttonProceed)
            }
            if(buffer.characters.count > 6) {
                let endIndex = buffer.startIndex.advancedBy(6)
                textField.text = buffer.substringToIndex(endIndex)
            } else {
                labelVerificationCode[index].text = (String)(buffer[buffer.endIndex.predecessor()])
                imageCodeDotArray[index].hidden = true
                labelVerificationCode[index].hidden = false;
                index += 1
            }
        }
        print(index)
        if index == 6 {
            enableButton(buttonProceed)
        }
    }
    func sendCodeToEmailAgain(email : String){
        let user = FaeUser()
//        user.whereKey("email", value: email)
        user.sendCodeToEmail{ (status:Int?, message:AnyObject?) in
            if ( status! / 100 == 2 ){
                //success
                print("Email sent")
                self.TextFieldDummy.text = ""
            }
            else{
                
                //failure
            }
        }
    }
    func verifyCode(input : String, email : String){
        let user = FaeUser()
        user.whereKey("email", value: email)
        user.whereKey("code", value: input)
        user.verifyEmail{ (status:Int?, message:AnyObject?) in
            if ( status! / 100 == 2 ){
                //success
                self.removeEmailVerify()
            }
            else{
                //failure
                self.labelTitleEmailVerify.text = "That’s an incorrect Code!\nPlease try again!"
            }
        }
    }
    func resendButtonDidPressed() {
        disableButton(buttonResend)
        countDown = 60
        // other resent email behavior
        sendCodeToEmailAgain(userEmail)
        disableButton(buttonProceed)
    }
    func update() {
        if(countDown > 0) {
            let title = "Resend Code \(countDown)"
            countDown -= 1
            buttonResend.setTitle(title, forState: .Normal)
            disableButton(buttonResend)
        } else {
            let title = "Resend Code"
            buttonResend.setTitle(title, forState: .Normal)
            enableButton(buttonResend)
        }
    }
    func disableButton(button : UIButton) {
        button.backgroundColor = UIColor(red: 255.0 / 255.0, green: 160.0 / 255.0, blue: 160.0 / 255.0, alpha: 1.0)
        button.enabled = false
    }
    func enableButton(button : UIButton) {
        button.backgroundColor = UIColor(red: 249.0 / 255.0, green: 90.0 / 255.0, blue: 90.0 / 255.0, alpha: 1.0)
        button.enabled = true
    }
    func sendEmailCode(){
        let user = FaeUser()
        user.whereKey("email", value: userEmail)
        user.sendCodeToEmail{ (status:Int?, message:AnyObject?) in
            if ( status! / 100 == 2 ){
                //success
                print("Email sent")
            }
            else{
                
                //failure
            }
        }
    }
    func showEmailVerify(){
        sendEmailCode()
        removeSendCodeInfo()
        self.view.addSubview(viewBackgroundEmailVerify)
    }
    func removeEmailVerify(){
        viewBackgroundEmailVerify.removeFromSuperview()
    }
}
//MARK send code info view
extension AccountEmailViewController {
    func initialSendCodeInfo(){
        let x : CGFloat = 32
        let y : CGFloat = 160
        viewBackgroundSendCodeInfo = UIView(frame: CGRectMake(0,0,screenWidth,screenHeight))
        viewBackgroundSendCodeInfo.backgroundColor = UIColor(colorLiteralRed: 107/255, green: 105/255, blue: 105/255, alpha: 0.5)
        
        buttonBackgroundSendCodeInfo = UIButton(frame: CGRectMake(0,0,screenWidth,screenHeight))
//        buttonBackgroundSendCodeInfo.addTarget(self, action: "removeSendCodeInfo", forControlEvents: .TouchUpInside)
        viewBackgroundSendCodeInfo.addSubview(buttonBackgroundSendCodeInfo)
        
        viewSendCodeInfo = UIView(frame: CGRectMake(x,y,360,208))
        viewSendCodeInfo.backgroundColor = UIColor.whiteColor()
        viewSendCodeInfo.layer.cornerRadius = 21
        viewBackgroundSendCodeInfo.addSubview(viewSendCodeInfo)
        
        labelTitleSendCodeInfo = UILabel(frame: CGRectMake(90-x,197-y,230,90))
        labelTitleSendCodeInfo.textAlignment = .Center
        labelTitleSendCodeInfo.text = "We sent a code to your email. Please verify your email with that code."
        labelTitleSendCodeInfo.numberOfLines = 0
        labelTitleSendCodeInfo.font = UIFont(name: "AvenirNext-Medium", size: 20)
        labelTitleSendCodeInfo.textColor = UIColor(colorLiteralRed: 107/255, green: 107/255, blue: 107/255, alpha: 1)
        viewSendCodeInfo.addSubview(labelTitleSendCodeInfo)
        
        buttonGot = UIButton(frame: CGRectMake(142-x,308-y,130,39))
        buttonGot.layer.cornerRadius = 7
        buttonGot.backgroundColor = UIColor(colorLiteralRed: 249/255, green: 90/255, blue: 90/255, alpha: 1)
        buttonGot.setTitle("Got it!", forState: .Normal)
        buttonGot.addTarget(self, action: #selector(AccountEmailViewController.showEmailVerify), forControlEvents: .TouchUpInside)
        viewSendCodeInfo.addSubview(buttonGot)
        
    }
    func showSendCodeInfo(){
        self.view.addSubview(viewBackgroundSendCodeInfo)
    }
    func removeSendCodeInfo(){
        viewBackgroundSendCodeInfo.removeFromSuperview()
    }
}
//MARK: change email view
extension AccountEmailViewController {
    func initialChangeEmail(){
        let x : CGFloat = 32
        let y : CGFloat = 160
        viewBackgroundChangeEmail = UIView(frame: CGRectMake(0,0,screenWidth,screenHeight))
        viewBackgroundChangeEmail.backgroundColor = UIColor(colorLiteralRed: 107/255, green: 105/255, blue: 105/255, alpha: 0.5)
        
        buttonBackgroundChangeEmail = UIButton(frame: CGRectMake(0,0,screenWidth,screenHeight))
        buttonBackgroundChangeEmail.addTarget(self, action: #selector(AccountEmailViewController.removeChangeEmailView), forControlEvents: .TouchUpInside)
        viewBackgroundChangeEmail.addSubview(buttonBackgroundChangeEmail)
        
        viewChangeEmail = UIView(frame: CGRectMake(x,y,350,208))
        viewChangeEmail.backgroundColor = UIColor.whiteColor()
        viewChangeEmail.layer.cornerRadius = 21
        viewBackgroundChangeEmail.addSubview(viewChangeEmail)
        
        buttonCloseChangeEmail = UIButton(frame: CGRectMake(47-x,175-y,17,17))
        buttonCloseChangeEmail.setImage(UIImage(named: "accountCloseFirstLast"), forState: .Normal)
        buttonCloseChangeEmail.addTarget(self, action: #selector(AccountEmailViewController.removeChangeEmailView), forControlEvents: .TouchUpInside)
        viewChangeEmail.addSubview(buttonCloseChangeEmail)
        
        labelTitleChangeEmail = UILabel(frame: CGRectMake(0,190-y,350,21))
        labelTitleChangeEmail.text = "Edit Email"
        labelTitleChangeEmail.textAlignment = .Center
        labelTitleChangeEmail.font = UIFont(name: "AvenirNext-Medium", size: 20)
        labelTitleChangeEmail.textColor = UIColor(colorLiteralRed: 107/255, green: 107/255, blue: 107/255, alpha: 1)
        viewChangeEmail.addSubview(labelTitleChangeEmail)
        
        textFieldChangeEmail = UITextField(frame:CGRectMake(74-x,250-y,266,21))
        textFieldChangeEmail.textAlignment = .Center
        textFieldChangeEmail.textColor = UIColor(colorLiteralRed: 138/255, green: 138/255, blue: 138/255, alpha: 1)
        viewChangeEmail.addSubview(textFieldChangeEmail)
        
        viewUnderlineChangeEmail = UIView(frame: CGRectMake(74-x,273-y,266,2))
        viewUnderlineChangeEmail.backgroundColor = UIColor(colorLiteralRed: 182/255, green: 182/255, blue: 182/255, alpha: 1)
        viewChangeEmail.addSubview(viewUnderlineChangeEmail)
        
        buttonSaveChangeEmail = UIButton(frame: CGRectMake(142-x,308-y,130,39))
        buttonSaveChangeEmail.setTitle("Save", forState: .Normal)
        buttonSaveChangeEmail.backgroundColor = UIColor(colorLiteralRed: 249/255, green: 90/255, blue: 90/255, alpha: 1)
        viewChangeEmail.addSubview(buttonSaveChangeEmail)
    }
    func showChangeEmailView(){
        if userEmailVerified == false {
            self.view.addSubview(viewBackgroundChangeEmail)
        } else {
            self.showEnterPassword()
        }
    }
    func removeChangeEmailView(){
        viewBackgroundChangeEmail.removeFromSuperview()
    }
}
