//
//  PasswordTextField.swift
//  faeBeta
//
//  Created by User on 5/17/16.
//  Copyright © 2016 fae. All rights reserved.
//

import Foundation
import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


class PasswordTexField : UITextField {
    
    var imageName = ""
    var rightButton : UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        rightButton = UIButton(frame: CGRect(x: 0, y: 0, width: 15, height: 15))
        rightButton.setImage(UIImage(named: "check_eye_close_red")!, for: UIControlState())
        imageName = "check_eye_close_red"
        self.isSecureTextEntry = true
        self.rightView = rightButton
        rightButton.addTarget(self, action: #selector(PasswordTexField.rightButtonClicked), for: UIControlEvents.touchUpInside)
        self.addTarget(self, action: #selector(PasswordTexField.decideButtonImage), for: .editingChanged)
        self.addTarget(self, action: #selector(PasswordTexField.decideButtonImage), for: .editingDidEnd)
        self.addTarget(self, action: #selector(PasswordTexField.decideButtonImage), for: .editingDidBegin)
        self.clearButtonMode = UITextFieldViewMode.never
        //        self.rightViewMode = UITextFieldViewMode.WhileEditing
    }
    
    func rightButtonClicked(_ sender:UIButton)
    {
        self.isSecureTextEntry = !self.isSecureTextEntry
        self.font = UIFont(name: "AvenirNext-Regular", size: 18.0)
        if(imageName == "check_eye_close_red") {
            rightButton.setImage(UIImage(named: "check_eye_open_red")!, for: UIControlState())
            imageName = "check_eye_open_red"
        } else if (imageName == "check_eye_open_red") {
            rightButton.setImage(UIImage(named: "check_eye_close_red")!, for: UIControlState())
            imageName = "check_eye_close_red"
        } else if(imageName == "check_eye_close_yellow") {
            rightButton.setImage(UIImage(named: "check_eye_open_yellow")!, for: UIControlState())
            imageName = "check_eye_open_yellow"
        } else if (imageName == "check_eye_open_yellow") {
            rightButton.setImage(UIImage(named: "check_eye_close_yellow")!, for: UIControlState())
            imageName = "check_eye_close_yellow"
        } else if(imageName == "check_eye_close_orange") {
            rightButton.setImage(UIImage(named: "check_eye_open_orange")!, for: UIControlState())
            imageName = "check_eye_open_orange"
        } else {
            rightButton.setImage(UIImage(named: "check_eye_close_orange")!, for: UIControlState())
            imageName = "check_eye_close_orange"
        }
    }
    
    func decideButtonImage() {
        if(self.text?.characters.count < 8) {
            if(self.isSecureTextEntry) {
                rightButton.setImage(UIImage(named: "check_eye_close_yellow")!, for: UIControlState())
                imageName = "check_eye_close_yellow"
            } else {
                rightButton.setImage(UIImage(named: "check_eye_open_yellow")!, for: UIControlState())
                imageName = "check_eye_open_yellow"
            }
        } else if (isValidPassword(self.text!)) {
            if(self.isSecureTextEntry) {
                rightButton.setImage(UIImage(named: "check_eye_close_red")!, for: UIControlState())
                imageName = "check_eye_close_red"
            } else {
                rightButton.setImage(UIImage(named: "check_eye_open_red")!, for: UIControlState())
                imageName = "check_eye_open_red"
            }
        } else {
            if(self.isSecureTextEntry) {
                rightButton.setImage(UIImage(named: "check_eye_close_orange")!, for: UIControlState())
                imageName = "check_eye_close_orange"
            } else {
                rightButton.setImage(UIImage(named: "check_eye_open_orange")!, for: UIControlState())
                imageName = "check_eye_open_orange"
            }
        }
    }
    
    func isValidPassword(_ testStr:String) -> Bool {
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
