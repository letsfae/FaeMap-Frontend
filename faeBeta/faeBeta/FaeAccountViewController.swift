//
//  FaeAccountViewController.swift
//  faeBeta
//
//  Created by blesssecret on 6/28/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit


class FaeAccountViewController: UIViewController {
    let screenWidth = UIScreen.mainScreen().bounds.width
    let screenHeight = UIScreen.mainScreen().bounds.height
    let colorGreyFae = UIColor(colorLiteralRed: 138/255, green: 138/255, blue: 138/255, alpha: 1)
    //tableview
    var myTableView : UITableView!
    let cellGeneralIdentifier = "cellGeneral"
    let cellTitleIdentifier = "cellGeneral2"
    //firstName lastname view
    var viewFirstLastBackground : UIView!
    var viewFirstAndLast : UIView!
    var labelTitleFirstLast : UILabel!
    var labelDetailFirstLast : UILabel!
    var textFieldFirstLast : UITextField!
    var viewUnderlineName : UIView!
    var buttonSaveName : UIButton!
    var buttonCloseName : UIButton!
    var buttonBackgroundClose : UIButton!
    //birthday view
    var viewBirthdayBackground : UIView!
    var viewBirthday : UIView!
    var labelTitleBirthday : UILabel!
    var labelDataShowBirthday : UILabel!
    var viewUnderlineBirthday : UIView!
    var buttonCloseBirthday : UIButton!
    var buttonSaveBirthday : UIButton!
    var buttonBackgroundCloseBirthday : UIButton!
    var dataPickerBirthday : UIDatePicker!
    // gender view
    var viewGenderBackground : UIView!
    var viewGender : UIView!
    var buttonCloseGender : UIButton!
    var buttonBackgroundCloseGender : UIButton!
    var labelTitleGender : UILabel!
    var buttonMale : UIButton!
    var buttonFemale : UIButton!
    var buttonSaveGender : UIButton!
    //MARK: gender must be load from local storage
    var gender : Int = 1 // 0 means male 1 means female
    //MARK: phone and reset password log out
    var popUpView : UIView!
    var popUpDialogView : UIView!
    
    var labelDialogTital : UILabel!
    var labelRetryHint : UILabel!
    var buttonContinuePasswordChange : UIButton!
    var buttonProceed : UIButton!
    
    var imagePassword : UIImageView!
    var imagePasswordAgain : UIImageView!
    
    var textPassword : UITextField!
    var textPasswordAgain : UITextField!
    
    var imageCheckPassword : UIImageView!
    var imageCheckPasswordAgain : UIImageView!
    
    var labelPasswordHint : UILabel!
    var labelPasswordAgainHint : UILabel!
    
    var viewPassword : UIView!
    var viewPasswordAgain : UIView!
    
    var inLineViewPassword : UIView!
    var inLineViewPasswordAgain : UIView!
    
    var imageAlertView : UIImageView!
    
    var textPassWordCheck : UITextField!
    
    var passwordRetryChance : Int = 6
    
    var TextFieldDummy = UITextField(frame: CGRectZero)
    
    let colorFae = UIColor(red: 249.0 / 255.0, green: 90.0 / 255.0, blue: 90.0 / 255.0, alpha: 1.0)
    
    let colorDisableButton = UIColor(red: 255.0 / 255.0, green: 160.0 / 255.0, blue: 160.0 / 255.0, alpha: 1.0)
    let ColorFae = UIColor(red: 248/255, green: 90/255, blue: 90/255, alpha: 1)
    let ColorFaeOrange = UIColor(red: 252.0 / 255.0, green: 155.0 / 255.0, blue: 43.0 / 255.0, alpha: 1.0)
    let ColorFaeYellow = UIColor(red: 247.0 / 255.0, green: 200.0 / 255.0, blue: 90.0 / 255.0, alpha: 1.0)
    
    var imageCodeDotArray = [UIImageView!]()
    
    var textVerificationCode = [UILabel!]()
    
    var index : Int = 0
    
    var countDown : Int = 60
    
    var timer : NSTimer!
    
    let isIPhone5 = UIScreen.mainScreen().bounds.size.height == 568
    
    var passwordValidated = false
    
    var passwordAgainValidated = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addTableView()
        self.navigationController?.navigationBar.tintColor = UIColor.redColor()
//        self.navigationController?.navigationBar.setBackgroundImage(UIImage(named: "transparent"), forBarMetrics: UIBarMetrics.Default)
        self.navigationController?.navigationBar.shadowImage = nil
//        self.navigationController?.navigationBar.shadowImage = UIImage(named: "transparent")
        initialSubView()
        // Do any additional setup after loading the view.
        let shareAPI = LocalStorageManager()
        shareAPI.readLogInfo()
        print(userFirstname)
        
        let user = FaeUser()
        user.getAccountBasicInfo({(status:Int,message:AnyObject?) in
        })
    }
    func initialSubView(){
        initialFirstLastName()
        initialBirthdayView()
        initialGenderView()
        popUpView = UIView(frame: CGRectZero)
    }
    override func viewWillAppear(animated: Bool) {
//        self.myTableView.reloadData()
        //reload after internet completed
    }
    func addTableView(){
        myTableView = UITableView(frame: CGRectMake(0, 0, screenWidth, screenHeight),style: .Grouped)
        myTableView.delegate = self
        myTableView.dataSource = self
        self.view.addSubview(myTableView)
        myTableView.rowHeight = 54
        myTableView.registerNib( UINib(nibName: "FaeAccountTableViewCell", bundle: nil), forCellReuseIdentifier: cellGeneralIdentifier)
        myTableView.registerNib(UINib(nibName: "FaeAccountWithoutTableViewCell",bundle: nil), forCellReuseIdentifier: cellTitleIdentifier)
        myTableView.backgroundColor = UIColor.clearColor()
        myTableView.separatorColor = UIColor.clearColor()
    }
    func jumpToAccountEmail(){
        let vc = UIStoryboard(name: "Main", bundle: nil) .instantiateViewControllerWithIdentifier("AccountEmailViewController")as! AccountEmailViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func jumpToPhone(){
        let phoneNumber = alreadyBindWithPhoneNumber()
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("PhoneConnectViewController") as! PhoneConnectViewController
        vc.phoneString = phoneNumber
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func jumpToUsername(){
        let vc = UIStoryboard(name: "Main", bundle: nil) .instantiateViewControllerWithIdentifier("FaeAccountUsernameViewController")as! FaeAccountUsernameViewController
        self.navigationController?.pushViewController(vc, animated: true)
        
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

//MARK: log out
extension FaeAccountViewController {
    
    func addLogOutView() {
        clearSubViewFor(popUpView)
        preparePopUpView()
        popUpDialogView = UIView(frame: CGRect(x: 32, y: 160, width: 350, height: 208))
        popUpDialogView.layer.cornerRadius = 21
        popUpDialogView.layer.zPosition = 30
        popUpDialogView.backgroundColor = UIColor.whiteColor()
        
        labelDialogTital = UILabel(frame: CGRect(x: 111.5, y: 30, width: 127, height: 21))
        let attributedString = NSMutableAttributedString(string: "See you soon!")
        attributedString.addAttribute(NSKernAttributeName, value: CGFloat(-0.3), range: NSRange(location: 0, length: attributedString.length))
        labelDialogTital.attributedText = attributedString
        labelDialogTital.font = UIFont(name: "Avenir Next", size: 20)
        labelDialogTital.textColor = UIColor(red: 107 / 255, green: 105 / 255, blue: 105 / 255, alpha: 1)
        labelDialogTital.textAlignment = .Center
        popUpDialogView.addSubview(labelDialogTital)
        
        addCancelButton()
        
        let labelContent = UILabel(frame: CGRect(x: 47.5, y: 60, width: 256, height: 72))
        labelContent.text = "If you’re not a Crown/Winged Member,\nLogging out will impact your Activity Level.\nLog back in soon to continue your Growth\n& retain your Level"
        labelContent.numberOfLines = 0
        labelContent.font = UIFont(name: "Avenir Next", size: 13)
        labelContent.textColor = UIColor(red: 138 / 255, green: 138 / 255, blue: 138 / 255, alpha: 1)
        labelContent.textAlignment = .Center
        popUpDialogView.addSubview(labelContent)
        
        let buttonLogOut = UIButton(frame: CGRect(x: 107, y: 148, width: 137, height: 39))
        buttonLogOut.backgroundColor = UIColor(red: 249 / 255, green: 90 / 255, blue: 90 / 255, alpha: 1.0)
        buttonLogOut.setTitle("Log Out", forState: .Normal)
        buttonLogOut.titleLabel?.font = UIFont(name: "Avenir Next", size: 20)
        buttonLogOut.layer.cornerRadius = 7
        buttonLogOut.addTarget(self, action: #selector(FaeAccountViewController.logOut), forControlEvents: .TouchUpInside)
        popUpDialogView.addSubview(buttonLogOut)
        
        popUpView.addSubview(popUpDialogView)
        self.view.addSubview(popUpView)
    }
    
    func logOut() {
        let user = FaeUser()
        user.logOut()
        jumpTowelcomeVC()
    }
}
//MARK: change password

extension FaeAccountViewController : UITextFieldDelegate{
    
    //MARK: Change Password layout
    
    func addPasswordChangeView() {
        clearSubViewFor(popUpView)
        preparePopUpView()
        popUpDialogView = UIView(frame: CGRect(x: 32, y: 160, width: 350, height: 229))
        popUpDialogView.backgroundColor = UIColor.whiteColor()
        popUpDialogView.layer.zPosition = 30
        popUpDialogView.layer.cornerRadius = 21
        
        labelDialogTital = UILabel(frame: CGRect(x: 84, y: 30, width: 182, height: 21))
        let attributedString = NSMutableAttributedString(string: "Enter your Password")
        attributedString.addAttribute(NSKernAttributeName, value: CGFloat(-0.3), range: NSRange(location: 0, length: attributedString.length))
        labelDialogTital.attributedText = attributedString
        labelDialogTital.font = UIFont(name: "Avenir Next", size: 20)
        labelDialogTital.textColor = UIColor(red: 107 / 255, green: 105 / 255, blue: 105 / 255, alpha: 1)
        labelDialogTital.textAlignment = .Center
        popUpDialogView.addSubview(labelDialogTital)
        
        textPassWordCheck = UITextField(frame: CGRect(x: 42, y: 90, width: 266, height: 21))
        textPassWordCheck.textAlignment = .Center
        textPassWordCheck.textColor = UIColor(red: 200 / 255, green: 199 / 255, blue: 204 / 255, alpha: 1.0)
        textPassWordCheck.placeholder = "Password"
        textPassWordCheck.font = UIFont(name: "Avenir Next", size: 20)
        textPassWordCheck.addTarget(self, action: #selector(FaeAccountViewController.passwordFieldDidChange), forControlEvents: UIControlEvents.EditingChanged)
        textPassWordCheck.secureTextEntry = true
        textPassWordCheck.textColor = colorFae
        textPassWordCheck.tintColor = colorFae
        textPassWordCheck.delegate = self
        textPassWordCheck.becomeFirstResponder()
        popUpDialogView.addSubview(textPassWordCheck)
        
        let underLineView = UIView(frame: CGRect(x: 42, y: 113, width: 266, height: 2))
        underLineView.backgroundColor = UIColor(red: 182 / 255, green: 182 / 255, blue: 182 / 255, alpha: 1.0)
        popUpDialogView.addSubview(underLineView)
        
        buttonContinuePasswordChange = UIButton(frame: CGRect(x: 107, y: 148, width: 137, height: 39))
        buttonContinuePasswordChange.setTitle("Continue", forState: .Normal)
        buttonContinuePasswordChange.titleLabel?.font = UIFont(name: "Avenir Next", size: 20)
        buttonContinuePasswordChange.layer.cornerRadius = 7
        buttonContinuePasswordChange.addTarget(self, action: #selector(FaeAccountViewController.processPWDChangeRequest), forControlEvents: .TouchUpInside)
        disableButton(buttonContinuePasswordChange)
        popUpDialogView.addSubview(buttonContinuePasswordChange)
        
        addCancelButton()
        
        labelRetryHint = UILabel(frame: CGRect(x: 127.5, y: 51, width: 97, height: 18))
        labelRetryHint.textColor = UIColor(red: 138 / 255, green: 138 / 255, blue: 138 / 255, alpha: 1.0)
        labelRetryHint.font = UIFont(name: "Avenir Next", size: 13)
        labelRetryHint.textAlignment = .Center
        labelRetryHint.hidden = true
        popUpDialogView.addSubview(labelRetryHint)
        
        let buttonForgetPassword = UIButton(frame: CGRect(x: 126, y: 197, width: 100, height: 18))
        buttonForgetPassword.setTitle("Forgot Password", forState: .Normal)
        buttonForgetPassword.setTitleColor(UIColor(red: 138 / 255, green: 138 / 255, blue: 138 / 255, alpha: 1.0), forState: .Normal)
        buttonForgetPassword.titleLabel?.font = UIFont(name: "Avenir Next", size: 13)
        buttonForgetPassword.addTarget(self, action: #selector(FaeAccountViewController.jumpToforgetPassword), forControlEvents: .TouchUpInside)
        popUpDialogView.addSubview(buttonForgetPassword)
        
        popUpView.addSubview(popUpDialogView)
        self.view.addSubview(popUpView)
    }
    
    func addSendCodeView() {
        clearSubViewFor(popUpDialogView)
        popUpDialogView = UIView(frame: CGRect(x: 32, y: 160, width: 350, height: 210))
        popUpDialogView.backgroundColor = UIColor.whiteColor()
        popUpDialogView.layer.zPosition = 30
        popUpDialogView.layer.cornerRadius = 21
        
        labelDialogTital = UILabel(frame: CGRect(x: 40, y: 30, width: 270, height: 60))
        labelDialogTital.text = "Send a code to your Primary\nEmail to reset Password. "
        labelDialogTital.numberOfLines = 0
        labelDialogTital.font = UIFont(name: "Avenir Next", size: 20)
        labelDialogTital.textColor = UIColor(red: 107 / 255, green: 105 / 255, blue: 105 / 255, alpha: 1)
        labelDialogTital.textAlignment = .Center
        popUpDialogView.addSubview(labelDialogTital)
        
        buttonContinuePasswordChange.frame = CGRectMake(107, 150, 137, 39)
        buttonContinuePasswordChange.addTarget(self, action: #selector(FaeAccountViewController.sendCodeToEmail), forControlEvents: .TouchUpInside)
        popUpDialogView.addSubview(buttonContinuePasswordChange)
        
        var labelEmail = UILabel(frame: CGRect(x: 30, y: 98, width: 290, height: 21))
        labelEmail.font = UIFont(name: "Avenir Next", size: 20)
        let attributeEmail = NSMutableAttributedString(string: convertEmailAddress(getCurrentUserEmail()))
        attributeEmail.addAttribute(NSKernAttributeName, value: CGFloat(-0.3), range: NSRange(location: 0, length: attributeEmail.length))
        labelEmail.attributedText = attributeEmail
        labelEmail.textAlignment = .Center
        labelEmail.textColor = UIColor(red: 138 / 255, green: 138 / 255, blue: 138 / 255, alpha: 1.0)
        popUpDialogView.addSubview(labelEmail)
        
        addCancelButton()
        
        popUpView.addSubview(popUpDialogView)
    }
    
    func addCodeView() {
        clearSubViewFor(popUpDialogView)
        popUpDialogView = UIView(frame: CGRect(x: 32, y: 139, width: 350, height: 239))
        popUpDialogView.backgroundColor = UIColor.whiteColor()
        popUpDialogView.layer.zPosition = 30
        popUpDialogView.layer.cornerRadius = 21
        
        buttonContinuePasswordChange.frame = CGRectMake(75, 179, 200, 39)
        buttonContinuePasswordChange.addTarget(self, action: #selector(FaeAccountViewController.resendCode), forControlEvents: .TouchUpInside)
        buttonContinuePasswordChange.setTitle("Resend Code", forState: .Normal)
        popUpDialogView.addSubview(buttonContinuePasswordChange)
        
        labelDialogTital = UILabel(frame: CGRect(x: 40, y: 30, width: 270, height: 60))
        labelDialogTital.text = "Please enter the code we\nsend to your email"
        labelDialogTital.numberOfLines = 0
        labelDialogTital.font = UIFont(name: "Avenir Next", size: 20)
        labelDialogTital.textColor = UIColor(red: 107 / 255, green: 105 / 255, blue: 105 / 255, alpha: 1)
        labelDialogTital.textAlignment = .Center
        popUpDialogView.addSubview(labelDialogTital)
        
        buttonProceed = UIButton(frame: CGRect(x: 0, y: 456, width: screenWidth, height: 56))
        buttonProceed.setTitle("Proceed", forState: .Normal)
        buttonProceed.titleLabel?.font = UIFont(name: "Avenir Next", size: 20)
        disableButton(buttonProceed)
        buttonProceed.addTarget(self, action: #selector(FaeAccountViewController.processToNewPassword), forControlEvents: .TouchUpInside)
        self.view.addSubview(buttonProceed)
        
        addCancelButton()
        
        loadTextField()
        loadVerificaitonCode()
        loadDot()
        disableButton(buttonContinuePasswordChange)
        
        popUpView.addSubview(popUpDialogView)
        
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(FaeAccountViewController.update), userInfo: nil, repeats: true)
    }
    
    func addResetPasswordView() {
        clearSubViewFor(popUpDialogView)
        popUpDialogView.removeFromSuperview()
        popUpDialogView = UIView(frame: CGRect(x: 32, y: 160, width: 350, height: 278))
        popUpDialogView.backgroundColor = UIColor.whiteColor()
        popUpDialogView.layer.zPosition = 30
        popUpDialogView.layer.cornerRadius = 21
        
        addCancelButton()
        
        labelDialogTital = UILabel(frame: CGRect(x: 94.5, y: 30, width: 161, height: 21))
        let attributedString = NSMutableAttributedString(string: "Change Password")
        attributedString.addAttribute(NSKernAttributeName, value: CGFloat(-0.3), range: NSRange(location: 0, length: attributedString.length))
        labelDialogTital.attributedText = attributedString
        labelDialogTital.font = UIFont(name: "Avenir Next", size: 20)
        labelDialogTital.textColor = UIColor(red: 107 / 255, green: 105 / 255, blue: 105 / 255, alpha: 1)
        labelDialogTital.textAlignment = .Center
        popUpDialogView.addSubview(labelDialogTital)
        
        buttonContinuePasswordChange.frame = CGRectMake(110, 218, 130, 39)
        buttonContinuePasswordChange.setTitle("Save", forState: .Normal)
        buttonContinuePasswordChange.addTarget(self, action: #selector(FaeAccountViewController.updatePasswordToBackEnd), forControlEvents: .TouchUpInside)
        popUpDialogView.addSubview(buttonContinuePasswordChange)
        
        popUpView.addSubview(popUpDialogView)
        
        //load textfield
        
        textPassword = PasswordTexField(frame: CGRectMake(81, 84, 230, 25))
        let passwordPlaceholder = NSAttributedString(string: "New Password", attributes: [NSForegroundColorAttributeName : UIColor.grayColor()])
        textPassword.attributedPlaceholder = passwordPlaceholder
        //        textPasswordAgain.textColor = ColorFae
        textPassword.font = UIFont(name: "AvenirNext-Regular", size: 18.0)
        popUpDialogView.addSubview(textPassword)
        
        textPasswordAgain = PasswordAgainTextField(frame: CGRectMake(81, 148, 230, 25))
        let passwordAgainPlaceholder = NSAttributedString(string: "Confirm Password", attributes: [NSForegroundColorAttributeName : UIColor.grayColor()])
        textPasswordAgain.attributedPlaceholder = passwordAgainPlaceholder;
        //        textPasswordAgain.textColor = ColorFae
        textPasswordAgain.font = UIFont(name: "AvenirNext-Regular", size: 18.0)
        popUpDialogView.addSubview(textPasswordAgain)
        
        //load inline view
        
        inLineViewPassword = UIView(frame: CGRectMake(35, 112, 280, 2))
        inLineViewPassword.layer.borderWidth = 1.0
        inLineViewPassword.layer.borderColor = UIColor.grayColor().CGColor
        popUpDialogView.addSubview(inLineViewPassword)
        
        inLineViewPasswordAgain = UIView(frame: CGRectMake(35, 176, 280, 2))
        inLineViewPasswordAgain.layer.borderWidth = 1.0
        inLineViewPasswordAgain.layer.borderColor = UIColor.grayColor().CGColor
        popUpDialogView.addSubview(inLineViewPasswordAgain)
        
        //load small icon
        
        imagePassword = UIImageView(frame: CGRectMake(43, 78.1, 16.8, 27.9))
        imagePassword.image = UIImage(named: "password_gray")
        popUpDialogView.addSubview(imagePassword)
        
        imagePasswordAgain = UIImageView(frame: CGRectMake(41, 144, 22.7, 26.2))
        imagePasswordAgain.image = UIImage(named: "conf_password_gray")
        popUpDialogView.addSubview(imagePasswordAgain)
        
        // load image view
        
        imageAlertView = UIImageView(frame: CGRectMake(301, 87, 7, 20))
        imageAlertView.image = UIImage(named: "Page 1")
        imageAlertView.hidden = true
        popUpDialogView.addSubview(imageAlertView)
        
        imageCheckPassword = UIImageView(frame: CGRectMake(298, 89, 15, 17))
        imageCheckPassword.image = UIImage(named: "check_yes")
        imageCheckPassword.layer.hidden = true
        popUpDialogView.addSubview(imageCheckPassword)
        
        imageCheckPasswordAgain = UIImageView(frame: CGRectMake(298, 153, 15, 17))
        imageCheckPasswordAgain.image = UIImage(named: "check_yes")
        imageCheckPasswordAgain.layer.hidden = true
        popUpDialogView.addSubview(imageCheckPasswordAgain)
        
        //load hint
        
        labelPasswordHint = UILabel(frame: CGRectMake(35, 115.5, 280, 15))
        labelPasswordHint.textAlignment = .Right
        labelPasswordHint.font = UIFont(name: "Helvetica Neue", size: 11)
        labelPasswordHint.layer.hidden = true
        popUpDialogView.addSubview(labelPasswordHint)
        
        //load callback
        
        textPassword.addTarget(self, action: #selector(FaeAccountViewController.passwordIsFocus), forControlEvents: .EditingDidBegin)
        textPassword.addTarget(self, action: #selector(FaeAccountViewController.passwordIsNotFocus), forControlEvents: .EditingDidEnd)
        textPassword.addTarget(self, action: #selector(FaeAccountViewController.passwordIsChanged), forControlEvents: .EditingChanged)
        
        textPasswordAgain.addTarget(self, action: #selector(FaeAccountViewController.passwordAgainIsFocus), forControlEvents: .EditingDidBegin)
        textPasswordAgain.addTarget(self, action: #selector(FaeAccountViewController.passwordAgainIsNotFocus), forControlEvents: .EditingDidEnd)
        textPasswordAgain.addTarget(self, action: #selector(FaeAccountViewController.passwordAgainIsChanged), forControlEvents: .EditingChanged)
    }
    
    func loadDot() {
        var xDistance : CGFloat = 63.0
        let paddingTop : CGFloat = 121.0
        let length : CGFloat = 13.0
        let height : CGFloat = 13.0
        let interval : CGFloat = 42.0
        for (var i = 0 ; i < 6 ; i += 1) {
            imageCodeDotArray.append(UIImageView(frame : CGRectMake(xDistance, paddingTop, length, height)))
            xDistance += interval
            imageCodeDotArray[i].image = UIImage(named: "verification_dot")
            popUpDialogView.addSubview(imageCodeDotArray[i]);
        }
    }
    
    func loadVerificaitonCode() {
        var xDistance : CGFloat = 55.0
        let length = 0.085 * screenWidth - 8
        let height = 0.1114 * screenHeight - 8
        let paddingTop : CGFloat = 94.0
        let interval : CGFloat = 42
        for (var i = 0 ; i < 6 ; i += 1) {
            textVerificationCode.append(UILabel(frame: CGRectMake(xDistance, paddingTop, length, height)))
            if(isIPhone5) {
                textVerificationCode[i].font = UIFont(name: "AvenirNext-Regular", size: 40)
            } else {
                textVerificationCode[i].font = UIFont(name: "AvenirNext-Regular", size: 50)
            }
            textVerificationCode[i].textColor = colorFae
            textVerificationCode[i].textAlignment = .Center
            let attributedString = NSMutableAttributedString(string: "\(i)")
            attributedString.addAttribute(NSKernAttributeName, value: CGFloat(-0.6), range: NSRange(location: 0, length: attributedString.length))
            
            textVerificationCode[i].attributedText = attributedString
            textVerificationCode[i].hidden = true
            xDistance += interval
            popUpDialogView.addSubview(textVerificationCode[i])
        }
    }
    
    func loadTextField() {
        self.view.addSubview(TextFieldDummy)
        TextFieldDummy.keyboardType = UIKeyboardType.NumberPad
        TextFieldDummy.addTarget(self, action: #selector(FaeAccountViewController.textFieldValueDidChanged(_:)), forControlEvents: UIControlEvents.EditingChanged)
        TextFieldDummy.becomeFirstResponder()
    }
    
    func processPWDChangeRequest() {
        print("Continue button clicked")
        if passwordIsCorrectFromBackEnd(textPassWordCheck.text!) {
            addSendCodeView()
        } else {
            labelDialogTital.removeFromSuperview()
            labelDialogTital = UILabel(frame: CGRect(x: 64.5, y: 30, width: 221, height: 21))
            let attributedString = NSMutableAttributedString(string: "Oops...Wrong Password!")
            attributedString.addAttribute(NSKernAttributeName, value: CGFloat(-0.3), range: NSRange(location: 0, length: attributedString.length))
            labelDialogTital.attributedText = attributedString
            labelDialogTital.font = UIFont(name: "Avenir Next", size: 20)
            labelDialogTital.textColor = UIColor(red: 107 / 255, green: 105 / 255, blue: 105 / 255, alpha: 1)
            labelDialogTital.textAlignment = .Center
            popUpDialogView.addSubview(labelDialogTital)
            passwordRetryChance -= 1
            if(passwordRetryChance == 0) {
                lockAccount()
                logOut()
            }
            //update text for button
            labelRetryHint.text = "\(passwordRetryChance) more tries left."
            labelRetryHint.hidden = false
        }
    }
    
    //MARK: Callback Function for password
    
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
        } else if (passwordVerification(textPassword.text!)){
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
        } else if (!passwordVerification(textPassword.text!)){
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
        textPasswordAgain.textColor = ColorFae
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
    
    func isValidPasswordAgain() -> Bool {
        if(textPasswordAgain.text != "" && textPassword != "") {
            return textPasswordAgain.text == textPassword.text
        } else {
            return false
        }
    }
    
    //MARK: password model
    
    func checkAllValidation() {
        if(passwordValidated && passwordAgainValidated) {
            enableButton(buttonContinuePasswordChange)
        } else {
            disableButton(buttonContinuePasswordChange)
        }
    }
    
    func update() {
        if(countDown > 0) {
            let title = "Resend Code \(countDown--)"
            buttonContinuePasswordChange.setTitle(title, forState: .Normal)
        } else {
            let title = "Resend Code"
            buttonContinuePasswordChange.setTitle(title, forState: .Normal)
            enableButton(buttonContinuePasswordChange)
        }
    }
    
    func textFieldValueDidChanged(textField: UITextField) {
        let buffer = textField.text!
        while(buffer.characters.count<index) {
            index -= 1;
            imageCodeDotArray[index].hidden = false
            textVerificationCode[index].hidden = true
            disableButton(buttonProceed)
        }
        if (buffer.characters.count > index) {
            if(buffer.characters.count >= 6) {
                enableButton(buttonProceed)
            }
            if(buffer.characters.count > 6) {
                let endIndex = buffer.startIndex.advancedBy(6)
                textField.text = buffer.substringToIndex(endIndex)
            } else {
                textVerificationCode[index].text = (String)(buffer[buffer.endIndex.predecessor()])
                imageCodeDotArray[index].hidden = true
                textVerificationCode[index].hidden = false;
                index += 1
            }
        }
        print(buffer)
    }
    
    func passwordFieldDidChange() {
        if textPassWordCheck.text?.characters.count == 0 {
            disableButton(buttonContinuePasswordChange)
        } else {
            enableButton(buttonContinuePasswordChange)
        }
    }
    
    func passwordIsCorrectFromBackEnd(password : String) -> Bool {
        return password == userPassword
    }
    
    func resendCode() {
        let user = FaeUser()
        user.whereKey("email", value: userEmail)
        user.sendCodeToEmail { (status, message) in
            if status / 100 == 2 {
                print("send code to email")
            }
        }
    }
    
    func lockAccount() {
        
    }
    
    func updateRetryTimeToBackEnd(time : Int) {
        
    }
    
    func loadRetryTimeFromBackEnd() -> Int {
        return 6
    }
    
    func unlockAccount() {
        
    }
    
    func sendCodeToEmail() {
        let user = FaeUser()
        user.whereKey("email", value: userEmail)
        user.sendCodeToEmail { (status, message) in
            if status / 100 == 2 {
                print("send code to email")
            }
        }
        disableButton(buttonContinuePasswordChange)
        countDown = 60
        addCodeView()
    }
    
    func processToNewPassword() {
        if compareCode() {
            TextFieldDummy.text = ""
            index = 0
            TextFieldDummy.removeFromSuperview()
            timer.invalidate()
            timer = nil
            countDown = 60
            textVerificationCode.removeAll()
            imageCodeDotArray.removeAll()
            addResetPasswordView()
            buttonProceed.removeFromSuperview()
        } else {
            labelDialogTital.frame = CGRectMake(45, 20, 260, 70)
            labelDialogTital.text = "Oops…That’s not the right\ncode. Please try again!"
        }
    }
    
    func getCurrentUserEmail() -> String {
        return userEmail
    }
    
    func convertEmailAddress(email : String) -> String {
        return email
    }
    
    func updatePasswordToBackEnd() {
        // doing update
        let user = FaeUser()
        user.whereKey("password", value: self.textPassword.text!)
        user.whereKey("code", value: TextFieldDummy.text!)
        user.whereKey("email", value: userEmail)
        user.changePassword { (status, message) in
            if status / 100 == 2 {
                print("password change correctly")
            }
        }
        cancelpopUpView()
    }
    // MARK:RetriveByEmailViewController is deleted
    func jumpToforgetPassword() {
        /*
        let vc = UIStoryboard(name: "Main", bundle: nil) .instantiateViewControllerWithIdentifier("RetriveByEmailViewController") as! RetriveByEmailViewController
        self.navigationController?.pushViewController(vc, animated: true)
 */
    }
    
    func compareCode() -> Bool {
        //compare if code is corrent form backend
        var validate = true
        let user = FaeUser()
        user.whereKey("email", value: userEmail)
        user.whereKey("code", value: TextFieldDummy.text!)
        
        user.validateCode { (status, message) in
            if status / 100 != 2 {
                validate = false
            }
        }
        
        return validate
    }
    
    func jumpTowelcomeVC() {
//        let vc = UIStoryboard(name: "Main", bundle: nil) .instantiateViewControllerWithIdentifier("WelcomeViewController") as! WelcomeViewController
//        self.presentViewController(vc, animated: true, completion: nil)
        let vc = UIStoryboard(name: "Main", bundle: nil) .instantiateViewControllerWithIdentifier("NavigationWelcomeViewController")as! NavigationWelcomeViewController
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
}

//MARK: change phone

extension FaeAccountViewController {
    
    func alreadyBindWithPhoneNumber() -> String {
        
        var phone = ""
        
        let user = FaeUser()
        user.getAccountBasicInfo { (status, message) in
            if userPhoneNumber != nil {
                phone = userPhoneNumber!
            }
        }
        
        return phone
    }
    
}

//MARK: support function

extension FaeAccountViewController {
    
    func preparePopUpView() {
        popUpView = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
        let buttonBackGround = UIButton(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
        buttonBackGround.backgroundColor = UIColor(red: 107 / 255, green: 105 / 255, blue: 105 / 255, alpha: 0.5)
        buttonBackGround.setTitle("", forState: .Normal)
        buttonBackGround.addTarget(self, action: #selector(FaeAccountViewController.cancelpopUpView), forControlEvents: .TouchUpInside)
        buttonBackGround.layer.zPosition = 20
        popUpView.addSubview(buttonBackGround)
    }
    
    func addCancelButton() {
        let buttonCancel = UIButton(frame: CGRect(x: 15, y: 15, width: 17, height: 17))
        buttonCancel.setImage(UIImage(named: "check_cross_red"), forState: .Normal)
        buttonCancel.addTarget(self, action: #selector(FaeAccountViewController.cancelpopUpView), forControlEvents: .TouchUpInside)
        popUpDialogView.addSubview(buttonCancel)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func cancelpopUpView() {
        popUpView.removeFromSuperview()
        if(buttonProceed != nil) {
            buttonProceed.removeFromSuperview()
        }
        TextFieldDummy.text = ""
        index = 0
        TextFieldDummy.removeFromSuperview()
        if(timer != nil) {
            timer.invalidate()
            timer = nil
        }
        countDown = 60
        textVerificationCode.removeAll()
        imageCodeDotArray.removeAll()
        passwordAgainValidated = false
        passwordValidated = false
    }
    
    func clearSubViewFor(view : UIView) {
        for subview in view.subviews {
            subview.removeFromSuperview()
        }
    }
    
    func disableButton(button : UIButton) {
        button.backgroundColor = colorDisableButton
        button.enabled = false
    }
    
    func enableButton(button : UIButton) {
        button.backgroundColor = colorFae
        button.enabled = true
    }
    
}


//MARK: Gender view
extension FaeAccountViewController{
    func initialGenderView(){
        let x : CGFloat = 32
        let y : CGFloat = 160
        viewGenderBackground = UIView(frame: CGRectMake(0,0,screenWidth,screenHeight))
        viewGenderBackground.backgroundColor = UIColor(colorLiteralRed: 107/255, green: 105/255, blue: 105/255, alpha: 0.5)
        
        buttonBackgroundCloseGender = UIButton(frame: CGRectMake(0,0,screenWidth,screenHeight))
        buttonBackgroundCloseGender.addTarget(self, action: "actionCloseGenderView", forControlEvents: .TouchUpInside)
        viewGenderBackground.addSubview(buttonBackgroundCloseGender)
        
        viewGender = UIView(frame: CGRectMake(x,y,350,228))
        viewGender.backgroundColor = UIColor.whiteColor()
        viewGender.layer.cornerRadius = 21
        viewGenderBackground.addSubview(viewGender)
        
        buttonCloseGender = UIButton(frame: CGRectMake(47-x,175-y,17,17))
        buttonCloseGender.setImage(UIImage(named: "accountCloseFirstLast"), forState: .Normal)
        buttonCloseGender.addTarget(self, action: "actionCloseGenderView", forControlEvents: .TouchUpInside)
        viewGender.addSubview(buttonCloseGender)
        
        labelTitleGender = UILabel(frame: CGRectMake(0,190-y,350,21))
        labelTitleGender.text = "Your Gender"
        labelTitleGender.font = UIFont(name: "AvenirNext-Medium", size: 20)
        labelTitleGender.textColor = UIColor(colorLiteralRed: 107/255, green: 105/255, blue: 105/255, alpha: 1)
        labelTitleGender.textAlignment = .Center
        viewGender.addSubview(labelTitleGender)
        
        buttonMale = UIButton(frame: CGRectMake(90-x,240-y,70,65))
        buttonMale.tag = 0
        buttonMale.addTarget(self, action: "genderImage:", forControlEvents: .TouchUpInside)
        viewGender.addSubview(buttonMale)
        
        buttonFemale = UIButton(frame: CGRectMake(267-x,240-y,58,65))
        buttonFemale.tag = 1
        buttonFemale.addTarget(self, action: "genderImage:", forControlEvents: .TouchUpInside)
        viewGender.addSubview(buttonFemale)
        if gender == 0 {
            buttonMale.sendActionsForControlEvents(.TouchUpInside)
        }else {
            buttonFemale.sendActionsForControlEvents(.TouchUpInside)
        }
        
        buttonSaveGender = UIButton(frame: CGRectMake(142-x,328-y,130,39))
        buttonSaveGender.backgroundColor = UIColor(colorLiteralRed: 249/255, green: 90/255, blue: 90/255, alpha: 1)
        buttonSaveGender.layer.cornerRadius = 7
        buttonSaveGender.setTitle("Save", forState: .Normal)
        buttonSaveGender.addTarget(self, action: "actionSaveGender", forControlEvents: .TouchUpInside)
        viewGender.addSubview(buttonSaveGender)
        
    }
    func genderImage(sender : UIButton){
        if sender.tag == 0 {//male
            buttonMale.setImage(UIImage(named: "male_selected"), forState: .Normal)
            buttonFemale.setImage(UIImage(named: "female_unselected"), forState: .Normal)
            gender = 0
        }else if sender.tag == 1{
            buttonMale.setImage(UIImage(named: "male_unselected"), forState: .Normal)
            buttonFemale.setImage(UIImage(named: "female_selected"), forState: .Normal)
            gender = 1
        }
    }
    //MARK : save gender
    func actionSaveGender(){
//        print(gender)
        var genderUpload = "male"
        if gender == 0 {//male
            genderUpload = "male"
        }else if gender == 1 {//female
            genderUpload = "female"
        }
        let user = FaeUser()
        user.whereKey("gender", value: genderUpload)
        user.updateAccountBasicInfo({(status:Int,message:AnyObject?)in
            if status / 100 == 2 {
                //success
                self.myTableView.reloadData()
                
            }
            else {
                
            }
        })
        actionCloseGenderView()
    }
    func actionCloseGenderView(){
        viewGenderBackground.removeFromSuperview()
    }
    func actionShowGenderView(){
        self.view.addSubview(viewGenderBackground)
    }
}
//MARK: birthday view
extension FaeAccountViewController {
    func initialBirthdayView(){
        let x : CGFloat = 32
        let y : CGFloat = 160
        viewBirthdayBackground = UIView(frame: CGRectMake(0,0,screenWidth,screenHeight))
        viewBirthdayBackground.backgroundColor = UIColor(colorLiteralRed: 107/255, green: 105/255, blue: 105/255, alpha: 0.5)
        
        buttonBackgroundCloseBirthday = UIButton(frame: CGRectMake(0,0,screenWidth,screenHeight))
        buttonBackgroundCloseBirthday.addTarget(self, action: "actionCloseBrithdayView", forControlEvents: .TouchUpInside)
        viewBirthdayBackground.addSubview(buttonBackgroundCloseBirthday)
        
        viewBirthday = UIView(frame: CGRectMake(32,160,350,208))
        viewBirthday.backgroundColor = UIColor.whiteColor()
        viewBirthday.layer.cornerRadius = 21
        viewBirthdayBackground.addSubview(viewBirthday)
        
        buttonCloseBirthday = UIButton(frame: CGRectMake(47-x,175-y,17,17))
        buttonCloseBirthday.setImage(UIImage(named: "accountCloseFirstLast"), forState: .Normal)
        buttonCloseBirthday.addTarget(self, action: "actionCloseBrithdayView", forControlEvents: .TouchUpInside)
        viewBirthday.addSubview(buttonCloseBirthday)
        
        labelTitleBirthday = UILabel(frame: CGRectMake(0,190-y,350,21))
        labelTitleBirthday.textAlignment = .Center
        labelTitleBirthday.text = "Your Birthday"
        labelTitleBirthday.font = UIFont(name: "AvenirNext-Medium", size: 20)
        labelTitleBirthday.textColor = UIColor(colorLiteralRed: 107/255, green: 105/255, blue: 105/255, alpha: 1)
        viewBirthday.addSubview(labelTitleBirthday)
        
        labelDataShowBirthday = UILabel(frame: CGRectMake(74-x,250-y,266,21))
        labelDataShowBirthday.textAlignment = .Center
        labelDataShowBirthday.textColor = colorGreyFae
        viewBirthday.addSubview(labelDataShowBirthday)
        
        viewUnderlineBirthday = UIView(frame: CGRectMake(74-x,273-y,266,2))
        viewUnderlineBirthday.backgroundColor = UIColor(colorLiteralRed: 182/255, green: 182/255, blue: 182/255, alpha: 1)
        viewBirthday.addSubview(viewUnderlineBirthday)
        
        buttonSaveBirthday = UIButton(frame: CGRectMake(142-x,308-y,130,39))
        buttonSaveBirthday.layer.cornerRadius = 7
        buttonSaveBirthday.backgroundColor = UIColor(colorLiteralRed: 249/255, green: 90/255, blue: 90/255, alpha: 1)
        buttonSaveBirthday.setTitle("Save", forState: .Normal)
        buttonSaveBirthday.addTarget(self, action: "actionSaveBirthday", forControlEvents: .TouchUpInside)
        viewBirthday.addSubview(buttonSaveBirthday)
        
        dataPickerBirthday = UIDatePicker(frame: CGRectMake(0,screenHeight-216,screenWidth,216))
        dataPickerBirthday.timeZone = NSTimeZone.localTimeZone()
        dataPickerBirthday.datePickerMode = UIDatePickerMode.Date
        dataPickerBirthday.backgroundColor = UIColor.whiteColor()
        dataPickerBirthday.addTarget(self, action: "handleDatePicker:", forControlEvents: .ValueChanged)
        viewBirthdayBackground.addSubview(dataPickerBirthday)
    }
    //MARK: save birthday to database
    func actionSaveBirthday(){
        //add code to save
        let dateGot = dataPickerBirthday.date
        print(dateGot)
        let dateString = timeToString(dateGot)
        let user = FaeUser()
        user.whereKey("birthday", value: dateString)
        user.updateAccountBasicInfo({(status:Int,message:AnyObject?)in
            if status / 100 == 2 {
                //success
                self.myTableView.reloadData()
            }
            else {
                
            }
        })
        
        actionCloseBrithdayView()
    }
    func handleDatePicker(sender: UIDatePicker) {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.LongStyle
        sender.maximumDate = NSDate()
        labelDataShowBirthday.text = dateFormatter.stringFromDate(sender.date)
    }
    func actionCloseBrithdayView(){
        viewBirthdayBackground.removeFromSuperview()
    }
    func showBirthdayView(){
        self.view.addSubview(viewBirthdayBackground)
    }
}
//MARK: firstname and lastname view
extension FaeAccountViewController {
    func initialFirstLastName(){
        let x : CGFloat = 32
        let y : CGFloat = 160
        viewFirstLastBackground = UIView(frame: CGRectMake(0,0,screenWidth,screenHeight))
        viewFirstLastBackground.backgroundColor = UIColor(colorLiteralRed: 107/255, green: 105/255, blue: 105/255, alpha: 0.5)
        
        buttonBackgroundClose = UIButton(frame: CGRectMake(0,0,screenWidth,screenHeight))
        buttonBackgroundClose.addTarget(self, action: "closeFirstLastView", forControlEvents: .TouchUpInside)
        viewFirstLastBackground.addSubview(buttonBackgroundClose)
        
        viewFirstAndLast = UIView(frame: CGRectMake(32,160,350,258))
        viewFirstAndLast.backgroundColor = UIColor.whiteColor()
        viewFirstAndLast.layer.cornerRadius = 21
        viewFirstLastBackground.addSubview(viewFirstAndLast)
        
        buttonCloseName = UIButton(frame: CGRectMake(47-x,175-y,17,17))
        buttonCloseName.setImage(UIImage(named: "accountCloseFirstLast"), forState: .Normal)
        buttonCloseName.addTarget(self, action: "closeFirstLastView", forControlEvents: .TouchUpInside)
        viewFirstAndLast.addSubview(buttonCloseName)
        
        labelTitleFirstLast = UILabel(frame: CGRectMake(0,190-y,350,21))
        labelTitleFirstLast.textAlignment = .Center
        labelTitleFirstLast.textColor = UIColor(colorLiteralRed: 107/255, green: 105/255, blue: 105/255, alpha: 1)
        viewFirstAndLast.addSubview(labelTitleFirstLast)
        
        labelDetailFirstLast = UILabel(frame: CGRectMake(76-x,223-y,262,54))
        labelDetailFirstLast.text = "Please enter your real name so its easier for your friends to find you! You can toggle to/not to show this name in Edit Profile."
        labelDetailFirstLast.textColor = UIColor(colorLiteralRed: 138/255, green: 138/255, blue: 138/255, alpha: 1)
        labelDetailFirstLast.font = UIFont(name: "AvenirNext-Medium", size: 13)
        labelDetailFirstLast.numberOfLines = 0
        viewFirstAndLast.addSubview(labelDetailFirstLast)
        
        textFieldFirstLast = UITextField(frame: CGRectMake(74-x,300-y,262,22))
        textFieldFirstLast.placeholder = "Please enter your name"
        textFieldFirstLast.textAlignment = .Center
        textFieldFirstLast.textColor = colorGreyFae
        viewFirstAndLast.addSubview(textFieldFirstLast)
        
        viewUnderlineName = UIView(frame: CGRectMake(74-x,323-y,266,2))
        viewUnderlineName.backgroundColor = UIColor(colorLiteralRed: 182/255, green: 182/255, blue: 182/255, alpha: 1)
//        viewUnderlineName.backgroundColor = UIColor.blackColor()
        viewFirstAndLast.addSubview(viewUnderlineName)
        
        buttonSaveName = UIButton(frame: CGRectMake(142-x,358-y,130,39))
        buttonSaveName.setTitle("Save", forState: .Normal)
//        buttonSaveName.tag = sender
        buttonSaveName.addTarget(self, action: "actionSaveFirstLastName:", forControlEvents: .TouchUpInside)
        buttonSaveName.backgroundColor = UIColor(colorLiteralRed: 249/255, green: 90/255, blue: 90/255, alpha: 1)
        buttonSaveName.layer.cornerRadius = 7
        viewFirstAndLast.addSubview(buttonSaveName)
        
    }
    // MARK: save first name and last name function
    func actionSaveFirstLastName(sender:UIButton){
        if let strInputName = textFieldFirstLast.text {
            let user = FaeUser()
            if sender.tag == 0 {//first name
                user.whereKey("first_name", value: strInputName)
            
            }else if sender.tag == 1 {//last name
                user.whereKey("last_name", value: strInputName)
            }
            user.updateAccountBasicInfo({(status:Int,message:AnyObject?)in
                if status / 100 == 2 {
                //success
                        self.myTableView.reloadData()
                }
                else {
                
                }
            })
        }
        self.closeFirstLastView()
    }
    func closeFirstLastView(){
        viewFirstLastBackground.removeFromSuperview()
    }
    func showFirstLastView(sender:Int){
        if sender == 0 {
            //first name
            labelTitleFirstLast.text = "Your First Name"
            buttonSaveName.tag = 0
        }else if sender == 1{
            //last name
            labelTitleFirstLast.text = "Your Last Name"
            buttonSaveName.tag = 1
        }
        textFieldFirstLast.placeholder = "Please enter your name"
        self.view.addSubview(viewFirstLastBackground)
    }
}

// MARK: tableview delegate and dataSource
extension FaeAccountViewController: UITableViewDelegate , UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return 11
        if section == 0 {
            return 4
        }
        if section == 1 {
            return 4
        }
        return 3
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellGeneralIdentifier)as! FaeAccountTableViewCell
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        cell.accessoryType = .DisclosureIndicator
        let cell2 = tableView.dequeueReusableCellWithIdentifier(cellTitleIdentifier)as! FaeAccountWithoutTableViewCell
//        cell.labelTitle.text = String(indexPath.row)
        //section 0
        if indexPath.section == 0 && indexPath.row  == 0 {
            cell.imageViewTitle.image = UIImage(named: "accountFirstLast")
            cell.labelTitle.text = "First name"
            cell.labelDetail.text = userFirstname
            return cell
        }
        if indexPath.section == 0 && indexPath.row  == 1 {
            cell.imageViewTitle.image = UIImage(named: "accountFirstLast")
            cell.labelTitle.text = "Last Name"
            cell.labelDetail.text = userLastname
            return cell
        }
        if indexPath.section == 0 && indexPath.row  == 2 {
            cell.imageViewTitle.image = UIImage(named: "accountBirthday")
            cell.labelTitle.text = "Birthday"
            cell.labelDetail.text = userBirthday
            return cell
        }
        if indexPath.section == 0 && indexPath.row  == 3 {
            cell.imageViewTitle.image = UIImage(named: "accountGender")
            cell.labelTitle.text = "Gender"
            if userGender == 0 {
                cell.labelDetail.text = "Male"
            }else {
                cell.labelDetail.text = "Female"
            }
            return cell
        }
        //section 1
        if indexPath.section == 1 && indexPath.row  == 0 {
            cell.imageViewTitle.image = UIImage(named: "accountEmail")
            cell.labelTitle.text = "Email"
            cell.labelDetail.text = userEmail
            return cell
        }
        if indexPath.section == 1 && indexPath.row  == 1 {
            cell.imageViewTitle.image = UIImage(named: "accountUsername")
            cell.labelTitle.text = "Username"
            cell.labelDetail.text = username
            return cell
        }
        if indexPath.section == 1 && indexPath.row  == 2 {
            cell.imageViewTitle.image = UIImage(named: "accountPhone")
            cell.labelTitle.text = "Phone"
            cell.labelDetail.text = userPhoneNumber
            return cell
        }
        if indexPath.section == 1 && indexPath.row  == 3 {
            cell2.imageViewTitle.image = UIImage(named: "accountChangePassword")
            cell2.labelTitle.text = "Change Password"
            return cell2
        }
        //section 2
        if indexPath.section == 2 && indexPath.row  == 0 {
            cell2.imageViewTitle.image = UIImage(named: "accountMyAccount")
            cell2.labelTitle.text = "My Account"
            return cell2

        }
        if indexPath.section == 2 && indexPath.row  == 1 {
            cell2.imageViewTitle.image = UIImage(named: "accountLogOut")
            cell2.labelTitle.text = "Log Out"
            return cell2

        }
        if indexPath.section == 2 && indexPath.row  == 2 {
            cell2.imageViewTitle.image = UIImage(named: "accountRequestCloseAccount")
            cell2.labelTitle.text = "Request Close Account"
            return cell2

        }
        
        return cell
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        section 0
        if indexPath.section == 0 && indexPath.row  == 0 {
            print(userFirstname)
            self.showFirstLastView(0)
        }
        if indexPath.section == 0 && indexPath.row  == 1 {
            self.showFirstLastView(1)
        }
        if indexPath.section == 0 && indexPath.row  == 2 {
            self.showBirthdayView()
        }
        if indexPath.section == 0 && indexPath.row  == 3 {
            self.actionShowGenderView()
        }
        //section 1
        if indexPath.section == 1 && indexPath.row  == 0 {
            self.jumpToAccountEmail()
        }
        if indexPath.section == 1 && indexPath.row  == 1 {
            
            jumpToUsername()
        }
        if indexPath.section == 1 && indexPath.row  == 2 {
            jumpToPhone()
        }
        if indexPath.section == 1 && indexPath.row  == 3 {
            addPasswordChangeView()
            
        }
        //section 2
        if indexPath.section == 2 && indexPath.row  == 0 {
//            cell.labelTitle.text = "My Account"
        }
        if indexPath.section == 2 && indexPath.row  == 1 {
            addLogOutView()
        }
        if indexPath.section == 2 && indexPath.row  == 2 {
//            cell.labelTitle.text = "Request Close Account"
        }

    }
}
