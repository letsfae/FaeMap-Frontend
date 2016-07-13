//
//  CommentExtentTableViewCell.swift
//  faeBeta
//
//  Created by blesssecret on 6/16/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

class CommentPinUIView: UIView {
    
    var imageViewAvatar: UIImageView!
    
    var labelTitle: UILabel!
    var labelDes: UILabel!
    var textViewComment: UITextView!
    
    var buttonDelete: UIButton!
    var buttonLike: UIButton!
    var buttonAddComment: UIButton!
    
    var buttonDeleteLargerCover: UIButton!
    var buttonCommentPinLargerCover: UIButton!
    
    var uiviewUnderLine: UIView!
    
    var lineNumber: Int!
    
    var hasExpanded = true
    
    let screenWidth = UIScreen.mainScreen().bounds.width
    
    init() {
        super.init(frame: CGRect(x: 0, y: 20, width: screenWidth, height: 0))
        loadAvatar()
        loadLabel()
        loadUnderLine()
        loadButton()
        loadBackground()
        lineNumber = 1
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func loadAvatar() {
        imageViewAvatar = UIImageView(frame: CGRect(x: 16, y: 12, width: 50, height: 45))
        imageViewAvatar.image = UIImage(named: "avatar_expand_no")
        self.addSubview(imageViewAvatar)
        imageViewAvatar.layer.masksToBounds = true
        imageViewAvatar.hidden = true
//        imageViewAvatar.layer.cornerRadius = imageViewAvatar.frame.width/2
    }
    
    func loadLabel() {
        labelTitle = UILabel(frame: CGRect(x: 80, y: 16, width: screenWidth-120, height: 20))
        self.addSubview(labelTitle)
        labelTitle.font = UIFont(name: "AvenirNext-Medium", size: 20.0)
        labelTitle.textColor = UIColor.whiteColor()
        labelTitle.hidden = true
        
        labelDes = UILabel(frame: CGRect(x: 80, y: 40, width: screenWidth-120, height: 20))
        self.addSubview(labelDes)
        labelDes.font = UIFont(name: "AvenirNext-Regular", size: 15.0)
        labelDes.textColor = UIColor.whiteColor()
        labelDes.hidden = true
        
        textViewComment = UITextView(frame: CGRect(x: 40, y: 81, width: 334, height: 91))
        textViewComment.userInteractionEnabled = false
        self.addSubview(textViewComment)
        textViewComment.textColor = UIColor.whiteColor()
        textViewComment.font = UIFont(name: "AvenirNext-Regular", size: 18.0)
        textViewComment.backgroundColor = UIColor.clearColor()
        textViewComment.hidden = true
    }
    
    func loadButton() {
        buttonDelete = UIButton(frame: CGRect(x: 381, y: 29, width: 18, height: 18))
        //buttonExtend.setTitle("Delete", forState: .Normal)
        let imageDelete = UIImage(named: "comment_pin_delete")
        buttonDelete.setImage(imageDelete, forState: .Normal)
        self.addSubview(buttonDelete)
        buttonDeleteLargerCover = UIButton(frame: CGRect(x: screenWidth-50, y: 0, width: 50, height: 78))
        self.addSubview(buttonDeleteLargerCover)
        buttonDelete.hidden = true
        
        buttonAddComment = UIButton(frame: CGRect(x: 284, y: 196, width: 50, height: 50))
        let imageLike = UIImage(named: "comment_pin_groupchat")
        buttonAddComment.setImage(imageLike, forState: .Normal)
        self.addSubview(buttonAddComment)
        buttonAddComment.hidden = true
        buttonAddComment.clipsToBounds = false
        
        buttonLike = UIButton(frame: CGRect(x: 349, y: 196, width: 50, height: 50))
        let imageAddComment = UIImage(named: "comment_pin_like")
        buttonLike.setImage(imageAddComment, forState: .Normal)
        self.addSubview(buttonLike)
        buttonLike.hidden = true
        buttonLike.clipsToBounds = false
        
        buttonCommentPinLargerCover = UIButton(frame: CGRect(x: 0, y: 0, width: screenWidth-50, height: 78))
        self.addSubview(buttonCommentPinLargerCover)
    }
    
    func loadUnderLine() {
        uiviewUnderLine = UIView(frame: CGRectMake(0, 77, screenWidth, 1))
        uiviewUnderLine.layer.borderWidth = screenWidth
        uiviewUnderLine.layer.borderColor = UIColor(red: 182/255, green: 182/255, blue: 182/255, alpha: 1.0).CGColor
        self.addSubview(uiviewUnderLine)
        uiviewUnderLine.hidden = true
    }
    
    func loadBackground() {
        self.backgroundColor = UIColor.clearColor()
    }
}
