//
//  FirebaseWelcomer.swift
//  faeBeta
//
//  Created by User on 03/02/2017.
//  Copyright © 2017 fae. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase
import AVFoundation

func sendWelcomeMessage() {
    
    let text = "Hey there! Welcome to Fae Map! Super Happy to see you. We are here to ensure that you have the best experience on our platform. Let us know of any problems you encounter or what we can do to make your experience better. We'll be hitting you up with favorite places, recommendations, cool deals, and surprises from time to time. Feel free to chat with us here about anything. Let's Fae!"
    
    _ = OutgoingMessage.init(message : text, senderId : "1", senderName : "Fae Map Crew", date: Date(), status : "Delivered", type : "text", index : 1, hasTimeStamp: true)
    
    //print("[my user_id] :" + user_id.stringValue)
    //print("[my username] :" + username!)
    
    //Bryan
    //message.sendMessageWithWelcomeInformation("1-" + user_id.stringValue , withUser: RealmWithUser(userName: username!, userId: user_id.stringValue, userAvatar: nil))
    //ENDBryan
    
}
