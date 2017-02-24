//
//  PDEmptyCell.swift
//  faeBeta
//
//  Created by Yue on 2/21/17.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit

class PDEmptyCell: UITableViewCell {

    var lblEmptyCommentArea: UILabel!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        loadCellContent()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func loadCellContent() {
        // frame: CGRect(x: 0, y: 0, width: screenWidth, height: 25)
        lblEmptyCommentArea = UILabel()
//        lblEmptyCommentArea.center.y = self.frame.size.height / 2
        lblEmptyCommentArea.text = "It’s empty around here, be the first to comment!"
        lblEmptyCommentArea.textColor = UIColor.faeAppInputPlaceholderGrayColor()
        lblEmptyCommentArea.textAlignment = .center
        lblEmptyCommentArea.font = UIFont(name: "AvenirNext-Medium", size: 16)
        self.addSubview(lblEmptyCommentArea)
        self.addConstraintsWithFormat("H:[v0(\(screenWidth))]", options: [], views: lblEmptyCommentArea)
        self.addConstraintsWithFormat("V:[v0(25)]", options: [], views: lblEmptyCommentArea)
        NSLayoutConstraint(item: lblEmptyCommentArea, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0).isActive = true
    }

}
