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
    
    var index : Int = 0
    
    var countDown : Int = 60
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadButton()
        loadLabel()
        loadDot()
        loadTextField()
        let timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("update"), userInfo: nil, repeats: true)
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadButton() {
        ButtonResend = UIButton(frame: CGRectMake(0.1377*screenWidth, 0.486*screenHeight, 0.7246*screenWidth, 0.068*screenHeight))
        ButtonResend.backgroundColor = UIColor(red: 249.0 / 255.0, green: 90.0 / 255.0, blue: 90.0 / 255.0, alpha: 1.0)
        ButtonResend.setTitle("Resend Code 60", forState: .Normal)
        ButtonResend.layer.cornerRadius = 7
        ButtonResend.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 20.0)
        self.view.addSubview(ButtonResend)
        //        ButtonResend.enabled = false
        
        ButtonProceed = UIButton(frame: CGRectMake(0.1377*screenWidth, 0.5815*screenHeight, 0.7246*screenWidth, 0.068*screenHeight))
        ButtonProceed.backgroundColor = UIColor(red: 249.0 / 255.0, green: 90.0 / 255.0, blue: 90.0 / 255.0, alpha: 1.0)
        ButtonProceed.setTitle("Proceed", forState: .Normal)
        ButtonProceed.layer.cornerRadius = 7
        ButtonProceed.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 20.0)
        //        ButtonResend.enabled = false
        self.view.addSubview(ButtonProceed)
        
        
    }
    
    func loadLabel() {
        TextHintView = UILabel(frame: CGRectMake(0, 0.1141*screenHeight, 1*screenWidth, 0.0625*screenHeight))
        TextHintView.text = "Enter the Code we just sent to your \n email to continue…"
        TextHintView.numberOfLines = 2
        TextHintView.textColor = UIColor(white: 155.0 / 255.0, alpha: 1.0)
        TextHintView.textAlignment = .Center
        TextHintView.font = UIFont(name: "SourceSansPro-Regular", size: 18.0)
        self.view.addSubview(TextHintView)
    }
    
    func loadDot() {
        var xDistance = 0.2488 * screenWidth
        for (var i = 0 ; i < 6 ; i++) {
            imageCodeDotArray.append(UIImageView(frame : CGRectMake( xDistance, 0.2337*screenHeight, 0.03*screenWidth, 0.017*screenHeight)))
            xDistance += 0.0942 * screenWidth
            imageCodeDotArray[i].image = UIImage(named: "verification_dot")
            self.view.addSubview(imageCodeDotArray[i]);
        }
    }
    
    func textFieldValueDidChanged(textField: UITextField) {
        let buffer = textField.text!
        if(buffer.characters.count<index) {
            index--;
            imageCodeDotArray[index].hidden = false
        } else if (buffer.characters.count > index) {
            if(buffer.characters.count > 6) {
                let endIndex = buffer.startIndex.advancedBy(6)
                textField.text = buffer.substringToIndex(endIndex)
            } else {
                imageCodeDotArray[index].hidden = true
                index++
            }
        }
        print(index)
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
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
