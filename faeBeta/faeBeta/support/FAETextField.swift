//
//  FaeTextField.swift
//  faeBeta
//
//  Created by Huiyuan Ren on 16/8/21.
//  Copyright © 2016年 fae. All rights reserved.
//

import Foundation
import UIKit

class FAETextField: UITextField {
    // MARK: - Properties
    private var contentInset: CGFloat! = 30
    private var lblLeft: UILabel!
    private var btnRight: UIButton!
    var fontSize: CGFloat = 22
    var uiviewRightPlaceHolder: UIView!
    var uiviewLeftPlaceHolderView: UIView!
    
    var defaultTextColor = UIColor._2499090() {
        willSet {
            self.textColor = newValue
        }
    }
    
    var isUsernameTextField: Bool {
        set {
            if newValue && lblLeft == nil {
                setupUsernameTextField()
            }
        }
        get {
            return self.isUsernameTextField
        }
    }
    
    override var isSecureTextEntry: Bool {
        set {
            super.isSecureTextEntry = newValue
            if newValue && btnRight == nil {
                setupPasswordTextField()
            }
        }
        get {
            return super.isSecureTextEntry
        }
    }
    
    override var placeholder: String? {
        willSet {
            let font = UIFont(name: "AvenirNext-Regular", size: fontSize)
            self.attributedPlaceholder = NSAttributedString(string: newValue!, attributes: [NSAttributedStringKey.foregroundColor: UIColor._155155155(), NSAttributedStringKey.font:font!])
        }
    }
    
    // MARK: - init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        setup()
    }
    
    private func setup() {
        self.autocorrectionType = .no
        self.textColor = UIColor._898989()
        self.font = UIFont(name: "AvenirNext-Regular", size: fontSize)
        self.clearButtonMode = UITextFieldViewMode.never
        self.contentHorizontalAlignment = .center
        self.textAlignment = .center
        self.tintColor = UIColor._2499090()
        self.autocapitalizationType = .none
        uiviewRightPlaceHolder = UIView(frame: CGRect(x: 0, y: 0, width: contentInset, height: 40))
        uiviewLeftPlaceHolderView = UIView(frame: CGRect(x: 0, y: 0, width: contentInset, height: 40))
        self.rightView = uiviewRightPlaceHolder
        self.rightViewMode = .whileEditing
        self.leftView = uiviewLeftPlaceHolderView
        self.leftViewMode = .always
        self.clipsToBounds = true
        self.minimumFontSize = 18
    }
    
    // MARK: - Helper methods
    private func setupPasswordTextField() {
        self.textColor = UIColor._2499090()
        btnRight = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 40))
        btnRight.setImage(UIImage(named: "check_eye_close_red_new")!, for: UIControlState())
        uiviewRightPlaceHolder.addSubview(btnRight)
        btnRight.addTarget(self, action: #selector(rightButtonTapped), for: UIControlEvents.touchUpInside)
    }
    
    @objc private func rightButtonTapped() {
        isSecureTextEntry = !isSecureTextEntry
        if isSecureTextEntry {
            btnRight.setImage(UIImage(named: "check_eye_close_red_new")!, for: UIControlState())
            self.textColor = defaultTextColor
        } else {
            btnRight.setImage(UIImage(named: "check_eye_open_red_new")!, for: UIControlState())
            self.textColor = UIColor._898989()
        }
    }
    
    private func setupUsernameTextField() {
        lblLeft = UILabel(frame: CGRect(x: contentInset - 20, y: 5, width: 20, height: 20))
        lblLeft.attributedText = NSAttributedString(string: " ", attributes: [NSAttributedStringKey.foregroundColor: UIColor._155155155(), NSAttributedStringKey.font:font!])
        uiviewLeftPlaceHolderView.addSubview(lblLeft)
    }
    
    // MARK: - Override methods
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: contentInset, dy: 0)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return textRect(forBounds: bounds)
    }
}
