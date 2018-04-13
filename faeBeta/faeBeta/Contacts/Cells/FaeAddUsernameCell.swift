//
//  FaeAddUsernameCell.swift
//  FaeContacts
//
//  Created by Justin He on 6/20/17.
//  Copyright © 2017 Yue. All rights reserved.
//

import UIKit
import SwiftyJSON
import RealmSwift

protocol FaeAddUsernameDelegate: class {
    func addFriend(indexPath: IndexPath, user_id: Int)
    func resendRequest(indexPath: IndexPath, user_id: Int)
    func acceptRequest(indexPath: IndexPath, user_id: Int)
    func ignoreRequest(indexPath: IndexPath, user_id: Int)
    func withdrawRequest(indexPath: IndexPath, user_id: Int)
}

class FaeAddUsernameCell: UITableViewCell {
    
    var userId: Int = -1
    var imgAvatar: UIImageView!
    var lblUserName: UILabel!
    var lblUserSaying: UILabel!
    var bottomLine: UIView!
    var hasAddedFriend = false
    var friendStatus: FriendStatus = .defaultMode
    var btnAddorAdded: UIButton! // btn that can substitute as the add button or the "added" button.
    var btnAcceptRequest: UIButton!
    var btnRefuseRequest: UIButton!
    var lblStatus: UILabel!
    var faeContact = FaeContact()
    var indexPath: IndexPath!
    weak var delegate: FaeAddUsernameDelegate!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        separatorInset = UIEdgeInsets.zero
        layoutMargins = UIEdgeInsets.zero
        selectionStyle = .none
        loadCellContent()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        friendStatus = .defaultMode
        lblStatus.text = ""
        btnAddorAdded.setImage(nil, for: .normal)
        btnAcceptRequest.setImage(nil, for: .normal)
        btnRefuseRequest.setImage(nil, for: .normal)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func getFriendStatus(id: Int) {
        if id == Key.shared.user_id {
            friendStatus = .blocked_by
        }
        let realm = try! Realm()
        if let user = realm.filterUser(id: id) {
            if user.relation & IS_FRIEND == IS_FRIEND {
                friendStatus = .accepted
            } else if user.relation & FRIEND_REQUESTED == FRIEND_REQUESTED {
                friendStatus = .pending
            } else if user.relation & FRIEND_REQUESTED_BY == FRIEND_REQUESTED_BY {
                friendStatus = .requested
            }
            if user.relation & BLOCKED == BLOCKED {
                friendStatus = .blocked
            } else if user.relation & BLOCKED_BY == BLOCKED_BY {
                friendStatus = .blocked_by
            }
            setButtonImage()
        }
        /*FaeUser().getUserRelation(String(id)) { (status: Int, message: Any?) in
            if status / 100 == 2 {
                let json = JSON(message!)
                let relation = Relations(json: json)
                self.getFromRelations(id: id, relation: relation)                
            } else {
                print("[get friend status fail] - \(status) \(message!)")
            }
        }*/
    }
    
    func getFromRelations(id: Int, relation: Relations) {
        var realationRealm = NO_RELATION
        if id == Key.shared.user_id {
            self.friendStatus = .blocked_by
        }
//        print(relation)
        if relation.blocked {   // blocked & blocked_by
            self.friendStatus = .blocked
            if relation.is_friend {
                realationRealm = BLOCKED | IS_FRIEND
            } else {
                realationRealm = BLOCKED
            }
        } else if relation.blocked_by {
            if relation.is_friend {
                self.friendStatus = .accepted
                realationRealm = BLOCKED_BY | IS_FRIEND
            } else {
                self.friendStatus = .blocked_by
                realationRealm = BLOCKED_BY
            }
        } else if relation.is_friend {
            self.friendStatus = .accepted
            realationRealm = IS_FRIEND
        } else if relation.requested {
            self.friendStatus = .pending
            realationRealm = FRIEND_REQUESTED
        } else if relation.requested_by {
            self.friendStatus = .requested
            realationRealm = FRIEND_REQUESTED_BY
        }
        
        self.setButtonImage()
        let realm = try! Realm()
        if let user = realm.filterUser(id: "\(id)") {
            try! realm.write {
                user.relation = realationRealm
            }
        }
    }
    
    fileprivate func setButtonImage() {
        switch friendStatus {
        case .defaultMode:
            lblStatus.text = ""
            btnAddorAdded.setImage(#imageLiteral(resourceName: "addButton"), for: .normal)
            btnAddorAdded.isHidden = false
            btnAcceptRequest.isHidden = true
            btnRefuseRequest.isHidden = true
        case .accepted:
            lblStatus.text = "Friends"
            btnAddorAdded.isHidden = true
            btnAcceptRequest.isHidden = true
            btnRefuseRequest.isHidden = true
        case .pending:
            lblStatus.text = ""
            btnAddorAdded.isHidden = true
            btnAcceptRequest.isHidden = false
            btnRefuseRequest.isHidden = false
            btnAcceptRequest.setImage(#imageLiteral(resourceName: "resendRequest"), for: .normal)
            btnRefuseRequest.setImage(#imageLiteral(resourceName: "cancelRequest"), for: .normal)
        case .requested:
            lblStatus.text = ""
            btnAddorAdded.isHidden = true
            btnAcceptRequest.isHidden = false
            btnRefuseRequest.isHidden = false
            btnAcceptRequest.setImage(#imageLiteral(resourceName: "acceptRequest"), for: .normal)
            btnRefuseRequest.setImage(#imageLiteral(resourceName: "cancelRequest"), for: .normal)
        case .blocked:
            lblStatus.text = "Blocked"
            btnAddorAdded.isHidden = true
            btnAcceptRequest.isHidden = true
            btnRefuseRequest.isHidden = true
        case .blocked_by:
            lblStatus.text = ""
            btnAddorAdded.isHidden = true
            btnAcceptRequest.isHidden = true
            btnRefuseRequest.isHidden = true
        default: break
        }
    }
    
    fileprivate func loadCellContent() {
        imgAvatar = UIImageView()
        imgAvatar.frame = CGRect(x: 14, y: 12, width: 50, height: 50)
        imgAvatar.image = #imageLiteral(resourceName: "defaultMen")
        imgAvatar.layer.cornerRadius = 25
        imgAvatar.contentMode = .scaleAspectFill
        imgAvatar.clipsToBounds = true
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
        btnAddorAdded.addTarget(self, action: #selector(self.changeButtonPic(_:)), for: .touchUpInside)
        addSubview(btnAddorAdded)
        addConstraintsWithFormat("V:|-26-[v0(29)]", options: [], views: btnAddorAdded)
        addConstraintsWithFormat("H:[v0(74)]-17-|", options: [], views: btnAddorAdded)
        
        addConstraintsWithFormat("V:|-17-[v0(22)]-0-[v1(20)]", options: [], views: lblUserName, lblUserSaying)
        
        bottomLine = UIView()
        bottomLine.backgroundColor = UIColor._200199204()
        addSubview(bottomLine)
        bottomLine.isHidden = false
        addConstraintsWithFormat("H:|-73-[v0]-0-|", options: [], views: bottomLine)
        addConstraintsWithFormat("V:[v0(1)]-0-|", options: [], views: bottomLine)
        
        btnAcceptRequest = UIButton()
        btnAcceptRequest.isHidden = true
        addSubview(btnAcceptRequest)
        btnAcceptRequest.addTarget(self, action: #selector(self.acceptResendRequest(_:)), for: .touchUpInside)
        
        btnRefuseRequest = UIButton()
        addSubview(btnRefuseRequest)
        btnRefuseRequest.isHidden = true
        btnRefuseRequest.addTarget(self, action: #selector(self.refuseWithdrawRequest(_:)), for: .touchUpInside)
        addConstraintsWithFormat("V:|-15-[v0]-15-|", options: [], views: btnAcceptRequest)
        addConstraintsWithFormat("V:|-15-[v0]-15-|", options: [], views: btnRefuseRequest)
        addConstraintsWithFormat("H:[v0(48)]-15-[v1(48)]-10-|", options: [], views:btnRefuseRequest, btnAcceptRequest)
        
        lblStatus = FaeLabel(CGRect(x: screenWidth - 65, y: 29, width: 50, height: 18), .right, .demiBold, 13, UIColor._155155155())
        addSubview(lblStatus)
    }
    
    func setValueForCell(user: UserNameCard) {
        General.shared.avatar(userid: user.userId, completion: { (avatarImage) in
            self.imgAvatar.image = avatarImage
        })
        lblUserName.text = user.displayName
        lblUserSaying.text = user.userName
    }
    
    @objc func changeButtonPic(_ sender: UIButton) {
        if sender.currentImage == #imageLiteral(resourceName: "addButton") {
            delegate.addFriend(indexPath: indexPath, user_id: userId)
        }
    }
    
    @objc func acceptResendRequest(_ sender: UIButton) {
        if friendStatus == .pending {
            delegate.resendRequest(indexPath: indexPath, user_id: userId)
        } else {
            delegate.acceptRequest(indexPath: indexPath, user_id: userId)
        }
    }
    
    @objc func refuseWithdrawRequest(_ sender: UIButton) {
        if friendStatus == .pending {
            delegate.withdrawRequest(indexPath: indexPath, user_id: userId)
        } else {
            delegate.ignoreRequest(indexPath: indexPath, user_id: userId)
        }
    }
}
