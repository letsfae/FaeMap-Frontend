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
        self.labelUnreadMessages.isHidden = true
        Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(self.updateUnreadChatIndicator), userInfo: nil, repeats: true)
    }

    func updateUnreadChatIndicator(){
        getFromURL("sync", parameter: nil, authentication: headerAuthentication()) { (status, result) in
            if(status / 100 == 2){
                if let cacheRecent = result as? NSDictionary {
                    let totalUnread = (cacheRecent["chat"] as! NSNumber).int32Value + (cacheRecent["chat_room"] as! NSNumber).int32Value
                    self.labelUnreadMessages.text = totalUnread > 99 ? "•••" : "\(totalUnread)"
                    
                    if(totalUnread / 10 >= 1){
                        self.labelUnreadMessages.frame.size.width = 28 //San ge dian dao 30
                    }else{
                        self.labelUnreadMessages.frame.size.width = 22
                    }
                    self.buttonChatOnMap.setImage(UIImage(named: "mainScreenHaveChat"), for: UIControlState())
                    self.labelUnreadMessages.isHidden = totalUnread == 0
                    if totalUnread == 0 {
                        self.buttonChatOnMap.setImage(UIImage(named: "mainScreenNoChat"), for: UIControlState())
                    }
                    UIApplication.shared.applicationIconBadgeNumber = Int(totalUnread)
                }
            }
        }
    }
    
    func animationMapChatShow(_ sender: UIButton!) {
        UINavigationBar.appearance().shadowImage = navBarDefaultShadowImage
        // check if the user's logged in the backendless
        self.present (UIStoryboard(name: "Chat", bundle: nil).instantiateInitialViewController()!, animated: true,completion: nil )
    }

    func segueToChat(_ withUserId: NSNumber, withUserName: String ){
        let chatVC = ChatViewController()
        
        chatVC.hidesBottomBarWhenPushed = true
        
        //            chatVC.recent = recent
        chatVC.chatRoomId = user_id.compare(withUserId).rawValue < 0 ? "\(user_id)-\(withUserId.stringValue)" : "\(withUserId.stringValue)-\(user_id)"
//        chatVC.chat_id = recent["chat_id"].number?.stringValue
//        chatVC.withUser = FaeWithUser(userName: withUserName, userId: withUserId.stringValue, userAvatar: nil)
        
        //Bryan
        chatVC.realmWithUser = RealmWithUser()
        chatVC.realmWithUser!.userID = withUserId.stringValue
        chatVC.realmWithUser!.userName = withUserName
        
        //EndBryan
        
        
        
        navigationController?.pushViewController(chatVC, animated: true)
    }
}
