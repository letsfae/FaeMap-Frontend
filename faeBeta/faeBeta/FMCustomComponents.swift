//
//  FMCustomComponents.swift
//  faeBeta
//
//  Created by Yue Shen on 8/1/17.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit

protocol NameCardDelegate: class {
    func openFaeUsrInfo()
}

class FMNameCardView: UIView {
    
    weak var delegate: NameCardDelegate?
    
    var userId: Int = 0 {
        didSet {
            if userId > 0 { updateNameCard(withUserId: userId) }
        }
    }
    
    var boolOpened = false
    
    let nameCardAnchor = CGPoint(x: 0.5, y: 1.0)
    let initialFrame = CGRect.zero
    let secondaryFrame = CGRect(x: 160, y: 350, w: 0, h: 0)
    var imgAvatarShadow: UIImageView!
    var btnChat: UIButton!
    var btnCloseOptions: UIButton!
    var btnProfile: UIButton!
    var btnFav: UIButton!
    var btnOptions: UIButton!
    var btnWaveSelf: UIButton!
    var btnCloseCard: UIButton!
    var btnEditNameCard: UIButton!
    var imgAvatar: UIImageView!
    var imgBackShadow: UIImageView!
    var imgCover: UIImageView!
    var imgMiddleLine: UIImageView!
    var lblNickName: UILabel!
    var lblShortIntro: UILabel!
    var uiviewPrivacy: FaeGenderView!
    var imgMoreOptions: UIImageView!
    var btnReport: UIButton!
    var btnShare: UIButton!
    
    override init(frame: CGRect = CGRect.zero) {
        super.init(frame: frame)
        center.x = screenWidth / 2
        center.y = 451 * screenWidthFactor
        self.frame.size.width = 320 * screenWidthFactor
        loadContent()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func showNameCardOptions(_ sender: UIButton) {
        btnCloseOptions.alpha = 1
        self.tag = 1
        var thisIsMe = false
        if sender.tag == Int(Key.shared.user_id) {
            print("[showNameCardOptions] this is me")
            thisIsMe = true
        }
        let subviewXBefore: CGFloat = 243 - 47
        let subviewYBefore: CGFloat = 151 - 129
        let subviewXAfter: CGFloat = 79 - 47
        let subviewYAfter: CGFloat = subviewYBefore
        let subviewWidthAfter: CGFloat = 164
        let subviewHeightAfter: CGFloat = 110
        let firstButtonX: CGFloat = 103 - 47
        let secondButtonX: CGFloat = 172 - 47
        let buttonY: CGFloat = 191 - 129
        let buttonWidth: CGFloat = 50
        let buttonHeight: CGFloat = 51
        
        btnOptions.setImage(#imageLiteral(resourceName: "moreOptionMapNameCardReal"), for: .normal)
        
        imgMoreOptions = UIImageView(frame: CGRect(x: subviewXBefore, y: subviewYBefore, w: 0, h: 0))
        imgMoreOptions.image = #imageLiteral(resourceName: "nameCardOptions")
        btnCloseOptions.addSubview(imgMoreOptions)
        
        btnShare = UIButton(frame: CGRect(x: subviewXBefore, y: subviewYBefore, w: 0, h: 0))
        btnShare.setImage(#imageLiteral(resourceName: "pinDetailShare"), for: .normal)
        btnCloseOptions.addSubview(btnShare)
        btnShare.clipsToBounds = true
        btnShare.alpha = 0.0
        //        shareNameCard.addTarget(self, action: #selector(CommentPinDetailViewController.actionShareComment(_:)), for: .TouchUpInside)
        
        btnEditNameCard = UIButton(frame: CGRect(x: subviewXBefore, y: subviewYBefore, w: 0, h: 0))
        btnEditNameCard.setImage(#imageLiteral(resourceName: "pinDetailEdit"), for: .normal)
        btnCloseOptions.addSubview(btnEditNameCard)
        btnEditNameCard.clipsToBounds = true
        btnEditNameCard.alpha = 0.0
        //        editNameCard.addTarget(self, action: #selector(CommentPinDetailViewController.actionEditComment(_:)), for: .touchUpInside)
        
        btnReport = UIButton(frame: CGRect(x: subviewXBefore, y: subviewYBefore, w: 0, h: 0))
        btnReport.setImage(#imageLiteral(resourceName: "pinDetailReport"), for: .normal)
        btnCloseOptions.addSubview(btnReport)
        btnReport.clipsToBounds = true
        btnReport.alpha = 0
//        btnReport.addTarget(self, action: #selector(actionReportThisPin(_:)), for: .touchUpInside)
        
        UIView.animate(withDuration: 0.3, animations: ({
            self.imgMoreOptions.frame = CGRect(x: subviewXAfter, y: subviewYAfter, w: subviewWidthAfter, h: subviewHeightAfter)
            self.btnShare.frame = CGRect(x: firstButtonX, y: buttonY, w: buttonWidth, h: buttonHeight)
            self.btnShare.alpha = 1.0
            if thisIsMe {
                self.btnEditNameCard.alpha = 1.0
                self.btnEditNameCard.frame = CGRect(x: secondButtonX, y: buttonY, w: buttonWidth, h: buttonHeight)
            } else {
                self.btnReport.alpha = 1.0
                self.btnReport.frame = CGRect(x: secondButtonX, y: buttonY, w: buttonWidth, h: buttonHeight)
            }
        }))
    }
    
    func updateNameCard(withUserId: Int) {
        btnChat.tag = withUserId
        btnOptions.tag = withUserId
        btnWaveSelf.isHidden = withUserId != Key.shared.user_id
        btnFav.isHidden = withUserId == Key.shared.user_id
        General.shared.avatar(userid: withUserId) { (avatarImage) in
            self.imgAvatar.image = avatarImage
        }
        uiviewPrivacy.loadGenderAge(id: withUserId) { (nickName, _, shortIntro) in
            self.lblNickName.text = nickName
            self.lblShortIntro.text = shortIntro
        }
    }
    
    func show() {
        boolOpened = true
        UIView.animate(withDuration: 0.8, delay: 0.3, usingSpringWithDamping: 0.6, initialSpringVelocity: 0, options: .curveLinear, animations: {
            self.frame = CGRect(x: 47, y: 129, w: 320, h: 350)
            self.imgBackShadow.frame = CGRect(x: 0, y: 0, w: 320, h: 350)
            self.imgCover.frame = CGRect(x: 26, y: 29, w: 268, h: 125)
            self.imgAvatarShadow.frame = CGRect(x: 116, y: 104, w: 88, h: 88)
            self.imgAvatar.frame = CGRect(x: 123, y: 111, w: 74, h: 74)
            self.btnChat.frame = CGRect(x: 146.5, y: 264, w: 27, h: 27)
            self.lblShortIntro.frame = CGRect(x: 75, y: 220, w: 171, h: 18)
            self.imgMiddleLine.frame = CGRect(x: 26, y: 251.5, w: 268, h: 1)
            self.btnFav.frame = CGRect(x: 69, y: 264, w: 27, h: 27)
            self.btnWaveSelf.frame = CGRect(x: 69, y: 264, w: 27, h: 27)
            self.btnOptions.frame = CGRect(x: 247, y: 163, w: 32, h: 18)
            self.btnProfile.frame = CGRect(x: 224, y: 264, w: 27, h: 27)
            self.uiviewPrivacy.frame = CGRect(x: 41, y: 163, w: 46, h: 18)
        }, completion: { _ in
            self.lblNickName.frame = CGRect(x: 67, y: 194, w: 186, h: 25)
            self.lblNickName.alpha = 1
        })
    }
    
    func hide() {
        guard boolOpened else { return }
        boolOpened = false
        UIView.animate(withDuration: 0.3, animations: {
            self.imgBackShadow.frame = self.secondaryFrame
            self.imgCover.frame = self.secondaryFrame
            self.imgAvatarShadow.frame = self.secondaryFrame
            self.imgAvatar.frame = self.secondaryFrame
            self.btnChat.frame = self.secondaryFrame
            self.lblNickName.frame = self.secondaryFrame
            self.lblNickName.alpha = 0
            self.lblShortIntro.frame = self.secondaryFrame
            self.imgMiddleLine.frame = self.secondaryFrame
            self.btnFav.frame = self.secondaryFrame
            self.btnWaveSelf.frame = self.secondaryFrame
            self.btnOptions.frame = self.secondaryFrame
            self.btnProfile.frame = self.secondaryFrame
            self.uiviewPrivacy.frame = self.secondaryFrame
        }, completion: { _ in
            self.imgBackShadow.frame = self.initialFrame
            self.imgCover.frame = self.initialFrame
            self.imgAvatarShadow.frame = self.initialFrame
            self.imgAvatar.frame = self.initialFrame
            self.btnChat.frame = self.initialFrame
            self.lblNickName.frame = CGRect(x: 114, y: 451, w: 0, h: 0)
            self.lblNickName.alpha = 0
            self.lblShortIntro.frame = self.initialFrame
            self.imgMiddleLine.frame = self.initialFrame
            self.btnFav.frame = self.initialFrame
            self.btnWaveSelf.frame = self.initialFrame
            self.btnOptions.frame = self.initialFrame
            self.btnProfile.frame = self.initialFrame
            self.uiviewPrivacy.frame = self.initialFrame
            self.frame = CGRect.zero
            self.center.x = screenWidth / 2
            self.center.y = 451 * screenWidthFactor
            self.frame.size.width = 320 * screenWidthFactor
            self.imgAvatar.image = #imageLiteral(resourceName: "defaultMen")
            self.lblNickName.text = ""
            self.lblShortIntro.text = ""
        })
    }
    
    private func loadContent() {
        layer.zPosition = 900
        
        imgBackShadow = UIImageView(frame: initialFrame)
        imgBackShadow.layer.anchorPoint = nameCardAnchor
        imgBackShadow.image = #imageLiteral(resourceName: "namecardsub_shadow")
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
//        btnChat.addTarget(self, action: #selector(btnChatAction(_:)), for: .touchUpInside)
        
        lblNickName = UILabel(frame: CGRect(x: 114, y: 451, w: 0, h: 0))
        lblNickName.layer.anchorPoint = nameCardAnchor
        lblNickName.text = nil
        lblNickName.textAlignment = .center
        lblNickName.font = UIFont(name: "AvenirNext-DemiBold", size: 18 * screenHeightFactor)
        lblNickName.textColor = UIColor(red: 107 / 255, green: 105 / 255, blue: 105 / 255, alpha: 1.0)
        lblNickName.alpha = 0
        addSubview(lblNickName)
        
        lblShortIntro = UILabel(frame: initialFrame)
        lblShortIntro.layer.anchorPoint = nameCardAnchor
        lblShortIntro.text = ""
        lblShortIntro.textAlignment = .center
        lblShortIntro.font = UIFont(name: "AvenirNext-Medium", size: 13 * screenHeightFactor)
        lblShortIntro.textColor = UIColor(red: 155 / 255, green: 155 / 255, blue: 155 / 255, alpha: 1.0)
        addSubview(lblShortIntro)
        
        imgMiddleLine = UIImageView(frame: initialFrame)
        imgMiddleLine.layer.anchorPoint = nameCardAnchor
        imgMiddleLine.backgroundColor = UIColor(red: 206 / 255, green: 203 / 255, blue: 203 / 255, alpha: 1.0)
        addSubview(imgMiddleLine)
        
        btnFav = UIButton(frame: initialFrame)
        btnFav.layer.anchorPoint = nameCardAnchor
        btnFav.setImage(UIImage(named: "Favorite"), for: .normal)
        addSubview(btnFav)
        
        btnWaveSelf = UIButton(frame: initialFrame)
        btnWaveSelf.layer.anchorPoint = nameCardAnchor
        btnWaveSelf.layer.zPosition = 910
        btnWaveSelf.setImage(#imageLiteral(resourceName: "showSelfWaveToOthers"), for: .normal)
        addSubview(btnWaveSelf)
        btnWaveSelf.isHidden = true
        
        btnOptions = UIButton(frame: initialFrame)
        btnOptions.layer.anchorPoint = nameCardAnchor
        btnOptions.setImage(#imageLiteral(resourceName: "moreOptionMapNameCardFade"), for: .normal)
        btnOptions.layer.zPosition = 910
        addSubview(btnOptions)
        btnOptions.addTarget(self, action: #selector(showNameCardOptions(_:)), for: .touchUpInside)
        
        btnProfile = UIButton(frame: initialFrame)
        btnProfile.layer.anchorPoint = nameCardAnchor
        btnProfile.setImage(#imageLiteral(resourceName: "Emoji"), for: .normal)
        btnProfile.addTarget(self, action: #selector(openFaeUsrInfo), for: .touchUpInside)
        btnProfile.layer.zPosition = 910
        addSubview(btnProfile)
        
        uiviewPrivacy = FaeGenderView(frame: initialFrame)
        uiviewPrivacy.layer.anchorPoint = nameCardAnchor
        uiviewPrivacy.layer.zPosition = 912
        addSubview(uiviewPrivacy)
        
        btnCloseOptions = UIButton(frame: CGRect(x: 73, y: 158, w: 268, h: 293))
        btnCloseOptions.layer.zPosition = 920
        addSubview(btnCloseOptions)
        btnCloseOptions.alpha = 0
//        btnCloseOptions.addTarget(self, action: #selector(hideNameCard(_:)), for: .touchUpInside)
    
        imgAvatar.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(openFaeUsrInfo))
        imgAvatar.addGestureRecognizer(tapGesture)
        
    }
    
    func openFaeUsrInfo() {
        delegate?.openFaeUsrInfo()
    }
    
}

class FMCompass: UIButton {
    
    var mapView: MKMapView!
    
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
    }
    
    func rotateCompass() {
        UIView.animate(withDuration: 0.5, animations: {
            self.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi * -self.mapView.camera.heading) / 180.0)
        })
    }
}

class FMLocateSelf: UIButton {
    
    var mapView: MKMapView!
    
    override init(frame: CGRect = CGRect.zero) {
        super.init(frame: CGRect(x: 333 * screenWidthFactor, y: 582 * screenWidthFactor, width: 59, height: 59))
        loadContent()
        let tapGesture = UITapGestureRecognizer()
        tapGesture.numberOfTapsRequired = 2
        tapGesture.addTarget(self, action: #selector(handleTap))
        addGestureRecognizer(tapGesture)
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
    }
    
    func handleTap() {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(LocManager.shared.curtLoc.coordinate, 3000, 3000)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
}
