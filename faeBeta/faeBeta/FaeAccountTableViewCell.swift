//
//  FaeAccountTableViewCell.swift
//  faeBeta
//
//  Created by blesssecret on 6/28/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

class FaeAccountTableViewCell: UITableViewCell {

    @IBOutlet weak var imageViewTitle: UIImageView!
    
    @IBOutlet weak var labelTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
