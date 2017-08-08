//
//  JustinHe.swift
//  FaeContacts
//
//  Created by Justin He on 6/13/17.
//  Copyright © 2017 Yue. All rights reserved.
//

import UIKit

extension ContactsViewController: UITableViewDelegate, UITableViewDataSource, FaeSearchBarTestDelegate {
    
    func loadTable() {
        tblContacts = UITableView() // note to self: must modify screenHeight - 65 to also subtract the bottom bar
        tblContacts.frame = CGRect(x: 0, y: 64, width: screenWidth, height: screenHeight - 65)
        tblContacts.dataSource = self
        tblContacts.delegate = self
        tblContacts.separatorStyle = .none
        self.automaticallyAdjustsScrollViewInsets = false
//        let tapToDismissKeyboard = UITapGestureRecognizer(target: self, action: #selector(self.tapOutsideToDismissKeyboard(_:)))
//        tblContacts.addGestureRecognizer(tapToDismissKeyboard)
        tblContacts.addGestureRecognizer(setTapDismissDropdownMenu())
        
        /* Comment from Joshua:
         uiviewSchbar is an uiview container of searchBar, because we need to adjust the left padding of searchBar
         */
        uiviewSchbar = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 50))
        
        /* Comment from Joshua:
         1. font size is wrong, should be 18, not 20
         2. value of x and y is modified due to the padding reason
         3. your next task is try to understand the following UI layer logic, a little bit complex
         */
        schbarContacts = FaeSearchBarTest(frame: CGRect(x: 5, y: 1, width: screenWidth, height: 48))
        schbarContacts.txtSchField.placeholder = "Search Friends"
        schbarContacts.delegate = self
        uiviewSchbar.addSubview(schbarContacts)
        
        /* Comment from Joshua:
         there is a weird thin black at the top of schBar, so I add a white line to cover the ugly one
         try to comment following 4 lines of codes to see if you can find the weird thin black line
         */
        let schBarTopLine = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 1))
        schBarTopLine.layer.borderWidth = 1
        schBarTopLine.layer.borderColor = UIColor.white.cgColor
        schbarContacts.addSubview(schBarTopLine) 
        
        /* Comment from Joshua:
         the following 7 lines are for boss's customized schbar icon, not the original one
         */
        
        let topLine = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 1))
        topLine.layer.borderWidth = 1
        topLine.layer.borderColor = UIColor._200199204cg()
        uiviewSchbar.addSubview(topLine)
        
        let bottomLine = UIView(frame: CGRect(x: 0, y: 49, width: screenWidth, height: 1))
        bottomLine.layer.borderWidth = 1
        bottomLine.layer.borderColor = UIColor._200199204cg()
        uiviewSchbar.addSubview(bottomLine)
        
        /* Comment from Joshua:
         register customized cell created by Wenjia: FaeContactsCell
         */
        tblContacts.tableHeaderView = uiviewSchbar
        tblContacts.register(FaeContactsCell.self, forCellReuseIdentifier: "myCell")
        tblContacts.register(FaeRequestedCell.self, forCellReuseIdentifier: "myCellRequested")
        tblContacts.register(FaeReceivedCell.self, forCellReuseIdentifier: "myCellReceivedRequests")
        view.addSubview(tblContacts)
        
        uiviewBottomNav = UIView()
        uiviewBottomNav.frame = CGRect(x: 0, y: screenHeight - 50, width: screenWidth, height: 50)
        uiviewBottomNav.backgroundColor = UIColor._210210210()
        uiviewBottomNav.addGestureRecognizer(setTapDismissDropdownMenu())
        view.addSubview(uiviewBottomNav)
        
        btnFFF = UIButton()
        btnFFF.setImage(#imageLiteral(resourceName: "FFFunselected"), for: .normal)
        btnFFF.setImage(#imageLiteral(resourceName: "FFFselected"), for: .selected)
        btnFFF.isSelected = true
        btnFFF.addTarget(self, action: #selector(pressbtnFFF(button:)), for: .touchUpInside)
        btnFFF.imageEdgeInsets = UIEdgeInsetsMake(0, 40, 0, 0)
        uiviewBottomNav.addSubview(btnFFF)
        uiviewBottomNav.addConstraintsWithFormat("H:|-0-[v0]-" + String(describing: screenWidth / 2) + "-|", options: [], views: btnFFF)
        uiviewBottomNav.addConstraintsWithFormat("V:|-0-[v0]-0-|", options: [], views: btnFFF)
        
        btnRR = UIButton()
        btnRR.setImage(#imageLiteral(resourceName: "RRunselected"), for: .normal)
        btnRR.setImage(#imageLiteral(resourceName: "RRselected"), for: .selected)
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
        uiviewNavBar.rightBtn.isHidden = false
        uiviewNavBar.bottomLine.isHidden = false
        uiviewNavBar.lblTitle.isHidden = true
        btnNavBarMenu.isHidden = false
        
        cellStatus = 1
        self.schbarContacts.isHidden = false
        self.uiviewTabView.isHidden = true
        tblContacts.tableHeaderView = uiviewSchbar
        tblContacts.frame = CGRect(x: 0, y: 64, width: screenWidth, height: screenHeight - 65)
        tblContacts.reloadData()
    }
    
    func pressbtnRR(button: UIButton) {
        print("RR was pressed")
        if btnFFF.isSelected {
            btnFFF.isSelected = false
            btnRR.isSelected = true
        }
        RequestsPressed()
        cellStatus = 2
        self.schbarContacts.isHidden = true
        self.uiviewTabView.isHidden = false
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
        if curtTitle == "Friends" {
            filtered = testArrayFriends.filter({(($0.name).lowercased()).range(of: searchText.lowercased()) != nil})
        } else  if curtTitle == "Followers" {
            filteredFollows = arrFollowers.filter({(($0.name).lowercased()).range(of: searchText.lowercased()) != nil})
        } else {
            filteredFollows = arrFollowees.filter({(($0.name).lowercased()).range(of: searchText.lowercased()) != nil})
        }
        tblContacts.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if cellStatus == 1 {
            if curtTitle == "Friends" {
                if schbarContacts.txtSchField.text != "" {
                    return filtered.count
                } else {
                    return testArrayFriends.count
                }
            } else {
                if schbarContacts.txtSchField.text != "" {
                    return filteredFollows.count
                } else {
                    return curtTitle == "Followers" ? arrFollowers.count : arrFollowees.count
                }
            }
        }
        else if cellStatus == 2 {
            return testArrayReceivedRequests.count
        }
        else {
            return testArrayRequested.count
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
        if cellStatus == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "myCellReceivedRequests", for: indexPath as IndexPath) as! FaeReceivedCell
            print("get into cell2")
            cell.userId = testArrayReceivedRequests[indexPath.row].userId
            cell.requestId = testArrayReceivedRequests[indexPath.row].requestId
            
            cell.imgAvatar.userID = cell.userId
            cell.imgAvatar.loadAvatar(id: cell.userId)
            cell.lblUserName.text = testArrayReceivedRequests[indexPath.row].name
            cell.lblUserSaying.text = String(testArrayReceivedRequests[indexPath.row].requestId)
            cell.delegate = self
            cell.indexPath = indexPath
            return cell
        } else if cellStatus == 3 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "myCellRequested", for: indexPath as IndexPath) as! FaeRequestedCell
            cell.userId = testArrayRequested[indexPath.row].userId
            cell.requestId = testArrayRequested[indexPath.row].requestId
            
            cell.imgAvatar.userID = cell.userId
            cell.imgAvatar.loadAvatar(id: cell.userId)
            cell.lblUserName.text = testArrayRequested[indexPath.row].name
            cell.lblUserSaying.text = String(testArrayRequested[indexPath.row].requestId)
            cell.delegate = self
            cell.indexPath = indexPath
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath as IndexPath) as! FaeContactsCell
            if curtTitle == "Friends" {
                if schbarContacts.txtSchField.text != "" {
                    cell.imgAvatar.userID = filtered[indexPath.row].userId
                    cell.imgAvatar.loadAvatar(id: filtered[indexPath.row].userId)
                    cell.lblUserName.text = filtered[indexPath.row].name
                    cell.lblUserSaying.text = String(filtered[indexPath.row].userId)
                } else {
                    cell.imgAvatar.userID = testArrayFriends[indexPath.row].userId
                    cell.imgAvatar.loadAvatar(id: testArrayFriends[indexPath.row].userId)
                    cell.lblUserName.text = testArrayFriends[indexPath.row].name
                    cell.lblUserSaying.text = String(testArrayFriends[indexPath.row].userId)
                }
            } else if curtTitle == "Followers" {
                if schbarContacts.txtSchField.text != "" {
                    cell.imgAvatar.userID = filteredFollows[indexPath.row].followerId
                    cell.imgAvatar.loadAvatar(id: filteredFollows[indexPath.row].followerId)
                    cell.lblUserName.text = filteredFollows[indexPath.row].name
                    cell.lblUserSaying.text = String(filteredFollows[indexPath.row].followerId)
                } else {
                    cell.imgAvatar.userID = arrFollowers[indexPath.row].followerId
                    cell.imgAvatar.loadAvatar(id: arrFollowers[indexPath.row].followerId)
                    cell.lblUserName.text = arrFollowers[indexPath.row].name
                    cell.lblUserSaying.text = String(arrFollowers[indexPath.row].followerId)
                }
            } else {
                if schbarContacts.txtSchField.text != "" {
                    cell.imgAvatar.userID = filteredFollows[indexPath.row].followeeId
                    cell.imgAvatar.loadAvatar(id: filteredFollows[indexPath.row].followeeId)
                    cell.lblUserName.text = filteredFollows[indexPath.row].name
                    cell.lblUserSaying.text = String(filteredFollows[indexPath.row].followeeId)
                } else {
                    cell.imgAvatar.userID = arrFollowees[indexPath.row].followeeId
                    cell.imgAvatar.loadAvatar(id: arrFollowees[indexPath.row].followeeId)
                    cell.lblUserName.text = arrFollowees[indexPath.row].name
                    cell.lblUserSaying.text = String(arrFollowees[indexPath.row].followeeId)
                }
            }
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
    
//    func tapOutsideToDismissKeyboard(_ sender: UITapGestureRecognizer) {
//        schbarContacts.txtSchField.resignFirstResponder()
//    }
    
    func animateWithdrawal(listType: Int) {
        switch listType {
        case WITHDRAW:
            apiCalls.withdrawFriendRequest(requestId: String(idGlobal)) {(status: Int, message: Any?) in
                if status / 100 == 2 {
                    self.testArrayRequested.remove(at: self.indexPathGlobal.row)
                    self.reloadAfterDelete()
                } else {
                    print("[Contacts Request Withdraw Fail] - \(status) \(message!)")
                }
            }
            break
        case BLOCK:
            apiCalls.blockPerson(userId: String(idGlobal)) {(status: Int, message: Any?) in
                if status / 100 == 2 {
                    self.testArrayReceivedRequests.remove(at: self.indexPathGlobal.row)
                    self.reloadAfterDelete()
                } else {
                    print("[Contacts Block Fail] - \(status) \(message!)")
                }
            }
            break
        case IGNORE:
            apiCalls.ignoreFriendRequest(requestId: String(idGlobal)) {(status: Int, message: Any?) in
                if status / 100 == 2 {
                    print("indexPathGlobal \(self.indexPathGlobal)")
                    self.testArrayReceivedRequests.remove(at: self.indexPathGlobal.row)
                    self.reloadAfterDelete()
                } else {
                    print("[Contacts Ignore Request Fail] - \(status) \(message!)")
                }
            }
            break
        case ACCEPT:
            apiCalls.acceptFriendRequest(requestId: String(idGlobal)) { (status: Int, message: Any?) in
                if status / 100 == 2 {
                    self.testArrayReceivedRequests.remove(at: self.indexPathGlobal.row)
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
