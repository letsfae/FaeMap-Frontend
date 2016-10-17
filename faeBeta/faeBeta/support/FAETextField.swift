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
    private var contentInset : CGFloat! = 30
    private var leftButton : UILabel!
    private var rightButton : UIButton!
    var rightPlaceHolderView: UIView!
    var leftPlaceHolderView:UIView!
    
    private var _defaultTextColor = UIColor.faeAppRedColor()
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
    
    override var secureTextEntry: Bool
    {
        set {
            super.secureTextEntry = newValue
            if newValue && rightButton == nil {
                setupPasswordTextField()
            }
        }
        get {
            return super.secureTextEntry
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
    
    private var _placeholder:String = ""
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
    
    private func setup()
    {
        self.autocorrectionType = .No
        self.textColor = UIColor.faeAppInputTextGrayColor()
        self.font = UIFont(name: "AvenirNext-Regular", size: 22.0)
        self.clearButtonMode = UITextFieldViewMode.Never
        self.contentHorizontalAlignment = .Center
        self.textAlignment = .Center
        self.tintColor = UIColor.faeAppRedColor()
        self.autocapitalizationType = .None
        rightPlaceHolderView = UIView(frame: CGRectMake(0, 0, contentInset, 30))
        leftPlaceHolderView = UIView(frame: CGRectMake(0, 0, contentInset, 30))
        self.rightView = rightPlaceHolderView
        self.rightViewMode = .WhileEditing
        self.leftView = leftPlaceHolderView
        self.leftViewMode = .Always
        self.clipsToBounds = true
        self.minimumFontSize = 18
    }
    
    private func setupPasswordTextField()
    {
        self.textColor = UIColor.faeAppRedColor()
        rightButton = UIButton(frame: CGRectMake(contentInset - 20, 5, 20, 20))
        rightButton.setImage(UIImage(named: "check_eye_close_red_new")!, forState: UIControlState.Normal)
        rightPlaceHolderView.addSubview(rightButton)

        rightButton.addTarget(self, action: #selector(FAETextField.rightButtonTapped), forControlEvents: UIControlEvents.TouchUpInside)

    }
    
    private func setupUsernameTextField()
    {
        leftButton = UILabel(frame: CGRectMake(contentInset - 20, 5, 20, 20))
        leftButton.attributedText = NSAttributedString(string: "@", attributes: [NSForegroundColorAttributeName: UIColor.faeAppInputPlaceholderGrayColor(), NSFontAttributeName:font!])
        leftPlaceHolderView.addSubview(leftButton)
    }
    
    func rightButtonTapped()
    {
        secureTextEntry = !secureTextEntry
        if secureTextEntry {
            rightButton.setImage(UIImage(named: "check_eye_close_red_new")!, forState: UIControlState.Normal)
            self.textColor = defaultTextColor
        }else{
            rightButton.setImage(UIImage(named: "check_eye_open_red_new")!, forState: UIControlState.Normal)
            self.textColor = UIColor.faeAppInputTextGrayColor()
        }
        
    }
    
    override func textRectForBounds(bounds: CGRect) -> CGRect {
        return CGRectInset(bounds, contentInset, 0)
    }
    override func editingRectForBounds(bounds: CGRect) -> CGRect {
        return textRectForBounds(bounds)
    }
}
