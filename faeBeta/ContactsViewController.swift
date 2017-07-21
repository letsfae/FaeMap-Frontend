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

struct cellData {
    var Image = UIImage()
    var name: String
    var saying: String?
    var requestUserId: Int = -1
    var userId: Int = -1
    
    init(name: String) {
        self.name = name
    }
    init(name: String, requestUserId: Int) {
        self.name = name
        self.requestUserId = requestUserId
    }
    init(name: String, userId: Int) {
        self.name = name
        self.userId = userId
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
    var testArrayFriends: [cellData] = [] // testArray; will replace once backend API is ready.
    var testArrayReceivedRequests: [cellData] = [] // testArray; will replace once backend API is ready.
    var testArrayRequested: [String] = ["testOne", "testTwo", "testThree", "testFour"] // testArray; will replace once backend API is ready.
    var tblContacts: UITableView!
    var filtered: [cellData] = []
    var schbarContacts: FaeSearchBar!
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
                    self.testArrayReceivedRequests.append(cellData(name: json[i-1]["request_user_nick_name"].stringValue, requestUserId: json[i-1]["request_user_id"].intValue))
                }
            }
            self.tblContacts.reloadData()
        }
        apiCalls.getFriends() {(status: Int, message: Any?) in
            self.testArrayFriends = []
            let json = JSON(message!)
            if json.count != 0 {
                for i in 1...json.count {
                    self.testArrayFriends.append(cellData(name: json[i-1]["friend_user_nick_name"].stringValue, userId: json[i-1]["friend_id"].intValue))
                }
            }
            self.tblContacts.reloadData()
        }

        loadTable()
        loadNavBar()
        setupViews()
        definesPresentationContext = true
    }
    
}
