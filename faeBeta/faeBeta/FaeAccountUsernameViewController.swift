//
//  MyFaeAccountUsernameViewController.swift
//  faeBeta
//
//  Created by 王彦翔 on 16/6/29.
//  Copyright © 2016年 fae. All rights reserved.
//

import UIKit

class FaeAccountUsernameViewController: UIViewController, UITextFieldDelegate{
    
    let screenWidth = UIScreen.main.bounds.width
    let screenHeight = UIScreen.main.bounds.height

    var username: String!
    
    var backgroundGrey: UIView!
    //var backgroundGrey: UIVisualEffectView!
    var backgroundButton: UIButton!
    
    var viewAlert: UIView!
    var labelAlertQuestion: UILabel!
    var labelAlertAction: UILabel!
    var buttonYes: UIButton!
    var imageAlertDelete: UIImageView!
    var viewEnterPassport: UIView!
    var labelEnterPassword: UILabel!
    var textfieldPassword: UITextField!
    var line: UIView!
    var labelForgetPassword: UILabel!
    var buttonContinue: UIButton!
    var imageEnterPasswordDelete: UIImageView!
    
    var labelPrompt: UILabel!
    var labelHint: UILabel!
    var labelUsername: UILabel!
    var labelUsedTo: UILabel!
    var labelFunction: UILabel!
    var labelResetHint: UILabel!
    
    var buttonCreate: UIButton!
    var buttonReset: UIButton!
    
    let colorButtonRed: UIColor = UIColor(red: 249.0 / 255.0, green: 90.0 / 255.0, blue: 90.0 / 255.0, alpha: 1.0)
    let colorButtonPink: UIColor = UIColor(red: 255.0 / 255.0, green: 160.0 / 255.0, blue: 160.0 / 255.0, alpha: 1.0)
    
    
    
    var textFieldUsername: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        loadTitle()
        loadBackground()
        loadLabel()
        loadButton()
        loadTextField()
        usernameNotExist()
        

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadTitle(){
        self.title = "Username"
    }
    
    func loadLabel(){
        let labelPromptY = 0.1399 * screenHeight
        let labelPromptWidth = 0.6618 * screenWidth
        let labelPromptHeight:CGFloat = 50.0
        labelPrompt = UILabel(frame: CGRect(x: (screenWidth-labelPromptWidth)/2, y: labelPromptY, width: labelPromptWidth, height: labelPromptHeight))
        labelPrompt.text = "Choose an unique Username\nto represent you!"
        labelPrompt.numberOfLines = 2
        labelPrompt.font = UIFont(name: "AvenirNext-Medium", size: 18.0)
        labelPrompt.textAlignment = .center
        labelPrompt.textColor = UIColor(white: 89.0 / 255.0, alpha: 0.6)
        self.view.addSubview(labelPrompt)
        
        let labelHintY = 0.2473 * screenHeight
        let labelHintWidth = 0.3478 * screenWidth
        let labelHintHeight:CGFloat = 36.0
        labelHint = UILabel(frame: CGRect(x: (screenWidth-labelHintWidth)/2, y: labelHintY, width: labelHintWidth, height: labelHintHeight))
        labelHint.text = "Only Letters & Numbers"
        labelHint.numberOfLines = 1
        labelHint.font = UIFont(name: "AvenirNext-Medium", size: 13.0)
        labelHint.textAlignment = .center
        labelHint.textColor = UIColor(white: 138.0 / 255.0, alpha: 0.6)
        self.view.addSubview(labelHint)
        
        let labelUsernameY = 221/736 * screenHeight
        let labelUsernameWidth = 172/414 * screenWidth
        let labelUsernameHeight:CGFloat = 34.0
        labelUsername = UILabel(frame: CGRect(x: (screenWidth-labelUsernameWidth)/2, y: labelUsernameY, width: labelUsernameWidth, height: labelUsernameHeight))
        labelUsername.text = "@LilyLily67890"
        labelUsername.numberOfLines = 1
        labelUsername.font = UIFont(name: "AvenirNext-Medium", size: 25.0)
        labelUsername.textAlignment = .center
        labelUsername.textColor = UIColor(white: 155.0 / 255.0, alpha: 1.0)
        self.view.addSubview(labelUsername)
        
        let labelUsedToY = 0.4538 * screenHeight
        let labelUsedToWidth = 0.4831 * screenWidth
        let labelUsedToHeight:CGFloat = 22.0
        labelUsedTo = UILabel(frame: CGRect(x: (screenWidth-labelUsedToWidth)/2, y: labelUsedToY, width: labelUsedToWidth, height: labelUsedToHeight))
        labelUsedTo.text = "Usernames can be used to:"
        labelUsedTo.numberOfLines = 1
        labelUsedTo.font = UIFont(name: "AvenirNext-Medium", size: 16.0)
        labelUsedTo.textAlignment = .center
        labelUsedTo.textColor = UIColor(white: 89.0 / 255.0, alpha: 0.6)
        self.view.addSubview(labelUsedTo)
        
        let labelFunctionY = 0.4891 * screenHeight
        let labelFunctionWidth = 0.6715 * screenWidth
        let labelFunctionHeight:CGFloat = 54.0
        labelFunction = UILabel(frame: CGRect(x: (screenWidth-labelFunctionWidth)/2, y: labelFunctionY, width: labelFunctionWidth, height: labelFunctionHeight))
        labelFunction.text = "-Log in, Find & Discover People, Add Contacts,\nStart Chats, Tag Friends & much more…"
        labelFunction.numberOfLines = 2
        labelFunction.font = UIFont(name: "AvenirNext-Medium", size: 13.0)
        labelFunction.textAlignment = .center
        labelFunction.textColor = UIColor(white: 138.0 / 255.0, alpha: 0.6)
        self.view.addSubview(labelFunction)
        
        let labelResetHintY = 592/736 * screenHeight
        let labelResetHintWidth = 226/414 * screenWidth
        let labelResetHintHeight:CGFloat = 36.0
        labelResetHint = UILabel(frame: CGRect(x: (screenWidth-labelResetHintWidth)/2, y: labelResetHintY, width: labelResetHintWidth, height: labelResetHintHeight))
        labelResetHint.text = "If you want to change your Username,\nplease request a Username Reset."
        labelResetHint.numberOfLines = 2
        labelResetHint.font = UIFont(name: "AvenirNext-Medium", size: 13.0)
        labelResetHint.textAlignment = .center
        labelResetHint.textColor = UIColor(white: 138.0 / 255.0, alpha: 0.6)
        self.view.addSubview(labelResetHint)
    }
    
    func loadButton(){
        let buttonCreateY = 437/736 * screenHeight
        let buttonCreateWidth = 160/414 * screenWidth
        let buttonCreateHeight:CGFloat = 39.0
        buttonCreate = UIButton(frame: CGRect(x: (screenWidth-buttonCreateWidth)/2, y: buttonCreateY, width: buttonCreateWidth, height: buttonCreateHeight))
        buttonCreate.setTitle("Create", for: UIControlState())
        buttonCreate.titleLabel?.textColor = UIColor.white
        buttonCreate.backgroundColor = UIColor(red: 255.0 / 255.0, green: 160.0 / 255.0, blue: 160.0 / 255.0, alpha: 1.0)
        buttonCreate.layer.cornerRadius = 7
        buttonCreate.titleLabel?.textAlignment = .center
        buttonCreate.addTarget(self, action: #selector(FaeAccountUsernameViewController.buttonAction(_:)), for: UIControlEvents.touchUpInside)
        self.view.addSubview(buttonCreate)
        
        let buttonResetY = 528/736 * screenHeight
        let buttonResetWidth = 217/414 * screenWidth
        let buttonResetHeight:CGFloat = 39.0
        buttonReset = UIButton(frame: CGRect(x: (screenWidth-buttonResetWidth)/2, y: buttonResetY, width: buttonResetWidth, height: buttonResetHeight))
        buttonReset.setTitle("Request Reset", for: UIControlState())
        buttonReset.titleLabel?.textColor = UIColor.white
        buttonReset.backgroundColor = UIColor(red: 255.0 / 255.0, green: 160.0 / 255.0, blue: 160.0 / 255.0, alpha: 1.0)
        buttonReset.layer.cornerRadius = 7
        buttonReset.titleLabel?.textAlignment = .center
        buttonReset.addTarget(self, action: #selector(FaeAccountUsernameViewController.buttonAction(_:)), for: UIControlEvents.touchUpInside)
        self.view.addSubview(buttonReset)

    }
    
    func buttonAction(_ sender: UIButton){
        //labelWelcome.text = "sdasdjak"
        if sender == buttonCreate{
            let user = FaeUser()
            if (textFieldUsername.text != nil) && (textFieldUsername.text != ""){
                user.whereKey("username", value: textFieldUsername.text!)
                user.checkUserExistence{(status:Int?, message: Any?) in
                    if ( status! / 100 == 2 ){
                        if let message = (message as? NSDictionary) {
                            if let didexist = message["existence"]{
                                if didexist as! Bool{
                                    self.labelPrompt.text = "Oh No…This Username is taken.\nPlease choose another one!"
                                }
                                else{
                                    self.username = self.textFieldUsername.text!
                                    self.buttonReset.setTitle("Processing...", for: UIControlState())
                                    self.buttonReset.backgroundColor = self.colorButtonPink
                                    self.buttonCreate.isEnabled = false
                                    self.usernameExist()
                                    let userUpdate = FaeUser()
                                    userUpdate.whereKey("user_name", value: self.textFieldUsername.text!)
                                    userUpdate.updateAccountBasicInfo{(code:Int?, message: Any?) in
                                        if code!/100 == 2{
                                            print("yes")
                                            self.buttonReset.setTitle("Reset", for: UIControlState())
                                            self.labelUsername.text = self.textFieldUsername.text!
                                            self.buttonReset.backgroundColor = self.colorButtonRed
                                        }
                                        else{
                                            self.usernameNotExist()
                                        }
                                        self.buttonCreate.isEnabled = true
                                    }
                                }
                            }
                        }
                        else{
                            print("failure")
                        }
                    }
                    else{
                        self.labelPrompt.text = "network failure"
                    }
                }
            }
            else{
                labelPrompt.text = "Please input username"
            }
        }
        else if sender == buttonReset{
            self.backgroundGrey.isHidden = false
            self.viewEnterPassport.isHidden = true
            self.viewAlert.isHidden = false
        }
        else if sender == buttonYes{
            viewAlert.isHidden = false
            viewEnterPassport.isHidden = false
        }
        else if sender == buttonContinue{
            if textfieldPassword.text != nil{
                if textfieldPassword.text != ""{
                    if checkPassword(textfieldPassword.text!){
                        print("heheahahahah")
                        self.backgroundGrey.isHidden = true
                        self.buttonReset.setTitle("Processing...", for: UIControlState())
                        self.buttonReset.backgroundColor = colorButtonPink
                        self.buttonReset.isEnabled = false
                        let user = FaeUser()
                        user.whereKey("user_name", value: self.textFieldUsername.text!)
                        user.updateAccountBasicInfo{(code:Int?, message: Any?) in
                            if code!/100 == 2{
                                print("yes")
                                self.buttonReset.setTitle("Reset", for: UIControlState())
                                self.labelUsername.text = self.textFieldUsername.text!
                                self.buttonReset.backgroundColor = self.colorButtonRed
                            }
                            else{
                                self.usernameNotExist()
                            }
                            self.buttonReset.isEnabled = true
                        }

                        //user.whereKey("user_name", value: )
                    }
                }
                else{
                    labelEnterPassword.text = "Please input password"
                }
            }
        }
    }
    
    
    
    
    
    func loadTextField(){
        let textFieldUsernameY = 253/736 * screenHeight
        let textFieldUsernameWidth = 166/414 * screenWidth
        let textFieldUsernameHeight:CGFloat = 30.0
        textFieldUsername = UITextField(frame: CGRect(x: (screenWidth-textFieldUsernameWidth)/2, y: textFieldUsernameY, width: textFieldUsernameWidth, height: textFieldUsernameHeight))
        textFieldUsername.placeholder = "@NewUsername"
        textFieldUsername.font = UIFont(name: "AvenirNext-Regular", size: 22.0)
        //textFieldUsername.textColor = UIColor.redColor()
        textFieldUsername.delegate = self
        textFieldUsername.autocorrectionType = .no
        textFieldUsername.textAlignment = .center
        self.view.addSubview(textFieldUsername)
    }
    
    
    func loadBackground(){
        let backgroundButtonMain = UIButton(frame: self.view.frame)
        backgroundButtonMain.addTarget(self, action: #selector(FaeAccountUsernameViewController.usernameInputFinished), for: UIControlEvents.touchUpInside)
        self.view.addSubview(backgroundButtonMain)
        
        
//        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
//        backgroundGrey = UIVisualEffectView(effect: blurEffect)
//        backgroundGrey.frame = self.view.frame
        
        backgroundGrey = UIView()
        backgroundGrey.frame = self.view.frame
        backgroundGrey.backgroundColor = UIColor(red: 107.0 / 255.0, green: 105.0 / 255.0, blue: 105.0 / 255.0, alpha: 0.5)
        
        //let tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(FaeAccountUsernameViewController.showMainView(_:)))
        //backgroundGrey.addGestureRecognizer(tapGesture2)
        //backgroundGrey.userInteractionEnabled = true
        //self.view.addSubview(backgroundGrey)
        UIApplication.shared.keyWindow?.rootViewController!.view.addSubview(backgroundGrey)
        //backgroundGrey.hidden = true
        
        backgroundButton = UIButton(frame: backgroundGrey.frame)
        backgroundButton.addTarget(self, action: #selector(FaeAccountUsernameViewController.showMainView(_:)), for: UIControlEvents.touchUpInside)
        backgroundGrey.addSubview(backgroundButton)
        
        let viewAlertY = 160/736 * screenHeight
        let viewAlertWidth = 350/414 * screenWidth
        let viewAlertHeight:CGFloat = 229.0
        viewAlert = UIView(frame: CGRect(x: (screenWidth-viewAlertWidth)/2, y: viewAlertY, width: viewAlertWidth, height: viewAlertHeight))
        viewAlert.backgroundColor = UIColor.white
        viewAlert.layer.cornerRadius = 21
        
        
        let labelAlertQuestionY = 24/739 * screenHeight
        let labelAlertQuestionWidth = 240/414 * screenWidth
        let labelAlertQuestionHeight:CGFloat = 60.0
        labelAlertQuestion = UILabel(frame: CGRect(x: (viewAlertWidth-labelAlertQuestionWidth)/2, y: labelAlertQuestionY, width: labelAlertQuestionWidth, height: labelAlertQuestionHeight))
        labelAlertQuestion.text = "Are you sure you want to\nreset your Username?"
        labelAlertQuestion.numberOfLines = 2
        labelAlertQuestion.font = UIFont(name: "AvenirNext-Medium", size: 20.0)
        
        labelAlertQuestion.textAlignment = .center
        labelAlertQuestion.textColor = UIColor(red: 107.0 / 255.0, green: 105.0 / 255.0, blue: 105.0 / 255.0, alpha: 1.0)
        viewAlert.addSubview(labelAlertQuestion)

        
        let labelAlertActionY = 93/739 * screenHeight
        let labelAlertActionWidth = 269/414 * screenWidth
        let labelAlertActionHeight:CGFloat = 54.0
        labelAlertAction = UILabel(frame: CGRect(x: (viewAlertWidth-labelAlertActionWidth)/2, y: labelAlertActionY, width: labelAlertActionWidth, height: labelAlertActionHeight))
        labelAlertAction.text = "We’ll send you a message when your\nUsername is ready to be resetted. Meanwhile\nyou can still use your Username."
        labelAlertAction.numberOfLines = 3
        labelAlertAction.font = UIFont(name: "AvenirNext-Medium", size: 13.0)
        labelAlertAction.textAlignment = .center
        labelAlertAction.textColor = UIColor(red: 138.0 / 255.0, green: 138.0 / 255.0, blue: 138.0 / 255.0, alpha: 1.0)
        viewAlert.addSubview(labelAlertAction)
        
        let buttonYesY = 169/736 * screenHeight
        let buttonYesWidth = 130/414 * screenWidth
        let buttonYesHeight:CGFloat = 39.0
        buttonYes = UIButton(frame: CGRect(x: (viewAlertWidth-buttonYesWidth)/2, y: buttonYesY, width: buttonYesWidth, height: buttonYesHeight))
        buttonYes.setTitle("Yes", for: UIControlState())
        buttonYes.titleLabel?.textColor = UIColor.white
        buttonYes.backgroundColor = colorButtonRed
        buttonYes.layer.cornerRadius = 7
        buttonYes.titleLabel?.textAlignment = .center
        buttonYes.addTarget(self, action: #selector(FaeAccountUsernameViewController.buttonAction(_:)), for: UIControlEvents.touchUpInside)
        viewAlert.addSubview(buttonYes)
     
        let imageAlertDeleteY = 15/736 * screenHeight
        let imageAlertDeleteWidth = 17/414 * screenWidth
        let imageAlertDeleteHeight:CGFloat = 17.0
        imageAlertDelete = UIImageView(frame: CGRect(x: imageAlertDeleteY, y: imageAlertDeleteY, width: imageAlertDeleteWidth, height: imageAlertDeleteHeight))
        imageAlertDelete.image = UIImage(named: "check_cross_red")
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(FaeAccountUsernameViewController.showMainView(_:)))
        imageAlertDelete.addGestureRecognizer(tapGesture)
        imageAlertDelete.isUserInteractionEnabled = true
        viewAlert.addSubview(imageAlertDelete)
        
        
        self.backgroundGrey.addSubview(viewAlert)
        viewAlert.isHidden = false
        
        
        let viewEnterPassportY = 160/736 * screenHeight
        let viewEnterPassportWidth = 350/414 * screenWidth
        let viewEnterPassportHeight:CGFloat = 229.0
        viewEnterPassport = UIView(frame: CGRect(x: (screenWidth-viewEnterPassportWidth)/2, y: viewEnterPassportY, width: viewEnterPassportWidth, height: viewEnterPassportHeight))
        viewEnterPassport.backgroundColor = UIColor.white
        viewEnterPassport.layer.cornerRadius = 21
        
        
        let labelEnterPasswordY = 30/739 * screenHeight
        let labelEnterPasswordWidth = 240/414 * screenWidth
        let labelEnterPasswordHeight:CGFloat = 25.0
        labelEnterPassword = UILabel(frame: CGRect(x: (viewEnterPassportWidth-labelEnterPasswordWidth)/2, y: labelEnterPasswordY, width: labelEnterPasswordWidth, height: labelEnterPasswordHeight))
        labelEnterPassword.text = "Enter your Password"
        labelEnterPassword.numberOfLines = 1
        labelEnterPassword.font = UIFont(name: "AvenirNext-Medium", size: 20.0)
        
        labelEnterPassword.textAlignment = .center
        labelEnterPassword.textColor = UIColor(red: 107.0 / 255.0, green: 105.0 / 255.0, blue: 105.0 / 255.0, alpha: 1.0)
        viewEnterPassport.addSubview(labelEnterPassword)
        
        
        let labelForgetPasswordY = 197/739 * screenHeight
        let labelForgetPasswordWidth = 100/414 * screenWidth
        let labelForgetPasswordHeight:CGFloat = 18.0
        labelForgetPassword = UILabel(frame: CGRect(x: (viewEnterPassportWidth-labelForgetPasswordWidth)/2, y: labelForgetPasswordY, width: labelForgetPasswordWidth, height: labelForgetPasswordHeight))
        labelForgetPassword.text = "Forgot Password"
        labelForgetPassword.numberOfLines = 1
        labelForgetPassword.font = UIFont(name: "AvenirNext-Medium", size: 13.0)
        labelForgetPassword.textAlignment = .center
        labelForgetPassword.textColor = UIColor(red: 138.0 / 255.0, green: 138.0 / 255.0, blue: 138.0 / 255.0, alpha: 1.0)
        viewEnterPassport.addSubview(labelForgetPassword)
        
        let buttonContinueY = 141/736 * screenHeight
        let buttonContinueWidth = 130/414 * screenWidth
        let buttonContinueHeight:CGFloat = 39.0
        buttonContinue = UIButton(frame: CGRect(x: (viewEnterPassportWidth-buttonContinueWidth)/2, y: buttonContinueY, width: buttonContinueWidth, height: buttonContinueHeight))
        buttonContinue.setTitle("Continue", for: UIControlState())
        buttonContinue.titleLabel?.textColor = UIColor.white
        buttonContinue.backgroundColor = colorButtonPink
        buttonContinue.layer.cornerRadius = 7
        buttonContinue.titleLabel?.textAlignment = .center
        buttonContinue.addTarget(self, action: #selector(FaeAccountUsernameViewController.buttonAction(_:)), for: UIControlEvents.touchUpInside)
        viewEnterPassport.addSubview(buttonContinue)
        
        let textfieldPasswordY = 85/736 * screenHeight
        let textfieldPasswordWidth = 100/414 * screenWidth
        let textfieldPasswordHeight:CGFloat = 30.0
        textfieldPassword = UITextField(frame: CGRect(x: (viewEnterPassportWidth-textfieldPasswordWidth)/2, y: textfieldPasswordY, width: textfieldPasswordWidth, height: textfieldPasswordHeight))
        textfieldPassword.placeholder = "Password"
        textfieldPassword.font = UIFont(name: "AvenirNext-Regular", size: 20.0)
        textfieldPassword.delegate = self
        textfieldPassword.isSecureTextEntry = true
        viewEnterPassport.addSubview(textfieldPassword)
        
        let lineY = 113/736 * screenHeight
        let lineWidth = 266/414 * screenWidth
        let lineHeight:CGFloat = 2.0
        line = UITextField(frame: CGRect(x: (viewEnterPassportWidth-lineWidth)/2, y: lineY, width: lineWidth, height: lineHeight))
        line.backgroundColor = UIColor(red: 182.0 / 255.0, green: 182.0 / 255.0, blue: 182.0 / 255.0, alpha: 1.0)
        viewEnterPassport.addSubview(line)
        
        let imageEnterPasswordDeleteY = 15/736 * screenHeight
        let imageEnterPasswordDeleteWidth = 17/414 * screenWidth
        let imageEnterPasswordDeleteHeight:CGFloat = 17.0
        imageEnterPasswordDelete = UIImageView(frame: CGRect(x: imageEnterPasswordDeleteY, y: imageEnterPasswordDeleteY, width: imageEnterPasswordDeleteWidth, height: imageEnterPasswordDeleteHeight))
        imageEnterPasswordDelete.image = UIImage(named: "check_cross_red")
        let tapGesture1 = UITapGestureRecognizer(target: self, action: #selector(FaeAccountUsernameViewController.showMainView(_:)))
        imageEnterPasswordDelete.addGestureRecognizer(tapGesture1)
        imageEnterPasswordDelete.isUserInteractionEnabled = true
        viewEnterPassport.addSubview(imageEnterPasswordDelete)
        viewEnterPassport.isHidden = true
        
        self.backgroundGrey.addSubview(viewEnterPassport)
        
        self.backgroundGrey.isHidden = true
        
        
    }
    
    func usernameInputFinished(){
        print("get in")
        if textFieldUsername != nil{
            if textFieldUsername.text != ""{
                buttonCreate.backgroundColor = colorButtonRed
            }
            else{
                buttonCreate.backgroundColor = colorButtonPink
            }
        }

    }
    
    func checkPassword(_ password: String) ->Bool{
        return true
    }
    
    func showMainView(_ sender: UIImageView){
        backgroundGrey.isHidden = true
    }
    
    func usernameExist(){
        labelResetHint.isHidden = false
        buttonReset.isHidden = false
        labelUsername.isHidden = false
        labelHint.isHidden = true
        textFieldUsername.isHidden = true
        buttonCreate.isHidden = true
    }
    
    func usernameNotExist(){
        labelResetHint.isHidden = true
        buttonReset.isHidden = true
        labelUsername.isHidden = true
        labelHint.isHidden = false
        textFieldUsername.isHidden = false
        buttonCreate.isHidden = false
        
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
