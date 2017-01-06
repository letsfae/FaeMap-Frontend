//
//  SignInViewController.swift
//  faeBeta
//  Wrote by: Yanxiang Wang
//  Created by blesssecret on 5/11/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

class CreateNewPasswordViewController: UIViewController, UITextFieldDelegate {
    let screenWidth = UIScreen.mainScreen().bounds.width
    let screenHeight = UIScreen.mainScreen().bounds.height
    //let imageCatWidth : CGFloat = 0.277778 * UIScreen.mainScreen().bounds.width
    let imageCatHeight : CGFloat = 115
    
    
    //var imageWelcome : UIImageView!
    var imageCat : UIImageView!
    var imageIconUserPassword : UIImageView!
    var imageIconUserValidation : UIImageView!
    var imagePasswordCheckIcon : UIImageView!
    var imageValidationCheckIcon : UIImageView!
    var imageBack : UIImageView!
    var textUserPassword : UITextField!
    var textUserValidation : UITextField!
    var labelCopyRight : UILabel!
    //    var labelUsernameUnserLine : UILabel!
    //    var labelUserPasswordLine : UILabel!
    var labelWelcome : UILabel!
    var labelPasswordUnderline : UILabel!
    var labelValidationUnderline : UILabel!
    var buttonSubmit : UIButton!
    
    let navigationBarHeight : CGFloat = 0
    var emailNeedToBeVerified : String = ""
    var codeForVerification : String  = ""
    
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
        
        let imageCatWidth = screenWidth * 0.2444
        let imageCatHeight = screenHeight * 0.1376
        let imageCatYcor = screenHeight * 0.1861 - navigationBarHeight
        imageCat = UIImageView(frame: CGRectMake(screenWidth/2-imageCatWidth/2, imageCatYcor, imageCatWidth, imageCatHeight))
        imageCat.image = UIImage(named: "normal_cat")
        self.view.addSubview(imageCat)
        
        let imageIconUserPasswordWidth = screenWidth * 0.03864734
        let imageIconUserPasswordHeight = screenHeight * 0.03668478
        let imageIconUserPasswordXCor = screenWidth/2 - screenWidth * 0.41062802
        let imageIconUserPasswordYCor = screenHeight * 0.3668 - navigationBarHeight
        imageIconUserPassword = UIImageView(frame: CGRectMake(imageIconUserPasswordXCor, imageIconUserPasswordYCor, imageIconUserPasswordWidth, imageIconUserPasswordHeight))
        imageIconUserPassword.image = UIImage(named: "password_gray")
        self.view.addSubview(imageIconUserPassword)
        
        let imageIconPasswordWidth = screenWidth * 0.03864734
        let imageIconPasswordHeight = screenHeight * 0.03668478
        let imageIconPasswordXCor = screenWidth/2 - screenWidth * 0.41062802
        let imageIconPasswordYCor = screenHeight * 0.4626 - navigationBarHeight
        imageIconUserValidation = UIImageView(frame: CGRectMake(imageIconPasswordXCor, imageIconPasswordYCor, imageIconPasswordWidth, imageIconPasswordHeight))
        imageIconUserValidation.image = UIImage(named: "conf_password_gray")
        self.view.addSubview(imageIconUserValidation)
        
        let imagePasswordCheckIconWidth = screenWidth * 0.04589372
        let imagePasswordCheckIconHeight = screenHeight * 0.02581522
        let imagePasswordCheckIconXCor = screenWidth/2 + screenWidth * 0.35024155
        let imagePasswordCheckIconYCor = screenHeight * 0.3668 - navigationBarHeight
        imagePasswordCheckIcon = UIImageView(frame: CGRectMake(imagePasswordCheckIconXCor, imagePasswordCheckIconYCor, imagePasswordCheckIconWidth, imagePasswordCheckIconHeight))
        imagePasswordCheckIcon = UIImageView(frame: CGRectMake(imagePasswordCheckIconXCor, imagePasswordCheckIconYCor, imagePasswordCheckIconWidth, imagePasswordCheckIconHeight))
        let tapGestureRecognizer2 = UITapGestureRecognizer(target:self, action:Selector("imageTapped2:"))
        imagePasswordCheckIcon.userInteractionEnabled = true
        imagePasswordCheckIcon.addGestureRecognizer(tapGestureRecognizer2)
        //imagePasswordCheckIcon.image = UIImage(named: "check_eye_open_red")
        self.view.addSubview(imagePasswordCheckIcon)
        
        let imageValidationCheckIconWidth = screenWidth * 0.04589372
        let imageValidationCheckIconHeight = screenHeight * 0.02581522
        let imageValidationCheckIconXCor = screenWidth/2 + screenWidth * 0.35024155
        let imageValidationCheckIconYCor = screenHeight * 0.4626 - navigationBarHeight
        imageValidationCheckIcon = UIImageView(frame: CGRectMake(imageValidationCheckIconXCor, imageValidationCheckIconYCor, imageValidationCheckIconWidth, imageValidationCheckIconHeight))
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:Selector("imageTapped:"))
        imageValidationCheckIcon.userInteractionEnabled = true
        imageValidationCheckIcon.addGestureRecognizer(tapGestureRecognizer)
        //imageValidationCheckIcon.image = UIImage(named: "check_eye_open_red")
        self.view.addSubview(imageValidationCheckIcon)
        
        let imageBackHeight = screenHeight
        imageBack = UIImageView(frame: CGRect(x: 0, y: screenHeight - imageBackHeight - navigationBarHeight, width: screenWidth, height: imageBackHeight))
        imageBack.image = UIImage(named: "signup_back")
        
        self.view.addSubview(imageBack)
        self.view.sendSubviewToBack(imageBack)
        
    }
    
    func imageTapped(img: AnyObject)
    {
        if(textUserValidation.secureTextEntry==true){
            imageValidationCheckIcon.image = UIImage(named: "check_eye_close_red")
            textUserValidation.secureTextEntry = false
        }
        else{
            if(textUserPassword.text==textUserValidation.text){
                imageValidationCheckIcon.image = UIImage(named: "check_eye_open_red")
            }
            else{
                imageValidationCheckIcon.image = UIImage(named:  "check_exclamation_red-1")
            }
            textUserValidation.secureTextEntry = true
        }
    }
    
    func imageTapped2(img: AnyObject){
        if(textUserPassword.secureTextEntry==true){
            imagePasswordCheckIcon.image = UIImage(named: "check_eye_close_red")
            textUserPassword.secureTextEntry = false
        }
        else{
            if(isValidPassword(textUserPassword.text!)){
                imagePasswordCheckIcon.image = UIImage(named: "check_eye_open_red")
            }
            else{
                imagePasswordCheckIcon.image = UIImage(named:  "check_exclamation_red-1")
            }
            textUserPassword.secureTextEntry = true
        }
    }
    
    func loadTextView(){
        let textUserPasswordWidth = screenWidth * 0.68599034
        let textUserPasswordHeight = screenHeight * 0.04076087
        let textUserPasswordXCor = screenWidth/2 - screenWidth * 0.34299517
        let textUserPasswordYCor = screenHeight * 0.3709 - navigationBarHeight
        textUserPassword = UITextField(frame: CGRectMake(textUserPasswordXCor, textUserPasswordYCor, textUserPasswordWidth, textUserPasswordHeight))
        //textUserPassword = UITextField(frame: CGRectMake(screenWidth/2-142, 362, 284, 30))
        textUserPassword.placeholder = "newPassword"
        textUserPassword.restorationIdentifier = "userName"
        textUserPassword.font = UIFont(name: "AvenirNext-Medium", size: 18.0)
        textUserPassword.secureTextEntry = true
        self.view.addSubview(textUserPassword)
        textUserPassword.delegate = self
        
        let textUserValidationWidth = screenWidth * 0.68599034
        let textUserValidationHeight = screenHeight * 0.04076087
        let textUserValidationXCor = screenWidth/2 - screenWidth * 0.34299517
        let textUserValidationYCor = screenHeight * 0.4565 - navigationBarHeight
        textUserValidation = UITextField(frame: CGRectMake(textUserValidationXCor, textUserValidationYCor, textUserValidationWidth, textUserValidationHeight))
        //textUserValidation = UITextField(frame: CGRectMake(screenWidth/2-142, 429, 284, 30))
        textUserValidation.placeholder = "Password"
        textUserValidation.restorationIdentifier = "userPassword"
        textUserValidation.font = UIFont(name: "AvenirNext-Medium", size: 18.0)
        textUserValidation.secureTextEntry = true
        self.view.addSubview(textUserValidation)
        textUserValidation.delegate = self
    }
    
    func loadButton(){
        let buttonSubmitWidth = screenWidth * 0.83091787
        let buttonSubmitHeight = screenHeight * 0.05842391
        let buttonSubmitXCor = screenWidth/2 - screenWidth * 0.41545894
        let buttonSubmitYCor = screenHeight * 0.5516 - navigationBarHeight
        buttonSubmit = UIButton(frame: CGRectMake(buttonSubmitXCor, buttonSubmitYCor, buttonSubmitWidth, buttonSubmitHeight))
        //buttonSubmit = UIButton(frame: CGRectMake(screenWidth/2-172, 498, 344, 43))
        buttonSubmit.setTitle("Finish!", forState: .Normal)
        buttonSubmit.titleLabel?.textColor = UIColor.whiteColor()
        buttonSubmit.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size: 25.0)
        buttonSubmit.backgroundColor = UIColor(red: 255.0 / 255.0, green: 160.0 / 255.0, blue: 160.0 / 255.0, alpha: 1.0)
        buttonSubmit.layer.cornerRadius = 7
        buttonSubmit.addTarget(self, action: Selector("buttonAction:"), forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(buttonSubmit)
    }
    
    func buttonAction(sender: UIButton){
        if(isValidPassword(textUserPassword.text!)&&textUserPassword.text==textUserValidation.text){
            createPassword()
        }
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
        labelWelcome.textAlignment = NSTextAlignment.Center
        labelWelcome.text = "Create your new Password!"
        labelWelcome.textColor = UIColor(red: 249.0 / 255.0, green: 90.0 / 255.0, blue: 90.0 / 255.0, alpha: 1.0)
        labelWelcome.numberOfLines = 2
        labelWelcome.font = UIFont(name: "AvenirNext-Medium", size: 25.0)
        self.view.addSubview(labelWelcome)
        //labelUsernameUnserLine.layer.bordr
        
        
        let labelPasswordUnderlineWidth = screenWidth * 0.82125604
        let labelPasswordUnderlineXCor = screenWidth/2 - screenWidth * 0.41062802
        let labelPasswordUnderlineYCor = screenHeight * 0.4117 - navigationBarHeight
        labelPasswordUnderline = UILabel(frame: CGRect(x: labelPasswordUnderlineXCor, y: labelPasswordUnderlineYCor, width: labelPasswordUnderlineWidth, height: 1))
        labelPasswordUnderline.backgroundColor = UIColor.grayColor()
        self.view.addSubview(labelPasswordUnderline)
        
        let labelValidationUnderlineWidth = screenWidth * 0.82125604
        let labelValidationUnderlineXCor = screenWidth/2 - screenWidth * 0.41062802
        let labelValidationUnderlineYCor = screenHeight * 0.4986 - navigationBarHeight
        labelValidationUnderline = UILabel(frame: CGRect(x: labelValidationUnderlineXCor, y: labelValidationUnderlineYCor, width: labelValidationUnderlineWidth, height: 1))
        labelValidationUnderline.backgroundColor = UIColor.grayColor()
        self.view.addSubview(labelValidationUnderline)
    }
    
    //func pickerView(
    //    func textFieldDidBeginEditing(textField: UITextField) {
    //        print(textField.text)
    //    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        
        //        self.imageWelcome.image = UIImage(named: "signin_alert_type1")
        if(textField.restorationIdentifier=="userName"){
            imageIconUserPassword.image = UIImage(named: "password_red")
            labelPasswordUnderline.backgroundColor = UIColor(red: 255.0 / 255.0, green: 90.0 / 255.0, blue: 90.0 / 255.0, alpha: 1.0)
            if(textUserPassword.text==""){
                imagePasswordCheckIcon.image = UIImage(named: "check_eye_open_red")
            }
        }
        else if(textField.restorationIdentifier=="userPassword"){
            imageIconUserValidation.image = UIImage(named: "conf_password_red")
            labelValidationUnderline.backgroundColor = UIColor(red: 255.0 / 255.0, green: 90.0 / 255.0, blue: 90.0 / 255.0, alpha: 1.0)
            if(textUserValidation.text==""){
                imageValidationCheckIcon.image = UIImage(named: "check_eye_open_red")
            }
        }
        textField.textColor = UIColor(red: 255.0 / 255.0, green: 160.0 / 255.0, blue: 160.0 / 255.0, alpha: 1.0)
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        validateAll()
    }
    
    func validateAll(){
        if(textUserPassword.text==""){
            imagePasswordCheckIcon.image = UIImage(named:  "")
            textUserValidation.secureTextEntry = true
            imageIconUserPassword.image = UIImage(named: "password_gray")
            labelPasswordUnderline.backgroundColor = UIColor.grayColor()
        }
        else{
            if(isValidPassword(textUserPassword.text!)){
                imagePasswordCheckIcon.image = UIImage(named:  "check_eye_open_red")
            }
            else{
                imagePasswordCheckIcon.image = UIImage(named:  "check_exclamation_red-1")
            }
        }
        if(textUserValidation.text==""){
            imageValidationCheckIcon.image = UIImage(named:  "")
            textUserValidation.secureTextEntry = true
            imageIconUserValidation.image = UIImage(named: "conf_password_gray")
            labelValidationUnderline.backgroundColor = UIColor.grayColor()
            
        }
        else{
            if(textUserPassword.text==textUserValidation.text){
                imageValidationCheckIcon.image = UIImage(named:  "check_eye_open_red")
                buttonSubmit.backgroundColor = UIColor(red: 255.0 / 255.0, green: 90.0 / 255.0, blue: 90.0 / 255.0, alpha: 1.0)
            }
            else{
                imageValidationCheckIcon.image = UIImage(named:  "check_exclamation_red-1")
            }
        }
        
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
            if(uppercase + digit + symbol >= 2 && testStr.characters.count>=8)  {
                return true
            }
        }
        return false
    }
    
    func validation(){
        if(textUserValidation.text=="" && textUserPassword.text==""){
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
    
    func createPassword(){
        if let input = self.textUserPassword.text {
            let user = FaeUser()
            user.whereKey("email", value: emailNeedToBeVerified)
            user.whereKey("code", value: codeForVerification)
            user.whereKey("password", value: input)
            user.changePassword{ (status:Int?, message:AnyObject?) in
                if ( status! / 100 == 2 ){
                    //success
                    print("Changed successfully")
                    //login?
                }
                else{
                    //failure
                    print("Password update failure")
                }
            }
        }
    }
    
}
