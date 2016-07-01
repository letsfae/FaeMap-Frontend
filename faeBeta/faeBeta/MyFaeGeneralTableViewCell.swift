//
//  MyFaeGeneralTableViewCell.swift
//  faeBeta
//
//  Created by blesssecret on 6/23/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

class MyFaeGeneralTableViewCell: UITableViewCell {

    @IBOutlet weak var imageViewTitle: UIImageView!
    
    @IBOutlet weak var labelTitle: UILabel!
    
    @IBOutlet weak var imageViewStatus: UIImageView!
    
    @IBOutlet weak var labelStatus: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        labelStatus.text = ""
        labelTitle.textColor = UIColor(colorLiteralRed: 89/255, green: 89/255, blue: 89/255, alpha: 1)
        labelStatus.textColor = UIColor(colorLiteralRed: 89/255, green: 89/255, blue: 89/255, alpha: 1)
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
