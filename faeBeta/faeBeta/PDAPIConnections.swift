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
            if let _ = realm.objects(NewFaePin.self).filter("pinId == \(self.pinIdSentBySegue) AND pinType == \(self.pinTypeDecimal)").first {
                print("[checkPinStatus] newPin exists!")
            }
            else {
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
    
    func uploadingFile(image: UIImage) {
        let imgData = UIImageJPEGRepresentation(image, 0.1) as NSData?
        let imgNew = UIImage.sd_image(with: imgData as Data!)
        let mediaImage = FaeImage()
        mediaImage.type = "image"
        mediaImage.image = imgNew
        mediaImage.faeUploadFile { (status: Int, message: Any?) in
            if status / 100 == 2 {
                print("[uploadingFile] Successfully upload Image File")
                let fileIDJSON = JSON(message!)
                if let file_Id = fileIDJSON["file_id"].int {
                    self.sendMessage("<faeImg>\(file_Id)</faeImg>", date: Date(), picture: nil, sticker : nil, location: nil, snapImage : nil, audio: nil)
                    self.buttonSend.isEnabled = false
                    self.buttonSend.setImage(UIImage(named: "cannotSendMessage"), for: UIControlState())
                }
            } else {
                print("[uploadingFile] Fail to upload Image File")
            }
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
            let realm = try! Realm()
            if self.pinComments.count >= 1 {
                for i in 0...self.pinComments.count - 1 {
                    let indexPath = IndexPath(row: i, section: 0)
                    let getUser = FaeUser()
                    let userid = self.pinComments[i].userId
                    getUser.getNamecardOfSpecificUser("\(userid)", completion: { (status, message) in
                        if status / 100 != 2 {
                            print("[getNamecardOfSpecificUser] fail to get user")
                        } else {
                            let userJSON = JSON(message!)
                            let displayName = userJSON["nick_name"].stringValue
                            self.pinComments[i].displayName = displayName
                            self.tableCommentsForPin.reloadRows(at: [indexPath], with: UITableViewRowAnimation.none)
                        }
                    })
                    if let userRealm = realm.objects(UserAvatar.self).filter("userId == \(userid) AND avatar != nil").first {
                        let profileImage = UIImage.sd_image(with: userRealm.avatar as Data!)
                        self.pinComments[i].profileImage = profileImage!
                        self.tableCommentsForPin.reloadRows(at: [indexPath], with: UITableViewRowAnimation.none)
                    } else {
                        let stringHeaderURL = "\(baseURL)/files/users/\(userid)/avatar"
                        UIImageView().sd_setImage(with: URL(string: stringHeaderURL), placeholderImage: UIImage(), options: [.retryFailed, .refreshCached], completed: { (image, error, SDImageCacheType, imageURL) in
                            if let profileImage = image {
                                self.pinComments[i].profileImage = profileImage
                                let userAvatar = UserAvatar()
                                userAvatar.userId = userid
                                userAvatar.avatar = UIImageJPEGRepresentation(image!, 1.0) as NSData?
                                try! realm.write {
                                    realm.add(userAvatar)
                                }
                                self.tableCommentsForPin.reloadRows(at: [indexPath], with: UITableViewRowAnimation.none)
                            }
                        })
                    }
                    
                }
                if sendMessageFlag {
                    let indexPath = IndexPath(row: self.pinComments.count - 1, section: 0)
                    self.tableCommentsForPin.scrollToRow(at: indexPath, at: .bottom, animated: true)
                }
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
            if let userid = pinInfoJSON["user_id"].int {
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
                        self.fileIdArray.append(fileID!)
                        //Changed by Yao, decide to pass fileIdArray to editPinViewController rather than fileIdString
                    }
                }
                self.loadMedias()
                if let content = pinInfoJSON["description"].string {
                    self.stringPlainTextViewTxt = "\(content)"
                    self.textviewPinDetail.attributedText = "\(content)".convertStringWithEmoji()
                    opinContent = "\(content)"
                }
            }
            else if self.pinTypeEnum == .comment {
                if let content = pinInfoJSON["content"].string {
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
//                getAvatarFromRealm(id: toGetUserName, imgView: self.imagePinUserAvatar)
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
