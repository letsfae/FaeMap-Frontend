//
//  JustinHe.swift
//  FaeContacts
//
//  Created by Justin He on 6/13/17.
//  Copyright © 2017 Yue. All rights reserved.
//

import UIKit
import SwiftyJSON
import RealmSwift

extension ContactsViewController {
    
    // MARK: Setup UI
    func loadSearchBar() {
        uiviewSchbar = UIView(frame: CGRect(x: 0, y: 65 + device_offset_top, width: screenWidth, height: 49))
        view.addSubview(uiviewSchbar)
        
        schbarContacts = FaeSearchBarTest(frame: CGRect(x: 5, y: 0, width: screenWidth, height: 48))
        schbarContacts.txtSchField.placeholder = "Search Friends"
        schbarContacts.delegate = self
        uiviewSchbar.addSubview(schbarContacts)
        
        let bottomLine = UIView(frame: CGRect(x: 0, y: 48, width: screenWidth, height: 1))
        bottomLine.layer.borderWidth = 1
        bottomLine.layer.borderColor = UIColor._200199204cg()
        uiviewSchbar.addSubview(bottomLine)
    }
    
    func loadTable() {
        tblContacts = UITableView()
        tblContacts.frame = CGRect(x: 0, y: 114 + device_offset_top, width: screenWidth, height: screenHeight - 114 - device_offset_top)
        tblContacts.dataSource = self
        tblContacts.delegate = self
        tblContacts.separatorStyle = .none
        tblContacts.showsVerticalScrollIndicator = false
        automaticallyAdjustsScrollViewInsets = false
        tblContacts.addGestureRecognizer(tapDismissGestureOnDropdownMenu())
  
        tblContacts.register(FaeContactsCell.self, forCellReuseIdentifier: "FaeContactsCell")
        tblContacts.register(FaeRequestedCell.self, forCellReuseIdentifier: "FaeRequestedCell")
        tblContacts.register(FaeReceivedCell.self, forCellReuseIdentifier: "FaeReceivedCell")
        view.addSubview(tblContacts)
    }
    
    func loadTabView() {
        uiviewBottomNav = UIView(frame: CGRect(x: 0, y: screenHeight - 49 - device_offset_bot, width: screenWidth, height: 49 + device_offset_bot))
        uiviewBottomNav.addGestureRecognizer(tapDismissGestureOnDropdownMenu())
        view.addSubview(uiviewBottomNav)
        uiviewBottomNav.isHidden = true
        
        let line = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 1))
        line.backgroundColor = UIColor._200199204()
        uiviewBottomNav.addSubview(line)
        
        btnFFF = UIButton()
        btnFFF.setAttributedTitle(NSAttributedString(string: "Received", attributes: [NSAttributedStringKey.foregroundColor: UIColor._146146146(), NSAttributedStringKey.font: UIFont(name: "AvenirNext-Regular", size: 18)!]), for: .normal)
        btnFFF.setAttributedTitle(NSAttributedString(string: "Received", attributes: [NSAttributedStringKey.foregroundColor: UIColor._2499090(), NSAttributedStringKey.font: UIFont(name: "AvenirNext-DemiBold", size: 18)!]), for: .selected)
        btnFFF.isSelected = true
        btnFFF.addTarget(self, action: #selector(pressbtnFFF(button:)), for: .touchUpInside)
        btnFFF.imageEdgeInsets = UIEdgeInsetsMake(0, 40, 0, 0)
        uiviewBottomNav.addSubview(btnFFF)
        uiviewBottomNav.addConstraintsWithFormat("H:|-0-[v0]-" + String(describing: screenWidth / 2) + "-|", options: [], views: btnFFF)
        uiviewBottomNav.addConstraintsWithFormat("V:|-0-[v0]-\(device_offset_bot)-|", options: [], views: btnFFF)
        
        btnRR = UIButton()
        btnRR.setAttributedTitle(NSAttributedString(string: "Requested", attributes: [NSAttributedStringKey.foregroundColor: UIColor._146146146(), NSAttributedStringKey.font: UIFont(name: "AvenirNext-Regular", size: 18)!]), for: .normal)
        btnRR.setAttributedTitle(NSAttributedString(string: "Requested", attributes: [NSAttributedStringKey.foregroundColor: UIColor._2499090(), NSAttributedStringKey.font: UIFont(name: "AvenirNext-DemiBold", size: 18)!]), for: .selected)
        btnRR.addTarget(self, action: #selector(pressbtnRR(button:)), for: .touchUpInside)
        btnRR.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 40)
        uiviewBottomNav.addSubview(btnRR)
        uiviewBottomNav.addConstraintsWithFormat("H:|-\(screenWidth / 2)-[v0]-0-|", options: [], views: btnRR)
        uiviewBottomNav.addConstraintsWithFormat("V:|-0-[v0]-\(device_offset_bot)-|", options: [], views: btnRR)
    }
    
    func loadNameCard() {
        view.addSubview(uiviewNameCard)
        uiviewNameCard.delegate = self
    }
    
    // MARK: Bottom button functionalities
    @objc func pressbtnFFF(button: UIButton) {
        if btnRR.isSelected {
            btnRR.isSelected = false
            btnFFF.isSelected = true
        }
        cellStatus = 1
        switchRealmObserverTarget()
    }
    
    @objc func pressbtnRR(button: UIButton) {
        if btnFFF.isSelected {
            btnFFF.isSelected = false
            btnRR.isSelected = true
        }
        cellStatus = 2
        switchRealmObserverTarget()
    }

    func reloadAfterDelete() {
        tblContacts.performUpdate({
            self.tblContacts.deleteRows(at: [indexPathGlobal], with: UITableViewRowAnimation.right)
        }) {
            self.tblContacts.reloadData()
            self.setupScrollBar()
        }
    }
}

// MARK: - NameCardDelegate
extension ContactsViewController: NameCardDelegate {
    func openFaeUsrInfo() {
        let fmUsrInfo = FMUserInfo()
        fmUsrInfo.userId = uiviewNameCard.userId
        uiviewNameCard.hideSelf()
        navigationController?.pushViewController(fmUsrInfo, animated: true)
    }
    
    func chatUser(id: Int) {
        uiviewNameCard.hideSelf()
        let vcChat = ChatViewController()
        vcChat.arrUserIDs.append("\(Key.shared.user_id)")
        vcChat.arrUserIDs.append("\(id)")
        vcChat.strChatId = "\(id)"
        navigationController?.pushViewController(vcChat, animated: true)
    }
    
    func reportUser(id: Int) {
        let reportPinVC = ReportViewController()
        reportPinVC.reportType = 0
        present(reportPinVC, animated: true, completion: nil)
    }
    
    func openAddFriendPage(userId: Int, status: FriendStatus) {
        let addFriendVC = AddFriendFromNameCardViewController()
        addFriendVC.delegate = uiviewNameCard
        addFriendVC.contactsDelegate = self
        addFriendVC.userId = userId
        addFriendVC.statusMode = status
        addFriendVC.modalPresentationStyle = .overCurrentContext
        present(addFriendVC, animated: false)
    }
}

// MARK: - AddFriendFromNameCardDelegate
extension ContactsViewController: AddFriendFromNameCardDelegate {
    func changeContactsTable(action: Int, userId: Int) {
        felixprint("changeContactsTable")
        uiviewNameCard.hide { }
    }
}

// MARK: - FaeSearchBarTestDelegate
extension ContactsViewController: FaeSearchBarTestDelegate {
    func searchBar(_ searchBar: FaeSearchBarTest, textDidChange searchText: String) {
        filter(searchText: searchText)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: FaeSearchBarTest) {
        schbarContacts.txtSchField.becomeFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: FaeSearchBarTest) {
        schbarContacts.txtSchField.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: FaeSearchBarTest) {
        schbarContacts.txtSchField.resignFirstResponder()
    }
    
    // helper - search on friend list
    func filter(searchText: String, scope: String = "All") {
        filteredRealm = realmFriends.filter({ ($0.display_name).lowercased().range(of: searchText.lowercased()) != nil })
        tblContacts.reloadData()
    }
}

// MARK: - Received & Requested requests delegate
extension ContactsViewController: ContactsReceivedRequestsDelegate, ContactsRequestedDelegate {
    // MARK: ContactsReceivedRequestsDelegate
    func refuseRequest(userId: Int, indexPath: IndexPath) {
        btnYes.tag = IGNORE
        indexPathGlobal = indexPath
        idGlobal = userId
        chooseAnAction()
    }
    
    func acceptRequest(userId: Int, indexPath: IndexPath) {
        indexPathGlobal = indexPath
        idGlobal = userId
        indicatorView.startAnimating()
        animateWithdrawal(listType: ACCEPT)
    }
    
    // MARK: ContactsRequestedDelegate
    func withdrawRequest(userId: Int, indexPath: IndexPath) {
        btnYes.tag = WITHDRAW
        indexPathGlobal = indexPath
        idGlobal = userId
        showNoti(type: WITHDRAW)
    }
    
    func resendRequest(userId: Int, indexPath: IndexPath) {
        btnYes.tag = RESEND
        indexPathGlobal = indexPath
        idGlobal = userId
        showNoti(type: RESEND)
    }
    
    // MARK: Contact actions
    func animateWithdrawal(listType: Int) {
        switch listType {
        case WITHDRAW:
            apiCalls.withdrawFriendRequest(friendId: String(idGlobal)) { [weak self] (status: Int, message: Any?) in
                guard let `self` = self else { return }
                if status / 100 == 2 {
                    self.lblNotificationText.text = "Request Withdraw \nSuccessfully!"
                    let realm = try! Realm()
                    if let user = realm.filterUser(id: self.idGlobal) {
                        try! realm.write {
                            user.relation = NO_RELATION
                            user.created_at = ""
                        }
                        FaeChat.sendContactMessage(to: self.idGlobal, with: "withdraw friend request")
                    }
                } else {
                    self.lblNotificationText.text = "Request Withdraw \nFail!"
                    print("[Contacts Request Withdraw Fail] - \(status) \(message!)")
                }
                self.btnYes.setTitle("OK", for: .normal)
                self.btnYes.tag = self.OK
                self.indicatorView.stopAnimating()
            }
            break
        case BLOCK:
            apiCalls.blockPerson(userId: String(idGlobal)) { [weak self] (status: Int, message: Any?) in
                guard let `self` = self else { return }
                if status / 100 == 2 {
                    self.lblNotificationText.text = "The user has been \nblocked successfully!"
                    let realm = try! Realm()
                    if let user = realm.filterUser(id: self.idGlobal) {
                        try! realm.write {
                            if user.relation & IS_FRIEND == IS_FRIEND {
                                user.relation &= BLOCKED
                            } else {
                                user.relation = NO_RELATION
                                user.created_at = ""
                            }
                        }
                        FaeChat.sendContactMessage(to: self.idGlobal, with: "block")
                    }
                } else {
                    self.lblNotificationText.text = "Block user \nFail!"
                    print("[Contacts Block Fail] - \(status) \(message!)")
                }
                self.btnYes.setTitle("OK", for: .normal)
                self.btnYes.tag = self.OK
                self.indicatorView.stopAnimating()
            }
            break
        case IGNORE:
            apiCalls.ignoreFriendRequest(friendId: String(idGlobal)) { [weak self] (status: Int, message: Any?) in
                guard let `self` = self else { return }
                self.showNoti(type: self.IGNORE)
                if status / 100 == 2 {
                    self.lblNotificationText.text = "Ignore Request \nSuccessfully!"
                    let realm = try! Realm()
                    if let user = realm.filterUser(id: self.idGlobal) {
                        try! realm.write {
                            user.relation = NO_RELATION
                            user.created_at = ""
                        }
                        FaeChat.sendContactMessage(to: self.idGlobal, with: "ignore friend request")
                    }
                } else {
                    self.lblNotificationText.text = "Ignore Request \nFail!"
                    print("[Contacts Ignore Request Fail] - \(status) \(message!)")
                }
                self.indicatorView.stopAnimating()
            }
            break
        case ACCEPT:
            apiCalls.acceptFriendRequest(friendId: String(idGlobal)) { [weak self] (status: Int, message: Any?) in
                guard let `self` = self else { return }
                self.showNoti(type: self.ACCEPT)
                if status / 100 == 2 {
                    self.lblNotificationText.text = "Accept Request \nSuccessfully!"
                    let realm = try! Realm()
                    if let user = realm.filterUser(id: self.idGlobal) {
                        try! realm.write {
                            user.relation = IS_FRIEND
                            user.created_at = ""
                        }
                        FaeChat.sendContactMessage(to: self.idGlobal, with: "accept friend request")
                    }
                    print("[Contacts Accept Request Successfully]")
                } else {
                    self.lblNotificationText.text = "Accept Request \nFail!"
                    print("[Contacts Accept Request Fail] - \(status) \(message!)")
                }
                self.indicatorView.stopAnimating()
            }
        case RESEND:
            apiCalls.sendFriendRequest(friendId: String(self.idGlobal), boolResend: "true") { [weak self] (status, message) in
                guard let `self` = self else { return }
                if status / 100 == 2 {
                    self.lblNotificationText.text = "Request Resent \nSuccessfully!"
                    let realm = try! Realm()
                    if let user = realm.filterUser(id: self.idGlobal) {
                        try! realm.write {
                            user.created_at = RealmUser.formateTime(Date())
                        }
                        FaeChat.sendContactMessage(to: self.idGlobal, with: "resend friend request")
                    }
                } else {
                    self.lblNotificationText.text = "Request Resent \nFail!"
                    print("[Contacts resend friend request fail]")
                }
                self.btnYes.setTitle("OK", for: .normal)
                self.btnYes.tag = self.OK
                self.indicatorView.stopAnimating()
            }
        default:
            break
        }
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension ContactsViewController: UITableViewDataSource, UITableViewDelegate {
    // MARK: TableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if cellStatus == 1 {
            return realmReceivedRequests.count
        } else if cellStatus == 2 {
            return realmSentRequests.count
        } else {
            if schbarContacts.txtSchField.text != "" {
                return filteredRealm.count
            } else {
                return realmFriends.count
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if cellStatus == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "FaeReceivedCell", for: indexPath as IndexPath) as! FaeReceivedCell
            //if indexPath.row > realmReceivedRequests.count { return cell }
            let realmUser = realmReceivedRequests[indexPath.row]
            cell.userId = Int(realmUser.id)!
            if let data = realmUser.avatar?.userSmallAvatar {
                cell.imgAvatar.image = UIImage(data: data as Data)
            }
            General.shared.avatar(userid: Int(realmUser.id)!, completion: { (avatarImage) in
                //cell.imgAvatar.image = avatarImage
            })
            cell.lblUserName.text = realmUser.display_name
            cell.lblUserSaying.text = realmUser.user_name
            cell.delegate = self
            cell.indexPath = indexPath
            return cell
        } else if cellStatus == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "FaeRequestedCell", for: indexPath as IndexPath) as! FaeRequestedCell
            //if indexPath.row > realmSentRequests.count { return cell }
            let realmUser = realmSentRequests[indexPath.row]
            cell.userId = Int(realmUser.id)!
            if let data = realmUser.avatar?.userSmallAvatar {
                cell.imgAvatar.image = UIImage(data: data as Data)
            }
            General.shared.avatar(userid: Int(realmUser.id)!, completion: { [weak cell] (avatarImage) in
                cell?.imgAvatar.image = avatarImage
            })
            cell.lblUserName.text = realmUser.display_name
            cell.lblUserSaying.text = realmUser.user_name
            cell.delegate = self
            cell.indexPath = indexPath
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "FaeContactsCell", for: indexPath as IndexPath) as! FaeContactsCell
            var realmUser: RealmUser!
            if schbarContacts.txtSchField.text != "" {
                realmUser = filteredRealm[indexPath.row]
            } else {
                //if indexPath.row > realmFriends.count { return cell }
                realmUser = realmFriends[indexPath.row]
            }
            if let data = realmUser.avatar?.userSmallAvatar {
                cell.imgAvatar.image = UIImage(data: data as Data)
            }
            General.shared.avatar(userid: Int(realmUser.id)!, completion: { [weak cell] (avatarImage) in
                cell?.imgAvatar.image = avatarImage
            })
            cell.lblUserName.text = realmUser.display_name
            cell.lblUserSaying.text = realmUser.user_name
            return cell
        }
    }
    
    // MARK: TableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // received
        indexPathGlobal = indexPath
        if cellStatus == 1 {
            uiviewNameCard.userId = Int(realmReceivedRequests[indexPath.row].id)!
        } else if cellStatus == 2 {   // requested
            uiviewNameCard.userId = Int(realmSentRequests[indexPath.row].id)!
        } else {
            if schbarContacts.txtSchField.text != "" {
                uiviewNameCard.userId = Int(filteredRealm[indexPath.row].id)!
            } else {
                uiviewNameCard.userId = Int(realmFriends[indexPath.row].id)!
            }
        }
        uiviewNameCard.show {}
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 74
    }
}
