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
    
    @IBOutlet weak var textfield: FAETextField!
    
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
        textfield.placeholder = text
        self.indexPath = indexPath
    }
    
    func setTextFieldForPasswordConfiguration() {
        textfield.secureTextEntry = true
    }
    
    func setCharacterLimit() {
        isCharacterLimit = true
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
        if(!textfield.secureTextEntry ){
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
    
    @IBAction func textFieldDidChange(sender: AnyObject) {
        delegate?.textFieldDidChange(textfield.text!, indexPath: indexPath)
//        if(isUsernameField){
//            let fixedHeight = textfield.frame.size.height
//            let fixedWidth = textfield.frame.size.width
//
//            textfield.sizeThatFits(CGSize(width: CGFloat.max, height: fixedHeight))
//            let newSize = textfield.sizeThatFits(CGSize(width: CGFloat.max, height: fixedHeight))
//            var newFrame = textfield.frame
//            newFrame.size = CGSize(width: min(newSize.width, fixedWidth), height: fixedHeight)
//            textfield.frame = newFrame;
//        }
        
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        delegate?.textFieldDidBeginEditing(indexPath)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        delegate?.textFieldShouldReturn(indexPath)
        return true
    }
}


