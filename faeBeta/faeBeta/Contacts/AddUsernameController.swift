//
//  AddUsernameController.swift
//  FaeContacts
//
//  Created by Justin He on 6/15/17.
//  Copyright © 2017 Yue. All rights reserved.
//

import UIKit
import SwiftyJSON

struct UserNameCard {
    let userId: Int
    let userName: String
    let displayName: String
    let shortIntro: String
    init(user_id: Int, nick_name: String, user_name: String, short_intro: String = "") {
        userId = user_id
        userName = user_name
        displayName = nick_name
        shortIntro = short_intro
    }
}

class AddUsernameController: UIViewController, UITableViewDelegate, UITableViewDataSource, FaeSearchBarTestDelegate, FaeAddUsernameDelegate, FriendOperationFromContactsDelegate {
    
    var uiviewNavBar: FaeNavBar!
    var uiviewSchbar: UIView!
    var schbarUsernames: FaeSearchBarTest!
    var tblUsernames: UITableView!
    var lblMyUsername: UILabel!
    var lblMyUsernameField: UILabel!
    var lblMyScreenname: UILabel!
    var lblMyScreennameField: UILabel!
    var imgGhost: UIImageView!
    var boolSearched: Bool = false
    var indicatorView: UIActivityIndicatorView!
    
    var filtered = [UserNameCard]()
    var arrFriends = [Friends]()
    var arrReceivedRequests = [Friends]()
    var arrRequested = [Friends]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadSearchTable()
        loadNavBar()
        view.backgroundColor = .white
        createActivityIndicator()
        schbarUsernames.txtSchField.becomeFirstResponder()
    }
    
    @objc func actionGoBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func createActivityIndicator() {
        indicatorView = UIActivityIndicatorView()
        indicatorView.activityIndicatorViewStyle = .whiteLarge
        indicatorView.center = view.center
        indicatorView.hidesWhenStopped = true
        indicatorView.color = UIColor._2499090()
        
        view.addSubview(indicatorView)
    }
    
    func loadSearchTable() {
        /* Joshua 06/16/17
         tblUsernames' height should be screenHeight - 65 - height of schbar
         */
        let uiviewSchbar = UIView(frame: CGRect(x: 0, y: 65 + device_offset_top, width: screenWidth, height: 49))
        schbarUsernames = FaeSearchBarTest(frame: CGRect(x: 5, y: 0, width: screenWidth, height: 48))
        schbarUsernames.txtSchField.placeholder = "Search Username"
        schbarUsernames.delegate = self
        uiviewSchbar.addSubview(schbarUsernames)
        
        let bottomLine = UIView(frame: CGRect(x: 0, y: 48, width: screenWidth, height: 1))
        bottomLine.layer.borderWidth = 1
        bottomLine.layer.borderColor = UIColor._200199204cg()
        uiviewSchbar.addSubview(bottomLine)
        
        view.addSubview(uiviewSchbar)
        
        /* Joshua 06/16/17
         1. name components as short and easy-recoginized as possible
         2. group each component for readability
         */
        lblMyUsername = UILabel()
        lblMyUsername.textAlignment = .center
        lblMyUsername.text = "My Username:"
        lblMyUsername.textColor = UIColor._155155155()
        lblMyUsername.font = UIFont(name: "AvenirNext-Medium", size: 13)
        
        lblMyUsernameField = UILabel()
        lblMyUsernameField.textAlignment = .center
        lblMyUsernameField.text = Key.shared.username
        lblMyUsernameField.textColor = UIColor._155155155()
        lblMyUsernameField.font = UIFont(name: "AvenirNext-Medium", size: 16)
        
        lblMyScreenname = UILabel()
        lblMyScreenname.textAlignment = .center
        lblMyScreenname.text = "My Display Name:"
        lblMyScreenname.textColor = UIColor._155155155()
        lblMyScreenname.font = UIFont(name: "AvenirNext-Medium", size: 13)
        
        lblMyScreennameField = UILabel()
        lblMyScreennameField.textAlignment = .center
        lblMyScreennameField.text = Key.shared.nickname ?? "Someone"
        lblMyScreennameField.textColor = UIColor._155155155()
        lblMyScreennameField.font = UIFont(name: "AvenirNext-Medium", size: 16)
        
        view.addSubview(lblMyUsername)
        view.addSubview(lblMyUsernameField)
        view.addSubview(lblMyScreenname)
        view.addSubview(lblMyScreennameField)
        
        view.addConstraintsWithFormat("H:|-0-[v0]-0-|", options: [], views: lblMyUsername)
        view.addConstraintsWithFormat("H:|-0-[v0]-0-|", options: [], views: lblMyUsernameField)
        view.addConstraintsWithFormat("H:|-0-[v0]-0-|", options: [], views: lblMyScreenname)
        view.addConstraintsWithFormat("H:|-0-[v0]-0-|", options: [], views: lblMyScreennameField)
        
        view.addConstraintsWithFormat("V:|-\(144+device_offset_top)-[v0]", options: [], views: lblMyUsername)
        view.addConstraintsWithFormat("V:|-\(164+device_offset_top)-[v0]", options: [], views: lblMyUsernameField)
        view.addConstraintsWithFormat("V:|-\(229+device_offset_top)-[v0]", options: [], views: lblMyScreenname)
        view.addConstraintsWithFormat("V:|-\(249+device_offset_top)-[v0]", options: [], views: lblMyScreennameField)
        
        tblUsernames = UITableView()
        tblUsernames.frame = CGRect(x: 0, y: 114 + device_offset_top, width: screenWidth, height: screenHeight - 114 - device_offset_top)
        tblUsernames.dataSource = self
        tblUsernames.delegate = self
        let tapToDismissKeyboard = UITapGestureRecognizer(target: self, action: #selector(self.tapOutsideToDismissKeyboard(_:)))
        tblUsernames.addGestureRecognizer(tapToDismissKeyboard)
        tblUsernames.register(FaeAddUsernameCell.self, forCellReuseIdentifier: "FaeAddUsernameCell")
        tblUsernames.isHidden = false
        tblUsernames.indicatorStyle = .white
        tblUsernames.separatorStyle = .none
        view.addSubview(tblUsernames)
        
        imgGhost = UIImageView()
        imgGhost.frame = CGRect(x: screenWidth/5, y: 3*screenHeight/10, width: 252, height: 209)
        imgGhost.contentMode = .scaleAspectFit
        imgGhost.image = #imageLiteral(resourceName: "ghostBubble")
        view.addSubview(imgGhost)
        imgGhost.isHidden = true // default hidden

    }
    
    func loadNavBar() {
        uiviewNavBar = FaeNavBar(frame: .zero)
        view.addSubview(uiviewNavBar)
        uiviewNavBar.rightBtn.isHidden = true
        uiviewNavBar.loadBtnConstraints()
        uiviewNavBar.lblTitle.text = "Add Username"
        uiviewNavBar.leftBtn.addTarget(self, action: #selector(self.actionGoBack(_:)), for: .touchUpInside)
    }
    
    // Vicky 07/28/17
    // FaeSearchBarTestDelegate
    func searchBar(_ searchBar: FaeSearchBarTest, textDidChange searchText: String) {}
    func searchBarTextDidBeginEditing(_ searchBar: FaeSearchBarTest) {
        schbarUsernames.txtSchField.becomeFirstResponder()
    }
    func searchBarSearchButtonClicked(_ searchBar: FaeSearchBarTest) {
        if !boolSearched {
            filter(searchText: searchBar.txtSchField.text!)
        }
    }
    func searchBarCancelButtonClicked(_ searchBar: FaeSearchBarTest) {
        filter(searchText: "")
    }
    // End of FaeSearchBarTestDelegate
    
    func filter(searchText: String) {
        boolSearched = true
        filtered.removeAll()
        if searchText == "" {
            self.tblUsernames.reloadData()
            boolSearched = false
            return
        }
        
        let faeUser = FaeUser()
        faeUser.whereKey("user_name", value: searchText)
        indicatorView.startAnimating()
        faeUser.checkUserExistence() {(status: Int, message: Any?) in
            if status / 100 == 2 {
                let json = JSON(message!)
                if !json["existence"].boolValue {
                    self.tblUsernames.reloadData()
                    self.boolSearched = false
                    self.indicatorView.stopAnimating()
                    return
                }
                let userId = json["user_id"].intValue
                faeUser.getUserCard(String(userId)) {(status: Int, message: Any?) in
                    if status / 100 == 2 {
                        let json = JSON(message!)
                        let userInfo = UserNameCard(user_id: userId, nick_name: json["nick_name"].stringValue, user_name: json["user_name"].stringValue)
                        self.filtered.append(userInfo)
                        self.tblUsernames.reloadData()
                    } else {
                        print("[get user name card fail] \(status) \(message!)")
                    }
                    self.boolSearched = false
                    self.indicatorView.stopAnimating()
                }
            } else {
                print("[check user existence fail] \(status) \(message!)")
                self.boolSearched = false
                self.indicatorView.stopAnimating()
            }
        }
    }
    // End of Vicky 07/28/17
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if schbarUsernames.txtSchField.text != "" {
            tblUsernames.isHidden = false
            if filtered.count == 0 { // this means no results.
                imgGhost.isHidden = false
            } else {
                imgGhost.isHidden = true
            }
            return filtered.count
        } else {
            tblUsernames.isHidden = true
            imgGhost.isHidden = true
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FaeAddUsernameCell", for: indexPath) as! FaeAddUsernameCell
        let user = filtered[indexPath.row]
        if schbarUsernames.txtSchField.text != "" {
            /*
            cell.userId = user.userId
            var findRes = false
            if !findRes {
                for friend in arrFriends {
                    if friend.userId == cell.userId {
                        cell.friendStatus = .accepted
                        findRes = true
                        break
                    }
                }
            }
            
            if !findRes {
                for friend in arrReceivedRequests {
                    if friend.userId == cell.userId {
                        cell.friendStatus = .requested
                        cell.requestId = friend.requestId
                        findRes = true
                        break
                    }
                }
            }
            
            if !findRes {
                for friend in arrRequested {
                    if friend.userId == cell.userId {
                        cell.friendStatus = .pending
                        cell.requestId = friend.requestId
                        findRes = true
                        break
                    }
                }
            }
            */
            cell.indexPath = indexPath
            cell.delegate = self
            cell.setValueForCell(user: user)
            cell.userId = user.userId
            cell.getFriendStatus(id: cell.userId)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 74
    }
    
    @objc func tapOutsideToDismissKeyboard(_ sender: UITapGestureRecognizer) {
        schbarUsernames.txtSchField.resignFirstResponder()
    }

    // FaeAddUsernameDelegate
    func addFriend(indexPath: IndexPath, user_id: Int) {
        let vc = FriendOperationFromContactsViewController()
        vc.delegate = self
        vc.action = "add"
        vc.userId = user_id
        vc.indexPath = indexPath
        vc.modalPresentationStyle = .overCurrentContext
        present(vc, animated: false)
    }
    
    func resendRequest(indexPath: IndexPath, user_id: Int) {
        let vc = FriendOperationFromContactsViewController()
        vc.delegate = self
        vc.action = "resend"
        vc.userId = user_id
        vc.indexPath = indexPath
        vc.modalPresentationStyle = .overCurrentContext
        present(vc, animated: false)
    }
    
    func acceptRequest(indexPath: IndexPath, request_id: Int) {
        let vc = FriendOperationFromContactsViewController()
        vc.delegate = self
        vc.action = "accept"
        vc.requestId = request_id
        vc.indexPath = indexPath
        vc.modalPresentationStyle = .overCurrentContext
        present(vc, animated: false)
    }
    
    func ignoreRequest(indexPath: IndexPath, request_id: Int) {
        let vc = FriendOperationFromContactsViewController()
        vc.delegate = self
        vc.action = "ignore"
        vc.requestId = request_id
        vc.indexPath = indexPath
        vc.modalPresentationStyle = .overCurrentContext
        present(vc, animated: false)
    }
    
    func withdrawRequest(indexPath: IndexPath, request_id: Int) {
        let vc = FriendOperationFromContactsViewController()
        vc.delegate = self
        vc.action = "withdraw"
        vc.requestId = request_id
        vc.indexPath = indexPath
        vc.modalPresentationStyle = .overCurrentContext
        present(vc, animated: false)
    }
    // FaeAddUsernameDelegate End
    
    // FriendOperationFromContactsDelegate
    func passFriendStatusBack(indexPath: IndexPath) {
        tblUsernames.reloadRows(at: [indexPath], with: .none)
    }
    // FriendOperationFromContactsDelegate End
}
