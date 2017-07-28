//
//  FaeRecommendedCell.swift
//  FaeContacts
//
//  Created by Justin He on 6/15/17.
//  Copyright © 2017 Yue. All rights reserved.
//

import UIKit

class FaeRecommendedCell: UITableViewCell {
    
    var imgAvatar: UIImageView!
    var lblUserName: UILabel!
    var lblUserSaying: UILabel!
    var lblUserRecommendReason: UILabel!
    var btnAddFriend: UIButton!
    var bottomLine: UIView!
    var hasAddFriend = false
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        separatorInset = UIEdgeInsets.zero
        layoutMargins = UIEdgeInsets.zero
        loadRecommendedCellContent()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func loadRecommendedCellContent() {
        imgAvatar = UIImageView()
        imgAvatar.frame = CGRect(x: 14, y: 12, width: 50, height: 50)
        imgAvatar.layer.cornerRadius = 25
        imgAvatar.contentMode = .scaleAspectFill
        imgAvatar.clipsToBounds = true
        imgAvatar.backgroundColor = .red
        addSubview(imgAvatar)
        
        lblUserName = UILabel()
        lblUserName.textAlignment = .left
        lblUserName.textColor = UIColor._898989()
        lblUserName.font = UIFont(name: "AvenirNext-Medium", size: 18)
        addSubview(lblUserName)
        addConstraintsWithFormat("H:|-86-[v0]-173-|", options: [], views: lblUserName)
        
        lblUserSaying = UILabel()
        lblUserSaying.textAlignment = .left
        lblUserSaying.textColor = UIColor.faeAppInputPlaceholderGrayColor()
        lblUserSaying.font = UIFont(name: "AvenirNext-Medium", size: 13)
        addSubview(lblUserSaying)
        addConstraintsWithFormat("H:|-86-[v0]-173-|", options: [], views: lblUserSaying)
        
        lblUserRecommendReason = UILabel()
        lblUserRecommendReason.textAlignment = .left
        lblUserRecommendReason.textColor = UIColor.faeAppInputPlaceholderGrayColor()
        lblUserRecommendReason.font = UIFont(name: "AvenirNext-DemiBoldItalic", size: 12)
        addSubview(lblUserRecommendReason)
        addConstraintsWithFormat("H:|-86-[v0]-173-|", options: [], views: lblUserRecommendReason)
        
        btnAddFriend = UIButton()
        btnAddFriend.setImage(#imageLiteral(resourceName: "addButton"), for: .normal)
        btnAddFriend.addTarget(self, action: #selector(self.changeButtonPic(_:)), for: .touchUpInside)
        addSubview(btnAddFriend)
        addConstraintsWithFormat("V:|-26-[v0(29)]", options: [], views: btnAddFriend)
        addConstraintsWithFormat("H:[v0(74)]-17-|", options: [], views: btnAddFriend)
        /* Joshua 06/16/17
         put every single constraint at the end of each component, it is ok to put contraints for a group of components
         */
        
        addConstraintsWithFormat("V:|-17-[v0(22)]-0-[v1(20)]-3-[v2(16)]", options: [], views: lblUserName, lblUserSaying, lblUserRecommendReason)
        
        bottomLine = UIView()
        bottomLine.backgroundColor = UIColor.faeAppNavBarBorderColor()
        addSubview(bottomLine)
        addConstraintsWithFormat("H:|-73-[v0]-0-|", options: [], views: bottomLine)
        addConstraintsWithFormat("V:[v0(1)]-0-|", options: [], views: bottomLine)
    }
    
    func changeButtonPic(_ sender: UIButton) {
        if !hasAddFriend {
            btnAddFriend.setImage(#imageLiteral(resourceName: "btnAdded"), for: .normal)
            hasAddFriend = true
        }
        else {
            btnAddFriend.setImage(#imageLiteral(resourceName: "addButton"), for: .normal)
            hasAddFriend = false
        }
    }
}
