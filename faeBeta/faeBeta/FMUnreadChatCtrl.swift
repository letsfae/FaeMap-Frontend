//
//  UnreadChatTableView.swift
//  faeBeta
//
//  Created by Yue on 8/9/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
import SwiftyJSON
import RealmSwift

// MARK: Show unread chat tableView
extension FaeMapViewController {
    
    func loadMapChat() {
        lblUnreadCount.isHidden = true
        updateUnreadChatIndicator()
        if Key.shared.user_id != -1 {
            //faeChat.updateFriendsList()
        }
        if faeChat.notificationRunLoop == nil {
            // each call will start a run loop, so only initialize one
            faeChat.observeMessageChange()
        }
    }
    
    func updateUnreadChatIndicator() {
        let realm = try! Realm()
        let resultRealmRecents = realm.objects(RealmRecentMessage.self).filter("login_user_id == %@", String(Key.shared.user_id))
        unreadNotiToken = resultRealmRecents.observe { (changes: RealmCollectionChange) in
            switch changes {
            case .initial:
                self.setupUnreadNum(resultRealmRecents)
            case .update:
                self.setupUnreadNum(resultRealmRecents)
            case .error:
                break
            }
        }
    }
    
    func setupUnreadNum(_ currentRecents: Results<RealmRecentMessage>) {
        var unreadCount = 0
        for recent in currentRecents {
            unreadCount += recent.unread_count
        }
        lblUnreadCount.text = unreadCount > 99 ? "•••" : "\(unreadCount)"
        lblUnreadCount.frame.size.width = unreadCount / 10 >= 1 ? 28 : 22
        btnOpenChat.isSelected = unreadCount != 0
        lblUnreadCount.isHidden = unreadCount == 0
        UIApplication.shared.applicationIconBadgeNumber = unreadCount
    }
}
