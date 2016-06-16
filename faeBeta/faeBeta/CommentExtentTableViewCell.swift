//
//  CommentExtentTableViewCell.swift
//  faeBeta
//
//  Created by blesssecret on 6/16/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

class CommentExtentTableViewCell: UITableViewCell {

    @IBOutlet weak var imageViewAvatar: UIImageView!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var buttonExtend: UIButton!
    
    @IBOutlet weak var textViewComment: UITextView!
    @IBOutlet weak var labelDes: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
