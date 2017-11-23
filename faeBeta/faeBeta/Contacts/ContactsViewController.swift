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

class ContactsViewController: UIViewController, SomeDelegateReceivedRequests, SomeDelegateRequested {
    
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
    var countReceived = 0
    var countSent = 0
    var countRequests = 0
    
    let lblPrefix: UILabel = {
        let label = UILabel(frame: CGRect(x: 10, y: 3, width: 12, height: 25))
        label.textAlignment = .left
        label.font = UIFont(name: "AvenirNext-DemiBold", size: 18)
        label.textColor = .white
        label.tag = 0
        return label
    }()
    
    let btnIndicator: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 23, height: 30))
        //button.backgroundColor = UIColor._2499090()
        //button.layer.cornerRadius = 3
        button.frame.origin.x = screenWidth - 23
        button.frame.origin.y = 120 + device_offset_top
        button.adjustsImageWhenHighlighted = false
        
        let uiviewBar = UIView(frame: CGRect(x: 15, y: 0, width: 3, height: 30))
        uiviewBar.backgroundColor = UIColor._2499090()
        uiviewBar.layer.cornerRadius = 3
        button.addSubview(uiviewBar)
        
        return button
    }()
    
    enum IndicatorState: String {
        case began
        case scrolling
        case end
    }
    var indicatorState: IndicatorState = .end
    var floatLongpressStart: CGFloat = 0.0
    var floatFingerToBtnTop: CGFloat = 0.0
    let floatBtnRange = screenHeight - 120 - 30 - 6 - device_offset_top - device_offset_bot
    
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
        setupScrollBar()
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
            self.arrFriends.append(Friends(displayName: "Fae Maps Team", userName: "faemaps", userId: 1))
            self.arrFriends.sort{ $0.displayName < $1.displayName }
            self.countFriends = self.arrFriends.count
            self.tblContacts.reloadData()
            guard let prefix = self.arrFriends.first?.displayName else { return }
            self.lblPrefix.text = (prefix as NSString).substring(to: 1)
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
            self.countSent = self.arrRequested.count
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
                self.imgDot.isHidden = false
            }
            self.countReceived = self.arrReceivedRequests.count
            self.tblContacts.reloadData()
        }
    }
}
