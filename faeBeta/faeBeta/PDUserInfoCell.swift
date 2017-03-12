//
//  PDUserInfoCell.swift
//  faeBeta
//
//  Created by Yue on 3/10/17.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit

class PDUserInfoCell: UITableViewCell {
    
    var userId = 0
    var imgAvatar: UIImageView!
    var imgUserGender: UIImageView!
    var lblDisplayName: UILabel!
    var lblUserName: UILabel!
    var lblUserAge: UILabel!
    var uiviewUserGender: UIView!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.separatorInset = UIEdgeInsets.zero
        self.layoutMargins = UIEdgeInsets.zero
        loadCellContent()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateAvatarUI(isPinOwner: Bool) {
        if isPinOwner {
            imgAvatar.frame = CGRect(x: 13, y: 11, width: 52, height: 52)
            imgAvatar.layer.cornerRadius = 26
            imgAvatar.layer.borderWidth = 2
            imgAvatar.layer.borderColor = UIColor.faeAppRedColor().cgColor
        } else {
            imgAvatar.frame = CGRect(x: 15, y: 13, width: 50, height: 50)
            imgAvatar.layer.cornerRadius = 25
            imgAvatar.layer.borderWidth = 0
            imgAvatar.layer.borderColor = nil
        }
    }
    
    func updatePrivacyUI(showGender: Bool, gender: String, showAge: Bool, age: String) {
        if !showGender && !showAge {
            uiviewUserGender.isHidden = true
            imgUserGender.image = nil
        } else if showGender && showAge {
            uiviewUserGender.isHidden = false
            if gender == "male" {
                imgUserGender.image = #imageLiteral(resourceName: "userGenderMale")
                uiviewUserGender.backgroundColor = UIColor.maleBackgroundColor()
            } else if gender == "female" {
                imgUserGender.image = #imageLiteral(resourceName: "userGenderFemale")
                uiviewUserGender.backgroundColor = UIColor.femaleBackgroundColor()
            } else {
                imgUserGender.image = nil
            }
            lblUserAge.text = age
            lblUserAge.frame.size = lblUserAge.intrinsicContentSize
            uiviewUserGender.frame.size.width = 32 + lblUserAge.intrinsicContentSize.width
        } else if showAge && !showGender {
            uiviewUserGender.isHidden = false
            lblUserAge.text = age
            lblUserAge.frame.size = lblUserAge.intrinsicContentSize
            uiviewUserGender.frame.size.width = 17 + lblUserAge.intrinsicContentSize.width
            lblUserAge.frame.origin.x = 97
            imgUserGender.image = nil
            uiviewUserGender.backgroundColor = UIColor.faeAppShadowGrayColor()
        } else if showGender && !showAge {
            uiviewUserGender.isHidden = false
            if gender == "male" {
                imgUserGender.image = #imageLiteral(resourceName: "userGenderMale")
                uiviewUserGender.backgroundColor = UIColor.maleBackgroundColor()
            } else if gender == "female" {
                imgUserGender.image = #imageLiteral(resourceName: "userGenderFemale")
                uiviewUserGender.backgroundColor = UIColor.femaleBackgroundColor()
            } else {
                imgUserGender.image = nil
            }
            uiviewUserGender.frame.size.width = 28
            lblUserAge.text = nil
        }
        self.uiviewUserGender.frame.origin.x = screenWidth - 15 - self.uiviewUserGender.frame.size.width
    }
    
    fileprivate func loadCellContent() {
        
        imgAvatar = UIImageView()
        imgAvatar.contentMode = .scaleAspectFill
        imgAvatar.clipsToBounds = true
        addSubview(imgAvatar)
        
        lblDisplayName = UILabel()
        lblDisplayName.textAlignment = .left
        lblDisplayName.textColor = UIColor.faeAppInputTextGrayColor()
        lblDisplayName.font = UIFont(name: "AvenirNext-Medium", size: 18)
        addSubview(lblDisplayName)
        lblUserName = UILabel()
        lblUserName.textAlignment = .left
        lblUserName.textColor = UIColor.faeAppInputPlaceholderGrayColor()
        lblUserName.font = UIFont(name: "AvenirNext-Medium", size: 13)
        addSubview(lblUserName)
        addConstraintsWithFormat("H:|-80-[v0]-100-|", options: [], views: lblDisplayName)
        addConstraintsWithFormat("H:|-80-[v0]-100-|", options: [], views: lblUserName)
        addConstraintsWithFormat("V:|-17-[v0(25)]-0-[v1(18)]-17-|", options: [], views: lblDisplayName, lblUserName)
        lblDisplayName.text = "Holly Laura"
        lblUserName.text = "@hollylaura"
        
        uiviewUserGender = UIView(frame: CGRect(x: 0, y: 13, width: 46, height: 18))
        uiviewUserGender.backgroundColor = UIColor.maleBackgroundColor()
        uiviewUserGender.layer.cornerRadius = 9
        uiviewUserGender.clipsToBounds = true
        uiviewUserGender.isHidden = true
        addSubview(uiviewUserGender)
        imgUserGender = UIImageView(frame: CGRect(x: 9, y: 3, width: 10, height: 12))
        imgUserGender.contentMode = .scaleAspectFit
        imgUserGender.image = #imageLiteral(resourceName: "userGenderMale")
        uiviewUserGender.addSubview(imgUserGender)
        lblUserAge = UILabel(frame: CGRect(x: 25, y: 1, width: 16, height: 14))
        lblUserAge.textColor = UIColor.white
        lblUserAge.font = UIFont(name: "AvenirNext-Demibold", size: 13)
        uiviewUserGender.addSubview(lblUserAge)
        lblUserAge.text = "21"
    }
}
