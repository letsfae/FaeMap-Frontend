//
//  UnreadChatTableView.swift
//  faeBeta
//
//  Created by Yue on 8/9/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

//MARK: Show unread chat tableView
extension FaeMapViewController {
    
    func loadMapChat() {
        self.lblUnreadCount.isHidden = true
        Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(self.updateUnreadChatIndicator), userInfo: nil, repeats: true)
    }

    func updateUnreadChatIndicator(){
        getFromURL("sync", parameter: nil, authentication: headerAuthentication()) { (status, result) in
            guard status / 100 == 2 else { return }
            if let cacheRecent = result as? NSDictionary {
                let totalUnread = (cacheRecent["chat"] as! NSNumber).int32Value + (cacheRecent["chat_room"] as! NSNumber).int32Value
                self.lblUnreadCount.text = totalUnread > 99 ? "•••" : "\(totalUnread)"
                
                if(totalUnread / 10 >= 1){
                    self.lblUnreadCount.frame.size.width = 28 //San ge dian dao 30
                }else{
                    self.lblUnreadCount.frame.size.width = 22
                }
                self.btnOpenChat.setImage(UIImage(named: "mainScreenHaveChat"), for: UIControlState())
                self.lblUnreadCount.isHidden = totalUnread == 0
                if totalUnread == 0 {
                    self.btnOpenChat.setImage(UIImage(named: "mainScreenNoChat"), for: UIControlState())
                }
                UIApplication.shared.applicationIconBadgeNumber = Int(totalUnread)
            }
        }
    }

    func segueToChat(_ withUserId: NSNumber, withUserName: String ){
        let chatVC = ChatViewController()
        
        chatVC.hidesBottomBarWhenPushed = true
        
        //            chatVC.recent = recent
        chatVC.chatRoomId = Key.shared.user_id < Int(withUserId) ? "\(Key.shared.user_id)-\(withUserId.stringValue)" : "\(withUserId.stringValue)-\(Key.shared.user_id)"
//        chatVC.chat_id = recent["chat_id"].number?.stringValue
//        chatVC.withUser = FaeWithUser(userName: withUserName, userId: withUserId.stringValue, userAvatar: nil)
        
        //Bryan
        chatVC.realmWithUser = RealmUser()
        chatVC.realmWithUser!.userID = withUserId.stringValue
        chatVC.realmWithUser!.userName = withUserName
        
        //EndBryan
        
        
        
        navigationController?.pushViewController(chatVC, animated: true)
    }
}
