//
//  MPDCollectionViewCell.swift
//  faeBeta
//
//  Created by Yue on 12/3/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

class MPDCollectionViewCell: UICollectionViewCell {
    
    var media: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadCellItems()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func loadCellItems() {
        media = UIImageView(frame: CGRect(x: 0, y: 0, width: 95, height: 95))
        media.clipsToBounds = true
        media.layer.cornerRadius = 13.5
        media.contentMode = .scaleAspectFill
        self.addSubview(media)
    }
}