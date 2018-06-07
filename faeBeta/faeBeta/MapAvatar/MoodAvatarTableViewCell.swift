//
//  MoodAvatarTableViewCell.swift
//  faeBeta
//
//  Created by User on 7/14/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

protocol MoodAvatarCellDelegate: class {
    func changeAvatar(tag: Int)
}

class MoodAvatarTableViewCell: UITableViewCell {
    
    weak var delegate: MoodAvatarCellDelegate?
    
    var imgMale: UIImageView!
    var imgFemale: UIImageView!
    var maleRedBtn: UIImageView!
    var femaleRedBtn: UIImageView!
    var lblAvatarDes: UILabel!
    var btnLeft: UIButton!
    var btnRight: UIButton!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        separatorInset = UIEdgeInsetsMake(0, 500, 0, 0)
        loadAvatarItems()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func loadAvatarItems() {
        maleRedBtn = UIImageView()
        maleRedBtn.image = UIImage(named: "unselectedMoodButton")
        addSubview(maleRedBtn)
        addConstraintsWithFormat("H:|-15-[v0(20)]", options: [], views: maleRedBtn)
        addConstraintsWithFormat("V:[v0(20)]-20-|", options: [], views: maleRedBtn)
        
        femaleRedBtn = UIImageView()
        femaleRedBtn.image = UIImage(named: "unselectedMoodButton")
        addSubview(femaleRedBtn)
        addConstraintsWithFormat("H:[v0(20)]-15-|", options: [], views: femaleRedBtn)
        addConstraintsWithFormat("V:[v0(20)]-20-|", options: [], views: femaleRedBtn)
        
        imgMale = UIImageView()
        imgMale.image = UIImage(named: "")
        imgMale.contentMode = .scaleAspectFill
        addSubview(imgMale)
        addConstraintsWithFormat("H:|-50-[v0(54)]", options: [], views: imgMale)
        addConstraintsWithFormat("V:[v0(54)]-5-|", options: [], views: imgMale)
        
        imgFemale = UIImageView()
        imgFemale.image = UIImage(named: "")
        imgFemale.contentMode = .scaleAspectFill
        addSubview(imgFemale)
        addConstraintsWithFormat("H:[v0(50)]-54-|", options: [], views: imgFemale)
        addConstraintsWithFormat("V:[v0(54)]-5-|", options: [], views: imgFemale)
        
        lblAvatarDes = UILabel()
        lblAvatarDes.font = UIFont(name: "AvenirNext-Medium", size: 18)
        lblAvatarDes.textColor = UIColor(red: 89/255, green: 89/255, blue: 89/255, alpha: 1.0)
        lblAvatarDes.textAlignment = .center
        addSubview(lblAvatarDes)
        addConstraintsWithFormat("H:[v0(140)]", options: [], views: lblAvatarDes)
        addConstraintsWithFormat("V:[v0(25)]-17-|", options: [], views: lblAvatarDes)
        NSLayoutConstraint(item: lblAvatarDes, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0).isActive = true
        
        btnLeft = UIButton()
        addSubview(btnLeft)
        addConstraintsWithFormat("H:|-0-[v0(\(screenWidth/2))]", options: [], views: btnLeft)
        addConstraintsWithFormat("V:[v0(60)]-0-|", options: [], views: btnLeft)
        btnLeft.addTarget(self, action: #selector(changeAvatar(_:)), for: .touchUpInside)
        
        btnRight = UIButton()
        addSubview(btnRight)
        addConstraintsWithFormat("H:[v0(\(screenWidth/2))]-0-|", options: [], views: btnRight)
        addConstraintsWithFormat("V:[v0(60)]-0-|", options: [], views: btnRight)
        btnRight.addTarget(self, action: #selector(changeAvatar(_:)), for: .touchUpInside)
    }
    
    @objc private func changeAvatar(_ sender: UIButton) {
        delegate?.changeAvatar(tag: sender.tag)
    }
}
