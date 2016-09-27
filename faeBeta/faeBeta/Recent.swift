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

// this file has some function to connect to firebase and change information in recent
// which can be described as dictionary.
// it should be connected to chat table in map view.


let firebase = FIRDatabase.database().reference()
let backendless = Backendless.sharedInstance()
//let currentUser = backendless.userService.currentUser

//MARK : CREATE CHATROOM

//given two BackendlessUser object, create a chat room for them.

func startChat(user1 : BackendlessUser, user2 : BackendlessUser) -> String {
    //user1 is current user
    
    //    let userId1 : String = user1.objectId
    //    let userId2 : String = user2.objectId
    
    var chatRoomId : String = ""
    
    let value = user1.objectId.compare(user2.objectId).rawValue
    
    if value < 0 {
        chatRoomId = user1.objectId.stringByAppendingString("-" + user2.objectId)
    } else {
        chatRoomId = user2.objectId.stringByAppendingString("-" + user1.objectId)
    }
    
    let members = [user1.objectId as String, user2.objectId as String]
    print("the chatRoom Id is \(chatRoomId)")
    //create recent object on both end of user on firebase.
    
    //create recent
    createdRecent(user1.objectId, chatRoomId: chatRoomId, members: members, withUserUsername: user2.name, withUserUserId: user2.objectId)
//    createdRecent(user2.objectId, chatRoomId: chatRoomId, members: members, withUserUsername: user1.name, withUserUserId: user1.objectId)
    
    return chatRoomId
}

//MARK : create recentItem

//create a recent : if the chatRoomId is already exist in firebase, we don't need to create a new one.

func createdRecent(userId : String, chatRoomId : String, members : [String], withUserUsername : String, withUserUserId : String) {
    
    //firebase query
    
    firebase.child("Recent").queryOrderedByChild("chatRoomId").queryEqualToValue(chatRoomId).observeSingleEventOfType(.Value, withBlock:{
        snapshot in
        
        var createRecent = true
        
        //check if we have a result
        if snapshot.exists() {
            print(snapshot)
            for recent in snapshot.value!.allValues {
                //if we already have recent with passed userId, we dont create a new one
                let senderId = (recent as! NSDictionary).valueForKey("userId") as? String
                if senderId == userId {
                    createRecent = false
                }
            }
        }
        if createRecent {
            
            CreateRecentItem(userId, chatRoomId: chatRoomId, members: members, withUserUsername: withUserUsername, withUserUserId: withUserUserId, lastMessage: "", counter: 0)
        }
    })
}

// creating a recent object

func CreateRecentItem(userId : String, chatRoomId : String, members : [String], withUserUsername : String, withUserUserId : String, lastMessage: String, counter: Int) {
    
    // let firebase create a reference with a random generated id
    
    let ref = firebase.child("Recent").childByAutoId()
    
    let recentId = ref.key
    
    let date = dateFormatter().stringFromDate(NSDate())
    
    let recent = ["recentId" : recentId, "userId" : userId, "chatRoomId" : chatRoomId, "members" : members, "withUserUsername" : withUserUsername, "lastMessage" : lastMessage, "counter" : counter, "date" : date, "withUserUserId" : withUserUserId]
    
    // set value for the reference
    
    ref.setValue(recent) { (error, ref) -> Void in
        if error != nil {
            print("error creating recent \(error)")
        }
    }
    
}

//MARK : update recent

//given a chatRoomId, we update last message for it.

func UpdateRecents(chatRoomId : String, lastMessage : String, withUser: BackendlessUser) {

    //firebase query
    firebase.child("Recent").queryOrderedByChild("chatRoomId").queryEqualToValue(chatRoomId).observeSingleEventOfType(.Value) { (snapshot : FIRDataSnapshot) in
        
        if snapshot.exists() {
            for recent in snapshot.value!.allValues {
                
                //update recent
                updateRecentItem(recent as! NSDictionary, lastMessage: lastMessage)
            }
            
            if(snapshot.value!.allValues.count == 1){
                CreateRecentItem(withUser.objectId, chatRoomId: chatRoomId, members: [backendless.userService.currentUser.objectId as String, withUser.objectId as String], withUserUsername: backendless.userService.currentUser.name, withUserUserId: backendless.userService.currentUser.objectId, lastMessage: lastMessage, counter: 1)
            }
        }
    }
}

func updateRecentItem(recent : NSDictionary, lastMessage : String) {
    let date = dateFormatter().stringFromDate(NSDate())
    
    var counter = recent["counter"] as! Int
    
    let localStorage = LocalStorageManager()
    localStorage.readLogInfo()
    
    if recent["userId"] as? String !=  "\(backendless.userService.currentUser.objectId)" {
        counter += 1
    }
    
    //only the date we need to update
    
    let values = ["lastMessage" : lastMessage, "counter" : counter, "date" : date]
    
    //firebase query : update
    
    firebase.child("Recent").child((recent["recentId"] as? String)!).updateChildValues(values as [NSObject : AnyObject]) { (error, ref) in
        if error != nil {
            print("Error couldn't update recent item: \(error)")
        }
        
    }
}

//MARK : Restart recent chat

func restartRecentChat(recent : NSDictionary) {
    
    let localStorage = LocalStorageManager()
    localStorage.readLogInfo()
    //    for userId in recent["members"] as! [String] {
    
    
    //        if userId != backendless.userService.currentUser.objectId && userId != recent{
    //            
    //            createdRecent(userId, chatRoomId: (recent["chatRoomId"] as? String)!, members: recent["members"] as! [String], withUserUsername: backendless.userService.currentUser.name, withUserUserId: backendless.userService.currentUser.objectId)
    //            
    //        }
    //    }
}



//MARK : delete recent functions

func DeleteRecentItem(recent : NSDictionary) {
    
    //firebase query delete item (recent)
    
    firebase.child("Recent").child((recent["recentId"] as? String)!).removeValueWithCompletionBlock { (error, ref) in
        if error != nil {
            print("Error deleting recent item: \(error)")
        }
    }
}

//MARK : Clear recent counter function

func clearRecentCounter(chatRoomId : String) {
    
    //firebase query
    
    firebase.child("Recent").queryOrderedByChild("chatRoomId").queryEqualToValue(chatRoomId).observeSingleEventOfType(.Value) { (snapshot : FIRDataSnapshot) in
        
        if snapshot.exists() {
            
            let localStorage = LocalStorageManager()
            localStorage.readLogInfo()
            
            for recent in snapshot.value!.allValues {
                if recent.objectForKey("userId") as? String == backendless.userService.currentUser.objectId {
                    //clear counter
                    ClearRecentCounterItem(recent as! NSDictionary)
                }
            }
            
        }
    }
}


func ClearRecentCounterItem(recent : NSDictionary) {
    
    //firebase query : update
    
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
