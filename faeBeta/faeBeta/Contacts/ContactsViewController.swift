//
//  ContactsViewController.swift
//  FaeContacts
//
//  Created by Yue on 6/13/17.
//  Copyright © 2017 Yue. All rights reserved.
//

import UIKit
import SwiftyJSON
/* Contacts View Controller
 
 This is the view controller for the very first UI of the contacts_faemap build.
 It is made up of various extensions, named as of now: YingChen.swift, JustinHe.swift, and WenJia.swift.
 
*/

struct Friends {
//    var Image = UIImage()
    var name: String
    var saying: String?
    var requestId: Int = -1
    var userId: Int = -1
    
    init(name: String) {
        self.name = name
    }
    init(name: String, userId: Int, requestId: Int) {
        self.name = name
        self.userId = userId
        self.requestId = requestId
    }
    init(name: String, userId: Int) {
        self.name = name
        self.userId = userId
    }
}

struct Follows {
    var name: String
    var saying: String?
    var followeeId: Int = -1
    var followerId: Int = -1
    
    init(followeeJson: JSON) {
        name = followeeJson["followee_user_nick_name"].stringValue
        followeeId = followeeJson["followee_id"].intValue
    }
    
    init(followerJson: JSON) {
        name = followerJson["follower_user_nick_name"].stringValue
        followerId = followerJson["follower_id"].intValue
    }
}

class ContactsViewController: UIViewController, SomeDelegateReceivedRequests, SomeDelegateRequested {
    

    // YingChen.swift variable declaration for UI objects
    var uiviewNavBar: FaeNavBar!
    var blurViewDropDownMenu: UIVisualEffectView!
    var btnTop: UIButton!
    var btnBottom: UIButton!
    var navBarMenuBtnClicked = false
    var curtTitle: String = "Friends"
    var titleArray: [String] = ["Following", "Followers"]
    var btnNavBarMenu: UIButton!
    
    // JustinHe.swift variable declaration for UI objects
    var testArrayFriends: [Friends] = [] // testArray; will replace once backend API is ready.
    var testArrayReceivedRequests: [Friends] = [] // testArray; will replace once backend API is ready.
    var testArrayRequested: [Friends] = []
    var arrFollowers: [Follows] = []
    var arrFollowees: [Follows] = []
//    var testArrayRequested: [String] = ["testOne", "testTwo", "testThree", "testFour"] // testArray; will replace once backend API is ready.
    var tblContacts: UITableView!
    var filtered: [Friends] = []
    var filteredFollows: [Follows] = []
    var schbarContacts: FaeSearchBarTest!
    var uiviewSchbar: UIView!
    var uiviewBottomNav: UIView!
    var btnFFF: UIButton! // btnFFF switches to friends, following, followed.
    var btnRR: UIButton! // btnRR switches to requests, requested.
    var cellStatus = 1 // 3 cases: 1st case is Contacts, 2nd is RecievedRequests, 3rd is Requested.
                       // This is used to switch out cell types and cells in the main table (tblContacts)
    
    // attempting api calls to pull some information.
    let apiCalls = FaeContact()
    
    // Wenjia.swift variable declaration for UI objects.
    var uiviewNavBar2: FaeNavBar!
    var uiviewTabView: UIView!
    var btnReceived: UIButton!
    var btnRequested: UIButton!
    var uiviewBottomLine: UIView!
    var uiviewRedBottomLine: UIView!
    
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
    
    let BLOCK = 0
    let WITHDRAW = 1
    let RESEND = 2
    let IGNORE = 4
    let ACCEPT = 5
    
    internal var notiContraint = [NSLayoutConstraint]() {
        didSet {
            if oldValue.count != 0 {
                self.view.removeConstraints(oldValue)
            }
            if notiContraint.count != 0 {
                self.view.addConstraints(notiContraint)
            }
        }
    }
    
    // Basic viewDidLoad() implementation, needed for start of program
    override func viewDidLoad() {
        super.viewDidLoad()
        apiCalls.getFriendRequests() {(status: Int, message: Any?) in
            self.testArrayReceivedRequests = []
            let json = JSON(message!)
            if json.count != 0 {
                for i in 1...json.count {
                    self.testArrayReceivedRequests.append(Friends(name: json[i-1]["request_user_nick_name"].stringValue, userId: json[i-1]["request_user_id"].intValue, requestId: json[i-1]["friend_request_id"].intValue))
                }
            }
            self.tblContacts.reloadData()
        }
        
        apiCalls.getFriendRequestsSent() {(status: Int, message: Any?) in
            self.testArrayRequested = []
            let json = JSON(message!)
            if json.count != 0 {
                for i in 1...json.count {
                    self.testArrayRequested.append(Friends(name: json[i-1]["requested_user_nick_name"].stringValue, userId: json[i-1]["requested_user_id"].intValue, requestId: json[i-1]["friend_request_id"].intValue))
                }
            }
            self.tblContacts.reloadData()
        }
        
        apiCalls.getFriends() {(status: Int, message: Any?) in
            self.testArrayFriends = []
            let json = JSON(message!)
            if json.count != 0 {
                for i in 1...json.count {
                    self.testArrayFriends.append(Friends(name: json[i-1]["friend_user_nick_name"].stringValue, userId: json[i-1]["friend_id"].intValue))
                }
            }
            self.tblContacts.reloadData()
        }
        
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
        
        loadTable()
        loadNavBar()
        setupViews()
        definesPresentationContext = true
    }
    
}
