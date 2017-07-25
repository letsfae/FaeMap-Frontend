//
//  FaeAddFriendOptionsCell.swift
//  FaeContacts
//
//  Created by Justin He on 6/15/17.
//  Copyright © 2017 Yue. All rights reserved.
//

import UIKit

class FaeAddFriendOptionsCell: UITableViewCell {
    
    var imgIcon: UIImageView!
    var lblOption: UILabel!
    var imgArrow: UIImageView!
    var bottomLine: UIView!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        separatorInset = UIEdgeInsets.zero
        layoutMargins = UIEdgeInsets.zero
        loadAddFriendOptionsCellContent()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func loadAddFriendOptionsCellContent() {
        imgIcon = UIImageView()
        imgIcon.frame = CGRect(x: 15, y: 12, width: 28, height: 28)
        imgIcon.contentMode = .scaleAspectFit
        addSubview(imgIcon)
        
        lblOption = UILabel()
        lblOption.textAlignment = .left
        lblOption.textColor = UIColor.faeAppInputTextGrayColor()
        lblOption.font = UIFont(name: "AvenirNext-Medium", size: 18)
        addSubview(lblOption)
        
        imgArrow = UIImageView()
        imgArrow.frame = CGRect(x: 389, y: 19, width: 8.57, height: 15)
        imgArrow.contentMode = .scaleAspectFit
        imgArrow.image = #imageLiteral(resourceName: "addFriendOptionArrowIcon")
        addSubview(imgArrow)
        
        bottomLine = UIView()
        bottomLine.backgroundColor = UIColor.faeAppNavBarBorderColor()
        addSubview(bottomLine)
        addConstraintsWithFormat("H:|-0-[v0]-0-|", options: [], views: bottomLine)
        addConstraintsWithFormat("V:[v0(1)]-0-|", options: [], views: bottomLine)

        
        /* Joshua 06/16/17
         put every single constraint at the end of each component, it is ok to put contraints for a group of components
         */
        addConstraintsWithFormat("H:|-63-[v0]-0-|", options: [], views: lblOption)
        addConstraintsWithFormat("V:|-0-[v0]-0-|", options: [], views: lblOption)
    }
}
