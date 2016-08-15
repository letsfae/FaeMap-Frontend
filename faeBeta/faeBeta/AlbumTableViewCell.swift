//
//  AlbumTableViewCell.swift
//  quickChat
//
//  Created by User on 7/12/16.
//  Copyright © 2016 User. All rights reserved.
//

import UIKit

class AlbumTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleImageView: UIImageView!
    
    @IBOutlet weak var albumTitleLabel: UILabel!

    @IBOutlet weak var albumNumberLabel: UILabel!

    @IBOutlet weak var checkMarkImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        albumTitleLabel.textColor = UIColor(red: 89 / 255, green: 89 / 255, blue: 89 / 255, alpha: 1.0)
        albumNumberLabel.textColor = UIColor(red: 146 / 255, green: 146 / 255, blue: 146 / 255, alpha: 1.0)
        albumTitleLabel.font =  UIFont(name: "AvenirNext-Medium", size: 18.0)
        albumNumberLabel.font = UIFont(name: "AvenirNext-Medium", size: 15.0)
        
        checkMarkImage.image = UIImage(named: "albumTableCheckMark")
        titleImageView.contentMode = .ScaleAspectFill
        titleImageView.clipsToBounds = true
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setCheckMark(bool : Bool) {
        checkMarkImage.hidden = bool
    }
    
}
