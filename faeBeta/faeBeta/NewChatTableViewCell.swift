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
    //var imgSeparator: UIImageView!
    var statusSelected = false
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        //backgroundColor = .green
        
        imgAvatar = UIImageView()
        imgAvatar.image = #imageLiteral(resourceName: "avatarPlaceholder")
        imgAvatar.layer.cornerRadius = 5
        imgAvatar.layer.masksToBounds = true
        addSubview(imgAvatar)
        addConstraintsWithFormat("H:|-15-[v0(50)]", options: [], views: imgAvatar)
        addConstraintsWithFormat("V:|-12-[v0(50)]", options: [], views: imgAvatar)
        
        lblNickName = UILabel()
        lblNickName.textAlignment = .left
        lblNickName.textColor = UIColor._107105105()
        lblNickName.font = UIFont(name: "AvenirNext-Medium", size: 18)
        addSubview(lblNickName)
        addConstraintsWithFormat("H:|-85-[v0(274)]", options: [], views: lblNickName)
        addConstraintsWithFormat("V:|-21-[v0(12)]", options: [], views: lblNickName)
        
        lblUserName = UILabel()
        lblUserName.textAlignment = .left
        lblUserName.textColor = UIColor._898989()
        lblUserName.font = UIFont(name: "AvenirNext-Medium", size: 13)
        addSubview(lblUserName)
        addConstraintsWithFormat("H:|-85-[v0(274)]", options: [], views: lblUserName)
        addConstraintsWithFormat("V:|-41-[v0(15)]", options: [], views: lblUserName)
        
        imgStatus = UIImageView()
        imgStatus.image = #imageLiteral(resourceName: "status_unselected")
        imgStatus.layer.masksToBounds = true
        addSubview(imgStatus)
        addConstraintsWithFormat("H:[v0(20)]-27-|", options: [], views: imgStatus)
        addConstraintsWithFormat("V:|-34-[v0(20)]", options: [], views: imgStatus)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
}


