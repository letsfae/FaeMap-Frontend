//
//  CommentExtentTableViewCell.swift
//  faeBeta
//
//  Created by blesssecret on 9/9/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

class CommentPinListCell: UIView {
    
    var imageViewAvatar: UIImageView!
    
    var content: UILabel!
    var time: UILabel!
    
    var deleteButton: UIButton!
    var jumpToDetail: UIButton!
    
    var underLine: UIView!
    
    var cellY: CGFloat = 0
    
    let screenWidth = UIScreen.mainScreen().bounds.width
    
    var commentID: Int = -999
    
    var userID: String = "NULL"
    
    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 76))
        loadAvatar()
        loadLabel()
        loadUnderLine()
        loadButton()
        loadBackground()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func loadAvatar() {
        imageViewAvatar = UIImageView(frame: CGRect(x: 14, y: 13, width: 50, height: 50))
        imageViewAvatar.image = UIImage(named: "avatar_expand_no")
        self.addSubview(imageViewAvatar)
        imageViewAvatar.layer.masksToBounds = true
    }
    
    func loadLabel() {
        content = UILabel(frame: CGRect(x: 80, y: 17, width: 250, height: 25))
        self.addSubview(content)
        content.font = UIFont(name: "AvenirNext-Regular", size: 18.0)
        content.text = "Content"
        content.textColor = UIColor(red: 89/255, green: 89/255, blue: 89/255, alpha: 1.0)
        
        time = UILabel(frame: CGRect(x: 80, y: 41, width: 130, height: 18))
        self.addSubview(time)
        time.font = UIFont(name: "AvenirNext-Medium", size: 13.0)
        time.text = "September 23, 2016"
        time.textColor = UIColor(red: 155/255, green: 155/255, blue: 155/255, alpha: 1.0)
    }
    
    func loadButton() {
        deleteButton = UIButton(frame: CGRect(x: 341, y: 14, width: 100, height: 48))
        let imageDelete = UIImage(named: "comment_pin_delete")
        deleteButton.setImage(imageDelete, forState: .Normal)
        self.addSubview(deleteButton)
        
        jumpToDetail = UIButton(frame: CGRect(x: 0, y: 3, width: 341, height: 70))
        self.addSubview(jumpToDetail)
    }
    
    func loadUnderLine() {
        underLine = UIView(frame: CGRectMake(0, 75, screenWidth, 1))
        underLine.layer.borderWidth = screenWidth
        underLine.layer.borderColor = UIColor(red: 182/255, green: 182/255, blue: 182/255, alpha: 1.0).CGColor
        self.addSubview(underLine)
    }
    
    func loadBackground() {
        self.backgroundColor = UIColor.clearColor()
    }
}
