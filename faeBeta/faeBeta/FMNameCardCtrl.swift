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
    func openAddFriendPage(userId: Int, requestId: Int, status: FriendStatus) {
        let addFriendVC = AddFriendFromNameCardViewController()
        addFriendVC.delegate = uiviewNameCard
        addFriendVC.userId = userId
        addFriendVC.requestId = requestId
        addFriendVC.statusMode = status
        addFriendVC.modalPresentationStyle = .overCurrentContext
        present(addFriendVC, animated: false)
    }
    
    // NameCardDelegate
    func reportUser(id: Int) {
        let reportPinVC = ReportViewController()
        reportPinVC.reportType = 0
        present(reportPinVC, animated: true, completion: nil)
    }
    
    // NameCardDelegate
    func openFaeUsrInfo() {
        let fmUsrInfo = FMUserInfo()
        fmUsrInfo.userId = uiviewNameCard.userId
        uiviewNameCard.hide() {
            self.mapGesture(isOn: true)
        }
        navigationController?.pushViewController(fmUsrInfo, animated: true)
    }
    
    // NameCardDelegate
    func chatUser(id: Int) {
//        uiviewNameCard.hide() {
//            self.mapGesture(isOn: true)
//        }
        // First get chatroom id
        getFromURL("chats/users/\(Key.shared.user_id)/\(id)", parameter: nil, authentication: headerAuthentication()) { status, result in
            var resultJson1 = JSON([])
            if status / 100 == 2 {
                resultJson1 = JSON(result!)
            }
            // then get with user name
            getFromURL("users/\(id)/name_card", parameter: nil, authentication: headerAuthentication()) { status, result in
                guard status / 100 == 2 else { return }
                let resultJson2 = JSON(result!)
                var chat_id: String?
                if let id = resultJson1["chat_id"].number {
                    chat_id = id.stringValue
                }
                if let nickName = resultJson2["nick_name"].string {
                    self.startChat(chat_id, userId: id, nickName: nickName)
                } else {
                    self.startChat(chat_id, userId: id, nickName: nil)
                }
            }
        }
    }
    
    func startChat(_ chat_id: String?, userId: Int, nickName: String?) {
        let chatVC = ChatViewController()
        chatVC.strChatRoomId = Key.shared.user_id < userId ? "\(Key.shared.user_id)-\(userId)" : "\(userId)-\(Key.shared.user_id)"
        chatVC.strChatId = chat_id
        // Bryan
        let nickName = nickName ?? "Chat"
        // ENDBryan
        // chatVC.withUser = FaeWithUser(userName: withUserName, userId: withUserId.stringValue, userAvatar: nil)
        
        // Bryan
        // TODO: Tell nickname and username apart
        chatVC.realmWithUser = RealmUser()
        chatVC.realmWithUser!.userNickName = nickName
        chatVC.realmWithUser!.userID = "\(userId)"
        // chatVC.realmWithUser?.userAvatar =
        
        // RealmChat.addWithUser(withUser: chatVC.realmWithUser!)
        
        // EndBryan
//        self.present(chatVC, animated: true, completion: nil)
        navigationController?.pushViewController(chatVC, animated: true)
    }
}
