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
        let getPinById = FaeMap()
        getPinById.getPin(type: "\(PinDetailViewController.pinTypeEnum)", pinId: self.pinIDPinDetailView) {(status: Int, message: Any?) in
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
            // Has posted feeling or not
            if let chosenFeel = pinInfoJSON["user_pin_operations"]["feeling"].int {
                self.chosenFeeling = chosenFeel
                if chosenFeel < 5 && chosenFeel >= 0 {
                    UIView.animate(withDuration: 0.2, animations: { 
                        let xOffset = Int(chosenFeel * 52 + 12)
                        self.btnFeelingArray[chosenFeel].frame = CGRect(x: xOffset, y: 3, width: 48, height: 48)
                    })
                }
            } else {
                self.chosenFeeling = -1
            }
            self.loadFeelingQuickView()
            
            // Images
            if PinDetailViewController.pinTypeEnum == .media {
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
            } else if PinDetailViewController.pinTypeEnum == .comment {
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
            let anonymous = pinInfoJSON["anonymous"].boolValue
            if anonymous {
                self.labelPinUserName.text = "Someone"
                self.isAnonymous = true
            }
            else {
                self.labelPinUserName.text = pinInfoJSON["nick_name"].stringValue
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
    }
    
    func postFeeling(_ sender: UIButton) {
        if sender.tag == chosenFeeling {
            deleteFeeling()
            chosenFeeling = -1
            return
        }
        print("[postFeeling] pre self.chosenFeeling", chosenFeeling)
        chosenFeeling = sender.tag
        print("[postFeeling] aft self.chosenFeeling", chosenFeeling)
        let postFeeling = FaePinAction()
        postFeeling.whereKey("feeling", value: "\(sender.tag)")
        postFeeling.postFeelingToPin("\(PinDetailViewController.pinTypeEnum)", pinID: self.pinIDPinDetailView) { (status, message) in
            if status / 100 != 2 {
                return
            }
            
            UIView.animate(withDuration: 0.2, animations: {
                let yAxis = 11 * screenHeightFactor
                let width = 32 * screenHeightFactor
                for i in 0..<self.btnFeelingArray.count {
                    self.btnFeelingArray[i].frame = CGRect(x: CGFloat(20+52*i), y: yAxis, width: width, height: width)
                }
                if sender.tag < 5 {
                    let xOffset = Int(sender.tag * 52 + 12)
                    self.btnFeelingArray[sender.tag].frame = CGRect(x: xOffset, y: 3, width: 48, height: 48)
                }
            })
            
            let getPinById = FaeMap()
            getPinById.getPin(type: "\(PinDetailViewController.pinTypeEnum)", pinId: self.pinIDPinDetailView) {(status: Int, message: Any?) in
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
    
    func deleteFeeling() {
        UIView.animate(withDuration: 0.2, animations: {
            self.btnFeelingBar_01.frame = CGRect(x: 20, y: 11, width: 32, height: 32)
            self.btnFeelingBar_02.frame = CGRect(x: 72, y: 11, width: 32, height: 32)
            self.btnFeelingBar_03.frame = CGRect(x: 124, y: 11, width: 32, height: 32)
            self.btnFeelingBar_04.frame = CGRect(x: 176, y: 11, width: 32, height: 32)
            self.btnFeelingBar_05.frame = CGRect(x: 228, y: 11, width: 32, height: 32)
        })
        let deleteFeeling = FaePinAction()
        deleteFeeling.deleteFeeling("\(PinDetailViewController.pinTypeEnum)", pinID: self.pinIDPinDetailView) { (status, message) in
            if status / 100 != 2 {
                return
            }
            let getPinById = FaeMap()
            getPinById.getPin(type: "\(PinDetailViewController.pinTypeEnum)", pinId: self.pinIDPinDetailView) {(status: Int, message: Any?) in
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
    
    func updateFeelingPicker() {
        
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
    
    func getSeveralInfo() {
        getPinAttributeNum("\(PinDetailViewController.pinTypeEnum)", pinID: self.pinIDPinDetailView)
        getPinInfo()
        getPinComments("\(PinDetailViewController.pinTypeEnum)", pinID: self.pinIDPinDetailView, sendMessageFlag: false)
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
                if PinDetailViewController.pinStatus == "read" || PinDetailViewController.pinStatus == "hot and read" {
                    PinDetailViewController.pinStatus = "hot and read"
                    PinDetailViewController.pinStateEnum = .hotRead
                } else {
                    PinDetailViewController.pinStatus = "hot"
                    PinDetailViewController.pinStateEnum = .hot
                }
                self.selectPinState(pinState: PinDetailViewController.pinStateEnum, pinType: PinDetailViewController.pinTypeEnum)
                self.delegate?.changeIconImage(marker: PinDetailViewController.pinMarker, type: "\(PinDetailViewController.pinTypeEnum)", status: PinDetailViewController.pinStatus)
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
            
            self.userNameCard(PinDetailViewController.pinUserId, -1, completion: { (id, index) in
                if id != 0 {
                    self.userNameGetter(userid: id, index: index)
                    self.userAvatarGetter(PinDetailViewController.pinUserId, index: index, isPeople: true)
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
//        if userid == -1 {
//            return
//        }
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
                print("[userNameCard] fail to get user")
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
//        if userid == -1 {
//            self.pinDetailUsers[index].userName = "Someone"
//        }
        let getUser = FaeUser()
        getUser.getOthersProfile("\(userid)", completion: { (status, message) in
            if status / 100 != 2 {
                print("[userNameGetter] fail to get user")
            } else {
                let userJSON = JSON(message!)
                let userName = userJSON["user_name"].stringValue
                self.pinDetailUsers[index].userName = userName
            }
        })
    }
    
    func checkPinStatus() {
        if PinDetailViewController.pinStatus == "new" {
            let realm = try! Realm()
            if realm.objects(NewFaePin.self).filter("pinId == \(self.pinIDPinDetailView) AND pinType == '\(PinDetailViewController.pinTypeEnum)'").first != nil {
                print("[checkPinStatus] newPin exists!")
            } else {
                let newPin = NewFaePin()
                newPin.pinId = Int(self.pinIDPinDetailView)!
                newPin.pinType = "\(PinDetailViewController.pinTypeEnum)"
                try! realm.write {
                    realm.add(newPin)
                    print("[checkPinStatus] newPin written!")
                }
            }
            self.delegate?.changeIconImage(marker: PinDetailViewController.pinMarker, type: "\(PinDetailViewController.pinTypeEnum)", status: "normal")
        }
    }
    
    func commentThisPin(_ type: String, pinID: String, text: String) {
        let commentThisPin = FaePinAction()
        commentThisPin.whereKey("content", value: text)
        commentThisPin.whereKey("anonymous", value: "\(switchAnony.isOn)")
        if self.pinIDPinDetailView != "-999" {
            commentThisPin.commentThisPin(type , pinID: pinID) {(status: Int, message: Any?) in
                if status == 201 {
                    print("Successfully comment this pin!")
                    self.getPinAttributeNum("\(PinDetailViewController.pinTypeEnum)", pinID: self.pinIDPinDetailView)
                    self.getPinComments("\(PinDetailViewController.pinTypeEnum)", pinID: self.pinIDPinDetailView, sendMessageFlag: true)
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
        if self.pinIDPinDetailView != "-999" {
            likeThisPin.likeThisPin(type , pinID: pinID) {(status: Int, message: Any?) in
                if status == 201 {
                    print("[likeThisPin] Successfully like this pin!")
                    self.getPinAttributeNum("\(PinDetailViewController.pinTypeEnum)", pinID: self.pinIDPinDetailView)
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
        if self.pinIDPinDetailView != "-999" {
            saveThisPin.saveThisPin(type , pinID: pinID) {(status: Int, message: Any?) in
                if status / 100 == 2 {
                    print("Successfully save this pin!")
                    self.getPinSavedState()
                    self.getPinAttributeNum("\(PinDetailViewController.pinTypeEnum)", pinID: self.pinIDPinDetailView)
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
        if self.pinIDPinDetailView != "-999" {
            unsaveThisPin.unsaveThisPin(type , pinID: pinID) {(status: Int, message: Any?) in
                if status / 100 == 2 {
                    print("Successfully unsave this pin!")
                    self.getPinSavedState()
                    self.getPinAttributeNum("\(PinDetailViewController.pinTypeEnum)", pinID: self.pinIDPinDetailView)
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
        if self.pinIDPinDetailView != "-999" {
            readThisPin.haveReadThisPin(type , pinID: pinID) {(status: Int, message: Any?) in
                if status / 100 == 2 {
                    print("Successfully read this pin!")
                    if PinDetailViewController.pinStatus == "hot" || PinDetailViewController.pinStatus == "hot and read" {
                        PinDetailViewController.pinStatus = "hot and read"
                        PinDetailViewController.pinStateEnum = .hotRead
                    } else {
                        PinDetailViewController.pinStatus = "read"
                        PinDetailViewController.pinStateEnum = .read
                    }
                    self.selectPinState(pinState: PinDetailViewController.pinStateEnum, pinType: PinDetailViewController.pinTypeEnum)
                    self.delegate?.changeIconImage(marker: PinDetailViewController.pinMarker, type: "\(PinDetailViewController.pinTypeEnum)", status: PinDetailViewController.pinStatus)
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
        if self.pinIDPinDetailView != "-999" {
            unlikeThisPin.unlikeThisPin(type , pinID: pinID) {(status: Int, message: Any?) in
                if status/100 == 2 {
                    print("Successfully unlike this pin!")
                    self.getPinAttributeNum("\(PinDetailViewController.pinTypeEnum)", pinID: self.pinIDPinDetailView)
                }
                else {
                    print("Fail to unlike this pin!")
                }
            }
        }
    }
    
    func getPinSavedState() {
        let getPinSavedState = FaeMap()
        getPinSavedState.getPin(type: "\(PinDetailViewController.pinTypeEnum)", pinId: self.pinIDPinDetailView) {(status: Int, message: Any?) in
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
