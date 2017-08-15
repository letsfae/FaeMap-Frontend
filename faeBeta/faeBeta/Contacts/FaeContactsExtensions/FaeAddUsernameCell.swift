//
//  FaeAddUsernameCell.swift
//  FaeContacts
//
//  Created by Justin He on 6/20/17.
//  Copyright © 2017 Yue. All rights reserved.
//

import UIKit

class FaeAddUsernameCell: UITableViewCell {
    
    var imgAvatar: UIImageView!
    var lblUserName: UILabel!
    var lblUserSaying: UILabel!
    var bottomLine: UIView!
    var isFriend = false
    var hasAddedFriend = false
    var btnAddorAdded: UIButton! // btn that can substitute as the add button or the "added" button.
    
    init(style: UITableViewCellStyle, reuseIdentifier: String?, isFriend: Bool?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        separatorInset = UIEdgeInsets.zero
        layoutMargins = UIEdgeInsets.zero
        selectionStyle = .none
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
        lblUserSaying.textColor = UIColor._155155155()
        lblUserSaying.font = UIFont(name: "AvenirNext-Medium", size: 13)
        addSubview(lblUserSaying)
        addConstraintsWithFormat("H:|-86-[v0]-173-|", options: [], views: lblUserSaying)
        
        btnAddorAdded = UIButton()
        if isFriend {
            btnAddorAdded.setImage(#imageLiteral(resourceName: "addedButton"), for: .normal)
        }
        else {
            btnAddorAdded.setImage(#imageLiteral(resourceName: "addButton"), for: .normal)
            btnAddorAdded.addTarget(self, action: #selector(self.changeButtonPic(_:)), for: .touchUpInside)
        }
        addSubview(btnAddorAdded)
        addConstraintsWithFormat("V:|-26-[v0(29)]", options: [], views: btnAddorAdded)
        addConstraintsWithFormat("H:[v0(74)]-17-|", options: [], views: btnAddorAdded)
        
        addConstraintsWithFormat("V:|-17-[v0(22)]-0-[v1(20)]", options: [], views: lblUserName, lblUserSaying)
        
        bottomLine = UIView()
        bottomLine.backgroundColor = UIColor._200199204()
        addSubview(bottomLine)
        addConstraintsWithFormat("H:|-73-[v0]-0-|", options: [], views: bottomLine)
        addConstraintsWithFormat("V:[v0(1)]-0-|", options: [], views: bottomLine)
    }
    
    func changeButtonPic(_ sender: UIButton) {
        if !hasAddedFriend {
            btnAddorAdded.setImage(#imageLiteral(resourceName: "btnAdded"), for: .normal)
            hasAddedFriend = true
        }
        else {
            btnAddorAdded.setImage(#imageLiteral(resourceName: "addButton"), for: .normal)
            hasAddedFriend = false
        }
    }
}
