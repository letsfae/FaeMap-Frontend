//
//  PDChatUserCell.swift
//  faeBeta
//
//  Created by Yue on 6/26/17.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit

class PDChatUserCell: UICollectionViewCell {
    
    var imgUser: FaeAvatarView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadCellItems()
        layer.cornerRadius = 25
        layer.borderColor = UIColor.faeAppRedColor().cgColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func loadCellItems() {
        imgUser = FaeAvatarView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        imgUser.layer.cornerRadius = 25
        imgUser.image = #imageLiteral(resourceName: "defaultMen")
        imgUser.clipsToBounds = true
        imgUser.contentMode = .scaleAspectFill
        addSubview(imgUser)
    }
    
    func setValueForCell(userId: Int) {
        imgUser.userID = userId
        imgUser.loadAvatar(id: userId)
    }
}
