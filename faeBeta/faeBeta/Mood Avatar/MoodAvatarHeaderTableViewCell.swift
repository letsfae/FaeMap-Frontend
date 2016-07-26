//
//  MoodAvatarHeaderTableViewCell.swift
//  faeBeta
//
//  Created by User on 7/14/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

class MoodAvatarHeaderTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var currentAvatarImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        titleLabel.font = UIFont(name: "AvenirNext-Medium", size: 18)
        titleLabel.text = "Current Map Avatar:"
        titleLabel.textColor = UIColor(red: 89 / 255, green: 89 / 255, blue: 89 / 255, alpha: 1.0)
        titleLabel.textAlignment = .Center
        currentAvatarImage.contentMode = .ScaleAspectFit
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
