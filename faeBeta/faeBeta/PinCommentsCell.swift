//
//  CommentExtentTableViewCell.swift
//  faeBeta
//
//  Created by Yue Shen on 9/19/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
import SwiftyJSON

protocol PinCommentsCellDelegate: class {
    func showActionSheetFromPinCell(_ username: String) // Reply to this user
    func cancelTouchToReplyTimerFromPinCell(_ cancel: Bool) // CancelTimerForTouchingCell
}

class PinCommentsCell: UITableViewCell, UITextViewDelegate {
    
    weak var delegate: PinCommentsCellDelegate?
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
    var buttonReply: UIButton!
    var pinID = ""
    enum VoteType {
        case null
        case up
        case down
    }
    var voteType: VoteType = .null
    var pinType = ""
    var pinCommentID = ""
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        loadCellContent()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func loadCellContent() {
        
        self.buttonForWholeCell = UIButton()
        self.buttonForWholeCell.addTarget(self, action: #selector(self.showActionSheet(_:)), for: .touchDown)
        self.buttonForWholeCell.addTarget(self, action: #selector(self.cancelTouchToReplyTimer(_:)), for: [.touchUpInside, .touchUpOutside])
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
        self.addConstraintsWithFormat("H:|-0-[v0(\(screenWidth))]", options: [], views: uiviewCommentActionButtons)
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
        self.buttonDownVote.setImage(#imageLiteral(resourceName: "pinCommentDownVoteGray"), for: .normal)
        self.buttonDownVote.addTarget(self, action: #selector(self.downVoteThisComment(_:)), for: .touchUpInside)
        self.uiviewCommentActionButtons.addSubview(buttonDownVote)
        self.uiviewCommentActionButtons.addConstraintsWithFormat("H:|-0-[v0(53)]", options: [], views: buttonDownVote)
        self.uiviewCommentActionButtons.addConstraintsWithFormat("V:[v0(22)]-0-|", options: [], views: buttonDownVote)
        
        // UpVote
        self.buttonUpVote = UIButton()
        self.buttonUpVote.setImage(#imageLiteral(resourceName: "pinCommentUpVoteGray"), for: .normal)
        self.buttonUpVote.addTarget(self, action: #selector(self.upVoteThisComment(_:)), for: .touchUpInside)
        self.uiviewCommentActionButtons.addSubview(buttonUpVote)
        self.uiviewCommentActionButtons.addConstraintsWithFormat("H:|-91-[v0(53)]", options: [], views: buttonUpVote)
        self.uiviewCommentActionButtons.addConstraintsWithFormat("V:[v0(22)]-0-|", options: [], views: buttonUpVote)
 
        // Add Comment
        self.buttonReply = UIButton()
        self.buttonReply.setImage(#imageLiteral(resourceName: "pinCommentReply"), for: UIControlState())
        self.buttonReply.addTarget(self, action: #selector(self.showActionSheet(_:)), for: .touchUpInside)
        self.uiviewCommentActionButtons.addSubview(buttonReply)
        self.uiviewCommentActionButtons.addConstraintsWithFormat("H:[v0(56)]-0-|", options: [], views: buttonReply)
        self.uiviewCommentActionButtons.addConstraintsWithFormat("V:[v0(22)]-0-|", options: [], views: buttonReply)
    }
    
    func showActionSheet(_ sender: UIButton) {
        if let username = labelUsername.text {
            self.delegate?.showActionSheetFromPinCell(username)
        }
    }
    
    func cancelTouchToReplyTimer(_ sender: UIButton) {
        self.delegate?.cancelTouchToReplyTimerFromPinCell(true)
    }
    
    func upVoteThisComment(_ sender: UIButton) {
        if voteType == .up || pinCommentID == "" {
            return
        }
        buttonUpVote.setImage(#imageLiteral(resourceName: "pinCommentUpVoteRed"), for: .normal)
        buttonDownVote.setImage(#imageLiteral(resourceName: "pinCommentDownVoteGray"), for: .normal)
        let upVote = FaePinAction()
        upVote.whereKey("vote", value: "up")
        upVote.votePinComments(pinID: "\(pinCommentID)") { (status: Int, message: Any?) in
            print("[upVoteThisComment] pinID: \(self.pinCommentID)")
            if status / 100 == 2 {
                self.voteType = .up
                self.updateVoteCount()
                print("[upVoteThisComment] Successfully upvote this pin comment")
            }
            else if status == 400 {
                print("[upVoteThisComment] Already upvote this pin comment")
            }
            else {
                if self.voteType == .down {
                    self.buttonUpVote.setImage(#imageLiteral(resourceName: "pinCommentUpVoteGray"), for: .normal)
                    self.buttonDownVote.setImage(#imageLiteral(resourceName: "pinCommentDownVoteRed"), for: .normal)
                }
                else if self.voteType == .null {
                    self.buttonUpVote.setImage(#imageLiteral(resourceName: "pinCommentUpVoteGray"), for: .normal)
                    self.buttonDownVote.setImage(#imageLiteral(resourceName: "pinCommentDownVoteGray"), for: .normal)
                }
                print("[upVoteThisComment] Fail to upvote this pin comment")
            }
        }
    }
    
    func downVoteThisComment(_ sender: UIButton) {
        if voteType == .down || pinCommentID == "" {
            return
        }
        buttonUpVote.setImage(#imageLiteral(resourceName: "pinCommentUpVoteGray"), for: .normal)
        buttonDownVote.setImage(#imageLiteral(resourceName: "pinCommentDownVoteRed"), for: .normal)
        let downVote = FaePinAction()
        downVote.whereKey("vote", value: "down")
        downVote.votePinComments(pinID: "\(pinCommentID)") { (status: Int, message: Any?) in
            if status / 100 == 2 {
                self.voteType = .down
                self.updateVoteCount()
                print("[upVoteThisComment] Successfully downvote this pin comment")
            }
            else if status == 400 {
                print("[upVoteThisComment] Already downvote this pin comment")
            }
            else {
                if self.voteType == .up {
                    self.buttonUpVote.setImage(#imageLiteral(resourceName: "pinCommentUpVoteRed"), for: .normal)
                    self.buttonDownVote.setImage(#imageLiteral(resourceName: "pinCommentDownVoteGray"), for: .normal)
                }
                else if self.voteType == .null {
                    self.buttonUpVote.setImage(#imageLiteral(resourceName: "pinCommentUpVoteGray"), for: .normal)
                    self.buttonDownVote.setImage(#imageLiteral(resourceName: "pinCommentDownVoteGray"), for: .normal)
                }
                print("[upVoteThisComment] Fail to downvote this pin comment")
            }
        }
    }
    
    func updateVoteCount() {
        let getPinCommentsDetail = FaePinAction()
        getPinCommentsDetail.getPinComments(pinType, pinID: pinID) {(status: Int, message: Any?) in
            let commentsOfCommentJSON = JSON(message!)
            if commentsOfCommentJSON.count > 0 {
                for i in 0...(commentsOfCommentJSON.count-1) {
                    var upVote = -999
                    var downVote = -999
                    if let pin_comment_id = commentsOfCommentJSON[i]["pin_comment_id"].int {
                        if self.pinCommentID != "\(pin_comment_id)" {
                            continue
                        }
                    }
                    if let vote_up_count = commentsOfCommentJSON[i]["vote_up_count"].int {
                        print("[getPinComments] upVoteCount: \(vote_up_count)")
                        upVote = vote_up_count
                    }
                    if let vote_down_count = commentsOfCommentJSON[i]["vote_down_count"].int {
                        print("[getPinComments] downVoteCount: \(vote_down_count)")
                        downVote = vote_down_count
                    }
                    if let _ = commentsOfCommentJSON[i]["pin_comment_operations"]["vote"].string {
                        
                    }
                    if upVote != -999 && downVote != -999 {
                        self.labelVoteCount.text = "\(upVote - downVote)"
                    }
                }
            }
        }
    }
}
