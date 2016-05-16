//
//  SignInViewController.swift
//  faeBeta
//  Wrote by: Yanxiang Wang
//  Created by blesssecret on 5/11/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

class LogInViewController: UIViewController, UITextFieldDelegate {
    let screenWidth = UIScreen.mainScreen().bounds.width
    let screenHeight = UIScreen.mainScreen().bounds.height
    //let imageCatWidth : CGFloat = 0.277778 * UIScreen.mainScreen().bounds.width
    let imageCatHeight : CGFloat = 115
    
    
    //var imageWelcome : UIImageView!
    var imageCat : UIImageView!
    var imageIconUsername : UIImageView!
    var imageIconUserPassword : UIImageView!
    var imageEmailCheckIcon : UIImageView!
    var imagePasswordCheckIcon : UIImageView!
    var textUserName : UITextField!
    var textUserPassword : UITextField!
    var labelCopyRight : UILabel!
    var labelUsernameUnserLine : UILabel!
    var labelUserPasswordLine : UILabel!
    var labelWelcome : UILabel!
    var labelUsernameUnderline : UILabel!
    var labelSignInSupport : UILabel!
    var labelPasswordUnderline : UILabel!
    var buttonSubmit : UIButton!
    
    let navigationBarHeight : CGFloat = 64.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(screenWidth)
        print(screenHeight)
        // Do any additional setup after loading the view.
        
        loadImageView()
        loadTextView()
        loadButton()
        loadLabel()
    }
    
    func loadImageView(){
        //let imageWelcomeWidth = screenWidth * 0.31980676
        //let imageWelcomeHeight = screenHeight * 0.18478261
        //let imageWelcomeYCor = screenHeight * 0.06793478
        //imageWelcome = UIImageView(frame: CGRectMake(screenWidth/2-imageWelcomeWidth/2, imageWelcomeYCor, imageWelcomeWidth, imageWelcomeHeight))
        //imageWelcome.image = UIImage(named: "signin_alert_type1")
        //self.view.addSubview(imageWelcome)
        
        let imageCatWidth = screenWidth * 0.277778
        let imageCatHeight = screenHeight * 0.15625
        let imageCatYcor = (screenHeight * 0.27173923) - navigationBarHeight
        imageCat = UIImageView(frame: CGRectMake(screenWidth/2-imageCatWidth/2, imageCatYcor, imageCatWidth, imageCatHeight))
        imageCat.image = UIImage(named: "normal_cat")
        self.view.addSubview(imageCat)
        
        let imageIconUsernameWidth = screenWidth * 0.05072464
        let imageIconUsernameHeight = screenHeight * 0.03668478
        let imageIconUsernameXCor = screenWidth/2 - screenWidth * 0.41545894
        let imageIconUsernameYCor = screenHeight * 0.49320652 - navigationBarHeight
        imageIconUsername = UIImageView(frame: CGRectMake(imageIconUsernameXCor, imageIconUsernameYCor, imageIconUsernameWidth, imageIconUsernameHeight))
        imageIconUsername.image = UIImage(named: "signin_email_gray")
        self.view.addSubview(imageIconUsername)
        
        let imageIconPasswordWidth = screenWidth * 0.03864734
        let imageIconPasswordHeight = screenHeight * 0.03668478
        let imageIconPasswordXCor = screenWidth/2 - screenWidth * 0.41062802
        let imageIconPasswordYCor = screenHeight * 0.58423913 - navigationBarHeight
        imageIconUserPassword = UIImageView(frame: CGRectMake(imageIconPasswordXCor, imageIconPasswordYCor, imageIconPasswordWidth, imageIconPasswordHeight))
        imageIconUserPassword.image = UIImage(named: "password_gray")
        self.view.addSubview(imageIconUserPassword)
        
        let imageEmailCheckIconWidth = screenWidth * 0.01449275
        let imageEmailCheckIconHeight = screenHeight * 0.02581522
        let imageEmailCheckIconXCor = screenWidth/2 + screenWidth * 0.36473430
        let imageEmailCheckIconYCor = screenHeight * 0.49592391 - navigationBarHeight
        imageEmailCheckIcon = UIImageView(frame: CGRectMake(imageEmailCheckIconXCor, imageEmailCheckIconYCor, imageEmailCheckIconWidth, imageEmailCheckIconHeight))
        //imageEmailCheckIcon.image = UIImage(named: "check_exclamation_red")
        self.view.addSubview(imageEmailCheckIcon)
        
        let imagePasswordCheckIconWidth = screenWidth * 0.04589372
        let imagePasswordCheckIconHeight = screenHeight * 0.02581522
        let imagePasswordCheckIconXCor = screenWidth/2 + screenWidth * 0.35024155
        let imagePasswordCheckIconYCor = screenHeight * 0.58695652 - navigationBarHeight
        imagePasswordCheckIcon = UIImageView(frame: CGRectMake(imagePasswordCheckIconXCor, imagePasswordCheckIconYCor, imagePasswordCheckIconWidth, imagePasswordCheckIconHeight))
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:Selector("imageTapped:"))
        imagePasswordCheckIcon.userInteractionEnabled = true
        imagePasswordCheckIcon.addGestureRecognizer(tapGestureRecognizer)
        //imagePasswordCheckIcon.image = UIImage(named: "check_eye_open_red")
        self.view.addSubview(imagePasswordCheckIcon)
    }
    
    func imageTapped(img: AnyObject)
    {
        if(textUserPassword.secureTextEntry==true){
            imagePasswordCheckIcon.image = UIImage(named: "check_eye_close_red")
            textUserPassword.secureTextEntry = false
        }
        else{
            imagePasswordCheckIcon.image = UIImage(named: "check_eye_open_red")
            textUserPassword.secureTextEntry = true
        }
    }
    
    func loadTextView(){
        let textUserNameWidth = screenWidth * 0.68599034
        let textUserNameHeight = screenHeight * 0.04076087
        let textUserNameXCor = screenWidth/2 - screenWidth * 0.34299517
        let textUserNameYCor = screenHeight * 0.49184783 - navigationBarHeight
        textUserName = UITextField(frame: CGRectMake(textUserNameXCor, textUserNameYCor, textUserNameWidth, textUserNameHeight))
        //textUserName = UITextField(frame: CGRectMake(screenWidth/2-142, 362, 284, 30))
        textUserName.placeholder = "Username/Email"
        textUserName.restorationIdentifier = "userName"
        self.view.addSubview(textUserName)
        textUserName.delegate = self
        
        let textUserPasswordWidth = screenWidth * 0.68599034
        let textUserPasswordHeight = screenHeight * 0.04076087
        let textUserPasswordXCor = screenWidth/2 - screenWidth * 0.34299517
        let textUserPasswordYCor = screenHeight * 0.58288043 - navigationBarHeight
        textUserPassword = UITextField(frame: CGRectMake(textUserPasswordXCor, textUserPasswordYCor, textUserPasswordWidth, textUserPasswordHeight))
        //textUserPassword = UITextField(frame: CGRectMake(screenWidth/2-142, 429, 284, 30))
        textUserPassword.placeholder = "Password"
        textUserPassword.restorationIdentifier = "userPassword"
        textUserPassword.secureTextEntry = true
        self.view.addSubview(textUserPassword)
        textUserPassword.delegate = self
    }
    
    func loadButton(){
        let buttonSubmitWidth = screenWidth * 0.83091787
        let buttonSubmitHeight = screenHeight * 0.05842391
        let buttonSubmitXCor = screenWidth/2 - screenWidth * 0.41545894
        let buttonSubmitYCor = screenHeight * 0.67663043 - navigationBarHeight
        buttonSubmit = UIButton(frame: CGRectMake(buttonSubmitXCor, buttonSubmitYCor, buttonSubmitWidth, buttonSubmitHeight))
        //buttonSubmit = UIButton(frame: CGRectMake(screenWidth/2-172, 498, 344, 43))
        buttonSubmit.setTitle("Go!", forState: .Normal)
        buttonSubmit.titleLabel?.textColor = UIColor.whiteColor()
        buttonSubmit.backgroundColor = UIColor(red: 255.0 / 255.0, green: 160.0 / 255.0, blue: 160.0 / 255.0, alpha: 1.0)
        buttonSubmit.layer.cornerRadius = 7
        self.view.addSubview(buttonSubmit)
    }
    
    func loadLabel(){
        let labelCopyRightHeight = screenHeight * 0.06793478
        labelCopyRight = UILabel(frame: CGRectMake(0, screenHeight-labelCopyRightHeight-navigationBarHeight, screenWidth, labelCopyRightHeight))
        labelCopyRight.textAlignment = NSTextAlignment.Center
        labelCopyRight.text = "© 2016 Fae ::: Faevorite, Inc.\nAll Rights Reserved."
        labelCopyRight.numberOfLines = 0
        labelCopyRight.textColor = UIColor(red: 255.0 / 255.0, green: 160.0 / 255.0, blue: 160.0 / 255.0, alpha: 1.0)
        labelCopyRight.font = UIFont(name: "Helvetica Neue", size: 11.0)
        self.view.addSubview(labelCopyRight)
        
        //let labelWelcomeWidth = screenWidth * 0.2512314
        let labelWelcomeHeight = screenHeight * 0.06793478
        let labelWelcomeYCor = screenHeight * 0.08403361 - navigationBarHeight
        labelWelcome = UILabel(frame: CGRectMake(0, labelWelcomeYCor, screenWidth, labelWelcomeHeight))
        //labelWelcome = UILabel(frame: CGRectMake(screenWidth/2-labelWelcomeWidth/2, screenHeight-labelCopyRightHeight, screenWidth, labelCopyRightHeight))
        labelWelcome.textAlignment = NSTextAlignment.Center
        labelWelcome.text = ""
        labelWelcome.textColor = UIColor(red: 249.0 / 255.0, green: 90.0 / 255.0, blue: 90.0 / 255.0, alpha: 1.0)
        labelWelcome.numberOfLines = 2
        self.view.addSubview(labelWelcome)
        
        let labelUsernameUnderlineWidth = screenWidth * 0.82125604
        let labelUsernameUnderlineXCor = screenWidth/2 - screenWidth * 0.41062802
        let labelUsernameUnderlineYCor = screenHeight * 0.5326087 - navigationBarHeight
        labelUsernameUnderline = UILabel(frame: CGRect(x: labelUsernameUnderlineXCor, y: labelUsernameUnderlineYCor, width: labelUsernameUnderlineWidth, height: 1))
        labelUsernameUnderline.backgroundColor = UIColor.grayColor()
        self.view.addSubview(labelUsernameUnderline)
        
        let labelPasswordUnderlineWidth = screenWidth * 0.82125604
        let labelPasswordUnderlineXCor = screenWidth/2 - screenWidth * 0.41062802
        let labelPasswordUnderlineYCor = screenHeight * 0.6235087 - navigationBarHeight
        labelPasswordUnderline = UILabel(frame: CGRect(x: labelPasswordUnderlineXCor, y: labelPasswordUnderlineYCor, width: labelPasswordUnderlineWidth, height: 1))
        labelPasswordUnderline.backgroundColor = UIColor.grayColor()
        self.view.addSubview(labelPasswordUnderline)
        
        let labelSignInSupportYCor = screenHeight * 0.7230 - navigationBarHeight
        labelSignInSupport = UILabel(frame: CGRect(x: 0, y: labelSignInSupportYCor, width: screenWidth, height: labelWelcomeHeight))
        labelSignInSupport.textAlignment = NSTextAlignment.Center
        labelSignInSupport.text = "Sign In Support"
        labelSignInSupport.textColor = UIColor(red: 249.0 / 255.0, green: 90.0 / 255.0, blue: 90.0 / 255.0, alpha: 1.0)
        labelSignInSupport.font = UIFont(name: "AvenirNext-Medium", size: 16.0)
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:Selector("supportTapped:"))
        labelSignInSupport.userInteractionEnabled = true
        labelSignInSupport.addGestureRecognizer(tapGestureRecognizer)
        self.view.addSubview(labelSignInSupport)
        
        
    }
    
    func supportTapped(lab: AnyObject){
        let vc = UIStoryboard(name: "Main", bundle: nil) .instantiateViewControllerWithIdentifier("SignInSupportViewController")as! SignInSupportViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    //func pickerView(
    //    func textFieldDidBeginEditing(textField: UITextField) {
    //        print(textField.text)
    //    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if(self.labelWelcome.text == ""){
            self.labelWelcome.text = "Welcome!"
            labelWelcome.font = UIFont(name: "AvenirNext-Medium", size: 25.0)
            
        }
        //        self.imageWelcome.image = UIImage(named: "signin_alert_type1")
        if(textField.restorationIdentifier=="userName"){
            imageIconUsername.image = UIImage(named: "signin_email_red")
            labelUsernameUnderline.backgroundColor = UIColor(red: 255.0 / 255.0, green: 90.0 / 255.0, blue: 90.0 / 255.0, alpha: 1.0)
        }
        else if(textField.restorationIdentifier=="userPassword"){
            imageIconUserPassword.image = UIImage(named: "password_red")
            labelPasswordUnderline.backgroundColor = UIColor(red: 255.0 / 255.0, green: 90.0 / 255.0, blue: 90.0 / 255.0, alpha: 1.0)
            if(textUserPassword.text==""){
                imagePasswordCheckIcon.image = UIImage(named: "check_eye_open_red")
            }
        }
        textField.textColor = UIColor(red: 255.0 / 255.0, green: 160.0 / 255.0, blue: 160.0 / 255.0, alpha: 1.0)
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if(textField.restorationIdentifier=="userName"){
            if(textField.text==""){
                //print("1")
                imageIconUsername.image = UIImage(named: "signin_email_gray")
                labelUsernameUnderline.backgroundColor = UIColor.grayColor()
                if(textUserPassword.text==""){
                    labelWelcome.text = "Welcome!"
                    labelWelcome.font = UIFont(name: "AvenirNext-Medium", size: 25.0)
                    imageCat.image = UIImage(named: "normal_cat")
                }
                else{
                    labelWelcome.text = "Almost there!"
                    imageCat.image = UIImage(named: "normal_cat")
                }
            }
            else{
                if(textUserPassword.text==""){
                    self.labelWelcome.text = "Almost there!"
                    imageCat.image = UIImage(named: "normal_cat")
                }
                else{
                    //print(textUserPassword.text)
                    self.labelWelcome.text = "Let's go!"
                    self.labelWelcome.font = UIFont(name: "AvenirNext-Medium", size: 25.0)
                    //self.view.addSubview(labelWelcome)
                    imageCat.image = UIImage(named: "smile_cat")
                    buttonSubmit.backgroundColor = UIColor(red: 255.0 / 255.0, green: 90.0 / 255.0, blue: 90.0 / 255.0, alpha: 1.0)
                }
            }
        }
        else if(textField.restorationIdentifier=="userPassword"){
            if(textField.text==""){
                imagePasswordCheckIcon.image = UIImage(named:  "")
                textUserPassword.secureTextEntry = true
                imageIconUserPassword.image = UIImage(named: "password_gray")
                labelUsernameUnderline.backgroundColor = UIColor.grayColor()
                if(textUserPassword.text==""){
                    labelWelcome.text = "Welcome!"
                    labelWelcome.font = UIFont(name: "AvenirNext-Medium", size: 25.0)
                    imageCat.image = UIImage(named: "normal_cat")
                }
                else{
                    labelWelcome.text = "Almost there!"
                    imageCat.image = UIImage(named: "normal_cat")
                }
            }
            else{
                if(textUserName.text==""){
                    labelWelcome.text = "Almost there!"
                    imageCat.image = UIImage(named: "normal_cat")
                }
                else{
                    self.labelWelcome.text = "Let's go!"
                    self.labelWelcome.font = UIFont(name: "AvenirNext-Medium", size: 25.0)
                    imageCat.image = UIImage(named: "smile_cat")
                    buttonSubmit.backgroundColor = UIColor(red: 255.0 / 255.0, green: 90.0 / 255.0, blue: 90.0 / 255.0, alpha: 1.0)
                }
                
            }
        }
    }
    
    func validation(){
        if(textUserPassword.text=="" && textUserName.text==""){
            buttonSubmit.backgroundColor = UIColor(red: 255.0 / 255.0, green: 160.0 / 255.0, blue: 160.0 / 255.0, alpha: 1.0)
            
            //image
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
