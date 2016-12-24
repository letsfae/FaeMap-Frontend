//
//  RegisterTextfieldTableViewCell.swift
//  faeBeta
//
//  Created by Yash on 17/08/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

protocol RegisterTextfieldProtocol {
    func textFieldShouldReturn(_ indexPath: IndexPath)
    func textFieldDidBeginEditing(_ indexPath: IndexPath)
    func textFieldDidChange(_ text: String, indexPath: IndexPath)
}

class RegisterTextfieldTableViewCell: UITableViewCell {
    
    // MARK: - IBOutlets
    
    var textfield: FAETextField!
    
    // MARK: - Variables
    
    var delegate: RegisterTextfieldProtocol?
    var indexPath: IndexPath!
    var isUsernameField = false
    var isCharacterLimit = false
    var limitNumber: Int = Int.max
    // MARK: - Awake
    
    override func awakeFromNib() {
        super.awakeFromNib()
        textfield = FAETextField(frame: CGRect(x: 15, y: self.contentView.frame.height / 2 - 17 ,width: self.contentView.frame.width - 30, height: 34))
        self.contentView.addSubview(textfield)
        textfield.delegate = self
        textfield.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for:.editingChanged )

        // Initialization code
    }

    override func layoutSubviews(){
        super.layoutSubviews()
        textfield.frame =  CGRect(x: 15, y: self.contentView.frame.height / 2 - 17 ,width: self.contentView.frame.width - 30, height: 34)

    }
    
    // MARK: - Functions
    
    func setPlaceholderLabelText(_ text: String, indexPath: IndexPath)  {
        textfield.placeholder = text
        self.indexPath = indexPath
    }
    
    func setTextFieldForPasswordConfiguration() {
        textfield.isSecureTextEntry = true
    }
    
    func setCharacterLimit(_ number:Int) {
        isCharacterLimit = true
        limitNumber = number
    }
    
    func setTextFieldForUsernameConfiguration() {
        isUsernameField = true
    }
    
    func setLeftPlaceHolderDisplay(_ bool:Bool){
        textfield.isUsernameTextField = bool
        self.setNeedsDisplay()
    }
    
    func setRightPlaceHolderDisplay(_ bool:Bool){
        textfield.isSecureTextEntry = bool
        self.setNeedsDisplay()
    }
    
    func updateTextColorAccordingToPassword(_ text:String){
        if(!textfield.isSecureTextEntry){
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
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

extension RegisterTextfieldTableViewCell: UITextFieldDelegate {
    
    func textFieldDidChange(_ textField: UITextField) {
        delegate?.textFieldDidChange(textfield.text!, indexPath: indexPath)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        delegate?.textFieldDidBeginEditing(indexPath)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        delegate?.textFieldShouldReturn(indexPath)
        return true
    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentCharacterCount = textField.text?.characters.count ?? 0
        if (range.length + range.location > currentCharacterCount){
            return false
        }
        let newLength = currentCharacterCount + string.characters.count - range.length
        return (newLength <= limitNumber) || (!isCharacterLimit)
    }
}


