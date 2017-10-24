//
//  SelectedFriendCollectionViewCell.swift
//  faeBeta
//
//  Created by Jichao Zhong on 10/9/17.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit

protocol CustomTextFieldDelegate: UITextFieldDelegate {
    func textFieldDidChange(_ textField: UITextField)
    func textFieldDidBeginEditing(_ textField: UITextField)
    func textFieldDidDelete(_ textField: UITextField)
}

protocol DeleteCellDelegate: NSObjectProtocol {
    func deleteIsTapped()
}

class SelectedFriendCollectionViewCell: UICollectionViewCell, UIKeyInput {
    var hasText: Bool {
        get {
            return boolSelected
        }
    }
    
    func insertText(_ text: String) {
        print("insert")
    }
    
    func deleteBackward() {
        print("delelte in select")
        deleteDelegate?.deleteIsTapped()
    }
    
    override var canBecomeFirstResponder: Bool {
        get {
            return true
        }
    }
    
    var lblSelected: UILabel!
    var boolSelected: Bool = false
    weak var deleteDelegate: DeleteCellDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        lblSelected = UILabel(frame: frame)
        lblSelected.textColor = UIColor._2499090()
        lblSelected.font = UIFont(name: "AvenirNext-Medium", size: 18)
        lblSelected.textAlignment = .center
        lblSelected.translatesAutoresizingMaskIntoConstraints = false
        addSubview(lblSelected)
        addConstraintsWithFormat("H:|-2-[v0]-2-|", options: [], views: lblSelected)
        addConstraintsWithFormat("V:|-0-[v0]-0-|", options: [], views: lblSelected)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func width() -> CGFloat {
        let size = lblSelected.text!.boundingRect(with: CGSize(width: CGFloat(MAXFLOAT), height: CGFloat(MAXFLOAT)), options: [], attributes: [NSFontAttributeName: UIFont(name: "AvenirNext-Medium", size: 18)!], context: nil).size
        return size.width
    }
    
    func setCellSelected(_ selected: Bool) {
        boolSelected = selected
        if selected {
            lblSelected.textColor = UIColor._95181245()
        } else {
            lblSelected.textColor = UIColor._2499090()
        }
    }
}

class TextFieldCollectionViewCell: UICollectionViewCell {
    var tfInput: CustomUITextField!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        tfInput = CustomUITextField(frame: frame)
        tfInput.text = ""
        tfInput.tintColor = UIColor._2499090()
        tfInput.font = UIFont(name: "AvenirNext-Medium", size: 18)
        tfInput.textColor = UIColor._898989()
        tfInput.backgroundColor = .white
        addSubview(tfInput)
        addConstraintsWithFormat("H:|-2-[v0]-2-|", options: [], views: tfInput)
        addConstraintsWithFormat("V:|-0-[v0]-0-|", options: [], views: tfInput)
        tfInput.translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class CustomUITextField: UITextField {
    
    weak var customDelegate: CustomTextFieldDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addTarget(self, action: #selector(changeDelegate(_:)), for: .editingChanged)
        addTarget(self, action: #selector(beginDelegate(_:)), for: .editingDidBegin)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func deleteBackward() {
        super.deleteBackward()
        customDelegate?.textFieldDidDelete(self)
    }
    
    @objc func changeDelegate(_ textField: UITextField) {
        customDelegate?.textFieldDidChange(textField)
    }
    
    @objc func beginDelegate(_ textField: UITextField) {
        customDelegate?.textFieldDidBeginEditing(textField)
    }
    
    /*override func becomeFirstResponder() -> Bool {
     let res = super.becomeFirstResponder()
     return res
     }*/
}
