//
//  EmailTextField.swift
//  faeBeta
//
//  Created by User on 5/17/16.
//  Copyright © 2016 fae. All rights reserved.
//

import Foundation
import UIKit

class EmailTextField: UITextField {
    override init(frame: CGRect) {
        super.init(frame: frame)
        let btnClear = UIButton(frame: CGRect(x: 0, y: 0, width: 15, height: 15))
        btnClear.setImage(UIImage(named: "check_cross_red")!, for: UIControlState())
        self.rightView = btnClear
        self.keyboardType = .emailAddress
        btnClear.addTarget(self, action: #selector(EmailTextField.clearClicked), for: UIControlEvents.touchUpInside)
        self.clearButtonMode = UITextFieldViewMode.never
    }
    
    func clearClicked(_ sender:UIButton) {
        self.text = ""
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
}
