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
    //MARK: - Interface
    fileprivate var contentInset : CGFloat! = 30
    fileprivate var leftButton : UILabel!
    fileprivate var rightButton : UIButton!
    var rightPlaceHolderView: UIView!
    var leftPlaceHolderView:UIView!
    
    fileprivate var _defaultTextColor = UIColor.faeAppRedColor()
    var defaultTextColor: UIColor
    {
        get{
            return _defaultTextColor
        }
        set{
            _defaultTextColor = newValue
            self.textColor = newValue
        }
    }
    
    override var isSecureTextEntry: Bool
    {
        set {
            super.isSecureTextEntry = newValue
            if newValue && rightButton == nil {
                setupPasswordTextField()
            }
        }
        get {
            return super.isSecureTextEntry
        }
    }
    
    var isUsernameTextField: Bool{
        set{
            if newValue && leftButton == nil{
                setupUsernameTextField()
            }
        }
        get {
            return self.isUsernameTextField
        }
    }
    
    fileprivate var _placeholder:String = ""
    override var placeholder: String?
    {
        set{
            _placeholder = newValue!
            let font = UIFont(name: "AvenirNext-Regular", size: 22)
            self.attributedPlaceholder = NSAttributedString(string: newValue!, attributes: [NSForegroundColorAttributeName: UIColor.faeAppInputPlaceholderGrayColor(), NSFontAttributeName:font!])
        }
        get{
            return _placeholder
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        setup()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    fileprivate func setup()
    {
        self.autocorrectionType = .no
        self.textColor = UIColor.faeAppInputTextGrayColor()
        self.font = UIFont(name: "AvenirNext-Regular", size: 22.0)
        self.clearButtonMode = UITextFieldViewMode.never
        self.contentHorizontalAlignment = .center
        self.textAlignment = .center
        self.tintColor = UIColor.faeAppRedColor()
        self.autocapitalizationType = .none
        rightPlaceHolderView = UIView(frame: CGRect(x: 0, y: 0, width: contentInset, height: 30))
        leftPlaceHolderView = UIView(frame: CGRect(x: 0, y: 0, width: contentInset, height: 30))
        self.rightView = rightPlaceHolderView
        self.rightViewMode = .whileEditing
        self.leftView = leftPlaceHolderView
        self.leftViewMode = .always
        self.clipsToBounds = true
        self.minimumFontSize = 18
    }
    
    fileprivate func setupPasswordTextField()
    {
        self.textColor = UIColor.faeAppRedColor()
        rightButton = UIButton(frame: CGRect(x: contentInset - 25, y: 0, width: 30, height: 30))
        rightButton.setImage(UIImage(named: "check_eye_close_red_new")!, for: UIControlState())
        rightPlaceHolderView.addSubview(rightButton)

        rightButton.addTarget(self, action: #selector(FAETextField.rightButtonTapped), for: UIControlEvents.touchUpInside)

    }
    
    fileprivate func setupUsernameTextField()
    {
        leftButton = UILabel(frame: CGRect(x: contentInset - 20, y: 5, width: 20, height: 20))
        leftButton.attributedText = NSAttributedString(string: " ", attributes: [NSForegroundColorAttributeName: UIColor.faeAppInputPlaceholderGrayColor(), NSFontAttributeName:font!])
        leftPlaceHolderView.addSubview(leftButton)
    }
    
    func rightButtonTapped()
    {
        isSecureTextEntry = !isSecureTextEntry
        if isSecureTextEntry {
            rightButton.setImage(UIImage(named: "check_eye_close_red_new")!, for: UIControlState())
            self.textColor = defaultTextColor
        }else{
            rightButton.setImage(UIImage(named: "check_eye_open_red_new")!, for: UIControlState())
            self.textColor = UIColor.faeAppInputTextGrayColor()
        }
        
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: contentInset, dy: 0)
    }
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return textRect(forBounds: bounds)
    }
}
