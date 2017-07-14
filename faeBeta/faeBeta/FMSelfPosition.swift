//
//  FMSelfPositionAnimation.swift
//  faeBeta
//
//  Created by Yue on 11/16/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
import SwiftyJSON

extension FaeMapViewController {
    
    // Get self avatar on map
    func getSelfAccountInfo() {
        let getSelfInfo = FaeUser()
        getSelfInfo.getAccountBasicInfo({(status: Int, message: Any?) in
            if status / 100 != 2 {
                return
            }
            let selfUserInfoJSON = JSON(message!)
            userFirstname = selfUserInfoJSON["first_name"].stringValue
            userLastname = selfUserInfoJSON["last_name"].stringValue
            userBirthday = selfUserInfoJSON["birthday"].stringValue
            userUserGender = selfUserInfoJSON["gender"].stringValue
            userUserName = selfUserInfoJSON["user_name"].stringValue
            if userStatus == 5 {
                return
            }
            userMiniAvatar = selfUserInfoJSON["mini_avatar"].intValue
//            self.myPositionCircle_1.image = UIImage(named: "myPosition_outside")
//            self.myPositionCircle_2.image = UIImage(named: "myPosition_outside")
//            self.myPositionCircle_3.image = UIImage(named: "myPosition_outside")
//            self.selfMarkerIcon.setImage(UIImage(named: "miniAvatar_\(userMiniAvatar+1)"), for: .normal)
        })
    }
}
