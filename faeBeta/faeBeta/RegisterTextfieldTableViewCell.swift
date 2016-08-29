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
    
    @IBOutlet weak var textfield: UITextField!
    @IBOutlet weak var showPasswordButton: UIButton!
    
    
    // MARK: - Variables
    
    var delegate: RegisterTextfieldProtocol?
    var indexPath: NSIndexPath!
    var isUsernameField = false
    var isCharacterLimit = false
    
    // MARK: - Awake
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    // MARK: - Functions
    
    func setPlaceholderLabelText(text: String, indexPath: NSIndexPath)  {
        textfield.attributedPlaceholder = NSAttributedString(string:"placeholder text", attributes: [NSForegroundColorAttributeName: UIColor.init(colorLiteralRed: 155/255.0, green: 155/255.0, blue: 155/255.0, alpha: 1.0)])
        textfield.placeholder = text
        self.indexPath = indexPath
    }
    
    func setTextFieldForPasswordConfiguration() {
        textfield.secureTextEntry = true
        showPasswordButton.hidden = false
    }
    
    func setCharacterLimit() {
        isCharacterLimit = true
    }
    
    func setTextFieldForUsernameConfiguration() {
        isUsernameField = true
    }
    
    func makeFirstResponder() {
        textfield.becomeFirstResponder()
    }
    
    func endAsResponder() {
        textfield.resignFirstResponder()
    }
    
    
    // MARK: - IBAction
    
    @IBAction func showPasswordButtonTapped(sender: AnyObject) {
        showPasswordButton.selected = !showPasswordButton.selected
        textfield.secureTextEntry = !showPasswordButton.selected
    }
    
    // MARK: - Selection Function
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

extension RegisterTextfieldTableViewCell: UITextFieldDelegate {
    
    @IBAction func textFieldDidChange(sender: AnyObject) {
        delegate?.textFieldDidChange(textfield.text!, indexPath: indexPath)
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        delegate?.textFieldDidBeginEditing(indexPath)
        if isUsernameField {
            textField.text = "@"
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        delegate?.textFieldShouldReturn(indexPath)
        return true
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        if isUsernameField {
            if textField.text?.characters.count == 0 && string != "@" {
                textField.text = "@\(string)"
                return false
            }
        }
        if isCharacterLimit {
            let newText = (textField.text! as NSString).stringByReplacingCharactersInRange(range, withString: string)
            let numberOfChars = newText.characters.count
            return numberOfChars < 16
        }

        return true
    }
    
}


