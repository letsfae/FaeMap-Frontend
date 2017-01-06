//
//  FaeAccountWithoutTableViewCell.swift
//  faeBeta
//
//  Created by blesssecret on 7/3/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
class FaeAccountWithoutTableViewCell: UITableViewCell {

    @IBOutlet weak var imageViewTitle: UIImageView!
    @IBOutlet weak var labelTitle: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        labelTitle.textColor = UIColor(colorLiteralRed: 89/255, green: 89/255, blue: 89/255, alpha: 1)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
