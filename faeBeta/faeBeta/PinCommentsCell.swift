//
//  PinCommentsCell.swift
//  faeBeta
//
//  Created by Yue Shen on 9/19/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
import SwiftyJSON

protocol PinCommentsCellDelegate: class {
    func directReplyFromPinCell(_ username: String, index: IndexPath) // Reply to this user
    func showActionSheetFromPinCell(_ username: String, userid: Int, index: IndexPath)
}

class PinCommentsCell: UITableViewCell {
    
    weak var delegate: PinCommentsCellDelegate?
    var uiviewCell: UIButton!
    var imgAvatar: UIImageView!
    var lblUsername: UILabel!
    var lblTime: UILabel!
    var lblVoteCount: UILabel!
    var lblLikeCount: UILabel!
    var lblContent: UILabel!
    var btnUpVote: UIButton!
    var btnDownVote: UIButton!
    var btnReply: UIButton!
    var pinID = ""
    var voteType: String = "null"    
    var pinType = ""
    var pinCommentID = ""
    var userID = -1
    var cellIndex: IndexPath!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.separatorInset = UIEdgeInsets.zero
        self.layoutMargins = UIEdgeInsets.zero
        loadCellContent()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func loadCellContent() {
        
        uiviewCell = UIButton()
        addSubview(uiviewCell)
        addConstraintsWithFormat("H:|-0-[v0]-0-|", options: [], views: uiviewCell)
        addConstraintsWithFormat("V:|-0-[v0]-0-|", options: [], views: uiviewCell)
        uiviewCell.addTarget(self, action: #selector(self.showActionSheet(_:)), for: .touchUpInside)
        
        imgAvatar = UIImageView()
        addSubview(imgAvatar)
        imgAvatar.layer.cornerRadius = 19.5
        imgAvatar.clipsToBounds = true
        imgAvatar.contentMode = .scaleAspectFill
        addConstraintsWithFormat("H:|-15-[v0(39)]", options: [], views: imgAvatar)
        
        lblContent = UILabel()
        addSubview(lblContent)
        lblContent.lineBreakMode = .byWordWrapping
        lblContent.numberOfLines = 0
        lblContent.font = UIFont(name: "AvenirNext-Regular", size: 18)
        lblContent.textColor = UIColor.faeAppInputTextGrayColor()
        addConstraintsWithFormat("H:|-27-[v0]-27-|", options: [], views: lblContent)
        
        lblUsername = UILabel()
        addSubview(lblUsername)
        lblUsername.font = UIFont(name: "AvenirNext-Medium", size: 16)
        lblUsername.textColor = UIColor.faeAppInputTextGrayColor()
        lblUsername.textAlignment = .left
        addConstraintsWithFormat("H:|-69-[v0]-69-|", options: [], views: lblUsername)
        
        lblTime = UILabel()
        addSubview(lblTime)
        lblTime.font = UIFont(name: "AvenirNext-Medium", size: 13)
        lblTime.textColor = UIColor.faeAppTimeTextBlackColor()
        lblTime.textAlignment = .left
        addConstraintsWithFormat("H:|-69-[v0]-69-|", options: [], views: lblTime)
        
        // Label of Vote Count
        lblVoteCount = UILabel()
        lblVoteCount.text = "0"
        lblVoteCount.font = UIFont(name: "PingFang SC-Semibold", size: 15)
        lblVoteCount.textColor = UIColor.faeAppTimeTextBlackColor()
        lblVoteCount.textAlignment = .center
        addSubview(lblVoteCount)
        addConstraintsWithFormat("H:|-42-[v0(56)]", options: [], views: lblVoteCount)
        
        // DownVote
        btnDownVote = UIButton()
//        btnDownVote.setImage(#imageLiteral(resourceName: "pinCommentDownVoteGray"), for: .normal)
        btnDownVote.addTarget(self, action: #selector(downVoteThisComment(_:)), for: .touchUpInside)
        addSubview(btnDownVote)
        addConstraintsWithFormat("H:|-0-[v0(53)]", options: [], views: btnDownVote)
        
        // UpVote
        btnUpVote = UIButton()
//        btnUpVote.setImage(#imageLiteral(resourceName: "pinCommentUpVoteGray"), for: .normal)
        btnUpVote.addTarget(self, action: #selector(upVoteThisComment(_:)), for: .touchUpInside)
        addSubview(btnUpVote)
        addConstraintsWithFormat("H:|-91-[v0(53)]", options: [], views: btnUpVote)
        
        // Add Comment
        btnReply = UIButton()
        btnReply.setImage(#imageLiteral(resourceName: "pinCommentReply"), for: UIControlState())
        btnReply.addTarget(self, action: #selector(directReply(_:)), for: .touchUpInside)
        addSubview(btnReply)
        addConstraintsWithFormat("H:[v0(56)]-0-|", options: [], views: btnReply)
        
        addConstraintsWithFormat("V:|-15-[v0(39)]-10-[v1]-13-[v2(22)]-16-|", options: [], views: imgAvatar, lblContent, lblVoteCount)
        addConstraintsWithFormat("V:|-15-[v0(20)]-1-[v1(20)]", options: [], views: lblUsername, lblTime)
        addConstraintsWithFormat("V:[v0(54)]-0-|", options: [], views: btnDownVote)
        addConstraintsWithFormat("V:[v0(54)]-0-|", options: [], views: btnUpVote)
        addConstraintsWithFormat("V:[v0(54)]-0-|", options: [], views: btnReply)
    }
    
    func directReply(_ sender: UIButton) {
        if let username = lblUsername.text {
            delegate?.directReplyFromPinCell(username, index: cellIndex)
        }
    }
    
    func showActionSheet(_ sender: UIButton) {
        if let username = lblUsername.text {
            delegate?.showActionSheetFromPinCell(username, userid: userID, index: cellIndex)
        }
    }
    
    func upVoteThisComment(_ sender: UIButton) {
        if voteType == "up" || pinCommentID == "" {
            cancelVote()
            return
        }
        btnUpVote.setImage(#imageLiteral(resourceName: "pinCommentUpVoteRed"), for: .normal)
        btnDownVote.setImage(#imageLiteral(resourceName: "pinCommentDownVoteGray"), for: .normal)
        let upVote = FaePinAction()
        upVote.whereKey("vote", value: "up")
        upVote.votePinComments(pinID: "\(pinCommentID)") { (status: Int, message: Any?) in
            print("[upVoteThisComment] pinID: \(self.pinCommentID)")
            if status / 100 == 2 {
                self.voteType = "up"
                self.updateVoteCount()
                print("[upVoteThisComment] Successfully upvote this pin comment")
            }
            else if status == 400 {
                print("[upVoteThisComment] Already upvote this pin comment")
            }
            else {
                if self.voteType == "down" {
                    self.btnUpVote.setImage(#imageLiteral(resourceName: "pinCommentUpVoteGray"), for: .normal)
                    self.btnDownVote.setImage(#imageLiteral(resourceName: "pinCommentDownVoteRed"), for: .normal)
                }
                else if self.voteType == "" {
                    self.btnUpVote.setImage(#imageLiteral(resourceName: "pinCommentUpVoteGray"), for: .normal)
                    self.btnDownVote.setImage(#imageLiteral(resourceName: "pinCommentDownVoteGray"), for: .normal)
                }
                print("[upVoteThisComment] Fail to upvote this pin comment")
            }
        }
    }
    
    func downVoteThisComment(_ sender: UIButton) {
        if voteType == "down" || pinCommentID == "" {
            cancelVote()
            return
        }
        btnUpVote.setImage(#imageLiteral(resourceName: "pinCommentUpVoteGray"), for: .normal)
        btnDownVote.setImage(#imageLiteral(resourceName: "pinCommentDownVoteRed"), for: .normal)
        let downVote = FaePinAction()
        downVote.whereKey("vote", value: "down")
        downVote.votePinComments(pinID: "\(pinCommentID)") { (status: Int, message: Any?) in
            if status / 100 == 2 {
                self.voteType = "down"
                self.updateVoteCount()
                print("[upVoteThisComment] Successfully downvote this pin comment")
            }
            else if status == 400 {
                print("[upVoteThisComment] Already downvote this pin comment")
            }
            else {
                if self.voteType == "up" {
                    self.btnUpVote.setImage(#imageLiteral(resourceName: "pinCommentUpVoteRed"), for: .normal)
                    self.btnDownVote.setImage(#imageLiteral(resourceName: "pinCommentDownVoteGray"), for: .normal)
                }
                else if self.voteType == "" {
                    self.btnUpVote.setImage(#imageLiteral(resourceName: "pinCommentUpVoteGray"), for: .normal)
                    self.btnDownVote.setImage(#imageLiteral(resourceName: "pinCommentDownVoteGray"), for: .normal)
                }
                print("[upVoteThisComment] Fail to downvote this pin comment")
            }
        }
    }
    
    func cancelVote() {
        let cancelVote = FaePinAction()
        cancelVote.cancelVotePinComments(pinId: "\(pinCommentID)") { (status: Int, message: Any?) in
            if status / 100 == 2 {
                self.voteType = ""
                self.btnUpVote.setImage(#imageLiteral(resourceName: "pinCommentUpVoteGray"), for: .normal)
                self.btnDownVote.setImage(#imageLiteral(resourceName: "pinCommentDownVoteGray"), for: .normal)
                self.updateVoteCount()
                print("[upVoteThisComment] Successfully cancel vote this pin comment")
            }
            else if status == 400 {
                print("[upVoteThisComment] Already cancel vote this pin comment")
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
                        self.lblVoteCount.text = "\(upVote - downVote)"
                    }
                }
            }
        }
    }
}
