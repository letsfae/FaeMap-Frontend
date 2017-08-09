//
//  FMCustomComponents.swift
//  faeBeta
//
//  Created by Yue Shen on 8/1/17.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit
import SwiftyJSON

protocol NameCardDelegate: class {
    func openFaeUsrInfo()
    func chatUser(id: Int)
    func reportUser(id: Int)
}

protocol PassStatusFromButtonToView: class {
    func passFriendStatusFromButton(id: Int, status: FriendStatus)
}

protocol PassStatusFromViewToButton: class {
    func passFriendStatusFromView(status: FriendStatus)
}

enum FriendStatus: String {
    case defaultMode
    case accepted
    case blocked
    case pending
}

class FMNameCardView: UIView, PassStatusFromViewToButton {
    
    weak var delegate: NameCardDelegate?
    weak var passStatusDelegate: PassStatusFromButtonToView?
    let faeContact = FaeContact()
    var statusMode: FriendStatus = .defaultMode
    
    var userId: Int = 0 {
        didSet {
            if userId > 0 { updateNameCard(withUserId: userId) }
        }
    }
    
    var boolCardOpened = false
    var boolOptionsOpened = false
    
    let initialFrame = CGRect.zero
    let secondaryFrame = CGRect(x: 160, y: 350, w: 0, h: 0)
    let initFrame = CGRect(x: 269, y: 180, w: 0, h: 0)
    let nextFrame = CGRect(x: 105, y: 180, w: 164, h: 110)
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
    
    override init(frame: CGRect = CGRect.zero) {
        super.init(frame: frame)
        center.x = screenWidth / 2
        center.y = 451 * screenHeightFactor
        self.frame.size.width = 320 * screenWidthFactor
        loadContent()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func openFaeUsrInfo() {
        delegate?.openFaeUsrInfo()
    }
    
    func btnChatAction() {
        delegate?.chatUser(id: userId)
    }
    
    func reportUser() {
        delegate?.reportUser(id: userId)
    }
    
    func hideOptions(_ sender: UIButton) {
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
    
    func showOptions(_ sender: UIButton) {
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
    }
    
    func updateNameCard(withUserId: Int) {
        General.shared.avatar(userid: withUserId) { (avatarImage) in
            self.imgAvatar.image = avatarImage
        }
        uiviewPrivacy.loadGenderAge(id: withUserId) { (nickName, userName, _) in
            self.lblNickName.text = nickName
            self.lblUserName.text = "@" + userName
        }
        getFriendStatus(id: withUserId)
    }
    
    func show() {
        boolCardOpened = true
        btnProfile.isHidden = self.userId == Key.shared.user_id
        UIView.animate(withDuration: 0.8, delay: 0.3, usingSpringWithDamping: 0.6, initialSpringVelocity: 0, options: .curveLinear, animations: {
            self.frame = CGRect(x: 47, y: 129, w: 320, h: 350)
            self.imgBackShadow.frame = CGRect(x: 0, y: 0, w: 320, h: 350)
            self.imgCover.frame = CGRect(x: 26, y: 29, w: 268, h: 125)
            self.imgAvatarShadow.frame = CGRect(x: 116, y: 104, w: 88, h: 88)
            self.imgAvatar.frame = CGRect(x: 123, y: 111, w: 74, h: 74)
            self.btnChat.frame = CGRect(x: self.userId == Key.shared.user_id ? 146.5 : 98.5, y: 264, w: 27, h: 27)
            self.imgMiddleLine.frame = CGRect(x: 41, y: 251.5, w: 238, h: 1)
            self.btnOptions.frame = CGRect(x: 247, y: 163, w: 32, h: 18)
            self.btnProfile.frame = CGRect(x: 195, y: 264, w: 27, h: 27)
            self.uiviewPrivacy.frame = CGRect(x: 41, y: 163, w: 46, h: 18)
        }, completion: { _ in
            self.lblNickName.frame = CGRect(x: 67, y: 194, w: 186, h: 25)
            self.lblNickName.alpha = 1
            self.lblUserName.frame = CGRect(x: 75, y: 220, w: 171, h: 18)
            self.lblUserName.alpha = 1
        })
    }
    
    func hide() {
        guard boolCardOpened else { return }
        boolCardOpened = false
        self.lblNickName.text = ""
        self.lblUserName.text = ""
        UIView.animate(withDuration: 0.3, animations: {
            self.imgBackShadow.frame = self.secondaryFrame
            self.imgCover.frame = self.secondaryFrame
            self.imgAvatarShadow.frame = self.secondaryFrame
            self.imgAvatar.frame = self.secondaryFrame
            self.btnChat.frame = self.secondaryFrame
            self.lblNickName.frame = self.secondaryFrame
            self.lblNickName.alpha = 0
            self.lblUserName.frame = self.secondaryFrame
            self.lblUserName.alpha = 0
            self.imgMiddleLine.frame = self.secondaryFrame
            self.btnOptions.frame = self.secondaryFrame
            self.btnProfile.frame = self.secondaryFrame
            self.uiviewPrivacy.frame = self.secondaryFrame
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
            self.btnChat.frame = self.initialFrame
            self.lblNickName.frame = CGRect(x: 114, y: 451, w: 0, h: 0)
            self.lblNickName.alpha = 0
            self.lblUserName.frame = self.initialFrame
            self.lblUserName.alpha = 0
            self.imgMiddleLine.frame = self.initialFrame
            self.btnOptions.frame = self.initialFrame
            self.btnProfile.frame = self.initialFrame
            self.uiviewPrivacy.frame = self.initialFrame
            self.frame = CGRect.zero
            self.center.x = screenWidth / 2
            self.center.y = 451 * screenWidthFactor
            self.frame.size.width = 320 * screenWidthFactor
            self.imgAvatar.image = #imageLiteral(resourceName: "defaultMen")
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
        addSubview(imgCover)
        
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
        
        btnCloseOptions = UIButton(frame: CGRect(x: 0, y: 0, w: 320, h: 350)) // 26 29
        addSubview(btnCloseOptions)
        btnCloseOptions.alpha = 0
        btnCloseOptions.addTarget(self, action: #selector(hideOptions(_:)), for: .touchUpInside)
    
        imgAvatar.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(openFaeUsrInfo))
        imgAvatar.addGestureRecognizer(tapGesture)
    }

    func getFriendStatus(id: Int) {
        statusMode = .defaultMode
        faeContact.getFriends() {(status: Int, message: Any?) in
            if status / 100 == 2 {
                let json = JSON(message!)
                if json.count != 0 {
                    for i in 0..<json.count {
                        if json[i]["friend_id"].intValue == id {
                            self.statusMode = .accepted
                            break
                        }
                    }
                }
                self.setButtonImage()
            } else {
                print("[FMUserInfo get friends list fail] - \(status) \(message!)")
            }
        }
        
        faeContact.getFriendRequestsSent() {(status: Int, message: Any?) in
            if status / 100 == 2 {
                let json = JSON(message!)
                if json.count != 0 {
                    for i in 0..<json.count {
                        if json[i]["requested_user_id"].intValue == id {
                            self.statusMode = .pending
                            break
                        }
                    }
                }
                self.setButtonImage()
            } else {
                print("[FMUserInfo get requested friends list fail] - \(status) \(message!)")
            }
        }
    }
    
    fileprivate func setButtonImage() {
        switch statusMode {
        case .defaultMode:
            btnProfile.setImage(#imageLiteral(resourceName: "btnAddFriend"), for: .normal)
            break
        case .accepted:
            btnProfile.setImage(#imageLiteral(resourceName: "gearIcon"), for: .normal)
            break
        case .pending:
            btnProfile.setImage(#imageLiteral(resourceName: "questionIcon"), for: .normal)
            break
        case .blocked:
            isHidden = true
            break
        }
    }
    
    func chooseFriendActions(_ sender: UIButton) {
        passStatusDelegate?.passFriendStatusFromButton(id: userId, status: statusMode)
    }
    
    // PassStatusFromViewToButton
    func passFriendStatusFromView(status: FriendStatus) {
        statusMode = status
        setButtonImage()
    }
    // PassStatusFromViewToButton End
}

class FMCompass: UIButton {
    
    var mapView: MKMapView!
    var nameCard = FMNameCardView()
    
    override init(frame: CGRect = CGRect.zero) {
        super.init(frame: CGRect(x: 22, y: 582 * screenWidthFactor, width: 59, height: 59))
        loadContent()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func loadContent() {
        setImage(#imageLiteral(resourceName: "mainScreenNorth"), for: .normal)
        addTarget(self, action: #selector(actionToNorth(_:)), for: .touchUpInside)
        layer.zPosition = 500
    }
    
    func actionToNorth(_ sender: UIButton) {
        let camera = mapView.camera
        camera.heading = 0
        mapView.setCamera(camera, animated: true)
        transform = CGAffineTransform.identity
        nameCard.hide()
    }
    
    func rotateCompass() {
        UIView.animate(withDuration: 0.5, animations: {
            self.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi * -self.mapView.camera.heading) / 180.0)
        })
    }
}

class FMLocateSelf: UIButton {
    
    var mapView: MKMapView!
    var nameCard = FMNameCardView()
    
    override init(frame: CGRect = CGRect.zero) {
        super.init(frame: CGRect(x: 333 * screenWidthFactor, y: 582 * screenWidthFactor, width: 59, height: 59))
        loadContent()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func loadContent() {
        setImage(#imageLiteral(resourceName: "mainScreenSelfCenter"), for: .normal)
        addTarget(self, action: #selector(actionLocateSelf(_:)), for: .touchUpInside)
        layer.zPosition = 500
    }
    
    func actionLocateSelf(_ sender: UIButton) {
        let camera = mapView.camera
        camera.centerCoordinate = LocManager.shared.curtLoc.coordinate
        mapView.setCamera(camera, animated: true)
        nameCard.hide()
    }
}

class FMAddWithdrawFriendView: UIView, PassStatusFromButtonToView {
    weak var delegate: PassStatusFromViewToButton?
    var uiviewChooseAction: UIView!
    var uiviewMsgSent: UIView!
    var btnActFirst: UIButton!
    var btnActSecond: UIButton!
    var btnActThird: UIButton!
    var btnOK: UIButton!
    var btnCancel:UIButton!
    var btnFriendSentBack: UIButton!
    var lblChoose: UILabel!
    var lblMsgSent: UILabel!
    
    var userId: Int = -1
    let faeContact = FaeContact()
    var requestId: Int = -1
    
    let ADD_FRIEND_ACT = 1
    let FOLLOW_ACT = 2
    let WITHDRAW_ACT = 3
    let RESEND_ACT = 4
    let REMOVE_FRIEND_ACT = 5
    let BLOCK_ACT = 6
    let REPORT_ACT = 7
    let UNFOLLOW_ACT = 8
    
    override init(frame: CGRect = CGRect.zero) {
        super.init(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
        loadContent()
        animationShowSelf()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func loadContent() {
        backgroundColor = UIColor(red: 107 / 255, green: 105 / 255, blue: 105 / 255, alpha: 70 / 100)
        
        uiviewChooseAction = UIView(frame: CGRect(x: 0, y: 200, w: 290, h: 237))
        uiviewChooseAction.center.x = screenWidth / 2
        uiviewChooseAction.backgroundColor = .white
        uiviewChooseAction.layer.cornerRadius = 20
        
        lblChoose = UILabel(frame: CGRect(x: 0, y: 20, w: 290, h: 25))
//        lblChoose.center.x = screenWidth / 2
        lblChoose.textAlignment = .center
        lblChoose.text = "Choose an Action"
        lblChoose.textColor = UIColor._898989()
        lblChoose.font = UIFont(name: "AvenirNext-Medium", size: 18 * screenHeightFactor)
        uiviewChooseAction.addSubview(lblChoose)
        
        btnActFirst = UIButton(frame: CGRect(x: 41, y: 65, w: 208, h: 50))
        btnActSecond = UIButton(frame: CGRect(x: 41, y: 130, w: 208, h: 50))
        btnActThird = UIButton(frame: CGRect(x: 41, y: 195, w: 208, h: 50))
        btnActThird.isHidden = true
        
        var btnActions = [UIButton]()
        btnActions.append(btnActFirst)
        btnActions.append(btnActSecond)
        btnActions.append(btnActThird)
        
        for i in 0..<btnActions.count {
            btnActions[i].setTitleColor(UIColor._2499090(), for: .normal)
            btnActions[i].titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 18 * screenHeightFactor)
            btnActions[i].addTarget(self, action: #selector(sentActRequest(_:)), for: .touchUpInside)
            btnActions[i].layer.borderWidth = 2
            btnActions[i].layer.borderColor = UIColor._2499090().cgColor
            btnActions[i].layer.cornerRadius = 26 * screenWidthFactor
            uiviewChooseAction.addSubview(btnActions[i])
        }
        
        btnCancel = UIButton()
        btnCancel.setTitle("Cancel", for: .normal)
        btnCancel.setTitleColor(UIColor._2499090(), for: .normal)
        btnCancel.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size: 18 * screenHeightFactor)
        btnCancel.addTarget(self, action: #selector(actionCancel(_:)), for: .touchUpInside)
        uiviewChooseAction.addSubview(btnCancel)
        addConstraintsWithFormat("H:|-80-[v0]-80-|", options: [], views: btnCancel)
        addConstraintsWithFormat("V:[v0(25)]-\(15 * screenHeightFactor)-|", options: [], views: btnCancel)
        
        addSubview(uiviewChooseAction)
        loadSendActRequest()
    }
    
    fileprivate func loadSendActRequest() {
        uiviewMsgSent = UIView(frame: CGRect(x: 0, y: 200, w: 290, h: 161))
        uiviewMsgSent.backgroundColor = .white
        uiviewMsgSent.center.x = screenWidth / 2
        uiviewMsgSent.layer.cornerRadius = 20 * screenWidthFactor
        
        btnFriendSentBack = UIButton(frame: CGRect(x: 0, y: 0, w: 42, h: 40))
        btnFriendSentBack.tag = 0
        btnFriendSentBack.setImage(#imageLiteral(resourceName: "check_cross_red"), for: .normal)
        btnFriendSentBack.addTarget(self, action: #selector(actionFinish(_:)), for: .touchUpInside)
        
        lblMsgSent = UILabel(frame: CGRect(x: 58, y: 14, w: 190, h: 80))
        
        btnOK = UIButton(frame: CGRect(x: 43, y: 102, w: 208, h: 39))
        lblMsgSent.numberOfLines = 2
        lblMsgSent.textAlignment = .center
        lblMsgSent.font = UIFont(name: "AvenirNext-Medium", size: 18 * screenHeightFactor)
        lblMsgSent.textColor = UIColor._898989()
        
        btnOK.setTitle("OK", for: .normal)
        btnOK.setTitleColor(UIColor.white, for: .normal)
        btnOK.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 18 * screenHeightFactor)
        btnOK.backgroundColor = UIColor._2499090()
        btnOK.layer.cornerRadius = 19 * screenWidthFactor
        btnOK.addTarget(self, action: #selector(actionFinish(_:)), for: .touchUpInside)
        
        uiviewMsgSent.addSubview(lblMsgSent)
        uiviewMsgSent.addSubview(btnFriendSentBack)
        uiviewMsgSent.addSubview(btnOK)
        addSubview(uiviewMsgSent)
    }
    
    // PassStatusFromButtonToView
    func passFriendStatusFromButton(id: Int, status: FriendStatus) {
        userId = id
        isHidden = false
        uiviewChooseAction.isHidden = false
        animationShowSelf()
        uiviewMsgSent.isHidden = true
        switch status {
        case .defaultMode:
            btnActFirst.setTitle("Add Friend", for: .normal)
            btnActFirst.tag = ADD_FRIEND_ACT
            btnActSecond.setTitle("Follow", for: .normal)
            btnActSecond.tag = FOLLOW_ACT
            break
        case .pending:
            btnActFirst.setTitle("Withdraw", for: .normal)
            btnActFirst.tag = WITHDRAW_ACT
            btnActSecond.setTitle("Resend", for: .normal)
            btnActSecond.tag = RESEND_ACT
            break
        case .accepted:
            btnActFirst.setTitle("Remove Friend", for: .normal)
            btnActFirst.tag = REMOVE_FRIEND_ACT
            btnActSecond.setTitle("Block", for: .normal)
            btnActSecond.tag = BLOCK_ACT
            btnActThird.setTitle("Report", for: .normal)
            btnActThird.tag = REPORT_ACT
            break
        default:
            break
        }
        
        if status == .accepted {
            uiviewChooseAction.frame.size.height = 302 * screenHeightFactor
            btnActThird.isHidden = false
        } else {
            uiviewChooseAction.frame.size.height = 237 * screenHeightFactor
            btnActThird.isHidden = true
        }
    }
    // PassStatusFromButtonToView End
    
    // actions
    func sentActRequest(_ sender: UIButton!) {
        btnOK.tag = sender.tag
        uiviewChooseAction.isHidden = true
        uiviewMsgSent.isHidden = false
        animationActionView()
        switch sender.tag {
        case ADD_FRIEND_ACT:
            // send friend request
            faeContact.sendFriendRequest(friendId: String(self.userId)) {(status: Int, message: Any?) in
                if status / 100 == 2 {
                    self.lblMsgSent.text = "Friend Request Sent Successfully!"
                    self.delegate?.passFriendStatusFromView(status: .pending)
                } else if status == 400 {
                    self.lblMsgSent.text = "You've Already Sent Friend Request!"
                    self.delegate?.passFriendStatusFromView(status: .pending)
                } else {
                    self.lblMsgSent.text = "Friend Request Sent Fail!"
                    print("[FMUserInfo Friend Request Sent Fail] - \(status) \(message!)")
                }
            }
            break
        case FOLLOW_ACT:
            faeContact.followPerson(followeeId: String(self.userId)) {(status: Int, message: Any?) in
                if status / 100 == 2 {
                    self.lblMsgSent.text = "Follow Request Sent Successfully!"
                } else {
                    self.lblMsgSent.text = "Follow Request Sent Fail!"
                    print("[FMUserInfo Follow Request Sent Fail] - \(status) \(message!)")
                }
            }
            break
        case WITHDRAW_ACT:
            // withdraw friend request
            faeContact.getFriendRequestsSent() {(status: Int, message: Any?) in
                if status / 100 == 2 {
                    let json = JSON(message!)
                    for i in 0..<json.count {
                        print("json request_id \(json[i]["requested_user_id"].intValue)")
                        if json[i]["requested_user_id"].intValue == self.userId {
                            self.requestId = json[i]["friend_request_id"].intValue
                            break
                        }
                    }
                    self.faeContact.withdrawFriendRequest(requestId: String(self.requestId)) {(status: Int, message: Any?) in
                        if status / 100 == 2 {
                            self.lblMsgSent.text = "Request Withdraw Successfully!"
                            self.delegate?.passFriendStatusFromView(status: .defaultMode)
                        } else if status == 404 {
                            self.lblMsgSent.text = "You haven't Sent Friend Request!"
                            self.delegate?.passFriendStatusFromView(status: .defaultMode)
                        } else {
                            self.lblMsgSent.text = "Request Withdraw Fail!"
                            print("[FMUserInfo Request Withdraw Fail] - \(status) \(message!)")
                        }
                    }
                } else {
                    self.lblMsgSent.text = "Internet Error"
                    print("[FMUserInfo getFriendRequestsSent Fail] - \(status) \(message!)")
                }
            }
            break
        case RESEND_ACT:
            faeContact.sendFriendRequest(friendId: String(userId), boolResend: "true") {(status: Int, message: Any?) in
                if status / 100 == 2 {
                    self.lblMsgSent.text = "Request Resent Successfully!"
                } else if status == 400 {
                    self.lblMsgSent.text = "The User Has Already Sent You a Friend Request!"
                } else {
                    self.lblMsgSent.text = "Request Resent Fail!"
                    print("[FMUserInfo Friend Request Resent Fail] - \(status) \(message!)")
                }
            }
            break
        case REMOVE_FRIEND_ACT:
            faeContact.deleteFriend(userId: String(userId)) {(status: Int, message: Any?) in
                if status / 100 == 2 {
                    self.lblMsgSent.text = "Remove Friend Successfully!"
                    self.delegate?.passFriendStatusFromView(status: .defaultMode)
                } else {
                    self.lblMsgSent.text = "Remove Friend Fail!"
                    print("[FMUserInfo Delete Friend Fail] - \(status) \(message!)")
                }
            }
            break
        case BLOCK_ACT:
            faeContact.blockPerson(userId: String(userId)) {(status: Int, message: Any?) in
                if status / 100 == 2 {
                    self.lblMsgSent.text = "Block Friend Successfully!"
                    self.delegate?.passFriendStatusFromView(status: .blocked)
                } else {
                    self.lblMsgSent.text = "Block Friend Fail!"
                    print("[FMUserInfo Friend Block Fail] - \(status) \(message!)")
                }
            }
            break
        case REPORT_ACT:
            break
        default:
            break
        }
    }
    
    func actionCancel(_ sender: UIButton) {
        animationHideSelf()
    }
    
    func actionFinish(_ sender: UIButton!) {
        isHidden = true
        switch sender.tag {
        case 0:
            print("action dismiss")
        case ADD_FRIEND_ACT:
            print("request finish")
        case FOLLOW_ACT:
            print("follow finish")
        case WITHDRAW_ACT:
            print("withdraw finish")
        case RESEND_ACT:
            print("resent finish")
        default:break
        }
    }
    // actions end
    
    // animations
    func animationActionView() {
        uiviewChooseAction.alpha = 0
        uiviewMsgSent.alpha = 0
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut, animations: {
            self.uiviewMsgSent.alpha = 1
        }, completion: nil)
    }
    
    func animationShowSelf() {
        alpha = 0
        uiviewChooseAction.alpha = 0
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut, animations: {
            self.alpha = 1
            self.uiviewChooseAction.alpha = 1
        }, completion: nil)
    }
    
    func animationHideSelf() {
        alpha = 1
        uiviewChooseAction.alpha = 1
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut, animations: {
            self.alpha = 0
            self.uiviewChooseAction.alpha = 0
        }, completion: { _ in
            self.isHidden = true
        })
    }
    // animations end
}
