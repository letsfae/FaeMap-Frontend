//
//  FMMapNameCard.swift
//  faeBeta
//
//  Created by Yue on 12/15/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
import SwiftyJSON

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
        
        animateNameCard()
        
        uiviewCardPrivacy.loadGenderAge(id: user_id) { (nickName, _, shortIntro) in
            self.lblNickName.text = nickName
            self.lblShortIntro.text = shortIntro
        }
    }
    
    func animateNameCard() {
        let targetFrame = CGRect(x: 47, y: 129, w: 320, h: 350)
        uiviewCardPrivacy.isHidden = false
        UIView.animate(withDuration: 0.8, delay: 0.3, usingSpringWithDamping: 0.6, initialSpringVelocity: 0, options: .curveLinear, animations: {
            self.imgCardBack.frame = targetFrame
            self.imgCardCover.frame = CGRect(x: 73, y: 158, w: 268, h: 125)
            self.imgAvatarShadow.frame = CGRect(x: 163, y: 233, w: 88, h: 88) // 88 88
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
            self.uiviewCardPrivacy.frame = CGRect(x: 88, y: 292, w: 46, h: 18)
        }, completion: nil)
        
        imgCardAvatar.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.openFaeUsrInfo(_:)))
        imgCardAvatar.addGestureRecognizer(tapGesture)
    }
    
    func openFaeUsrInfo(_ sender: Any?) {
        let fmUsrInfo = FMUserInfo()
        fmUsrInfo.userId = aroundUsrId
        hideNameCard(btnCardClose)
        navigationController?.pushViewController(fmUsrInfo, animated: true)
    }
    
    func hideNameCard(_ sender: UIButton) {
        deselectAllAnnotations()
        UIView.animate(withDuration: 0.3, animations: ({
            if sender == self.btnCardClose {
                self.imgCardBack.frame = CGRect(x: 414 / 2, y: 451, w: 0, h: 0)
                self.imgCardCover.frame = self.startFrame
                self.imgAvatarShadow.frame = self.startFrame
                self.imgCardAvatar.frame = self.startFrame
                self.btnCardChat.frame = self.startFrame
                self.lblNickName.frame = CGRect(x: 114, y: 451, w: 0, h: 0)
                self.lblShortIntro.frame = self.startFrame
                self.imgCardLine.frame = self.startFrame
                self.btnCardFav.frame = self.startFrame
                self.btnCardShowSelf.frame = self.startFrame
                self.btnCardOptions.frame = self.startFrame
                self.btnCardProfile.frame = self.startFrame
                self.uiviewCardPrivacy.frame = self.startFrame
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
                self.uiviewCardPrivacy.isHidden = true
                self.lblNickName.alpha = 0
            }
        })
    }
    
    func loadNameCard() {
        btnCardClose = UIButton()
        btnCardClose.layer.zPosition = 900
        btnCardClose.alpha = 0
        btnCardClose.addTarget(self, action: #selector(hideNameCard(_:)), for: .touchUpInside)
        
        imgCardBack = UIImageView(frame: startFrame)
        imgCardBack.layer.anchorPoint = nameCardAnchor
        imgCardBack.image = #imageLiteral(resourceName: "namecardsub_shadow")
        imgCardBack.contentMode = .scaleAspectFit
        imgCardBack.clipsToBounds = true
        imgCardBack.layer.zPosition = 902
        view.addSubview(imgCardBack)
        
        imgCardCover = UIImageView(frame: startFrame)
        imgCardCover.image = UIImage(named: "Cover")
        imgCardCover.layer.anchorPoint = nameCardAnchor
        imgCardCover.layer.zPosition = 903
        view.addSubview(imgCardCover)
        
        imgAvatarShadow = UIImageView(frame: startFrame)
        imgAvatarShadow.image = #imageLiteral(resourceName: "avatar_rim_shadow")
        imgAvatarShadow.layer.anchorPoint = nameCardAnchor
        imgAvatarShadow.layer.zPosition = 904
        view.addSubview(imgAvatarShadow)
        
        imgCardAvatar = UIImageView(frame: startFrame)
        imgCardAvatar.layer.anchorPoint = nameCardAnchor
        imgCardAvatar.layer.cornerRadius = 37 * screenHeightFactor
        imgCardAvatar.layer.borderColor = UIColor.white.cgColor
        imgCardAvatar.layer.borderWidth = 6 * screenHeightFactor
        imgCardAvatar.image = #imageLiteral(resourceName: "defaultMen")
        imgCardAvatar.contentMode = .scaleAspectFill
        imgCardAvatar.layer.masksToBounds = true
        imgCardAvatar.layer.zPosition = 905
        view.addSubview(imgCardAvatar)
        
        btnCardChat = UIButton(frame: startFrame)
        btnCardChat.layer.anchorPoint = nameCardAnchor
        btnCardChat.setImage(#imageLiteral(resourceName: "chatFromMap"), for: .normal)
        btnCardChat.layer.zPosition = 906
        view.addSubview(btnCardChat)
        btnCardChat.addTarget(self, action: #selector(btnChatAction(_:)), for: .touchUpInside)
        
        lblNickName = UILabel(frame: CGRect(x: 114, y: 451, w: 0, h: 0))
        lblNickName.layer.anchorPoint = nameCardAnchor
        lblNickName.text = nil
        lblNickName.textAlignment = .center
        lblNickName.font = UIFont(name: "AvenirNext-DemiBold", size: 18 * screenHeightFactor)
        lblNickName.textColor = UIColor(red: 107 / 255, green: 105 / 255, blue: 105 / 255, alpha: 1.0)
        lblNickName.layer.zPosition = 907
        lblNickName.alpha = 0
        view.addSubview(lblNickName)
        
        lblShortIntro = UILabel(frame: startFrame)
        lblShortIntro.layer.anchorPoint = nameCardAnchor
        lblShortIntro.text = ""
        lblShortIntro.textAlignment = .center
        lblShortIntro.font = UIFont(name: "AvenirNext-Medium", size: 13 * screenHeightFactor)
        lblShortIntro.textColor = UIColor(red: 155 / 255, green: 155 / 255, blue: 155 / 255, alpha: 1.0)
        lblShortIntro.layer.zPosition = 908
        view.addSubview(lblShortIntro)
        
        imgCardLine = UIImageView(frame: startFrame)
        imgCardLine.layer.anchorPoint = nameCardAnchor
        imgCardLine.backgroundColor = UIColor(red: 206 / 255, green: 203 / 255, blue: 203 / 255, alpha: 1.0)
        imgCardLine.layer.zPosition = 909
        view.addSubview(imgCardLine)
        
        btnCardFav = UIButton(frame: startFrame)
        btnCardFav.layer.anchorPoint = nameCardAnchor
        btnCardFav.setImage(UIImage(named: "Favorite"), for: .normal)
        btnCardFav.layer.zPosition = 910
        view.addSubview(btnCardFav)
        
        btnCardShowSelf = UIButton(frame: startFrame)
        btnCardShowSelf.layer.anchorPoint = nameCardAnchor
        btnCardShowSelf.layer.zPosition = 910
        btnCardShowSelf.setImage(#imageLiteral(resourceName: "showSelfWaveToOthers"), for: .normal)
        view.addSubview(btnCardShowSelf)
        btnCardShowSelf.isHidden = true
        
        btnCardOptions = UIButton(frame: startFrame)
        btnCardOptions.layer.anchorPoint = nameCardAnchor
        btnCardOptions.setImage(#imageLiteral(resourceName: "moreOptionMapNameCardFade"), for: .normal)
        btnCardOptions.layer.zPosition = 910
        view.addSubview(btnCardOptions)
        btnCardOptions.addTarget(self, action: #selector(showNameCardOptions(_:)), for: .touchUpInside)
        
        btnCardProfile = UIButton(frame: startFrame)
        btnCardProfile.layer.anchorPoint = nameCardAnchor
        btnCardProfile.setImage(#imageLiteral(resourceName: "Emoji"), for: .normal)
        btnCardProfile.addTarget(self, action: #selector(openFaeUsrInfo(_:)), for: .touchUpInside)
        btnCardProfile.layer.zPosition = 910
        view.addSubview(btnCardProfile)
        
        loadGenderAge()
        
        btnCardCloseOptions = UIButton(frame: CGRect(x: 73, y: 158, w: 268, h: 293))
        btnCardCloseOptions.layer.zPosition = 920
        view.addSubview(btnCardCloseOptions)
        btnCardCloseOptions.alpha = 0
        btnCardCloseOptions.addTarget(self, action: #selector(hideNameCard(_:)), for: .touchUpInside)
    }
    
    func loadGenderAge() {
        uiviewCardPrivacy = FaeGenderView(frame: startFrame)
        uiviewCardPrivacy.layer.anchorPoint = nameCardAnchor
        uiviewCardPrivacy.layer.zPosition = 912
        view.addSubview(uiviewCardPrivacy)
    }
    
    func updateNameCard(withUserId: Int) {
        btnCardChat.tag = withUserId
        btnCardOptions.tag = withUserId
        btnCardShowSelf.isHidden = true
        btnCardFav.isHidden = false
        aroundUsrId = withUserId
        General.shared.avatar(userid: withUserId) { (avatarImage) in
            self.imgCardAvatar.image = avatarImage
        }
        uiviewCardPrivacy.loadGenderAge(id: withUserId) { (nickName, _, shortIntro) in
            self.lblNickName.text = nickName
            self.lblShortIntro.text = shortIntro
        }
    } 
    
    func btnChatAction(_ sender: UIButton) {
        hideNameCard(btnCardClose)
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
        
        navigationController?.pushViewController(chatVC, animated: true)
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
        btnCardCloseOptions.addSubview(nameCardMoreOptions)
        
        shareNameCard = UIButton(frame: CGRect(x: subviewXBefore, y: subviewYBefore, w: 0, h: 0))
        shareNameCard.setImage(#imageLiteral(resourceName: "pinDetailShare"), for: .normal)
        btnCardCloseOptions.addSubview(shareNameCard)
        shareNameCard.clipsToBounds = true
        shareNameCard.alpha = 0.0
        //        shareNameCard.addTarget(self, action: #selector(CommentPinDetailViewController.actionShareComment(_:)), for: .TouchUpInside)
        
        btnEditNameCard = UIButton(frame: CGRect(x: subviewXBefore, y: subviewYBefore, w: 0, h: 0))
        btnEditNameCard.setImage(#imageLiteral(resourceName: "pinDetailEdit"), for: .normal)
        btnCardCloseOptions.addSubview(btnEditNameCard)
        btnEditNameCard.clipsToBounds = true
        btnEditNameCard.alpha = 0.0
        //        editNameCard.addTarget(self, action: #selector(CommentPinDetailViewController.actionEditComment(_:)), for: .touchUpInside)
        
        reportNameCard = UIButton(frame: CGRect(x: subviewXBefore, y: subviewYBefore, w: 0, h: 0))
        reportNameCard.setImage(#imageLiteral(resourceName: "pinDetailReport"), for: .normal)
        btnCardCloseOptions.addSubview(reportNameCard)
        reportNameCard.clipsToBounds = true
        reportNameCard.alpha = 0.0
        reportNameCard.addTarget(self, action: #selector(actionReportThisPin(_:)), for: .touchUpInside)
        
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
