//
//  PlacesListCell.swift
//  FaeContacts
//
//  Created by Wenjia on 7/15/17.
//  Copyright © 2017 Yue. All rights reserved.
//

import UIKit

class PlacesListCell: UITableViewCell {
    
    var imgPic: UIImageView!
    var lblUserName: UILabel!
    var lblAddress: UILabel!
    var bottomLine: UIView!
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        separatorInset = UIEdgeInsets.zero
        layoutMargins = UIEdgeInsets.zero
        selectionStyle = .none
        loadRecommendedCellContent()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func loadRecommendedCellContent() {
        imgPic = UIImageView()
        imgPic.frame = CGRect(x: 9, y: 5, width: 58, height: 58)
        imgPic.contentMode = .scaleAspectFill
        imgPic.clipsToBounds = true
        imgPic.backgroundColor = .white
        addSubview(imgPic)
        
        lblUserName = UILabel()
        lblUserName.textAlignment = .left
        lblUserName.lineBreakMode = .byTruncatingTail
        lblUserName.textColor = UIColor._898989()
        lblUserName.font = UIFont(name: "AvenirNext-Medium", size: 15)
        addSubview(lblUserName)
        addConstraintsWithFormat("H:|-86-[v0]-20-|", options: [], views: lblUserName)
        
        lblAddress = UILabel()
        lblAddress.textAlignment = .left
        lblAddress.lineBreakMode = .byTruncatingTail
        lblAddress.textColor = UIColor._107107107()
        lblAddress.font = UIFont(name: "AvenirNext-Medium", size: 12)
        addSubview(lblAddress)
        addConstraintsWithFormat("H:|-86-[v0]-20-|", options: [], views: lblAddress)
        addConstraintsWithFormat("V:|-16-[v0(20)]-0-[v1(16)]", options: [], views: lblUserName, lblAddress)
        
        bottomLine = UIView()
        bottomLine.backgroundColor = UIColor.faeAppNavBarBorderColor()
        addSubview(bottomLine)
        addConstraintsWithFormat("H:|-63-[v0]-0-|", options: [], views: bottomLine)
        addConstraintsWithFormat("V:[v0(1)]-0-|", options: [], views: bottomLine)
    }
    

}
