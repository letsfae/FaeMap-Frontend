//
//  CommentExtentTableViewCell.swift
//  faeBeta
//
//  Created by blesssecret on 6/16/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

class CommentExtentTableViewCell: UITableViewCell {
    
    var imageViewAvatar: UIImageView!
    var labelTitle: UILabel!
    var buttonExtend: UIButton!
    var buttonLike: UIButton!
    var buttonAddComment: UIButton!
    
    var textViewComment: UITextView!
    var labelDes: UILabel!
    
    var index: NSIndexPath!
    
    let screenWidth = UIScreen.mainScreen().bounds.width
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        loadAvatar()
        loadLabel()
        
        loadBackground()
        loadButton()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        imageViewAvatar.image = UIImage(named: "pin_user_avatar")
        
        // Configure the view for the selected state
    }
    
    func hideComment(){
        textViewComment.hidden = true
        UIView.animateWithDuration(0.3, delay: 0, options: .TransitionFlipFromBottom, animations: ({
            self.frame.size.height = 77
        }), completion: nil)
        buttonLike.hidden = true
        buttonAddComment.hidden = true
    }
    
    func showComment(){
        textViewComment.hidden = false
        UIView.animateWithDuration(0.3, delay: 0, options: .TransitionFlipFromBottom, animations: ({
            self.frame.size.height = 227
        }), completion: nil)
        buttonAddComment.hidden = false
        buttonLike.hidden = false
    }
    
    func loadAvatar(){
        imageViewAvatar = UIImageView(frame: CGRect(x: 16, y: 12, width: 50, height: 50))
        self.addSubview(imageViewAvatar)
        imageViewAvatar.layer.masksToBounds = true
        imageViewAvatar.layer.cornerRadius = imageViewAvatar.frame.width/2
    }
    
    func loadLabel(){
        labelTitle = UILabel(frame: CGRect(x: 86, y: 17, width: screenWidth-120, height: 20))
        self.addSubview(labelTitle)
        labelTitle.font = UIFont(name: "AvenirNext-Medium", size: 20.0)
        labelTitle.textColor = UIColor.whiteColor()
        
        labelDes = UILabel(frame: CGRect(x: 86, y: 41, width: screenWidth-120, height: 20))
        self.addSubview(labelDes)
        labelDes.font = UIFont(name: "AvenirNext-Regular", size: 15.0)
        labelDes.textColor = UIColor.whiteColor()
        print(screenWidth-80)
        print(labelDes.frame)
        
        textViewComment = UITextView(frame: CGRect(x: 25, y: 70, width: screenWidth-50, height: 101))
        textViewComment.userInteractionEnabled = false
        self.addSubview(textViewComment)
        textViewComment.textColor = UIColor.whiteColor()
        textViewComment.font = UIFont(name: "AvenirNext-Regular", size: 18.0)
        textViewComment.backgroundColor = UIColor.clearColor()
    }
    
    func loadButton(){
        buttonExtend = UIButton(frame: CGRect(x: screenWidth-30, y: 25, width: 15, height: 15))
        //buttonExtend.setTitle("Delete", forState: .Normal)
        let imageDelete = UIImage(named: "comment_pin_delete")
        buttonExtend.setImage(imageDelete, forState: .Normal)
        self.addSubview(buttonExtend)
        
        buttonLike = UIButton(frame: CGRect(x: screenWidth-120, y: 198, width: 50, height: 50))
        let imageLike = UIImage(named: "comment_pin_groupchat")
        buttonLike.setImage(imageLike, forState: .Normal)
        self.addSubview(buttonLike)
        
        
        buttonAddComment = UIButton(frame: CGRect(x: screenWidth-60, y: 198, width: 50, height: 50))
        let imageAddComment = UIImage(named: "comment_pin_like")
        buttonAddComment.setImage(imageAddComment, forState: .Normal)
        self.addSubview(buttonAddComment)
        
    }
    
    func loadBackground(){
        self.backgroundColor = UIColor.clearColor()
    }
}
