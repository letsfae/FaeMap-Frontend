//
//  AddFriendFromNameCardViewController.swift
//  faeBeta
//
//  Created by Vicky on 2017-08-10.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit
import SwiftyJSON
import RealmSwift

enum FriendStatus: String {
    case defaultMode
    case accepted
    case blocked
    case blocked_by
    case pending
    case requested
    case nameCardOther
    case nameCardSelf
}

protocol AddFriendFromNameCardDelegate: class {
    func changeContactsTable(action: Int, userId: Int)
}

class AddFriendFromNameCardViewController: UIViewController {
    weak var delegate: PassStatusFromViewToButtonDelegate?
    weak var contactsDelegate: AddFriendFromNameCardDelegate?
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
    var lblBlockHint: UILabel!
    var indicatorView: UIActivityIndicatorView!
    
    var userId: Int = -1
    let faeContact = FaeContact()
    //var requestId: Int = -1
    
    let OK = 0
    let ADD_FRIEND_ACT = 1
    let FOLLOW_ACT = 2
    let WITHDRAW_ACT = 3
    let RESEND_ACT = 4
    let REMOVE_FRIEND_ACT = 5
    let BLOCK_ACT = 6
    let REPORT_ACT = 7
    let UNFOLLOW_ACT = 8
    let ACCEPT_ACT = 9
    let IGNORE_ACT = 10
    let EDIT_NAME_CARD = 11
    let INFO_SETTING = 12
    
    var statusMode: FriendStatus = .defaultMode
    
    // MARK: life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor._107105105_a50()
        loadContent()
        createActivityIndicator()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(actionCancel(_:)))
        view.addGestureRecognizer(tapGesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        animationShowSelf()
    }
    
    // MARK: setup
    fileprivate func createActivityIndicator() {
        indicatorView = UIActivityIndicatorView()
        indicatorView.activityIndicatorViewStyle = .whiteLarge
        indicatorView.center = view.center
        indicatorView.hidesWhenStopped = true
        indicatorView.color = UIColor._2499090()
        
        view.addSubview(indicatorView)
        view.bringSubview(toFront: indicatorView)
    }
    
    fileprivate func loadContent() {
        uiviewChooseAction = UIView(frame: CGRect(x: 0, y: 200, w: 290, h: 237))
        uiviewChooseAction.center.x = screenWidth / 2
        uiviewChooseAction.backgroundColor = .white
        uiviewChooseAction.layer.cornerRadius = 20
        view.addSubview(uiviewChooseAction)
        
        lblChoose = UILabel(frame: CGRect(x: 0, y: 20, w: 290, h: 25))
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
        view.addConstraintsWithFormat("H:|-80-[v0]-80-|", options: [], views: btnCancel)
        view.addConstraintsWithFormat("V:[v0(25)]-\(15 * screenHeightFactor)-|", options: [], views: btnCancel)
        
        loadSendActRequest()
        getFriendStatus()
    }
    
    fileprivate func loadSendActRequest() {
        uiviewMsgSent = UIView(frame: CGRect(x: 0, y: 200, w: 290, h: 161))
        uiviewMsgSent.backgroundColor = .white
        uiviewMsgSent.center.x = screenWidth / 2
        uiviewMsgSent.layer.cornerRadius = 20 * screenWidthFactor
        uiviewMsgSent.isHidden = true
        
        btnFriendSentBack = UIButton(frame: CGRect(x: 0, y: 0, w: 42, h: 40))
        btnFriendSentBack.tag = 0
        btnFriendSentBack.setImage(#imageLiteral(resourceName: "check_cross_red"), for: .normal)
        btnFriendSentBack.addTarget(self, action: #selector(actionFinish(_:)), for: .touchUpInside)
        
        lblMsgSent = UILabel(frame: CGRect(x: 0, y: 30, w: 290, h: 50))
        lblMsgSent.numberOfLines = 2
        lblMsgSent.textAlignment = .center
        lblMsgSent.font = UIFont(name: "AvenirNext-Medium", size: 18 * screenHeightFactor)
        lblMsgSent.textColor = UIColor._898989()
        
        lblBlockHint = UILabel(frame: CGRect(x: 0, y: 93, w: 290, h: 36))
        lblBlockHint.numberOfLines = 2
        lblBlockHint.textAlignment = .center
        lblBlockHint.font = UIFont(name: "AvenirNext-Medium", size: 13 * screenHeightFactor)
        lblBlockHint.textColor = UIColor._138138138()
        lblBlockHint.text = "The User will be found in your \nBlocked List in Settings > Privacy."
        uiviewMsgSent.addSubview(lblBlockHint)
        lblBlockHint.isHidden = true
        
        btnOK = UIButton()
        uiviewMsgSent.addSubview(btnOK)
        btnOK.setTitleColor(.white, for: .normal)
        btnOK.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 18 * screenHeightFactor)
        btnOK.backgroundColor = UIColor._2499090()
        btnOK.layer.cornerRadius = 19 * screenWidthFactor
        btnOK.addTarget(self, action: #selector(actionOK(_:)), for: .touchUpInside)
        let padding = (290 - 208) / 2 * screenWidthFactor
        uiviewMsgSent.addConstraintsWithFormat("H:|-\(padding)-[v0]-\(padding)-|", options: [], views: btnOK)
        uiviewMsgSent.addConstraintsWithFormat("V:[v0(\(39 * screenHeightFactor))]-\(20 * screenHeightFactor)-|", options: [], views: btnOK)
        
        uiviewMsgSent.addSubview(lblMsgSent)
        uiviewMsgSent.addSubview(btnFriendSentBack)
        view.addSubview(uiviewMsgSent)
    }
    
    fileprivate func getFriendStatus() {
        switch statusMode {
        case .defaultMode:
            btnActFirst.setTitle("Add Friend", for: .normal)
            btnActFirst.tag = ADD_FRIEND_ACT
            btnActSecond.setTitle("Follow", for: .normal)
            btnActSecond.tag = FOLLOW_ACT
        case .pending:
            btnActFirst.setTitle("Withdraw", for: .normal)
            btnActFirst.tag = WITHDRAW_ACT
            btnActSecond.setTitle("Resend", for: .normal)
            btnActSecond.tag = RESEND_ACT
        case .requested:
            btnActFirst.setTitle("Accept", for: .normal)
            btnActFirst.tag = ACCEPT_ACT
            btnActSecond.setTitle("Ignore", for: .normal)
            btnActSecond.tag = IGNORE_ACT
        case .accepted:
            btnActFirst.setTitle("Remove Friend", for: .normal)
            btnActFirst.tag = REMOVE_FRIEND_ACT
            btnActSecond.setTitle("Block", for: .normal)
            btnActSecond.tag = BLOCK_ACT
            btnActThird.setTitle("Report", for: .normal)
            btnActThird.tag = REPORT_ACT
        case .nameCardOther:
            btnActFirst.setTitle("Block", for: .normal)
            btnActFirst.tag = BLOCK_ACT
            btnActSecond.setTitle("Report", for: .normal)
            btnActSecond.tag = REPORT_ACT
        case .nameCardSelf:
            btnActFirst.setTitle("Edit NameCard", for: .normal)
            btnActFirst.tag = EDIT_NAME_CARD
            btnActSecond.setTitle("Info Settings", for: .normal)
            btnActSecond.tag = INFO_SETTING
        default: break
        }
        
        if statusMode == .accepted {
            uiviewChooseAction.frame.size.height = 302 * screenHeightFactor
            btnActSecond.isHidden = false
            btnActThird.isHidden = false
        } else if statusMode == .defaultMode {
            uiviewChooseAction.frame.size.height = 172 * screenHeightFactor
            btnActSecond.isHidden = true
            btnActThird.isHidden = true
        } else {
            uiviewChooseAction.frame.size.height = 237 * screenHeightFactor
            btnActSecond.isHidden = false
            btnActThird.isHidden = true
        }
    }
    
    // MARK: actions
    @objc func sentActRequest(_ sender: UIButton!) {
        if !(sender.tag == REPORT_ACT || sender.tag == EDIT_NAME_CARD || sender.tag == INFO_SETTING) {
            print(sender.tag)
            uiviewChooseAction.isHidden = true
        }
        if sender.tag == BLOCK_ACT {
            uiviewMsgSent.frame.size.height = 208 * screenHeightFactor
            lblBlockHint.isHidden = false
        } else {
            uiviewMsgSent.frame.size.height = 161 * screenHeightFactor
            lblBlockHint.isHidden = true
        }
        if sender.tag == BLOCK_ACT || sender.tag == REMOVE_FRIEND_ACT || sender.tag == WITHDRAW_ACT || sender.tag == RESEND_ACT {
            self.animationActionView()
            btnOK.setTitle("Yes", for: .normal)
            btnOK.tag = sender.tag
        } else {
            btnOK.setTitle("OK", for: .normal)
            btnOK.tag = OK
        }
        
        switch sender.tag {
        case ADD_FRIEND_ACT:
            // send friend request
            indicatorView.startAnimating()
            faeContact.sendFriendRequest(friendId: String(self.userId)) {(status: Int, message: Any?) in
                if status / 100 == 2 {
                    self.lblMsgSent.text = "Friend Request \nSent Successfully!"
                    self.statusMode = .pending
                    let realm = try! Realm()
                    if let user = realm.filterUser(id: String(self.userId)) {
                        try! realm.write {
                            user.relation = FRIEND_REQUESTED
                            let dateFormatter = DateFormatter()
                            dateFormatter.calendar = Calendar(identifier: .gregorian)
                            dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
                            dateFormatter.dateFormat = "yyyyMMddhhmmss"
                            user.created_at = dateFormatter.string(from: Date())
                        }
                    }
                    FaeChat.sendContactMessage(to: "\(self.userId)", with: "send friend request")
                } else if status == 500 {
                    self.lblMsgSent.text = "Internal Server \n Error!"
                } else {
                    if let errorCode = JSON(message!)["error_code"].string {
                        handleErrorCode(.contact, errorCode, { (errorMsg) in
                            self.lblMsgSent.text = errorMsg
                        })
                    }
                }
                self.indicatorView.stopAnimating()
                self.animationActionView()
            }
        case FOLLOW_ACT:
            indicatorView.startAnimating()
            faeContact.followPerson(followeeId: String(self.userId)) {(status: Int, message: Any?) in
                if status / 100 == 2 {
                    self.lblMsgSent.text = "Follow Request \nSent Successfully!"
                } else {
                    self.lblMsgSent.text = "Follow Request \nSent Fail!"
                    print("[FMUserInfo Follow Request Sent Fail] - \(status) \(message!)")
                }
                self.indicatorView.stopAnimating()
                self.animationActionView()
            }
        case WITHDRAW_ACT:
            // withdraw friend request
            lblMsgSent.text = "Are you sure you want \nto withdraw this request?"
        case RESEND_ACT:
            lblMsgSent.text = "Are you sure you want \nto resend this request?"
        case ACCEPT_ACT:
            indicatorView.startAnimating()
            faeContact.acceptFriendRequest(friendId: String(userId)) { (status: Int, message: Any?) in
                if status / 100 == 2 {
                    self.lblMsgSent.text = "Accept Request \nSuccessfully!"
                    self.statusMode = .accepted
                    self.contactsDelegate?.changeContactsTable(action: self.ACCEPT_ACT, userId: self.userId)
                    
                    let realm = try! Realm()
                    if let user = realm.filterUser(id: String(self.userId)) {
                        try! realm.write {
                            user.relation = IS_FRIEND
                            user.created_at = ""
                        }
                    }
                    FaeChat.sendContactMessage(to: "\(self.userId)", with: "accept friend request")
                    //print("[FMUserInfo Accept Request Successfully]")
                } else if status == 500 {
                    self.lblMsgSent.text = "Internal Server \n Error!"
                } else {
                    if let errorCode = JSON(message!)["error_code"].string {
                        handleErrorCode(.contact, errorCode, { (errorMsg) in
                            self.lblMsgSent.text = errorMsg
                        })
                    }
                }
                self.indicatorView.stopAnimating()
                self.animationActionView()
            }
        case IGNORE_ACT:
            indicatorView.startAnimating()
            faeContact.ignoreFriendRequest(friendId: String(userId)) {(status: Int, message: Any?) in
                if status / 100 == 2 {
                    self.lblMsgSent.text = "Ignore Request \nSuccessfully!"
                    self.statusMode = .defaultMode
                    self.contactsDelegate?.changeContactsTable(action: self.IGNORE_ACT, userId: self.userId)
                    
                    let realm = try! Realm()
                    if let user = realm.filterUser(id: String(self.userId)) {
                        try! realm.write {
                            user.relation = NO_RELATION
                            user.created_at = ""
                        }
                    }
                    FaeChat.sendContactMessage(to: "\(self.userId)", with: "ignore friend request")
                } else if status == 500 {
                    self.lblMsgSent.text = "Internal Server \n Error!"
                } else {
                    if let errorCode = JSON(message!)["error_code"].string {
                        handleErrorCode(.contact, errorCode, { (errorMsg) in
                            self.lblMsgSent.text = errorMsg
                        })
                    }
                }
                self.indicatorView.stopAnimating()
                self.animationActionView()
            }
        case REMOVE_FRIEND_ACT:
            lblMsgSent.text = "Are you sure you want \nto remove this person?"
        case BLOCK_ACT:
            lblMsgSent.text = "Are you sure you want \nto block this person?"
        case REPORT_ACT:
            let reportPinVC = ReportViewController()
            reportPinVC.reportType = 0
            reportPinVC.modalPresentationStyle = .overCurrentContext
            self.present(reportPinVC, animated: true, completion: nil)
        case EDIT_NAME_CARD:
            let vc = SetInfoNamecard()
            vc.enterMode = .nameCard
            vc.modalPresentationStyle = .overCurrentContext
            self.present(vc, animated: true, completion: nil)
        case INFO_SETTING:
            let vc = SetInfoViewController()
            vc.enterMode = .nameCard
            vc.modalPresentationStyle = .overCurrentContext
            self.present(vc, animated: true, completion: nil)
        default: break
        }
    }
    
    @objc func actionCancel(_ sender: Any?) {
        delegate?.updateNameCardAfterEditing()
        animationHideSelf()
    }
    
    @objc func actionFinish(_ sender: UIButton!) {
        delegate?.passFriendStatusFromView(status: statusMode)
        animationHideSelf()
    }
    
    @objc func actionOK(_ sender: UIButton) { // TODO: jichao
        if sender.tag == OK {
            delegate?.passFriendStatusFromView(status: statusMode)
            animationHideSelf()
        } else if sender.tag == REMOVE_FRIEND_ACT {
            indicatorView.startAnimating()
            faeContact.deleteFriend(userId: String(userId)) {(status: Int, message: Any?) in
                if status / 100 == 2 {
                    self.lblMsgSent.text = "Remove Friend \nSuccessfully!"
                    self.statusMode = .defaultMode
                    self.contactsDelegate?.changeContactsTable(action: self.REMOVE_FRIEND_ACT, userId: self.userId)
                    
                    let realm = try! Realm()
                    if let user = realm.filterUser(id: String(self.userId)) {
                        try! realm.write {
                            user.relation = NO_RELATION
                        }
                    }
                    FaeChat.sendContactMessage(to: "\(self.userId)", with: "remove friend")
                } else if status == 500 {
                    self.lblMsgSent.text = "Internal Server \n Error!"
                } else {
                    if let errorCode = JSON(message!)["error_code"].string {
                        handleErrorCode(.contact, errorCode, { (errorMsg) in
                            self.lblMsgSent.text = errorMsg
                        })
                    }
                }
                self.btnOK.setTitle("OK", for: .normal)
                self.btnOK.tag = self.OK
                self.indicatorView.stopAnimating()
                self.animationActionView()
            }
        } else if sender.tag == BLOCK_ACT {
            indicatorView.startAnimating()
            faeContact.blockPerson(userId: String(userId)) {(status: Int, message: Any?) in
                if status / 100 == 2 {
                    self.lblMsgSent.text = "The user has been \nblocked successfully!"
                    self.statusMode = .blocked
                    self.contactsDelegate?.changeContactsTable(action: self.BLOCK_ACT, userId: self.userId)
                    
                    let realm = try! Realm()
                    if let user = realm.filterUser(id: String(self.userId)) {
                        try! realm.write {
                            if user.relation & IS_FRIEND == IS_FRIEND {
                                user.relation = IS_FRIEND | BLOCKED
                            } else {
                                user.relation = NO_RELATION
                                user.created_at = ""
                            }
                        }
                    }
                    FaeChat.sendContactMessage(to: "\(self.userId)", with: "block")
                } else if status == 500 {
                    self.lblMsgSent.text = "Internal Server \n Error!"
                } else {
                    if let errorCode = JSON(message!)["error_code"].string {
                        handleErrorCode(.contact, errorCode, { (errorMsg) in
                            self.lblMsgSent.text = errorMsg
                        })
                    }
                }
                self.btnOK.setTitle("OK", for: .normal)
                self.btnOK.tag = self.OK
                self.indicatorView.stopAnimating()
                self.animationActionView()
            }
        } else if sender.tag == WITHDRAW_ACT {
            indicatorView.startAnimating()
            faeContact.withdrawFriendRequest(friendId: String(self.userId)) {(status: Int, message: Any?) in
                if status / 100 == 2 {
                    self.lblMsgSent.text = "Request Withdraw \nSuccessfully!"
                    self.statusMode = .defaultMode
                    self.contactsDelegate?.changeContactsTable(action: self.WITHDRAW_ACT, userId: self.userId)
                    let realm = try! Realm()
                    if let user = realm.filterUser(id: String(self.userId)) {
                        try! realm.write {
                            user.relation = NO_RELATION
                            user.created_at = ""
                        }
                    }
                    FaeChat.sendContactMessage(to: "\(self.userId)", with: "withdraw friend request")
                } else if status == 500 {
                    self.lblMsgSent.text = "Internal Server \n Error!"
                } else {
                    if let errorCode = JSON(message!)["error_code"].string {
                        handleErrorCode(.contact, errorCode, { (errorMsg) in
                            self.lblMsgSent.text = errorMsg
                        })
                    }
                }
                self.btnOK.setTitle("OK", for: .normal)
                self.btnOK.tag = self.OK
                self.indicatorView.stopAnimating()
                self.animationActionView()
            }
            
            /*if let user = realm.filterUser(id: String(userId)) {
                //guard let request_id = Int(user.request_id) else { return }
                //requestId = request_id
                faeContact.withdrawFriendRequest(friendId: String(self.userId)) {(status: Int, message: Any?) in
                    if status / 100 == 2 {
                        self.lblMsgSent.text = "Request Withdraw \nSuccessfully!"
                        self.statusMode = .defaultMode
                        self.contactsDelegate?.changeContactsTable(action: self.WITHDRAW_ACT, userId: self.userId)
                        
                        try! realm.write {
                            user.relation = NO_RELATION
                        }
                    } else if status == 500 {
                        self.lblMsgSent.text = "Internal Server \n Error!"
                    } else {
                        if let errorCode = JSON(message!)["error_code"].string {
                            handleErrorCode(.contact, errorCode, { (errorMsg) in
                                self.lblMsgSent.text = errorMsg
                            })
                        }
                    }
                }
            } else {
                faeContact.getFriendRequestsSent() {(status: Int, message: Any?) in
                    if status / 100 == 2 {
                        let json = JSON(message!)
                        for i in 0..<json.count {
                            if json[i]["requested_user_id"].intValue == self.userId {
                                //self.requestId = json[i]["friend_request_id"].intValue
                            }
                        }
                        self.faeContact.withdrawFriendRequest(friendId: String(self.userId)) {(status: Int, message: Any?) in
                            if status / 100 == 2 {
                                self.lblMsgSent.text = "Request Withdraw \nSuccessfully!"
                                self.statusMode = .defaultMode
                                self.contactsDelegate?.changeContactsTable(action: self.WITHDRAW_ACT, userId: self.userId)                            
                            } else if status == 500 {
                                self.lblMsgSent.text = "Internal Server \n Error!"
                            } else {
                                if let errorCode = JSON(message!)["error_code"].string {
                                    handleErrorCode(.contact, errorCode, { (errorMsg) in
                                        self.lblMsgSent.text = errorMsg
                                    })
                                }
                            }
                        }
                    } else if status == 500 {
                        self.lblMsgSent.text = "Internal Server \n Error!"
                    } else {
                        if let errorCode = JSON(message!)["error_code"].string {
                            handleErrorCode(.contact, errorCode, { (errorMsg) in
                                self.lblMsgSent.text = errorMsg
                            })
                        }
                    }
                    self.btnOK.setTitle("OK", for: .normal)
                    self.btnOK.tag = self.OK
                    self.indicatorView.stopAnimating()
                    self.animationActionView()
                }
            }*/
        } else if sender.tag == RESEND_ACT {
            indicatorView.startAnimating()
            faeContact.sendFriendRequest(friendId: String(userId), boolResend: "true") {(status: Int, message: Any?) in
                if status / 100 == 2 {
                    self.lblMsgSent.text = "Request Resent \nSuccessfully!"
                    let realm = try! Realm()
                    if let user = realm.filterUser(id: "\(self.userId)") {
                        try! realm.write {
                            let dateFormatter = DateFormatter()
                            dateFormatter.calendar = Calendar(identifier: .gregorian)
                            dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
                            dateFormatter.dateFormat = "yyyyMMddhhmmss"
                            user.created_at = dateFormatter.string(from: Date())
                        }
                    }
                    FaeChat.sendContactMessage(to: "\(self.userId)", with: "resend friend request")
                } else if status == 500 {
                    self.lblMsgSent.text = "Internal Server \n Error!"
                } else {
                    if let errorCode = JSON(message!)["error_code"].string {
                        handleErrorCode(.contact, errorCode, { (errorMsg) in
                            self.lblMsgSent.text = errorMsg
                        })
                    }
                }
                self.btnOK.setTitle("OK", for: .normal)
                self.btnOK.tag = self.OK
                self.indicatorView.stopAnimating()
                self.animationActionView()
            }
        }
    }
    
    // MARK: animations
    func animationActionView() {
        uiviewMsgSent.isHidden = false
        uiviewChooseAction.alpha = 0
        uiviewMsgSent.alpha = 0
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut, animations: {
            self.uiviewMsgSent.alpha = 1
        }, completion: nil)
    }
    
    func animationShowSelf() {
        view.alpha = 0
        uiviewChooseAction.alpha = 0
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut, animations: {
            self.view.alpha = 1
            self.uiviewChooseAction.alpha = 1
        }, completion: nil)
    }
    
    func animationHideSelf() {
        view.alpha = 1
        uiviewChooseAction.alpha = 1
        uiviewMsgSent.alpha = 1
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut, animations: {
            self.uiviewChooseAction.alpha = 0
            self.uiviewMsgSent.alpha = 0
            self.view.alpha = 0
        }, completion: { _ in
            self.dismiss(animated: false)
        })
    }
}

