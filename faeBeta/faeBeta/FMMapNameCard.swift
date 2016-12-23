//
//  FMMapNameCard.swift
//  faeBeta
//
//  Created by Yue on 12/15/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
import SDWebImage
import SwiftyJSON
import GoogleMaps

extension FaeMapViewController {
    
    func updateNameCard(withUserId: Int) {
        buttonChat.tag = withUserId
        buttonOptions.tag = withUserId
        buttonShowSelfOnMap.isHidden = true
        buttonFavorite.isHidden = false
        let stringHeaderURL = "\(baseURL)/files/users/\(withUserId)/avatar"
        imageAvatarNameCard.sd_setImage(with: URL(string: stringHeaderURL), placeholderImage: Key.sharedInstance.imageDefaultMale, options: .refreshCached)
        let userNameCard = FaeUser()
        userNameCard.getNamecardOfSpecificUser("\(withUserId)"){(status:Int, message: Any?) in
            if(status / 100 == 2) {
                print("[updateNameCard] \(message!)")
                let profileInfo = JSON(message!)
                if let canShowGender = profileInfo["show_gender"].bool {
                    print("[updateNameCard] canShowGender: \(canShowGender)")
                    if canShowGender {
                        self.uiviewUserGender.isHidden = false
                    }
                    else {
                        self.uiviewUserGender.isHidden = true
                    }
                }
                if let canShowAge = profileInfo["show_age"].bool {
                    print("[updateNameCard] canShowAge: \(canShowAge)")
                }
                if let displayName = profileInfo["nick_name"].string{
                    self.labelDisplayName.text = displayName
                }
                if let shortIntro = profileInfo["short_intro"].string{
                    self.labelShortIntro.text = shortIntro
                }
                if let age = profileInfo["age"].int {
                    print("[updateNameCard] age: \(age)")
                }
            }
        }
    }
    
    func getSelfNameCard(_ sender: UIButton) {
        buttonOptions.tag = Int(user_id)
        buttonShowSelfOnMap.isHidden = false
        buttonFavorite.isHidden = true
        if user_id != nil {
            let stringHeaderURL = "\(baseURL)/files/users/\(user_id.stringValue)/avatar"
            imageAvatarNameCard.sd_setImage(with: URL(string: stringHeaderURL), placeholderImage: Key.sharedInstance.imageDefaultMale, options: .refreshCached)
            buttonChat.tag = Int(user_id)
        }
        else {
            return
        }
        let camera = GMSCameraPosition.camera(withLatitude: currentLatitude+0.0012, longitude: currentLongitude, zoom: 17)
        faeMapView.animate (to: camera)
        UIView.animate(withDuration: 0.25, animations: {
            self.buttonFakeTransparentClosingView.alpha = 1
        })
        self.openUserPinActive = true
        let userNameCard = FaeUser()
        userNameCard.getSelfNamecard(){(status:Int, message: Any?) in
            if(status / 100 == 2){
                print("[updateNameCard] \(message!)")
                let profileInfo = JSON(message!)
                if let canShowGender = profileInfo["show_gender"].bool {
                    print("[updateNameCard] canShowGender: \(canShowGender)")
                }
                if let canShowAge = profileInfo["show_age"].bool {
                    print("[updateNameCard] canShowAge: \(canShowAge)")
                }
                if let displayName = profileInfo["nick_name"].string{
                    self.labelDisplayName.text = displayName
                }
                if let shortIntro = profileInfo["short_intro"].string{
                    self.labelShortIntro.text = shortIntro
                }
                if let age = profileInfo["age"].int {
                    print("[updateNameCard] age: \(age)")
                }
            }
        }
    }
    
    func loadNameCard() {
        buttonFakeTransparentClosingView = UIButton(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
        self.view.addSubview(buttonFakeTransparentClosingView)
        buttonFakeTransparentClosingView.layer.zPosition = 998
        buttonFakeTransparentClosingView.alpha = 0
        buttonFakeTransparentClosingView.addTarget(self, action: #selector(self.hideNameCard(_:)), for: .touchUpInside)
        
        uiViewNameCard = UIView(frame: CGRect(x: 73*screenWidthFactor, y: 158*screenWidthFactor, width:268*screenWidthFactor, height: 293*screenWidthFactor))
        imageBackground = UIImageView(frame: CGRect(x: 0*screenWidthFactor, y: 0*screenWidthFactor, width:268*screenWidthFactor, height: 293*screenWidthFactor))
        imageBackground.image = UIImage(named: "NameCard")
        imageBackground.contentMode = UIViewContentMode.scaleAspectFit
        uiViewNameCard.addSubview(imageBackground)
        uiViewNameCard.layer.shadowColor = UIColor.gray.cgColor
        uiViewNameCard.layer.shadowOffset = CGSize.zero
        uiViewNameCard.layer.shadowOpacity = 1
        uiViewNameCard.layer.shadowRadius = 25
        self.buttonFakeTransparentClosingView.addSubview(uiViewNameCard)
        
        buttonClosingOptionsInNameCard = UIButton(frame: CGRect(x: 0, y: 0, width:268*screenWidthFactor, height: 293*screenWidthFactor))
        self.uiViewNameCard.addSubview(buttonClosingOptionsInNameCard)
        buttonClosingOptionsInNameCard.isHidden = true
        buttonClosingOptionsInNameCard.addTarget(self, action: #selector(self.hideNameCard(_:)), for: .touchUpInside)
        
        imageCover = UIImageView(frame: CGRect(x: 0, y:0, width:268*screenWidthFactor, height: 125*screenWidthFactor))
        imageCover.image = UIImage(named: "Cover")
        self.uiViewNameCard.addSubview(imageCover)
        
        let baseView = UIView(frame: CGRect(x: 103*screenWidthFactor, y: 88*screenWidthFactor, width: 62*screenWidthFactor, height: 62*screenWidthFactor))
        baseView.backgroundColor = UIColor.clear
        baseView.layer.cornerRadius = 31*screenWidthFactor
        baseView.layer.borderColor = UIColor.white.cgColor
        baseView.layer.borderWidth = 6
        baseView.layer.shadowColor = UIColor.gray.cgColor
        baseView.layer.shadowOffset = CGSize.zero
        baseView.layer.shadowOpacity = 0.75
        baseView.layer.shadowRadius = 3
        imageAvatarNameCard = UIImageView(frame: CGRect(x: 0, y: 0, width: 62*screenWidthFactor, height: 62*screenWidthFactor))
        imageAvatarNameCard.layer.cornerRadius = 31*screenWidthFactor
        imageAvatarNameCard.layer.borderColor = UIColor.white.cgColor
        imageAvatarNameCard.layer.borderWidth = 6
        imageAvatarNameCard.image = #imageLiteral(resourceName: "defaultMen")
        imageAvatarNameCard.contentMode = .scaleAspectFill
        imageAvatarNameCard.layer.masksToBounds = true
        self.uiViewNameCard.addSubview(baseView)
        baseView.addSubview(imageAvatarNameCard)
        
        buttonChat = UIButton(frame: CGRect(x: 120.5*screenWidthFactor, y: 235*screenWidthFactor, width: 27*screenWidthFactor, height: 27*screenWidthFactor))
        buttonChat.setImage(#imageLiteral(resourceName: "chatFromMap"), for: .normal)
        self.uiViewNameCard.addSubview(buttonChat)
        buttonChat.addTarget(self, action: #selector(self.buttonChatAction(_:)), for: .touchUpInside)
        
        labelDisplayName = UILabel(frame: CGRect(x: 41*screenWidthFactor, y: 165*screenWidthFactor, width: 186*screenWidthFactor, height: 25*screenWidthFactor))
        labelDisplayName.text = ""
        labelDisplayName.textAlignment = .center
        labelDisplayName.font = UIFont(name: "AvenirNext-DemiBold", size: 18*screenWidthFactor)
        labelDisplayName.textColor = UIColor(red: 107/255, green: 105/255, blue: 105/255, alpha: 1.0)
        self.uiViewNameCard.addSubview(labelDisplayName)
        
        labelShortIntro = UILabel(frame: CGRect(x: 49*screenWidthFactor, y: 191*screenWidthFactor, width: 171*screenWidthFactor, height: 18*screenWidthFactor))
        labelShortIntro.text = ""
        labelShortIntro.textAlignment = .center
        labelShortIntro.font = UIFont(name: "AvenirNext-Medium", size: 13*screenWidthFactor)
        labelShortIntro.textColor = UIColor(red: 155/255, green: 155/255, blue: 155/255, alpha: 1.0)
        self.uiViewNameCard.addSubview(labelShortIntro)
        
        imageOneLine = UIImageView(frame: CGRect(x: 0*screenWidthFactor, y: 222.5*screenWidthFactor, width: 268*screenWidthFactor, height: 1*screenWidthFactor))
        imageOneLine.backgroundColor = UIColor(red: 206/255, green: 203/255, blue: 203/255, alpha: 1.0)
        self.uiViewNameCard.addSubview(imageOneLine)
        
        buttonFavorite = UIButton(frame: CGRect(x: 43*screenWidthFactor, y: 235*screenWidthFactor, width: 27*screenWidthFactor, height: 27*screenWidthFactor))
        buttonFavorite.setImage(UIImage(named: "Favorite"), for: .normal)
        self.uiViewNameCard.addSubview(buttonFavorite)
        
        buttonShowSelfOnMap = UIButton(frame: CGRect(x: 43*screenWidthFactor, y: 235*screenWidthFactor, width: 27*screenWidthFactor, height: 27*screenWidthFactor))
        buttonShowSelfOnMap.setImage(#imageLiteral(resourceName: "showSelfWaveToOthers"), for: .normal)
        self.uiViewNameCard.addSubview(buttonShowSelfOnMap)
        buttonShowSelfOnMap.isHidden = true
        
        buttonOptions = UIButton(frame: CGRect(x: 221*screenWidthFactor, y: 134*screenWidthFactor, width: 32*screenWidthFactor, height: 18*screenWidthFactor))
        buttonOptions.setImage(#imageLiteral(resourceName: "moreOptionMapNameCardFade"), for: .normal)
        self.uiViewNameCard.addSubview(buttonOptions)
        buttonOptions.addTarget(self, action: #selector(self.showNameCardOptions(_:)), for: .touchUpInside)
        
        buttonEmoji = UIButton(frame: CGRect(x: 198*screenWidthFactor, y: 235*screenWidthFactor, width: 27*screenWidthFactor, height: 27*screenWidthFactor))
        buttonEmoji.setImage(UIImage(named: "Emoji"), for: .normal)
        self.uiViewNameCard.addSubview(buttonEmoji)
        
        loadGenderAge()
        
        buttonClosingOptionsInNameCard = UIButton(frame: CGRect(x: 0, y: 0, width:268*screenWidthFactor, height: 293*screenWidthFactor))
        self.uiViewNameCard.addSubview(buttonClosingOptionsInNameCard)
        buttonClosingOptionsInNameCard.isHidden = true
        buttonClosingOptionsInNameCard.addTarget(self, action: #selector(self.hideNameCard(_:)), for: .touchUpInside)
    }
    
    func loadGenderAge() {
        uiviewUserGender = UIView(frame: CGRect(x: 15*screenWidthFactor, y: 134*screenWidthFactor, width: 28*screenWidthFactor, height: 18*screenWidthFactor))
        uiviewUserGender.backgroundColor = UIColor(red: 149/255, green: 207/255, blue: 246/255, alpha: 1)
        uiviewUserGender.layer.cornerRadius = 9*screenHeightFactor
        uiViewNameCard.addSubview(uiviewUserGender)
        imageUserGender = UIImageView(frame: CGRect(x: 9*screenWidthFactor, y: 3*screenWidthFactor, width: 10*screenWidthFactor, height: 12*screenWidthFactor))
        imageUserGender.image = #imageLiteral(resourceName: "userGenderMale")
        uiviewUserGender.addSubview(imageUserGender)
    }
    
    func buttonChatAction(_ sender: UIButton) {
        let withUserId: NSNumber = NSNumber(value: sender.tag)
        //First get chatroom id
        getFromURL("chats/users/\(user_id.stringValue)/\(withUserId.stringValue)", parameter: nil, authentication: headerAuthentication()) { (status, result) in
            var resultJson1 = JSON([])
            if(status / 100 == 2){
                resultJson1 = JSON(result!)
            }
            // then get with user name
            getFromURL("users/\(withUserId.stringValue)/profile", parameter: nil, authentication: headerAuthentication()) { (status, result) in
                if(status / 100 == 2){
                    let resultJson2 = JSON(result!)
                    var chat_id: String?
                    
                    if let id = resultJson1["chat_id"].number{
                        chat_id = id.stringValue
                    }
                    if let withUserName = resultJson2["user_name"].string {
                        self.startChat(chat_id ,withUserId: withUserId, withUserName: withUserName)
                    }else{
                        self.startChat(chat_id, withUserId: withUserId, withUserName: nil)
                    }
                }
            }
        }
    }
    
    func startChat(_ chat_id: String? ,withUserId: NSNumber, withUserName: String?){
        let chatVC = UIStoryboard(name: "Chat", bundle: nil) .instantiateViewController(withIdentifier: "ChatViewController")as! ChatViewController
        
        chatVC.chatRoomId = user_id.compare(withUserId).rawValue < 0 ? "\(user_id.stringValue)-\(withUserId.stringValue)" : "\(withUserId.stringValue)-\(user_id.stringValue)"
        chatVC.chat_id = chat_id
        let withUserName = withUserName ?? "Chat"
        chatVC.withUser = FaeWithUser(userName: withUserName, userId: withUserId.stringValue, userAvatar: nil)
        self.navigationController?.pushViewController(chatVC, animated: true)
    }
    
    func showNameCardOptions(_ sender: UIButton) {
        buttonClosingOptionsInNameCard.isHidden = false
        buttonFakeTransparentClosingView.tag = 1
        var thisIsMe = false
        if sender.tag == Int(user_id) {
            print("[showNameCardOptions] this is me")
            thisIsMe = true
        }
        let subviewXBefore: CGFloat = 243 / 414 * screenWidth
        let subviewYBefore: CGFloat = 151 / 414 * screenWidth
        let subviewXAfter: CGFloat = 79 / 414 * screenWidth
        let subviewYAfter: CGFloat = subviewYBefore
        let subviewWidthAfter: CGFloat = 164 / 414 * screenWidth
        let subviewHeightAfter: CGFloat = 110 / 414 * screenWidth
        let firstButtonX: CGFloat = 103 / 414 * screenWidth
        let secondButtonX: CGFloat = 172 / 414 * screenWidth
        let buttonY: CGFloat = 191 / 414 * screenWidth
        let buttonWidth: CGFloat = 44 / 414 * screenWidth
        let buttonHeight: CGFloat = 51 / 414 * screenWidth
        
        buttonOptions.setImage(#imageLiteral(resourceName: "moreOptionMapNameCardReal"), for: .normal)
        
        nameCardMoreOptions = UIImageView(frame: CGRect(x: subviewXBefore, y: subviewYBefore, width: 0, height: 0))
        nameCardMoreOptions.image = #imageLiteral(resourceName: "nameCardOptions")
        self.uiViewNameCard.addSubview(nameCardMoreOptions)
        
        shareNameCard = UIButton(frame: CGRect(x: subviewXBefore, y: subviewYBefore, width: 0, height: 0))
        shareNameCard.setImage(#imageLiteral(resourceName: "buttonShareOnCommentDetail"), for: .normal)
        self.uiViewNameCard.addSubview(shareNameCard)
        shareNameCard.clipsToBounds = true
        shareNameCard.alpha = 0.0
//        shareNameCard.addTarget(self, action: #selector(CommentPinDetailViewController.actionShareComment(_:)), for: .TouchUpInside)
        
        editNameCard = UIButton(frame: CGRect(x: subviewXBefore, y: subviewYBefore, width: 0, height: 0))
        editNameCard.setImage(#imageLiteral(resourceName: "buttonEditOnCommentDetail"), for: .normal)
        self.uiViewNameCard.addSubview(editNameCard)
        editNameCard.clipsToBounds = true
        editNameCard.alpha = 0.0
//        shareNameCard.addTarget(self, action: #selector(CommentPinDetailViewController.actionEditComment(_:)), for: .touchUpInside)
        
        reportNameCard = UIButton(frame: CGRect(x: subviewXBefore, y: subviewYBefore, width: 0, height: 0))
        reportNameCard.setImage(#imageLiteral(resourceName: "buttonReportOnCommentDetail"), for: .normal)
        self.uiViewNameCard.addSubview(reportNameCard)
        reportNameCard.clipsToBounds = true
        reportNameCard.alpha = 0.0
//        reportNameCard.addTarget(self, action: #selector(CommentPinDetailViewController.actionReportThisPin(_:)), for: .touchUpInside)
        
        UIView.animate(withDuration: 0.3, animations: ({
            self.nameCardMoreOptions.frame = CGRect(x: subviewXAfter, y: subviewYAfter, width: subviewWidthAfter, height: subviewHeightAfter)
            self.shareNameCard.frame = CGRect(x: firstButtonX, y: buttonY, width: buttonWidth, height: buttonHeight)
            self.shareNameCard.alpha = 1.0
            if thisIsMe {
                self.editNameCard.alpha = 1.0
                self.editNameCard.frame = CGRect(x: secondButtonX, y: buttonY, width: buttonWidth, height: buttonHeight)
            }
            else {
                self.reportNameCard.alpha = 1.0
                self.reportNameCard.frame = CGRect(x: secondButtonX, y: buttonY, width: buttonWidth, height: buttonHeight)
            }
        }))
    }
    
    func hideNameCard(_ sender: UIButton) {
        UIView.animate(withDuration: 0.3, animations: ({
            if sender == self.buttonFakeTransparentClosingView {
                self.buttonFakeTransparentClosingView.alpha = 0
            }
            if sender.tag == 1 || sender == self.buttonClosingOptionsInNameCard {
                self.buttonOptions.setImage(#imageLiteral(resourceName: "moreOptionMapNameCardFade"), for: .normal)
                self.buttonClosingOptionsInNameCard.isHidden = true
                sender.tag = 0
                let subviewXBefore: CGFloat = 243 / 414 * screenWidth
                let subviewYBefore: CGFloat = 151 / 414 * screenWidth
                let buttonY: CGFloat = 191 / 414 * screenWidth
                self.nameCardMoreOptions.frame = CGRect(x: subviewXBefore, y: subviewYBefore, width: 0, height: 0)
                self.shareNameCard.frame = CGRect(x: subviewXBefore, y: buttonY, width: 0, height: 0)
                self.editNameCard.frame = CGRect(x: subviewXBefore, y: buttonY, width: 0, height: 0)
                self.reportNameCard.frame = CGRect(x: subviewXBefore, y: buttonY, width: 0, height: 0)
                self.shareNameCard.alpha = 0
                self.editNameCard.alpha = 0
                self.reportNameCard.alpha = 0
            }
        }), completion: {(done: Bool) in
            self.canDoNextUserUpdate = true
        })
    }
}
