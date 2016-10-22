//
//  CommentPinDetailAPIConnections.swift
//  faeBeta
//
//  Created by Yue on 10/18/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
import SwiftyJSON

extension CommentPinViewController {
    // Like comment pin
    func actionLikeThisComment(sender: UIButton) {
        buttonCommentPinLike.setImage(UIImage(named: "commentPinLikeFull"), forState: .Normal)
        buttonCommentPinUpVote.setImage(UIImage(named: "commentPinUpVoteRed"), forState: .Normal)
        buttonCommentPinDownVote.setImage(UIImage(named: "commentPinDownVoteGray"), forState: .Normal)
        
        if animatingHeart != nil {
            animatingHeart.image = UIImage(named: "commentPinLikeFull")
        }
        
        isUpVoting = true
        isDownVoting = false
        
        animateHeart()
        
        if commentIDCommentPinDetailView != "-999" {
            likeThisPin("comment", pinID: commentIDCommentPinDetailView)
        }
    }
    
    // Upvote comment pin
    func actionUpvoteThisComment(sender: UIButton) {
        if isUpVoting {
            return
        }
        
        buttonCommentPinLike.setImage(UIImage(named: "commentPinLikeFull"), forState: .Normal)
        buttonCommentPinUpVote.setImage(UIImage(named: "commentPinUpVoteRed"), forState: .Normal)
        buttonCommentPinDownVote.setImage(UIImage(named: "commentPinDownVoteGray"), forState: .Normal)
        
        if animatingHeart != nil {
            animatingHeart.image = UIImage(named: "commentPinLikeFull")
        }
        
        isUpVoting = true
        isDownVoting = false
        
        if commentIDCommentPinDetailView != "-999" {
            likeThisPin("comment", pinID: commentIDCommentPinDetailView)
        }
    }
    
    // Down vote comment pin
    func actionDownVoteThisComment(sender: UIButton) {
        if isDownVoting {
            return
        }
        
        buttonCommentPinLike.setImage(UIImage(named: "commentPinLikeHollow"), forState: .Normal)
        buttonCommentPinUpVote.setImage(UIImage(named: "commentPinUpVoteGray"), forState: .Normal)
        buttonCommentPinDownVote.setImage(UIImage(named: "commentPinDownVoteRed"), forState: .Normal)
        
        if animatingHeart != nil {
            animatingHeart.image = UIImage(named: "commentPinLikeHollow")
        }
        
        isUpVoting = false
        isDownVoting = true
        
        if commentIDCommentPinDetailView != "-999" {
            unlikeThisPin("comment", pinID: commentIDCommentPinDetailView)
        }
    }
    
    func likeThisPin(type: String, pinID: String) {
        let likeThisPin = FaePinAction()
        likeThisPin.whereKey("", value: "")
        if commentIDCommentPinDetailView != "-999" {
            likeThisPin.likeThisPin(type , commentId: pinID) {(status: Int, message: AnyObject?) in
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
    
    func saveThisPin(type: String, pinID: String) {
        let saveThisPin = FaePinAction()
        saveThisPin.whereKey("", value: "")
        if commentIDCommentPinDetailView != "-999" {
            saveThisPin.saveThisPin(type , commentId: pinID) {(status: Int, message: AnyObject?) in
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
    
    func unlikeThisPin(type: String, pinID: String) {
        let unlikeThisPin = FaePinAction()
        unlikeThisPin.whereKey("", value: "")
        if commentIDCommentPinDetailView != "-999" {
            unlikeThisPin.unlikeThisPin(type , commentID: pinID) {(status: Int, message: AnyObject?) in
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
    
    func getPinAttributeNum(type: String, pinID: String) {
        let getPinAttr = FaePinAction()
        getPinAttr.getPinAttribute(type, commentId: pinID) {(status: Int, message: AnyObject?) in
            let mapInfoJSON = JSON(message!)
            
            if let likes = mapInfoJSON["likes"].int {
                self.labelCommentPinLikeCount.text = "\(likes)"
                self.labelCommentPinVoteCount.text = "\(likes)"
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
    
    func getPinAttributeCommentsNum(type: String, pinID: String) {
        let getPinAttr = FaePinAction()
        getPinAttr.getPinAttribute(type, commentId: pinID) {(status: Int, message: AnyObject?) in
            let mapInfoJSON = JSON(message!)
            if let comments = mapInfoJSON["comments"].int {
                self.labelCommentPinCommentsCount.text = "\(comments)"
                self.numberOfCommentTableCells = comments
                self.tableCommentsForComment.reloadData()
            }
        }
    }
    
    func getPinComments(type: String, pinID: String) {
        dictCommentsOnCommentDetail.removeAll()
        let getPinCommentsDetail = FaePinAction()
        getPinCommentsDetail.getPinComments(type, commentId: pinID) {(status: Int, message: AnyObject?) in
            let commentsOfCommentJSON = JSON(message!)
            if commentsOfCommentJSON.count > 0 {
                for i in 0...(commentsOfCommentJSON.count-1) {
                    var dicCell = [String: AnyObject]()
                    if let pin_comment_id = commentsOfCommentJSON[i]["pin_comment_id"].string {
                        dicCell["pin_comment_id"] = pin_comment_id
                    }
                    
                    if let user_id = commentsOfCommentJSON[i]["user_id"].int {
                        dicCell["user_id"] = user_id
                    }
                    if let content = commentsOfCommentJSON[i]["content"].string {
                        dicCell["content"] = content
                    }
                    if let date = commentsOfCommentJSON[i]["created_at"]["date"].string {
                        dicCell["date"] = date
                    }
                    if let timezone_type = commentsOfCommentJSON[i]["created_at"]["timezone_type"].int {
                        dicCell["timezone_type"] = timezone_type
                    }
                    if let timezone = commentsOfCommentJSON[i]["created_at"]["timezone"].string {
                        dicCell["timezone"] = timezone
                    }
                    self.dictCommentsOnCommentDetail.append(dicCell)
                }
            }
        }
    }
    
    func getCommentInfo() {
        let getCommentById = FaeMap()
        getCommentById.getComment(commentIDCommentPinDetailView) {(status: Int, message: AnyObject?) in
            let commentInfoJSON = JSON(message!)
            if let isLiked = commentInfoJSON["user_pin_operations"]["is_liked"].bool {
                if isLiked == false {
                    self.buttonCommentPinLike.setImage(UIImage(named: "commentPinLikeHollow"), forState: .Normal)
                    self.buttonCommentPinUpVote.setImage(UIImage(named: "commentPinUpVoteGray"), forState: .Normal)
                    self.buttonCommentPinDownVote.setImage(UIImage(named: "commentPinDownVoteRed"), forState: .Normal)
                    if self.animatingHeart != nil {
                        self.animatingHeart.image = UIImage(named: "commentPinLikeHollow")
                    }
                    self.isUpVoting = false
                    self.isDownVoting = true
                }
                else {
                    self.buttonCommentPinLike.setImage(UIImage(named: "commentPinLikeFull"), forState: .Normal)
                    self.buttonCommentPinUpVote.setImage(UIImage(named: "commentPinUpVoteRed"), forState: .Normal)
                    self.buttonCommentPinDownVote.setImage(UIImage(named: "commentPinDownVoteGray"), forState: .Normal)
                    if self.animatingHeart != nil {
                        self.animatingHeart.image = UIImage(named: "commentPinLikeFull")
                    }
                    self.isUpVoting = true
                    self.isDownVoting = false
                }
            }
            if let toGetUserName = commentInfoJSON["user_id"].int {
                let getUserName = FaeUser()
                getUserName.getOthersProfile("\(toGetUserName)") {(status, message) in
                    let userProfile = JSON(message!)
                    if let username = userProfile["user_name"].string {
                        self.labelCommentPinUserName.text = username
//                        cell.userID = username
                    }
                }
            }
            if let time = commentInfoJSON["created_at"].string {
                self.labelCommentPinTimestamp.text = "\(time)"
//                cell.time.text = "\(time)"
            }
            if let content = commentInfoJSON["content"].string {
                self.textviewCommentPinDetail.text = "\(content)"
//                cell.content.text = "\(content)"
            }
        }
    }
}
