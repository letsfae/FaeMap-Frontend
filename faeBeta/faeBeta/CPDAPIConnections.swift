//
//  CommentPinDetailAPIConnections.swift
//  faeBeta
//
//  Created by Yue on 10/18/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
import SwiftyJSON
import SDWebImage

extension CommentPinViewController {
    // Like comment pin
    func actionLikeThisComment(sender: UIButton) {
        endEdit()
        if animatingHeartTimer != nil {
            animatingHeartTimer.invalidate()
        }
        
        if sender.tag == 0 && commentIDCommentPinDetailView != "-999" {
            sender.tag = 1
            buttonCommentPinLike.setImage(UIImage(named: "commentPinLikeFull"), forState: .Normal)
            likeThisPin("comment", pinID: commentIDCommentPinDetailView)
            return
        }
        
        if sender.tag == 1 && commentIDCommentPinDetailView != "-999" {
            sender.tag = 0
            buttonCommentPinLike.setImage(UIImage(named: "commentPinLikeHollow"), forState: .Normal)
            unlikeThisPin("comment", pinID: commentIDCommentPinDetailView)
        }
    }
    
    func actionHoldingLikeButton(sender: UIButton) {
        endEdit()
        likeButtonIsHolding = true
        buttonCommentPinLike.setImage(UIImage(named: "commentPinLikeFull"), forState: .Normal)
        animatingHeartTimer = NSTimer.scheduledTimerWithTimeInterval(0.15, target: self, selector: #selector(CommentPinViewController.animateHeart), userInfo: nil, repeats: true)
    }
    
    // Upvote comment pin
    func actionUpvoteThisComment(sender: UIButton) {
        if isUpVoting {
            return
        }
        
        buttonCommentPinLike.setImage(UIImage(named: "commentPinLikeFull"), forState: .Normal)
        
        if animatingHeart != nil {
            animatingHeart.image = UIImage(named: "commentPinLikeFull")
        }
        
        if commentIDCommentPinDetailView != "-999" {
            likeThisPin("comment", pinID: commentIDCommentPinDetailView)
        }
    }
    
    // Down vote comment pin
    func actionDownVoteThisComment(sender: UIButton) {
        buttonCommentPinLike.setImage(UIImage(named: "commentPinLikeHollow"), forState: .Normal)
        if animatingHeart != nil {
            animatingHeart.image = UIImage(named: "commentPinLikeHollow")
        }
        if commentIDCommentPinDetailView != "-999" {
            unlikeThisPin("comment", pinID: commentIDCommentPinDetailView)
        }
    }
    
    func commentThisPin(type: String, pinID: String, text: String) {
        let commentThisPin = FaePinAction()
        commentThisPin.whereKey("content", value: text)
        if commentIDCommentPinDetailView != "-999" {
            commentThisPin.commentThisPin(type , commentId: pinID) {(status: Int, message: AnyObject?) in
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
                    print(status)
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
//                self.labelCommentPinVoteCount.text = "\(likes)"
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
    
    func getPinComments(type: String, pinID: String, sendMessageFlag: Bool) {
        dictCommentsOnCommentDetail.removeAll()
        dictPeopleOfCommentDetail.removeAll()
        let getPinCommentsDetail = FaePinAction()
        getPinCommentsDetail.getPinComments(type, commentId: pinID) {(status: Int, message: AnyObject?) in
            let commentsOfCommentJSON = JSON(message!)
            if commentsOfCommentJSON.count > 0 {
                for i in 0...(commentsOfCommentJSON.count-1) {
                    var dicCell = [String: AnyObject]()
                    var userID = -999
                    var latestDate = "NULL"
                    if let pin_comment_id = commentsOfCommentJSON[i]["pin_comment_id"].string {
                        dicCell["pin_comment_id"] = pin_comment_id
                    }
                    
                    if let user_id = commentsOfCommentJSON[i]["user_id"].int {
                        dicCell["user_id"] = user_id
                        if !self.dictPeopleOfCommentDetail.keys.contains(user_id) {
                            userID = user_id
                        }
                    }
                    if let content = commentsOfCommentJSON[i]["content"].string {
                        dicCell["content"] = content
                    }
                    if let date = commentsOfCommentJSON[i]["created_at"].string {
                        dicCell["date"] = date.formatFaeDate()
                        latestDate = date.formatFaeDate()
                    }
                    if let timezone_type = commentsOfCommentJSON[i]["created_at"]["timezone_type"].int {
                        dicCell["timezone_type"] = timezone_type
                    }
                    if let timezone = commentsOfCommentJSON[i]["created_at"]["timezone"].string {
                        dicCell["timezone"] = timezone
                    }
                    self.dictCommentsOnCommentDetail.insert(dicCell, atIndex: 0)
                    if userID != -999 {
                        self.dictPeopleOfCommentDetail[userID] = latestDate
                    }
                }
            }
            if sendMessageFlag {
                print("DEBUG RELOAD DATA")
                print(self.dictCommentsOnCommentDetail.count)
                self.numberOfCommentTableCells = self.dictCommentsOnCommentDetail.count
                self.tableCommentsForComment.frame.size.height += 140
                self.commentDetailFullBoardScrollView.contentSize.height += 140
                //// Will figure out the UI presentation later
                /**
                var offset = self.commentDetailFullBoardScrollView.contentOffset
                offset.y = self.commentDetailFullBoardScrollView.contentSize.height + self.commentDetailFullBoardScrollView.contentInset.bottom - self.commentDetailFullBoardScrollView.bounds.size.height
                self.commentDetailFullBoardScrollView.setContentOffset(offset, animated: true)
                **/
            }
            let newHeight = CGFloat(140 * self.dictCommentsOnCommentDetail.count)
            self.commentDetailFullBoardScrollView.contentSize.height = newHeight + 281
            self.tableCommentsForComment.frame.size.height = newHeight
            self.tableCommentsForComment.reloadData()
            self.tableViewPeople.reloadData()
        }
    }
    
    func getCommentInfo() {
        let getCommentById = FaeMap()
        getCommentById.getComment(commentIDCommentPinDetailView) {(status: Int, message: AnyObject?) in
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
                    self.buttonCommentPinLike.setImage(UIImage(named: "commentPinLikeHollow"), forState: .Normal)
                    self.buttonCommentPinLike.tag = 0
                    if self.animatingHeart != nil {
                        self.animatingHeart.image = UIImage(named: "commentPinLikeHollow")
                    }
                }
                else {
                    self.buttonCommentPinLike.setImage(UIImage(named: "commentPinLikeFull"), forState: .Normal)
                    self.buttonCommentPinLike.tag = 1
                    if self.animatingHeart != nil {
                        self.animatingHeart.image = UIImage(named: "commentPinLikeFull")
                    }
                }
            }
            if let toGetUserName = commentInfoJSON["user_id"].int {
                let stringHeaderURL = "https://api.letsfae.com/files/users/\(toGetUserName)/avatar"
                self.imageCommentPinUserAvatar.sd_setImageWithURL(NSURL(string: stringHeaderURL), placeholderImage: Key.sharedInstance.imageDefaultCover, options: .RefreshCached)
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
    
    func getAndSetUserAvatar(userAvatar: UIImageView, userID: Int) {
        let stringHeaderURL = "https://api.letsfae.com/files/users/\(userID)/avatar"
        let block = {(image: UIImage!, error: NSError!, cacheType: SDImageCacheType, imageURL: NSURL!) -> Void in
            // completion code here
            if userAvatar.image != nil {
                let croppedImage = self.cropToBounds(userAvatar.image!)
                userAvatar.image = croppedImage
            }
        }
        userAvatar.sd_setImageWithURL(NSURL(string: stringHeaderURL), placeholderImage: UIImage(named: "defaultMan"), completed: block)
    }
}
