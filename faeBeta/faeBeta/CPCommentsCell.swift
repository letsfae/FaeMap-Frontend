//
//  CommentExtentTableViewCell.swift
//  faeBeta
//
//  Created by Yue Shen on 9/19/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

protocol CPCommentsCellDelegate {
    // Reply to this user
    func showActionSheetFromCommentPinCell(username: String)
    // CancelTimerForTouchingCell
    func cancelTouchToReplyTimerFromCommentPinCell(cancel: Bool)
}

class CPCommentsCell: UITableViewCell {
    
    var delegate: CPCommentsCellDelegate?
    
    var imageViewAvatar: UIImageView!
    
    var labelUsername: UILabel!
    var labelTimestamp: UILabel!
    
    var uiviewCommentActionButtons: UIView!
    
    var labelVoteCount: UILabel!
    var labelLikeCount: UILabel!
    var labelShareCount: UILabel!
    
    var buttonForWholeCell: UIButton!
    
    var textViewComment: UITextView!
    
//    var buttonUpVote: UIButton!
//    var buttonDownVote: UIButton!
//    var buttonLike: UIButton!
    var buttonShare: UIButton!
    
    let screenWidth = UIScreen.mainScreen().bounds.width
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        loadCellContent()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func loadCellContent() {
        self.imageViewAvatar = UIImageView()
        self.addSubview(self.imageViewAvatar)
        self.imageViewAvatar.layer.cornerRadius = 19.5
        self.imageViewAvatar.clipsToBounds = true
        self.imageViewAvatar.contentMode = .ScaleAspectFill
        self.addConstraintsWithFormat("H:|-15-[v0(39)]", options: [], views: imageViewAvatar)
//        self.addConstraintsWithFormat("V:|-15-[v0(39)]", options: [], views: imageViewAvatar)
        
        self.textViewComment = UITextView()
        self.addSubview(self.textViewComment)
        self.textViewComment.font = UIFont(name: "AvenirNext-Regular", size: 18)
        self.textViewComment.editable = false
        self.textViewComment.userInteractionEnabled = false
        self.textViewComment.textContainerInset = UIEdgeInsetsZero
        self.textViewComment.textColor = UIColor(red: 89/255, green: 89/255, blue: 89/255, alpha: 1.0)
        self.addConstraintsWithFormat("H:|-27-[v0(361)]", options: [], views: textViewComment)
        self.addConstraintsWithFormat("V:|-15-[v0(39)]-10-[v1(25)]", options: [], views: imageViewAvatar, textViewComment)
        self.textViewComment.scrollEnabled = false
        
        self.labelUsername = UILabel()
        self.addSubview(self.labelUsername)
        self.labelUsername.font = UIFont(name: "AvenirNext-Medium", size: 16)
        self.labelUsername.textColor = UIColor(red: 89/255, green: 89/255, blue: 89/255, alpha: 1.0)
        self.labelUsername.textAlignment = .Left
        self.addConstraintsWithFormat("H:|-69-[v0(200)]", options: [], views: labelUsername)
        self.addConstraintsWithFormat("V:|-15-[v0(20)]", options: [], views: labelUsername)
        
        self.labelTimestamp = UILabel()
        self.addSubview(self.labelTimestamp)
        self.labelTimestamp.font = UIFont(name: "AvenirNext-Medium", size: 13)
        self.labelTimestamp.textColor = UIColor(red: 107/255, green: 105/255, blue: 105/255, alpha: 1.0)
        self.labelTimestamp.textAlignment = .Left
        self.addConstraintsWithFormat("H:|-69-[v0(200)]", options: [], views: labelTimestamp)
        self.addConstraintsWithFormat("V:|-36-[v0(20)]", options: [], views: labelTimestamp)
        
        /*
        // Main buttons container of comment pin detail
        self.uiviewCommentActionButtons = UIView()
        self.addSubview(uiviewCommentActionButtons)
        self.addConstraintsWithFormat("H:|-0-[v0(\(self.screenWidth))]", options: [], views: uiviewCommentActionButtons)
        self.addConstraintsWithFormat("V:[v0(22)]-16-|", options: [], views: uiviewCommentActionButtons)
        
        // Label of Share Count
        self.labelShareCount = UILabel()
        self.labelShareCount.text = "0"
        self.labelShareCount.font = UIFont(name: "PingFang SC-Semibold", size: 15)
        self.labelShareCount.textColor = UIColor(red: 107/255, green: 105/255, blue: 105/255, alpha: 1.0)
        self.labelShareCount.textAlignment = .Right
        self.uiviewCommentActionButtons.addSubview(labelShareCount)
        self.uiviewCommentActionButtons.addConstraintsWithFormat("H:[v0(41)]-49-|", options: [], views: labelShareCount)
        self.uiviewCommentActionButtons.addConstraintsWithFormat("V:[v0(22)]-0-|", options: [], views: labelShareCount)
        
        
        // Label of Vote Count
        self.labelVoteCount = UILabel()
        self.labelVoteCount.text = "0"
        self.labelVoteCount.font = UIFont(name: "PingFang SC-Semibold", size: 15)
        self.labelVoteCount.textColor = UIColor(red: 107/255, green: 105/255, blue: 105/255, alpha: 1.0)
        self.labelVoteCount.textAlignment = .Center
        self.uiviewCommentActionButtons.addSubview(labelVoteCount)
        self.uiviewCommentActionButtons.addConstraintsWithFormat("H:|-42-[v0(56)]", options: [], views: labelVoteCount)
        self.uiviewCommentActionButtons.addConstraintsWithFormat("V:[v0(22)]-0-|", options: [], views: labelVoteCount)
        
        // Label of Like Count
        self.labelLikeCount = UILabel()
        self.labelLikeCount.text = "0"
        self.labelLikeCount.font = UIFont(name: "PingFang SC-Semibold", size: 15)
        self.labelLikeCount.textColor = UIColor(red: 107/255, green: 105/255, blue: 105/255, alpha: 1.0)
        self.labelLikeCount.textAlignment = .Right
        self.uiviewCommentActionButtons.addSubview(labelLikeCount)
        self.uiviewCommentActionButtons.addConstraintsWithFormat("H:[v0(41)]-141-|", options: [], views: labelLikeCount)
        self.uiviewCommentActionButtons.addConstraintsWithFormat("V:[v0(22)]-0-|", options: [], views: labelLikeCount)
        
        // Button 3: Comment Pin DownVote
        self.buttonDownVote = UIButton()
        self.buttonDownVote.setImage(UIImage(named: "commentPinDownVoteGray"), forState: .Normal)
//        self.buttonDownVote.addTarget(self, action: #selector(FaeMapViewController.actionDownVoteThisComment(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.uiviewCommentActionButtons.addSubview(buttonDownVote)
        self.uiviewCommentActionButtons.addConstraintsWithFormat("H:|-0-[v0(53)]", options: [], views: buttonDownVote)
        self.uiviewCommentActionButtons.addConstraintsWithFormat("V:[v0(22)]-0-|", options: [], views: buttonDownVote)
        
        // Button 4: Comment Pin UpVote
        self.buttonUpVote = UIButton()
        self.buttonUpVote.setImage(UIImage(named: "commentPinUpVoteGray"), forState: .Normal)
//        self.buttonUpVote.addTarget(self, action: #selector(FaeMapViewController.actionLikeThisComment(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.uiviewCommentActionButtons.addSubview(buttonUpVote)
        self.uiviewCommentActionButtons.addConstraintsWithFormat("H:|-91-[v0(53)]", options: [], views: buttonUpVote)
        self.uiviewCommentActionButtons.addConstraintsWithFormat("V:[v0(22)]-0-|", options: [], views: buttonUpVote)
        
        // Button 5: Comment Pin Like
        self.buttonLike = UIButton()
        self.buttonLike.setImage(UIImage(named: "commentPinLikeHollow"), forState: .Normal)
//        self.buttonLike.addTarget(self, action: #selector(FaeMapViewController.actionLikeThisComment(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.uiviewCommentActionButtons.addSubview(buttonLike)
        self.uiviewCommentActionButtons.addConstraintsWithFormat("H:[v0(56)]-90-|", options: [], views: buttonLike)
        self.uiviewCommentActionButtons.addConstraintsWithFormat("V:[v0(22)]-0-|", options: [], views: buttonLike)
        */
        
        self.buttonForWholeCell = UIButton()
        self.buttonForWholeCell.addTarget(self, action: #selector(CPCommentsCell.showActionSheet(_:)), forControlEvents: .TouchDown)
        self.buttonForWholeCell.addTarget(self, action: #selector(CPCommentsCell.cancelTouchToReplyTimer(_:)), forControlEvents: [.TouchUpInside, .TouchUpOutside])
        self.addSubview(buttonForWholeCell)
        self.addConstraintsWithFormat("H:[v0(\(screenWidth))]-0-|", options: [], views: buttonForWholeCell)
        self.addConstraintsWithFormat("V:[v0(140)]-0-|", options: [], views: buttonForWholeCell)
        
        // Button 6: Add Comment
        self.buttonShare = UIButton()
        self.buttonShare.setImage(UIImage(named: "commentPinForwardHollow"), forState: .Normal)
//        self.buttonShare.addTarget(self, action: #selector(FaeMapViewController.actionReplyToThisComment(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.buttonShare.addTarget(self, action: #selector(CPCommentsCell.showActionSheet(_:)), forControlEvents: .TouchUpInside)
        self.addSubview(buttonShare)
        self.addConstraintsWithFormat("H:[v0(56)]-0-|", options: [], views: buttonShare)
        self.addConstraintsWithFormat("V:[v0(22)]-16-|", options: [], views: buttonShare)
    }
    
    func showActionSheet(sender: UIButton) {
        if let username = labelUsername.text {
            self.delegate?.showActionSheetFromCommentPinCell(username)
        }
    }
    
    func cancelTouchToReplyTimer(sender: UIButton) {
        self.delegate?.cancelTouchToReplyTimerFromCommentPinCell(true)
    }
}
