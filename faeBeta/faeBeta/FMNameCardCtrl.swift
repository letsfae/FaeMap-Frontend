//
//  FMMapNameCard.swift
//  faeBeta
//
//  Created by Yue on 12/15/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
import SwiftyJSON
import RealmSwift

extension FaeMapViewController: NameCardDelegate {
    func loadNameCard() {
        uiviewNameCard = FMNameCardView()
        uiviewNameCard.delegate = self
        view.addSubview(uiviewNameCard)
    }
    
    // MARK: NameCardDelegate
    func openAddFriendPage(userId: Int, status: FriendStatus) {
        let addFriendVC = AddFriendFromNameCardViewController()
        addFriendVC.delegate = uiviewNameCard
        addFriendVC.userId = userId
        addFriendVC.statusMode = status
        addFriendVC.modalPresentationStyle = .overCurrentContext
        present(addFriendVC, animated: false)
    }
    
    func reportUser(id: Int) {
        let reportPinVC = ReportViewController()
        reportPinVC.reportType = 0
        present(reportPinVC, animated: true, completion: nil)
    }
    
    func openFaeUsrInfo() {
        let fmUsrInfo = FMUserInfo()
        fmUsrInfo.userId = uiviewNameCard.userId
        uiviewNameCard.hide() {
            self.mapGesture(isOn: true)
        }
        navigationController?.pushViewController(fmUsrInfo, animated: true)
    }
    
    func chatUser(id: Int) {
        let vcChat = ChatViewController()
        vcChat.arrUserIDs.append("\(Key.shared.user_id)")
        vcChat.arrUserIDs.append("\(id)")
        vcChat.strChatId = "\(id)"
        let realm = try! Realm()
        if let _ = realm.filterUser(id: "\(id)") {
            navigationController?.pushViewController(vcChat, animated: true)
        } else {
            assert(false, "[Chat - check why this user is not in Realm]")
        }
    }
}
