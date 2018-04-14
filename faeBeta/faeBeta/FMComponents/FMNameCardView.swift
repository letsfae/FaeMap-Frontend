//
//  FMNameCardView.swift
//  faeBeta
//
//  Created by Yue Shen on 8/15/17.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit
import SwiftyJSON
import RealmSwift

protocol NameCardDelegate: class {
    func openFaeUsrInfo()
    func chatUser(id: Int)
    func reportUser(id: Int)
    func openAddFriendPage(userId: Int, status: FriendStatus)
}

protocol PassStatusFromViewToButtonDelegate: class {
    func passFriendStatusFromView(status: FriendStatus)
    func updateNameCardAfterEditing()
}

class FMNameCardView: UIView, PassStatusFromViewToButtonDelegate {
    
    weak var delegate: NameCardDelegate?
    let faeContact = FaeContact()
    var statusMode: FriendStatus = .defaultMode
    
    var userId: Int = 0 {
        didSet {
            if userId > 0 { updateNameCard(with: userId) }
        }
    }
    //var requestId: Int = -1
    
    var boolCardOpened = false
    var boolOptionsOpened = false
    
    let initialFrame = CGRect.zero
    let secondaryFrame: CGRect = {
        return CGRect(x: 160, y: 175, w: 0, h: 0) // y: 350
    }()
    let initFrame: CGRect = {
//        if screenHeight == 812 {
//            return CGRect(x: 269, y: 180 / 736 * 812, w: 0, h: 0)
//        }
        return CGRect(x: 269, y: 180, w: 0, h: 0)
    }()
    let nextFrame: CGRect = {
//        if screenHeight == 812 {
//            return CGRect(x: 105, y: 180 / 736 * 812, w: 164, h: 110)
//        }
        return CGRect(x: 105, y: 180, w: 164, h: 110)
    }()
    let firstBtnFrame = CGRect(x: 129, y: 220, w: 50, h: 51)
    let secondBtnFrame = CGRect(x: 198, y: 220, w: 50, h: 51)
    
    let nameCardAnchor = CGPoint(x: 0.5, y: 1.0)
    var imgAvatarShadow: UIImageView!
    var btnChat: UIButton!
    var btnCloseOptions: UIButton!
    var btnProfile: UIButton!
    var btnOptions: UIButton!
    var btnCloseCard: UIButton!
    var btnEditNameCard: UIButton!
    var imgAvatar: UIImageView!
    var imgBackShadow: UIImageView!
    var imgCover: UIImageView!
    var imgMiddleLine: UIImageView!
    var lblNickName: UILabel!
    var lblUserName: UILabel!
    var uiviewPrivacy: FaeGenderView!
    var imgMoreOptions: UIImageView!
    var btnReport: UIButton!
    var btnShare: UIButton!
    var btnBlock: UIButton!
    var imgMoodAvatar: UIImageView!
    
    var btnLeftPart: UIButton!
    var btnRightPart: UIButton!
    var btnTopPart: UIButton!
    var btnBottomPart: UIButton!
    
    var isAnimating = false
    
    var uiviewBackground: UIButton!
    var boolPending = false
    
    var cgfloatCenter: CGFloat = {
        return 276 / 736 * screenHeight
    }()
    
    var boolSmallSize: Bool = false {
        didSet {
            guard fullLoaded else { return }
            if boolSmallSize {
                imgBackShadow.frame = CGRect(x: 0, y: 0, w: 320, h: 301)
                imgBackShadow.image = #imageLiteral(resourceName: "namecardsub_shadow_new_sm")
            } else {
                imgBackShadow.frame = CGRect(x: 0, y: 0, w: 320, h: 350)
                imgBackShadow.image = #imageLiteral(resourceName: "namecardsub_shadow_new")
            }
            imgMiddleLine.isHidden = boolSmallSize
            btnChat.isHidden = boolSmallSize
            btnProfile.isHidden = boolSmallSize
        }
    }
    
    var fullLoaded = false
    
    override init(frame: CGRect = CGRect.zero) {
        super.init(frame: frame)
        center.x = screenWidth / 2
        center.y = cgfloatCenter // 451
        self.frame.size.width = 320 * screenWidthFactor
        loadContent()
        fullLoaded = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func showFullNameCard() {
        var iPhone_X_offset: CGFloat = 129
        if screenHeight == 812 {
            iPhone_X_offset = 129 / 736 * 812 + 50
        }
        self.frame = CGRect(x: 47, y: iPhone_X_offset, w: 320, h: 350)
        self.imgBackShadow.frame = CGRect(x: 0, y: 0, w: 320, h: 350) // height 301
        self.imgCover.frame = CGRect(x: 26, y: 37, w: 268, h: 125)
        self.imgAvatarShadow.frame = CGRect(x: 116, y: 112, w: 88, h: 88)
        self.imgAvatar.frame = CGRect(x: 123, y: 119, w: 74, h: 74)
        self.imgMoodAvatar.frame = CGRect(x: 169, y: 167, w: 35, h: 33)
        self.btnChat.frame = CGRect(x: self.userId == Key.shared.user_id ? 146.5 : 98.5, y: 272, w: 27, h: 27)
        self.imgMiddleLine.frame = CGRect(x: 41, y: 259.5, w: 238, h: 1)
        self.btnOptions.frame = CGRect(x: 247, y: 171, w: 32, h: 18)
        self.btnProfile.frame = CGRect(x: 195, y: 272, w: 27, h: 27)
        self.uiviewPrivacy.frame = CGRect(x: 41, y: 171, w: 46, h: 18)
        self.btnLeftPart.frame = CGRect(x: 0, y: 0, w: 26, h: 350)
        self.btnRightPart.frame = CGRect(x: 294, y: 0, w: 26, h: 350)
        self.btnTopPart.frame = CGRect(x: 26, y: 0, w: 268, h: 38)
        self.btnBottomPart.frame = CGRect(x: 26, y: 312, w: 268, h: 38)
        self.lblNickName.frame = CGRect(x: 67, y: 202, w: 186, h: 25)
        self.lblNickName.alpha = 1
        self.lblUserName.frame = CGRect(x: 75, y: 228, w: 171, h: 18)
        self.lblUserName.alpha = 1
    }
    
    // MARK: - Actions
    
    @objc func openFaeUsrInfo() {
        delegate?.openFaeUsrInfo()
    }
    
    @objc func btnChatAction() {
        delegate?.chatUser(id: userId)
    }
    
    func reportUser() {
        delegate?.reportUser(id: userId)
    }
    
    @objc func hideOptions(_ sender: UIButton) {
        guard boolOptionsOpened else { return }
        boolOptionsOpened = false
        btnOptions.isSelected = false
        let btnFrame = CGRect(x: 243 + 26, y: 180, w: 0, h: 0)
        UIView.animate(withDuration: 0.3, animations: ({
            self.imgMoreOptions.frame = CGRect(x: 243 + 26, y: 180, w: 0, h: 0)
            self.btnShare.frame = btnFrame
            self.btnEditNameCard.frame = btnFrame
            self.btnReport.frame = btnFrame
            self.btnBlock.frame = btnFrame
            self.btnShare.alpha = 0
            self.btnEditNameCard.alpha = 0
            self.btnReport.alpha = 0
            self.btnCloseOptions.alpha = 0
            self.btnBlock.alpha = 0
        }), completion: nil)
    }
    
    @objc func showOptions(_ sender: UIButton) {
        var thisIsMe = false
        if userId == Int(Key.shared.user_id) {
            print("[showNameCardOptions] this is me")
            thisIsMe = true
        }
        
        if thisIsMe {
            statusMode = .nameCardSelf
        } else {
            statusMode = .nameCardOther
        }
        
        delegate?.openAddFriendPage(userId: userId, status: statusMode)
        
        /*
        guard !boolOptionsOpened else { return }
        boolOptionsOpened = true
        btnCloseOptions.alpha = 1
        btnOptions.isSelected = true
        var thisIsMe = false
        if userId == Int(Key.shared.user_id) {
            print("[showNameCardOptions] this is me")
            thisIsMe = true
        }
        
        if imgMoreOptions != nil { imgMoreOptions.removeFromSuperview() }
        imgMoreOptions = UIImageView(frame: initFrame)
        imgMoreOptions.image = #imageLiteral(resourceName: "nameCardOptions")
        addSubview(imgMoreOptions)
        
        if btnShare != nil { btnShare.removeFromSuperview() }
        btnShare = UIButton(frame: initFrame)
        btnShare.setImage(#imageLiteral(resourceName: "pinDetailShare"), for: .normal)
        addSubview(btnShare)
        btnShare.clipsToBounds = true
        btnShare.alpha = 0
        
        if btnBlock != nil { btnBlock.removeFromSuperview() }
        btnBlock = UIButton(frame: initFrame)
        btnBlock.setImage(#imageLiteral(resourceName: "blockUser"), for: .normal)
        addSubview(btnBlock)
        btnBlock.clipsToBounds = true
        btnBlock.alpha = 0
        
        if btnEditNameCard != nil { btnEditNameCard.removeFromSuperview() }
        btnEditNameCard = UIButton(frame: initFrame)
        btnEditNameCard.setImage(#imageLiteral(resourceName: "pinDetailEdit"), for: .normal)
        addSubview(btnEditNameCard)
        btnEditNameCard.clipsToBounds = true
        btnEditNameCard.alpha = 0
        
        if btnReport != nil {
            btnReport.removeTarget(self, action: #selector(reportUser), for: .touchUpInside)
            btnReport.removeFromSuperview()
        }
        btnReport = UIButton(frame: initFrame)
        btnReport.setImage(#imageLiteral(resourceName: "pinDetailReport"), for: .normal)
        addSubview(btnReport)
        btnReport.clipsToBounds = true
        btnReport.alpha = 0
        btnReport.addTarget(self, action: #selector(reportUser), for: .touchUpInside)
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.imgMoreOptions.frame = self.nextFrame
            if thisIsMe {
                self.btnShare.alpha = 1
                self.btnShare.frame = self.firstBtnFrame
                self.btnEditNameCard.alpha = 1
                self.btnEditNameCard.frame = self.secondBtnFrame
            } else {
                self.btnBlock.alpha = 1
                self.btnBlock.frame = self.firstBtnFrame
                self.btnReport.alpha = 1
                self.btnReport.frame = self.secondBtnFrame
            }
        }, completion: nil)
        */
    }
    
    func updateNameCard(with userId: Int) {
        uiviewPrivacy.isHidden = true
        if userId == 1 {
            imgAvatar.image = UIImage(named: "faeAvatar")
            imgAvatar.isUserInteractionEnabled = false
            imgMoodAvatar.isHidden = true
            uiviewPrivacy.isHidden = true
            lblUserName.text = "@faemaps"
            lblNickName.text = "Fae Map Team"
            btnOptions.isHidden = true
            return
        }
        General.shared.avatarCached(userid: userId) { (avatarImage) in
            self.imgAvatar.image = avatarImage
        }
        General.shared.avatar(userid: userId) { (avatarImage) in
            self.imgAvatar.image = avatarImage
            self.imgAvatar.isUserInteractionEnabled = true
        }
        General.shared.coverPhotoCached(userid: userId) { (coverPhoto) in
            self.imgCover.image = coverPhoto
        }
        General.shared.coverPhoto(userid: userId) { (coverPhoto) in
            self.imgCover.image = coverPhoto
            self.imgCover.isUserInteractionEnabled = true
        }
        uiviewPrivacy.loadGenderAge(id: userId) { (nickName, userName, shortIntro) in
            self.lblNickName.text = nickName
            self.lblUserName.text = shortIntro == "" ? "@" + userName : shortIntro
            self.getFriendStatus(id: userId)
        }
    }
    
    func show(avatar: UIImage? = nil, completionHandler: @escaping () -> Void) {
        guard !isAnimating else { return }
        isAnimating = true
        boolCardOpened = true
        btnProfile.isHidden = [Key.shared.user_id, 1].contains(self.userId) || boolSmallSize
        btnChat.isHidden = boolSmallSize
        if avatar == nil {
            let getMiniAvatar = FaeUser()
            getMiniAvatar.getOthersProfile("\(userId)", completion: { (status, message) in
                if status / 100 == 2 && message != nil {
                    let messageJson = JSON(message!)
                    let miniAvatarID = messageJson["mini_avatar"].intValue
                    self.imgMoodAvatar.image = Mood.avatars[miniAvatarID] ?? UIImage()
                }
            })
            uiviewBackground = UIButton(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
            self.superview?.addSubview(uiviewBackground)
            uiviewBackground.alpha = 0
            uiviewBackground.backgroundColor = UIColor._115115115().withAlphaComponent(0.3)
            uiviewBackground.layer.zPosition = 899
            uiviewBackground.addTarget(self, action: #selector(hideSelf), for: .touchUpInside)
            self.superview?.bringSubview(toFront: self)
            UIView.animate(withDuration: 0.5, animations: {
                self.uiviewBackground.alpha = 1
            }, completion: nil)
        } else {
            imgMoodAvatar.image = avatar
        }
        var iPhone_X_offset: CGFloat = 129
        if screenHeight == 812 {
            iPhone_X_offset = 129 / 736 * 812 + 50
        }
        UIView.animate(withDuration: 0.3, animations: {
            self.frame = CGRect(x: 47, y: iPhone_X_offset, w: 320, h: 350)
            self.imgBackShadow.frame = CGRect(x: 0, y: 0, w: 320, h: self.boolSmallSize ? 301 : 350) // height 301
            self.imgCover.frame = CGRect(x: 26, y: 37, w: 268, h: 125)
            self.imgAvatarShadow.frame = CGRect(x: 116, y: 112, w: 88, h: 88)
            self.imgAvatar.frame = CGRect(x: 123, y: 119, w: 74, h: 74)
            self.imgMoodAvatar.frame = CGRect(x: 169, y: 167, w: 35, h: 33)
            self.btnChat.frame = CGRect(x: ([Key.shared.user_id, 1].contains(self.userId)) ? 146.5 : 98.5, y: 272, w: 27, h: 27)
            self.imgMiddleLine.frame = CGRect(x: 41, y: 259.5, w: 238, h: 1)
            self.btnOptions.frame = CGRect(x: 247, y: 171, w: 32, h: 18)
            self.btnProfile.frame = CGRect(x: 195, y: 272, w: 27, h: 27)
            self.uiviewPrivacy.frame = CGRect(x: 41, y: 171, w: 46, h: 18)
            self.btnLeftPart.frame = CGRect(x: 0, y: 0, w: 26, h: 350)
            self.btnRightPart.frame = CGRect(x: 294, y: 0, w: 26, h: 350)
            self.btnTopPart.frame = CGRect(x: 26, y: 0, w: 268, h: 38)
            self.btnBottomPart.frame = CGRect(x: 26, y: 312, w: 268, h: 38)
        }, completion: { _ in
            self.lblNickName.frame = CGRect(x: 67, y: 202, w: 186, h: 25)
            self.lblNickName.alpha = 1
            self.lblUserName.frame = CGRect(x: 75, y: 228, w: 171, h: 18)
            self.lblUserName.alpha = 1
            self.isAnimating = false
            completionHandler()
        })
    }
    
    func hide(completionHandler: @escaping () -> Void) {
        guard boolCardOpened else { completionHandler(); return }
        guard !isAnimating else { completionHandler(); return }
        boolCardOpened = false
        lblNickName.text = ""
        lblUserName.text = ""
        lblNickName.frame = initialFrame
        lblNickName.alpha = 0
        lblUserName.frame = initialFrame
        lblUserName.alpha = 0
        UIView.animate(withDuration: 0.3, animations: {
            self.imgBackShadow.frame = self.secondaryFrame
            self.imgCover.frame = self.secondaryFrame
            self.imgAvatarShadow.frame = self.secondaryFrame
            self.imgAvatar.frame = self.secondaryFrame
            self.imgMoodAvatar.frame = self.secondaryFrame
            self.btnChat.frame = self.secondaryFrame
            self.imgMiddleLine.frame = self.secondaryFrame
            self.btnOptions.frame = self.secondaryFrame
            self.btnProfile.frame = self.secondaryFrame
            self.uiviewPrivacy.frame = self.secondaryFrame
            self.btnLeftPart.frame = self.secondaryFrame
            self.btnRightPart.frame = self.secondaryFrame
            self.btnTopPart.frame = self.secondaryFrame
            self.btnBottomPart.frame = self.secondaryFrame
            if self.boolOptionsOpened {
                self.imgMoreOptions.frame = self.secondaryFrame
                self.btnShare.frame = self.secondaryFrame
                self.btnBlock.frame = self.secondaryFrame
                self.btnReport.frame = self.secondaryFrame
                self.btnEditNameCard.frame = self.secondaryFrame
            }
        }, completion: { _ in
            self.imgBackShadow.frame = self.initialFrame
            self.imgCover.frame = self.initialFrame
            self.imgAvatarShadow.frame = self.initialFrame
            self.imgAvatar.frame = self.initialFrame
            self.imgMoodAvatar.frame = self.initialFrame
            self.btnChat.frame = self.initialFrame
            self.imgMiddleLine.frame = self.initialFrame
            self.btnOptions.frame = self.initialFrame
            self.btnProfile.frame = self.initialFrame
            self.uiviewPrivacy.frame = self.initialFrame
            self.frame = CGRect.zero
            self.center.x = screenWidth / 2
            self.center.y = self.cgfloatCenter // 451
            self.frame.size.width = 320 * screenWidthFactor
            self.imgAvatar.image = #imageLiteral(resourceName: "defaultMen")
            self.imgMoodAvatar.image = nil
            self.btnLeftPart.frame = self.initialFrame
            self.btnRightPart.frame = self.initialFrame
            self.btnTopPart.frame = self.initialFrame
            self.btnBottomPart.frame = self.initialFrame
            if self.boolOptionsOpened {
                self.imgMoreOptions.frame = self.initFrame
                self.btnShare.frame = self.initFrame
                self.btnBlock.frame = self.initFrame
                self.btnReport.frame = self.initFrame
                self.btnEditNameCard.frame = self.initFrame
                self.btnOptions.isSelected = false
                self.btnCloseOptions.alpha = 0
                self.boolOptionsOpened = false
            }
            completionHandler()
            Key.shared.FMVCtrler?.boolCanUpdateUsers = true
        })
        guard self.uiviewBackground != nil else { return }
        UIView.animate(withDuration: 0.5, animations: {
            self.uiviewBackground.alpha = 0
        }, completion: { _ in
            self.uiviewBackground.removeFromSuperview()
        })
    }
    
    private func loadContent() {
        layer.zPosition = 900
        
        imgBackShadow = UIImageView(frame: initialFrame)
        imgBackShadow.layer.anchorPoint = nameCardAnchor
        imgBackShadow.image = #imageLiteral(resourceName: "namecardsub_shadow_new")
        imgBackShadow.contentMode = .scaleAspectFit
        imgBackShadow.clipsToBounds = true
        addSubview(imgBackShadow)
        
        imgCover = UIImageView(frame: initialFrame)
        imgCover.image = UIImage(named: "Cover")
        imgCover.layer.anchorPoint = nameCardAnchor
        imgCover.clipsToBounds = true
        imgCover.contentMode = .scaleAspectFill
        addSubview(imgCover)
        let rectShape = CAShapeLayer()
        rectShape.bounds = CGRect(x: 25.5, y: 37.5, w: 269, h: 125)
        rectShape.position = CGPoint(x: 134*screenWidthFactor, y: 63.6*screenHeightFactor)
        rectShape.path = UIBezierPath(roundedRect: CGRect(x: 26, y: 37, w: 268, h: 125), byRoundingCorners: [.topRight, .topLeft], cornerRadii: CGSize(width: 18.9*screenHeightFactor, height: 18.9*screenHeightFactor)).cgPath
        //Here I'm masking the textView's layer with rectShape layer
        imgCover.layer.mask = rectShape
        
        imgAvatarShadow = UIImageView(frame: initialFrame)
        imgAvatarShadow.image = #imageLiteral(resourceName: "avatar_rim_shadow")
        imgAvatarShadow.layer.anchorPoint = nameCardAnchor
        addSubview(imgAvatarShadow)
        
        imgAvatar = UIImageView(frame: initialFrame)
        imgAvatar.layer.anchorPoint = nameCardAnchor
        imgAvatar.layer.cornerRadius = 37 * screenHeightFactor
        imgAvatar.layer.borderColor = UIColor.white.cgColor
        imgAvatar.layer.borderWidth = 6 * screenHeightFactor
        imgAvatar.image = #imageLiteral(resourceName: "defaultMen")
        imgAvatar.contentMode = .scaleAspectFill
        imgAvatar.layer.masksToBounds = true
        addSubview(imgAvatar)
        
        imgMoodAvatar = UIImageView(frame: initialFrame)
        imgMoodAvatar.layer.anchorPoint = nameCardAnchor
        imgMoodAvatar.contentMode = .scaleAspectFit
        imgMoodAvatar.layer.masksToBounds = true
        addSubview(imgMoodAvatar)
        
        btnChat = UIButton(frame: initialFrame)
        btnChat.layer.anchorPoint = nameCardAnchor
        btnChat.setImage(#imageLiteral(resourceName: "chatFromMap"), for: .normal)
        addSubview(btnChat)
        btnChat.addTarget(self, action: #selector(btnChatAction), for: .touchUpInside)
        
        lblNickName = UILabel(frame: CGRect(x: 114, y: 451, w: 0, h: 0))
        lblNickName.layer.anchorPoint = nameCardAnchor
        lblNickName.text = nil
        lblNickName.textAlignment = .center
        lblNickName.font = UIFont(name: "AvenirNext-DemiBold", size: 18 * screenHeightFactor)
        lblNickName.textColor = UIColor(red: 107 / 255, green: 105 / 255, blue: 105 / 255, alpha: 1.0)
        lblNickName.alpha = 0
        addSubview(lblNickName)
        
        lblUserName = UILabel(frame: initialFrame)
        lblUserName.layer.anchorPoint = nameCardAnchor
        lblUserName.text = ""
        lblUserName.textAlignment = .center
        lblUserName.font = UIFont(name: "AvenirNext-Medium", size: 13 * screenHeightFactor)
        lblUserName.textColor = UIColor._107105105()
        lblUserName.alpha = 0
        addSubview(lblUserName)
        
        imgMiddleLine = UIImageView(frame: initialFrame)
        imgMiddleLine.layer.anchorPoint = nameCardAnchor
        imgMiddleLine.backgroundColor = UIColor(r: 230, g: 230, b: 230, alpha: 100)
        addSubview(imgMiddleLine)
        
        btnOptions = UIButton(frame: initialFrame)
        btnOptions.layer.anchorPoint = nameCardAnchor
        btnOptions.setImage(#imageLiteral(resourceName: "moreOptionMapNameCardFade"), for: .normal)
        btnOptions.setImage(#imageLiteral(resourceName: "moreOptionMapNameCardReal"), for: .selected)
        addSubview(btnOptions)
        btnOptions.addTarget(self, action: #selector(showOptions(_:)), for: .touchUpInside)
        
        btnProfile = UIButton(frame: initialFrame)
        btnProfile.layer.anchorPoint = nameCardAnchor
        btnProfile.setImage(#imageLiteral(resourceName: "btnAddFriend"), for: .normal)
        btnProfile.addTarget(self, action: #selector(chooseFriendActions(_:)), for: .touchUpInside)
        addSubview(btnProfile)
        
        uiviewPrivacy = FaeGenderView(frame: initialFrame)
        uiviewPrivacy.layer.anchorPoint = nameCardAnchor
        addSubview(uiviewPrivacy)
        uiviewPrivacy.isHidden = true
        
        btnCloseOptions = UIButton(frame: CGRect(x: 0, y: 0, w: 320, h: 350)) // 26 29
        addSubview(btnCloseOptions)
        btnCloseOptions.alpha = 0
        btnCloseOptions.addTarget(self, action: #selector(hideOptions(_:)), for: .touchUpInside)
        
        //let tapGesture = UITapGestureRecognizer(target: self, action: #selector(openFaeUsrInfo))
        //imgAvatar.addGestureRecognizer(tapGesture)
        
        btnLeftPart = UIButton(frame: initialFrame)
        btnLeftPart.addTarget(self, action: #selector(hideSelf), for: .touchUpInside)
        addSubview(btnLeftPart)
        
        btnRightPart = UIButton(frame: initialFrame)
        btnRightPart.addTarget(self, action: #selector(hideSelf), for: .touchUpInside)
        addSubview(btnRightPart)
        
        btnTopPart = UIButton(frame: initialFrame)
        btnTopPart.addTarget(self, action: #selector(hideSelf), for: .touchUpInside)
        addSubview(btnTopPart)
        
        btnBottomPart = UIButton(frame: initialFrame)
        btnBottomPart.addTarget(self, action: #selector(hideSelf), for: .touchUpInside)
        addSubview(btnBottomPart)
    }
    
    @objc func hideSelf() {
        self.hide {}
    }
    
    func getFriendStatus(id: Int) {
        statusMode = .defaultMode
        let realm = try! Realm()
        if let user = realm.filterUser(id: id) {
            if user.relation & IS_FRIEND == IS_FRIEND {
                statusMode = .accepted
            } else if user.relation & FRIEND_REQUESTED == FRIEND_REQUESTED {
                statusMode = .pending
            } else if user.relation & FRIEND_REQUESTED_BY == FRIEND_REQUESTED_BY {
                statusMode = .requested
            } else if user.relation & BLOCKED == BLOCKED || user.relation & BLOCKED_BY == BLOCKED_BY {
                statusMode = .blocked
            }
            setButtonImage()
        } else {
            /*FaeUser().getUserRelation(String(id)) { (status: Int, message: Any?) in
                if status / 100 == 2 {
                    let json = JSON(message!)
                    let relation = Relations(json: json)
                    if relation.is_friend {
                        self.statusMode = .accepted
                    } else if relation.requested {
                        self.statusMode = .pending
                    } else if relation.requested_by {
                        self.statusMode = .requested
                    } else if relation.blocked || relation.blocked_by {   // blocked & blocked_by
                        self.statusMode = .blocked
                    }
                    self.setButtonImage()
                } else {
                    print("[get friend status fail] - \(status) \(message!)")
                }
            }*/
        }
    }
    
    fileprivate func setButtonImage() {
        switch statusMode {
        case .defaultMode:
            btnProfile.setImage(#imageLiteral(resourceName: "btnAddFriend"), for: .normal)
        case .accepted:
            btnProfile.setImage(#imageLiteral(resourceName: "gearIcon"), for: .normal)
        case .pending:
            boolPending = true
            btnProfile.setImage(#imageLiteral(resourceName: "questionIcon"), for: .normal)
        case .requested:
            boolPending = false
            btnProfile.setImage(#imageLiteral(resourceName: "questionIcon"), for: .normal)
        case .blocked:
            btnProfile.setImage(nil, for: .normal)
        default: break
        }
    }
    
    @objc func chooseFriendActions(_ sender: UIButton) {
        switch sender.currentImage {
        case #imageLiteral(resourceName: "btnAddFriend")?:
            statusMode = .defaultMode
        case #imageLiteral(resourceName: "gearIcon")?:
            statusMode = .accepted
        case #imageLiteral(resourceName: "questionIcon")?:
            statusMode = boolPending ? .pending : .requested
        case nil:
            statusMode = .blocked
        default:
            statusMode = .defaultMode
        }
        delegate?.openAddFriendPage(userId: userId, status: statusMode)
    }
    
    // MARK: PassStatusFromViewToButtonDelegate
    func passFriendStatusFromView(status: FriendStatus) {
        statusMode = status
        setButtonImage()
    }
    
    func updateNameCardAfterEditing() {
        if userId == Key.shared.user_id {
            userId = Key.shared.user_id
        }
    }
}

