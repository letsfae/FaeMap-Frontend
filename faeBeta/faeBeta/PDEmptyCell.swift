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
        self.separatorInset = UIEdgeInsetsMake(0, 500, 0, 0)
        loadCellContent()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func loadCellContent() {
        lblEmptyCommentArea = UILabel()
        lblEmptyCommentArea.numberOfLines = 2
        lblEmptyCommentArea.text = "It’s empty around here, be\nthe first to comment!"
        lblEmptyCommentArea.textColor = UIColor.faeAppInputPlaceholderGrayColor()
        lblEmptyCommentArea.textAlignment = .center
        lblEmptyCommentArea.font = UIFont(name: "AvenirNext-Medium", size: 16)
        self.addSubview(lblEmptyCommentArea)
        self.addConstraintsWithFormat("H:|-0-[v0]-0-|", options: [], views: lblEmptyCommentArea)
        self.addConstraintsWithFormat("V:|-38-[v0(44)]", options: [], views: lblEmptyCommentArea)
    }

}
