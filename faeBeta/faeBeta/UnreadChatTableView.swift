//
//  UnreadChatTableView.swift
//  faeBeta
//
//  Created by Yue on 8/9/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

//MARK: Show unread chat tableView
extension FaeMapViewController {
    
    func loadMapChat()
    {
        self.labelUnreadMessages.hidden = true
        if (backendless.userService.currentUser != nil){
            // keep tracking the unread messages number
            firebase.child("Recent").queryOrderedByChild("userId").queryEqualToValue(user_id?.stringValue).observeEventType(.Value) { (snapshot : FIRDataSnapshot) in
                var totalUnread = 0
                if snapshot.exists() {
                    for recent in snapshot.value!.allValues {
                        let recentDic = recent as! NSDictionary
                        totalUnread += recentDic["counter"] as! Int
                    }
                    if(totalUnread / 10 >= 1){
                        self.labelUnreadMessages.text = "\(totalUnread)"
                        self.labelUnreadMessages.frame.size.width = 23
                    }else{
                        self.labelUnreadMessages.text = "\(totalUnread)"
                        self.labelUnreadMessages.frame.size.width = 20
                    }
                }
                self.labelUnreadMessages.hidden = totalUnread == 0
                UIApplication.sharedApplication().applicationIconBadgeNumber = totalUnread
            }
        }
        if(backendless.userService.currentUser != nil && backendless.messagingService.currentDevice().deviceId != nil){
            // update the user's device_id for future message receive
            backendless.userService.currentUser.updateProperties(["device_id":backendless.messagingService.currentDevice().deviceId])
            backendless.userService.update(backendless.userService.currentUser, response: { (updatedUser) in
                print("Updated current device_id")
                }, error: { (fault) in
                    print("error couldn't update device_id \(fault)")
            })
        }
    }
    
    func stopMapChat(){
        firebase.child("Recent").removeAllObservers()// reference to all chat room
    }
    
    func animationMapChatShow(sender: UIButton!) {
        // check if the user's logged in the backendless
        if(backendless.userService.currentUser != nil){
            self.presentViewController (UIStoryboard(name: "Chat", bundle: nil).instantiateInitialViewController()!, animated: true,completion: nil )
        }
    }
    
    
    func animationMapChatHide(sender: UIButton!) {
        UIView.animateWithDuration(0.25, animations: ({
            self.mapChatSubview.alpha = 0.0
            self.mapChatWindow.alpha = 0.0
        }))
    }
}
