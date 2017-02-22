//
//  PDAPIConnections.swift
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
    
    func getSeveralInfo() {
        getPinAttributeNum("\(self.pinTypeEnum)", pinID: pinIDPinDetailView)
        getPinInfo()
        getPinComments("\(self.pinTypeEnum)", pinID: pinIDPinDetailView, sendMessageFlag: false)
    }
    
    func checkPinStatus() {
        if pinStatus == "new" {
            let realm = try! Realm()
            let newPinRealm = realm.objects(NewFaePin.self).filter("pinId == \(self.pinIdSentBySegue) AND pinType == \(self.pinTypeDecimal)")
            if newPinRealm.count >= 1 {
                if newPinRealm.first != nil {
                    print("[checkPinStatus] newPin exists!")
                }
            }
            else if newPinRealm.count == 0 {
                let newPin = NewFaePin()
                newPin.pinId = Int(self.pinIdSentBySegue)!
                newPin.pinType = self.pinTypeDecimal
                try! realm.write {
                    realm.add(newPin)
                    print("[checkPinStatus] newPin written!")
                }
            }
            self.delegate?.changeIconImage(marker: pinMarker, type: "\(pinTypeEnum)", status: "normal")
        }
    }
    
    func commentThisPin(_ type: String, pinID: String, text: String) {
        let commentThisPin = FaePinAction()
        commentThisPin.whereKey("content", value: text)
        if pinIDPinDetailView != "-999" {
            commentThisPin.commentThisPin(type , pinID: pinID) {(status: Int, message: Any?) in
                if status == 201 {
                    print("Successfully comment this pin!")
                    self.getPinAttributeNum("\(self.pinTypeEnum)", pinID: self.pinIDPinDetailView)
                    self.getPinComments("\(self.pinTypeEnum)", pinID: self.pinIDPinDetailView, sendMessageFlag: true)
                }
                else {
                    print("Fail to comment this pin!")
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
                    print("[likeThisPin] Successfully like this pin!")
                    self.getPinAttributeNum("\(self.pinTypeEnum)", pinID: self.pinIDPinDetailView)
                }
                else {
                    print("Fail to like this pin!")
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
                    print("Successfully save this pin!")
                    self.getPinSavedState()
                    self.getPinAttributeNum("\(self.pinTypeEnum)", pinID: self.pinIDPinDetailView)
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
                    print("Fail to save this pin!")
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
                    print("Successfully unsave this pin!")
                    self.getPinSavedState()
                    self.getPinAttributeNum("\(self.pinTypeEnum)", pinID: self.pinIDPinDetailView)
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
                    print("Fail to unsave this pin!")
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
                    print("Successfully read this pin!")
                    self.pinStatus = "read"
                    self.delegate?.changeIconImage(marker: self.pinMarker, type: "\(self.pinTypeEnum)", status: self.pinStatus)
                }
                else {
                    print("Fail to read this pin!")
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
                    print("Successfully unlike this pin!")
                    self.getPinAttributeNum("\(self.pinTypeEnum)", pinID: self.pinIDPinDetailView)
                }
                else {
                    print("Fail to unlike this pin!")
                }
            }
        }
    }
    
    func getPinAttributeNum(_ type: String, pinID: String) {
        let getPinAttr = FaePinAction()
        getPinAttr.getPinAttribute(type, pinID: pinID) {(status: Int, message: Any?) in
            let mapInfoJSON = JSON(message!)
            var likesCount = 0
            var commentsCount = 0
            if let likes = mapInfoJSON["likes"].int {
                self.labelPinLikeCount.text = "\(likes)"
                likesCount = likes
            }
            if let _ = mapInfoJSON["saves"].int {
                
            }
            if let comments = mapInfoJSON["comments"].int {
                self.pinCommentsCount = comments
                self.labelPinCommentsCount.text = "\(comments)"
                commentsCount = comments
            }
            if likesCount >= 15 || commentsCount >= 10 {
                self.imageViewHotPin.isHidden = false
                self.pinStatus = "hot"
                if self.pinStatus == "read" {
                    self.pinStatus = "hot and read"
                }
                self.delegate?.changeIconImage(marker: self.pinMarker, type: "\(self.pinTypeEnum)", status: self.pinStatus)
            }
            else {
                self.imageViewHotPin.isHidden = true
            }
        }
    }
    
    func getPinComments(_ type: String, pinID: String, sendMessageFlag: Bool) {
        dictCommentsOnPinDetail.removeAll()
        self.tableCommentsForPin.reloadData()
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
                self.tableCommentsForPin.reloadData()
            }
        }
    }
    
    func getPinInfo() {
        self.buttonBackToPinLists.isEnabled = false
        let getPinById = FaeMap()
        getPinById.getPin(type: "\(self.pinTypeEnum)", pinId: pinIDPinDetailView) {(status: Int, message: Any?) in
            let opinType = "\(self.pinTypeEnum)"
            let opinId = self.pinIDPinDetailView
            var opinContent = ""
            var opinLat = self.selectedMarkerPosition.latitude
            var opinLon = self.selectedMarkerPosition.longitude
            var opinTime = ""
            let pinInfoJSON = JSON(message!)
//            print("[PinDetailViewController getPinInfo] id = \(self.pinIDPinDetailView) json = \(pinInfoJSON)")
            if let userid = pinInfoJSON["user_id"].int {
//                print(user_id)
                if userid == Int(user_id) {
                    self.thisIsMyPin = true
                }
                else {
                    self.thisIsMyPin = false
                }
            }
            if self.pinTypeEnum == .media {
                self.fileIdArray.removeAll()
                let fileIDs = pinInfoJSON["file_ids"].arrayValue.map({Int($0.string!)})
                for fileID in fileIDs {
                    if fileID != nil {
//                        print("[getPinInfo] fileID: \(fileID)")
                        self.fileIdArray.append(fileID!)
                        //Changed by Yao, decide to pass fileIdArray to editPinViewController rather than fileIdString
                    }
                }
                self.loadMedias()
//                print("[getPinInfo] fileIDs: \(self.fileIdArray)")
//                print("[getPinInfo] fileIDs append done!")
                if let content = pinInfoJSON["description"].string {
//                    print("[getPinInfo] description: \(content)")
                    self.stringPlainTextViewTxt = "\(content)"
                    self.textviewPinDetail.attributedText = "\(content)".convertStringWithEmoji()
                    opinContent = "\(content)"
                }
            }
            else if self.pinTypeEnum == .comment {
                if let content = pinInfoJSON["content"].string {
//                    print("[getPinInfo] description: \(content)")
                    self.stringPlainTextViewTxt = "\(content)"
                    self.textviewPinDetail.attributedText = "\(content)".convertStringWithEmoji()
                    opinContent = "\(content)"
                }
            }
            if let isLiked = pinInfoJSON["user_pin_operations"]["is_liked"].bool {
                if isLiked == false {
                    self.buttonPinLike.setImage(#imageLiteral(resourceName: "pinDetailLikeHeartHollowNew"), for: UIControlState())
                    self.buttonPinLike.tag = 0
                    if self.animatingHeart != nil {
                        self.animatingHeart.image = #imageLiteral(resourceName: "pinDetailLikeHeartHollowNew")
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
            if let isSaved = pinInfoJSON["user_pin_operations"]["is_saved"].bool {
                if isSaved == false {
                    self.isSavedByMe = false
                    self.imageViewSaved.image = #imageLiteral(resourceName: "pinUnsaved")
                }
                else {
                    self.isSavedByMe = true
                    self.imageViewSaved.image = #imageLiteral(resourceName: "pinSaved")
                }
            }
            if let toGetUserName = pinInfoJSON["user_id"].int {
                let stringHeaderURL = "\(baseURL)/files/users/\(toGetUserName)/avatar"
                self.imagePinUserAvatar.sd_setImage(with: URL(string: stringHeaderURL), placeholderImage: Key.sharedInstance.imageDefaultCover, options: .refreshCached)
                self.imagePinUserAvatar.sd_setImage(with: URL(string: stringHeaderURL), placeholderImage: Key.sharedInstance.imageDefaultMale, options: [.retryFailed, .refreshCached], completed: { (image, error, SDImageCacheType, imageURL) in
                    if image != nil {
                        UIView.animate(withDuration: 0.2, animations: { 
                            self.imagePinUserAvatar.alpha = 1
                        })
                    }
                })
                let getUserName = FaeUser()
                getUserName.getNamecardOfSpecificUser("\(toGetUserName)") {(status, message) in
                    let userProfile = JSON(message!)
                    if let username = userProfile["nick_name"].string {
                        self.labelPinUserName.text = username
                    } else {
                        self.labelPinUserName.text = "Anonymous"
                    }
                }
            }
            if let time = pinInfoJSON["created_at"].string {
                self.labelPinTimestamp.text = time.formatFaeDate()
                opinTime = time
            }
            
            if let latitudeInfo = pinInfoJSON["geolocation"]["latitude"].double {
                opinLat = latitudeInfo
            }
            else {
                print("DEBUG: Cannot get geoInfo: Latitude")
                return
            }
            if let longitudeInfo = pinInfoJSON["geolocation"]["longitude"].double {
                opinLon = longitudeInfo
            }
            else {
                print("DEBUG: Cannot get geoInfo: Longitude")
                return
            }
            
            let realm = try! Realm()
            let opinListElem = OPinListElem()
            opinListElem.pinTypeId = "\(opinType)\(opinId)"
            opinListElem.pinContent = opinContent
            opinListElem.pinLat = opinLat
            opinListElem.pinLon = opinLon
            opinListElem.pinTime = opinTime
            try! realm.write {
                realm.add(opinListElem, update: true)
                self.buttonBackToPinLists.isEnabled = true
            }
        }
    }
    
    func getPinSavedState() {
        let getPinSavedState = FaeMap()
        getPinSavedState.getPin(type: "\(self.pinTypeEnum)", pinId: pinIDPinDetailView) {(status: Int, message: Any?) in
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
