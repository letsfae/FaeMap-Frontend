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

func firebaseWelcome() {
    
    let text = "Hey there! Welcome to Fae Map! Super Happy to see you here. We are here to enhance your experience on Fae Map and make you time more fun. Let us know of any problems you encounter or what we can do to make your experience better. We'll be hitting you up with surprices, recommandations, favorite places, cool deals, and tone of fun stuff. Feel free to chat with us here anytime about anything. Let's fae"
    
    let message = OutgoingMessage.init(message : text, senderId : "1", senderName : "Fae Map Crew", date: Date(), status : "Delivered", type : "text", index : 1, hasTimeStamp: true)
    
    print("[my user_id] :" + user_id.stringValue)
    print("[my username] :" + username!)
    
    message.sendMessage("1-" + user_id.stringValue , withUser: FaeWithUser(userName: username!, userId: user_id.stringValue, userAvatar: nil))
    
}
