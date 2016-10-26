//
//  MoodAvatarTableViewCell.swift
//  faeBeta
//
//  Created by User on 7/14/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

class MoodAvatarTableViewCell: UITableViewCell {
    
    let screenWidth = UIScreen.mainScreen().bounds.width
    let screenHeight = UIScreen.mainScreen().bounds.height
    
    var maleImage: UIImageView!
    var femaleImage: UIImageView!
    var maleRedBtn: UIImageView!
    var femaleRedBtn: UIImageView!
    var buttonLeft: UIButton!
    var buttonRight: UIButton!
    var labelAvatarDes: UILabel!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        loadAvatarItems()
    }
    
    func loadAvatarItems() {
        maleRedBtn = UIImageView()
        maleRedBtn.image = UIImage(named: "unselectedMoodButton")
        self.addSubview(maleRedBtn)
        self.addConstraintsWithFormat("H:|-15-[v0(20)]", options: [], views: maleRedBtn)
        self.addConstraintsWithFormat("V:[v0(20)]-20-|", options: [], views: maleRedBtn)
        
        femaleRedBtn = UIImageView()
        femaleRedBtn.image = UIImage(named: "unselectedMoodButton")
        self.addSubview(femaleRedBtn)
        self.addConstraintsWithFormat("H:[v0(20)]-15-|", options: [], views: femaleRedBtn)
        self.addConstraintsWithFormat("V:[v0(20)]-20-|", options: [], views: femaleRedBtn)
        
        maleImage = UIImageView()
        maleImage.image = UIImage(named: "")
        self.addSubview(maleImage)
        self.addConstraintsWithFormat("H:|-50-[v0(50)]", options: [], views: maleImage)
        self.addConstraintsWithFormat("V:[v0(50)]-5-|", options: [], views: maleImage)
        
        femaleImage = UIImageView()
        femaleImage.image = UIImage(named: "")
        self.addSubview(femaleImage)
        self.addConstraintsWithFormat("H:[v0(50)]-50-|", options: [], views: femaleImage)
        self.addConstraintsWithFormat("V:[v0(50)]-5-|", options: [], views: femaleImage)
        
        labelAvatarDes = UILabel()
        labelAvatarDes.font = UIFont(name: "AvenirNext-Medium", size: 18)
        labelAvatarDes.textColor = UIColor(red: 89/255, green: 89/255, blue: 89/255, alpha: 1.0)
        labelAvatarDes.textAlignment = .Center
        self.addSubview(labelAvatarDes)
        self.addConstraintsWithFormat("H:[v0(140)]", options: [], views: labelAvatarDes)
        self.addConstraintsWithFormat("V:[v0(25)]-17-|", options: [], views: labelAvatarDes)
        NSLayoutConstraint(item: labelAvatarDes, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1.0, constant: 0).active = true
        
        buttonLeft = UIButton()
        self.addSubview(buttonLeft)
        self.addConstraintsWithFormat("H:|-0-[v0(\(screenWidth/2))]", options: [], views: buttonLeft)
        self.addConstraintsWithFormat("V:[v0(60)]-0-|", options: [], views: buttonLeft)
        
        buttonRight = UIButton()
        self.addSubview(buttonRight)
        self.addConstraintsWithFormat("H:[v0(\(screenWidth/2))]-0-|", options: [], views: buttonRight)
        self.addConstraintsWithFormat("V:[v0(60)]-0-|", options: [], views: buttonRight)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
