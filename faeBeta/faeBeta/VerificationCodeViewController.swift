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
    
    var TextHintView : UILabel!
    
    var ButtonResend : UIButton!
    var ButtonProceed : UIButton!
    
    var TextFieldDummy = UITextField(frame: CGRectZero)
    
    var imageCodeDotArray = [UIImageView!]()
    
    var textVerificationCode = [UILabel!]()
    
    var index : Int = 0
    
    var countDown : Int = 60
    
    let colorFae = UIColor(red: 249.0 / 255.0, green: 90.0 / 255.0, blue: 90.0 / 255.0, alpha: 1.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadButton()
        loadLabel()
        loadDot()
        loadTextField()
        loadVerificaitonCode()
        let timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("update"), userInfo: nil, repeats: true)
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadButton() {
        let spaceLeft = 0.138*screenWidth
        let height = 0.068*screenHeight
        let length = screenWidth - 2 * spaceLeft
        ButtonResend = UIButton(frame: CGRectMake(spaceLeft, 0.49*screenHeight, length, height))
        ButtonResend.backgroundColor = colorFae
        ButtonResend.setTitle("Resend Code 60", forState: .Normal)
        ButtonResend.layer.cornerRadius = 7
        ButtonResend.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 20.0)
        self.view.addSubview(ButtonResend)
        //        ButtonResend.enabled = false
        
        ButtonProceed = UIButton(frame: CGRectMake(spaceLeft, 0.58*screenHeight, length, height))
        ButtonProceed.backgroundColor = colorFae
        ButtonProceed.setTitle("Proceed", forState: .Normal)
        ButtonProceed.layer.cornerRadius = 7
        ButtonProceed.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 20.0)
        //        ButtonResend.enabled = false
        ButtonProceed.addTarget(self, action: "jumpToCreateNewPassword", forControlEvents: .TouchUpInside)
        self.view.addSubview(ButtonProceed)
    }
    
    func loadLabel() {
        TextHintView = UILabel(frame: CGRectMake(0, 0.114*screenHeight, screenWidth, 0.0625*screenHeight))
        TextHintView.text = "Enter the Code we just sent to your \n email to continue…"
        TextHintView.numberOfLines = 2
        TextHintView.textColor = UIColor(white: 155.0 / 255.0, alpha: 1.0)
        TextHintView.textAlignment = .Center
        TextHintView.font = UIFont(name: "SourceSansPro-Regular", size: 18.0)
        self.view.addSubview(TextHintView)
    }
    
    func loadDot() {
        var xDistance = 0.23 * screenWidth
        let paddingTop = 0.234 * screenHeight
        let length = 0.03*screenWidth
        let height = 0.017*screenHeight
        let interval = 0.1014 * screenWidth
        for (var i = 0 ; i < 6 ; i++) {
            imageCodeDotArray.append(UIImageView(frame : CGRectMake(xDistance, paddingTop, length, height)))
            xDistance += interval
            imageCodeDotArray[i].image = UIImage(named: "verification_dot")
            self.view.addSubview(imageCodeDotArray[i]);
        }
    }
    
    func textFieldValueDidChanged(textField: UITextField) {
        let buffer = textField.text!
        if(buffer.characters.count<index) {
            index--;
            imageCodeDotArray[index].hidden = false
            textVerificationCode[index].hidden = true
        } else if (buffer.characters.count > index) {
            if(buffer.characters.count > 6) {
                let endIndex = buffer.startIndex.advancedBy(6)
                textField.text = buffer.substringToIndex(endIndex)
            } else {
                textVerificationCode[index].text = (String)(buffer[buffer.endIndex.predecessor()])
                imageCodeDotArray[index].hidden = true
                textVerificationCode[index].hidden = false;
                index++
            }
        }
        print(index)
    }
    
    func loadVerificaitonCode() {
        var xDistance = 0.201 * screenWidth
        let length = 0.085 * screenWidth
        let height = 0.1114 * screenHeight
        let paddingTop = 0.18*screenHeight
        let interval = 0.102*screenWidth
        for (var i = 0 ; i < 6 ; i++) {
            textVerificationCode.append(UILabel(frame: CGRectMake(xDistance, paddingTop, length, height)))
            textVerificationCode[i].font = UIFont(name: "AvenirNext-Regular", size: 60)
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
        TextFieldDummy.addTarget(self, action: "textFieldValueDidChanged:", forControlEvents: UIControlEvents.EditingChanged)
        TextFieldDummy.becomeFirstResponder()
    }
    
    func update() {
        if(countDown > 0) {
            let title = "Resend Code \(countDown--)"
            ButtonResend.setTitle(title, forState: .Normal)
        } else {
            let title = "Resend Code"
            ButtonResend.setTitle(title, forState: .Normal)
        }
    }
    func jumpToCreateNewPassword(){
        let vc = UIStoryboard(name: "Main", bundle: nil) .instantiateViewControllerWithIdentifier("CreateNewPasswordViewController")as! CreateNewPasswordViewController
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
