//
//  Recent.swift
//  quickChat
//
//  Created by User on 6/6/16.
//  Copyright © 2016 User. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase


public let kAVATARSTATE = ""
public let kFIRSTRUN = "firstRun"

let firebase = FIRDatabase.database().reference()
let backendless = Backendless.sharedInstance()
//let currentUser = backendless.userService.currentUser

//MARK : CREATE CHATROOM

func startChat(user1 : BackendlessUser, user2 : BackendlessUser) -> String {
    //user1 is current user
    
    let userId1 : String = user1.objectId
    let userId2 : String = user2.objectId
    
    var chatRoomId : String = ""
    
    let value = userId1.compare(userId2).rawValue
    
    if value < 0 {
        chatRoomId = userId1.stringByAppendingString(userId2)
    } else {
        chatRoomId = userId2.stringByAppendingString(userId1)
    }
    
    let members = [userId1, userId2]
    
    //create recent
    createdRecent(userId1, chatRoomId: chatRoomId, members: members, withUserUsername: user2.name!, withUserUserId: userId2)
    createdRecent(userId2, chatRoomId: chatRoomId, members: members, withUserUsername: user1.name!, withUserUserId: userId1)
    
    return chatRoomId
}

//MARK : create recentItem

func createdRecent(userId : String, chatRoomId : String, members : [String], withUserUsername : String, withUserUserId : String) {
    
    firebase.child("Recent").queryOrderedByChild("chatRoomId").queryEqualToValue(chatRoomId).observeSingleEventOfType(.Value) { (snapShot : FIRDataSnapshot) in
        var createRecent = true
        //check if we have a result
        if snapShot.exists() {
            for recent in snapShot.value!.allValues {
                //if we already have recent with passed userId, don't create new one
                if recent["userId"] as! String == userId {
                    createRecent = false
                }
            }
        }
        
        if createRecent {
            
            CreateRecentItem(userId, chatRoomId: chatRoomId, members: members, withUserUsername: withUserUsername, withUserUserId: withUserUserId)
            
        }
    }
    
}

func CreateRecentItem(userId : String, chatRoomId : String, members : [String], withUserUsername : String, withUserUserId : String) {
    
    let ref = firebase.child("Recent").childByAutoId()
    
    let recentId = ref.key
    
    let date = dateFormatter().stringFromDate(NSDate())
    
    let recent = ["recentId" : recentId, "userId" : userId, "chatRoomId" : chatRoomId, "members" : members, "withUserUsername" : withUserUsername, "lastMessage" : "", "counter" : 0, "date" : date, "withUserUserId" : withUserUserId]
    ref.setValue(recent) { (error, ref) -> Void in
        if error != nil {
            print("error creating recent \(error)")
        }
    }
    
}

//MARK : update recent

func UpdateRecents(chatRooId : String, lastMessage : String) {
    
    firebase.child("Recent").queryOrderedByChild("chatRoomId").queryEqualToValue(chatRooId).observeSingleEventOfType(.Value) { (snapshot : FIRDataSnapshot) in
        
        if snapshot.exists() {
            
            for recent in snapshot.value!.allValues {
                //update recent
                updateRecentItem(recent as! NSDictionary, lastMessage: lastMessage)
            }
            
        }
    }
}

func updateRecentItem(recent : NSDictionary, lastMessage : String) {
    let date = dateFormatter().stringFromDate(NSDate())
    
    var counter = recent["counter"] as! Int
    
    if recent["userId"] as? String != backendless.userService.currentUser.objectId {
        counter++
    }
    
    let values = ["lastMessage" : lastMessage, "counter" : counter, "date" : date]
    
    firebase.child("Recent").child((recent["recentId"] as? String)!).updateChildValues(values as [NSObject : AnyObject]) { (error, ref) in
        if error != nil {
            print("Error couldn't update recent item: \(error)")
        }
        
    }
}

//MARK : Restart recent chat

func restartRecentChat(recent : NSDictionary) {
    
    for userId in recent["members"] as! [String] {
        
        if userId != backendless.userService.currentUser.objectId {
            
            createdRecent(userId, chatRoomId: (recent["chatRoomId"] as? String)!, members: recent["members"] as! [String], withUserUsername: backendless.userService.currentUser.name, withUserUserId: backendless.userService.currentUser.objectId)
            
        }
        
    }
}



//MARK : delete recent functions

func DeleteRecentItem(recent : NSDictionary) {
    
    firebase.child("Recent").child((recent["recentId"] as? String)!).removeValueWithCompletionBlock { (error, ref) in
        if error != nil {
            print("Error deleting recent item: \(error)")
        }
    }
}

//MARK : Clear recent counter function

func clearRecentCounter(chatRoomId : String) {
    
    firebase.child("Recent").queryOrderedByChild("chatRoomId").queryEqualToValue(chatRoomId).observeSingleEventOfType(.Value) { (snapshot : FIRDataSnapshot) in
        
        if snapshot.exists() {
            
            for recent in snapshot.value!.allValues {
                if recent.objectForKey("userId") as? String == backendless.userService.currentUser.objectId {
                    //clear counter
                    
                    
                }
            }
            
        }
    }
}

func ClearRecentCounterItem(recent : NSDictionary) {
    firebase.child("Recent").child((recent["recentId"] as? String)!).updateChildValues(["counter" : 0]) { (error, ref) in
        if error != nil {
            print("Error couldn't update recents counter: \(error)")
        }
    }
}

private let dateFormat = "yyyyMMddHHmmss"

func dateFormatter() -> NSDateFormatter {
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = dateFormat
    return dateFormatter
}