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
    var uiviewAvatarShadow: UIView!
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
    var requestId: Int = -1
    
    let ADD_FRIEND_ACT = 1
    let FOLLOW_ACT = 2
    let WITHDRAW_ACT = 3
    let RESEND_ACT = 4
    
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
        loadBlurView()
        loadSendActRequest()
    }
    
    func getStatusMode() {
        faeContact.getFriends() {(status: Int, message: Any?) in
            if status / 100 == 2 {
                let json = JSON(message!)
                if json.count != 0 {
                    for i in 0..<json.count {
                        if json[i]["friend_id"].intValue == self.userId {
                            self.statusMode = .accepted
                            break
                        }
                    }
                }
                self.switchBtmSecondBtn()
            } else {
                print("[FMUserInfo get friends list fail] - \(status) \(message!)")
            }
        }
        
        faeContact.getFriendRequestsSent() {(status: Int, message: Any?) in
            if status / 100 == 2 {
                let json = JSON(message!)
                if json.count != 0 {
                    for i in 0..<json.count {
                        if json[i]["requested_user_id"].intValue == self.userId {
                            self.statusMode = .pending
                            break
                        }
                    }
                }
                self.switchBtmSecondBtn()
            } else {
                print("[FMUserInfo get requested friends list fail] - \(status) \(message!)")
            }
        }
    }
    
    // setupUI
    fileprivate func loadMainPage() {
        self.view.backgroundColor = .white
        imgHeadBgd = UIImageView(frame: CGRect(x: 0, y: 0, w: screenWidth / screenWidthFactor, h: 188))
        imgHeadBgd.image = #imageLiteral(resourceName: "imgBackground")
        view.addSubview(imgHeadBgd)
        
        uiviewAvatarShadow = UIView(frame: CGRect(x: 0, y: 136, w: 98, h: 98))
        uiviewAvatarShadow.center.x = screenWidth / 2
        uiviewAvatarShadow.layer.cornerRadius = 43
        uiviewAvatarShadow.layer.shadowColor = UIColor._182182182().cgColor
        uiviewAvatarShadow.layer.shadowOpacity = 1
        uiviewAvatarShadow.layer.shadowRadius = 8
        uiviewAvatarShadow.layer.shadowOffset = CGSize(width: 0, height: 1)
        
        imgAvatar = FaeAvatarView(frame: CGRect(x: 0, y: 0, w: 98, h: 98))
        imgAvatar.layer.cornerRadius = 43
        imgAvatar.contentMode = .scaleAspectFill
        imgAvatar.clipsToBounds = true
        imgAvatar.layer.borderWidth = 6
        imgAvatar.layer.borderColor = UIColor.white.cgColor
        
        view.addSubview(uiviewAvatarShadow)
        uiviewAvatarShadow.addSubview(imgAvatar)
        
        imgAvatar.userID = self.userId
        imgAvatar.loadAvatar(id: self.userId)
        
        btnMoreOptions = UIButton()
        btnMoreOptions.setImage(#imageLiteral(resourceName: "pinDetailMore"), for: .normal)
        view.addSubview(btnMoreOptions)
        addConstraintsToView(parent: view, child: btnMoreOptions, left: false, gapH: 15, width: 27, top: true, gapV: 205, height: 7)
        btnMoreOptions.addTarget(self, action: #selector(showPinMoreButtonDetails(_:)), for: .touchUpInside)
        
        lblNickName = UILabel(frame: CGRect(x: 0, y: 237, w: 350, h: 27))
        lblNickName.center.x = screenWidth / 2
        lblNickName.font = UIFont(name: "AvenirNext-DemiBold", size: 20 * screenHeightFactor)
        lblNickName.adjustsFontSizeToFitWidth = true
        lblNickName.textAlignment = .center
        lblNickName.textColor = UIColor._898989()
        
        lblUserName = UILabel(frame: CGRect(x: 0, y: 265, w: 140, h: 18))
        lblUserName.center.x = screenWidth / 2
        lblUserName.font = UIFont(name: "AvenirNext-Medium", size: 13 * screenHeightFactor)
        lblUserName.adjustsFontSizeToFitWidth = true
        lblUserName.textAlignment = .center
        lblUserName.textColor = UIColor._155155155()
        
        lblShortIntro = UILabel(frame: CGRect(x: 0, y: 289, w: 343, h: 18))
        lblShortIntro.center.x = screenWidth / 2
        lblShortIntro.font = UIFont(name: "AvenirNext-Medium", size: 13 * screenHeightFactor)
        lblShortIntro.textAlignment = .center
        lblShortIntro.textColor = UIColor._146146146()
        
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
    
    fileprivate func loadSlideBtm() {
        uiviewTblCtrlBtnSub = UIView(frame: CGRect(x: 0, y: 320, w: screenWidth / screenWidthFactor, h: 416))
        uiviewTblCtrlBtnSub.backgroundColor = UIColor.white
        view.addSubview(uiviewTblCtrlBtnSub)
        
        uiviewGrayTopLine = UIView(frame: CGRect(x: 0, y: 0, w: screenWidth / screenWidthFactor, h: 5))
        uiviewGrayTopLine.layer.backgroundColor = UIColor(red: 241 / 255, green: 241 / 255, blue: 241 / 255, alpha: 100).cgColor
        uiviewTblCtrlBtnSub.addSubview(uiviewGrayTopLine)
        
        uiviewGrayMidLine = UIView(frame: CGRect(x: 0, y: 53, w: screenWidth / screenWidthFactor, h: 1))
        uiviewGrayMidLine.layer.backgroundColor = UIColor(red: 200 / 255, green: 199 / 255, blue: 204 / 255, alpha: 1.0).cgColor
        uiviewTblCtrlBtnSub.addSubview(uiviewGrayMidLine)
        
        let widthOfThreeButtons = screenWidth / (3 * screenWidthFactor)
        
        uiviewRedLine = UIView(frame: CGRect(x: 0, y: 52, w: widthOfThreeButtons, h: 2))
        uiviewRedLine.layer.borderWidth = 2
        uiviewRedLine.layer.borderColor = UIColor(red: 249 / 255, green: 90 / 255, blue: 90 / 255, alpha: 1.0).cgColor
        uiviewTblCtrlBtnSub.addSubview(uiviewRedLine)
        
        lblGeneral = UILabel()
        lblGeneral.text = "General"
        lblGeneral.textColor = UIColor._898989()
        lblGeneral.textAlignment = .center
        lblGeneral.font = UIFont(name: "AvenirNext-Medium", size: 16 * screenHeightFactor)
        uiviewTblCtrlBtnSub.addSubview(lblGeneral)
        
        btnGeneral = UIButton()
        btnGeneral.addTarget(self, action: #selector(animationRedSlidingLine(_:)), for: .touchUpInside)
        uiviewTblCtrlBtnSub.addSubview(btnGeneral)
        btnGeneral.tag = 1
        
        lblActivities = UILabel()
        lblActivities.text = "Activities"
        lblActivities.textColor = UIColor._898989()
        lblActivities.textAlignment = .center
        lblActivities.font = UIFont(name: "AvenirNext-Medium", size: 16 * screenHeightFactor)
        uiviewTblCtrlBtnSub.addSubview(lblActivities)
        
        btnActivities = UIButton()
        btnActivities.addTarget(self, action: #selector(animationRedSlidingLine(_:)), for: .touchUpInside)
        uiviewTblCtrlBtnSub.addSubview(btnActivities)
        btnActivities.tag = 3
        
        lblAlbums = UILabel()
        lblAlbums.text = "Albums"
        lblAlbums.textColor = UIColor._898989()
        lblAlbums.textAlignment = .center
        lblAlbums.font = UIFont(name: "AvenirNext-Medium", size: 16 * screenHeightFactor)
        uiviewTblCtrlBtnSub.addSubview(lblAlbums)
        
        btnAlbums = UIButton()
        btnAlbums.addTarget(self, action: #selector(animationRedSlidingLine(_:)), for: .touchUpInside)
        uiviewTblCtrlBtnSub.addSubview(btnAlbums)
        btnAlbums.tag = 5
        
        lblContent = UILabel(frame: CGRect(x: 0, y: 98, w: 221, h: 50))
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
        
        uiviewGrayBtmLine = UIView(frame: CGRect(x: 0, y: 687, w: screenWidth / screenWidthFactor, h: 1))
        uiviewGrayBtmLine.layer.backgroundColor = UIColor(red: 200 / 255, green: 199 / 255, blue: 204 / 255, alpha: 1.0).cgColor
        view.addSubview(uiviewGrayBtmLine)
    }
    
    fileprivate func loadBtmBar() {
        btnBack = UIButton()
        view.addSubview(btnBack)
        btnBack.setImage(#imageLiteral(resourceName: "navigationBack"), for: .normal)
        addConstraintsToView(parent: view, child: btnBack, left: true, gapH: 0, width: 48, top: false, gapV: 0, height: 48)
        btnBack.addTarget(self, action: #selector(actionBack(_:)), for: .touchUpInside)
        
        btnBelowFirst = UIButton()
        view.addSubview(btnBelowFirst)
        btnBelowFirst.setImage(#imageLiteral(resourceName: "btnChat"), for: .normal)
        addConstraintsToView(parent: view, child: btnBelowFirst, left: true, gapH: 133, width: 48, top: false, gapV: 0, height: 48)
        btnBelowFirst.addTarget(self, action: #selector(belowEnterChat(_:)), for: .touchUpInside)
        
        btnBelowSecond = UIButton()
        view.addSubview(btnBelowSecond)
        addConstraintsToView(parent: view, child: btnBelowSecond, left: true, gapH: 228, width: 48, top: false, gapV: 0, height: 48)
        btnBelowSecond.addTarget(self, action: #selector(belowAddFriend(_:)), for: .touchUpInside)
        
        getStatusMode()
    }
    
    fileprivate func loadBlurView() {
        uiviewBlurMainScreen = UIView(frame: CGRect(x: 0, y: 0, w: screenWidth / screenWidthFactor, h: screenHeight / screenHeightFactor))
        uiviewBlurMainScreen.backgroundColor = UIColor(r: 107, g: 105, b: 105, alpha: 70)
        
        uiviewAction = UIView()
        uiviewAction.backgroundColor = UIColor.white
        uiviewAction.layer.cornerRadius = 20
        
        lblChoose = UILabel(frame: CGRect(x: 0, y: 20, w: 290, h: 25))
        lblChoose.textAlignment = .center
        lblChoose.text = "Choose an Action"
        lblChoose.textColor = UIColor._898989()
        lblChoose.font = UIFont(name: "AvenirNext-Medium", size: 18 * screenHeightFactor)
        
        uiviewAddFriend = UIView(frame: CGRect(x: 40, y: 66, w: 208, h: 50))
        uiviewAddFriend.layer.borderWidth = 2
        uiviewAddFriend.layer.borderColor = UIColor._2499090().cgColor
        uiviewAddFriend.layer.cornerRadius = 23
        
        uiviewFollow = UIView(frame: CGRect(x: 40, y: 131, w: 208, h: 50))
        uiviewFollow.layer.borderWidth = 2
        uiviewFollow.layer.borderColor = UIColor._2499090().cgColor
        uiviewFollow.layer.cornerRadius = 23
        
        btnActFirst = UIButton(frame: CGRect(x: 40, y: 66, w: 208, h: 50))
        btnActFirst.setTitleColor(UIColor._2499090(), for: .normal)
        btnActFirst.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 18 * screenHeightFactor)
        btnActFirst.addTarget(self, action: #selector(sentActFirstRequest(_:)), for: .touchUpInside)
        
        btnActSecond = UIButton(frame: CGRect(x: 40, y: 131, w: 208, h: 50))
        btnActSecond.setTitleColor(UIColor._2499090(), for: .normal)
        btnActSecond.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 18 * screenHeightFactor)
        btnActSecond.addTarget(self, action: #selector(sentActSecondRequest(_:)), for: .touchUpInside)
        
        btnCancel = UIButton(frame: CGRect(x: 40, y: 185, w: 208, h: 50))
        btnCancel.setTitle("Cancel", for: .normal)
        btnCancel.setTitleColor(UIColor._2499090(), for: .normal)
        btnCancel.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size: 18 * screenHeightFactor)
        btnCancel.addTarget(self, action: #selector(actionCancel(_:)), for: .touchUpInside)
        
        uiviewAction.addSubview(lblChoose)
        uiviewAction.addSubview(uiviewAddFriend)
        uiviewAction.addSubview(uiviewFollow)
        uiviewAction.addSubview(btnActFirst)
        uiviewAction.addSubview(btnActSecond)
        uiviewAction.addSubview(btnCancel)
        
        uiviewBlurMainScreen.addSubview(uiviewAction)
        addConstraintsToView(parent: uiviewBlurMainScreen, child: uiviewAction, left: true, gapH: (screenWidth / screenWidthFactor - 290) / 2, width: 290, top: true, gapV: 200, height: 237)
        
        view.addSubview(uiviewBlurMainScreen)
        uiviewBlurMainScreen.isHidden = true
    }
    
    fileprivate func loadSendActRequest() {
        uiviewFriendSent = UIView()
        uiviewFriendSent.backgroundColor = UIColor.white
        uiviewFriendSent.center.x = screenWidth / 2
        uiviewFriendSent.layer.cornerRadius = 20
        
        btnFriendSentBack = UIButton(frame: CGRect(x: 0, y: 0, w: 42, h: 40))
        btnFriendSentBack.tag = 0
        btnFriendSentBack.setImage(#imageLiteral(resourceName: "check_cross_red"), for: .normal)
        btnFriendSentBack.addTarget(self, action: #selector(actionFinish(_:)), for: .touchUpInside)
        
        lblFriendSent = UILabel(frame: CGRect(x: 58, y: 14, w: 190, h: 80))
        
        btnFriendOK = UIButton(frame: CGRect(x: 43, y: 102, w: 208, h: 39))
        lblFriendSent.numberOfLines = 2
        lblFriendSent.textAlignment = .center
        lblFriendSent.font = UIFont(name: "AvenirNext-Medium", size: 18 * screenHeightFactor)
        lblFriendSent.textColor = UIColor._898989()
        
        btnFriendOK.setTitle("OK", for: .normal)
        btnFriendOK.setTitleColor(UIColor.white, for: .normal)
        btnFriendOK.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 18 * screenHeightFactor)
        btnFriendOK.backgroundColor = UIColor._2499090()
        btnFriendOK.layer.cornerRadius = 19
        btnFriendOK.addTarget(self, action: #selector(actionFinish(_:)), for: .touchUpInside)
        
        uiviewFriendSent.addSubview(lblFriendSent)
        uiviewFriendSent.addSubview(btnFriendSentBack)
        uiviewFriendSent.addSubview(btnFriendOK)
        
        uiviewBlurMainScreen.addSubview(uiviewFriendSent)
        addConstraintsToView(parent: uiviewBlurMainScreen, child: uiviewFriendSent, left: false, gapH: 62, width: 290, top: true, gapV: 195, height: 161)
    }
    // setupUI end
    
    // actions
    func showPinMoreButtonDetails(_ sender: UIButton!) {
        print("in more details")
    }
    func actionBack(_ sender: UIButton!) {
        navigationController?.popViewController(animated: true)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "willEnterForeground"), object: nil)
    }
    
    func belowEnterChat(_ sender: UIButton!) {
        print("enter Chat")
    }
    
    func belowAddFriend(_ sender: UIButton!) {
        uiviewBlurMainScreen.isHidden = false
        animationBlurMainScreen(action: "show")
        getActionInfo()
        if let uiview = uiviewFriendSent {
            uiview.isHidden = true
        }
        uiviewAction.isHidden = false
    }
    
    func sentActFirstRequest(_ sender: UIButton!) {
        if sender.tag == ADD_FRIEND_ACT {   // "Add Friend" button pressed
            triggerSendActRequest(type: ADD_FRIEND_ACT)
        } else if sender.tag == WITHDRAW_ACT {     // "Withdraw" button pressed
            triggerSendActRequest(type: WITHDRAW_ACT)
        }
    }
    
    func sentActSecondRequest(_ sender: UIButton!) {
        if sender.tag == FOLLOW_ACT {
            triggerSendActRequest(type: FOLLOW_ACT)
        } else if sender.tag == RESEND_ACT {
            triggerSendActRequest(type: RESEND_ACT)
        }
    }
    
    func actionCancel(_ sender: UIButton!) {
        animationBlurMainScreen(action: "hide")
    }
    func actionFinish(_ sender: UIButton!) {
        uiviewBlurMainScreen.isHidden = true
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
    
    func switchBtmSecondBtn() {
        switch statusMode {
        case .defaultMode:
            btnBelowSecond.setImage(#imageLiteral(resourceName: "btnAddFriend"), for: .normal)
            break
        case .accepted:
            btnBelowSecond.setImage(#imageLiteral(resourceName: "gearIcon"), for: .normal)
            break
        case .blocked:
            //            btnBelowFirst.removeFromSuperview()
            btnBelowFirst.isHidden = true
            btnBelowSecond.isHidden = true
            lblContent.text = "Content Unavailable"
            break
        case .pending:
            btnBelowSecond.setImage(#imageLiteral(resourceName: "questionIcon"), for: .normal)
            break
        }
    }
    
    func getActionInfo() {
        switch statusMode {
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
            break
        default:
            break
        }
    }
    
    fileprivate func triggerSendActRequest(type: Int) {
        uiviewAction.isHidden = true
        uiviewFriendSent.isHidden = false
        animationActionView()
        
        switch statusMode {
        case .defaultMode:
            if type == ADD_FRIEND_ACT {   // "Add Friend" button pressed
                self.btnFriendOK.tag = ADD_FRIEND_ACT
                // send friend request
                faeContact.sendFriendRequest(friendId: String(self.userId)) {(status: Int, message: Any?) in
                    if status / 100 == 2 {
                        self.lblFriendSent.text = "Friend Request Sent Successfully!"
                        self.statusMode = .pending
                        self.btnBelowSecond.setImage(#imageLiteral(resourceName: "questionIcon"), for: .normal)
                    } else if status == 400 {
                        self.lblFriendSent.text = "You've Already Sent Friend Request!"
                        self.statusMode = .pending
                        self.btnBelowSecond.setImage(#imageLiteral(resourceName: "questionIcon"), for: .normal)
                    } else {
                        self.lblFriendSent.text = "Friend Request Sent Fail!"
                        print("[FMUserInfo Friend Request Sent Fail] - \(status) \(message!)")
                    }
                }
            } else if type == FOLLOW_ACT {  // "Follow" button pressed
                btnFriendOK.tag = FOLLOW_ACT
                faeContact.followPerson(followeeId: String(self.userId)) {(status: Int, message: Any?) in
                    if status / 100 == 2 {
                        self.lblFriendSent.text = "Follow Successfully!"
//                        self.statusMode = .pending
//                        self.btnBelowSecond.setImage(#imageLiteral(resourceName: "questionIcon"), for: .normal)
                    } else {
                        self.lblFriendSent.text = "Follow Request Sent Fail!"
                        print("[FMUserInfo Follow Request Sent Fail] - \(status) \(message!)")
                    }
                }
            }
            break
        case .pending:
            if type == WITHDRAW_ACT {    // "Withdraw" button pressed
                btnFriendOK.tag = WITHDRAW_ACT
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
                                self.lblFriendSent.text = "Request Withdraw Successfully!"
                                self.statusMode = .defaultMode
                                self.btnBelowSecond.setImage(#imageLiteral(resourceName: "btnAddFriend"), for: .normal)
                            } else if status == 404 {
                                self.lblFriendSent.text = "You haven't Sent Friend Request!"
                                self.statusMode = .defaultMode
                                self.btnBelowSecond.setImage(#imageLiteral(resourceName: "btnAddFriend"), for: .normal)
                            } else {
                                self.lblFriendSent.text = "Request Withdraw Fail!"
                                print("[FMUserInfo Request Withdraw Fail] - \(status) \(message!)")
                            }
                        }
                    } else {
                        self.lblFriendSent.text = "Internet Error"
                        print("[FMUserInfo getFriendRequestsSent Fail] - \(status) \(message!)")
                    }
                }
            } else if type == RESEND_ACT {   // "Resend" button pressed
                btnFriendOK.tag = RESEND_ACT
                faeContact.sendFriendRequest(friendId: String(self.userId), boolResend: "true") {(status: Int, message: Any?) in
                    if status / 100 == 2 {
                        self.lblFriendSent.text = "Request Resent Successfully!"
                    } else if status == 400 {
                        self.lblFriendSent.text = "The User Has Already Sent You a Friend Request!"
                    } else {
                        self.lblFriendSent.text = "Request Resent Fail!"
                        print("[FMUserInfo Friend Request Resent Fail] - \(status) \(message!)")
                    }
                }
            }
            break
        default:
            break
        }
    }
    
    // animations
    func animationActionView() {
        uiviewAction.alpha = 0
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
            self.uiviewAction.alpha = 1
        }, completion: nil)
    }
    
    func animationBlurMainScreen(action: String) {
        if action == "show" {
            uiviewBlurMainScreen.alpha = 0
            uiviewAction.alpha = 0
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
                self.uiviewBlurMainScreen.alpha = 1
                self.uiviewAction.alpha = 1
            }, completion: nil)
        } else if action == "hide" {
            uiviewBlurMainScreen.alpha = 1
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
    // animations end
    
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
    
}

