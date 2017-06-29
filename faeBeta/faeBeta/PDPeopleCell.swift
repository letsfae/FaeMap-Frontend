//
//  PDPeopleCell.swift
//  faeBeta
//
//  Created by Yue on 3/10/17.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit

class PDPeopleCell: UITableViewCell {
    
    var userId = 0
    var imgAvatar: FaeAvatarView!
    var lblDisplayName: UILabel!
    var lblUserName: UILabel!
    
    var uiviewGenderAge: FaeGenderView!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        separatorInset = UIEdgeInsets.zero
        layoutMargins = UIEdgeInsets.zero
        loadCellContent()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updatePrivacyUI(id: Int) {
        uiviewGenderAge.userId = id
        uiviewGenderAge.boolAlignLeft = false
        uiviewGenderAge.loadGenderAge(id: id) { (nikeName, userName, _) in
            self.lblDisplayName.text = nikeName
            self.lblUserName.text = "@"+userName
        }
        
        imgAvatar.userID = id
        imgAvatar.loadAvatar(id: id)
    }
    
    fileprivate func loadCellContent() {
        
        imgAvatar = FaeAvatarView(frame: CGRect(x: 15, y: 13, width: 50, height: 50))
        imgAvatar.layer.cornerRadius = 25
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
        
        uiviewGenderAge = FaeGenderView(frame: CGRect(x: screenWidth - 61, y: 13, width: 46, height: 18))
        addSubview(uiviewGenderAge)
    }
}
