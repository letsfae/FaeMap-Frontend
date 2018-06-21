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

class ContactsViewController: UIViewController {
    
    // MARK: - Static functions
    //         to pull latest friend list, received requests, sent requests, and block list
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
        var setDeletedFriends = Set(realm.filterFriends().map { $0.id })
        FaeContact().getFriends() {(status, message) in
            if status / 100 == 2 {
                let messageJSON = JSON(message!)
                for (_, user):(String, JSON) in messageJSON {
                    RealmUser.getUpdated([user["friend_id"].stringValue, user["friend_user_name"].stringValue, user["friend_user_nick_name"].stringValue, user["friend_user_age"].stringValue, user["friend_user_gender"].stringValue, ""], with: IS_FRIEND)
                    setDeletedFriends.remove(user["friend_id"].stringValue)
                }
                setDeletedFriends.remove("1")
                let realm = try! Realm()
                for userId in setDeletedFriends {
                    if let user = realm.filterUser(id: userId) {
                        try! realm.write {
                            user.relation = NO_RELATION
                        }
                    }
                }
            } else if status == 500 { // TODO: error code undecided
                
            } else {
                
            }
        }
    }
    
    static func loadReceivedFriendRequests() {
        let realm = try! Realm()
        var setDeletedReceived = Set(realm.filterReceivedFriendRequest().map { $0.id })
        FaeContact().getFriendRequests { (status, message) in
            if status / 100 == 2 {
                let messageJSON = JSON(message!)
                for (_, user):(String, JSON) in messageJSON {
                    RealmUser.getUpdated([user["request_user_id"].stringValue, user["request_user_name"].stringValue, user["request_user_nick_name"].stringValue, user["request_user_age"].stringValue, user["request_user_gender"].stringValue, RealmUser.formateTime(user["created_at"].stringValue)], with: FRIEND_REQUESTED_BY)
                    setDeletedReceived.remove(user["request_user_id"].stringValue)
                }
                let realm = try! Realm()
                for userId in setDeletedReceived {
                    if let user = realm.filterUser(id: userId) {
                        try! realm.write {
                            user.relation = NO_RELATION
                        }
                    }
                }
            } else if status == 500 {
                
            } else { // TODO: error code undecided
                
            }
        }
    }
    
    static func loadSentFriendRequests() {
        let realm = try! Realm()
        var setDeletedSent = Set(realm.filterSentFriendRequest().map { $0.id })
        FaeContact().getFriendRequestsSent { (status, message) in
            if status / 100 == 2 {
                let messageJSON = JSON(message!)
                for (_, user):(String, JSON) in messageJSON {
                    RealmUser.getUpdated([user["requested_user_id"].stringValue, user["requested_user_name"].stringValue, user["requested_user_nick_name"].stringValue, user["requested_user_age"].stringValue, user["requested_user_gender"].stringValue, RealmUser.formateTime(user["created_at"].stringValue)], with: FRIEND_REQUESTED)
                    setDeletedSent.remove(user["requested_user_id"].stringValue)
                }
                let realm = try! Realm()
                for userId in setDeletedSent {
                    if let user = realm.filterUser(id: userId) {
                        try! realm.write {
                            user.relation = NO_RELATION
                        }
                    }
                }
            } else if status == 500 {
                
            } else { // TODO: error code undecided
                
            }
        }
    }
    
    static func loadBlockedList() {
        
    }
    
    // MARK: - Properties
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

    var tblContacts: UITableView!
    var filteredRealm: [RealmUser] = []
    var schbarContacts: FaeSearchBarTest!
    var uiviewSchbar: UIView!
    var uiviewBottomNav: UIView!
    var btnFFF: UIButton! /// btnFFF switches to friends, following, followed.
    var btnRR: UIButton! /// btnRR switches to requests, requested.
    var cellStatus = 0 /// 3 cases: 1st case is Contacts - 0, 2nd is RecievedRequests - 1, 3rd is Requested - 2.
                       /// This is used to switch out cell types and cells in the main table (tblContacts)
    
    let apiCalls = FaeContact()
    var indicatorView: UIActivityIndicatorView!
    
    /// ContactsNotificationCtrl.swift variable declaration for UI objects
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
    
    private var notificationToken: NotificationToken? = nil
    
    var uiviewNameCard = FMNameCardView()
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        getFriendStatus()
        loadSearchBar()
        loadTable()
        loadNavBar()
        loadTabView()
        loadNameCard()
        setupPopupViews()
        view.backgroundColor = .white
        definesPresentationContext = true
        switchRealmObserverTarget()
    }
    
    deinit {
        notificationToken?.invalidate()
    }
    
    // MARK: - initialize data source of tableView
    func getFriendStatus() {
        let realm = try! Realm()
        realmFriends = realm.filterFriends()
        realmReceivedRequests = realm.filterReceivedFriendRequest()
        realmSentRequests = realm.filterSentFriendRequest()
    }
    
    func switchRealmObserverTarget() {
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
        notificationToken = tableDataSource.observe { [weak self] (changes: RealmCollectionChange) in
            guard let `self` = self else { return }
            switch changes {
            case .initial:
                felixprint("contacts initial")
                tableView.reloadData()
                tableView.scrollToTop(animated: false)
                tableView.layoutIfNeeded()
                if self.cellStatus == 0 {
                    self.setupScrollBar()
                }
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
