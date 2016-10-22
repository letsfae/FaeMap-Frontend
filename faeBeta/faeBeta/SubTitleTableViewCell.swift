//
//  SubTitleTableViewCell.swift
//  faeBeta
//
//  Created by Yash on 22/08/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

class SubTitleTableViewCell: UITableViewCell {

    // MARK: - IBOutlets
    
    @IBOutlet weak var subTitleLabel: UILabel!
    
    // MARK: - Awake Function
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    // MARK: - Function

    func setSubTitleLabelText(subTitleLabelText: String)  {
        subTitleLabel.text = subTitleLabelText
    }
    
    // MARK: - Selection Function
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
