//
//  ChatTableViewCell.swift
//  iPark
//
//  Created by blesssecret on 9/13/15.
//  Copyright (c) 2015 carryof. All rights reserved.
//

import UIKit

class ChatTableViewCell: UITableViewCell {

    @IBOutlet weak var imageViewProfile: UIImageView!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelDetail: UILabel!
    @IBOutlet weak var viewNewMessage: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        viewNewMessage.layer.cornerRadius = 14/2
        viewNewMessage.backgroundColor=UIColor.clearColor()
        
        
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
