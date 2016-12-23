//
//  LeftSlideWindowCell.swift
//  SetPicture
//
//  Created by Jacky on 12/17/16.
//  Copyright © 2016 Jacky. All rights reserved.
//

import UIKit

class LeftSlideWindowCell: UITableViewCell {
    
    var imageLeft: UIImageView!
    var labelMiddle: UILabel!
    var switchRight: UISwitch!

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        loadItem()
    }
    
    func loadItem() {
        imageLeft = UIImageView()
        imageLeft.contentMode = .scaleAspectFill
        imageLeft.clipsToBounds = true
        self.addSubview(imageLeft)
        self.addConstraintsWithFormat("H:|-25-[v0(28)]", options: [], views: imageLeft)
        self.addConstraintsWithFormat("V:|-20-[v0(28)]", options: [], views: imageLeft)

        labelMiddle = UILabel()
        labelMiddle.font = UIFont(name: "AvenirNext-Medium", size: 18)
        labelMiddle.textColor = UIColor(red: 89/255, green: 89/255, blue: 89/255, alpha:1)
        self.addSubview(labelMiddle)
        self.addConstraintsWithFormat("H:|-68-[v0(143.65)]", options: [], views: labelMiddle)
        self.addConstraintsWithFormat("V:|-21-[v0(28)]", options: [], views: labelMiddle)
        
        switchRight = UISwitch(frame: CGRect(x: 0, y: 0, width: 39, height: 23))
        switchRight.isHidden = true
        switchRight.isOn = false
        switchRight.onTintColor = UIColor(red: 249/255, green: 90/255, blue: 90/255, alpha: 1)
        switchRight.transform = CGAffineTransform(scaleX: 39/51, y: 23/31)
        self.addSubview(switchRight)
        self.addConstraintsWithFormat("H:[v0(39)]-23-|", options: [], views: switchRight)
        self.addConstraintsWithFormat("V:|-20-[v0(23)]", options: [], views: switchRight)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

}
