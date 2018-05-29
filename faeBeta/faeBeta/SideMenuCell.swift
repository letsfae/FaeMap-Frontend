//
//  LeftSlideWindowCell.swift
//  SetPicture
//
//  Created by Jacky on 12/17/16.
//  Copyright © 2016 Jacky. All rights reserved.
//

import UIKit

class SideMenuCell: UITableViewCell {
    
    var uiviewRedDot: UIView!
    var imgLeft: UIImageView!
    var lblMiddle: UILabel!
    var switchRight: UISwitch!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        loadItem()
        selectionStyle = .none
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func loadItem() {
        uiviewRedDot = UIView()
        uiviewRedDot.backgroundColor = UIColor._2499090()
        uiviewRedDot.layer.cornerRadius = 4
        addSubview(uiviewRedDot)
        addConstraintsWithFormat("H:|-10-[v0(8)]", options: [], views: uiviewRedDot)
        addConstraintsWithFormat("V:|-30-[v0(8)]", options: [], views: uiviewRedDot)
        uiviewRedDot.isHidden = true
        
        imgLeft = UIImageView()
        imgLeft.contentMode = .scaleAspectFill
        imgLeft.clipsToBounds = true
        addSubview(imgLeft)
        addConstraintsWithFormat("H:|-25-[v0(28)]", options: [], views: imgLeft)
        addConstraintsWithFormat("V:|-20-[v0(28)]", options: [], views: imgLeft)
        
        lblMiddle = UILabel()
        lblMiddle.font = UIFont(name: "AvenirNext-Medium", size: 18)
        lblMiddle.textColor = UIColor._898989()
        addSubview(lblMiddle)
        addConstraintsWithFormat("H:|-68-[v0(143.65)]", options: [], views: lblMiddle)
        addConstraintsWithFormat("V:|-21-[v0(28)]", options: [], views: lblMiddle)
        
        switchRight = UISwitch(frame: CGRect(x: 0, y: 0, width: 39, height: 23))
        switchRight.isHidden = true
        switchRight.isOn = false
        switchRight.onTintColor = UIColor._2499090()
        switchRight.transform = CGAffineTransform(scaleX: 39 / 51, y: 23 / 31)
        addSubview(switchRight)
        addConstraintsWithFormat("H:[v0(39)]-23-|", options: [], views: switchRight)
        addConstraintsWithFormat("V:|-20-[v0(23)]", options: [], views: switchRight)
    }
}
