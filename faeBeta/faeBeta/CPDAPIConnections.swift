//
//  CPDAPIConnections.swift
//  faeBeta
//
//  Created by Yue on 10/18/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
import SwiftyJSON
import SDWebImage

extension CommentPinDetailViewController {
    // Like comment pin
    func actionLikeThisComment(_ sender: UIButton) {
        endEdit()
        
        if animatingHeartTimer != nil {
            animatingHeartTimer.invalidate()
        }
        
        if sender.tag == 1 && commentIDCommentPinDetailView != "-999" {
            buttonCommentPinLike.setImage(UIImage(named: "commentPinLikeHollow"), for: UIControlState())
            if animatingHeart != nil {
                animatingHeart.image = nil
            }
            unlikeThisPin("comment", pinID: commentIDCommentPinDetailView)
            print("debug animating sender.tag 1")
            print(sender.tag)
            sender.tag = 0
            return
        }
        
        if sender.tag == 0 && commentIDCommentPinDetailView != "-999" {
            buttonCommentPinLike.setImage(UIImage(named: "commentPinLikeFull"), for: UIControlState())
            self.animateHeart()
            likeThisPin("comment", pinID: commentIDCommentPinDetailView)
            print("debug animating sender.tag 0")
            print(sender.tag)
            sender.tag = 1
        }
    }
    
    func actionHoldingLikeButton(_ sender: UIButton) {
        endEdit()
        buttonCommentPinLike.setImage(UIImage(named: "commentPinLikeFull"), for: UIControlState())
        animatingHeartTimer = Timer.scheduledTimer(timeInterval: 0.15, target: self, selector: #selector(CommentPinDetailViewController.animateHeart), userInfo: nil, repeats: true)
    }
    
    // Upvote comment pin
    func actionUpvoteThisComment(_ sender: UIButton) {
        if isUpVoting {
            return
        }
        
        buttonCommentPinLike.setImage(UIImage(named: "commentPinLikeFull"), for: UIControlState())
        
        if animatingHeart != nil {
            animatingHeart.image = UIImage(named: "commentPinLikeFull")
        }
        
        if commentIDCommentPinDetailView != "-999" {
            likeThisPin("comment", pinID: commentIDCommentPinDetailView)
        }
    }
    
    // Down vote comment pin
    func actionDownVoteThisComment(_ sender: UIButton) {
        buttonCommentPinLike.setImage(UIImage(named: "commentPinLikeHollow"), for: UIControlState())
        if animatingHeart != nil {
            animatingHeart.image = UIImage(named: "commentPinLikeHollow")
        }
        if commentIDCommentPinDetailView != "-999" {
            unlikeThisPin("comment", pinID: commentIDCommentPinDetailView)
        }
    }
    
    func commentThisPin(_ type: String, pinID: String, text: String) {
        let commentThisPin = FaePinAction()
        commentThisPin.whereKey("content", value: text)
        if commentIDCommentPinDetailView != "-999" {
            commentThisPin.commentThisPin(type , commentId: pinID) {(status: Int, message: Any?) in
                if status == 201 {
                    print("Successfully comment this comment pin!")
                    self.getPinAttributeNum("comment", pinID: self.commentIDCommentPinDetailView)
                    self.getPinComments("comment", pinID: self.commentIDCommentPinDetailView, sendMessageFlag: true)
                }
                else {
                    print("Fail to comment this comment pin!")
                }
            }
        }
    }
    
    func likeThisPin(_ type: String, pinID: String) {
        let likeThisPin = FaePinAction()
        likeThisPin.whereKey("", value: "")
        if commentIDCommentPinDetailView != "-999" {
            likeThisPin.likeThisPin(type , commentId: pinID) {(status: Int, message: Any?) in
                if status == 201 {
                    print("Successfully like this comment pin!")
                    self.getPinAttributeNum("comment", pinID: self.commentIDCommentPinDetailView)
                }
                else {
                    print("Fail to like this comment pin!")
                }
            }
        }
    }
    
    func saveThisPin(_ type: String, pinID: String) {
        let saveThisPin = FaePinAction()
        saveThisPin.whereKey("", value: "")
        if commentIDCommentPinDetailView != "-999" {
            saveThisPin.saveThisPin(type , commentId: pinID) {(status: Int, message: Any?) in
                if status == 201 {
                    print("Successfully save this comment pin!")
                    self.getPinAttributeNum("comment", pinID: self.commentIDCommentPinDetailView)
                }
                else {
                    print("Fail to save this comment pin!")
                }
            }
        }
    }
    
    func unlikeThisPin(_ type: String, pinID: String) {
        let unlikeThisPin = FaePinAction()
        unlikeThisPin.whereKey("", value: "")
        if commentIDCommentPinDetailView != "-999" {
            unlikeThisPin.unlikeThisPin(type , commentID: pinID) {(status: Int, message: Any?) in
                if status/100 == 2 {
                    print("Successfully unlike this comment pin!")
                    self.getPinAttributeNum("comment", pinID: self.commentIDCommentPinDetailView)
                }
                else {
                    print("Fail to unlike this comment pin!")
                }
            }
        }
    }
    
    func getPinAttributeNum(_ type: String, pinID: String) {
        let getPinAttr = FaePinAction()
        getPinAttr.getPinAttribute(type, commentId: pinID) {(status: Int, message: Any?) in
            let mapInfoJSON = JSON(message!)
            
            if let likes = mapInfoJSON["likes"].int {
                self.labelCommentPinLikeCount.text = "\(likes)"
            }
            if let _ = mapInfoJSON["saves"].int {
                
            }
            if let _ = mapInfoJSON["type"].string {
                
            }
            if let _ = mapInfoJSON["pin_id"].string {
                
            }
            if let comments = mapInfoJSON["comments"].int {
                self.labelCommentPinCommentsCount.text = "\(comments)"
            }
        }
    }
    
    func getPinAttributeCommentsNum(_ type: String, pinID: String) {
        let getPinAttr = FaePinAction()
        getPinAttr.getPinAttribute(type, commentId: pinID) {(status: Int, message: Any?) in
            let mapInfoJSON = JSON(message!)
            if let comments = mapInfoJSON["comments"].int {
                self.labelCommentPinCommentsCount.text = "\(comments)"
                self.numberOfCommentTableCells = comments
                self.tableCommentsForComment.reloadData()
            }
        }
    }
    
    func getPinComments(_ type: String, pinID: String, sendMessageFlag: Bool) {
        dictCommentsOnCommentDetail.removeAll()
        dictPeopleOfCommentDetail.removeAll()
        let getPinCommentsDetail = FaePinAction()
        getPinCommentsDetail.getPinComments(type, commentId: pinID) {(status: Int, message: Any?) in
            let commentsOfCommentJSON = JSON(message!)
            if commentsOfCommentJSON.count > 0 {
                for i in 0...(commentsOfCommentJSON.count-1) {
                    var dicCell = [String: AnyObject]()
                    var userID = -999
                    var latestDate = "NULL"
                    if let pin_comment_id = commentsOfCommentJSON[i]["pin_comment_id"].int {
                        dicCell["pin_comment_id"] = pin_comment_id as AnyObject?
                    }
                    
                    if let user_id = commentsOfCommentJSON[i]["user_id"].int {
                        dicCell["user_id"] = user_id as AnyObject?
                        if !self.dictPeopleOfCommentDetail.keys.contains(user_id) {
                            userID = user_id
                        }
                    }
                    if let content = commentsOfCommentJSON[i]["content"].string {
                        dicCell["content"] = content as AnyObject?
                    }
                    if let date = commentsOfCommentJSON[i]["created_at"].string {
                        dicCell["date"] = date.formatFaeDate() as AnyObject?
                        latestDate = date.formatFaeDate()
                    }
                    if let vote_up_count = commentsOfCommentJSON[i]["vote_up_count"].int {
                        print("[getPinComments] upVoteCount: \(vote_up_count)")
                        dicCell["vote_up_count"] = vote_up_count as AnyObject?
                    }
                    if let vote_down_count = commentsOfCommentJSON[i]["vote_down_count"].int {
                        print("[getPinComments] downVoteCount: \(vote_down_count)")
                        dicCell["vote_down_count"] = vote_down_count as AnyObject?
                    }
                    if let voteType = commentsOfCommentJSON[i]["pin_comment_operations"]["vote"].string {
                        dicCell["vote_type"] = voteType as AnyObject?
                    }
                    
                    self.dictCommentsOnCommentDetail.insert(dicCell, at: 0)
                    if userID != -999 {
                        self.dictPeopleOfCommentDetail[userID] = latestDate
                    }
                }
            }
            if sendMessageFlag {
                print("DEBUG RELOAD DATA")
                print(self.dictCommentsOnCommentDetail.count)
                self.numberOfCommentTableCells = self.dictCommentsOnCommentDetail.count
                //// Will figure out the UI presentation later
                /**
                var offset = self.commentDetailFullBoardScrollView.contentOffset
                **/
            }
            self.tableCommentsForComment.reloadData()
            self.tableViewPeople.reloadData()
        }
    }
    
    func getCommentInfo() {
        let getCommentById = FaeMap()
        getCommentById.getComment(commentIDCommentPinDetailView) {(status: Int, message: Any?) in
            let commentInfoJSON = JSON(message!)
            if let userid = commentInfoJSON["user_id"].int {
                print(user_id)
                if userid == Int(user_id) {
                    self.thisIsMyPin = true
                }
                else {
                    self.thisIsMyPin = false
                }
            }
            if let isLiked = commentInfoJSON["user_pin_operations"]["is_liked"].bool {
                if isLiked == false {
                    self.buttonCommentPinLike.setImage(UIImage(named: "commentPinLikeHollow"), for: UIControlState())
                    self.buttonCommentPinLike.tag = 0
                    if self.animatingHeart != nil {
                        self.animatingHeart.image = UIImage(named: "commentPinLikeHollow")
                    }
                }
                else {
                    self.buttonCommentPinLike.setImage(UIImage(named: "commentPinLikeFull"), for: UIControlState())
                    self.buttonCommentPinLike.tag = 1
                    if self.animatingHeart != nil {
                        self.animatingHeart.image = UIImage(named: "commentPinLikeFull")
                    }
                }
            }
            if let toGetUserName = commentInfoJSON["user_id"].int {
                let stringHeaderURL = "\(baseURL)/files/users/\(toGetUserName)/avatar"
                self.imageCommentPinUserAvatar.sd_setImage(with: URL(string: stringHeaderURL), placeholderImage: Key.sharedInstance.imageDefaultCover, options: .refreshCached)
                let getUserName = FaeUser()
                getUserName.getOthersProfile("\(toGetUserName)") {(status, message) in
                    let userProfile = JSON(message!)
                    if let username = userProfile["user_name"].string {
                        self.labelCommentPinUserName.text = username
                    }
                }
            }
            if let time = commentInfoJSON["created_at"].string {
                self.labelCommentPinTimestamp.text = time.formatFaeDate()
            }
            if let content = commentInfoJSON["content"].string {
                self.textviewCommentPinDetail.text = "\(content)"
            }
        }
    }
}
