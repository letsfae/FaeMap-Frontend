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
    
    func getPinInfo() {
        self.buttonBackToPinLists.isEnabled = false
        let getPinById = FaeMap()
        getPinById.getPin(type: "\(self.pinTypeEnum)", pinId: pinIDPinDetailView) {(status: Int, message: Any?) in
            let pinInfoJSON = JSON(message!)
            // Time
            self.labelPinTimestamp.text = pinInfoJSON["created_at"].stringValue.formatFaeDate()
            // Check if pin is mine
            if let userid = pinInfoJSON["user_id"].int {
                if userid == Int(user_id) {
                    self.thisIsMyPin = true
                } else {
                    self.thisIsMyPin = false
                }
            }
            // Feelings
            self.feelingArray.removeAll()
            let feelings = pinInfoJSON["feeling_count"].arrayValue.map({Int($0.stringValue)})
            for feeling in feelings {
                if feeling != nil {
                    self.feelingArray.append(feeling!)
                }
            }
            if self.tableMode == .feelings {
                self.tableCommentsForPin.reloadData()
            }
            self.loadFeelingQuickView()
            // Images
            if self.pinTypeEnum == .media {
                self.fileIdArray.removeAll()
                let fileIDs = pinInfoJSON["file_ids"].arrayValue.map({Int($0.stringValue)})
                for fileID in fileIDs {
                    if fileID != nil {
                        self.fileIdArray.append(fileID!)
                    }
                }
                self.loadMedias()
                self.stringPlainTextViewTxt = pinInfoJSON["description"].stringValue
                self.textviewPinDetail.attributedText = self.stringPlainTextViewTxt.convertStringWithEmoji()
            } else if self.pinTypeEnum == .comment {
                self.stringPlainTextViewTxt = pinInfoJSON["content"].stringValue
                self.textviewPinDetail.attributedText = self.stringPlainTextViewTxt.convertStringWithEmoji()
            }
            // Liked or not
            if !pinInfoJSON["user_pin_operations"]["is_liked"].boolValue {
                self.buttonPinLike.setImage(#imageLiteral(resourceName: "pinDetailLikeHeartHollowNew"), for: UIControlState())
                self.buttonPinLike.tag = 0
                if self.animatingHeart != nil {
                    self.animatingHeart.image = #imageLiteral(resourceName: "pinDetailLikeHeartHollowNew")
                }
            } else {
                self.buttonPinLike.setImage(#imageLiteral(resourceName: "pinDetailLikeHeartFull"), for: UIControlState())
                self.buttonPinLike.tag = 1
                if self.animatingHeart != nil {
                    self.animatingHeart.image = #imageLiteral(resourceName: "pinDetailLikeHeartFull")
                }
            }
            // Saved or not
            if !pinInfoJSON["user_pin_operations"]["is_saved"].boolValue {
                self.isSavedByMe = false
                self.imageViewSaved.image = #imageLiteral(resourceName: "pinUnsaved")
            } else {
                self.isSavedByMe = true
                self.imageViewSaved.image = #imageLiteral(resourceName: "pinSaved")
            }
            // Get nick name
            if pinInfoJSON["anonymous"].boolValue {
                self.labelPinUserName.text = "Someone"
            } else {
                self.labelPinUserName.text = pinInfoJSON["nick_name"].stringValue
            }
            // Get avatar
            if let pinUserId = pinInfoJSON["user_id"].int {
                let stringHeaderURL = "\(baseURL)/files/users/\(pinUserId)/avatar"
                self.imagePinUserAvatar.sd_setImage(with: URL(string: stringHeaderURL), placeholderImage: Key.sharedInstance.imageDefaultMale, options: [.retryFailed, .refreshCached], completed: { (image, error, SDImageCacheType, imageURL) in
                    UIView.animate(withDuration: 0.2, animations: {
                        self.imagePinUserAvatar.alpha = 1
                    })
                })
            }
        }
    }
    
    func postFeeling(_ sender: UIButton) {
        let postFeeling = FaePinAction()
        postFeeling.whereKey("feeling", value: "\(sender.tag)")
        postFeeling.postFeelingToPin("\(self.pinTypeEnum)", pinID: pinIDPinDetailView) { (status, message) in
            if status / 100 != 2 {
                return
            }
            let xOffset = Int(sender.tag * 52 + 12)
            sender.frame = CGRect(x: xOffset, y: 3, width: 48, height: 48)
            let getPinById = FaeMap()
            getPinById.getPin(type: "\(self.pinTypeEnum)", pinId: self.pinIDPinDetailView) {(status: Int, message: Any?) in
                let pinInfoJSON = JSON(message!)
                self.feelingArray.removeAll()
                let feelings = pinInfoJSON["feeling_count"].arrayValue.map({Int($0.stringValue)})
                for feeling in feelings {
                    if feeling != nil {
                        self.feelingArray.append(feeling!)
                    }
                }
                if self.tableMode == .feelings {
                    self.tableCommentsForPin.reloadData()
                }
                self.loadFeelingQuickView()
            }
        }
    }
    
    func loadFeelingQuickView() {
        uiviewFeeling.removeFromSuperview()
        uiviewFeeling = UIView(frame: CGRect(x: 14, y: 0, width: screenWidth - 180, height: 27))
        uiviewPinDetailMainButtons.addSubview(uiviewFeeling)
        uiviewFeeling.layer.zPosition = 109
        var count = 0
        for i in 0..<feelingArray.count {
            if feelingArray[i] != 0 {
                let offset = count * 30
                let feeling = UIImageView(frame: CGRect(x: offset, y: 0, width: 27, height: 27))
                if i+1 < 10 {
                    feeling.image = UIImage(named: "pdFeeling_0\(i+1)")
                } else {
                    feeling.image = UIImage(named: "pdFeeling_\(i+1)")
                }
                uiviewFeeling.addSubview(feeling)
                count += 1
            }
        }
    }
    
    func deleteFeeling() {
        let deleteFeeling = FaePinAction()
        deleteFeeling.deleteFeeling("\(self.pinTypeEnum)", pinID: pinIDPinDetailView) { (status, message) in
            if status / 100 != 2 {
                return
            }
            let getPinById = FaeMap()
            getPinById.getPin(type: "\(self.pinTypeEnum)", pinId: self.pinIDPinDetailView) {(status: Int, message: Any?) in
                let pinInfoJSON = JSON(message!)
                self.feelingArray.removeAll()
                let feelings = pinInfoJSON["feeling_count"].arrayValue.map({Int($0.stringValue)})
                for feeling in feelings {
                    if feeling != nil {
                        self.feelingArray.append(feeling!)
                    }
                }
                if self.tableMode == .feelings {
                    self.tableCommentsForPin.reloadData()
                }
                self.loadFeelingQuickView()
            }
        }
    }
    
    func getSeveralInfo() {
        getPinAttributeNum("\(self.pinTypeEnum)", pinID: pinIDPinDetailView)
        getPinInfo()
        getPinComments("\(self.pinTypeEnum)", pinID: pinIDPinDetailView, sendMessageFlag: false)
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
            if let comments = mapInfoJSON["comments"].int {
                self.pinCommentsCount = comments
                self.labelPinCommentsCount.text = "\(comments)"
                commentsCount = comments
            }
            if likesCount >= 15 || commentsCount >= 10 {
                self.imageViewHotPin.isHidden = false
                if self.pinStatus == "read" || self.pinStatus == "hot and read" {
                    self.pinStatus = "hot and read"
                    self.pinStateEnum = .hotRead
                } else {
                    self.pinStatus = "hot"
                    self.pinStateEnum = .hot
                }
                self.selectPinState(pinState: self.pinStateEnum, pinType: self.pinTypeEnum)
                self.delegate?.changeIconImage(marker: self.pinMarker, type: "\(self.pinTypeEnum)", status: self.pinStatus)
            }
            else {
                self.imageViewHotPin.isHidden = true
            }
        }
    }
    
    func getPinComments(_ type: String, pinID: String, sendMessageFlag: Bool) {
        pinComments.removeAll()
        let getPinComments = FaePinAction()
        getPinComments.getPinComments(type, pinID: pinID) {(status: Int, message: Any?) in
            if status / 100 != 2 {
                print("[getPinComments] fail to get pin comments")
                return
            }
            let commentsJSON = JSON(message!)
            guard let pinCommentJsonArray = commentsJSON.array else {
                print("[getPinComments] fail to parse pin comments")
                return
            }
            self.pinComments = pinCommentJsonArray.map{PinComment(json: $0)}
            self.pinComments.reverse()
            self.tableCommentsForPin.reloadData()
            
//            print(self.pinComments)
            
            self.userNameCard(self.pinUserId, -1, completion: { (id, index) in
                if id != 0 {
                    self.userNameGetter(userid: id, index: index)
                    self.userAvatarGetter(self.pinUserId, index: index, isPeople: true)
                }
            })
            
            if self.pinComments.count >= 1 {
                for i in 0...self.pinComments.count - 1 {
                    let userid = self.pinComments[i].userId
                    self.userNameCard(userid, i, completion: { (id, index) in
                        if id != 0 {
                            self.userNameGetter(userid: id, index: index)
                            self.userAvatarGetter(userid, index: index, isPeople: true)
                        }
                    })
                    self.userAvatarGetter(userid, index: i, isPeople: false)
                }
                if sendMessageFlag {
                    let indexPath = IndexPath(row: self.pinComments.count - 1, section: 0)
                    self.tableCommentsForPin.scrollToRow(at: indexPath, at: .bottom, animated: true)
                }
            }
        }
    }
    
    fileprivate func userAvatarGetter(_ userid: Int, index: Int, isPeople: Bool) {
        let indexPath = IndexPath(row: index, section: 0)
        let realm = try! Realm()
        if let userRealm = realm.objects(UserAvatar.self).filter("userId == \(userid) AND avatar != nil").first {
            let profileImage = UIImage.sd_image(with: userRealm.avatar as Data!)
            if isPeople {
                self.pinDetailUsers[index].profileImage = profileImage!
            } else {
                self.pinComments[index].profileImage = profileImage!
                self.tableCommentsForPin.reloadRows(at: [indexPath], with: UITableViewRowAnimation.none)
            }
        } else {
            let stringHeaderURL = "\(baseURL)/files/users/\(userid)/avatar"
            UIImageView().sd_setImage(with: URL(string: stringHeaderURL), placeholderImage: UIImage(), options: [.retryFailed, .refreshCached], completed: { (image, error, SDImageCacheType, imageURL) in
                if let profileImage = image {
                    if isPeople {
                        self.pinDetailUsers[index].profileImage = profileImage
                    } else {
                        self.pinComments[index].profileImage = profileImage
                        self.tableCommentsForPin.reloadRows(at: [indexPath], with: UITableViewRowAnimation.none)
                    }
                    let userAvatar = UserAvatar()
                    userAvatar.userId = userid
                    userAvatar.avatar = UIImageJPEGRepresentation(image!, 1.0) as NSData?
                    try! realm.write {
                        realm.add(userAvatar)
                    }
                }
            })
        }
    }
    
    fileprivate func userNameCard(_ userid: Int, _ index: Int, completion: @escaping (Int, Int)->()) {
        let getUser = FaeUser()
        getUser.getNamecardOfSpecificUser("\(userid)", completion: { (status, message) in
            if status / 100 != 2 {
                print("[getNamecardOfSpecificUser] fail to get user")
            } else {
                
                let userJSON = JSON(message!)
                
                if index != -1 {
                    let displayName = userJSON["nick_name"].stringValue
                    self.pinComments[index].displayName = displayName
                    let indexPath = IndexPath(row: index, section: 0)
                    self.tableCommentsForPin.reloadRows(at: [indexPath], with: UITableViewRowAnimation.none)
                }
                
                var userDetail = PinDetailUser(json: userJSON)
                userDetail.userId = userid
                if self.pinDetailUsers.contains(userDetail) {
                    print("[userNameCard], exists this user")
                    completion(0, 0)
                } else {
                    self.pinDetailUsers.append(userDetail)
                    guard let userIndex = self.pinDetailUsers.index(of: userDetail) else { return }
                    completion(userid, userIndex)
                }
            }
        })
    }
    
    fileprivate func userNameGetter(userid: Int, index: Int) {
        let getUser = FaeUser()
        getUser.getOthersProfile("\(userid)", completion: { (status, message) in
            if status / 100 != 2 {
                print("[getOthersProfile] fail to get user")
            } else {
                let userJSON = JSON(message!)
                let userName = userJSON["user_name"].stringValue
                self.pinDetailUsers[index].userName = userName
            }
        })
    }
    
    func checkPinStatus() {
        if pinStatus == "new" {
            let realm = try! Realm()
            if realm.objects(NewFaePin.self).filter("pinId == \(self.pinIdSentBySegue) AND pinType == '\(self.pinTypeEnum)'").first != nil {
                print("[checkPinStatus] newPin exists!")
            } else {
                let newPin = NewFaePin()
                newPin.pinId = Int(self.pinIdSentBySegue)!
                newPin.pinType = "\(self.pinTypeEnum)"
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
        commentThisPin.whereKey("anonymous", value: "true")
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
                    if self.pinStatus == "hot" || self.pinStatus == "hot and read" {
                        self.pinStatus = "hot and read"
                        self.pinStateEnum = .hotRead
                    } else {
                        self.pinStatus = "read"
                        self.pinStateEnum = .read
                    }
                    self.selectPinState(pinState: self.pinStateEnum, pinType: self.pinTypeEnum)
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
