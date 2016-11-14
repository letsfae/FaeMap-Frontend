//
//  AccountEmailViewController.swift
//  faeBeta
//
//  Created by blesssecret on 7/5/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

class AccountEmailViewController: UIViewController {
    let screenWidth = UIScreen.main.bounds.width
    let screenHeight = UIScreen.main.bounds.height
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
    var TextFieldDummy = UITextField(frame: CGRect.zero)
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
        NotificationCenter.default.addObserver(self, selector: #selector(AccountEmailViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(AccountEmailViewController.update), userInfo: nil, repeats: true)
    }
    func initialView(){
        labelTitle = UILabel(frame: CGRect(x: 0,y: 89,width: screenWidth,height: 25))
        labelTitle.textAlignment = .center
        labelTitle.text = "Your Primary/Log In Email"
        self.view.addSubview(labelTitle)
        
        labelEmail = UILabel(frame: CGRect(x: 0,y: 122,width: screenWidth,height: 30))
        labelEmail.textAlignment = .center
        labelEmail.text = userEmail
        self.view.addSubview(labelEmail)
        
        buttonVerify = UIButton(frame: CGRect(x: 99,y: 213,width: 217,height: 39))
        buttonVerify.setTitle("Verify", for: UIControlState())
        buttonVerify.backgroundColor = UIColor(colorLiteralRed: 249/255, green: 90/255, blue: 90/255, alpha: 1)
        buttonVerify.layer.cornerRadius = 7
        buttonVerify.addTarget(self, action: #selector(AccountEmailViewController.showSendCodeInfo), for: .touchUpInside)
        self.view.addSubview(buttonVerify)
        
        buttonChange = UIButton(frame: CGRect(x: 99,y: 283,width: 217,height: 39))
        buttonChange.setTitle("Change", for: UIControlState())
        buttonChange.backgroundColor = UIColor(colorLiteralRed: 249/255, green: 90/255, blue: 90/255, alpha: 1)
        buttonChange.layer.cornerRadius = 7
        buttonChange.addTarget(self, action: #selector(AccountEmailViewController.showChangeEmailView), for: .touchUpInside)
        self.view.addSubview(buttonChange)
    }
    func keyboardWillShow(_ notification:Notification) {
        let userInfo:NSDictionary = notification.userInfo! as NSDictionary
        let keyboardFrame:NSValue = userInfo.value(forKey: UIKeyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue
        let keyboardHeight = keyboardRectangle.height
        if buttonProceed != nil {
            buttonProceed.frame = CGRect(x: 0, y: screenHeight - 56 - keyboardHeight, width: screenWidth, height: 56)
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
        viewBackgroundEnterPassword = UIView(frame:CGRect(x: 0,y: 0,width: screenWidth,height: screenHeight))
        viewBackgroundEnterPassword.backgroundColor = UIColor(colorLiteralRed: 107/255, green: 105/255, blue: 105/255, alpha: 0.5)
        
        buttonBackgroundEnterPassword = UIButton(frame: CGRect(x: 0,y: 0,width: screenWidth,height: screenHeight))
        buttonBackgroundEnterPassword.addTarget(self, action: #selector(AccountEmailViewController.removeEnterPassword), for: .touchUpInside)
        viewBackgroundEnterPassword.addSubview(buttonBackgroundEnterPassword)
        
        viewEnterPassword = UIView(frame: CGRect(x: x,y: y,width: 350,height: 229))
        viewEnterPassword.backgroundColor = UIColor.white
        viewEnterPassword.layer.cornerRadius = 21
        viewBackgroundEnterPassword.addSubview(viewEnterPassword)
        
        buttonCloseEnterPassword = UIButton(frame: CGRect(x: 47-x,y: 175-y,width: 17,height: 17))
        buttonCloseEnterPassword.addTarget(self, action: #selector(AccountEmailViewController.removeEnterPassword), for: .touchUpInside)
        buttonCloseEnterPassword.setImage(UIImage(named: "accountCloseFirstLast"), for: UIControlState())
        viewEnterPassword.addSubview(buttonCloseEnterPassword)
        
        labelTitleEnterPassword = UILabel(frame: CGRect(x: 0,y: 190-y,width: 350,height: 21))
        labelTitleEnterPassword.text = "Enter your Password"
        labelTitleEnterPassword.textAlignment = .center
        labelTitleEnterPassword.font = UIFont(name: "AvenirNext-Medium", size: 20)
        viewEnterPassword.addSubview(labelTitleEnterPassword)
        
        labelSubtitleEnterPassword = UILabel(frame: CGRect(x: 160-x,y: 211-y,width: 97,height: 18))
//        labelSubtitleEnterPassword.hidden = true
        labelSubtitleEnterPassword.textAlignment = .center
        labelSubtitleEnterPassword.font = UIFont(name: "AvenirNext-Medium", size: 13)
        viewEnterPassword.addSubview(labelSubtitleEnterPassword)
        
        textFieldEnterPassword = UITextField(frame: CGRect(x: 74-x,y: 255-y,width: 266,height: 21))
        textFieldEnterPassword.textAlignment = .center
        viewEnterPassword.addSubview(textFieldEnterPassword)
        
        viewUnderlineEnterPassword = UIView(frame: CGRect(x: 74-x,y: 278-y,width: 266,height: 2))
        viewUnderlineEnterPassword.backgroundColor = UIColor(colorLiteralRed: 182/255, green: 182/255, blue: 182/255, alpha: 1)
        viewEnterPassword.addSubview(viewUnderlineEnterPassword)
        
        buttonContinuePassword = UIButton(frame: CGRect(x: 139-x,y: 304-y,width: 137,height: 39))
        buttonContinuePassword.layer.cornerRadius = 7
        buttonContinuePassword.backgroundColor = UIColor(colorLiteralRed: 255/255, green: 160/255, blue: 160/255, alpha: 1)
        buttonContinuePassword.setTitle("Continue", for: UIControlState())
        buttonContinuePassword.addTarget(self, action: #selector(AccountEmailViewController.continuePassword), for: .touchUpInside)
        viewEnterPassword.addSubview(buttonContinuePassword)
        
        buttonForgotPassword = UIButton(frame: CGRect(x: 158-x,y: 357-y,width: 100,height: 18))
        buttonForgotPassword.setTitle("Forgot Password", for: UIControlState())
        buttonForgotPassword.tintColor = UIColor(colorLiteralRed: 138/255, green: 138/255, blue: 138/255, alpha: 1)
        buttonForgotPassword.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size: 13)
        buttonForgotPassword.addTarget(self, action: #selector(AccountEmailViewController.forgotPassword), for: .touchUpInside)
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
        viewBackgroundEmailVerify = UIView(frame: CGRect(x: 0,y: 0,width: screenWidth,height: screenHeight))
        viewBackgroundEmailVerify.backgroundColor = UIColor(colorLiteralRed: 107/255, green: 105/255, blue: 105/255, alpha: 0.5)
        
        buttonBackgroundCloseEmailVerify = UIButton(frame: CGRect(x: 0,y: 0,width: screenWidth,height: screenHeight))
        buttonBackgroundCloseEmailVerify.addTarget(self, action: #selector(AccountEmailViewController.removeEmailVerify), for: .touchUpInside)
        viewBackgroundEmailVerify.addSubview(buttonBackgroundCloseEmailVerify)
        
        viewEmailVerify = UIView(frame: CGRect(x: x,y: y,width: 350,height: 239))
        viewEmailVerify.backgroundColor = UIColor.white
        viewEmailVerify.layer.cornerRadius = 21
        viewBackgroundEmailVerify.addSubview(viewEmailVerify)
        
        buttonCloseEmailVerify = UIButton(frame: CGRect(x: 47-x,y: 154-y,width: 17,height: 17))
        buttonCloseEmailVerify.setImage(UIImage(named: "accountCloseFirstLast"), for: UIControlState())
        buttonCloseEmailVerify.addTarget(self, action: #selector(AccountEmailViewController.removeEmailVerify), for: .touchUpInside)
        viewEmailVerify.addSubview(buttonCloseEmailVerify)
        
        labelTitleEmailVerify = UILabel(frame: CGRect(x: 85-x,y: 163-y,width: 244,height: 54))
        labelTitleEmailVerify.text = "Please verify your email using the code we sent you"
        labelTitleEmailVerify.font = UIFont(name: "AvenirNext-Medium", size: 20)
        labelTitleEmailVerify.textColor = UIColor(colorLiteralRed: 107/255, green: 105/255, blue: 105/255, alpha: 1)
        labelTitleEmailVerify.numberOfLines = 0
        labelTitleEmailVerify.textAlignment = .center
        viewEmailVerify.addSubview(labelTitleEmailVerify)
        
        let imageX = 95 - x
        let imageY = 260 - y
        let distance : CGFloat = 42
        for i in 0...5 {
            imageCodeDotArray.append(UIImageView(frame: CGRect(x: imageX + distance * CGFloat(i), y: imageY, width: 13, height: 13)))
            imageCodeDotArray[i].image = UIImage(named: "verification_dot")
            viewEmailVerify.addSubview(imageCodeDotArray[i])
        }
        
        let labelX = 87 - x
        let labelY = 223 - y
//        var distance : CGFloat = 42
        for i in 0...5 {
            labelVerificationCode.append(UILabel(frame: CGRect(x: labelX + CGFloat(i) * distance,y: labelY,width: 35,height: 82)))
            labelVerificationCode[i].isHidden = true
            labelVerificationCode[i].font = UIFont(name: "AvenirNext-Regular", size: 60)
            labelVerificationCode[i].textAlignment = .center
            labelVerificationCode[i].textColor = UIColor(colorLiteralRed: 249/255, green: 90/255, blue: 90/255, alpha: 1)
            let attributedString = NSMutableAttributedString(string: "\(i)")
            attributedString.addAttribute(NSKernAttributeName, value: CGFloat(-0.6), range: NSRange(location: 0, length: attributedString.length))
            labelVerificationCode[i].attributedText = attributedString
            viewEmailVerify.addSubview(labelVerificationCode[i])
        }
        
        buttonResend = UIButton(frame: CGRect(x: 107-x,y: 318-y,width: 200,height: 39))
        buttonResend.setTitle("Resend Code", for: UIControlState())
        buttonResend.layer.cornerRadius = 7
        buttonResend.backgroundColor = UIColor(colorLiteralRed: 249/255, green: 90/255, blue: 90/255, alpha: 1)
        buttonResend.addTarget(self, action: #selector(AccountEmailViewController.resendButtonDidPressed), for: .touchUpInside)
        disableButton(buttonResend)
        viewEmailVerify.addSubview(buttonResend)
        
        buttonProceed = UIButton (frame: CGRect(x: 0,y: 441,width: screenWidth,height: 56))
        buttonProceed.setTitle("Proceed", for: UIControlState())
        buttonProceed.backgroundColor = UIColor(colorLiteralRed: 249/255, green: 90/255, blue: 90/255, alpha: 1)
        buttonProceed.addTarget(self, action: #selector(AccountEmailViewController.proceedCode), for: .touchUpInside)
        disableButton(buttonProceed)
        viewBackgroundEmailVerify.addSubview(buttonProceed)
        
        viewEmailVerify.addSubview(TextFieldDummy)
        TextFieldDummy.keyboardType = UIKeyboardType.numberPad
        TextFieldDummy.addTarget(self, action: #selector(AccountEmailViewController.textFieldValueDidChanged(_:)), for: UIControlEvents.editingChanged)
        TextFieldDummy.becomeFirstResponder()
        
        
    }
    func proceedCode(){
        verifyCode(TextFieldDummy.text!, email: userEmail)
    }
    func textFieldValueDidChanged(_ textField: UITextField) {
        
        let buffer = textField.text!
        if(buffer.characters.count<index) {
            index -= 1;
            imageCodeDotArray[index].isHidden = false
            labelVerificationCode[index].isHidden = true
            disableButton(buttonProceed)
        } else if (buffer.characters.count > index) {
            if(buffer.characters.count >= 6 && !buttonProceed.isEnabled) {
                enableButton(buttonProceed)
            }
            if(buffer.characters.count > 6) {
                let endIndex = buffer.characters.index(buffer.startIndex, offsetBy: 6)
                textField.text = buffer.substring(to: endIndex)
            } else {
                labelVerificationCode[index].text = (String)(buffer[buffer.characters.index(before: buffer.endIndex)])
                imageCodeDotArray[index].isHidden = true
                labelVerificationCode[index].isHidden = false;
                index += 1
            }
        }
        print(index)
        if index == 6 {
            enableButton(buttonProceed)
        }
    }
    func sendCodeToEmailAgain(_ email : String){
        let user = FaeUser()
//        user.whereKey("email", value: email)
        user.sendCodeToEmail{ (status:Int?, message: Any?) in
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
    func verifyCode(_ input : String, email : String){
        let user = FaeUser()
        user.whereKey("email", value: email)
        user.whereKey("code", value: input)
        user.verifyEmail{ (status:Int?, message: Any?) in
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
            buttonResend.setTitle(title, for: UIControlState())
            disableButton(buttonResend)
        } else {
            let title = "Resend Code"
            buttonResend.setTitle(title, for: UIControlState())
            enableButton(buttonResend)
        }
    }
    func disableButton(_ button : UIButton) {
        button.backgroundColor = UIColor(red: 255.0 / 255.0, green: 160.0 / 255.0, blue: 160.0 / 255.0, alpha: 1.0)
        button.isEnabled = false
    }
    func enableButton(_ button : UIButton) {
        button.backgroundColor = UIColor(red: 249.0 / 255.0, green: 90.0 / 255.0, blue: 90.0 / 255.0, alpha: 1.0)
        button.isEnabled = true
    }
    func sendEmailCode(){
        let user = FaeUser()
        user.whereKey("email", value: userEmail)
        user.sendCodeToEmail{ (status:Int?, message: Any?) in
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
        viewBackgroundSendCodeInfo = UIView(frame: CGRect(x: 0,y: 0,width: screenWidth,height: screenHeight))
        viewBackgroundSendCodeInfo.backgroundColor = UIColor(colorLiteralRed: 107/255, green: 105/255, blue: 105/255, alpha: 0.5)
        
        buttonBackgroundSendCodeInfo = UIButton(frame: CGRect(x: 0,y: 0,width: screenWidth,height: screenHeight))
//        buttonBackgroundSendCodeInfo.addTarget(self, action: "removeSendCodeInfo", forControlEvents: .TouchUpInside)
        viewBackgroundSendCodeInfo.addSubview(buttonBackgroundSendCodeInfo)
        
        viewSendCodeInfo = UIView(frame: CGRect(x: x,y: y,width: 360,height: 208))
        viewSendCodeInfo.backgroundColor = UIColor.white
        viewSendCodeInfo.layer.cornerRadius = 21
        viewBackgroundSendCodeInfo.addSubview(viewSendCodeInfo)
        
        labelTitleSendCodeInfo = UILabel(frame: CGRect(x: 90-x,y: 197-y,width: 230,height: 90))
        labelTitleSendCodeInfo.textAlignment = .center
        labelTitleSendCodeInfo.text = "We sent a code to your email. Please verify your email with that code."
        labelTitleSendCodeInfo.numberOfLines = 0
        labelTitleSendCodeInfo.font = UIFont(name: "AvenirNext-Medium", size: 20)
        labelTitleSendCodeInfo.textColor = UIColor(colorLiteralRed: 107/255, green: 107/255, blue: 107/255, alpha: 1)
        viewSendCodeInfo.addSubview(labelTitleSendCodeInfo)
        
        buttonGot = UIButton(frame: CGRect(x: 142-x,y: 308-y,width: 130,height: 39))
        buttonGot.layer.cornerRadius = 7
        buttonGot.backgroundColor = UIColor(colorLiteralRed: 249/255, green: 90/255, blue: 90/255, alpha: 1)
        buttonGot.setTitle("Got it!", for: UIControlState())
        buttonGot.addTarget(self, action: #selector(AccountEmailViewController.showEmailVerify), for: .touchUpInside)
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
        viewBackgroundChangeEmail = UIView(frame: CGRect(x: 0,y: 0,width: screenWidth,height: screenHeight))
        viewBackgroundChangeEmail.backgroundColor = UIColor(colorLiteralRed: 107/255, green: 105/255, blue: 105/255, alpha: 0.5)
        
        buttonBackgroundChangeEmail = UIButton(frame: CGRect(x: 0,y: 0,width: screenWidth,height: screenHeight))
        buttonBackgroundChangeEmail.addTarget(self, action: #selector(AccountEmailViewController.removeChangeEmailView), for: .touchUpInside)
        viewBackgroundChangeEmail.addSubview(buttonBackgroundChangeEmail)
        
        viewChangeEmail = UIView(frame: CGRect(x: x,y: y,width: 350,height: 208))
        viewChangeEmail.backgroundColor = UIColor.white
        viewChangeEmail.layer.cornerRadius = 21
        viewBackgroundChangeEmail.addSubview(viewChangeEmail)
        
        buttonCloseChangeEmail = UIButton(frame: CGRect(x: 47-x,y: 175-y,width: 17,height: 17))
        buttonCloseChangeEmail.setImage(UIImage(named: "accountCloseFirstLast"), for: UIControlState())
        buttonCloseChangeEmail.addTarget(self, action: #selector(AccountEmailViewController.removeChangeEmailView), for: .touchUpInside)
        viewChangeEmail.addSubview(buttonCloseChangeEmail)
        
        labelTitleChangeEmail = UILabel(frame: CGRect(x: 0,y: 190-y,width: 350,height: 21))
        labelTitleChangeEmail.text = "Edit Email"
        labelTitleChangeEmail.textAlignment = .center
        labelTitleChangeEmail.font = UIFont(name: "AvenirNext-Medium", size: 20)
        labelTitleChangeEmail.textColor = UIColor(colorLiteralRed: 107/255, green: 107/255, blue: 107/255, alpha: 1)
        viewChangeEmail.addSubview(labelTitleChangeEmail)
        
        textFieldChangeEmail = UITextField(frame:CGRect(x: 74-x,y: 250-y,width: 266,height: 21))
        textFieldChangeEmail.textAlignment = .center
        textFieldChangeEmail.textColor = UIColor(colorLiteralRed: 138/255, green: 138/255, blue: 138/255, alpha: 1)
        viewChangeEmail.addSubview(textFieldChangeEmail)
        
        viewUnderlineChangeEmail = UIView(frame: CGRect(x: 74-x,y: 273-y,width: 266,height: 2))
        viewUnderlineChangeEmail.backgroundColor = UIColor(colorLiteralRed: 182/255, green: 182/255, blue: 182/255, alpha: 1)
        viewChangeEmail.addSubview(viewUnderlineChangeEmail)
        
        buttonSaveChangeEmail = UIButton(frame: CGRect(x: 142-x,y: 308-y,width: 130,height: 39))
        buttonSaveChangeEmail.setTitle("Save", for: UIControlState())
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
