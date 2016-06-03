//
//  Message.swift
//  iPark
//
//  Created by blesssecret on 9/1/15.
//  Copyright (c) 2015 carryof. All rights reserved.
//


import Foundation

class Message : NSObject, JSQMessageData {
    var text_: String//content
    var sender_: String//name
    var createdAt_: String//now time
    var imageUrl_: String?//img
    var authorId_: String//objectId
    var userToId_: String//objectId
    
    convenience init(text: String?, sender: String?) {
//        self.init(text: text, sender: sender, imageUrl: nil)
        self.init(authorId:nil,userToId:nil,text:text,createdAt:nil,sender: sender, imageUrl: nil)
    }
    
    init(authorId:String?,userToId:String?,text: String?,createdAt:String?, sender: String?, imageUrl: String?) {
        self.authorId_ = authorId!
        self.userToId_ = userToId!
        self.text_ = text!
        if createdAt == nil {
            self.createdAt_ = String(stringInterpolationSegment: NSDate().timeIntervalSince1970 * 1000)
        }
        else {
            self.createdAt_ = createdAt!
        }
        self.sender_ = sender!
        self.imageUrl_ = imageUrl
    }
    func authorId() -> String! {
        return authorId_;
    }
    func userToId() -> String! {
        return userToId_;
    }
    func text() -> String! {
        return text_;
    }
    
    func sender() -> String! {
        return sender_;
    }
    
    func date() -> NSDate! {
//        return createdAt_;
        let timeNow = createdAt_.toInt()! * 1000
        let timeCreated = NSDate(timeIntervalSince1970: Double(timeNow))
        return timeCreated;
    }
    
    func imageUrl() -> String? {
        return imageUrl_;
    }
}