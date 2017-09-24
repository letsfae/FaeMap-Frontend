//
//  Recent.swift
//  quickChat
//
//  Created by User on 6/6/16.
//  Copyright © 2016 User. All rights reserved.
//

import Foundation
import SwiftyJSON

// this file has some function to connect to firebase and change information in recent
// which can be described as dictionary.
// it should be connected to chat table in map view.


//MARK: - recent functions


/// delete a recent history from back-end
///
/// - Parameters:
///   - recent: a recent JSON containing the info of the history to delete
///   - completion: (status, result) -> Void
func DeleteRecentItem(_ recent : JSON, completion: ((Int,Any?) -> Void)?) {
    let chat_room_id = recent["chat_id"].number
    deleteFromURL("chats/\(chat_room_id!)", parameter: [:], authentication: headerAuthentication(), completion: { (statusCode, result) in
        if(completion != nil) {
            completion!(statusCode,result)
        }
    })
}


/// Mark all unread messages as read
///
/// - Parameter chatRoomId: id of the chat room that user's viewing
func clearRecentCounter(_ chatRoomId : String?) {
    if let chatRoomId = chatRoomId{
        postToURL("chats/read", parameter: ["chat_id": chatRoomId], authentication: headerAuthentication(), completion: { (statusCode, result) in
            
        })
    }
}

// MARK: - utilities


/// a DateFormatter factory creating formatters of date included in the message
///
/// - Returns: a DateFormatter
func dateFormatter() -> DateFormatter {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyyMMddHHmmssSSS"
    return dateFormatter
}
