//
//  CommentExtentTableViewCell.swift
//  faeBeta
//
//  Created by Yue Shen on 9/19/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

protocol CPCommentsCellDelegate: class {
    func showActionSheetFromCommentPinCell(_ username: String) // Reply to this user
    func cancelTouchToReplyTimerFromCommentPinCell(_ cancel: Bool) // CancelTimerForTouchingCell
}

class CPCommentsCell: UITableViewCell, UITextViewDelegate {
    
    weak var delegate: CPCommentsCellDelegate?
    var imageViewAvatar: UIImageView!
    var labelUsername: UILabel!
    var labelTimestamp: UILabel!
    var uiviewCommentActionButtons: UIView!
    var labelVoteCount: UILabel!
    var labelLikeCount: UILabel!
    var labelShareCount: UILabel!
    var buttonForWholeCell: UIButton!
    var textViewComment: UITextView!
    var buttonUpVote: UIButton!
    var buttonDownVote: UIButton!
//    var buttonLike: UIButton!
    var buttonReply: UIButton!
    
    let screenWidth = UIScreen.main.bounds.width
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        loadCellContent()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func loadCellContent() {
        
        self.buttonForWholeCell = UIButton()
        self.buttonForWholeCell.addTarget(self, action: #selector(CPCommentsCell.showActionSheet(_:)), for: .touchDown)
        self.buttonForWholeCell.addTarget(self, action: #selector(CPCommentsCell.cancelTouchToReplyTimer(_:)), for: [.touchUpInside, .touchUpOutside])
        self.addSubview(buttonForWholeCell)
        self.addConstraintsWithFormat("H:[v0(\(screenWidth))]-0-|", options: [], views: buttonForWholeCell)
        self.addConstraintsWithFormat("V:[v0(140)]-0-|", options: [], views: buttonForWholeCell)
        
        self.imageViewAvatar = UIImageView()
        self.addSubview(self.imageViewAvatar)
        self.imageViewAvatar.layer.cornerRadius = 19.5
        self.imageViewAvatar.clipsToBounds = true
        self.imageViewAvatar.contentMode = .scaleAspectFill
        self.addConstraintsWithFormat("H:|-15-[v0(39)]", options: [], views: imageViewAvatar)
        
        self.textViewComment = UITextView()
        self.addSubview(self.textViewComment)
        self.textViewComment.font = UIFont(name: "AvenirNext-Regular", size: 18)
        self.textViewComment.isEditable = false
        self.textViewComment.isUserInteractionEnabled = false
        self.textViewComment.textContainerInset = UIEdgeInsets.zero
        self.textViewComment.textColor = UIColor(red: 89/255, green: 89/255, blue: 89/255, alpha: 1.0)
        self.addConstraintsWithFormat("H:|-27-[v0(361)]", options: [], views: textViewComment)
        self.addConstraintsWithFormat("V:|-15-[v0(39)]-10-[v1(25)]", options: [], views: imageViewAvatar, textViewComment)
        self.textViewComment.isScrollEnabled = false
        self.textViewComment.delegate = self
        
        self.labelUsername = UILabel()
        self.addSubview(self.labelUsername)
        self.labelUsername.font = UIFont(name: "AvenirNext-Medium", size: 16)
        self.labelUsername.textColor = UIColor(red: 89/255, green: 89/255, blue: 89/255, alpha: 1.0)
        self.labelUsername.textAlignment = .left
        self.addConstraintsWithFormat("H:|-69-[v0(200)]", options: [], views: labelUsername)
        self.addConstraintsWithFormat("V:|-15-[v0(20)]", options: [], views: labelUsername)
        
        self.labelTimestamp = UILabel()
        self.addSubview(self.labelTimestamp)
        self.labelTimestamp.font = UIFont(name: "AvenirNext-Medium", size: 13)
        self.labelTimestamp.textColor = UIColor(red: 107/255, green: 105/255, blue: 105/255, alpha: 1.0)
        self.labelTimestamp.textAlignment = .left
        self.addConstraintsWithFormat("H:|-69-[v0(200)]", options: [], views: labelTimestamp)
        self.addConstraintsWithFormat("V:|-36-[v0(20)]", options: [], views: labelTimestamp)
        
        // Main buttons container
        self.uiviewCommentActionButtons = UIView()
        self.addSubview(uiviewCommentActionButtons)
        self.addConstraintsWithFormat("H:|-0-[v0(\(self.screenWidth))]", options: [], views: uiviewCommentActionButtons)
        self.addConstraintsWithFormat("V:[v0(22)]-16-|", options: [], views: uiviewCommentActionButtons)
        
        // Label of Vote Count
        self.labelVoteCount = UILabel()
        self.labelVoteCount.text = "0"
        self.labelVoteCount.font = UIFont(name: "PingFang SC-Semibold", size: 15)
        self.labelVoteCount.textColor = UIColor(red: 107/255, green: 105/255, blue: 105/255, alpha: 1.0)
        self.labelVoteCount.textAlignment = .center
        self.uiviewCommentActionButtons.addSubview(labelVoteCount)
        self.uiviewCommentActionButtons.addConstraintsWithFormat("H:|-42-[v0(56)]", options: [], views: labelVoteCount)
        self.uiviewCommentActionButtons.addConstraintsWithFormat("V:[v0(22)]-0-|", options: [], views: labelVoteCount)
        
        // DownVote
        self.buttonDownVote = UIButton()
        self.buttonDownVote.setImage(UIImage(named: "commentPinDownVoteGray"), for: .normal)
//        self.buttonDownVote.addTarget(self, action: #selector(FaeMapViewController.actionDownVoteThisComment(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.uiviewCommentActionButtons.addSubview(buttonDownVote)
        self.uiviewCommentActionButtons.addConstraintsWithFormat("H:|-0-[v0(53)]", options: [], views: buttonDownVote)
        self.uiviewCommentActionButtons.addConstraintsWithFormat("V:[v0(22)]-0-|", options: [], views: buttonDownVote)
        
        // UpVote
        self.buttonUpVote = UIButton()
        self.buttonUpVote.setImage(UIImage(named: "commentPinUpVoteGray"), for: .normal)
//        self.buttonUpVote.addTarget(self, action: #selector(FaeMapViewController.actionLikeThisComment(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.uiviewCommentActionButtons.addSubview(buttonUpVote)
        self.uiviewCommentActionButtons.addConstraintsWithFormat("H:|-91-[v0(53)]", options: [], views: buttonUpVote)
        self.uiviewCommentActionButtons.addConstraintsWithFormat("V:[v0(22)]-0-|", options: [], views: buttonUpVote)
 
        // Add Comment
        self.buttonReply = UIButton()
        self.buttonReply.setImage(UIImage(named: "commentPinForwardHollow"), for: UIControlState())
//        self.buttonShare.addTarget(self, action: #selector(FaeMapViewController.actionReplyToThisComment(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.buttonReply.addTarget(self, action: #selector(CPCommentsCell.showActionSheet(_:)), for: .touchUpInside)
        self.uiviewCommentActionButtons.addSubview(buttonReply)
        self.uiviewCommentActionButtons.addConstraintsWithFormat("H:[v0(56)]-0-|", options: [], views: buttonReply)
        self.uiviewCommentActionButtons.addConstraintsWithFormat("V:[v0(22)]-0-|", options: [], views: buttonReply)
    }
    
    func showActionSheet(_ sender: UIButton) {
        if let username = labelUsername.text {
            self.delegate?.showActionSheetFromCommentPinCell(username)
        }
    }
    
    func cancelTouchToReplyTimer(_ sender: UIButton) {
        self.delegate?.cancelTouchToReplyTimerFromCommentPinCell(true)
    }
}

/*
 // Comment Pin Like
 self.buttonLike = UIButton()
 self.buttonLike.setImage(UIImage(named: "commentPinLikeHollow"), forState: .Normal)
 //        self.buttonLike.addTarget(self, action: #selector(FaeMapViewController.actionLikeThisComment(_:)), forControlEvents: UIControlEvents.TouchUpInside)
 self.uiviewCommentActionButtons.addSubview(buttonLike)
 self.uiviewCommentActionButtons.addConstraintsWithFormat("H:[v0(56)]-90-|", options: [], views: buttonLike)
 self.uiviewCommentActionButtons.addConstraintsWithFormat("V:[v0(22)]-0-|", options: [], views: buttonLike)
 
 // Label of Like Count
 self.labelLikeCount = UILabel()
 self.labelLikeCount.text = "0"
 self.labelLikeCount.font = UIFont(name: "PingFang SC-Semibold", size: 15)
 self.labelLikeCount.textColor = UIColor(red: 107/255, green: 105/255, blue: 105/255, alpha: 1.0)
 self.labelLikeCount.textAlignment = .right
 self.uiviewCommentActionButtons.addSubview(labelLikeCount)
 self.uiviewCommentActionButtons.addConstraintsWithFormat("H:[v0(41)]-141-|", options: [], views: labelLikeCount)
 self.uiviewCommentActionButtons.addConstraintsWithFormat("V:[v0(22)]-0-|", options: [], views: labelLikeCount)
 
 // Label of Share Count
 self.labelShareCount = UILabel()
 self.labelShareCount.text = "0"
 self.labelShareCount.font = UIFont(name: "PingFang SC-Semibold", size: 15)
 self.labelShareCount.textColor = UIColor(red: 107/255, green: 105/255, blue: 105/255, alpha: 1.0)
 self.labelShareCount.textAlignment = .right
 self.uiviewCommentActionButtons.addSubview(labelShareCount)
 self.uiviewCommentActionButtons.addConstraintsWithFormat("H:[v0(41)]-49-|", options: [], views: labelShareCount)
 self.uiviewCommentActionButtons.addConstraintsWithFormat("V:[v0(22)]-0-|", options: [], views: labelShareCount)
 */
