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
        if strPinId == "-1" {
            return
        }
        
        // Cache the current user's profile pic and use it when current user post a feeling
        // The small size (20x20) of it will be displayed at the right bottom corner of the feeling table
        if user_id != nil {
            let stringHeaderURL = "\(baseURL)/files/users/\(Int(user_id))/avatar"
            imgCurUserAvatar = UIImageView()
            imgCurUserAvatar.sd_setImage(with: URL(string: stringHeaderURL), placeholderImage: UIImage(), options: [.retryFailed, .refreshCached], completed: nil)
        }
        
        let getPinById = FaeMap()
        getPinById.getPin(type: "\(PinDetailViewController.pinTypeEnum)", pinId: self.strPinId) {(status: Int, message: Any?) in
            let pinInfoJSON = JSON(message!)
            // Time
            self.lblPinDate.text = pinInfoJSON["created_at"].stringValue.formatFaeDate()
            // Check if pin is mine
            if let userid = pinInfoJSON["user_id"].int {
                if userid == Int(user_id) {
                    self.boolMyPin = true
                } else {
                    self.boolMyPin = false
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
                self.tblMain.reloadData()
            }
            // QuickView is the middle line of pin detail, displayed the chosen feeling the all users have posted
            self.loadFeelingQuickView()
            
            // Images of story pin
            if PinDetailViewController.pinTypeEnum == .media {
                self.fileIdArray.removeAll()
                let fileIDs = pinInfoJSON["file_ids"].arrayValue.map({Int($0.stringValue)})
                for fileID in fileIDs {
                    if fileID != nil {
                        self.fileIdArray.append(fileID!)
                    }
                }
                // Use separate func to load pictures in a scrollView
                self.loadMedias()
                self.strCurrentTxt = pinInfoJSON["description"].stringValue
                if self.enterMode != .collections {
                    self.textviewPinDetail.attributedText = self.strCurrentTxt.convertStringWithEmoji()
                }
            } else if PinDetailViewController.pinTypeEnum == .comment {
                self.strCurrentTxt = pinInfoJSON["content"].stringValue
                self.textviewPinDetail.attributedText = self.strCurrentTxt.convertStringWithEmoji()
            }
            
            // Liked or not
            if !pinInfoJSON["user_pin_operations"]["is_liked"].boolValue {
                self.btnPinLike.setImage(#imageLiteral(resourceName: "pinDetailLikeHeartHollowNew"), for: UIControlState())
                self.btnPinLike.tag = 0
                if self.animatingHeart != nil {
                    self.animatingHeart.image = #imageLiteral(resourceName: "pinDetailLikeHeartHollowNew")
                }
            } else {
                self.btnPinLike.setImage(#imageLiteral(resourceName: "pinDetailLikeHeartFull"), for: UIControlState())
                self.btnPinLike.tag = 1
                if self.animatingHeart != nil {
                    self.animatingHeart.image = #imageLiteral(resourceName: "pinDetailLikeHeartFull")
                }
            }
            // Saved or not
            if !pinInfoJSON["user_pin_operations"]["is_saved"].boolValue {
                self.isSavedByMe = false
                self.imgCollected.image = #imageLiteral(resourceName: "pinUnsaved")
            } else {
                self.isSavedByMe = true
                self.imgCollected.image = #imageLiteral(resourceName: "pinSaved")
            }
            // Get nick name
            let anonymous = pinInfoJSON["anonymous"].boolValue
            if anonymous {
                self.lblPinDisplayName.text = "Someone"
                self.isAnonymous = true
            }
            else {
                self.lblPinDisplayName.text = pinInfoJSON["nick_name"].stringValue
                // Get avatar
                if let pinUserId = pinInfoJSON["user_id"].int {
                    let stringHeaderURL = "\(baseURL)/files/users/\(pinUserId)/avatar"
                    self.imgPinUserAvatar.sd_setImage(with: URL(string: stringHeaderURL), placeholderImage: Key.sharedInstance.imageDefaultMale, options: [.retryFailed, .refreshCached], completed: { (image, error, SDImageCacheType, imageURL) in
                        UIView.animate(withDuration: 0.2, animations: {
                            self.imgPinUserAvatar.alpha = 1
                        })
                    })
                }
            }
        }
    }
    
    func postFeeling(_ sender: UIButton) {
        if sender.tag == intChosenFeeling {
            deleteFeeling()
            intChosenFeeling = -1
            return
        }
        print("[postFeeling] pre self.intChosenFeeling", intChosenFeeling)
        intChosenFeeling = sender.tag
        print("[postFeeling] aft self.intChosenFeeling", intChosenFeeling)
        let postFeeling = FaePinAction()
        postFeeling.whereKey("feeling", value: "\(sender.tag)")
        postFeeling.postFeelingToPin("\(PinDetailViewController.pinTypeEnum)", pinID: self.strPinId) { (status, message) in
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
                    let xOffset = Int(sender.tag * 52 + 13)
                    self.btnFeelingArray[sender.tag].frame = CGRect(x: xOffset, y: 3, width: 46, height: 46)
                }
            })
            
            let getPinById = FaeMap()
            getPinById.getPin(type: "\(PinDetailViewController.pinTypeEnum)", pinId: self.strPinId) {(status: Int, message: Any?) in
                let pinInfoJSON = JSON(message!)
                self.feelingArray.removeAll()
                let feelings = pinInfoJSON["feeling_count"].arrayValue.map({Int($0.stringValue)})
                for feeling in feelings {
                    if feeling != nil {
                        self.feelingArray.append(feeling!)
                    }
                }
                if self.tableMode == .feelings && !self.boolDetailShrinked {
                    self.tblMain.reloadData()
                    let indexPath = IndexPath(row: 0, section: 0)
                    self.tblMain.scrollToRow(at: indexPath, at: .bottom, animated: false)
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
        deleteFeeling.deleteFeeling("\(PinDetailViewController.pinTypeEnum)", pinID: self.strPinId) { (status, message) in
            if status / 100 != 2 {
                return
            }
            let getPinById = FaeMap()
            getPinById.getPin(type: "\(PinDetailViewController.pinTypeEnum)", pinId: self.strPinId) {(status: Int, message: Any?) in
                let pinInfoJSON = JSON(message!)
                self.feelingArray.removeAll()
                let feelings = pinInfoJSON["feeling_count"].arrayValue.map({Int($0.stringValue)})
                for feeling in feelings {
                    if feeling != nil {
                        self.feelingArray.append(feeling!)
                    }
                }
                if self.tableMode == .feelings {
                    self.tblMain.reloadData()
                }
                self.loadFeelingQuickView()
            }
        }
    }
    
    func loadFeelingQuickView() {
        uiviewFeelingQuick.removeFromSuperview()
        uiviewFeelingQuick = UIView(frame: CGRect(x: 14, y: 0, width: screenWidth - 180, height: 27))
        uiviewInteractBtnSub.addSubview(uiviewFeelingQuick)
        uiviewFeelingQuick.layer.zPosition = 109
        var count = 0
        for i in 0..<feelingArray.count {
            if feelingArray[i] != 0 {
                let offset = count * 30
                let feeling = UIImageView(frame: CGRect(x: offset, y: 0, width: 27, height: 27))
                if i+1 < 10 {
                    feeling.image = UIImage(named: "pdFeeling_0\(i+1)-1")
                } else {
                    feeling.image = UIImage(named: "pdFeeling_\(i+1)-1")
                }
                uiviewFeelingQuick.addSubview(feeling)
                count += 1
            }
        }
    }
    
    func getSeveralInfo() {
        getPinAttributeNum()
        getPinInfo()
        getPinComments(sendMessageFlag: false)
    }
    
    func getPinAttributeNum() {
        if strPinId == "-1" {
            return
        }
        let getPinAttr = FaePinAction()
        getPinAttr.getPinAttribute("\(PinDetailViewController.pinTypeEnum)", pinID: self.strPinId) {(status: Int, message: Any?) in
            let mapInfoJSON = JSON(message!)
            var likesCount = 0
            var commentsCount = 0
            if let likes = mapInfoJSON["likes"].int {
                self.lblPinLikeCount.text = "\(likes)"
                likesCount = likes
            }
            if let comments = mapInfoJSON["comments"].int {
                self.lblCommentCount.text = "\(comments)"
                commentsCount = comments
            }
            if likesCount >= 15 || commentsCount >= 10 {
                self.imgHotPin.isHidden = false
                if PinDetailViewController.pinStatus == "read" || PinDetailViewController.pinStatus == "hot and read" {
                    PinDetailViewController.pinStatus = "hot and read"
                    PinDetailViewController.pinStateEnum = .hotRead
                } else {
                    PinDetailViewController.pinStatus = "hot"
                    PinDetailViewController.pinStateEnum = .hot
                }
                self.selectPinState()
                self.delegate?.changeIconImage()
            }
            else {
                self.imgHotPin.isHidden = true
            }
        }
    }
    
    func getPinComments(sendMessageFlag: Bool) {
        if strPinId == "-1" {
            return
        }
        pinComments.removeAll()
        let getPinComments = FaePinAction()
        getPinComments.getPinComments("\(PinDetailViewController.pinTypeEnum)", pinID: self.strPinId) {(status: Int, message: Any?) in
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
            self.tblMain.reloadData()
            
            self.userNameCard(PinDetailViewController.pinUserId, -1, completion: { (id, index) in
                if id != 0 {
                    self.userAvatarGetter(PinDetailViewController.pinUserId, index: index, isPeople: true)
                }
            })
            
            if self.pinComments.count >= 1 {
                for i in 0...self.pinComments.count - 1 {
                    let userid = self.pinComments[i].userId
                    self.userNameCard(userid, i, completion: { (id, index) in
                        if id != 0 {
                            self.userAvatarGetter(userid, index: index, isPeople: true)
                        }
                    })
                    self.userAvatarGetter(userid, index: i, isPeople: false)
                }
                if sendMessageFlag {
                    let indexPath = IndexPath(row: self.pinComments.count - 1, section: 0)
                    self.tblMain.scrollToRow(at: indexPath, at: .bottom, animated: true)
                }
            }
        }
    }
    
    fileprivate func userAvatarGetter(_ userid: Int, index: Int, isPeople: Bool) {

        let indexPath = IndexPath(row: index, section: 0)
        getImage(userID: userid, type: 2) { (status, etag, imageRawData) in
            print("[userAvatarGetter] userid", userid)
            print("[userAvatarGetter] Etag", etag)
            let realm = try! Realm()
            if let avatarRealm = realm.objects(RealmUser.self).filter("userID == '\(userid)'").first {
                // 存在User，Etag没变
                print("存在User，Etag没变")
                if etag == avatarRealm.smallAvatarEtag {
                    if isPeople {
                        self.pinDetailUsers[index].profileImage = UIImage.sd_image(with: avatarRealm.userSmallAvatar as Data!)
                    } else {
                        self.pinComments[index].profileImage = UIImage.sd_image(with: avatarRealm.userSmallAvatar as Data!)
                        self.tblMain.reloadRows(at: [indexPath], with: UITableViewRowAnimation.none)
                    }
                }
                // 存在User，Etag改变
                else {
                    print("存在User，Etag改变")
                    if isPeople {
                        self.pinDetailUsers[index].profileImage = UIImage.sd_image(with: imageRawData)
                    } else {
                        self.pinComments[index].profileImage = UIImage.sd_image(with: imageRawData)
                        self.tblMain.reloadRows(at: [indexPath], with: UITableViewRowAnimation.none)
                    }
                    try! realm.write {
                        avatarRealm.smallAvatarEtag = etag
                        avatarRealm.userSmallAvatar = imageRawData as NSData?
                        avatarRealm.largeAvatarEtag = nil
                        avatarRealm.userLargeAvatar = nil
                    }
                }
            } else {
                // 不存在User
                print("不存在User", userid, index, isPeople)
                if isPeople {
                    self.pinDetailUsers[index].profileImage = UIImage.sd_image(with: imageRawData)
                } else {
                    self.pinComments[index].profileImage = UIImage.sd_image(with: imageRawData)
                    self.tblMain.reloadRows(at: [indexPath], with: UITableViewRowAnimation.none)
                }
                let avatarObj = RealmUser()
                avatarObj.userID = "\(userid)"
                avatarObj.smallAvatarEtag = etag
                avatarObj.userSmallAvatar = imageRawData as NSData?
                try! realm.write {
                    realm.add(avatarObj)
                }
            }
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
                    self.tblMain.reloadRows(at: [indexPath], with: UITableViewRowAnimation.none)
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
    
    func checkPinStatus() {
        if PinDetailViewController.pinTypeEnum == .place {
            return
        }
        if PinDetailViewController.pinStatus == "new" {
            let realm = try! Realm()
            if realm.objects(NewFaePin.self).filter("pinId == \(self.strPinId) AND pinType == '\(PinDetailViewController.pinTypeEnum)'").first != nil {
                print("[checkPinStatus] newPin exists!")
            } else {
                let newPin = NewFaePin()
                newPin.pinId = Int(self.strPinId)!
                newPin.pinType = "\(PinDetailViewController.pinTypeEnum)"
                try! realm.write {
                    realm.add(newPin)
                    print("[checkPinStatus] newPin written!")
                }
            }
            PinDetailViewController.pinStatus = "normal"
            self.delegate?.changeIconImage()
        }
    }
    
    func commentThisPin(text: String) {
        if strPinId == "-1" {
            return
        }
        let commentThisPin = FaePinAction()
        commentThisPin.whereKey("content", value: text)
        commentThisPin.whereKey("anonymous", value: "\(switchAnony.isOn)")
        if self.strPinId != "-999" {
            commentThisPin.commentThisPin("\(PinDetailViewController.pinTypeEnum)", pinID: self.strPinId) {(status: Int, message: Any?) in
                if status == 201 {
                    print("Successfully comment this pin!")
                    self.getPinAttributeNum()
                    self.getPinComments(sendMessageFlag: true)
                }
                else {
                    print("Fail to comment this pin!")
                }
            }
        }
    }
    
    func likeThisPin() {
        if strPinId == "-1" {
            return
        }
        let likeThisPin = FaePinAction()
        likeThisPin.whereKey("", value: "")
        if self.strPinId != "-999" {
            likeThisPin.likeThisPin("\(PinDetailViewController.pinTypeEnum)", pinID: self.strPinId) {(status: Int, message: Any?) in
                if status == 201 {
                    print("[likeThisPin] Successfully like this pin!")
                    self.getPinAttributeNum()
                }
                else {
                    print("Fail to like this pin!")
                }
            }
        }
    }
    
    func saveThisPin() {
        if self.strPinId == "-1" {
            return
        }
        let saveThisPin = FaePinAction()
        saveThisPin.whereKey("", value: "")
        if self.strPinId != "-999" {
            saveThisPin.saveThisPin("\(PinDetailViewController.pinTypeEnum)", pinID: self.strPinId) {(status: Int, message: Any?) in
                if status / 100 == 2 {
                    print("Successfully save this pin!")
                    self.getPinSavedState()
                    self.getPinAttributeNum()
                    UIView.animate(withDuration: 0.5, animations: ({
                        self.imgCollected.alpha = 1.0
                    }), completion: { (_) in
                        UIView.animate(withDuration: 0.5, delay: 1.0, options: [], animations: {
                            self.imgCollected.alpha = 0.0
                        }, completion: nil)
                    })
                }
                else {
                    print("Fail to save this pin!")
                }
            }
        }
    }
    
    func unsaveThisPin() {
        if self.strPinId == "-1" {
            return
        }
        let unsaveThisPin = FaePinAction()
        unsaveThisPin.whereKey("", value: "")
        if self.strPinId != "-999" {
            unsaveThisPin.unsaveThisPin("\(PinDetailViewController.pinTypeEnum)", pinID: self.strPinId) {(status: Int, message: Any?) in
                if status / 100 == 2 {
                    print("Successfully unsave this pin!")
                    self.getPinSavedState()
                    self.getPinAttributeNum()
                    UIView.animate(withDuration: 0.5, animations: ({
                        self.imgCollected.alpha = 1.0
                    }), completion: { (_) in
                        UIView.animate(withDuration: 0.5, delay: 1.0, options: [], animations: {
                            self.imgCollected.alpha = 0.0
                        }, completion: nil)
                    })
                }
                else {
                    print("Fail to unsave this pin!")
                }
            }
        }
    }
    
    // Have read this pin
    func readThisPin() {
        if self.strPinId == "-1" {
            return
        }
        let readThisPin = FaePinAction()
        readThisPin.whereKey("", value: "")
        readThisPin.haveReadThisPin("\(PinDetailViewController.pinTypeEnum)" , pinID: self.strPinId) {(status: Int, message: Any?) in
            if status / 100 == 2 {
                print("Successfully read this pin!")
                if PinDetailViewController.pinStatus == "hot" || PinDetailViewController.pinStatus == "hot and read" {
                    PinDetailViewController.pinStatus = "hot and read"
                    PinDetailViewController.pinStateEnum = .hotRead
                } else {
                    PinDetailViewController.pinStatus = "read"
                    PinDetailViewController.pinStateEnum = .read
                }
                self.selectPinState()
                self.delegate?.changeIconImage()
            }
            else {
                print("Fail to read this pin!")
            }
        }
    }
    
    func unlikeThisPin() {
        if self.strPinId == "-1" {
            return
        }
        let unlikeThisPin = FaePinAction()
        unlikeThisPin.whereKey("", value: "")
        unlikeThisPin.unlikeThisPin("\(PinDetailViewController.pinTypeEnum)" , pinID: self.strPinId) {(status: Int, message: Any?) in
            if status/100 == 2 {
                print("Successfully unlike this pin!")
                self.getPinAttributeNum()
            }
            else {
                print("Fail to unlike this pin!")
            }
        }
    }
    
    func getPinSavedState() {
        let getPinSavedState = FaeMap()
        getPinSavedState.getPin(type: "\(PinDetailViewController.pinTypeEnum)", pinId: self.strPinId) {(status: Int, message: Any?) in
            let commentInfoJSON = JSON(message!)
            if let isSaved = commentInfoJSON["user_pin_operations"]["is_saved"].bool {
                if isSaved == false {
                    self.isSavedByMe = false
                    self.imgCollected.image = #imageLiteral(resourceName: "pinUnsaved")
                }
                else {
                    self.isSavedByMe = true
                    self.imgCollected.image = #imageLiteral(resourceName: "pinSaved")
                }
            }
        }
    }
}
