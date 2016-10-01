//
//  NameCardShowTableViewCell.swift
//  faeBeta
//
//  Created by blesssecret on 9/23/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

class NameCardShowTableViewCell: UITableViewCell {

    @IBOutlet weak var labelShow: UILabel!
    
    @IBOutlet weak var switchOutlet: UISwitch!

    @IBAction func switchAction(sender: AnyObject) {
        
    }

    override func awakeFromNib() {
        super.awakeFromNib()
//        switchOutlet.on = false
        switchOutlet.tintColor = UIColor.redColor()
        switchOutlet.onTintColor = UIColor.redColor()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
