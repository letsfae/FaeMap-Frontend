//
//  EnterCodeTableViewCell.swift
//  faeBeta
//
//  Created by Yash on 28/08/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

class EnterCodeTableViewCell: UITableViewCell {
    
    var textfield: UITextField!

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        loadContent()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func loadContent() {
        textfield = UITextField(frame: CGRect(x: 0, y: 0, width: 320, height: 79))
        textfield.center.x = screenWidth / 2
        textfield.textAlignment = .center
        textfield.textColor = UIColor._2499090()
        textfield.font = UIFont(name: "AvenirNext-Regular", size: 60)
        addSubview(textfield)
    }
    
    // MARK: - Functions
    func makeFirstResponder() {
        textfield.becomeFirstResponder()
    }
    
    func showText(_ text: String) {
        textfield.text = text
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
