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

class ContactsViewController: UIViewController, SomeDelegateReceivedRequests, SomeDelegateRequested {
    
    // YingChen.swift variable declaration for UI objects
    var uiviewNavBar: FaeNavBar!
    var uiviewDropDownMenu: UIView!
    var btnTop: UIButton!
    var btnBottom: UIButton!
    var lblTop: UILabel!
    var lblBottom: UILabel!
    var imgTick: UIImageView!
    var navBarMenuBtnClicked = false
    var curtTitle: String = "Friends"
    var titleArray: [String] = ["Friends", "Requests"] //["Following", "Followers"]
    var btnNavBarMenu: UIButton!
    var contactStore = CNContactStore()
    
    // JustinHe.swift variable declaration for UI objects
    var arrFriends: [Friends] = []
    var arrReceivedRequests: [Friends] = []
    var arrRequested: [Friends] = []
    var arrFollowers: [Follows] = []
    var arrFollowees: [Follows] = []

    var tblContacts: UITableView!
    var filtered: [Friends] = []
    var filteredFollows: [Follows] = []
    var schbarContacts: FaeSearchBarTest!
    var uiviewSchbar: UIView!
    var uiviewBottomNav: UIView!
    var btnFFF: UIButton! // btnFFF switches to friends, following, followed.
    var btnRR: UIButton! // btnRR switches to requests, requested.
    var cellStatus = 0 // 3 cases: 1st case is Contacts, 2nd is RecievedRequests, 3rd is Requested.
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
    
    let OK = 0
    let WITHDRAW = 3
    let RESEND = 4
    let REMOVE = 5
    let BLOCK = 6
    let REPORT = 7
    let ACCEPT = 9
    let IGNORE = 10
    
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
        view.backgroundColor = .white
        definesPresentationContext = true
    }
    
    func getFriendStatus() {
        getFriendsList()
        getSentRequests()
        getReceivedRequests()
        
        apiCalls.getFollowees(userId: String(Key.shared.user_id)) {(status: Int, message: Any?) in
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
        }
    }
    
    func getFriendsList() {
        apiCalls.getFriends() {(status: Int, message: Any?) in
            self.arrFriends = []
            let json = JSON(message!)
            if json.count != 0 {
                for i in 1...json.count {
                    self.arrFriends.append(Friends(displayName: json[i-1]["friend_user_nick_name"].stringValue, userName: json[i-1]["friend_user_name"].stringValue, userId: json[i-1]["friend_id"].intValue))
                }
            }
            self.arrFriends.sort{ $0.displayName < $1.displayName }
            self.countFriends = self.arrFriends.count
            self.tblContacts.reloadData()
        }
    }
    
    func getSentRequests() {
        apiCalls.getFriendRequestsSent() {(status: Int, message: Any?) in
            self.arrRequested = []
            let json = JSON(message!)
            if json.count != 0 {
                for i in 1...json.count {
                    self.arrRequested.append(Friends(displayName: json[i-1]["requested_user_nick_name"].stringValue, userName: json[i-1]["requested_user_name"].stringValue, userId: json[i-1]["requested_user_id"].intValue, requestId: json[i-1]["friend_request_id"].intValue))
                }
            }
            self.tblContacts.reloadData()
        }
    }
    
    func getReceivedRequests() {
        apiCalls.getFriendRequests() {(status: Int, message: Any?) in
            self.arrReceivedRequests = []
            let json = JSON(message!)
            if json.count != 0 {
                for i in 1...json.count {
                    self.arrReceivedRequests.append(Friends(displayName: json[i-1]["request_user_nick_name"].stringValue, userName: json[i-1]["request_user_name"].stringValue, userId: json[i-1]["request_user_id"].intValue, requestId: json[i-1]["friend_request_id"].intValue))
                }
            }
            self.tblContacts.reloadData()
        }
    }
}
