//
//  PasswordAgainTextField.swift
//  faeBeta
//
//  Created by User on 5/17/16.
//  Copyright © 2016 fae. All rights reserved.
//

import Foundation
import UIKit

class PasswordAgainTextField: UITextField {
    
    var imageName = ""
    var btnRight : UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        btnRight = UIButton(frame: CGRect(x: 0, y: 0, width: 15, height: 15))
        btnRight.setImage(UIImage(named: "check_eye_close_red")!, for: UIControlState())
        imageName = "check_eye_close_red"
        self.isSecureTextEntry = true
        self.rightView = btnRight
        btnRight.addTarget(self, action: #selector(PasswordAgainTextField.rightButtonClicked), for: UIControlEvents.touchUpInside)
        self.clearButtonMode = UITextFieldViewMode.never
    }
    
    func rightButtonClicked(_ sender:UIButton) {
        self.isSecureTextEntry = !self.isSecureTextEntry
        self.font = UIFont(name: "AvenirNext-Regular", size: 18.0)
        if imageName == "check_eye_close_red" {
            btnRight.setImage(UIImage(named: "check_eye_open_red")!, for: UIControlState())
            imageName = "check_eye_open_red"
        } else if imageName == "check_eye_open_red" {
            btnRight.setImage(UIImage(named: "check_eye_close_red")!, for: UIControlState())
            imageName = "check_eye_close_red"
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
}
