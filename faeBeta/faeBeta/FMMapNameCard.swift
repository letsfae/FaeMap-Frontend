//
//  FMMapNameCard.swift
//  faeBeta
//
//  Created by Yue on 12/15/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
import SwiftyJSON
import GoogleMaps

extension FaeMapViewController {
    
    func getSelfNameCard(_ sender: UIButton) {
        btnCardOptions.tag = user_id
        btnCardShowSelf.isHidden = false
        btnCardFav.isHidden = true
        if user_id != -1 {
            General.shared.avatar(userid: user_id, completion: { image in
                self.imgCardAvatar.image = image
            })
            btnCardChat.tag = user_id
        } else {
            return
        }
        let zoomLv = faeMapView.camera.zoom
        let offset: Double = 0.0012 * pow(2, Double(17 - zoomLv))
        let camera = GMSCameraPosition.camera(withLatitude: curLat + offset,
                                              longitude: curLon, zoom: zoomLv)
        faeMapView.animate(to: camera)
        animateNameCard()
        let userNameCard = FaeUser()
        userNameCard.getSelfNamecard { (status: Int, message: Any?) in
            guard status / 100 == 2 else { return }
            guard let unwrapMessage = message else {
                print("[getSelfNamecard] message is nil")
                return
            }
            let profileInfo = JSON(unwrapMessage)
            let canShowGender = profileInfo["show_gender"].boolValue
            let gender = profileInfo["gender"].stringValue
            let canShowAge = profileInfo["show_age"].boolValue
            let age = profileInfo["age"].stringValue
            self.showGenderAge(showGender: canShowGender, gender: gender, showAge: canShowAge, age: age)
            self.lblNickName.text = profileInfo["nick_name"].stringValue
            self.lblShortIntro.text = profileInfo["short_intro"].stringValue
        }
    }
    
    func animateNameCard() {
        let targetFrame = CGRect(x: 73, y: 158, w: 268, h: 293)
        UIView.animate(withDuration: 0.8, delay: 0.3, usingSpringWithDamping: 0.6, initialSpringVelocity: 0, options: .curveLinear, animations: {
            self.btnCardClose.alpha = 1
            self.imgCardBack.frame = targetFrame
            self.imgCardCover.frame = CGRect(x: 73, y: 158, w: 268, h: 125)
            self.uiviewAvatarShadow.frame = CGRect(x: 170, y: 240, w: 74, h: 74)
            self.imgCardAvatar.frame = CGRect(x: 170, y: 240, w: 74, h: 74)
            self.btnCardChat.frame = CGRect(x: 193.5, y: 393, w: 27, h: 27)
            self.lblNickName.frame = CGRect(x: 114, y: 323, w: 186, h: 25)
            self.lblNickName.alpha = 1
            self.lblShortIntro.frame = CGRect(x: 122, y: 349, w: 171, h: 18)
            self.imgCardLine.frame = CGRect(x: 73, y: 380.5, w: 268, h: 1)
            self.btnCardFav.frame = CGRect(x: 116, y: 393, w: 27, h: 27)
            self.btnCardShowSelf.frame = CGRect(x: 116, y: 393, w: 27, h: 27)
            self.btnCardOptions.frame = CGRect(x: 294, y: 292, w: 32, h: 18)
            self.btnCardProfile.frame = CGRect(x: 271, y: 393, w: 27, h: 27)
            self.uiviewCardShadow.frame = CGRect(x: 73, y: 158, w: 268, h: 275)
            self.uiviewCardGender.frame = CGRect(x: 88, y: 292, w: 46, h: 18)
            self.imgCardGender.frame = CGRect(x: 97, y: 295, w: 10, h: 12)
            self.lblCardAge.frame = CGRect(x: 113, y: 293, w: 16, h: 14)
            self.lblCardAge.alpha = 1
        }, completion: nil)
    }
    
    func hideNameCard(_ sender: UIButton) {
        UIView.animate(withDuration: 0.3, animations: ({
            if sender == self.btnCardClose {
                self.btnCardClose.alpha = 0
                self.imgCardBack.frame = CGRect(x: 414 / 2, y: 451, w: 0, h: 0)
                self.imgCardCover.frame = self.startFrame
                self.uiviewAvatarShadow.frame = self.startFrame
                self.imgCardAvatar.frame = self.startFrame
                self.btnCardChat.frame = self.startFrame
                self.lblNickName.frame = CGRect(x: 114, y: 451, w: 0, h: 0)
                self.lblShortIntro.frame = self.startFrame
                self.imgCardLine.frame = self.startFrame
                self.btnCardFav.frame = self.startFrame
                self.btnCardShowSelf.frame = self.startFrame
                self.btnCardOptions.frame = self.startFrame
                self.btnCardProfile.frame = self.startFrame
                self.uiviewCardGender.frame = self.startFrame
                self.uiviewCardShadow.frame = self.startFrame
                self.imgCardGender.frame = self.startFrame
                self.lblCardAge.frame = self.startFrame
            }
            if sender.tag == 1 || sender == self.btnCardCloseOptions {
                self.btnCardOptions.setImage(#imageLiteral(resourceName: "moreOptionMapNameCardFade"), for: .normal)
                sender.tag = 0
                self.nameCardMoreOptions.frame = CGRect(x: 243, y: 151, w: 0, h: 0)
                let btnFrame = CGRect(x: 243, y: 191, w: 0, h: 0)
                self.shareNameCard.frame = btnFrame
                self.btnEditNameCard.frame = btnFrame
                self.reportNameCard.frame = btnFrame
                self.shareNameCard.alpha = 0
                self.btnEditNameCard.alpha = 0
                self.reportNameCard.alpha = 0
                self.btnCardCloseOptions.alpha = 0
            }
        }), completion: { _ in
            if sender == self.btnCardClose {
                self.boolCanUpdateUserPin = true
                self.uiviewCardGender.isHidden = true
                self.imgCardGender.image = nil
                self.lblCardAge.text = nil
                self.lblCardAge.alpha = 0
                self.lblNickName.alpha = 0
                self.resumeAllUserPinTimers()
            }
        })
    }
    
    func loadNameCard() {
        btnCardClose = UIButton(frame: CGRect(x: 0, y: 0, w: 414, h: 736))
        self.view.addSubview(btnCardClose)
        btnCardClose.layer.zPosition = 900
        btnCardClose.alpha = 0
        btnCardClose.addTarget(self, action: #selector(self.hideNameCard(_:)), for: .touchUpInside)
        
        uiviewCardShadow = UIView(frame: startFrame)
        uiviewCardShadow.backgroundColor = UIColor.white
        uiviewCardShadow.layer.anchorPoint = nameCardAnchor
        uiviewCardShadow.layer.shadowColor = UIColor.gray.cgColor
        uiviewCardShadow.layer.shadowOffset = CGSize.zero
        uiviewCardShadow.layer.shadowOpacity = 1
        uiviewCardShadow.layer.shadowRadius = 25 * screenHeightFactor
        uiviewCardShadow.layer.zPosition = 901
        uiviewCardShadow.layer.cornerRadius = 18.9 * screenHeightFactor
        self.view.addSubview(uiviewCardShadow)
        
        imgCardBack = UIImageView(frame: startFrame)
        imgCardBack.layer.anchorPoint = nameCardAnchor
        imgCardBack.image = UIImage(named: "NameCard")
        imgCardBack.contentMode = .scaleAspectFit
        imgCardBack.clipsToBounds = true
        imgCardBack.layer.zPosition = 902
        self.view.addSubview(imgCardBack)
        
        imgCardCover = UIImageView(frame: startFrame)
        imgCardCover.image = UIImage(named: "Cover")
        imgCardCover.layer.anchorPoint = nameCardAnchor
        imgCardCover.layer.zPosition = 903
        self.view.addSubview(imgCardCover)
        
        uiviewAvatarShadow = UIView(frame: startFrame)
        uiviewAvatarShadow.layer.anchorPoint = nameCardAnchor
        uiviewAvatarShadow.backgroundColor = UIColor.white
        uiviewAvatarShadow.layer.cornerRadius = 37 * screenHeightFactor
        uiviewAvatarShadow.layer.borderColor = UIColor.white.cgColor
        uiviewAvatarShadow.layer.borderWidth = 6 * screenHeightFactor
        uiviewAvatarShadow.layer.shadowColor = UIColor.gray.cgColor
        uiviewAvatarShadow.layer.shadowOffset = CGSize.zero
        uiviewAvatarShadow.layer.shadowOpacity = 0.5
        uiviewAvatarShadow.layer.shadowRadius = 6 * screenHeightFactor
        uiviewAvatarShadow.layer.zPosition = 904
        
        self.view.addSubview(uiviewAvatarShadow)
        
        imgCardAvatar = UIImageView(frame: startFrame)
        imgCardAvatar.layer.anchorPoint = nameCardAnchor
        imgCardAvatar.layer.cornerRadius = 37 * screenHeightFactor
        imgCardAvatar.layer.borderColor = UIColor.white.cgColor
        imgCardAvatar.layer.borderWidth = 6 * screenHeightFactor
        imgCardAvatar.image = #imageLiteral(resourceName: "defaultMen")
        imgCardAvatar.contentMode = .scaleAspectFill
        imgCardAvatar.layer.masksToBounds = true
        imgCardAvatar.layer.zPosition = 905
        self.view.addSubview(imgCardAvatar)
        
        btnCardChat = UIButton(frame: startFrame)
        btnCardChat.layer.anchorPoint = nameCardAnchor
        btnCardChat.setImage(#imageLiteral(resourceName: "chatFromMap"), for: .normal)
        btnCardChat.layer.zPosition = 906
        self.view.addSubview(btnCardChat)
        btnCardChat.addTarget(self, action: #selector(self.btnChatAction(_:)), for: .touchUpInside)
        
        lblNickName = UILabel(frame: CGRect(x: 114, y: 451, w: 0, h: 0))
        lblNickName.layer.anchorPoint = nameCardAnchor
        lblNickName.text = nil
        lblNickName.textAlignment = .center
        lblNickName.font = UIFont(name: "AvenirNext-DemiBold", size: 18 * screenHeightFactor)
        lblNickName.textColor = UIColor(red: 107 / 255, green: 105 / 255, blue: 105 / 255, alpha: 1.0)
        lblNickName.layer.zPosition = 907
        lblNickName.alpha = 0
        self.view.addSubview(lblNickName)
        
        lblShortIntro = UILabel(frame: startFrame)
        lblShortIntro.layer.anchorPoint = nameCardAnchor
        lblShortIntro.text = ""
        lblShortIntro.textAlignment = .center
        lblShortIntro.font = UIFont(name: "AvenirNext-Medium", size: 13 * screenHeightFactor)
        lblShortIntro.textColor = UIColor(red: 155 / 255, green: 155 / 255, blue: 155 / 255, alpha: 1.0)
        lblShortIntro.layer.zPosition = 908
        self.view.addSubview(lblShortIntro)
        
        imgCardLine = UIImageView(frame: startFrame)
        imgCardLine.layer.anchorPoint = nameCardAnchor
        imgCardLine.backgroundColor = UIColor(red: 206 / 255, green: 203 / 255, blue: 203 / 255, alpha: 1.0)
        imgCardLine.layer.zPosition = 909
        self.view.addSubview(imgCardLine)
        
        btnCardFav = UIButton(frame: startFrame)
        btnCardFav.layer.anchorPoint = nameCardAnchor
        btnCardFav.setImage(UIImage(named: "Favorite"), for: .normal)
        btnCardFav.layer.zPosition = 910
        self.view.addSubview(btnCardFav)
        
        btnCardShowSelf = UIButton(frame: startFrame)
        btnCardShowSelf.layer.anchorPoint = nameCardAnchor
        btnCardShowSelf.layer.zPosition = 910
        btnCardShowSelf.setImage(#imageLiteral(resourceName: "showSelfWaveToOthers"), for: .normal)
        self.view.addSubview(btnCardShowSelf)
        btnCardShowSelf.isHidden = true
        
        btnCardOptions = UIButton(frame: startFrame)
        btnCardOptions.layer.anchorPoint = nameCardAnchor
        btnCardOptions.setImage(#imageLiteral(resourceName: "moreOptionMapNameCardFade"), for: .normal)
        btnCardOptions.layer.zPosition = 910
        self.view.addSubview(btnCardOptions)
        btnCardOptions.addTarget(self, action: #selector(self.showNameCardOptions(_:)), for: .touchUpInside)
        
        btnCardProfile = UIButton(frame: startFrame)
        btnCardProfile.layer.anchorPoint = nameCardAnchor
        btnCardProfile.setImage(UIImage(named: "Emoji"), for: .normal)
        btnCardProfile.layer.zPosition = 910
        self.view.addSubview(btnCardProfile)
        
        self.loadGenderAge()
        
        btnCardCloseOptions = UIButton(frame: CGRect(x: 73, y: 158, w: 268, h: 293))
        btnCardCloseOptions.layer.zPosition = 920
        self.view.addSubview(btnCardCloseOptions)
        btnCardCloseOptions.alpha = 0
        btnCardCloseOptions.addTarget(self, action: #selector(self.hideNameCard(_:)), for: .touchUpInside)
    }
    
    func loadGenderAge() {
        uiviewCardGender = UIView(frame: startFrame)
        uiviewCardGender.layer.anchorPoint = nameCardAnchor
        uiviewCardGender.backgroundColor = UIColor(r: 149, g: 207, b: 246, alpha: 100)
        uiviewCardGender.layer.cornerRadius = 9 * screenHeightFactor
        uiviewCardGender.layer.zPosition = 912
        self.view.addSubview(uiviewCardGender)
        imgCardGender = UIImageView(frame: startFrame)
        imgCardGender.contentMode = .scaleAspectFit
        imgCardGender.layer.anchorPoint = nameCardAnchor
        self.view.addSubview(imgCardGender)
        imgCardGender.layer.zPosition = 913
        lblCardAge = UILabel(frame: startFrame)
        lblCardAge.layer.anchorPoint = nameCardAnchor
        lblCardAge.textColor = UIColor.white
        lblCardAge.font = UIFont(name: "AvenirNext-Demibold", size: 13 * screenHeightFactor)
        lblCardAge.layer.zPosition = 913
        lblCardAge.alpha = 0
        self.view.addSubview(lblCardAge)
    }
    
    func updateNameCard(withUserId: Int) {
        btnCardChat.tag = withUserId
        btnCardOptions.tag = withUserId
        btnCardShowSelf.isHidden = true
        btnCardFav.isHidden = false
        General.shared.avatar(userid: withUserId) { (avatarImage) in
            self.imgCardAvatar.image = avatarImage
        }
        let userNameCard = FaeUser()
        userNameCard.getUserCard("\(withUserId)") { (status: Int, message: Any?) in
            guard status / 100 == 2 else { return }
            guard let unwrapMessage = message else {
                print("[getUserCard] message is nil")
                return
            }
            let profileInfo = JSON(unwrapMessage)
            let canShowGender = profileInfo["show_gender"].boolValue
            let gender = profileInfo["gender"].stringValue
            let canShowAge = profileInfo["show_age"].boolValue
            let age = profileInfo["age"].stringValue
            self.showGenderAge(showGender: canShowGender, gender: gender, showAge: canShowAge, age: age)
            self.lblNickName.text = profileInfo["nick_name"].stringValue
            self.lblShortIntro.text = profileInfo["short_intro"].stringValue
        }
    }
    
    fileprivate func showGenderAge(showGender: Bool, gender: String, showAge: Bool, age: String) {
        if !showGender && !showAge {
            uiviewCardGender.isHidden = true
            imgCardGender.image = nil
        } else if showGender && showAge {
            uiviewCardGender.isHidden = false
            if gender == "male" {
                imgCardGender.image = #imageLiteral(resourceName: "userGenderMale")
                uiviewCardGender.backgroundColor = UIColor.maleBackgroundColor()
            } else if gender == "female" {
                imgCardGender.image = #imageLiteral(resourceName: "userGenderFemale")
                uiviewCardGender.backgroundColor = UIColor.femaleBackgroundColor()
            } else {
                imgCardGender.image = nil
            }
            lblCardAge.text = age
            lblCardAge.frame.size = lblCardAge.intrinsicContentSize
            uiviewCardGender.frame.size.width = 32 * screenHeightFactor + lblCardAge.intrinsicContentSize.width
        } else if showAge && !showGender {
            uiviewCardGender.isHidden = false
            lblCardAge.text = age
            lblCardAge.frame.size = lblCardAge.intrinsicContentSize
            uiviewCardGender.frame.size.width = 17 * screenHeightFactor + lblCardAge.intrinsicContentSize.width
            lblCardAge.frame.origin.x = 97 * screenHeightFactor
            imgCardGender.image = nil
            uiviewCardGender.backgroundColor = UIColor.faeAppShadowGrayColor()
        } else if showGender && !showAge {
            uiviewCardGender.isHidden = false
            if gender == "male" {
                imgCardGender.image = #imageLiteral(resourceName: "userGenderMale")
                uiviewCardGender.backgroundColor = UIColor.maleBackgroundColor()
            } else if gender == "female" {
                imgCardGender.image = #imageLiteral(resourceName: "userGenderFemale")
                uiviewCardGender.backgroundColor = UIColor.femaleBackgroundColor()
            } else {
                imgCardGender.image = nil
            }
            uiviewCardGender.frame.size.width = 28 * screenHeightFactor
            lblCardAge.text = nil
        }
    }
    
    func btnChatAction(_ sender: UIButton) {
        self.hideNameCard(btnCardClose)
        let withUserId: NSNumber = NSNumber(value: sender.tag)
        // First get chatroom id
        getFromURL("chats/users/\(user_id)/\(withUserId.stringValue)", parameter: nil, authentication: headerAuthentication()) { status, result in
            var resultJson1 = JSON([])
            if status / 100 == 2 {
                resultJson1 = JSON(result!)
            }
            // then get with user name
            getFromURL("users/\(withUserId.stringValue)/name_card", parameter: nil, authentication: headerAuthentication()) { status, result in
                if status / 100 == 2 {
                    let resultJson2 = JSON(result!)
                    var chat_id: String?
                    if let id = resultJson1["chat_id"].number {
                        chat_id = id.stringValue
                    }
                    if let withNickName = resultJson2["nick_name"].string {
                        self.startChat(chat_id, withUserId: withUserId, withNickName: withNickName)
                    } else {
                        self.startChat(chat_id, withUserId: withUserId, withNickName: nil)
                    }
                }
            }
        }
    }
    
    func startChat(_ chat_id: String?, withUserId: NSNumber, withNickName: String?) {
        let chatVC = UIStoryboard(name: "Chat", bundle: nil).instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
        chatVC.chatRoomId = user_id < Int(withUserId) ? "\(user_id)-\(withUserId.stringValue)" : "\(withUserId.stringValue)-\(user_id)"
        chatVC.chat_id = chat_id
        // Bryan
        let nickName = withNickName ?? "Chat"
        // ENDBryan
        // chatVC.withUser = FaeWithUser(userName: withUserName, userId: withUserId.stringValue, userAvatar: nil)
        
        // Bryan
        // TODO: Tell nickname and username apart
        chatVC.realmWithUser = RealmUser()
        chatVC.realmWithUser!.userName = nickName
        chatVC.realmWithUser!.userID = withUserId.stringValue
        // chatVC.realmWithUser?.userAvatar =
        
        // RealmChat.addWithUser(withUser: chatVC.realmWithUser!)
        
        // EndBryan
        
        self.navigationController?.pushViewController(chatVC, animated: true)
    }
    
    func showNameCardOptions(_ sender: UIButton) {
        btnCardCloseOptions.alpha = 1
        btnCardClose.tag = 1
        var thisIsMe = false
        if sender.tag == Int(user_id) {
            print("[showNameCardOptions] this is me")
            thisIsMe = true
        }
        let subviewXBefore: CGFloat = 243
        let subviewYBefore: CGFloat = 151
        let subviewXAfter: CGFloat = 79
        let subviewYAfter: CGFloat = subviewYBefore
        let subviewWidthAfter: CGFloat = 164
        let subviewHeightAfter: CGFloat = 110
        let firstButtonX: CGFloat = 103
        let secondButtonX: CGFloat = 172
        let buttonY: CGFloat = 191
        let buttonWidth: CGFloat = 50
        let buttonHeight: CGFloat = 51
        
        btnCardOptions.setImage(#imageLiteral(resourceName: "moreOptionMapNameCardReal"), for: .normal)
        
        nameCardMoreOptions = UIImageView(frame: CGRect(x: subviewXBefore, y: subviewYBefore, w: 0, h: 0))
        nameCardMoreOptions.image = #imageLiteral(resourceName: "nameCardOptions")
        self.btnCardCloseOptions.addSubview(nameCardMoreOptions)
        
        shareNameCard = UIButton(frame: CGRect(x: subviewXBefore, y: subviewYBefore, w: 0, h: 0))
        shareNameCard.setImage(#imageLiteral(resourceName: "pinDetailShare"), for: .normal)
        self.btnCardCloseOptions.addSubview(shareNameCard)
        shareNameCard.clipsToBounds = true
        shareNameCard.alpha = 0.0
        //        shareNameCard.addTarget(self, action: #selector(CommentPinDetailViewController.actionShareComment(_:)), for: .TouchUpInside)
        
        btnEditNameCard = UIButton(frame: CGRect(x: subviewXBefore, y: subviewYBefore, w: 0, h: 0))
        btnEditNameCard.setImage(#imageLiteral(resourceName: "pinDetailEdit"), for: .normal)
        self.btnCardCloseOptions.addSubview(btnEditNameCard)
        btnEditNameCard.clipsToBounds = true
        btnEditNameCard.alpha = 0.0
        //        editNameCard.addTarget(self, action: #selector(CommentPinDetailViewController.actionEditComment(_:)), for: .touchUpInside)
        
        reportNameCard = UIButton(frame: CGRect(x: subviewXBefore, y: subviewYBefore, w: 0, h: 0))
        reportNameCard.setImage(#imageLiteral(resourceName: "pinDetailReport"), for: .normal)
        self.btnCardCloseOptions.addSubview(reportNameCard)
        reportNameCard.clipsToBounds = true
        reportNameCard.alpha = 0.0
        reportNameCard.addTarget(self, action: #selector(self.actionReportThisPin(_:)), for: .touchUpInside)
        
        UIView.animate(withDuration: 0.3, animations: ({
            self.nameCardMoreOptions.frame = CGRect(x: subviewXAfter, y: subviewYAfter, w: subviewWidthAfter, h: subviewHeightAfter)
            self.shareNameCard.frame = CGRect(x: firstButtonX, y: buttonY, w: buttonWidth, h: buttonHeight)
            self.shareNameCard.alpha = 1.0
            if thisIsMe {
                self.btnEditNameCard.alpha = 1.0
                self.btnEditNameCard.frame = CGRect(x: secondButtonX, y: buttonY, w: buttonWidth, h: buttonHeight)
            } else {
                self.reportNameCard.alpha = 1.0
                self.reportNameCard.frame = CGRect(x: secondButtonX, y: buttonY, w: buttonWidth, h: buttonHeight)
            }
        }))
    }
}
