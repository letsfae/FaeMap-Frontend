//
//  LocationListCell.swift
//  FaeContacts
//
//  Created by Wenjia on 7/19/17.
//  Copyright © 2017 Yue. All rights reserved.
//

import UIKit

class LocationListCell: UITableViewCell {
    
    var imgPic: UIImageView!
    var lblPlaceName: UILabel!
    //var lblAddress: UILabel!
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
        imgPic.frame = CGRect(x: 48, y: 17, width: 15, height: 15)
        imgPic.contentMode = .scaleAspectFill
        imgPic.clipsToBounds = true
        imgPic.backgroundColor = .white
        imgPic.image = #imageLiteral(resourceName: "mapSearchCurrentLocation")
        addSubview(imgPic)
        
        lblPlaceName = UILabel()
        lblPlaceName.textAlignment = .left
        lblPlaceName.lineBreakMode = .byTruncatingTail
        lblPlaceName.textColor = UIColor._898989()
        lblPlaceName.font = UIFont(name: "AvenirNext-Medium", size: 18)
        addSubview(lblPlaceName)
        addConstraintsWithFormat("H:|-86-[v0]-20-|", options: [], views: lblPlaceName)
        addConstraintsWithFormat("V:|-12-[v0]-12-|", options: [], views: lblPlaceName)
        
        bottomLine = UIView()
        bottomLine.backgroundColor = UIColor._200199204()
        addSubview(bottomLine)
        addConstraintsWithFormat("H:|-39-[v0]-39-|", options: [], views: bottomLine)
        addConstraintsWithFormat("V:[v0(1)]-0-|", options: [], views: bottomLine)
    }
    
    
}
