//
//  FaeAddUsernameCell.swift
//  FaeContacts
//
//  Created by Justin He on 6/20/17.
//  Copyright © 2017 Yue. All rights reserved.
//

import UIKit
import SwiftyJSON

class FaeAddUsernameCell: UITableViewCell {
    
    var userId: Int = -1
    var requestId: Int = -1
    var imgAvatar: UIImageView!
    var lblUserName: UILabel!
    var lblUserSaying: UILabel!
    var bottomLine: UIView!
    var isFriend = false
    var hasAddedFriend = false
    var friendStatus: FriendStatus = .defaultMode
    var btnAddorAdded: UIButton! // btn that can substitute as the add button or the "added" button.
    var btnAcceptRequest: UIButton!
    var btnRefuseRequest: UIButton!
    var faeContact = FaeContact()
    init(style: UITableViewCellStyle, reuseIdentifier: String?, isFriend: Bool?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        separatorInset = UIEdgeInsets.zero
        layoutMargins = UIEdgeInsets.zero
        selectionStyle = .none
        loadRecommendedCellContent()
//        getFriendStatus(id: userId)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func getFriendStatus(id: Int) {
        friendStatus = .defaultMode
        faeContact.getFriends() {(status: Int, message: Any?) in
            if status / 100 == 2 {
                let json = JSON(message!)
                if json.count != 0 {
                    for i in 0..<json.count {
                        print("json_id \(json[i]["friend_id"].intValue)")
                        if json[i]["friend_id"].intValue == id {
                            self.friendStatus = .accepted
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
                            self.friendStatus = .pending
                            self.requestId = json[i]["friend_request_id"].intValue
                            break
                        }
                    }
                }
                self.setButtonImage()
            } else {
                print("[FMUserInfo get requested friends list fail] - \(status) \(message!)")
            }
        }
        
        faeContact.getFriendRequests() {(status: Int, message: Any?) in
            if status / 100 == 2 {
                let json = JSON(message!)
                if json.count != 0 {
                    for i in 0..<json.count {
                        if json[i]["request_user_id"].intValue == id {
                            self.friendStatus = .requested
                            self.requestId = json[i]["friend_request_id"].intValue
                            break
                        }
                    }
                }
                self.setButtonImage()
            } else {
                print("[FMUserInfo get request friends list fail] - \(status) \(message!)")
            }
        }
    }
    
    fileprivate func setButtonImage() {
        print(self.userId)
        print("friendStatus \(friendStatus)")
        switch friendStatus {
        case .defaultMode:
            btnAddorAdded.isHidden = false
            btnAcceptRequest.isHidden = true
            btnRefuseRequest.isHidden = true
            break
        case .accepted:
            btnAddorAdded.isHidden = true
            btnAcceptRequest.isHidden = true
            btnRefuseRequest.isHidden = true
            break
        case .pending:
            btnAddorAdded.isHidden = true
            btnAcceptRequest.isHidden = false
            btnRefuseRequest.isHidden = false
            btnAcceptRequest.setImage(#imageLiteral(resourceName: "resendRequest"), for: .normal)
            break
        case .requested:
            btnAddorAdded.isHidden = true
            btnAcceptRequest.isHidden = false
            btnRefuseRequest.isHidden = false
            btnAcceptRequest.setImage(#imageLiteral(resourceName: "acceptRequest"), for: .normal)
            break
        case .blocked:
            btnAddorAdded.isHidden = true
            btnAcceptRequest.isHidden = true
            btnRefuseRequest.isHidden = true
            break
        default:
            break
        }
    }
    
    fileprivate func loadRecommendedCellContent() {
        imgAvatar = UIImageView()
        imgAvatar.frame = CGRect(x: 14, y: 12, width: 50, height: 50)
        imgAvatar.image = #imageLiteral(resourceName: "defaultMen")
        imgAvatar.layer.cornerRadius = 25
        imgAvatar.contentMode = .scaleAspectFill
        imgAvatar.clipsToBounds = true
        //imgAvatar.backgroundColor = .red
        addSubview(imgAvatar)
        
        lblUserName = UILabel()
        lblUserName.textAlignment = .left
        lblUserName.textColor = UIColor._898989()
        lblUserName.font = UIFont(name: "AvenirNext-Medium", size: 18)
        addSubview(lblUserName)
        addConstraintsWithFormat("H:|-86-[v0]-173-|", options: [], views: lblUserName)
        
        lblUserSaying = UILabel()
        lblUserSaying.textAlignment = .left
        lblUserSaying.textColor = UIColor._155155155()
        lblUserSaying.font = UIFont(name: "AvenirNext-Medium", size: 13)
        addSubview(lblUserSaying)
        addConstraintsWithFormat("H:|-86-[v0]-173-|", options: [], views: lblUserSaying)
        
        btnAddorAdded = UIButton()
        btnAddorAdded.setImage(#imageLiteral(resourceName: "addButton"), for: .normal)

        btnAddorAdded.addTarget(self, action: #selector(self.changeButtonPic(_:)), for: .touchUpInside)
        addSubview(btnAddorAdded)
        addConstraintsWithFormat("V:|-26-[v0(29)]", options: [], views: btnAddorAdded)
        addConstraintsWithFormat("H:[v0(74)]-17-|", options: [], views: btnAddorAdded)
        
        addConstraintsWithFormat("V:|-17-[v0(22)]-0-[v1(20)]", options: [], views: lblUserName, lblUserSaying)
        
        bottomLine = UIView()
        bottomLine.backgroundColor = UIColor._200199204()
        addSubview(bottomLine)
        addConstraintsWithFormat("H:|-73-[v0]-0-|", options: [], views: bottomLine)
        addConstraintsWithFormat("V:[v0(1)]-0-|", options: [], views: bottomLine)
        
        btnAcceptRequest = UIButton()
        btnAcceptRequest.isHidden = true
        addSubview(btnAcceptRequest)
        btnAcceptRequest.addTarget(self, action: #selector(self.acceptResendRequest(_:)), for: .touchUpInside)
        
        btnRefuseRequest = UIButton()
        addSubview(btnRefuseRequest)
        btnRefuseRequest.setImage(#imageLiteral(resourceName: "cancelRequest"), for: .normal)
        btnRefuseRequest.isHidden = true
        btnRefuseRequest.addTarget(self, action: #selector(self.refuseWithdrawRequest(_:)), for: .touchUpInside)
        addConstraintsWithFormat("V:|-15-[v0]-15-|", options: [], views: btnAcceptRequest)
        addConstraintsWithFormat("V:|-15-[v0]-15-|", options: [], views: btnRefuseRequest)
        addConstraintsWithFormat("H:[v0(48)]-15-[v1(48)]-10-|", options: [], views:btnRefuseRequest, btnAcceptRequest)
    }
    
    func setValueForCell(user: MBPeopleStruct) {
        General.shared.avatar(userid: user.userId, completion: { (avatarImage) in
            self.imgAvatar.image = avatarImage
        })
        lblUserName.text = user.displayName
        lblUserSaying.text = user.userName
        
        setButtonImage()
    }
    
    func changeButtonPic(_ sender: UIButton) {
        if sender.currentImage == #imageLiteral(resourceName: "addButton") {
            friendStatus = .pending
            setButtonImage()
        }
    }
    
    func acceptResendRequest(_ sender: UIButton) {
        if friendStatus == .pending {   // sent request
            print("resend")
        } else {   // receive request
            print("accept")
        }
    }
    
    func refuseWithdrawRequest(_ sender: UIButton) {
        if friendStatus == .pending {   // sent request
            print("withdraw")
        } else {   // receive request
            print("refuse")
        }
    }
}
