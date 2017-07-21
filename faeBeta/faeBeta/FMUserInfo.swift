//
//  ViewController.swift
//  FaeAccountSetting
//
//  Created by Sophie Wang on 6/9/17.
//  Copyright © 2017 Zixin Wang. All rights reserved.
//

import UIKit
import SwiftyJSON

class FMUserInfo: UIViewController {
    
    var userId: Int = -1
    var imgHeadBgd: UIImageView!
    var imgAvatar: FaeAvatarView!
    var btnMoreOptions: UIButton!
    var lblNickName: UILabel!
    var lblUserName: UILabel!
    var lblShortIntro: UILabel!
    var uiviewSplitView: UIView!
    var uiviewTblCtrlBtnSub: UIView!
    var uiviewGrayMidLine: UIView!
    var uiviewRedLine: UIView!
    var uiviewGrayTopLine: UIView!
    var lblGeneral: UILabel!
    var lblActivities: UILabel!
    var lblAlbums: UILabel!
    var btnGeneral: UIButton!
    var btnActivities: UIButton!
    var btnAlbums: UIButton!
    var uiviewGrayBtmLine: UIView!
    var btnBack: UIButton!
    var btnBelowFirst: UIButton!
    var btnBelowSecond: UIButton!
    var uiviewBlurMainScreen: UIView!
    var uiviewAction: UIView!
    var lblChoose: UILabel!
    var uiviewAddFriend: UIView!
    var uiviewFollow: UIView!
    var btnActFirst: UIButton!
    var btnActSecond: UIButton!
    var lblAddFriend: UILabel!
    var lblFollow: UILabel!
    var btnCancel: UIButton!
    var uiviewFriendSent: UIView!
    var btnFriendSentBack: UIButton!
    var btnFriendOK: UIButton!
    var lblFriendSent: UILabel!
    var lblContent: UILabel!
    var uiviewCardPrivacy: FaeGenderView!
    let faeContact = FaeContact()
    
    enum FriendStatus: String {
        case defaultMode
        case accepted
        case blocked
        case pending
    }
    
    var statusMode: FriendStatus = .defaultMode
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadMainPage()
        loadSlideBtm()
        loadBtmBar()
        print(statusMode)
    }
    
    func getStatusMode() {
        faeContact.getFriends() {(status: Int, message: Any?) in
            if status / 2 == 100 {
                let json = JSON(message!)
                var friendsList = [Int]()
                
                if json.count != 0 {
                    for i in 0...json.count-1 {
                        friendsList.append(json[i]["friend_id"].intValue)
                    }
                }
                
                print("friends \(friendsList)")
                if friendsList.contains(self.userId) {
                    self.statusMode = .accepted
                }
                
                self.switchBtmSecondBtn()
            } else {
                print("[FMUserInfo get friends list fail] - \(status) \(message!)")
            }
        }
    }
    
    func loadMainPage() {
        self.view.backgroundColor = .white
        imgHeadBgd = UIImageView(frame: CGRectWithFactor(x: 0, y: 0, width: screenWidth / screenWidthFactor, height: 188))
        imgHeadBgd.image = #imageLiteral(resourceName: "imgBackground")
        view.addSubview(imgHeadBgd)
        
        imgAvatar = FaeAvatarView(frame: CGRectWithFactor(x: 0, y: 136, width: 95, height: 95))
        imgAvatar.center.x = screenWidth / 2
        imgAvatar.layer.cornerRadius = 41
        imgAvatar.layer.shadowColor = UIColor.faeAppShadowGrayColor().cgColor
        imgAvatar.layer.shadowOpacity = 1
        imgAvatar.layer.shadowRadius = 10
        imgAvatar.layer.shadowOffset = CGSize(width: 0, height: 0)
        imgAvatar.layer.masksToBounds = false
        imgAvatar.clipsToBounds = true
        
        imgAvatar.userID = self.userId
        imgAvatar.loadAvatar(id: self.userId)
        imgAvatar.layer.borderWidth = 6
        imgAvatar.layer.borderColor = UIColor.white.cgColor
        view.addSubview(imgAvatar)
        
        btnMoreOptions = UIButton()
        btnMoreOptions.setImage(#imageLiteral(resourceName: "pinDetailMore"), for: .normal)
        view.addSubview(btnMoreOptions)
        addConstraintsToView(parent: view, child: btnMoreOptions, left: false, gapH: 15, width: 27, top: true, gapV: 205, height: 7)
        btnMoreOptions.addTarget(self, action: #selector(showPinMoreButtonDetails(_:)), for: .touchUpInside)
        
        lblNickName = UILabel(frame: CGRectWithFactor(x: 0, y: 237, width: 350, height: 27))
        lblNickName.center.x = screenWidth / 2
        lblNickName.font = UIFont(name: "AvenirNext-DemiBold", size: 20 * screenHeightFactor)
        lblNickName.adjustsFontSizeToFitWidth = true
        lblNickName.textAlignment = .center
        lblNickName.textColor = UIColor.faeAppInputTextGrayColor()
        
        lblUserName = UILabel(frame: CGRectWithFactor(x: 0, y: 265, width: 140, height: 18))
        lblUserName.center.x = screenWidth / 2
        lblUserName.font = UIFont(name: "AvenirNext-Medium", size: 13 * screenHeightFactor)
        lblUserName.adjustsFontSizeToFitWidth = true
        lblUserName.textAlignment = .center
        lblUserName.textColor = UIColor.faeAppInputPlaceholderGrayColor()
        
        lblShortIntro = UILabel(frame: CGRectWithFactor(x: 0, y: 289, width: 343, height: 18))
        lblShortIntro.center.x = screenWidth / 2
        lblShortIntro.font = UIFont(name: "AvenirNext-Medium", size: 13 * screenHeightFactor)
        lblShortIntro.textAlignment = .center
        lblShortIntro.textColor = UIColor.faeAppInactiveBtnGrayColor()
        
        view.addSubview(lblNickName)
        view.addSubview(lblUserName)
        view.addSubview(lblShortIntro)
        
        uiviewCardPrivacy = FaeGenderView(frame: CGRect(x: 15, y: 200, w: 46, h: 18))
        view.addSubview(uiviewCardPrivacy)
        
        uiviewCardPrivacy.loadGenderAge(id: self.userId) { (nickName, userName, shortIntro) in
            self.lblNickName.text = nickName
            self.lblUserName.text = userName
            self.lblShortIntro.text = shortIntro
        }
    }
    
    func loadBtmBar() {
        btnBack = UIButton()
        view.addSubview(btnBack)
        btnBack.setImage(#imageLiteral(resourceName: "navigationBack"), for: .normal)
        addConstraintsToView(parent: view, child: btnBack, left: true, gapH: 0, width: 48, top: false, gapV: 0, height: 48)
        btnBack.addTarget(self, action: #selector(animationBack(_:)), for: .touchUpInside)
        
        btnBelowFirst = UIButton()
        view.addSubview(btnBelowFirst)
        btnBelowFirst.setImage(#imageLiteral(resourceName: "btnChat"), for: .normal)
        addConstraintsToView(parent: view, child: btnBelowFirst, left: true, gapH: 133, width: 48, top: false, gapV: 0, height: 48)
        btnBelowFirst.addTarget(self, action: #selector(belowEnterChat(_:)), for: .touchUpInside)
        
        getStatusMode()
    }
    
    func switchBtmSecondBtn() {
        //        removeSwitchBtmSecondBtn()
        btnBelowSecond = UIButton()
        view.addSubview(btnBelowSecond)
        addConstraintsToView(parent: view, child: btnBelowSecond, left: true, gapH: 228, width: 48, top: false, gapV: 0, height: 48)
        switch statusMode {
        case .defaultMode:
            btnBelowSecond.setImage(#imageLiteral(resourceName: "btnAddFriend"), for: .normal)
            btnBelowSecond.addTarget(self, action: #selector(belowAddFriend(_:)), for: .touchUpInside)
            print("in default")
            break
        case .accepted:
            btnBelowSecond.setImage(#imageLiteral(resourceName: "gearIcon"), for: .normal)
            btnBelowSecond.addTarget(self, action: #selector(belowAddFriend(_:)), for: .touchUpInside)
            print("accepted")
            break
        case .blocked:
            //            btnBelowFirst.removeFromSuperview()
            btnBelowFirst.isHidden = true
            btnBelowSecond.isHidden = true
            lblContent.text = "Content Unavailable"
            break
        case .pending:
            btnBelowSecond.setImage(#imageLiteral(resourceName: "questionIcon"), for: .normal)
            btnBelowSecond.addTarget(self, action: #selector(belowAddFriend(_:)), for: .touchUpInside)
            break
        }
        
    }
    func removeSlideBtm() {
        removeView(viewArray: [uiviewTblCtrlBtnSub, uiviewGrayTopLine, uiviewGrayMidLine, uiviewRedLine, lblGeneral, btnGeneral, lblActivities, btnActivities, lblAlbums, btnAlbums, lblContent, uiviewTblCtrlBtnSub, uiviewGrayBtmLine])
    }
    func loadSlideBtm() {
        removeSlideBtm()
        uiviewTblCtrlBtnSub = UIView(frame: CGRectWithFactor(x: 0, y: 320, width: screenWidth / screenWidthFactor, height: 416))
        uiviewTblCtrlBtnSub.backgroundColor = UIColor.white
        view.addSubview(uiviewTblCtrlBtnSub)
        
        uiviewGrayTopLine = UIView(frame: CGRectWithFactor(x: 0, y: 0, width: screenWidth / screenWidthFactor, height: 5))
        uiviewGrayTopLine.layer.backgroundColor = UIColor(red: 241 / 255, green: 241 / 255, blue: 241 / 255, alpha: 100).cgColor
        uiviewTblCtrlBtnSub.addSubview(uiviewGrayTopLine)
        
        uiviewGrayMidLine = UIView(frame: CGRectWithFactor(x: 0, y: 53, width: screenWidth / screenWidthFactor, height: 1))
        uiviewGrayMidLine.layer.backgroundColor = UIColor(red: 200 / 255, green: 199 / 255, blue: 204 / 255, alpha: 1.0).cgColor
        uiviewTblCtrlBtnSub.addSubview(uiviewGrayMidLine)
        
        let widthOfThreeButtons = screenWidth / (3 * screenWidthFactor)
        
        uiviewRedLine = UIView(frame: CGRectWithFactor(x: 0, y: 52, width: widthOfThreeButtons, height: 2))
        uiviewRedLine.layer.borderWidth = 2
        uiviewRedLine.layer.borderColor = UIColor(red: 249 / 255, green: 90 / 255, blue: 90 / 255, alpha: 1.0).cgColor
        uiviewTblCtrlBtnSub.addSubview(uiviewRedLine)
        
        lblGeneral = UILabel()
        lblGeneral.text = "General"
        lblGeneral.textColor = UIColor.faeAppInputTextGrayColor()
        lblGeneral.textAlignment = .center
        lblGeneral.font = UIFont(name: "AvenirNext-Medium", size: 16 * screenHeightFactor)
        uiviewTblCtrlBtnSub.addSubview(lblGeneral)
        
        btnGeneral = UIButton()
        btnGeneral.addTarget(self, action: #selector(animationRedSlidingLine(_:)), for: .touchUpInside)
        uiviewTblCtrlBtnSub.addSubview(btnGeneral)
        btnGeneral.tag = 1
        
        lblActivities = UILabel()
        lblActivities.text = "Activities"
        lblActivities.textColor = UIColor.faeAppInputTextGrayColor()
        lblActivities.textAlignment = .center
        lblActivities.font = UIFont(name: "AvenirNext-Medium", size: 16 * screenHeightFactor)
        uiviewTblCtrlBtnSub.addSubview(lblActivities)
        
        btnActivities = UIButton()
        btnActivities.addTarget(self, action: #selector(animationRedSlidingLine(_:)), for: .touchUpInside)
        uiviewTblCtrlBtnSub.addSubview(btnActivities)
        btnActivities.tag = 3
        
        lblAlbums = UILabel()
        lblAlbums.text = "Albums"
        lblAlbums.textColor = UIColor.faeAppInputTextGrayColor()
        lblAlbums.textAlignment = .center
        lblAlbums.font = UIFont(name: "AvenirNext-Medium", size: 16 * screenHeightFactor)
        uiviewTblCtrlBtnSub.addSubview(lblAlbums)
        
        btnAlbums = UIButton()
        btnAlbums.addTarget(self, action: #selector(animationRedSlidingLine(_:)), for: .touchUpInside)
        uiviewTblCtrlBtnSub.addSubview(btnAlbums)
        btnAlbums.tag = 5
        
        lblContent = UILabel(frame: CGRectWithFactor(x: 0, y: 98, width: 221, height: 50))
        lblContent.center.x = screenWidth / 2
        lblContent.text = ""
        lblContent.font = UIFont(name: "AvenirNext-Medium", size: 18 * screenHeightFactor)
        lblContent.textColor = UIColor(red: 115 / 255, green: 115 / 255, blue: 115 / 255, alpha: 1)
        lblContent.textAlignment = .center
        uiviewTblCtrlBtnSub.addSubview(lblContent)
        
        let threeButtons = [lblGeneral: 0, lblActivities: 1, lblAlbums: 2, btnGeneral: 0, btnActivities: 1, btnAlbums: 2] as [AnyHashable: CGFloat]
        for btn in threeButtons {
            addConstraintsToView(parent: uiviewTblCtrlBtnSub, child: btn.key as! UIView, left: true, gapH: widthOfThreeButtons * btn.value, width: widthOfThreeButtons, top: true, gapV: 0, height: 60)
        }
        
        view.addSubview(uiviewTblCtrlBtnSub)
        
        uiviewGrayBtmLine = UIView(frame: CGRectWithFactor(x: 0, y: 687, width: screenWidth / screenWidthFactor, height: 1))
        uiviewGrayBtmLine.layer.backgroundColor = UIColor(red: 200 / 255, green: 199 / 255, blue: 204 / 255, alpha: 1.0).cgColor
        view.addSubview(uiviewGrayBtmLine)
    }
    
    func showPinMoreButtonDetails(_ sender: UIButton!) {
        print("in more details")
    }
    func removeBlurViewEle() {
        removeView(viewArray: [uiviewBlurMainScreen, uiviewAction, lblChoose, uiviewAddFriend, uiviewFollow, btnActFirst, btnActSecond, btnCancel])
    }
    func loadBlurView() {
        removeBlurViewEle()
        
        uiviewBlurMainScreen = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
        uiviewBlurMainScreen.backgroundColor = UIColor(red: 107 / 255, green: 105 / 255, blue: 105 / 255, alpha: 70 / 100)
        BlurViewAnimation()
        
        uiviewAction = UIView()
        uiviewAction.backgroundColor = UIColor.white
        uiviewAction.layer.cornerRadius = 20
        
        lblChoose = UILabel(frame: CGRectWithFactor(x: 0, y: 20, width: 290, height: 25))
        lblChoose.textAlignment = .center
        lblChoose.text = "Choose an Action"
        lblChoose.textColor = UIColor.faeAppInputTextGrayColor()
        lblChoose.font = UIFont(name: "AvenirNext-Medium", size: 18 * screenHeightFactor)
        
        uiviewAddFriend = UIView(frame: CGRectWithFactor(x: 40, y: 66, width: 208, height: 50))
        uiviewAddFriend.layer.borderWidth = 2
        uiviewAddFriend.layer.borderColor = UIColor.faeAppRedColor().cgColor
        uiviewAddFriend.layer.cornerRadius = 23
        
        uiviewFollow = UIView(frame: CGRectWithFactor(x: 40, y: 131, width: 208, height: 50))
        uiviewFollow.layer.borderWidth = 2
        uiviewFollow.layer.borderColor = UIColor.faeAppRedColor().cgColor
        uiviewFollow.layer.cornerRadius = 23
        
        btnActFirst = UIButton(frame: CGRectWithFactor(x: 40, y: 66, width: 208, height: 50))
        
        switch statusMode {
        case .defaultMode:
            btnActFirst.setTitle("Add Friend", for: .normal)
            btnActFirst.tag = 1
            break
        case .pending:
            btnActFirst.setTitle("Withdraw", for: .normal)
            btnActFirst.tag = 2
            break
        default:
            break
        }
        
        btnActFirst.setTitleColor(UIColor.faeAppRedColor(), for: .normal)
        btnActFirst.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 18 * screenHeightFactor)
        btnActFirst.addTarget(self, action: #selector(sentActFirstRequest(_:)), for: .touchUpInside)
        
        btnActSecond = UIButton(frame: CGRectWithFactor(x: 40, y: 131, width: 208, height: 50))
        
        switch statusMode {
        case .defaultMode:
            btnActSecond.setTitle("Follow", for: .normal)
            btnActSecond.tag = 1
            break
        case .pending:
            btnActSecond.setTitle("Resend", for: .normal)
            btnActSecond.tag = 2
            break
        default:
            break
        }
        
        btnActSecond.setTitleColor(UIColor.faeAppRedColor(), for: .normal)
        btnActSecond.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 18 * screenHeightFactor)
        btnActSecond.addTarget(self, action: #selector(sentActSecondRequest(_:)), for: .touchUpInside)
        
        btnCancel = UIButton(frame: CGRectWithFactor(x: 40, y: 185, width: 208, height: 50))
        btnCancel.setTitle("Cancel", for: .normal)
        btnCancel.setTitleColor(UIColor.faeAppRedColor(), for: .normal)
        btnCancel.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size: 18 * screenHeightFactor)
        btnCancel.addTarget(self, action: #selector(actionCancel(_:)), for: .touchUpInside)
        
        uiviewAction.addSubview(lblChoose)
        uiviewAction.addSubview(uiviewAddFriend)
        uiviewAction.addSubview(uiviewFollow)
        uiviewAction.addSubview(btnActFirst)
        uiviewAction.addSubview(btnActSecond)
        uiviewAction.addSubview(btnCancel)
        
        uiviewBlurMainScreen.addSubview(uiviewAction)
        ActViewAnimation()
        addConstraintsToView(parent: uiviewBlurMainScreen, child: uiviewAction, left: true, gapH: (screenWidth / screenWidthFactor - 290) / 2, width: 290, top: true, gapV: 200, height: 237)
        
        view.addSubview(uiviewBlurMainScreen)
    }
    func BlurViewAnimation() {
        uiviewBlurMainScreen.alpha = 0
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
            self.uiviewBlurMainScreen.alpha = 7
        }, completion: nil)
    }
    func ActViewAnimation() {
        uiviewAction.alpha = 0
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
            self.uiviewAction.alpha = 1
        }, completion: nil)
    }
    func animationBack(_ sender: UIButton!) {
        navigationController?.popViewController(animated: true)
    }
    
    func belowEnterChat(_ sender: UIButton!) {
        print("enter Chat")
    }
    
    func belowAddFriend(_ sender: UIButton!) {
        print("add Friend")
        loadBlurView()
    }
    
    func sentActFirstRequest(_ sender: UIButton!) {
        if sender.tag == 1 {   // "Add Friend" button pressed
            loadSendActRequest(type: 1)
        } else {     // "Withdraw" button pressed
            loadSendActRequest(type: 1)
        }
    }
    
    func sentActSecondRequest(_ sender: UIButton!) {
        if sender.tag == 1 {
            print("send follow request")
            loadSendActRequest(type: 2)
        } else {
            print("resend request")
            loadSendActRequest(type: 2)
        }
    }
    func removeSendActSecondRequest() {
        removeView(viewArray: [lblFriendSent, btnFriendSentBack, btnFriendOK, uiviewFriendSent])
    }
    func actionCancel(_ sender: UIButton!) {
        print("action cancel")
        animationBlurScreenCancel()
        print("after finish canceling")
    }
    func animationBlurScreenCancel() {
        uiviewBlurMainScreen.alpha = 7
        uiviewAction.alpha = 1
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
            self.uiviewBlurMainScreen.alpha = 0
            self.uiviewAction.alpha = 0
        }, completion: { (done: Bool) in
            if done {
                self.uiviewBlurMainScreen.isHidden = true
            }
        })
    }
    func actionFinish(_ sender: UIButton!) {
        uiviewBlurMainScreen.isHidden = true
        switch sender.tag {
        case 0:
            print("action dismiss")
        case 1:
            print("request finish")
        case 2:
            print("follow finish")
        case 3:
            print("withdraw finish")
        case 4:
            print("resent finish")
        default:break
        }
        loadSlideBtm()
        loadBtmBar()
    }
    
    func removeSendActFirstRequest() {
        removeView(viewArray: [lblFriendSent, btnFriendSentBack, btnFriendOK, uiviewFriendSent])
    }
    
    func loadSendActRequest(type: Int) {
        removeSendActFirstRequest()
        
        uiviewAction.isHidden = true
        uiviewFriendSent = UIView()
        uiviewFriendSent.backgroundColor = UIColor.white
        uiviewFriendSent.center.x = screenWidth / 2
        uiviewFriendSent.layer.cornerRadius = 20
        
        btnFriendSentBack = UIButton(frame: CGRectWithFactor(x: 0, y: 0, width: 42, height: 40))
        btnFriendSentBack.tag = 0
        btnFriendSentBack.setImage(#imageLiteral(resourceName: "check_cross_red"), for: .normal)
        btnFriendSentBack.addTarget(self, action: #selector(actionFinish(_:)), for: .touchUpInside)
        
        lblFriendSent = UILabel(frame: CGRectWithFactor(x: 58, y: 14, width: 190, height: 80))
        
        btnFriendOK = UIButton(frame: CGRectWithFactor(x: 43, y: 102, width: 208, height: 39))
        
        switch statusMode {
        case .defaultMode:
            if type == 1 {
                self.btnFriendOK.tag = 1
                // send friend request
                faeContact.sendFriendRequest(friendId: String(self.userId)) {(status: Int, message: Any?) in
                    if status / 2 == 100 {
                        self.lblFriendSent.text = "Friend Request Sent Successfully!"
                        self.statusMode = .pending
                        self.btnBelowSecond.setImage(#imageLiteral(resourceName: "questionIcon"), for: .normal)
                    } else {
                        print("[FMUserInfo Friend Request Sent Fail] - \(status) \(message!)")
                    }
                }
            } else {
                lblFriendSent.text = "Follow Request Sent Successfully!"
                btnFriendOK.tag = 2
            }
            break
        case .pending:
            if type == 1 {
                btnFriendOK.tag = 3
                // withdraw friend request
                /* when api is ready
                 faeContact.withdrawFriendRequest(friendId: String(self.userId)) {(status: Int, message: Any?) in
                 if status / 2 == 100 {
                 self.lblFriendSent.text = "Request Withdraw Successfully!"
                 self.statusMode = .defaultMode
                 self.btnBelowSecond.setImage(#imageLiteral(resourceName: "btnAddFriend"), for: .normal)
                 } else {
                 print("[FMUserInfo Request Withdraw Fail] - \(status) \(message!)")
                 }
                 }
                 */
                self.lblFriendSent.text = "Request Withdraw Successfully!"
                self.statusMode = .defaultMode
                self.btnBelowSecond.setImage(#imageLiteral(resourceName: "btnAddFriend"), for: .normal)
                
            } else {
                lblFriendSent.text = "Request Resent Successfully!"
                btnFriendOK.tag = 4
            }
            break
        default:
            break
        }
        
        lblFriendSent.numberOfLines = 2
        lblFriendSent.textAlignment = .center
        lblFriendSent.font = UIFont(name: "AvenirNext-Medium", size: 18 * screenHeightFactor)
        lblFriendSent.textColor = UIColor.faeAppInputTextGrayColor()
        
        btnFriendOK.setTitle("OK", for: .normal)
        btnFriendOK.setTitleColor(UIColor.white, for: .normal)
        btnFriendOK.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 18 * screenHeightFactor)
        btnFriendOK.backgroundColor = UIColor.faeAppRedColor()
        btnFriendOK.layer.cornerRadius = 19
        btnFriendOK.addTarget(self, action: #selector(actionFinish(_:)), for: .touchUpInside)
        
        uiviewFriendSent.addSubview(lblFriendSent)
        uiviewFriendSent.addSubview(btnFriendSentBack)
        uiviewFriendSent.addSubview(btnFriendOK)
        
        uiviewBlurMainScreen.addSubview(uiviewFriendSent)
        addConstraintsToView(parent: uiviewBlurMainScreen, child: uiviewFriendSent, left: false, gapH: 62, width: 290, top: true, gapV: 195, height: 161)
        
    }
    
    func animationRedSlidingLine(_ sender: UIButton!) {
        if sender.tag == 1 {
            UIView.animate(withDuration: 0.3, animations: {
                self.view.frame.size.height = screenHeight
            })
        } else if sender.tag == 3 {
            view.frame.size.height = screenHeight
        } else if sender.tag == 5 {
            view.frame.size.height = screenHeight
        }
        
        let tag = CGFloat(sender.tag)
        let centerAtOneSix = screenWidth / 6
        let targetCenter = CGFloat(tag * centerAtOneSix)
        UIView.animate(withDuration: 0.25, animations: ({
            self.uiviewRedLine.center.x = targetCenter
        }), completion: { _ in
            
        })
    }
    
    func CGRectWithFactor(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) -> CGRect {
        return CGRect(x: x * screenWidthFactor, y: y * screenHeightFactor, width: width * screenWidthFactor, height: height * screenHeightFactor)
    }
    
    func addConstraintsToView(parent: UIView, child: UIView, left: Bool, gapH: CGFloat, width: CGFloat, top: Bool, gapV: CGFloat, height: CGFloat) {
        let H: String!
        if left {
            H = "H:|-\(gapH * screenWidthFactor)-[v0(\(width * screenWidthFactor))]"
        } else {
            H = "H:[v0(\(width * screenWidthFactor))]-\(gapH * screenWidthFactor)-|"
        }
        
        let V: String!
        if top {
            V = "V:|-\(gapV * screenHeightFactor)-[v0(\(height * screenHeightFactor))]"
        } else {
            V = "V:[v0(\(height * screenHeightFactor))]-\(gapV * screenHeightFactor)-|"
        }
        parent.addConstraintsWithFormat(H, options: [], views: child)
        parent.addConstraintsWithFormat(V, options: [], views: child)
    }
    
    func removeView(viewArray: [UIView?]) {
        for aview in viewArray {
            if aview != nil {
                aview?.removeFromSuperview()
            }
        }
    }
}

