//
//  RegisterTextfieldTableViewCell.swift
//  faeBeta
//
//  Created by Yash on 17/08/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

protocol RegisterTextfieldProtocol: class {
    func textFieldShouldReturn(_ indexPath: IndexPath)
    func textFieldDidBeginEditing(_ indexPath: IndexPath)
    func textFieldDidChange(_ text: String, indexPath: IndexPath)
}

class RegisterTextfieldTableViewCell: UITableViewCell {
    // MARK: - Properties
    var textfield: FAETextField!
    weak var delegate: RegisterTextfieldProtocol?
    var indexPath: IndexPath!
    var isUsernameField = false
    var isCharacterLimit = false
    var limitNumber: Int = Int.max
    
    // MARK: - init
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        loadContent()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func loadContent() {
        textfield = FAETextField(frame: CGRect(x: 15, y: 18 * screenHeightFactor, width: screenWidth - 30, height: 44))
        addSubview(textfield)
        textfield.delegate = self
        textfield.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged )
    }

    // MARK: - Helper methods
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
    
    func setLeftPlaceHolderDisplay(_ bool:Bool) {
        textfield.isUsernameTextField = bool
        self.setNeedsDisplay()
    }
    
    func setRightPlaceHolderDisplay(_ bool:Bool) {
        textfield.isSecureTextEntry = bool
        self.setNeedsDisplay()
    }
    
    func clearTextFiled() {
        textfield.text = ""
    }
    
    func updateTextColorAccordingToPassword(_ text:String) {
        if !textfield.isSecureTextEntry {
            return;
        }
        var count = 0
        for c in text {
            if c < "a" || c > "z" {
                count += 1
            }
        }
        
        switch count {
        case 0:
            textfield.defaultTextColor = UIColor(r: 251, g: 201, b: 64, alpha: 100)
        case 1:
            textfield.defaultTextColor = UIColor(r: 254, g: 171, b: 55, alpha: 100)
        default:
            textfield.defaultTextColor = UIColor._2499090()
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

// MARK: - UITextFieldDelegate
extension RegisterTextfieldTableViewCell: UITextFieldDelegate {
    @objc func textFieldDidChange(_ textField: UITextField) {
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
        if isUsernameField {
            let set = NSCharacterSet(charactersIn: "ABCDEFGHIJKLMONPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_-.").inverted
            let isValid = string.rangeOfCharacter(from: set) == nil
            if !isValid {
                return false
            }
        }
        let currentCharacterCount = textField.text?.count ?? 0
        if range.length + range.location > currentCharacterCount {
            return false
        }
        let newLength = currentCharacterCount + string.count - range.length
        return (newLength <= limitNumber) || (!isCharacterLimit)
    }
}
