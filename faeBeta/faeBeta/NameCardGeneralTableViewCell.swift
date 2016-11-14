//
//  NameCardGeneralTableViewCell.swift
//  faeBeta
//
//  Created by blesssecret on 7/22/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

class NameCardGeneralTableViewCell: UITableViewCell {

    @IBOutlet weak var labelTitle: UILabel!
    
    @IBOutlet weak var labelDetail: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        labelTitle.textColor = UIColor(colorLiteralRed: 89/255, green: 89/255, blue: 89/255, alpha: 1)
        labelDetail.textColor = UIColor(colorLiteralRed: 155/255, green: 155/255, blue: 155/255, alpha: 1)
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
