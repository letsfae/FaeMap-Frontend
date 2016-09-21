//
//  PasswordTextField.swift
//  faeBeta
//
//  Created by User on 5/17/16.
//  Copyright © 2016 fae. All rights reserved.
//

import Foundation
import UIKit

class PasswordTexField : UITextField {
    
    var imageName = ""
    var rightButton : UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        rightButton = UIButton(frame: CGRectMake(0, 0, 15, 15))
        rightButton.setImage(UIImage(named: "check_eye_close_red")!, forState: UIControlState.Normal)
        imageName = "check_eye_close_red"
        self.secureTextEntry = true
        self.rightView = rightButton
        rightButton.addTarget(self, action: #selector(PasswordTexField.rightButtonClicked), forControlEvents: UIControlEvents.TouchUpInside)
        self.addTarget(self, action: #selector(PasswordTexField.decideButtonImage), forControlEvents: .EditingChanged)
        self.addTarget(self, action: #selector(PasswordTexField.decideButtonImage), forControlEvents: .EditingDidEnd)
        self.addTarget(self, action: #selector(PasswordTexField.decideButtonImage), forControlEvents: .EditingDidBegin)
        self.clearButtonMode = UITextFieldViewMode.Never
        //        self.rightViewMode = UITextFieldViewMode.WhileEditing
    }
    
    func rightButtonClicked(sender:UIButton)
    {
        self.secureTextEntry = !self.secureTextEntry
        self.font = UIFont(name: "AvenirNext-Regular", size: 18.0)
        if(imageName == "check_eye_close_red") {
            rightButton.setImage(UIImage(named: "check_eye_open_red")!, forState: UIControlState.Normal)
            imageName = "check_eye_open_red"
        } else if (imageName == "check_eye_open_red") {
            rightButton.setImage(UIImage(named: "check_eye_close_red")!, forState: UIControlState.Normal)
            imageName = "check_eye_close_red"
        } else if(imageName == "check_eye_close_yellow") {
            rightButton.setImage(UIImage(named: "check_eye_open_yellow")!, forState: UIControlState.Normal)
            imageName = "check_eye_open_yellow"
        } else if (imageName == "check_eye_open_yellow") {
            rightButton.setImage(UIImage(named: "check_eye_close_yellow")!, forState: UIControlState.Normal)
            imageName = "check_eye_close_yellow"
        } else if(imageName == "check_eye_close_orange") {
            rightButton.setImage(UIImage(named: "check_eye_open_orange")!, forState: UIControlState.Normal)
            imageName = "check_eye_open_orange"
        } else {
            rightButton.setImage(UIImage(named: "check_eye_close_orange")!, forState: UIControlState.Normal)
            imageName = "check_eye_close_orange"
        }
    }
    
    func decideButtonImage() {
        if(self.text?.characters.count < 8) {
            if(self.secureTextEntry) {
                rightButton.setImage(UIImage(named: "check_eye_close_yellow")!, forState: UIControlState.Normal)
                imageName = "check_eye_close_yellow"
            } else {
                rightButton.setImage(UIImage(named: "check_eye_open_yellow")!, forState: UIControlState.Normal)
                imageName = "check_eye_open_yellow"
            }
        } else if (isValidPassword(self.text!)) {
            if(self.secureTextEntry) {
                rightButton.setImage(UIImage(named: "check_eye_close_red")!, forState: UIControlState.Normal)
                imageName = "check_eye_close_red"
            } else {
                rightButton.setImage(UIImage(named: "check_eye_open_red")!, forState: UIControlState.Normal)
                imageName = "check_eye_open_red"
            }
        } else {
            if(self.secureTextEntry) {
                rightButton.setImage(UIImage(named: "check_eye_close_orange")!, forState: UIControlState.Normal)
                imageName = "check_eye_close_orange"
            } else {
                rightButton.setImage(UIImage(named: "check_eye_open_orange")!, forState: UIControlState.Normal)
                imageName = "check_eye_open_orange"
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
            if(uppercase + digit + symbol >= 2)  {
                return true
            }
        }
        return false
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
}