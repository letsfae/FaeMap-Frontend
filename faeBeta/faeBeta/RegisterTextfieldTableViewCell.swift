//
//  RegisterTextfieldTableViewCell.swift
//  faeBeta
//
//  Created by Yash on 17/08/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

protocol RegisterTextfieldProtocol {
    func textFieldShouldReturn(indexPath: NSIndexPath)
    func textFieldDidBeginEditing(indexPath: NSIndexPath)
    func textFieldDidChange(text: String, indexPath: NSIndexPath)
}

class RegisterTextfieldTableViewCell: UITableViewCell {
    
    // MARK: - IBOutlets
    
    var textfield: FAETextField!
    
    // MARK: - Variables
    
    var delegate: RegisterTextfieldProtocol?
    var indexPath: NSIndexPath!
    var isUsernameField = false
    var isCharacterLimit = false
    var limitNumber: Int = Int.max
    // MARK: - Awake
    
    override func awakeFromNib() {
        super.awakeFromNib()
        textfield = FAETextField(frame: CGRectMake(15, self.contentView.frame.height / 2 - 17 ,self.contentView.frame.width - 30, 34))
        self.contentView.addSubview(textfield)
        textfield.delegate = self
        textfield.addTarget(self, action: #selector(self.textFieldDidChange(_:)), forControlEvents:.EditingChanged )

        // Initialization code
    }

    override func layoutSubviews(){
        super.layoutSubviews()
        textfield.frame =  CGRectMake(15, self.contentView.frame.height / 2 - 17 ,self.contentView.frame.width - 30, 34)

    }
    
    // MARK: - Functions
    
    func setPlaceholderLabelText(text: String, indexPath: NSIndexPath)  {
        textfield.placeholder = text
        self.indexPath = indexPath
    }
    
    func setTextFieldForPasswordConfiguration() {
        textfield.secureTextEntry = true
    }
    
    func setCharacterLimit(number:Int) {
        isCharacterLimit = true
        limitNumber = number
    }
    
    func setTextFieldForUsernameConfiguration() {
        isUsernameField = true
    }
    
    func setLeftPlaceHolderDisplay(bool:Bool){
        textfield.isUsernameTextField = bool
        self.setNeedsDisplay()
    }
    
    func setRightPlaceHolderDisplay(bool:Bool){
        textfield.secureTextEntry = bool
        self.setNeedsDisplay()
    }
    
    func updateTextColorAccordingToPassword(text:String){
        if(!textfield.secureTextEntry){
            return;
        }
        
        var count = 0
        for c in text.characters{
            if c < "a" || c > "z" {
                count += 1
            }
        }
        
        switch count {
        case 0:
            textfield.defaultTextColor = UIColor.faeAppWeakPasswordYellowColor()
            break
        case 1:
            textfield.defaultTextColor = UIColor.faeAppOkPasswordOrangeColor()
            break
        default:
            textfield.defaultTextColor = UIColor.faeAppRedColor()
            break
        }
        
    }
    
    func makeFirstResponder() {
        textfield.becomeFirstResponder()
    }
    
    func endAsResponder() {
        textfield.resignFirstResponder()
    }
    
    // MARK: - Selection Function
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

extension RegisterTextfieldTableViewCell: UITextFieldDelegate {
    
    func textFieldDidChange(textField: UITextField) {
        delegate?.textFieldDidChange(textfield.text!, indexPath: indexPath)
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        delegate?.textFieldDidBeginEditing(indexPath)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        delegate?.textFieldShouldReturn(indexPath)
        return true
    }
    
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let currentCharacterCount = textField.text?.characters.count ?? 0
        if (range.length + range.location > currentCharacterCount){
            return false
        }
        let newLength = currentCharacterCount + string.characters.count - range.length
        return (newLength <= limitNumber) || (!isCharacterLimit)
    }
}


