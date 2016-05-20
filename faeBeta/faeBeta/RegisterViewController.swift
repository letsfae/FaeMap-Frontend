//
//  RegisterViewController.swift
//  faeBeta
//  write by Mingjie Jin
//  Created by blesssecret on 5/11/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController {
    
    let screenWidth = UIScreen.mainScreen().bounds.width
    let screenHeigh = UIScreen.mainScreen().bounds.height
    //6 plus 414 736
    //6      375 667
    //5      320 568
    
    let navigationBarOffset : CGFloat = 0
    
    var imageSignIn : UIImageView!
    
    var imageEmail : UIImageView!
    var imagePassword : UIImageView!
    var imagePasswordAgain : UIImageView!
    
    var textEmail : UITextField!
    var textPassword : UITextField!
    var textPasswordAgain : UITextField!
    
    var imageCheckEmail : UIImageView!
    var imageCheckPassword : UIImageView!
    var imageCheckPasswordAgain : UIImageView!
    
    var imageBackground : UIImageView!
    
    var labelCopyRight : UILabel!
    
    var labelEmailHint : UILabel!
    var labelPasswordHint : UILabel!
    var labelPasswordAgainHint : UILabel!
    
    var buttonJoin : UIButton!
    
    var textViewTerm : UITextView!
    
    var inLineViewEmail : UIView!
    var inLineViewPassword : UIView!
    var inLineViewPasswordAgain : UIView!
    
    var viewEmail : UIView!
    var viewPassword : UIView!
    var viewPasswordAgain : UIView!
    
    let backgroundLayer : CGFloat = 1
    let uiLayer : CGFloat = 2
    
    let ColorFae = UIColor(red: 248/255, green: 90/255, blue: 90/255, alpha: 1)
    let ColorFaeOrange = UIColor(red: 252.0 / 255.0, green: 155.0 / 255.0, blue: 43.0 / 255.0, alpha: 1.0)
    let ColorFaeYellow = UIColor(red: 247.0 / 255.0, green: 200.0 / 255.0, blue: 90.0 / 255.0, alpha: 1.0)
    let colorDisableButton = UIColor(red: 255.0 / 255.0, green: 160.0 / 255.0, blue: 160.0 / 255.0, alpha: 1.0)
    
    var tap : UITapGestureRecognizer!
    
    var space = 0.053 * UIScreen.mainScreen().bounds.width
    
    let interval = 0.1 * UIScreen.mainScreen().bounds.height
    
    let isIPhone5 = UIScreen.mainScreen().bounds.size.height == 568
    
    var imageAlertView : UIImageView!
    
    var emailValidated = false
    var passwordValidated = false
    var passwordAgainValidated = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadImageView()
        loadSmallIcon()
        loadTextInput()
        loadBackground()
        loadCopRight()
        loadButton()
        loadTextField()
        loadInlineView()
        tap = UITapGestureRecognizer(target: self, action: #selector(RegisterViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        loadCheckMark()
        loadHintLabel()
        loadCallback()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadImageView() {
        let width = 0.246*screenWidth
        imageSignIn = UIImageView(frame: CGRectMake(0.383*screenWidth, 0.1114*screenHeigh - navigationBarOffset, width, width))
        imageSignIn.image = UIImage(named: "signup_normal_cat")
        imageSignIn.layer.zPosition = uiLayer
        self.view.addSubview(imageSignIn)
    }
    
    func createInputTemplate() {
        //viewEmail = UIView(frame: CGRectMake(0, 0.1114*screenHeigh, screenWidth, 0.246*screenWidth))
    }
    
    func loadSmallIcon() {
        let yOffset = 0.3433*screenHeigh - navigationBarOffset;
        let iconInterval = 0.9 * interval
        imageEmail = UIImageView(frame: CGRectMake(space + 5, yOffset, 0.056*screenWidth, 0.024*screenHeigh))
        imageEmail.image = UIImage(named: "email_gray")
        imageEmail.layer.zPosition = uiLayer
        self.view.addSubview(imageEmail)
        
        imagePassword = UIImageView(frame: CGRectMake(space + 7 , yOffset + iconInterval, 0.045*screenWidth, 0.042*screenHeigh))
        imagePassword.image = UIImage(named: "password_gray")
        imagePassword.layer.zPosition = uiLayer
        self.view.addSubview(imagePassword)
        
        imagePasswordAgain = UIImageView(frame: CGRectMake(space, yOffset + 2 * iconInterval, 0.08*screenWidth, 0.05*screenHeigh))
        imagePasswordAgain.image = UIImage(named: "conf_password_gray")
        imagePasswordAgain.layer.zPosition = uiLayer
        self.view.addSubview(imagePasswordAgain)
        
    }
    
    func loadTextInput() {
        let height = 0.045*screenHeigh
        let width = 0.795 * screenWidth
        let xOffset = 0.152*screenWidth
        let yOffset = 0.333 * screenHeigh - navigationBarOffset
        
        textEmail = EmailTextField(frame: CGRectMake(xOffset, yOffset, width, height))
        let emailPlaceholder = NSAttributedString(string: "Email Address", attributes: [NSForegroundColorAttributeName : UIColor.grayColor()])
        textEmail.attributedPlaceholder = emailPlaceholder;
        textEmail.layer.zPosition = uiLayer
        textEmail.textColor = ColorFae
        textEmail.font = UIFont(name: "AvenirNext-Regular", size: 18.0)
        self.view.addSubview(textEmail)
        
        textPassword = PasswordTexField(frame: CGRectMake(xOffset, yOffset + interval, width, height))
        let passwordPlaceholder = NSAttributedString(string: "New Password", attributes: [NSForegroundColorAttributeName : UIColor.grayColor()])
        textPassword.attributedPlaceholder = passwordPlaceholder;
        textPassword.layer.zPosition = uiLayer
        textPassword.textColor = ColorFae
        textPassword.font = UIFont(name: "AvenirNext-Regular", size: 18.0)
        self.view.addSubview(textPassword)
        
        textPasswordAgain = PasswordAgainTextField(frame: CGRectMake(xOffset, yOffset + 2 * interval, width, height))
        let passwordAgainPlaceholder = NSAttributedString(string: "Confirm Password", attributes: [NSForegroundColorAttributeName : UIColor.grayColor()])
        textPasswordAgain.attributedPlaceholder = passwordAgainPlaceholder;
        textPasswordAgain.layer.zPosition = uiLayer
        textPasswordAgain.secureTextEntry = true
        textPasswordAgain.textColor = ColorFae
        textPasswordAgain.font = UIFont(name: "AvenirNext-Regular", size: 18.0)
        self.view.addSubview(textPasswordAgain)
        
    }
    
    func loadCheckMark() {
        let length = 0.05*screenWidth
        let xOffset = 0.9*screenWidth
        let yOffset = 0.343 * screenHeigh - navigationBarOffset
        
        imageCheckEmail = UIImageView(frame: CGRectMake(xOffset, yOffset, length, length))
        imageCheckEmail.image = UIImage(named: "check_yes")
        imageCheckEmail.layer.zPosition = uiLayer
        imageCheckEmail.layer.hidden = true
        self.view.addSubview(imageCheckEmail)
        
        imageAlertView = UIImageView(frame: CGRectMake(xOffset + 3, yOffset + interval - 3, 7, 20))
        imageAlertView.image = UIImage(named: "check_exclamation_red")
        imageAlertView.layer.zPosition = uiLayer
        imageAlertView.hidden = true
        self.view.addSubview(imageAlertView)
        
        imageCheckPassword = UIImageView(frame: CGRectMake(xOffset, yOffset + interval, length, length))
        imageCheckPassword.image = UIImage(named: "check_yes")
        imageCheckPassword.layer.zPosition = uiLayer
        imageCheckPassword.layer.hidden = true
        self.view.addSubview(imageCheckPassword)
        
        imageCheckPasswordAgain = UIImageView(frame: CGRectMake(xOffset, yOffset + interval * 2, length, length))
        imageCheckPasswordAgain.image = UIImage(named: "check_yes")
        imageCheckPasswordAgain.layer.zPosition = uiLayer
        imageCheckPasswordAgain.layer.hidden = true
        self.view.addSubview(imageCheckPasswordAgain)
    }
    
    func loadTextField() {
        textViewTerm = UITextView(frame: CGRectMake(space, 0.71*screenHeigh - navigationBarOffset, screenWidth - 2 * space, 0.1*screenHeigh))
        textViewTerm.text = "By signing up, you agree to Fae's Terms of Service\nand Privacy Policy"
        textViewTerm.layer.zPosition = uiLayer
        if isIPhone5 {
            textViewTerm.font = UIFont(name: "AvenirNext-Medium", size: 12.0)
        } else {
            textViewTerm.font = UIFont(name: "AvenirNext-Medium", size: 13.0)
        }
        textViewTerm.textColor = ColorFae
        textViewTerm.textAlignment = .Center
        self.view.addSubview(textViewTerm)
    }
    
    func loadCopRight() {
        let height = 0.075 * screenHeigh
        labelCopyRight = UILabel(frame: CGRectMake(0, screenHeigh - height - navigationBarOffset, screenWidth, height))
        labelCopyRight.text = "© 2016 Fae ::: Faevorite, Inc.\nAll Rights Reserved."
        labelCopyRight.font = UIFont(name: "AvenirNext-Regular", size: 10.0)
        labelCopyRight.textColor = UIColor.whiteColor()
        labelCopyRight.numberOfLines = 0
        labelCopyRight.textAlignment = .Center
        labelCopyRight.layer.zPosition = uiLayer
        self.view.addSubview(labelCopyRight)
    }
    
    func loadBackground() {
        imageBackground = UIImageView(frame: CGRectMake(0, -navigationBarOffset, screenWidth, screenHeigh))
        imageBackground.image = UIImage(named: "signup_back")
        imageBackground.layer.zPosition = backgroundLayer
        self.view.addSubview(imageBackground)
    }
    
    func loadButton() {
        //let height = 0.065 * screenHeigh
        buttonJoin = UIButton(frame: CGRectMake(space, 0.62*screenHeigh - navigationBarOffset, screenWidth - 2 * space, 50))
        buttonJoin.layer.zPosition = uiLayer
        buttonJoin.layer.cornerRadius = 7
        buttonJoin.setTitle("Join!", forState: .Normal)
        buttonJoin.backgroundColor = ColorFae
        buttonJoin.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 20.0)
        buttonJoin.addTarget(self, action: #selector(RegisterViewController.jumpToRegisterProfile), forControlEvents: .TouchUpInside)
        self.view.addSubview(buttonJoin)
        disableButton(buttonJoin)
    }
    
    func loadHintLabel() {
        let height = 0.0225*screenHeigh
        let yOffset = 0.38 * screenHeigh - navigationBarOffset
        labelEmailHint = UILabel(frame: CGRectMake(space, yOffset, screenWidth - 2 * space, height))
        labelEmailHint.textAlignment = .Right
        labelEmailHint.font = UIFont(name: "Helvetica Neue", size: 11)
        labelEmailHint.layer.zPosition = uiLayer
        labelEmailHint.textColor = ColorFae
        labelEmailHint.layer.hidden = true
        self.view.addSubview(labelEmailHint)
        
        labelPasswordHint = UILabel(frame: CGRectMake(space, yOffset + interval, screenWidth - 2 * space, height))
        labelPasswordHint.textAlignment = .Right
        labelPasswordHint.font = UIFont(name: "Helvetica Neue", size: 11)
        labelPasswordHint.layer.zPosition = uiLayer
        labelPasswordHint.layer.hidden = true
        self.view.addSubview(labelPasswordHint)
    }
    
    func loadInlineView() {
        let yOffset = 0.38 * screenHeigh - navigationBarOffset
        inLineViewEmail = UIView(frame: CGRectMake(space, yOffset, screenWidth - 2 * space, 1))
        inLineViewEmail.layer.zPosition = uiLayer
        inLineViewEmail.layer.borderWidth = 1.0
        inLineViewEmail.layer.borderColor = UIColor.grayColor().CGColor
        self.view.addSubview(inLineViewEmail)
        
        inLineViewPassword = UIView(frame: CGRectMake(space, yOffset + interval, screenWidth - 2 * space, 1))
        inLineViewPassword.layer.zPosition = uiLayer
        inLineViewPassword.layer.borderWidth = 1.0
        inLineViewPassword.layer.borderColor = UIColor.grayColor().CGColor
        self.view.addSubview(inLineViewPassword)
        
        inLineViewPasswordAgain = UIView(frame: CGRectMake(space, yOffset + 2 * interval, screenWidth - 2 * space, 1))
        inLineViewPasswordAgain.layer.zPosition = uiLayer
        inLineViewPasswordAgain.layer.borderWidth = 1.0
        inLineViewPasswordAgain.layer.borderColor = UIColor.grayColor().CGColor
        self.view.addSubview(inLineViewPasswordAgain)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func loadCallback() {
        textEmail.addTarget(self, action: #selector(RegisterViewController.emailIsFocused), forControlEvents: .EditingDidBegin)
        textEmail.addTarget(self, action: #selector(RegisterViewController.emailIsNotFocused), forControlEvents: .EditingDidEnd)
        textEmail.addTarget(self, action: #selector(RegisterViewController.emailIsChanged), forControlEvents: .EditingChanged)
        
        textPassword.addTarget(self, action: #selector(RegisterViewController.passwordIsFocus), forControlEvents: .EditingDidBegin)
        textPassword.addTarget(self, action: #selector(RegisterViewController.passwordIsNotFocus), forControlEvents: .EditingDidEnd)
        textPassword.addTarget(self, action: #selector(RegisterViewController.passwordIsChanged), forControlEvents: .EditingChanged)
        
        textPasswordAgain.addTarget(self, action: #selector(RegisterViewController.passwordAgainIsFocus), forControlEvents: .EditingDidBegin)
        textPasswordAgain.addTarget(self, action: #selector(RegisterViewController.passwordAgainIsNotFocus), forControlEvents: .EditingDidEnd)
        textPasswordAgain.addTarget(self, action: #selector(RegisterViewController.passwordAgainIsChanged), forControlEvents: .EditingChanged)
        
    }
    
    func emailIsFocused() {
        print("email is focused")
        imageEmail.image = UIImage(named: "emaiRed")
        inLineViewEmail.layer.borderColor = ColorFae.CGColor
        if (!isValidEmail(textEmail.text!)) {
            textEmail.rightViewMode = .WhileEditing
        }
    }
    
    func emailIsChanged() {
        print("email is changed")
        if(isValidEmail(textEmail.text!)) {
            //TODO: add duplicate email validation
            textEmail.rightViewMode = .Never
            labelEmailHint.hidden = true
            imageCheckEmail.hidden = false
            emailValidated = true
            print("right")
        } else {
            labelEmailHint.text = "Please enter a valid email"
            labelEmailHint.hidden = false
            imageCheckEmail.hidden = true
            textEmail.rightViewMode = .WhileEditing
            emailValidated = false
        }
        
        checkAllValidation()
    }
    
    func emailIsNotFocused() {
        print("email is not focused")
        if(textEmail.text == "" ) {
            imageEmail.image = UIImage(named: "email_gray")
            inLineViewEmail.layer.borderColor = UIColor.grayColor().CGColor
            
        }
        checkAllValidation()
    }
    
    func passwordIsFocus() {
        print("password is focused")
        imagePassword.image = UIImage(named: "password_red")
        inLineViewPassword.layer.borderColor = ColorFae.CGColor
        textPassword.rightViewMode = .WhileEditing
        passwordIsChanged()
        imageCheckPassword.hidden = true
        imageAlertView.hidden = true
        checkAllValidation()
    }
    
    func passwordIsChanged() {
        if textPassword.text!.characters.count < 8 {
            imagePassword.image = UIImage(named: "password_yellow")
            inLineViewPassword.layer.borderColor = ColorFaeYellow.CGColor
            labelPasswordHint.textColor = ColorFaeYellow
            textPassword.textColor = ColorFaeYellow
            labelPasswordHint.text = "Must be at least 8 characters"
            
            labelPasswordHint.hidden = false
        } else if (isValidPassword(textPassword.text!)){
            imagePassword.image = UIImage(named: "password_red")
            inLineViewPassword.layer.borderColor = ColorFae.CGColor
            textPassword.textColor = ColorFae
            labelPasswordHint.hidden = true
            passwordValidated = true
        } else {
            imagePassword.image = UIImage(named: "password_orange")
            inLineViewPassword.layer.borderColor = ColorFaeOrange.CGColor
            labelPasswordHint.textColor = ColorFaeOrange
            textPassword.textColor = ColorFaeOrange
            labelPasswordHint.text = "Try adding Capital Letters/Numbers/Symbols"
            labelPasswordHint.hidden = false
        }
        if(textPassword.text != "" && textPasswordAgain.text != "") {
            if(isValidPasswordAgain()) {
                imageCheckPasswordAgain.image = UIImage(named: "check_yes")
                imageCheckPasswordAgain.hidden = false
            } else {
                imageCheckPasswordAgain.image = UIImage(named: "check_cross_red")
                imageCheckPasswordAgain.hidden = false
            }
            
        }
        checkAllValidation()
    }
    
    func passwordIsNotFocus() {
        print("password is not focused")
        if(textPassword.text == "" ) {
            imagePassword.image = UIImage(named: "password_gray")
            inLineViewPassword.layer.borderColor = UIColor.grayColor().CGColor
            labelPasswordHint.hidden = true
        } else if(textPassword.text?.characters.count < 8) {
            imageCheckPassword.image = UIImage(named: "check_cross_red")
            imageCheckPassword.hidden = false
        } else if (!isValidPassword(textPassword.text!)){
            imageAlertView.hidden = false
        } else {
            imageCheckPassword.image = UIImage(named: "check_yes")
            imageCheckPassword.hidden = false
        }
        checkAllValidation()
    }
    
    func passwordAgainIsFocus() {
        imagePasswordAgain.image = UIImage(named: "conf_password_red")
        inLineViewPasswordAgain.layer.borderColor = ColorFae.CGColor
        if(!isValidPasswordAgain()) {
            imageCheckPasswordAgain.hidden = true
            passwordAgainValidated = false
            textPasswordAgain.rightViewMode = .WhileEditing
        }
        
        checkAllValidation()
    }
    
    func passwordAgainIsChanged() {
        if(isValidPasswordAgain()) {
            imageCheckPasswordAgain.image = UIImage(named: "check_yes")
            imageCheckPasswordAgain.hidden = false
            passwordAgainValidated = true
            textPasswordAgain.rightViewMode = .Never
        } else {
            textPasswordAgain.rightViewMode = .WhileEditing
            imageCheckPasswordAgain.hidden = true
            passwordAgainValidated = false
        }
        checkAllValidation()
    }
    
    func passwordAgainIsNotFocus() {
        textPasswordAgain.rightViewMode = .Never
        if(textPasswordAgain.text == "") {
            imagePasswordAgain.image = UIImage(named: "conf_password_gray")
            inLineViewPasswordAgain.layer.borderColor = UIColor.grayColor().CGColor
        } else if(!isValidPasswordAgain()) {
            imageCheckPasswordAgain.image = UIImage(named: "check_cross_red")
            imageCheckPasswordAgain.hidden = false
            passwordAgainValidated = false
        }
        checkAllValidation()
    }
    
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(testStr)
    }
    
    func isValidPassword(testStr:String) -> Bool {
        var uppercase = 0
        var symbol = 0
        var digit = 0
        for i in testStr.characters {
            if(i <= "9" && i >= "0") {
                digit = 1
            } else if (i <= "z" && i >= "a") {
                
            } else if (i <= "Z" && i >= "A") {
                uppercase = 1
            } else {
                symbol = 1
            }
            if(uppercase + digit + symbol >= 2)  {
                return true
            }
        }
        return false
    }
    
    func isValidPasswordAgain() -> Bool {
        if(textPasswordAgain.text != "" && textPassword != "") {
            return textPasswordAgain.text == textPassword.text
        } else {
            return false
        }
    }
    
    func checkAllValidation() {
        if(emailValidated && passwordValidated && passwordAgainValidated) {
            enableButton(buttonJoin)
        } else {
            disableButton(buttonJoin)
        }
    }
    
    func disableButton(button : UIButton) {
        button.backgroundColor = colorDisableButton
        button.enabled = false
        imageSignIn.image = UIImage(named: "signup_normal_cat")
    }
    
    func enableButton(button : UIButton) {
        button.backgroundColor = ColorFae
        button.enabled = true
        imageSignIn.image = UIImage(named: "smile_cat")
    }
    
    func jumpToRegisterProfile(){
        let vc = UIStoryboard(name: "Main", bundle: nil) .instantiateViewControllerWithIdentifier("RegisterProfileViewController")as! RegisterProfileViewController
        self.navigationController?.pushViewController(vc, animated: true)
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
