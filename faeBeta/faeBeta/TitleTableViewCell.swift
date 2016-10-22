//
//  TitleTableViewCell.swift
//  faeBeta
//
//  Created by Yash on 18/08/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

class TitleTableViewCell: UITableViewCell {

    // MARK: - IBOutlet
    
    @IBOutlet weak var titleLabel: UILabel!
    
    // MARK: - Awake
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    // MARK: - Function
    
    func setTitleLabelText(titleText: String)  {
        titleLabel.text = titleText
    }
    
    // MARK: - Selection

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
