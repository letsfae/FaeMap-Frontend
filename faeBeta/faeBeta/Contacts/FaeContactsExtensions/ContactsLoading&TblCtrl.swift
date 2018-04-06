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

extension ContactsViewController: UITableViewDelegate, UITableViewDataSource, FaeSearchBarTestDelegate, NameCardDelegate, AddFriendFromNameCardDelegate {
    
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
        tblContacts.addGestureRecognizer(setTapDismissDropdownMenu())
  
        tblContacts.register(FaeContactsCell.self, forCellReuseIdentifier: "FaeContactsCell")
        tblContacts.register(FaeRequestedCell.self, forCellReuseIdentifier: "FaeRequestedCell")
        tblContacts.register(FaeReceivedCell.self, forCellReuseIdentifier: "FaeReceivedCell")
        view.addSubview(tblContacts)
    }
    
    func loadTabView() {
        uiviewBottomNav = UIView(frame: CGRect(x: 0, y: screenHeight - 49 - device_offset_bot, width: screenWidth, height: 49 + device_offset_bot))
        uiviewBottomNav.addGestureRecognizer(setTapDismissDropdownMenu())
        view.addSubview(uiviewBottomNav)
        uiviewBottomNav.isHidden = true
        
        let line = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 1))
        line.backgroundColor = UIColor._200199204()
        uiviewBottomNav.addSubview(line)
        
        btnFFF = UIButton()
//        btnFFF.setImage(#imageLiteral(resourceName: "FFFunselected"), for: .normal)
//        btnFFF.setImage(#imageLiteral(resourceName: "FFFselected"), for: .selected)
        btnFFF.setAttributedTitle(NSAttributedString(string: "Received", attributes: [NSAttributedStringKey.foregroundColor: UIColor._146146146(), NSAttributedStringKey.font: UIFont(name: "AvenirNext-Regular", size: 18)!]), for: .normal)
        btnFFF.setAttributedTitle(NSAttributedString(string: "Received", attributes: [NSAttributedStringKey.foregroundColor: UIColor._2499090(), NSAttributedStringKey.font: UIFont(name: "AvenirNext-DemiBold", size: 18)!]), for: .selected)
        btnFFF.isSelected = true
        btnFFF.addTarget(self, action: #selector(pressbtnFFF(button:)), for: .touchUpInside)
        btnFFF.imageEdgeInsets = UIEdgeInsetsMake(0, 40, 0, 0)
        uiviewBottomNav.addSubview(btnFFF)
        uiviewBottomNav.addConstraintsWithFormat("H:|-0-[v0]-" + String(describing: screenWidth / 2) + "-|", options: [], views: btnFFF)
        uiviewBottomNav.addConstraintsWithFormat("V:|-0-[v0]-\(device_offset_bot)-|", options: [], views: btnFFF)
        
        btnRR = UIButton()
//        btnRR.setImage(#imageLiteral(resourceName: "RRunselected"), for: .normal)
//        btnRR.setImage(#imageLiteral(resourceName: "RRselected"), for: .selected)
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
    
    // MARK: NameCardDelegate
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
        //addFriendVC.requestId = requestId
        addFriendVC.statusMode = status
        addFriendVC.modalPresentationStyle = .overCurrentContext
        present(addFriendVC, animated: false)
    }
    
    func startChat(_ chat_id: String?, userId: Int, nickName: String?) {
        let vcChat = ChatViewController()
        vcChat.arrUserIDs.append("\(Key.shared.user_id)")
        vcChat.arrUserIDs.append("\(userId)")
        navigationController?.pushViewController(vcChat, animated: true)
    }
    
    // MARK: AddFriendFromNameCardDelegate
    func changeContactsTable(action: Int, userId: Int) {
        print("changeContactsTable")
        switch action {
        case ACCEPT:
            arrRealmReceivedRequests.remove(at: indexPathGlobal.row)
        case IGNORE:
            arrRealmReceivedRequests.remove(at: indexPathGlobal.row)
        case WITHDRAW:
            arrRealmRequested.remove(at: indexPathGlobal.row)
        case REMOVE:
            arrRealmFriends.remove(at: indexPathGlobal.row)
            self.uiviewNameCard.hide { }
        case BLOCK:
            arrRealmFriends.remove(at: indexPathGlobal.row)
            self.uiviewNameCard.hide { }
        default: break
        }
        self.reloadAfterDelete()
    }
    
    // MARK: Bottom button functionalities
    @objc func pressbtnFFF(button: UIButton) {
        if btnRR.isSelected {
            getReceivedRequests()
            btnRR.isSelected = false
            btnFFF.isSelected = true
        }
        cellStatus = 1
        tblContacts.reloadData()
    }
    
    @objc func pressbtnRR(button: UIButton) {
        if btnFFF.isSelected {
            getSentRequests()
            btnFFF.isSelected = false
            btnRR.isSelected = true
        }
        cellStatus = 2
        tblContacts.reloadData()
    }
    
    // MARK: FaeSearchBarTestDelegate
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
    
    // MAKR: search on friend list
    func filter(searchText: String, scope: String = "All") {
        filteredRealm = arrRealmFriends.filter({ ($0.display_name).lowercased().range(of: searchText.lowercased()) != nil })
        tblContacts.reloadData()
    }
    
    // MARK: ContactsReceivedRequestsDelegate
    func refuseRequest(userId: Int, indexPath: IndexPath) {
        btnYes.tag = IGNORE
        indexPathGlobal = indexPath
        idGlobal = userId
        self.chooseAnAction()
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
    
    // MARK: TableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if cellStatus == 1 {
            return arrRealmReceivedRequests.count
        } else if cellStatus == 2 {
            return arrRealmRequested.count
        } else {
            if schbarContacts.txtSchField.text != "" {
                return filteredRealm.count
            } else {
                return arrRealmFriends.count
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if cellStatus == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "FaeReceivedCell", for: indexPath as IndexPath) as! FaeReceivedCell
            cell.userId = Int(arrRealmReceivedRequests[indexPath.row].id)!
            //cell.requestId = Int(arrRealmReceivedRequests[indexPath.row].request_id)!
            if let data = arrRealmReceivedRequests[indexPath.row].avatar?.userSmallAvatar {
                cell.imgAvatar.image = UIImage(data: data as Data)
            }
            General.shared.avatar(userid: Int(arrRealmReceivedRequests[indexPath.row].id)!, completion: { (avatarImage) in
                //cell.imgAvatar.image = avatarImage
            })
            cell.lblUserName.text = arrRealmReceivedRequests[indexPath.row].display_name
            cell.lblUserSaying.text = arrRealmReceivedRequests[indexPath.row].user_name
            cell.delegate = self
            cell.indexPath = indexPath
            return cell
        } else if cellStatus == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "FaeRequestedCell", for: indexPath as IndexPath) as! FaeRequestedCell
            cell.userId = Int(arrRealmRequested[indexPath.row].id)!
            //cell.requestId = Int(arrRealmRequested[indexPath.row].request_id)!
            if let data = arrRealmRequested[indexPath.row].avatar?.userSmallAvatar {
                cell.imgAvatar.image = UIImage(data: data as Data)
            }
            General.shared.avatar(userid: Int(arrRealmRequested[indexPath.row].id)!, completion: { (avatarImage) in
                cell.imgAvatar.image = avatarImage
            })
            cell.lblUserName.text = arrRealmRequested[indexPath.row].display_name
            cell.lblUserSaying.text = arrRealmRequested[indexPath.row].user_name
            cell.delegate = self
            cell.indexPath = indexPath
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "FaeContactsCell", for: indexPath as IndexPath) as! FaeContactsCell
            if schbarContacts.txtSchField.text != "" {
                if let data = filteredRealm[indexPath.row].avatar?.userSmallAvatar {
                    cell.imgAvatar.image = UIImage(data: data as Data)
                }
                General.shared.avatar(userid: Int(filteredRealm[indexPath.row].id)!, completion: { (avatarImage) in
                    cell.imgAvatar.image = avatarImage
                })
                cell.lblUserName.text = filteredRealm[indexPath.row].display_name
                cell.lblUserSaying.text = filteredRealm[indexPath.row].user_name
            } else {
                if let data = arrRealmFriends[indexPath.row].avatar?.userSmallAvatar {
                    cell.imgAvatar.image = UIImage(data: data as Data)
                }
                General.shared.avatar(userid: Int(arrRealmFriends[indexPath.row].id)!, completion: { (avatarImage) in
                    cell.imgAvatar.image = avatarImage
                })
                cell.lblUserName.text = arrRealmFriends[indexPath.row].display_name
                cell.lblUserSaying.text = arrRealmFriends[indexPath.row].user_name
            }
            return cell
        }
    }
    
    // MARK: TableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // received
        indexPathGlobal = indexPath
        if cellStatus == 1 {
            uiviewNameCard.userId = Int(arrRealmReceivedRequests[indexPath.row].id)!
            //uiviewNameCard.requestId = Int(arrRealmReceivedRequests[indexPath.row].request_id)!
        } else if cellStatus == 2 {   // requested
            uiviewNameCard.userId = Int(arrRealmRequested[indexPath.row].id)!
            //uiviewNameCard.requestId = Int(arrRealmRequested[indexPath.row].request_id)!
        } else {
            if schbarContacts.txtSchField.text != "" {
                uiviewNameCard.userId = Int(filteredRealm[indexPath.row].id)!
            } else {
                uiviewNameCard.userId = Int(arrRealmFriends[indexPath.row].id)!
            }
        }
        uiviewNameCard.show {}
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 74
    }
    
    // MARK: Contact actions
    func animateWithdrawal(listType: Int) {
        switch listType {
        case WITHDRAW:
            apiCalls.withdrawFriendRequest(friendId: String(idGlobal)) {(status: Int, message: Any?) in
                if status / 100 == 2 {
                    self.lblNotificationText.text = "Request Withdraw \nSuccessfully!"
                    let realm = try! Realm()
                    try! realm.write {
                        self.arrRealmRequested[self.indexPathGlobal.row].relation = NO_RELATION
                        self.arrRealmRequested[self.indexPathGlobal.row].created_at = ""
                    }
                    self.arrRealmRequested.remove(at: self.indexPathGlobal.row)
                    self.reloadAfterDelete()
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
            apiCalls.blockPerson(userId: String(idGlobal)) {(status: Int, message: Any?) in
                if status / 100 == 2 {
                    self.lblNotificationText.text = "The user has been \nblocked successfully!"
                    let realm = try! Realm()
                    try! realm.write {
                        if self.arrRealmReceivedRequests[self.indexPathGlobal.row].relation & IS_FRIEND == IS_FRIEND {
                            self.arrRealmReceivedRequests[self.indexPathGlobal.row].relation &= BLOCKED
                        } else {
                            self.arrRealmReceivedRequests[self.indexPathGlobal.row].relation = NO_RELATION
                            self.arrRealmReceivedRequests[self.indexPathGlobal.row].created_at = ""
                        }
                        
                    }
                    self.arrRealmReceivedRequests.remove(at: self.indexPathGlobal.row)
                    self.reloadAfterDelete()
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
            apiCalls.ignoreFriendRequest(friendId: String(idGlobal)) {(status: Int, message: Any?) in
                self.showNoti(type: self.IGNORE)
                if status / 100 == 2 {
                    self.lblNotificationText.text = "Ignore Request \nSuccessfully!"
                    let realm = try! Realm()
                    try! realm.write {
                        self.arrRealmReceivedRequests[self.indexPathGlobal.row].relation = NO_RELATION
                        self.arrRealmReceivedRequests[self.indexPathGlobal.row].created_at = ""
                    }
                    self.arrRealmReceivedRequests.remove(at: self.indexPathGlobal.row)
                    self.reloadAfterDelete()
                } else {
                    self.lblNotificationText.text = "Ignore Request \nFail!"
                    print("[Contacts Ignore Request Fail] - \(status) \(message!)")
                }
                self.indicatorView.stopAnimating()
            }
            break
        case ACCEPT:
            apiCalls.acceptFriendRequest(friendId: String(idGlobal)) { (status: Int, message: Any?) in
                self.showNoti(type: self.ACCEPT)
                if status / 100 == 2 {
                    self.lblNotificationText.text = "Accept Request \nSuccessfully!"
                    let realm = try! Realm()
                    try! realm.write {
                        self.arrRealmReceivedRequests[self.indexPathGlobal.row].relation = IS_FRIEND
                        self.arrRealmReceivedRequests[self.indexPathGlobal.row].created_at = ""
                    }
                    self.arrRealmReceivedRequests.remove(at: self.indexPathGlobal.row)
                    self.reloadAfterDelete()
                    print("[Contacts Accept Request Successfully]")
                } else {
                    self.lblNotificationText.text = "Accept Request \nFail!"
                    print("[Contacts Accept Request Fail] - \(status) \(message!)")
                }
                self.indicatorView.stopAnimating()
            }
        case RESEND:
            apiCalls.sendFriendRequest(friendId: String(self.idGlobal), boolResend: "true") {(status, message) in
                if status / 100 == 2 {
                    self.lblNotificationText.text = "Request Resent \nSuccessfully!"
                    // TODO: API modification needed
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
    
    func reloadAfterDelete() {
        tblContacts.performUpdate({
            self.tblContacts.deleteRows(at: [indexPathGlobal], with: UITableViewRowAnimation.right)
        }) {
            self.tblContacts.reloadData()
            self.setupScrollBar()
        }
    }
}
