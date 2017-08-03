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
    
    func hideNameCard(_ sender: UIButton) {
        deselectAllAnnotations()
        UIView.animate(withDuration: 0.3, animations: ({
            if sender == self.btnCardClose {
                self.imgBackShadow.frame = CGRect(x: 414 / 2, y: 451, w: 0, h: 0)
                self.imgCover.frame = self.startFrame
                self.imgAvatarShadow.frame = self.startFrame
                self.imgAvatar.frame = self.startFrame
                self.btnChat.frame = self.startFrame
                self.lblNickName.frame = CGRect(x: 114, y: 451, w: 0, h: 0)
                self.lblShortIntro.frame = self.startFrame
                self.imgMiddleLine.frame = self.startFrame
                self.btnFav.frame = self.startFrame
                self.btnWaveSelf.frame = self.startFrame
                self.btnOptions.frame = self.startFrame
                self.btnProfile.frame = self.startFrame
                self.uiviewPrivacy.frame = self.startFrame
            }
            if sender.tag == 1 || sender == self.btnCloseOptions {
                self.btnOptions.setImage(#imageLiteral(resourceName: "moreOptionMapNameCardFade"), for: .normal)
                sender.tag = 0
                self.nameCardMoreOptions.frame = CGRect(x: 243, y: 151, w: 0, h: 0)
                let btnFrame = CGRect(x: 243, y: 191, w: 0, h: 0)
                self.shareNameCard.frame = btnFrame
                self.btnEditNameCard.frame = btnFrame
                self.reportNameCard.frame = btnFrame
                self.shareNameCard.alpha = 0
                self.btnEditNameCard.alpha = 0
                self.reportNameCard.alpha = 0
                self.btnCloseOptions.alpha = 0
            }
        }), completion: { _ in
            if sender == self.btnCardClose {
                self.boolCanUpdateUserPin = true
                self.uiviewPrivacy.isHidden = true
                self.lblNickName.alpha = 0
            }
        })
    }
    
    func loadNameCard() {
        btnCardClose = UIButton()
        btnCardClose.layer.zPosition = 900
        btnCardClose.alpha = 0
        btnCardClose.addTarget(self, action: #selector(hideNameCard(_:)), for: .touchUpInside)
    }
    
    func btnChatAction(_ sender: UIButton) {
        uiviewNameCard.hide()
        let withUserId: NSNumber = NSNumber(value: sender.tag)
        // First get chatroom id
        getFromURL("chats/users/\(Key.shared.user_id)/\(withUserId.stringValue)", parameter: nil, authentication: headerAuthentication()) { status, result in
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
        chatVC.chatRoomId = Key.shared.user_id < Int(withUserId) ? "\(Key.shared.user_id)-\(withUserId.stringValue)" : "\(withUserId.stringValue)-\(Key.shared.user_id)"
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
        btnCloseOptions.alpha = 1
        btnCardClose.tag = 1
        var thisIsMe = false
        if sender.tag == Int(Key.shared.user_id) {
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
        
        btnOptions.setImage(#imageLiteral(resourceName: "moreOptionMapNameCardReal"), for: .normal)
        
        nameCardMoreOptions = UIImageView(frame: CGRect(x: subviewXBefore, y: subviewYBefore, w: 0, h: 0))
        nameCardMoreOptions.image = #imageLiteral(resourceName: "nameCardOptions")
        btnCloseOptions.addSubview(nameCardMoreOptions)
        
        shareNameCard = UIButton(frame: CGRect(x: subviewXBefore, y: subviewYBefore, w: 0, h: 0))
        shareNameCard.setImage(#imageLiteral(resourceName: "pinDetailShare"), for: .normal)
        btnCloseOptions.addSubview(shareNameCard)
        shareNameCard.clipsToBounds = true
        shareNameCard.alpha = 0.0
        //        shareNameCard.addTarget(self, action: #selector(CommentPinDetailViewController.actionShareComment(_:)), for: .TouchUpInside)
        
        btnEditNameCard = UIButton(frame: CGRect(x: subviewXBefore, y: subviewYBefore, w: 0, h: 0))
        btnEditNameCard.setImage(#imageLiteral(resourceName: "pinDetailEdit"), for: .normal)
        btnCloseOptions.addSubview(btnEditNameCard)
        btnEditNameCard.clipsToBounds = true
        btnEditNameCard.alpha = 0.0
        //        editNameCard.addTarget(self, action: #selector(CommentPinDetailViewController.actionEditComment(_:)), for: .touchUpInside)
        
        reportNameCard = UIButton(frame: CGRect(x: subviewXBefore, y: subviewYBefore, w: 0, h: 0))
        reportNameCard.setImage(#imageLiteral(resourceName: "pinDetailReport"), for: .normal)
        btnCloseOptions.addSubview(reportNameCard)
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
