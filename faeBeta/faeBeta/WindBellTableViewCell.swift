//
//  WindBellTableViewCell.swift
//  faeBeta
//
//  Created by Yanxiang Wang on 16/7/25.
//  Copyright © 2016年 fae. All rights reserved.
//

import UIKit

class WindBellTableViewCell: UITableViewCell {

    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelContent: UILabel!
    @IBOutlet weak var labelTime: UILabel!
    @IBOutlet weak var viewCircle: UIView!
    override func awakeFromNib() {
        viewCircle.layer.cornerRadius = 6
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
