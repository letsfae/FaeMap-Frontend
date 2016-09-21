//
//  PasswordAgainTextField.swift
//  faeBeta
//
//  Created by User on 5/17/16.
//  Copyright © 2016 fae. All rights reserved.
//

import Foundation
import UIKit

class PasswordAgainTextField : UITextField {
    
    var imageName = ""
    var rightButton : UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        rightButton = UIButton(frame: CGRectMake(0, 0, 15, 15))
        rightButton.setImage(UIImage(named: "check_eye_close_red")!, forState: UIControlState.Normal)
        imageName = "check_eye_close_red"
        self.secureTextEntry = true
        self.rightView = rightButton
        rightButton.addTarget(self, action: #selector(PasswordAgainTextField.rightButtonClicked), forControlEvents: UIControlEvents.TouchUpInside)
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
        } else if(imageName == "check_eye_open_red") {
            rightButton.setImage(UIImage(named: "check_eye_close_red")!, forState: UIControlState.Normal)
            imageName = "check_eye_close_red"
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
}