//
//  FMMapNameCard.swift
//  faeBeta
//
//  Created by Yue on 12/15/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
import SwiftyJSON

extension FaeMapViewController: NameCardDelegate {
    
    func loadNameCard() {
        uiviewNameCard = FMNameCardView()
        uiviewNameCard.delegate = self
        view.addSubview(uiviewNameCard)
    }
    
    // NameCardDelegate
    func openFaeUsrInfo() {
        let fmUsrInfo = FMUserInfo()
        fmUsrInfo.userId = uiviewNameCard.userId
        uiviewNameCard.hide()
        navigationController?.pushViewController(fmUsrInfo, animated: true)
    }
    
    // NameCardDelegate
    func chatUser(id: Int) {
        uiviewNameCard.hide()
        let withUserId: NSNumber = NSNumber(value: id)
        // First get chatroom id
        getFromURL("chats/users/\(Key.shared.user_id)/\(withUserId.stringValue)", parameter: nil, authentication: headerAuthentication()) { status, result in
            var resultJson1 = JSON([])
            if status / 100 == 2 {
                resultJson1 = JSON(result!)
            }
            // then get with user name
            getFromURL("users/\(withUserId.stringValue)/name_card", parameter: nil, authentication: headerAuthentication()) { status, result in
                if status / 100 == 2 {
                    let resultJson2 = JSON(result!)
                    var chat_id: String?
                    if let id = resultJson1["chat_id"].number {
                        chat_id = id.stringValue
                    }
                    if let withNickName = resultJson2["nick_name"].string {
                        self.startChat(chat_id, withUserId: withUserId, withNickName: withNickName)
                    } else {
                        self.startChat(chat_id, withUserId: withUserId, withNickName: nil)
                    }
                }
            }
        }
    }
    
    func startChat(_ chat_id: String?, withUserId: NSNumber, withNickName: String?) {
        let chatVC = UIStoryboard(name: "Chat", bundle: nil).instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
        chatVC.chatRoomId = Key.shared.user_id < Int(withUserId) ? "\(Key.shared.user_id)-\(withUserId.stringValue)" : "\(withUserId.stringValue)-\(Key.shared.user_id)"
        chatVC.chat_id = chat_id
        // Bryan
        let nickName = withNickName ?? "Chat"
        // ENDBryan
        // chatVC.withUser = FaeWithUser(userName: withUserName, userId: withUserId.stringValue, userAvatar: nil)
        
        // Bryan
        // TODO: Tell nickname and username apart
        chatVC.realmWithUser = RealmUser()
        chatVC.realmWithUser!.userName = nickName
        chatVC.realmWithUser!.userID = withUserId.stringValue
        // chatVC.realmWithUser?.userAvatar =
        
        // RealmChat.addWithUser(withUser: chatVC.realmWithUser!)
        
        // EndBryan
        
        navigationController?.pushViewController(chatVC, animated: true)
    }
}
