//
//  StickerCollection.swift
//  faeBeta
//
//  Created by Jichao on 2018/1/21.
//  Copyright © 2018年 fae. All rights reserved.
//

import Foundation

class StickerCollection {
    var name: String!
    var count: Int!
    var isEmoji: Bool!
    var list: [String] = []
    var page: Int {
        get {
            if count == 0 {
                return 1
            } else {
                return count % countPerPage == 0 ? count / countPerPage : count / countPerPage + 1
            }
        }
    }
    var countPerPage: Int { return isEmoji ? 28 : 8 }
    var size: Int { return isEmoji ? 32 : 82 }
    
    init(name: String, count: Int, isEmoji: Bool) {
        self.name = name
        self.count = count
        self.isEmoji = isEmoji
    }
    
    func setupList(_ list: [String]) {
        self.list += list
    }
}
