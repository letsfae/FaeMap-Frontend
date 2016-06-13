//
//  CustomUIViewForScrollableTextField.swift
//  FaeMap
//
//  Created by Yue on 6/13/16.
//  Copyright © 2016 Yue. All rights reserved.
//

import UIKit

class CustomUIViewForScrollableTextField: UIView {
    var lineNumber: Int!
    var customTextField: UITextField!
    var customBorder: UIView!
    
    init() {
        super.init(frame: CGRect(x: 57, y: 396, width: 300, height: 50))
        lineNumber = 4
        loadCustomTextField()
        loadCustomBorder()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func loadCustomTextField() {
        customTextField = UITextField(frame: CGRectMake(7, 20, 291, 25))
        customTextField.font = UIFont(name: "AvenirNext-Regular", size: 18.0)
        customTextField.textColor = UIColor.whiteColor()
        customTextField.autocorrectionType = .No
        customTextField.autocapitalizationType = UITextAutocapitalizationType.None
        customTextField.textAlignment = .Center
        self.addSubview(customTextField)
    }
    
    func loadCustomBorder() {
        customBorder = UIView(frame: CGRectMake(0, 48, 300, 2))
        customBorder.layer.borderWidth = 300
        customBorder.layer.borderColor = UIColor.whiteColor().CGColor
        customBorder.layer.cornerRadius = 1.2
        self.addSubview(customBorder)
    }
}