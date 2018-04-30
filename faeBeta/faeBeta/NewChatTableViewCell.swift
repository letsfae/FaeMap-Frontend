//
//  NewChatTableViewCell.swift
//  faeBeta
//
//  Created by Jichao Zhong on 8/18/17.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit

class NewChatTableViewCell: UITableViewCell {
    
    var imgAvatar: UIImageView!
    var lblNickName: UILabel!
    var lblUserName: UILabel!
    var imgStatus: UIImageView!
    var userID: Int = -1
    var statusSelected = false
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        imgAvatar = UIImageView()
        imgAvatar.image = #imageLiteral(resourceName: "avatarPlaceholder")
        imgAvatar.layer.cornerRadius = 25
        imgAvatar.layer.masksToBounds = true
        addSubview(imgAvatar)
        addConstraintsWithFormat("H:|-15-[v0(50)]", options: [], views: imgAvatar)
        addConstraintsWithFormat("V:|-12-[v0(50)]", options: [], views: imgAvatar)
        
        lblNickName = UILabel()
        lblNickName.textAlignment = .left
        lblNickName.textColor = UIColor._898989()
        lblNickName.font = UIFont(name: "AvenirNext-Medium", size: 18)
        addSubview(lblNickName)
        addConstraintsWithFormat("H:|-85-[v0(274)]", options: [], views: lblNickName)
        addConstraintsWithFormat("V:|-17-[v0(22)]", options: [], views: lblNickName)
        
        lblUserName = UILabel()
        lblUserName.textAlignment = .left
        lblUserName.textColor = UIColor._107105105()
        lblUserName.font = UIFont(name: "AvenirNext-Medium", size: 13)
        addSubview(lblUserName)
        addConstraintsWithFormat("H:|-85-[v0(274)]", options: [], views: lblUserName)
        addConstraintsWithFormat("V:|-38-[v0(20)]", options: [], views: lblUserName)
        
        imgStatus = UIImageView()
        imgStatus.image = #imageLiteral(resourceName: "status_unselected")
        imgStatus.layer.masksToBounds = true
        addSubview(imgStatus)
        addConstraintsWithFormat("H:[v0(20)]-17-|", options: [], views: imgStatus)
        addConstraintsWithFormat("V:|-27-[v0]-27-|", options: [], views: imgStatus)
        
        selectionStyle = .none
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


