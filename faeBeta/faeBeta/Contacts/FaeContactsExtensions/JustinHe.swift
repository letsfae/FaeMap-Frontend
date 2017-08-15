//
//  JustinHe.swift
//  FaeContacts
//
//  Created by Justin He on 6/13/17.
//  Copyright © 2017 Yue. All rights reserved.
//

import UIKit

extension ContactsViewController: UITableViewDelegate, UITableViewDataSource, FaeSearchBarTestDelegate {
    func loadSearchBar() {
        uiviewSchbar = UIView(frame: CGRect(x: 0, y: 65, width: screenWidth, height: 49))
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
        tblContacts.frame = CGRect(x: 0, y: 114, width: screenWidth, height: screenHeight - 114)
        tblContacts.dataSource = self
        tblContacts.delegate = self
        tblContacts.separatorStyle = .none
        self.automaticallyAdjustsScrollViewInsets = false
        tblContacts.addGestureRecognizer(setTapDismissDropdownMenu())
  
        tblContacts.register(FaeContactsCell.self, forCellReuseIdentifier: "FaeContactsCell")
        tblContacts.register(FaeRequestedCell.self, forCellReuseIdentifier: "FaeRequestedCell")
        tblContacts.register(FaeReceivedCell.self, forCellReuseIdentifier: "FaeReceivedCell")
        view.addSubview(tblContacts)
    }
    
    func loadTabView() {
        uiviewBottomNav = UIView(frame: CGRect(x: 0, y: screenHeight - 49, width: screenWidth, height: 49))
        uiviewBottomNav.addGestureRecognizer(setTapDismissDropdownMenu())
        view.addSubview(uiviewBottomNav)
        uiviewBottomNav.isHidden = true
        
        let line = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 1))
        line.backgroundColor = UIColor._200199204()
        uiviewBottomNav.addSubview(line)
        
        btnFFF = UIButton()
//        btnFFF.setImage(#imageLiteral(resourceName: "FFFunselected"), for: .normal)
//        btnFFF.setImage(#imageLiteral(resourceName: "FFFselected"), for: .selected)
        btnFFF.setAttributedTitle(NSAttributedString(string: "Received", attributes: [NSForegroundColorAttributeName: UIColor._146146146(), NSFontAttributeName: UIFont(name: "AvenirNext-Regular", size: 18)!]), for: .normal)
        btnFFF.setAttributedTitle(NSAttributedString(string: "Received", attributes: [NSForegroundColorAttributeName: UIColor._2499090(), NSFontAttributeName: UIFont(name: "AvenirNext-DemiBold", size: 18)!]), for: .selected)
        btnFFF.isSelected = true
        btnFFF.addTarget(self, action: #selector(pressbtnFFF(button:)), for: .touchUpInside)
        btnFFF.imageEdgeInsets = UIEdgeInsetsMake(0, 40, 0, 0)
        uiviewBottomNav.addSubview(btnFFF)
        uiviewBottomNav.addConstraintsWithFormat("H:|-0-[v0]-" + String(describing: screenWidth / 2) + "-|", options: [], views: btnFFF)
        uiviewBottomNav.addConstraintsWithFormat("V:|-0-[v0]-0-|", options: [], views: btnFFF)
        
        btnRR = UIButton()
//        btnRR.setImage(#imageLiteral(resourceName: "RRunselected"), for: .normal)
//        btnRR.setImage(#imageLiteral(resourceName: "RRselected"), for: .selected)
        btnRR.setAttributedTitle(NSAttributedString(string: "Requested", attributes: [NSForegroundColorAttributeName: UIColor._146146146(), NSFontAttributeName: UIFont(name: "AvenirNext-Regular", size: 18)!]), for: .normal)
        btnRR.setAttributedTitle(NSAttributedString(string: "Requested", attributes: [NSForegroundColorAttributeName: UIColor._2499090(), NSFontAttributeName: UIFont(name: "AvenirNext-DemiBold", size: 18)!]), for: .selected)
        btnRR.addTarget(self, action: #selector(pressbtnRR(button:)), for: .touchUpInside)
        btnRR.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 40)
        uiviewBottomNav.addSubview(btnRR)
        uiviewBottomNav.addConstraintsWithFormat("H:|-\(screenWidth / 2)-[v0]-0-|", options: [], views: btnRR)
        uiviewBottomNav.addConstraintsWithFormat("V:|-0-[v0]-0-|", options: [], views: btnRR)
    }
    
    // button press functionalities
    func pressbtnFFF(button: UIButton) {
        print("FFF was pressed")
        if btnRR.isSelected {
            btnRR.isSelected = false
            btnFFF.isSelected = true
        }
//        uiviewNavBar.rightBtn.isHidden = false
//        uiviewNavBar.bottomLine.isHidden = false
//        uiviewNavBar.lblTitle.isHidden = true
//        btnNavBarMenu.isHidden = false
        
        cellStatus = 1
//        self.schbarContacts.isHidden = false
//        self.uiviewTabView.isHidden = true
//        tblContacts.frame = CGRect(x: 0, y: 64, width: screenWidth, height: screenHeight - 65)
        tblContacts.reloadData()
    }
    
    func pressbtnRR(button: UIButton) {
        print("RR was pressed")
        if btnFFF.isSelected {
            btnFFF.isSelected = false
            btnRR.isSelected = true
        }
//        RequestsPressed()
        cellStatus = 2
//        self.schbarContacts.isHidden = true
//        self.uiviewTabView.isHidden = false
        tblContacts.reloadData()
    }
    
    // FaeSearchBarTestDelegate
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
    // End of FaeSearchBarTestDelegate
    
    func filter(searchText: String, scope: String = "All") {
        filtered = arrFriends.filter({(($0.displayName).lowercased()).range(of: searchText.lowercased()) != nil})
        /*
        if curtTitle == "Friends" {
            filtered = arrFriends.filter({(($0.displayName).lowercased()).range(of: searchText.lowercased()) != nil})
        } else  if curtTitle == "Followers" {
            filteredFollows = arrFollowers.filter({(($0.displayName).lowercased()).range(of: searchText.lowercased()) != nil})
        } else {
            filteredFollows = arrFollowees.filter({(($0.displayName).lowercased()).range(of: searchText.lowercased()) != nil})
        }
         */
        tblContacts.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if cellStatus == 1 {
            return arrReceivedRequests.count
            /*
            if curtTitle == "Friends" {
                if schbarContacts.txtSchField.text != "" {
                    return filtered.count
                } else {
                    return arrFriends.count
                }
            } else {
                if schbarContacts.txtSchField.text != "" {
                    return filteredFollows.count
                } else {
                    return curtTitle == "Followers" ? arrFollowers.count : arrFollowees.count
                }
            }
             */
        }
        else if cellStatus == 2 {
            return arrRequested.count
        }
        else {
            if schbarContacts.txtSchField.text != "" {
                return filtered.count
            } else {
                return arrFriends.count
            }
        }
    }
    
    // SomeDelegateReceivedRequests
    func refuseRequest(requestId: Int, indexPath: IndexPath) {
        indexPathGlobal = indexPath
        idGlobal = requestId
        self.chooseAnAction()
    }
    
    func acceptRequest(requestId: Int, indexPath: IndexPath) {
        indexPathGlobal = indexPath
        idGlobal = requestId
        animateWithdrawal(listType: ACCEPT)
    }
    // SomeDelegateReceivedRequests End
    
    // SomeDelegateRequested
    func withdrawRequest(requestId: Int, indexPath: IndexPath) {
        indexPathGlobal = indexPath
        idGlobal = requestId
        print("button has been executed cancel request")
        self.showNoti(type: WITHDRAW)
    }
    
    func resendRequest(userId: Int, indexPath: IndexPath) {
        print("button has been executed resend request")
        indexPathGlobal = indexPath
        idGlobal = userId
        self.showNoti(type: RESEND)
    }
    // SomeDelegateRequested End
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("cell:\(cellStatus)")
        print("get into cell")
        if cellStatus == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "FaeReceivedCell", for: indexPath as IndexPath) as! FaeReceivedCell
            print("get into cell2")
            cell.userId = arrReceivedRequests[indexPath.row].userId
            cell.requestId = arrReceivedRequests[indexPath.row].requestId
            
            General.shared.avatar(userid: cell.userId, completion: { (avatarImage) in
                cell.imgAvatar.image = avatarImage
            })
            cell.lblUserName.text = arrReceivedRequests[indexPath.row].displayName
            cell.lblUserSaying.text = arrReceivedRequests[indexPath.row].userName
            cell.delegate = self
            cell.indexPath = indexPath
            return cell
        } else if cellStatus == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "FaeRequestedCell", for: indexPath as IndexPath) as! FaeRequestedCell
            cell.userId = arrRequested[indexPath.row].userId
            cell.requestId = arrRequested[indexPath.row].requestId
            
            General.shared.avatar(userid: cell.userId, completion: { (avatarImage) in
                cell.imgAvatar.image = avatarImage
            })
            cell.lblUserName.text = arrRequested[indexPath.row].displayName
            cell.lblUserSaying.text = arrRequested[indexPath.row].userName
            cell.delegate = self
            cell.indexPath = indexPath
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "FaeContactsCell", for: indexPath as IndexPath) as! FaeContactsCell
            if schbarContacts.txtSchField.text != "" {
                General.shared.avatar(userid: filtered[indexPath.row].userId, completion: { (avatarImage) in
                    cell.imgAvatar.image = avatarImage
                })
                //                    cell.imgAvatar.userID = filtered[indexPath.row].userId
                //                    cell.imgAvatar.loadAvatar(id: filtered[indexPath.row].userId)
                cell.lblUserName.text = filtered[indexPath.row].displayName
                cell.lblUserSaying.text = filtered[indexPath.row].userName
            } else {
                General.shared.avatar(userid: arrFriends[indexPath.row].userId, completion: { (avatarImage) in
                    cell.imgAvatar.image = avatarImage
                })
                //                    cell.imgAvatar.userID = testArrayFriends[indexPath.row].userId
                //                    cell.imgAvatar.loadAvatar(id: testArrayFriends[indexPath.row].userId)
                cell.lblUserName.text = arrFriends[indexPath.row].displayName
                cell.lblUserSaying.text = arrFriends[indexPath.row].userName
            }
            
            /*
            if curtTitle == "Friends" {
                if schbarContacts.txtSchField.text != "" {
                    General.shared.avatar(userid: filtered[indexPath.row].userId, completion: { (avatarImage) in
                        cell.imgAvatar.image = avatarImage
                    })
//                    cell.imgAvatar.userID = filtered[indexPath.row].userId
//                    cell.imgAvatar.loadAvatar(id: filtered[indexPath.row].userId)
                    cell.lblUserName.text = filtered[indexPath.row].displayName
                    cell.lblUserSaying.text = filtered[indexPath.row].userName
                } else {
                    General.shared.avatar(userid: arrFriends[indexPath.row].userId, completion: { (avatarImage) in
                        cell.imgAvatar.image = avatarImage
                    })
//                    cell.imgAvatar.userID = testArrayFriends[indexPath.row].userId
//                    cell.imgAvatar.loadAvatar(id: testArrayFriends[indexPath.row].userId)
                    cell.lblUserName.text = arrFriends[indexPath.row].displayName
                    cell.lblUserSaying.text = arrFriends[indexPath.row].userName
                }
            } else if curtTitle == "Followers" {
                if schbarContacts.txtSchField.text != "" {
                    General.shared.avatar(userid: filteredFollows[indexPath.row].followerId, completion: { (avatarImage) in
                        cell.imgAvatar.image = avatarImage
                    })
//                    cell.imgAvatar.userID = filteredFollows[indexPath.row].followerId
//                    cell.imgAvatar.loadAvatar(id: filteredFollows[indexPath.row].followerId)
                    cell.lblUserName.text = filteredFollows[indexPath.row].displayName
                    cell.lblUserSaying.text = filteredFollows[indexPath.row].userName
                } else {
                    General.shared.avatar(userid: arrFollowers[indexPath.row].followerId, completion: { (avatarImage) in
                        cell.imgAvatar.image = avatarImage
                    })
//                    cell.imgAvatar.userID = arrFollowers[indexPath.row].followerId
//                    cell.imgAvatar.loadAvatar(id: arrFollowers[indexPath.row].followerId)
                    cell.lblUserName.text = arrFollowers[indexPath.row].displayName
                    cell.lblUserSaying.text = arrFollowers[indexPath.row].userName
                }
            } else {
                if schbarContacts.txtSchField.text != "" {
                    General.shared.avatar(userid: filteredFollows[indexPath.row].followeeId, completion: { (avatarImage) in
                        cell.imgAvatar.image = avatarImage
                    })
//                    cell.imgAvatar.userID = filteredFollows[indexPath.row].followeeId
//                    cell.imgAvatar.loadAvatar(id: filteredFollows[indexPath.row].followeeId)
                    cell.lblUserName.text = filteredFollows[indexPath.row].displayName
                    cell.lblUserSaying.text = filteredFollows[indexPath.row].userName
                } else {
                    General.shared.avatar(userid: arrFollowees[indexPath.row].followeeId, completion: { (avatarImage) in
                        cell.imgAvatar.image = avatarImage
                    })
//                    cell.imgAvatar.userID = arrFollowees[indexPath.row].followeeId
//                    cell.imgAvatar.loadAvatar(id: arrFollowees[indexPath.row].followeeId)
                    cell.lblUserName.text = arrFollowees[indexPath.row].displayName
                    cell.lblUserSaying.text = arrFollowees[indexPath.row].userName
                }
            }
             */
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("User selected table row \(indexPath.row)")
    }
    
    /* Comment from Joshua:
     assign the table cell height
     */
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 74
    }
    
    func animateWithdrawal(listType: Int) {
        switch listType {
        case WITHDRAW:
            apiCalls.withdrawFriendRequest(requestId: String(idGlobal)) {(status: Int, message: Any?) in
                if status / 100 == 2 {
                    self.arrRequested.remove(at: self.indexPathGlobal.row)
                    self.reloadAfterDelete()
                } else {
                    print("[Contacts Request Withdraw Fail] - \(status) \(message!)")
                }
            }
            break
        case BLOCK:
            apiCalls.blockPerson(userId: String(idGlobal)) {(status: Int, message: Any?) in
                if status / 100 == 2 {
                    self.arrReceivedRequests.remove(at: self.indexPathGlobal.row)
                    self.reloadAfterDelete()
                } else {
                    print("[Contacts Block Fail] - \(status) \(message!)")
                }
            }
            break
        case IGNORE:
            apiCalls.ignoreFriendRequest(requestId: String(idGlobal)) {(status: Int, message: Any?) in
                if status / 100 == 2 {
                    self.arrReceivedRequests.remove(at: self.indexPathGlobal.row)
                    self.reloadAfterDelete()
                } else {
                    print("[Contacts Ignore Request Fail] - \(status) \(message!)")
                }
            }
            break
        case ACCEPT:
            apiCalls.acceptFriendRequest(requestId: String(idGlobal)) { (status: Int, message: Any?) in
                if status / 100 == 2 {
                    self.arrReceivedRequests.remove(at: self.indexPathGlobal.row)
                    self.reloadAfterDelete()
                    print("[Contacts Accept Request Successfully]")
                } else {
                    print("[Contacts Accept Request Fail] - \(status) \(message!)")
                }
            }
        case RESEND:
            apiCalls.sendFriendRequest(friendId: String(self.idGlobal), boolResend: "true") {(status, message) in
                if status / 100 == 2 {
                    print("[Contacts resend friend request successfully]")
                } else {
                    print("[Contacts resend friend request fail]")
                }
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
        }
    }
}
