//
//  NameCardAddCollectionViewCell.swift
//  faeBeta
//
//  Created by blesssecret on 7/22/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

class NameCardAddCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageViewTitle: UIImageView!
    
    override func awakeFromNib() {
        imageViewTitle.layer.cornerRadius = 10
        
        super.awakeFromNib()
        // Initialization code
    }

}
