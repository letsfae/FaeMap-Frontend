//
//  FaeWithUser.swift
//  faeBeta
//
//  Created by YAYUAN SHI on 10/3/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

class FaeWithUser: NSObject {
    var userName = ""
    var userId = ""
    var userAvatar = ""
    override init() {
    }
    init(userName: String?, userId: String?, userAvatar: String?){
        if(userId != nil) {self.userId = userId!}
        if(userName != nil) {self.userName = userName!}
        if(userAvatar != nil) {self.userAvatar = userAvatar!}
    }
}
