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
    
    let backgroundLayer : CGFloat = 1
    let uiLayer : CGFloat = 2
    
    let ColorFae = UIColor(red: 248/255, green: 90/255, blue: 90/255, alpha: 1)
    
    var tap : UITapGestureRecognizer!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadImageView()
        loadSmallIcon()
        loadTextInput()
        loadCheckMark()
        loadBackground()
        loadCopRight()
        loadButton()
        loadHintLabel()
        loadTextField()
        loadInlineView()
        tap = UITapGestureRecognizer(target: self, action: #selector(RegisterViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadImageView() {
        imageSignIn = UIImageView(frame: CGRectMake(0.383333*screenWidth, 0.1114*screenHeigh, 0.246*screenWidth, 0.246*screenWidth))
        imageSignIn.image = UIImage(named: "signup_normal_cat")
        imageSignIn.layer.zPosition = uiLayer
        self.view.addSubview(imageSignIn)
    }
    
    func loadSmallIcon() {
        imageEmail = UIImageView(frame: CGRectMake(0.0667*screenWidth, 0.3433*screenHeigh, 0.056*screenWidth, 0.024*screenHeigh))
        imageEmail.image = UIImage(named: "email_gray")
        imageEmail.layer.zPosition = uiLayer
        self.view.addSubview(imageEmail)
        
        imagePassword = UIImageView(frame: CGRectMake(0.072*screenWidth, 0.4213*screenHeigh, 0.045*screenWidth, 0.042*screenHeigh))
        imagePassword.image = UIImage(named: "password_gray")
        imagePassword.layer.zPosition = uiLayer
        self.view.addSubview(imagePassword)
        
        imagePasswordAgain = UIImageView(frame: CGRectMake(0.053*screenWidth, 0.516*screenHeigh, 0.08*screenWidth, 0.05*screenHeigh))
        imagePasswordAgain.image = UIImage(named: "conf_password_gray")
        imagePasswordAgain.layer.zPosition = uiLayer
        self.view.addSubview(imagePasswordAgain)
        
    }
    
    func loadTextInput() {
        textEmail = UITextField(frame: CGRectMake(0.152*screenWidth, 0.333*screenHeigh, 0.73*screenWidth, 0.045*screenHeigh))
        let emailPlaceholder = NSAttributedString(string: "Email Address", attributes: [NSForegroundColorAttributeName : UIColor.grayColor()])
        textEmail.attributedPlaceholder = emailPlaceholder;
        textEmail.layer.zPosition = uiLayer
        textEmail.font = UIFont(name: "AvenirNext-Regular", size: 18.0)
        self.view.addSubview(textEmail)
        
        textPassword = UITextField(frame: CGRectMake(0.152*screenWidth, 0.429*screenHeigh, 0.73*screenWidth, 0.045*screenHeigh))
        let passwordPlaceholder = NSAttributedString(string: "New Password", attributes: [NSForegroundColorAttributeName : UIColor.grayColor()])
        textPassword.attributedPlaceholder = passwordPlaceholder;
        textPassword.layer.zPosition = uiLayer
        textPassword.secureTextEntry = true
        textPassword.font = UIFont(name: "AvenirNext-Regular", size: 18.0)
        self.view.addSubview(textPassword)
        
        textPasswordAgain = UITextField(frame: CGRectMake(0.152*screenWidth, 0.5247*screenHeigh, 0.73*screenWidth, 0.045*screenHeigh))
        let passwordAgainPlaceholder = NSAttributedString(string: "Confirm Password", attributes: [NSForegroundColorAttributeName : UIColor.grayColor()])
        textPasswordAgain.attributedPlaceholder = passwordAgainPlaceholder;
        textPasswordAgain.layer.zPosition = uiLayer
        textPasswordAgain.secureTextEntry = true
        textPasswordAgain.font = UIFont(name: "AvenirNext-Regular", size: 18.0)
        self.view.addSubview(textPasswordAgain)
        
    }
    
    func loadCheckMark() {
        imageCheckEmail = UIImageView(frame: CGRectMake(0.896*screenWidth, 0.3433*screenHeigh, 0.05*screenWidth, 0.05*screenWidth))
        imageCheckEmail.image = UIImage(named: "check_yes")
        imageCheckEmail.layer.zPosition = uiLayer
        self.view.addSubview(imageCheckEmail)
        
        imageCheckPassword = UIImageView(frame: CGRectMake(0.896*screenWidth, 0.436*screenHeigh, 0.05*screenWidth, 0.05*screenWidth))
        imageCheckPassword.image = UIImage(named: "check_yes")
        imageCheckPassword.layer.zPosition = uiLayer
        self.view.addSubview(imageCheckPassword)
        
        imageCheckPasswordAgain = UIImageView(frame: CGRectMake(0.896*screenWidth, 0.5322*screenHeigh, 0.05*screenWidth, 0.05*screenWidth))
        imageCheckPasswordAgain.image = UIImage(named: "check_yes")
        imageCheckPasswordAgain.layer.zPosition = uiLayer
        self.view.addSubview(imageCheckPasswordAgain)
    }
    
    func loadTextField() {
        textViewTerm = UITextView(frame: CGRectMake(0.053*screenWidth, 0.71*screenHeigh, 0.893*screenWidth, 0.105*screenHeigh))
        textViewTerm.text = "By signing up, you agree to Fae's Terms of Service\nand Privacy Policy"
        textViewTerm.layer.zPosition = uiLayer
        textViewTerm.font = UIFont(name: "AvenirNext-Medium", size: 13.0)
        textViewTerm.textColor = ColorFae
        textViewTerm.textAlignment = .Center
        self.view.addSubview(textViewTerm)
    }
    
    func loadCopRight() {
        labelCopyRight = UILabel(frame: CGRectMake(0, screenHeigh-0.075*screenHeigh, screenWidth, 0.075*screenHeigh))
        labelCopyRight.text = "© 2016 The Fae App ::: Aorinix Technologies, Inc.\nAll Rights Reserved."
        labelCopyRight.font = UIFont(name: "AvenirNext-Regular", size: 10.0)
        labelCopyRight.textColor = UIColor.whiteColor()
        labelCopyRight.numberOfLines = 2
        labelCopyRight.textAlignment = .Center
        labelCopyRight.layer.zPosition = uiLayer
        self.view.addSubview(labelCopyRight)
    }
    
    func loadBackground() {
        imageBackground = UIImageView(frame: CGRectMake(0, 0, screenWidth, screenHeigh))
        imageBackground.image = UIImage(named: "signup_back")
        imageBackground.layer.zPosition = backgroundLayer
        self.view.addSubview(imageBackground)
    }
    
    func loadButton() {
        buttonJoin = UIButton(frame: CGRectMake(0.053*screenWidth, 0.6221*screenHeigh, 0.893*screenWidth, 0.065*screenHeigh))
        buttonJoin.layer.zPosition = uiLayer
        buttonJoin.layer.cornerRadius = 7
        buttonJoin.setTitle("Join!", forState: .Normal)
        buttonJoin.backgroundColor = ColorFae
        buttonJoin.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 20.0)
        buttonJoin.addTarget(self, action: #selector(RegisterViewController.jumpToRegisterProfile), forControlEvents: .TouchUpInside)
        self.view.addSubview(buttonJoin)
    }
    
    func loadHintLabel() {
        labelEmailHint = UILabel(frame: CGRectMake(0.053*screenWidth, 0.38*screenHeigh, 0.893*screenWidth, 0.0225*screenHeigh))
        labelEmailHint.text = "Dummy text."
        labelEmailHint.textColor = UIColor.grayColor()
        labelEmailHint.textAlignment = .Right
        labelEmailHint.font = UIFont(name: "Helvetica Neue", size: 11)
        labelEmailHint.layer.zPosition = uiLayer
        self.view.addSubview(labelEmailHint)
        
        labelPasswordHint = UILabel(frame: CGRectMake(0.053*screenWidth, 0.4782*screenHeigh, 0.893*screenWidth, 0.0225*screenHeigh))
        labelPasswordHint.text = "Dummy text."
        labelPasswordHint.textColor = UIColor.grayColor()
        labelPasswordHint.textAlignment = .Right
        labelPasswordHint.font = UIFont(name: "Helvetica Neue", size: 11)
        labelPasswordHint.layer.zPosition = uiLayer
        self.view.addSubview(labelPasswordHint)
        
        
        labelPasswordAgainHint = UILabel(frame: CGRectMake(0.053*screenWidth, 0.5742*screenHeigh, 0.893*screenWidth, 0.0225*screenHeigh))
        labelPasswordAgainHint.text = "Dummy text."
        labelPasswordAgainHint.textColor = UIColor.grayColor()
        labelPasswordAgainHint.textAlignment = .Right
        labelPasswordAgainHint.font = UIFont(name: "Helvetica Neue", size: 11)
        labelPasswordAgainHint.layer.zPosition = uiLayer
        self.view.addSubview(labelPasswordAgainHint)
        
    }
    
    func loadInlineView() {
        inLineViewEmail = UIView(frame: CGRectMake(0.053*screenWidth, 0.38*screenHeigh, 0.893*screenWidth, 1))
        inLineViewEmail.layer.zPosition = uiLayer
        inLineViewEmail.layer.borderWidth = 1.0
        inLineViewEmail.layer.borderColor = UIColor.grayColor().CGColor
        self.view.addSubview(inLineViewEmail)
        
        inLineViewPassword = UIView(frame: CGRectMake(0.053*screenWidth, 0.475*screenHeigh, 0.893*screenWidth, 1))
        inLineViewPassword.layer.zPosition = uiLayer
        inLineViewPassword.layer.borderWidth = 1.0
        inLineViewPassword.layer.borderColor = UIColor.grayColor().CGColor
        self.view.addSubview(inLineViewPassword)
        
        inLineViewPasswordAgain = UIView(frame: CGRectMake(0.053*screenWidth, 0.571*screenHeigh, 0.893*screenWidth, 1))
        inLineViewPasswordAgain.layer.zPosition = uiLayer
        inLineViewPasswordAgain.layer.borderWidth = 1.0
        inLineViewPasswordAgain.layer.borderColor = UIColor.grayColor().CGColor
        self.view.addSubview(inLineViewPasswordAgain)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
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
