//
//  InitialPageController.swift
//  faeBeta
//
//  Created by Yue on 6/23/17.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit
import Firebase

class InitialPageController: UIPageViewController {
    
    let firebase = Database.database().reference().child(fireBaseRef)
    var timerLoadMessages: Timer!
    
    lazy var arrViewCtrl: [UIViewController] = {
        let faeMap = FaeMapViewController()
        let mapBoard = MapBoardViewController()
        return [faeMap, mapBoard]
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let faeMap = arrViewCtrl.first {
            self.setViewControllers([faeMap], direction: .forward, animated: false, completion: nil)
        }
        //loadRecents()
        FaeChat().updateFriendsList()
        FaeChat().observeMessageChange()
        timerLoadMessages = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(updateMessages), userInfo: nil, repeats: true)
    }
    
    func goToFaeMap() {
        if let faeMap = arrViewCtrl.first {
            self.setViewControllers([faeMap], direction: .forward, animated: true, completion: nil)
        }
    }
    
    func goToMapBoard() {
        if let mapBoard = arrViewCtrl.last {
            self.setViewControllers([mapBoard], direction: .forward, animated: true, completion: nil)
        }
    }
    
    func updateMessages() {
        FaeChat().getMessageFromServer()
    }
    
    func loadRecents() {
        getFromURL("chats", parameter: nil, authentication: headerAuthentication()) { _, result in
            if let cacheRecent = result as? NSArray {
                for item in cacheRecent {
                    let recent: NSDictionary = item as! NSDictionary
                    let chatRoomId = Key.shared.user_id < recent["with_user_id"] as! Int ? "\(Key.shared.user_id)-\(recent["with_user_id"] ?? "")" : "\(recent["with_user_id"] ?? "")-\(Key.shared.user_id)"
                    self.firebase.child(chatRoomId).keepSynced(true)
                }
            }
        }
    }
    
}
