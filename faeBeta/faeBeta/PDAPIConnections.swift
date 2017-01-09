//
//  MPDAPIConnections.swift
//  faeBeta
//
//  Created by Yue on 12/2/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
import SwiftyJSON
import SDWebImage
import RealmSwift

extension PinDetailViewController {
    // Like comment pin
    func actionLikeThisPin(_ sender: UIButton) {
        endEdit()
        
        if animatingHeartTimer != nil {
            animatingHeartTimer.invalidate()
        }
        
        if sender.tag == 1 && pinIDPinDetailView != "-999" {
            buttonPinLike.setImage(#imageLiteral(resourceName: "pinDetailLikeHeartHollow"), for: UIControlState())
            if animatingHeart != nil {
                animatingHeart.image = nil
            }
            unlikeThisPin("media", pinID: pinIDPinDetailView)
            print("debug animating sender.tag 1")
            print(sender.tag)
            sender.tag = 0
            return
        }
        
        if sender.tag == 0 && pinIDPinDetailView != "-999" {
            buttonPinLike.setImage(#imageLiteral(resourceName: "pinDetailLikeHeartFull"), for: UIControlState())
            self.animateHeart()
            likeThisPin("media", pinID: pinIDPinDetailView)
            print("debug animating sender.tag 0")
            print(sender.tag)
            sender.tag = 1
        }
    }
    
    func actionHoldingLikeButton(_ sender: UIButton) {
        endEdit()
        buttonPinLike.setImage(#imageLiteral(resourceName: "pinDetailLikeHeartFull"), for: UIControlState())
        animatingHeartTimer = Timer.scheduledTimer(timeInterval: 0.15, target: self, selector: #selector(CommentPinDetailViewController.animateHeart), userInfo: nil, repeats: true)
    }
    
    // Upvote comment pin
    func actionUpvoteThisComment(_ sender: UIButton) {
        if isUpVoting {
            return
        }
        
        buttonPinLike.setImage(#imageLiteral(resourceName: "pinDetailLikeHeartFull"), for: UIControlState())
        
        if animatingHeart != nil {
            animatingHeart.image = #imageLiteral(resourceName: "pinDetailLikeHeartFull")
        }
        
        if pinIDPinDetailView != "-999" {
            likeThisPin("media", pinID: pinIDPinDetailView)
        }
    }
    
    // Down vote comment pin
    func actionDownVoteThisComment(_ sender: UIButton) {
        buttonPinLike.setImage(#imageLiteral(resourceName: "pinDetailLikeHeartHollow"), for: UIControlState())
        if animatingHeart != nil {
            animatingHeart.image = #imageLiteral(resourceName: "pinDetailLikeHeartHollow")
        }
        if pinIDPinDetailView != "-999" {
            unlikeThisPin("media", pinID: pinIDPinDetailView)
        }
    }
    
    func commentThisPin(_ type: String, pinID: String, text: String) {
        let commentThisPin = FaePinAction()
        commentThisPin.whereKey("content", value: text)
        if pinIDPinDetailView != "-999" {
            commentThisPin.commentThisPin(type , pinID: pinID) {(status: Int, message: Any?) in
                if status == 201 {
                    print("Successfully comment this comment pin!")
                    self.getPinAttributeNum("media", pinID: self.pinIDPinDetailView)
                    self.getPinComments("media", pinID: self.pinIDPinDetailView, sendMessageFlag: true)
                    self.tableCommentsForPin.reloadData()
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
        if pinIDPinDetailView != "-999" {
            likeThisPin.likeThisPin(type , pinID: pinID) {(status: Int, message: Any?) in
                if status == 201 {
                    print("[likeThisPin] Successfully like this media pin!")
                    self.getPinAttributeNum("media", pinID: self.pinIDPinDetailView)
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
        if pinIDPinDetailView != "-999" {
            saveThisPin.saveThisPin(type , pinID: pinID) {(status: Int, message: Any?) in
                if status / 100 == 2 {
                    print("Successfully save this comment pin!")
                    self.getPinSavedState()
                    self.getPinAttributeNum("media", pinID: self.pinIDPinDetailView)
                    UIView.animate(withDuration: 0.5, animations: ({
                        self.imageViewSaved.alpha = 1.0
                    }), completion: { (done: Bool) in
                        if done {
                            UIView.animate(withDuration: 0.5, delay: 1.0, options: [], animations: {
                                self.imageViewSaved.alpha = 0.0
                            }, completion: nil)
                        }
                    })
                }
                else {
                    print("Fail to save this comment pin!")
                }
            }
        }
    }
    
    func unsaveThisPin(_ type: String, pinID: String) {
        let unsaveThisPin = FaePinAction()
        unsaveThisPin.whereKey("", value: "")
        if pinIDPinDetailView != "-999" {
            unsaveThisPin.unsaveThisPin(type , pinID: pinID) {(status: Int, message: Any?) in
                if status / 100 == 2 {
                    print("Successfully unsave this comment pin!")
                    self.getPinSavedState()
                    self.getPinAttributeNum("media", pinID: self.pinIDPinDetailView)
                    UIView.animate(withDuration: 0.5, animations: ({
                        self.imageViewSaved.alpha = 1.0
                    }), completion: { (done: Bool) in
                        if done {
                            UIView.animate(withDuration: 0.5, delay: 1.0, options: [], animations: {
                                self.imageViewSaved.alpha = 0.0
                            }, completion: nil)
                        }
                    })
                }
                else {
                    print("Fail to unsave this comment pin!")
                }
            }
        }
    }
    
    // Have read this pin
    func readThisPin(_ type: String, pinID: String) {
        let readThisPin = FaePinAction()
        readThisPin.whereKey("", value: "")
        if pinIDPinDetailView != "-999" {
            readThisPin.haveReadThisPin(type , pinID: pinID) {(status: Int, message: Any?) in
                if status / 100 == 2 {
                    print("Successfully read this comment pin!")
                }
                else {
                    print("Fail to read this comment pin!")
                }
            }
        }
    }
    
    func unlikeThisPin(_ type: String, pinID: String) {
        let unlikeThisPin = FaePinAction()
        unlikeThisPin.whereKey("", value: "")
        if pinIDPinDetailView != "-999" {
            unlikeThisPin.unlikeThisPin(type , pinID: pinID) {(status: Int, message: Any?) in
                if status/100 == 2 {
                    print("Successfully unlike this comment pin!")
                    self.getPinAttributeNum("media", pinID: self.pinIDPinDetailView)
                }
                else {
                    print("Fail to unlike this comment pin!")
                }
            }
        }
    }
    
    func getPinAttributeNum(_ type: String, pinID: String) {
        let getPinAttr = FaePinAction()
        getPinAttr.getPinAttribute(type, pinID: pinID) {(status: Int, message: Any?) in
            let mapInfoJSON = JSON(message!)
            
            if let likes = mapInfoJSON["likes"].int {
                self.labelPinLikeCount.text = "\(likes)"
            }
            if let _ = mapInfoJSON["saves"].int {
                
            }
            if let comments = mapInfoJSON["comments"].int {
                self.labelPinCommentsCount.text = "\(comments)"
            }
        }
    }
    
    func getPinAttributeCommentsNum(_ type: String, pinID: String) {
        let getPinAttr = FaePinAction()
        getPinAttr.getPinAttribute(type, pinID: pinID) {(status: Int, message: Any?) in
            let mapInfoJSON = JSON(message!)
            if let comments = mapInfoJSON["comments"].int {
                self.labelPinCommentsCount.text = "\(comments)"
                self.numberOfCommentTableCells = comments
            }
        }
    }
    
    func getPinComments(_ type: String, pinID: String, sendMessageFlag: Bool) {
        dictCommentsOnPinDetail.removeAll()
        let getPinCommentsDetail = FaePinAction()
        getPinCommentsDetail.getPinComments(type, pinID: pinID) {(status: Int, message: Any?) in
            let commentsOfCommentJSON = JSON(message!)
            if commentsOfCommentJSON.count > 0 {
                for i in 0...(commentsOfCommentJSON.count-1) {
                    var dicCell = [String: AnyObject]()
                    if let pin_comment_id = commentsOfCommentJSON[i]["pin_comment_id"].int {
                        dicCell["pin_comment_id"] = pin_comment_id as AnyObject?
                    }
                    
                    if let user_id = commentsOfCommentJSON[i]["user_id"].int {
                        dicCell["user_id"] = user_id as AnyObject?
                    }
                    if let content = commentsOfCommentJSON[i]["content"].string {
                        dicCell["content"] = content as AnyObject?
                    }
                    if let date = commentsOfCommentJSON[i]["created_at"].string {
                        dicCell["date"] = date.formatFaeDate() as AnyObject?
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
                    
                    self.dictCommentsOnPinDetail.insert(dicCell, at: 0)
                }
            }
            if sendMessageFlag {
                print("DEBUG RELOAD DATA")
                print(self.dictCommentsOnPinDetail.count)
                self.numberOfCommentTableCells = self.dictCommentsOnPinDetail.count
                //// Will figure out the UI presentation later
                /**
                 var offset = self.commentDetailFullBoardScrollView.contentOffset
                 **/
            }
        }
    }
    
    func getPinInfo() {
        let getCommentById = FaeMap()
        getCommentById.getPin(type: "media", pinId: pinIDPinDetailView) {(status: Int, message: Any?) in
            let commentInfoJSON = JSON(message!)
            print("[PinDetailViewController getPinInfo] id = \(self.pinIDPinDetailView) json = \(commentInfoJSON)")
            if let userid = commentInfoJSON["user_id"].int {
                print(user_id)
                if userid == Int(user_id) {
                    self.thisIsMyPin = true
                }
                else {
                    self.thisIsMyPin = false
                }
            }
            self.fileIdArray.removeAll()
            let fileIDs = commentInfoJSON["file_ids"].arrayValue.map({Int($0.string!)})
            for fileID in fileIDs {
                if fileID != nil {
                    print("[getPinInfo] fileID: \(fileID)")
                    self.fileIdArray.append(fileID!)
                    if self.fileIdString == "" {
                        self.fileIdString = "\(fileID!)"
                    }else{
                        self.fileIdString = "\(self.fileIdString);\(fileID!)"
                    }
                }
            }
            self.loadMedias()
            print("[getPinInfo] fileIDs: \(self.fileIdArray)")
            print("[getPinInfo] fileIDs append done!")
            if let isLiked = commentInfoJSON["user_pin_operations"]["is_liked"].bool {
                if isLiked == false {
                    self.buttonPinLike.setImage(#imageLiteral(resourceName: "pinDetailLikeHeartHollow"), for: UIControlState())
                    self.buttonPinLike.tag = 0
                    if self.animatingHeart != nil {
                        self.animatingHeart.image = #imageLiteral(resourceName: "pinDetailLikeHeartHollow")
                    }
                }
                else {
                    self.buttonPinLike.setImage(#imageLiteral(resourceName: "pinDetailLikeHeartFull"), for: UIControlState())
                    self.buttonPinLike.tag = 1
                    if self.animatingHeart != nil {
                        self.animatingHeart.image = #imageLiteral(resourceName: "pinDetailLikeHeartFull")
                    }
                }
            }
            if let isSaved = commentInfoJSON["user_pin_operations"]["is_saved"].bool {
                if isSaved == false {
                    self.isSavedByMe = false
                    self.imageViewSaved.image = #imageLiteral(resourceName: "pinUnsaved")
                }
                else {
                    self.isSavedByMe = true
                    self.imageViewSaved.image = #imageLiteral(resourceName: "pinSaved")
                }
            }
            if let toGetUserName = commentInfoJSON["user_id"].int {
                let stringHeaderURL = "\(baseURL)/files/users/\(toGetUserName)/avatar"
                self.imagePinUserAvatar.sd_setImage(with: URL(string: stringHeaderURL), placeholderImage: Key.sharedInstance.imageDefaultCover, options: .refreshCached)
                let getUserName = FaeUser()
                getUserName.getNamecardOfSpecificUser("\(toGetUserName)") {(status, message) in
                    let userProfile = JSON(message!)
                    if let username = userProfile["nick_name"].string {
                        self.labelPinUserName.text = username
                    }
                }
            }
            if let time = commentInfoJSON["created_at"].string {
                self.labelPinTimestamp.text = time.formatFaeDate()
            }
            if let content = commentInfoJSON["description"].string {
                print("[getPinInfo] description: \(content)")
                self.textviewPinDetail.text = "\(content)"
            }
        }
    }
    
    func getPinSavedState() {
        let getPinSavedState = FaeMap()
        getPinSavedState.getPin(type: "media", pinId: pinIDPinDetailView) {(status: Int, message: Any?) in
            let commentInfoJSON = JSON(message!)
            if let isSaved = commentInfoJSON["user_pin_operations"]["is_saved"].bool {
                if isSaved == false {
                    self.isSavedByMe = false
                    self.imageViewSaved.image = #imageLiteral(resourceName: "pinUnsaved")
                }
                else {
                    self.isSavedByMe = true
                    self.imageViewSaved.image = #imageLiteral(resourceName: "pinSaved")
                }
            }
        }
    }
}
