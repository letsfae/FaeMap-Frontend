//
//  MBPlacesCell.swift
//  FaeMapBoard
//
//  Created by vicky on 4/14/17.
//  Copyright © 2017 Yue. All rights reserved.
//

import UIKit

class MBPlacesCell: UITableViewCell {

    var imgPlaceIcon: UIImageView!
    var lblPlaceName: UILabel!
    var lblPlaceAddr: UILabel!
    var lblDistance: UILabel!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        let separatorView = UIView(frame: CGRect(x: 89.5, y: 89, width: screenWidth - 89.5, height: 1))
        separatorView.backgroundColor = UIColor.faeAppLineBetweenCellGrayColor()
        addSubview(separatorView)
        selectionStyle = .none
        loadCellContent()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func loadCellContent() {
        imgPlaceIcon = UIImageView(frame: CGRect(x: 20, y: 20, width: 50, height: 50))
        addSubview(imgPlaceIcon)
        imgPlaceIcon.contentMode = .scaleAspectFill
        
        lblPlaceName = UILabel()
        addSubview(lblPlaceName)
        lblPlaceName.font = UIFont(name: "AvenirNext-Medium", size: 16)
        lblPlaceName.textColor = UIColor.faeAppInputTextGrayColor()
        lblPlaceName.lineBreakMode = .byTruncatingTail
        addConstraintsWithFormat("H:|-93-[v0]-90-|", options: [], views: lblPlaceName)
        
        lblPlaceAddr = UILabel()
        addSubview(lblPlaceAddr)
        lblPlaceAddr.font = UIFont(name: "AvenirNext-Medium", size: 12)
        lblPlaceAddr.textColor = UIColor.faeAppInfoLabelGrayColor()
        lblPlaceAddr.lineBreakMode = .byTruncatingTail
        addConstraintsWithFormat("H:|-93-[v0]-90-|", options: [], views: lblPlaceAddr)
        addConstraintsWithFormat("V:|-26-[v0(22)]-1-[v1(16)]", options: [], views: lblPlaceName, lblPlaceAddr)
        
        lblDistance = UILabel()
        addSubview(lblDistance)
        lblDistance.font = UIFont(name: "AvenirNext-Medium", size: 16)
        lblDistance.textColor = UIColor.faeAppInputPlaceholderGrayColor()
        lblDistance.textAlignment = .right
        addConstraintsWithFormat("H:[v0(70)]-10-|", options: [], views: lblDistance)
        addConstraintsWithFormat("V:|-34-[v0(22)]", options: [], views: lblDistance)
    }
}
