//
//  UnreadChatTableView.swift
//  faeBeta
//
//  Created by Yue on 8/9/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
import SwiftyJSON

// MARK: Show unread chat tableView
extension FaeMapViewController {
    
    func loadMapChat() {
        lblUnreadCount.isHidden = true
        updateUnreadChatIndicator()
        if Key.shared.user_id != -1 {
            faeChat.updateFriendsList()
        }
        if faeChat.notificationRunLoop == nil {
            // each call will start a run loop, so only initialize one
            faeChat.observeMessageChange()
        }
    }
    
    func updateMessages() {
        faeChat.getMessageFromServer()
    }
    
    func updateUnreadChatIndicator() {
        DispatchQueue.global(qos: .utility).asyncAfter(deadline: .now() + 5.0) {
            let sync = FaePush()
            sync.getSync({ (status, message) in
                guard status / 100 == 2 else { return }
                guard let result = message else { return }
                let resultJson = JSON(result)
                let unreadCount = resultJson["chat"].intValue + resultJson["chat_room"].intValue
                DispatchQueue.main.async {
                    self.lblUnreadCount.text = unreadCount > 99 ? "•••" : "\(unreadCount)"
                    self.lblUnreadCount.frame.size.width = unreadCount / 10 >= 1 ? 28 : 22
                    self.btnOpenChat.isSelected = unreadCount != 0
                    self.lblUnreadCount.isHidden = unreadCount == 0
                    UIApplication.shared.applicationIconBadgeNumber = unreadCount
                }
            })
        }
    }
    
    func segueToChat(_ withUserId: NSNumber, withUserName: String) {
        let chatVC = ChatViewController()
        
        chatVC.hidesBottomBarWhenPushed = true
        
        //            chatVC.recent = recent
        chatVC.strChatRoomId = Key.shared.user_id < Int(withUserId) ? "\(Key.shared.user_id)-\(withUserId.stringValue)" : "\(withUserId.stringValue)-\(Key.shared.user_id)"
        //        chatVC.chat_id = recent["chat_id"].number?.stringValue
        //        chatVC.withUser = FaeWithUser(userName: withUserName, userId: withUserId.stringValue, userAvatar: nil)
        
        // Bryan
        chatVC.realmWithUser = RealmUser()
        chatVC.realmWithUser!.id = withUserId.stringValue
        chatVC.realmWithUser!.user_name = withUserName
        
        // EndBryan
        self.present(chatVC, animated: true, completion: nil)
//        navigationController?.pushViewController(chatVC, animated: true)
    }
}
