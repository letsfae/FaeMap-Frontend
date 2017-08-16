//
//  AddFriendFromNameCardViewController.swift
//  faeBeta
//
//  Created by Vicky on 2017-08-10.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit
import SwiftyJSON

class AddFriendFromNameCardViewController: UIViewController {
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
    var indicatorView: UIActivityIndicatorView!
    
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
    let ACCEPT_ACT = 9
    let IGNORE_ACT = 10
    
    var statusMode: FriendStatus = .defaultMode
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(r: 107, g: 105, b: 105, alpha: 70)
        loadContent()
        createActivityIndicator()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        animationShowSelf()
    }
    
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
        view.addSubview(uiviewMsgSent)
    }
    
    fileprivate func getFriendStatus() {
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
        case .requested:
            btnActFirst.setTitle("Accept", for: .normal)
            btnActFirst.tag = ACCEPT_ACT
            btnActSecond.setTitle("Ignore", for: .normal)
            btnActSecond.tag = IGNORE_ACT
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
    
    // actions
    func sentActRequest(_ sender: UIButton!) {
        btnOK.tag = sender.tag
        if sender.tag != REPORT_ACT {
            uiviewChooseAction.isHidden = true
        }
        indicatorView.startAnimating()
        switch sender.tag {
        case ADD_FRIEND_ACT:
            // send friend request
            faeContact.sendFriendRequest(friendId: String(self.userId)) {(status: Int, message: Any?) in
                if status / 100 == 2 {
                    self.lblMsgSent.text = "Friend Request Sent Successfully!"
                    self.statusMode = .pending
                } else if status == 400 {
                    // 400-22  Bad request, this user has already sent you a friend request
                    // 400-20  Bad request, you have already sent a request
                    // 400-6   Bad request, you have already blocked this user
                    // 400-6   Bad request, you have already been blocked by the user
                    let errorCode = JSON(message!)["error_code"].string
                    if  errorCode == "400-20" {
                        self.lblMsgSent.text = "You've Already Sent Friend Request!"
                        self.statusMode = .pending
                    } else if errorCode == "400-22" {
                        self.lblMsgSent.text = "The User Has Already Sent You a Friend Request!"
                    } else if errorCode == "400-6" {
                        self.lblMsgSent.text = "Friend Request Sent Fail! [BLOCK]"
                        self.statusMode = .blocked
                    } else {
                        self.lblMsgSent.text = "Friend Request Error!"
                    }
                } else {
                    self.lblMsgSent.text = "Friend Request Sent Fail!"
                    print("[FMUserInfo Friend Request Sent Fail] - \(status) \(message!)")
                }
                self.indicatorView.stopAnimating()
                self.animationActionView()
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
                self.indicatorView.stopAnimating()
                self.animationActionView()
            }
            break
        case WITHDRAW_ACT:
            // withdraw friend request
            faeContact.getFriendRequestsSent() {(status: Int, message: Any?) in
                if status / 100 == 2 {
                    let json = JSON(message!)
                    for i in 0..<json.count {
                        if json[i]["requested_user_id"].intValue == self.userId {
                            self.requestId = json[i]["friend_request_id"].intValue
                        }
                    }
                    self.faeContact.withdrawFriendRequest(requestId: String(self.requestId)) {(status: Int, message: Any?) in
                        if status / 100 == 2 {
                            self.lblMsgSent.text = "Request Withdraw Successfully!"
                            self.statusMode = .defaultMode
                        } else if status == 404 {
                            self.lblMsgSent.text = "You haven't Sent Friend Request!"
                            self.statusMode = .defaultMode
                        } else {
                            self.lblMsgSent.text = "Request Withdraw Fail!"
                            print("[FMUserInfo Request Withdraw Fail] - \(status) \(message!)")
                        }
                    }
                } else {
                    self.lblMsgSent.text = "Request Withdraw Error!"
                    print("[FMUserInfo Request Withdraw Error] - \(status) \(message!)")
                }
                self.indicatorView.stopAnimating()
                self.animationActionView()
            }
            break
        case RESEND_ACT:
            faeContact.sendFriendRequest(friendId: String(userId), boolResend: "true") {(status: Int, message: Any?) in
                if status / 100 == 2 {
                    self.lblMsgSent.text = "Request Resent Successfully!"
                } else if status == 400 {
                    let errorCode = JSON(message!)["error_code"].string
                    if  errorCode == "400-20" {
                        self.lblMsgSent.text = "You've Already Sent Friend Request!"
                    } else if errorCode == "400-22" {
                        self.lblMsgSent.text = "The User Has Already Sent You a Friend Request!"
                    } else if errorCode == "400-6" {
                        self.lblMsgSent.text = "Friend Request Sent Fail! [BLOCK]"
                        self.statusMode = .blocked
                    } else {
                        self.lblMsgSent.text = "Friend Request Error!"
                    }
                } else {
                    self.lblMsgSent.text = "Request Resent Fail!"
                    print("[FMUserInfo Friend Request Resent Fail] - \(status) \(message!)")
                }
                self.indicatorView.stopAnimating()
                self.animationActionView()
            }
            break
        case ACCEPT_ACT:
            faeContact.acceptFriendRequest(requestId: String(requestId)) { (status: Int, message: Any?) in
                if status / 100 == 2 {
                    self.lblMsgSent.text = "Accept Request Successfully!"
                    self.statusMode = .accepted
                    print("[FMUserInfo Accept Request Successfully]")
                } else {
                    self.lblMsgSent.text = "Accept Request Fail!"
                    print("[FMUserInfo Accept Request Fail] - \(status) \(message!)")
                }
                self.indicatorView.stopAnimating()
                self.animationActionView()
            }
            break
        case IGNORE_ACT:
            faeContact.ignoreFriendRequest(requestId: String(requestId)) {(status: Int, message: Any?) in
                if status / 100 == 2 {
                    self.lblMsgSent.text = "Ignore Request Successfully!"
                    self.statusMode = .defaultMode
                } else {
                    self.lblMsgSent.text = "Ignore Request Fail!"
                    print("[FMUserInfo Ignore Request Fail] - \(status) \(message!)")
                }
                self.indicatorView.stopAnimating()
                self.animationActionView()
            }
            break
        case REMOVE_FRIEND_ACT:
            faeContact.deleteFriend(userId: String(userId)) {(status: Int, message: Any?) in
                if status / 100 == 2 {
                    self.lblMsgSent.text = "Remove Friend Successfully!"
                    self.statusMode = .defaultMode
                } else {
                    self.lblMsgSent.text = "Remove Friend Fail!"
                    print("[FMUserInfo Delete Friend Fail] - \(status) \(message!)")
                }
                self.indicatorView.stopAnimating()
                self.animationActionView()
            }
            break
        case BLOCK_ACT:
            faeContact.blockPerson(userId: String(userId)) {(status: Int, message: Any?) in
                if status / 100 == 2 {
                    self.lblMsgSent.text = "Block Friend Successfully!"
                    self.statusMode = .blocked
                } else {
                    self.lblMsgSent.text = "Block Friend Fail!"
                    print("[FMUserInfo Friend Block Fail] - \(status) \(message!)")
                }
                self.indicatorView.stopAnimating()
                self.animationActionView()
            }
            break
        case REPORT_ACT:
            self.indicatorView.stopAnimating()
            let reportPinVC = ReportViewController()
            reportPinVC.reportType = 0
            reportPinVC.modalPresentationStyle = .overCurrentContext
            self.present(reportPinVC, animated: true, completion: nil)
            break
        default:
            break
        }
    }
    
    func actionCancel(_ sender: UIButton) {
        delegate?.passFriendStatusFromView(status: statusMode)
        animationHideSelf()
    }
    
    func actionFinish(_ sender: UIButton!) {
        delegate?.passFriendStatusFromView(status: statusMode)
        animationHideSelf()
    }
    // actions end
    
    // animations
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
    // animations end
}

