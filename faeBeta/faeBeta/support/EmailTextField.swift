//
//  EmailTextField.swift
//  faeBeta
//
//  Created by User on 5/17/16.
//  Copyright © 2016 fae. All rights reserved.
//

import Foundation
import UIKit

class EmailTextField : UITextField {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let clearButton = UIButton(frame: CGRectMake(0, 0, 15, 15))
        clearButton.setImage(UIImage(named: "check_cross_red")!, forState: UIControlState.Normal)
        
        self.rightView = clearButton
        self.keyboardType = .EmailAddress
        clearButton.addTarget(self, action: #selector(EmailTextField.clearClicked), forControlEvents: UIControlEvents.TouchUpInside)
        
        self.clearButtonMode = UITextFieldViewMode.Never
//        self.rightViewMode = UITextFieldViewMode.WhileEditing
    }
    
    func clearClicked(sender:UIButton)
    {
        self.text = ""
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
}
