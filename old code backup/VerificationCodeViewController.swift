//
//  VerificationCodeViewController.swift
//  faeBeta
//
//  Created by blesssecret on 5/12/16.
//  edited by mingjie jin
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

class VerificationCodeViewController: UIViewController, UITextFieldDelegate {
    
    let screenWidth = UIScreen.mainScreen().bounds.width
    let screenHeight = UIScreen.mainScreen().bounds.height
    
    let navigationBarOffset : CGFloat = 0
    
    var textHintView : UILabel!
    
    var buttonResend : UIButton!
    var buttonProceed : UIButton!
    
    var TextFieldDummy = UITextField(frame: CGRectZero)
    
    var imageCodeDotArray = [UIImageView!]()
    
    var textVerificationCode = [UILabel!]()
    
    var index : Int = 0
    
    var countDown : Int = 60
    
    let colorFae = UIColor(red: 249.0 / 255.0, green: 90.0 / 255.0, blue: 90.0 / 255.0, alpha: 1.0)
    
    let colorDisableButton = UIColor(red: 255.0 / 255.0, green: 160.0 / 255.0, blue: 160.0 / 255.0, alpha: 1.0)
    
    let isIPhone5 = UIScreen.mainScreen().bounds.size.height == 568
    
    var emailNeedToBeVerified = "000000"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadButton()
        loadLabel()
        loadDot()
        loadTextField()
        loadVerificaitonCode()
        print(isIPhone5)
        let timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(VerificationCodeViewController.update), userInfo: nil, repeats: true)
        self.navigationController?.navigationBar.tintColor = UIColor.redColor()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(named: "transparent"), forBarMetrics: UIBarMetrics.Default)
        //        self.navigationController?.navigationBar.translucent = false
        self.navigationController?.navigationBar.shadowImage = UIImage(named: "transparent")
        self.navigationController?.navigationBar.topItem?.title = ""
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadButton() {
        let spaceLeft = 0.138*screenWidth
        //let height = 0.068*screenHeight
        let height : CGFloat = 50
        let length = screenWidth - 2 * spaceLeft
        var yPosition = 0.49*screenHeight - navigationBarOffset
        if isIPhone5 {
            yPosition = 0.45*screenHeight - navigationBarOffset
        }
        buttonResend = UIButton(frame: CGRectMake(spaceLeft, yPosition, length, height))
        buttonResend.backgroundColor = colorFae
        buttonResend.setTitle("Resend Code 60", forState: .Normal)
        buttonResend.layer.cornerRadius = 7
        buttonResend.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 20.0)
        disableButton(buttonResend)
        buttonResend.addTarget(self, action: #selector(VerificationCodeViewController.resendButtonDidPressed), forControlEvents: .TouchUpInside)
        
        self.view.addSubview(buttonResend)
        
        buttonProceed = UIButton(frame: CGRectMake(spaceLeft, yPosition + 0.09 * screenHeight, length, height))
        buttonProceed.backgroundColor = colorFae
        buttonProceed.setTitle("Proceed", forState: .Normal)
        buttonProceed.layer.cornerRadius = 7
        buttonProceed.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 20.0)
        buttonProceed.addTarget(self, action: #selector(VerificationCodeViewController.compareVerificationCode), forControlEvents: .TouchUpInside)
        disableButton(buttonProceed)
        self.view.addSubview(buttonProceed)
    }
    
    func loadLabel() {
        var yPosition = 0.114*screenHeight - navigationBarOffset
        var height = 0.0625*screenHeight
        if isIPhone5 {
            yPosition = 0.1*screenHeight - navigationBarOffset
            height = 0.0765 * screenHeight
        }
        textHintView = UILabel(frame: CGRectMake(0, yPosition, screenWidth, height))
        textHintView.text = "Enter the Code we just sent to your \n email to continue…"
        textHintView.numberOfLines = 0
        textHintView.textColor = UIColor(white: 155.0 / 255.0, alpha: 1.0)
        textHintView.font = UIFont(name: "SourceSansPro-Regular", size: 20.0)
        textHintView.textAlignment = .Center
        self.view.addSubview(textHintView)
    }
    
    func loadDot() {
        var xDistance = 0.23 * screenWidth
        let paddingTop = 0.234 * screenHeight - navigationBarOffset
        let length = 0.03*screenWidth
        let height = 0.017*screenHeight
        let interval = 0.1014 * screenWidth
        for (var i = 0 ; i < 6 ; i += 1) {
            imageCodeDotArray.append(UIImageView(frame : CGRectMake(xDistance, paddingTop, length, height)))
            xDistance += interval
            imageCodeDotArray[i].image = UIImage(named: "verification_dot")
            self.view.addSubview(imageCodeDotArray[i]);
        }
    }
    
    func textFieldValueDidChanged(textField: UITextField) {
        let buffer = textField.text!
        if(buffer.characters.count<index) {
            index -= 1;
            imageCodeDotArray[index].hidden = false
            textVerificationCode[index].hidden = true
            disableButton(buttonProceed)
        } else if (buffer.characters.count > index) {
            if(buffer.characters.count >= 6 && !buttonProceed.enabled) {
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
        print(index)
    }
    
    func loadVerificaitonCode() {
        var xDistance = 0.201 * screenWidth
        let length = 0.085 * screenWidth
        let height = 0.1114 * screenHeight
        let paddingTop = 0.18*screenHeight - navigationBarOffset
        let interval = 0.102*screenWidth
        for (var i = 0 ; i < 6 ; i += 1) {
            textVerificationCode.append(UILabel(frame: CGRectMake(xDistance, paddingTop, length, height)))
            if(isIPhone5) {
                textVerificationCode[i].font = UIFont(name: "AvenirNext-Regular", size: 50)
            } else {
                textVerificationCode[i].font = UIFont(name: "AvenirNext-Regular", size: 60)
            }
            textVerificationCode[i].textColor = colorFae
            textVerificationCode[i].textAlignment = .Center
            let attributedString = NSMutableAttributedString(string: "\(i)")
            attributedString.addAttribute(NSKernAttributeName, value: CGFloat(-0.6), range: NSRange(location: 0, length: attributedString.length))
            
            textVerificationCode[i].attributedText = attributedString
            textVerificationCode[i].hidden = true
            xDistance += interval
            self.view.addSubview(textVerificationCode[i])
        }
    }
    
    func loadTextField() {
        self.view.addSubview(TextFieldDummy)
        TextFieldDummy.keyboardType = UIKeyboardType.NumberPad
        TextFieldDummy.addTarget(self, action: #selector(VerificationCodeViewController.textFieldValueDidChanged(_:)), forControlEvents: UIControlEvents.EditingChanged)
        TextFieldDummy.becomeFirstResponder()
    }
    
    func update() {
        if(countDown > 0) {
            let title = "Resend Code \(countDown--)"
            buttonResend.setTitle(title, forState: .Normal)
        } else {
            let title = "Resend Code"
            buttonResend.setTitle(title, forState: .Normal)
            enableButton(buttonResend)
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
    
    func resendButtonDidPressed() {
        disableButton(buttonResend)
        countDown = 60
        // other resent email behavior
        sendCodeToEmailAgain(emailNeedToBeVerified)
        disableButton(buttonProceed)
    }
    
    func compareVerificationCode() {
        if let input = TextFieldDummy.text {
            verifyCode(input, email: emailNeedToBeVerified)
        }
    }
    
    func verifyCode(input : String, email : String){
        let user = FaeUser()
        user.whereKey("email", value: email)
        user.whereKey("code", value: input)
        user.validateCode{ (status:Int?, message:AnyObject?) in
            if ( status! / 100 == 2 ){
                //success
                let vc = UIStoryboard(name: "Main", bundle: nil) .instantiateViewControllerWithIdentifier("CreateNewPasswordViewController")as! CreateNewPasswordViewController
                vc.emailNeedToBeVerified = self.emailNeedToBeVerified
                vc.codeForVerification = input
                self.navigationController?.pushViewController(vc, animated: true)
            }
            else{
                //failure
                self.textHintView.text = "That’s an incorrect Code!\nPlease try again!"
            }
        }
    }
    
    func sendCodeToEmailAgain(email : String){
        let user = FaeUser()
        user.whereKey("email", value: email)
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
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
