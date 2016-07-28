//
//  MoreVisibleTableViewCell.swift
//  faeBeta
//
//  Created by blesssecret on 7/21/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

class MoreVisibleTableViewCell: UITableViewCell {

    @IBOutlet weak var imageViewTitle: UIImageView!
    @IBOutlet weak var labelTitle: UILabel!
    
    @IBOutlet weak var switchInvisible: UISwitch!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        switchInvisible.transform = CGAffineTransformMakeScale(0.74, 0.74)
        switchInvisible.hidden = true
        switchInvisible.onTintColor = UIColor(colorLiteralRed: 249/255, green: 90/255, blue: 90/255, alpha: 1)
        labelTitle.font = UIFont(name: "AvenirNext-Medium", size: 18)
        labelTitle.textColor = UIColor(colorLiteralRed: 89/255, green: 89/255, blue: 89/255, alpha: 1.0)
        
        // default hidden
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
