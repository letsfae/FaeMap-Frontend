//
//  AddFriendFromNameCardViewController.swift
//  faeBeta
//
//  Created by Vicky on 2017-10-26.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit
import SwiftyJSON

protocol FriendOperationFromContactsDelegate: class {
    func passFriendStatusBack(indexPath: IndexPath)
}

class FriendOperationFromContactsViewController: UIViewController {
    weak var delegate: FriendOperationFromContactsDelegate?
    var uiviewChooseAction: UIView!
    var uiviewMsgSent: UIView!
    var btnIgnore: UIButton!
    var btnBlock: UIButton!
    var btnReport: UIButton!
    var btnOK: UIButton!
    var btnCancel:UIButton!
    var btnFriendSentBack: UIButton!
    var lblChoose: UILabel!
    var lblMsgSent: UILabel!
    var lblBlockHint: UILabel!
    var indicatorView: UIActivityIndicatorView!
    var indexPath: IndexPath!
    
    var userId: Int = -1
    let faeContact = FaeContact()
    var requestId: Int = -1
    
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
    var action: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(r: 107, g: 105, b: 105, alpha: 70)
        view.alpha = 0
        createActivityIndicator()
        loadContent()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(actionCancel(_:)))
        view.addGestureRecognizer(tapGesture)
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
        uiviewChooseAction = UIView(frame: CGRect(x: 0, y: 200, w: 290, h: 302))
        uiviewChooseAction.center.x = screenWidth / 2
        uiviewChooseAction.backgroundColor = .white
        uiviewChooseAction.layer.cornerRadius = 20
        view.addSubview(uiviewChooseAction)
        uiviewChooseAction.alpha = 0
        
        lblChoose = UILabel(frame: CGRect(x: 0, y: 20, w: 290, h: 25))
        lblChoose.textAlignment = .center
        lblChoose.text = "Choose an Action"
        lblChoose.textColor = UIColor._898989()
        lblChoose.font = UIFont(name: "AvenirNext-Medium", size: 18 * screenHeightFactor)
        uiviewChooseAction.addSubview(lblChoose)
        
        btnIgnore = UIButton(frame: CGRect(x: 41, y: 65, w: 208, h: 50))
        btnIgnore.tag = IGNORE_ACT
        btnIgnore.setTitle("Ignore", for: .normal)
        btnBlock = UIButton(frame: CGRect(x: 41, y: 130, w: 208, h: 50))
        btnBlock.tag = BLOCK_ACT
        btnBlock.setTitle("Block", for: .normal)
        btnReport = UIButton(frame: CGRect(x: 41, y: 195, w: 208, h: 50))
        btnReport.tag = REPORT_ACT
        btnReport.setTitle("Report", for: .normal)
        
        var btnActions = [UIButton]()
        btnActions.append(btnIgnore)
        btnActions.append(btnBlock)
        btnActions.append(btnReport)
        
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
        uiviewMsgSent.alpha = 0
        
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
        btnOK.setTitle("OK", for: .normal)
        let padding = (290 - 208) / 2 * screenWidthFactor
        uiviewMsgSent.addConstraintsWithFormat("H:|-\(padding)-[v0]-\(padding)-|", options: [], views: btnOK)
        uiviewMsgSent.addConstraintsWithFormat("V:[v0(\(39 * screenHeightFactor))]-\(20 * screenHeightFactor)-|", options: [], views: btnOK)
        
        uiviewMsgSent.addSubview(lblMsgSent)
        uiviewMsgSent.addSubview(btnFriendSentBack)
        view.addSubview(uiviewMsgSent)
    }
    
    fileprivate func getFriendStatus() {
        animationShowSelf()
        if action == "add" {
            indicatorView.startAnimating()
            faeContact.sendFriendRequest(friendId: String(self.userId)) {(status: Int, message: Any?) in
                if status / 100 == 2 {
                    self.lblMsgSent.text = "Friend Request \nSent Successfully!"
                    self.delegate?.passFriendStatusBack(indexPath: self.indexPath)
                } else if status == 400 {
                    // 400-22  Bad request, this user has already sent you a friend request
                    // 400-20  Bad request, you have already sent a request
                    // 400-6   Bad request, you have already blocked this user
                    // 400-6   Bad request, you have already been blocked by the user
                    let errorCode = JSON(message!)["error_code"].string
                    if  errorCode == "400-20" {
                        self.lblMsgSent.text = "You've Already \nSent Friend Request!"
                    } else if errorCode == "400-22" {
                        self.lblMsgSent.text = "The User Has Already \nSent You a Friend Request!"
                    } else if errorCode == "400-6" {
                        self.lblMsgSent.text = "Friend Request \nSent Fail!" // [BLOCK]
                    } else {
                        self.lblMsgSent.text = "Friend Request \nError!"
                    }
                } else {
                    self.lblMsgSent.text = "Friend Request \nSent Fail!"
                    print("[Friend Request Sent Fail] - \(status) \(message!)")
                }
                self.btnOK.tag = self.OK
                self.btnOK.setTitle("OK", for: .normal)
                self.indicatorView.stopAnimating()
                self.animationActionView()
            }
        } else if action == "accept" {
            indicatorView.startAnimating()
            faeContact.acceptFriendRequest(requestId: String(requestId)) { (status: Int, message: Any?) in
                if status / 100 == 2 {
                    self.lblMsgSent.text = "Accept Request \nSuccessfully!"
                    self.delegate?.passFriendStatusBack(indexPath: self.indexPath)
                } else {
                    self.lblMsgSent.text = "Accept Request \nFail!"
                    print("[Accept Request Fail] - \(status) \(message!)")
                }
                self.btnOK.tag = self.OK
                self.btnOK.setTitle("OK", for: .normal)
                self.indicatorView.stopAnimating()
                self.animationActionView()
            }
            
        } else if action == "resend" {
            btnOK.setTitle("Yes", for: .normal)
            lblMsgSent.text = "Are you sure you want \nto resend this request?"
            btnOK.tag = RESEND_ACT
            animationActionView()
        } else if action == "withdraw" {
            btnOK.setTitle("Yes", for: .normal)
            lblMsgSent.text = "Are you sure you want \nto withdraw this request?"
            btnOK.tag = WITHDRAW_ACT
            animationActionView()
        }
    }
    
    // actions
    @objc func sentActRequest(_ sender: UIButton!) {
        if sender.tag == IGNORE_ACT {
            indicatorView.startAnimating()
            faeContact.ignoreFriendRequest(requestId: String(requestId)) {(status: Int, message: Any?) in
                if status / 100 == 2 {
                    self.lblMsgSent.text = "Ignore Request \nSuccessfully!"
                    self.delegate?.passFriendStatusBack(indexPath: self.indexPath)
                } else {
                    self.lblMsgSent.text = "Ignore Request \nFail!"
                    print("[Ignore Request Fail] - \(status) \(message!)")
                }
                self.btnOK.tag = self.OK
                self.btnOK.setTitle("OK", for: .normal)
                self.indicatorView.stopAnimating()
                self.animationActionView()
            }
        } else if sender.tag == REPORT_ACT {
            let reportPinVC = ReportViewController()
            reportPinVC.reportType = 0
            reportPinVC.modalPresentationStyle = .overCurrentContext
            self.present(reportPinVC, animated: true, completion: nil)
        } else if sender.tag == BLOCK_ACT {
            animationActionView()
            btnOK.setTitle("Yes", for: .normal)
            btnOK.tag = BLOCK_ACT
            lblMsgSent.text = "Are you sure you want \nto block this request?"
            uiviewMsgSent.frame.size.height = 208 * screenHeightFactor
            lblBlockHint.isHidden = false
        }
    }
    
    @objc func actionCancel(_ sender: Any?) {
        animationHideSelf()
    }
    
    @objc func actionFinish(_ sender: UIButton!) {
        animationHideSelf()
    }
    
    @objc func actionOK(_ sender: UIButton) {
        uiviewMsgSent.frame.size.height = 161 * screenHeightFactor
        if sender.tag == OK {
            animationHideSelf()
        } else {
            indicatorView.startAnimating()
            if sender.tag == WITHDRAW_ACT {
                faeContact.withdrawFriendRequest(requestId: String(requestId)) {(status: Int, message: Any?) in
                    if status / 100 == 2 {
                        self.lblMsgSent.text = "Request Withdraw \nSuccessfully!"
                        self.delegate?.passFriendStatusBack(indexPath: self.indexPath)
                    } else if status == 404 {
                        self.lblMsgSent.text = "You haven't Sent \nFriend Request!"
                    } else {
                        self.lblMsgSent.text = "Request Withdraw \nFail!"
                        print("[Request Withdraw Fail] - \(status) \(message!)")
                    }
                    self.btnOK.tag = self.OK
                    self.btnOK.setTitle("OK", for: .normal)
                    self.indicatorView.stopAnimating()
                    self.animationActionView()
                }
            } else if sender.tag == RESEND_ACT {
                faeContact.sendFriendRequest(friendId: String(userId), boolResend: "true") {(status: Int, message: Any?) in
                    if status / 100 == 2 {
                        self.lblMsgSent.text = "Request Resent \nSuccessfully!"
                    } else if status == 400 {
                        let errorCode = JSON(message!)["error_code"].string
                        if  errorCode == "400-20" {
                            self.lblMsgSent.text = "You've Already \nSent Friend Request!"
                        } else if errorCode == "400-22" {
                            self.lblMsgSent.text = "The User Has Already \nSent You a Friend Request!"
                        } else if errorCode == "400-6" {
                            self.lblMsgSent.text = "Friend Request Sent \nFail!" // [BLOCK]
                            self.statusMode = .blocked
                        } else {
                            self.lblMsgSent.text = "Friend Request \nError!"
                        }
                    } else {
                        self.lblMsgSent.text = "Request Resent \nFail!"
                        print("[FMUserInfo Friend Request Resent Fail] - \(status) \(message!)")
                    }
                    self.btnOK.tag = self.OK
                    self.btnOK.setTitle("OK", for: .normal)
                    self.indicatorView.stopAnimating()
                    self.animationActionView()
                }
            } else if sender.tag == BLOCK_ACT {
                lblBlockHint.isHidden = true
                uiviewMsgSent.frame.size.height = 161 * screenHeightFactor
                faeContact.blockPerson(userId: String(userId)) {(status: Int, message: Any?) in
                    if status / 100 == 2 {
                        self.lblMsgSent.text = "The user has been \nblocked successfully!"
                        self.delegate?.passFriendStatusBack(indexPath: self.indexPath)
                    } else {
                        self.lblMsgSent.text = "Block User \nFail!"
                        print("[Block Friend Fail] - \(status) \(message!)")
                    }
                    self.btnOK.tag = self.OK
                    self.btnOK.setTitle("OK", for: .normal)
                    self.indicatorView.stopAnimating()
                    self.animationActionView()
                }
            }
        }
    }
    // actions end
    
    // animations
    func animationActionView() {
        uiviewChooseAction.isHidden = true
        uiviewChooseAction.alpha = 0
        uiviewMsgSent.alpha = 0
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut, animations: {
            self.uiviewMsgSent.alpha = 1
        }, completion: nil)
    }
    
    func animationShowSelf() {
        view.alpha = 0
        uiviewChooseAction.alpha = 0
        uiviewMsgSent.alpha = 0
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut, animations: {
            self.view.alpha = 1
            if self.action == "ignore" {
                self.uiviewChooseAction.alpha = 1
            } else {
                if self.action == "resend" || self.action == "withdraw" {
                    self.uiviewMsgSent.alpha = 1
                }
            }
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


