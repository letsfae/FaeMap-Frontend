//
//  ContactsViewController.swift
//  FaeContacts
//
//  Created by Yue on 6/13/17.
//  Copyright © 2017 Yue. All rights reserved.
//

import UIKit
import SwiftyJSON
import Contacts
import ContactsUI
import RealmSwift
/* Contacts View Controller
 
 This is the view controller for the very first UI of the contacts_faemap build.
 It is made up of various extensions, named as of now: YingChen.swift, JustinHe.swift, and WenJia.swift.
 
*/

struct Friends {
    var displayName: String
    var userName: String
    var saying: String?
    var requestId: Int = -1
    var userId: Int = -1
    
    init(displayName: String, userName: String, userId: Int, requestId: Int) {
        self.displayName = displayName
        self.userName = userName
        self.userId = userId
        self.requestId = requestId
    }
    init(displayName: String, userName: String, userId: Int) {
        self.displayName = displayName
        self.userName = userName
        self.userId = userId
    }
}

struct Follows {
    var displayName: String
    var userName: String
    var saying: String?
    var followeeId: Int = -1
    var followerId: Int = -1
    
    init(followeeJson: JSON) {
        displayName = followeeJson["followee_user_nick_name"].stringValue
        userName = followeeJson["followee_user_name"].stringValue
        followeeId = followeeJson["followee_id"].intValue
    }
    
    init(followerJson: JSON) {
        displayName = followerJson["follower_user_nick_name"].stringValue
        userName = followerJson["follower_user_name"].stringValue
        followerId = followerJson["follower_id"].intValue
    }
}

struct Relations {
    let is_friend: Bool
    let requested: Bool // I've sent request to others
    let requested_by: Bool  // others have sent request to me
    let blocked: Bool  // I blocked others
    let blocked_by: Bool  // others blocked me
    let followed: Bool  // I followed others
    let followed_by: Bool  // others followed me
    
    init(json: JSON) {
        is_friend = json["is_friend"].boolValue
        requested = json["friend_requested"].boolValue
        requested_by = json["friend_requested_by"].boolValue
        blocked = json["blocked"].boolValue
        blocked_by = json["blocked_by"].boolValue
        followed = json["followed"].boolValue
        followed_by = json["followed_by"].boolValue
    }
}

class ContactsViewController: UIViewController, ContactsReceivedRequestsDelegate, ContactsRequestedDelegate {
    
    static func loadFriendsList() {
        let realmUser = RealmUser(value: ["\(Key.shared.user_id)_\(Key.shared.user_id)", String(Key.shared.user_id), String(Key.shared.user_id), Key.shared.username, Key.shared.nickname, MYSELF, Key.shared.age, true, Key.shared.gender, true, "", ""])
        let realm = try! Realm()
        try! realm.write {
            realm.add(realmUser, update: true)
        }
        let realmFae = RealmUser(value: ["\(Key.shared.user_id)_1", String(Key.shared.user_id), "1", "Fae Maps Team", "Fae Maps Team", IS_FRIEND, "", true, "", true])
        let realmFaeAvatar = UserImage()
        realmFaeAvatar.user_id = "1"
        realmFaeAvatar.userSmallAvatar = RealmChat.compressImageToData(UIImage(named: "faeAvatar")!)! as NSData
        try! realm.write {
            realm.add(realmFae, update: true)
            realm.add(realmFaeAvatar, update: true)
        }
        FaeContact().getFriends() {(status, message) in
            if status / 100 == 2 {
                let messageJSON = JSON(message!)
                for (_, user):(String, JSON) in messageJSON {
                    RealmUser.getUpdated([user["friend_id"].stringValue, user["friend_user_name"].stringValue, user["friend_user_nick_name"].stringValue, user["friend_user_age"].stringValue, user["friend_user_gender"].stringValue, ""], with: IS_FRIEND)
                    /*let user_id = user["friend_id"].stringValue
                    let user_name = user["friend_user_name"].stringValue
                    let display_name = user["friend_user_nick_name"].stringValue
                    let age = user["friend_user_age"].stringValue
                    let show_age = age != ""
                    let gender = user["friend_user_gender"].stringValue
                    let show_gender = gender != ""
                    let realm = try! Realm()
                    if let userExist = realm.filterUser(id: user_id) {
                        try! realm.write {
                            userExist.user_name = user_name
                            userExist.display_name = display_name
                            userExist.relation = IS_FRIEND
                            userExist.age = age
                            userExist.show_age = show_age
                            userExist.gender = gender
                            userExist.show_gender = show_gender
                        }
                    } else {
                        let realmUser = RealmUser(value: ["\(Key.shared.user_id)_\(user_id)", "\(Key.shared.user_id)", user_id, user_name, display_name, IS_FRIEND, age, show_age, gender, show_gender])
                        try! realm.write {
                            realm.add(realmUser)
                        }
                        General.shared.avatar(userid: Int(user_id)!) {_ in }
                    }*/
                }
            } else if status == 500 { // TODO: error code undecided
                
            } else {
                
            }
        }
    }
    
    static func loadReceivedFriendRequests() {
        FaeContact().getFriendRequests { (status, message) in
            if status / 100 == 2 {
                let messageJSON = JSON(message!)
                for (_, user):(String, JSON) in messageJSON {
                    RealmUser.getUpdated([user["request_user_id"].stringValue, user["request_user_name"].stringValue, user["request_user_nick_name"].stringValue, user["request_user_age"].stringValue, user["request_user_gender"].stringValue, RealmChat.formatDate(str: user["created_at"].stringValue)], with: FRIEND_REQUESTED_BY)
                    /*let user_id = user["request_user_id"].stringValue
                    let created_at = RealmChat.formatDate(str: user["created_at"].stringValue)
                    let realmUser = RealmUser(value: ["\(Key.shared.user_id)_\(user_id)", "\(Key.shared.user_id)", user_id, user["request_user_name"].stringValue, user["request_user_nick_name"].stringValue, FRIEND_REQUESTED_BY, user["request_user_age"].stringValue, user["request_user_gender"].stringValue, "", created_at])
                    let realm = try! Realm()
                    try! realm.write {
                        realm.add(realmUser, update: true)
                    }
                    General.shared.avatar(userid: Int(user_id)!) {_ in }*/
                }
            } else if status == 500 {
                
            } else { // TODO: error code undecided
                
            }
        }
    }
    
    static func loadSentFriendRequests() {
        FaeContact().getFriendRequestsSent { (status, message) in
            if status / 100 == 2 {
                let messageJSON = JSON(message!)
                for (_, user):(String, JSON) in messageJSON {
                    RealmUser.getUpdated([user["requested_user_id"].stringValue, user["requested_user_name"].stringValue, user["requested_user_nick_name"].stringValue, user["requested_user_age"].stringValue, user["requested_user_gender"].stringValue, RealmChat.formatDate(str: user["created_at"].stringValue)], with: FRIEND_REQUESTED)
                    /*let user_id = user["requested_user_id"].stringValue
                    let created_at = RealmChat.formatDate(str: user["created_at"].stringValue)
                    let realmUser = RealmUser(value: ["\(Key.shared.user_id)_\(user_id)", "\(Key.shared.user_id)", user_id, user["requested_user_name"].stringValue, user["requested_user_nick_name"].stringValue, FRIEND_REQUESTED, user["requested_user_age"].stringValue, user["requested_user_gender"].stringValue, "", created_at])
                    let realm = try! Realm()
                    try! realm.write {
                        realm.add(realmUser, update: true)
                    }
                    General.shared.avatar(userid: Int(user_id)!) {_ in }*/
                }
            } else if status == 500 {
                
            } else { // TODO: error code undecided
                
            }
        }
    }
    
    static func loadBlockedList() {
        
    }
    
    // YingChen.swift variable declaration for UI objects
    var uiviewNavBar: FaeNavBar!
    var uiviewDropDownMenu: UIView!
    var btnTop: UIButton!
    var btnBottom: UIButton!
    var lblTop: UILabel!
    var lblBottom: UILabel!
    var imgTick: UIImageView!
    var imgDot: UIImageView!
    var navBarMenuBtnClicked = false
    var curtTitle: String = "Friends"
    var titleArray: [String] = ["Friends", "Requests"] //["Following", "Followers"]
    var btnNavBarMenu: UIButton!
    var contactStore = CNContactStore()
    
    var realmFriends: Results<RealmUser>!
    var realmReceivedRequests: Results<RealmUser>!
    var realmSentRequests: Results<RealmUser>!
    
    // JustinHe.swift variable declaration for UI objects
    //var arrFriends: [Friends] = []
    var arrRealmFriends: [RealmUser] = []
    var arrDeletedFriendsIDs: [String] = []
    var arrAddedFriendsIDs: [String] = []
    //var arrReceivedRequests: [Friends] = []
    var arrRealmReceivedRequests: [RealmUser] = []
    var arrDeletedReceived: [String] = []
    //var arrRequested: [Friends] = []
    var arrRealmRequested: [RealmUser] = []
    var arrDeletedRequested: [String] = []
    var arrFollowers: [Follows] = []
    var arrFollowees: [Follows] = []

    var tblContacts: UITableView!
    //var filtered: [Friends] = []
    var filteredRealm: [RealmUser] = []
    var filteredFollows: [Follows] = []
    var schbarContacts: FaeSearchBarTest!
    var uiviewSchbar: UIView!
    var uiviewBottomNav: UIView!
    var btnFFF: UIButton! // btnFFF switches to friends, following, followed.
    var btnRR: UIButton! // btnRR switches to requests, requested.
    var cellStatus = 0 // 3 cases: 1st case is Contacts - 0, 2nd is RecievedRequests - 1, 3rd is Requested - 2.
                       // This is used to switch out cell types and cells in the main table (tblContacts)
    
    // attempting api calls to pull some information.
    let apiCalls = FaeContact()
    
    // Wenjia.swift variable declaration for UI objects.
    var uiviewTabView: UIView!
    var btnReceived: UIButton!
    var btnRequested: UIButton!
    var uiviewBottomLine: UIView!
    var uiviewRedBottomLine: UIView!
    var indicatorView: UIActivityIndicatorView!
    
    // NotificationExtension.swift variable declaration for UI objects
    var uiviewChooseAction: UIView!
    var uiviewNotification: UIView!
    var lblTitleInActions: UILabel!
    var btnForIgnore: UIButton!
    var btnForBlock: UIButton!
    var btnForReport: UIButton!
    var btnForCancel: UIButton!
    var btnClose: UIButton!
    var lblNotificationText: UILabel!
    var lblBlockSetting: UILabel!
    var btnYes: UIButton!
    var uiviewOverlayGrayOpaque: UIView!
    var indexPathGlobal: IndexPath!
    var idGlobal = -1
    var countFriends = 0
    var countReceived = 0
    var countSent = 0
    var countRequests = 0
    
    var faeScrollBar: FaeScrollBar?
    let floatBtnRange = screenHeight - 120 - 30 - 6 - device_offset_top - device_offset_bot
    
    let OK = 0
    let WITHDRAW = 3
    let RESEND = 4
    let REMOVE = 5
    let BLOCK = 6
    let REPORT = 7
    let ACCEPT = 9
    let IGNORE = 10
    
    var resultsRealmFriends: Results<RealmUser>!
    var notificationToken: NotificationToken? = nil
    
    var uiviewNameCard = FMNameCardView()
    // Basic viewDidLoad() implementation, needed for start of program
    override func viewDidLoad() {
        super.viewDidLoad()
        getFriendStatus()
        loadSearchBar()
        loadTable()
        loadNavBar()
        loadTabView()
        loadNameCard()
        setupViews()
        //setupScrollBar()
        view.backgroundColor = .white
        definesPresentationContext = true
        //observeOnFriendsChange()
        observeOnRelationChange()
    }
    
    deinit {
        notificationToken?.invalidate()
    }
    
    func getFriendStatus() {
        let realm = try! Realm()
        realmFriends = realm.filterFriends()
        realmReceivedRequests = realm.filterReceivedFriendRequest()
        realmSentRequests = realm.filterSentFriendRequest()
        //getFriendsList()
        //getSentRequests()
        //getReceivedRequests()
        
        /*apiCalls.getFollowees(userId: String(Key.shared.user_id)) {(status: Int, message: Any?) in
            self.arrFollowees = []
            if status / 100 == 2 {
                let json = JSON(message!)
                guard let followeeJson = json.array else {
                    print("[loadFolloweeInfoFail] - fail to parse")
                    return
                }
                for followee in followeeJson {
                    let followeeData = Follows(followeeJson: followee)
                    self.arrFollowees.append(followeeData)
                }
            } else {
                print("[loadFolloweeInfoFail] - \(status) \(message!)")
            }
        }
        
        apiCalls.getFollowers(userId: String(Key.shared.user_id)) {(status: Int, message: Any?) in
            self.arrFollowers = []
            if status / 100 == 2 {
                let json = JSON(message!)
                guard let followerJson = json.array else {
                    print("[loadFollowerInfoFail] - fail to parse")
                    return
                }
                for follower in followerJson {
                    let followerData = Follows(followerJson: follower)
                    self.arrFollowers.append(followerData)
                }
            } else {
                print("[loadFollowerInfoFail] - \(status) \(message!)")
            }
        }*/
    }
    
    func getFriendsList() {
        let realm = try! Realm()
        resultsRealmFriends = realm.filterFriends()
        arrRealmFriends = []
        for user in resultsRealmFriends {
            if user.relation & IS_FRIEND == IS_FRIEND {
                arrRealmFriends.append(user)
                arrDeletedFriendsIDs.append(user.id)
            }
        }
        apiCalls.getFriends() {(status: Int, message: Any?) in
            //self.arrFriends = []
            let json = JSON(message!)
            if json.count != 0 {
                for i in 1...json.count {
                    let user_id = json[i - 1]["friend_id"].stringValue
                    let user_name = json[i - 1]["friend_user_name"].stringValue
                    let display_name = json[i - 1]["friend_user_nick_name"].stringValue
                    let user_age = json[i - 1]["friend_user_age"].stringValue
                    let user_gender = json[i - 1]["friend_user_gender"].stringValue
                    let realmUser = RealmUser(value: ["\(Key.shared.user_id)_\(user_id)", String(Key.shared.user_id), user_id, user_name, display_name, IS_FRIEND, user_age, user_age != "", user_gender, user_gender != ""])
                    var boolModified: Bool = false
                    let realm = try! Realm()
                    if let current = realm.filterUser(id: user_id) {
                        self.arrDeletedFriendsIDs = self.arrDeletedFriendsIDs.filter() { $0 != user_id }
                        //if realmUser.modified(current) {
                        if realmUser != current {
                            boolModified = true
                            if current.relation == NO_RELATION {
                                self.arrAddedFriendsIDs.append(user_id)
                            }
                        }
                    } else {
                        boolModified = true
                        self.arrAddedFriendsIDs.append(user_id)
                    }
                    if boolModified {
                        try! realm.write {
                            realm.add(realmUser, update: true)
                        }
                        General.shared.avatar(userid: Int(user_id)!) { _ in }
                    }
                    //self.arrFriends.append(Friends(displayName: json[i-1]["friend_user_nick_name"].stringValue, userName: json[i-1]["friend_user_name"].stringValue, userId: json[i-1]["friend_id"].intValue))
                }
                let realm = try! Realm()
                self.arrDeletedFriendsIDs = self.arrDeletedFriendsIDs.filter() { $0 != "1" }
                realm.beginWrite()
                for deleted in self.arrDeletedFriendsIDs {
                    if let user = realm.filterUser(id: deleted) {
                        user.relation = NO_RELATION
                    }
                }
                try! realm.commitWrite()
            }
//            self.arrFriends.append(Friends(displayName: "Fae Maps Team", userName: "faemaps", userId: 1))
//            self.arrFriends.sort{ $0.displayName < $1.displayName }
//            self.countFriends = self.arrFriends.count
//            self.tblContacts.reloadData()
            guard let prefix = self.arrRealmFriends.first?.display_name else { return }
            self.faeScrollBar?.setPrefixLable((prefix as NSString).substring(to: 1))
            //self.setupScrollBar()
        }

    }
    
    func getSentRequests() {
        arrRealmRequested = []
        for user in resultsRealmFriends {
            if user.relation & FRIEND_REQUESTED == FRIEND_REQUESTED {
                arrRealmRequested.append(user)
                arrDeletedRequested.append(user.id)
            }
        }
        arrRealmRequested.sort { $0.created_at < $1.created_at }
        apiCalls.getFriendRequestsSent() {(status: Int, message: Any?) in
            //self.arrRequested = []
            let json = JSON(message!)
            if json.count != 0 {
                for i in 1...json.count {
                    //let request_id = json[i - 1]["friend_request_id"].stringValue
                    let user_id = json[i - 1]["requested_user_id"].stringValue
                    let user_name = json[i - 1]["requested_user_name"].stringValue
                    let display_name = json[i - 1]["requested_user_nick_name"].stringValue
                    let user_age = json[i - 1]["requested_user_age"].stringValue
                    let user_gender = json[i - 1]["requested_user_gender"].stringValue
                    let created_at = RealmChat.formatDate(str: json[i - 1]["created_at"].stringValue)
                    let realmUser = RealmUser(value: ["\(Key.shared.user_id)_\(user_id)", String(Key.shared.user_id), user_id, user_name, display_name, FRIEND_REQUESTED, user_age, user_age != "", user_gender, user_gender != "", "", created_at])
                    var boolModified: Bool = false
                    let realm = try! Realm()
                    if let current = realm.filterUser(id: user_id) {
                        self.arrDeletedRequested = self.arrDeletedRequested.filter() { $0 != user_id }
                        if realmUser != current {
                            boolModified = true
                        }
                    } else {
                        boolModified = true
                    }
                    if boolModified {
                        try! realm.write {
                            realm.add(realmUser, update: true)
                        }
                        General.shared.avatar(userid: Int(user_id)!) { _ in }
                    }
                    //self.arrRequested.append(Friends(displayName: json[i-1]["requested_user_nick_name"].stringValue, userName: json[i-1]["requested_user_name"].stringValue, userId: json[i-1]["requested_user_id"].intValue, requestId: json[i-1]["friend_request_id"].intValue))
                }
                let realm = try! Realm()
                realm.beginWrite()
                for deleted in self.arrDeletedRequested {
                    if let user = realm.filterUser(id: deleted) {
                        user.relation = NO_RELATION
                    }
                }
                try! realm.commitWrite()
            }
            self.countSent = self.arrRealmRequested.count
            //self.tblContacts.reloadData()
        }
    }
    
    func getReceivedRequests() {
        arrRealmReceivedRequests = []
        for user in resultsRealmFriends {
            if user.relation & FRIEND_REQUESTED_BY == FRIEND_REQUESTED_BY {
                arrRealmReceivedRequests.append(user)
                arrDeletedReceived.append(user.id)
            }
        }
        arrRealmReceivedRequests.sort { $0.created_at < $1.created_at }
        apiCalls.getFriendRequests() {(status: Int, message: Any?) in
            //self.arrReceivedRequests = []
            let json = JSON(message!)
            if json.count != 0 {
                for i in 1...json.count {
                    //let request_id = json[i - 1]["friend_request_id"].stringValue
                    let user_id = json[i - 1]["request_user_id"].stringValue
                    let user_name = json[i - 1]["request_user_name"].stringValue
                    let display_name = json[i - 1]["request_user_nick_name"].stringValue
                    let user_age = json[i - 1]["request_user_age"].stringValue
                    let user_gender = json[i - 1]["request_user_gender"].stringValue
                    let created_at = RealmChat.formatDate(str: json[i - 1]["created_at"].stringValue)
                    let realmUser = RealmUser(value: ["\(Key.shared.user_id)_\(user_id)", String(Key.shared.user_id), user_id, user_name, display_name, FRIEND_REQUESTED_BY, user_age, user_age != "", user_gender, user_gender != "", "", created_at])
                    var boolModified: Bool = false
                    let realm = try! Realm()
                    if let current = realm.filterUser(id: user_id) {
                        self.arrDeletedReceived = self.arrDeletedReceived.filter() { $0 != user_id }
                        if realmUser != current {
                            boolModified = true
                        }
                    } else {
                        boolModified = true
                    }
                    if boolModified {
                        try! realm.write {
                            realm.add(realmUser, update: true)
                        }
                        General.shared.avatar(userid: Int(user_id)!) { _ in }
                    }
                    //self.arrReceivedRequests.append(Friends(displayName: json[i-1]["request_user_nick_name"].stringValue, userName: json[i-1]["request_user_name"].stringValue, userId: json[i-1]["request_user_id"].intValue, requestId: json[i-1]["friend_request_id"].intValue))
                }
                self.imgDot.isHidden = false
                let realm = try! Realm()
                realm.beginWrite()
                for deleted in self.arrDeletedReceived {
                    if let user = realm.filterUser(id: deleted) {
                        user.relation = NO_RELATION
                    }
                }
                try! realm.commitWrite()
            }
            self.countReceived = self.arrRealmReceivedRequests.count
            //self.tblContacts.reloadData()
        }
    }
    
    func observeOnFriendsChange() {
        notificationToken = resultsRealmFriends.observe { (changes: RealmCollectionChange) in
            switch changes {
            case .initial:
                felixprint("initial")
                //self.tblContacts.reloadData()
                self.setupScrollBar()
            case .update(_, let deletions, let insertions, let modifications):
                break
                //felixprint("contact update")
                /*for index in insertions {
                    let insertedUser = self.resultsRealmFriends[index]
                    if insertedUser.relation & IS_FRIEND == IS_FRIEND {
                        self.arrRealmFriends.append(insertedUser)
                        self.arrRealmFriends.sort { $0.display_name < $1.display_name }
                        let row = self.arrRealmFriends.index(of: insertedUser)!
                        if self.cellStatus == 0 {
                            UIView.setAnimationsEnabled(false)
                            self.tblContacts.beginUpdates()
                            self.tblContacts.insertRows(at: [IndexPath(row: row, section: 0)], with: .none)
                            self.tblContacts.endUpdates()
                            UIView.setAnimationsEnabled(true)                            
                        }
                    }
                    if insertedUser.relation & FRIEND_REQUESTED == FRIEND_REQUESTED {
                        self.arrRealmRequested.append(insertedUser)
                        self.arrRealmRequested.sort { $0.created_at < $1.created_at }
                    }
                    if insertedUser.relation & FRIEND_REQUESTED_BY == FRIEND_REQUESTED_BY {
                        self.arrRealmReceivedRequests.append(insertedUser)
                        self.arrRealmReceivedRequests.sort { $0.created_at < $1.created_at }
                    }
                }
                for index in modifications {
                    let modifiedUser = self.resultsRealmFriends[index]
                    if modifiedUser.relation & IS_FRIEND == IS_FRIEND {
                        if self.cellStatus == 0 {
                            if self.schbarContacts.txtSchField.text == "" {
                                if let row = self.arrRealmFriends.index(of: modifiedUser) {
                                    self.tblContacts.performUpdate( {
                                        self.tblContacts.reloadRows(at: [IndexPath(row: row, section: 0)], with: .none)
                                    }, completion: nil)
                                }
                            } else {
                                if let row = self.filteredRealm.index(of: modifiedUser) {
                                    self.tblContacts.performUpdate( {
                                        self.tblContacts.reloadRows(at: [IndexPath(row: row, section: 0)], with: .none)
                                    }, completion: nil)
                                }
                            }
                        }
                    }
                    if modifiedUser.relation & FRIEND_REQUESTED == FRIEND_REQUESTED {
                        self.arrRealmRequested.append(modifiedUser)
                        self.arrRealmRequested.sort { $0.created_at < $1.created_at }
                    }
                    if modifiedUser.relation & FRIEND_REQUESTED_BY == FRIEND_REQUESTED_BY {
                        self.arrRealmReceivedRequests.append(modifiedUser)
                        self.arrRealmReceivedRequests.sort { $0.created_at < $1.created_at }
                    }
                }
                if deletions.count > 0 {
                    for id in self.arrDeletedFriendsIDs {
                        let deleted = self.arrRealmFriends.filter() { $0.id == id }
                        if let row = self.arrRealmFriends.index(of: deleted[0]) {
                            self.arrRealmFriends = self.arrRealmFriends.filter() { $0.id != id }
                            if self.cellStatus == 0 {
                                UIView.setAnimationsEnabled(false)
                                self.tblContacts.performUpdate( {
                                    self.tblContacts.deleteRows(at: [IndexPath(row: row, section: 0)], with: .none)
                                }, completion: {
                                    UIView.setAnimationsEnabled(true)
                                })
                            }
                        }
                    }
                    for id in self.arrDeletedReceived {
                        self.arrRealmReceivedRequests = self.arrRealmReceivedRequests.filter() { $0.id != id }
                    }
                    for id in self.arrDeletedRequested {
                        self.arrRealmRequested = self.arrRealmRequested.filter() { $0.id != id }
                    }
                }*/
            case .error:
                felixprint("error")
            }
        }
    }
    
    func observeOnRelationChange() {
        var tableDataSource: Results<RealmUser>!
        if cellStatus == 1 {
            tableDataSource = realmReceivedRequests
        } else if cellStatus == 2 {
            tableDataSource = realmSentRequests
        } else {
            tableDataSource = realmFriends
        }
        notificationToken?.invalidate()
        guard let tableView = tblContacts else { return }
        notificationToken = tableDataSource.observe { (changes: RealmCollectionChange) in
            switch changes {
            case .initial:
                felixprint("contacts initial")
                tableView.reloadData()
                self.setupScrollBar()
            case .update(_, let deletions, let insertions, let modifications):
                guard let seachBar = self.schbarContacts else { break }
                if self.cellStatus == 0 && seachBar.txtSchField.text != "" { break }
                UIView.setAnimationsEnabled(false)
                tableView.beginUpdates()
                tableView.insertRows(at: insertions.map({ IndexPath(row: $0, section: 0)}), with: .none)
                tableView.deleteRows(at: deletions.map({ IndexPath(row: $0, section: 0)}), with: .none)
                tableView.reloadRows(at: modifications.map({ IndexPath(row: $0, section: 0)}), with: .none)
                tableView.endUpdates()
                UIView.setAnimationsEnabled(true)
            case .error:
                felixprint("error")
            }
        }
    }
}
