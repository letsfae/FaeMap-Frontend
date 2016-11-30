//
//  CreatePinOptionsTableViewCell.swift
//  faeBeta
//
//  Created by YAYUAN SHI on 11/29/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

class CreatePinOptionsTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var leadingIconImageView: UIImageView!
    
    @IBOutlet weak var trailingLabel: UILabel!
    @IBOutlet weak var trailingIconImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor.clear
        // Initialization code
    }

    func setupCell(withTitle title: String?, leadingIcon: UIImage?, trailingText: String?, trailingIcon: UIImage?)
    {
        titleLabel.text = title
        leadingIconImageView.image = leadingIcon
        trailingLabel.text = trailingText
        trailingIconImageView.image = trailingIcon
    }
    
    
    
}
