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
    
    func loadSelfMarkerSubview() {
        self.subviewSelfMarker = UIView(frame: CGRect(x: -200, y: -200, width: 44, height: 44))
        subviewSelfMarker.layer.zPosition = 400
        subviewSelfMarker.clipsToBounds = false
        self.view.addSubview(self.subviewSelfMarker)
        selfMarkerIcon = UIButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        selfMarkerIcon.adjustsImageWhenHighlighted = false
        selfMarkerIcon.layer.zPosition = 5
        let point = CGPoint(x: 60, y: 60)
        selfMarkerIcon.center = point
        selfMarkerIcon.addTarget(self, action: #selector(self.getSelfNameCard(_:)), for: .touchUpInside)
        self.subviewSelfMarker.addSubview(selfMarkerIcon)
    }
    
    func reloadSelfMarker() {
        if myPositionCircle_1 != nil {
            myPositionCircle_1.removeFromSuperview()
            myPositionCircle_2.removeFromSuperview()
            myPositionCircle_3.removeFromSuperview()
        }
        let point = CGPoint(x: 60, y: 60)
        myPositionCircle_1 = UIImageView(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        myPositionCircle_2 = UIImageView(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        myPositionCircle_3 = UIImageView(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        myPositionCircle_1.layer.zPosition = 0
        myPositionCircle_2.layer.zPosition = 1
        myPositionCircle_3.layer.zPosition = 2
        myPositionCircle_1.center = point
        myPositionCircle_2.center = point
        myPositionCircle_3.center = point
        myPositionCircle_1.isUserInteractionEnabled = false
        myPositionCircle_2.isUserInteractionEnabled = false
        myPositionCircle_3.isUserInteractionEnabled = false
        
        self.subviewSelfMarker.addSubview(myPositionCircle_3)
        self.subviewSelfMarker.addSubview(myPositionCircle_2)
        self.subviewSelfMarker.addSubview(myPositionCircle_1)
        
        selfMarkerAnimation()
    }
    
    func selfMarkerAnimation() {
        UIView.animate(withDuration: 2.4, delay: 0, options: [.repeat, .curveEaseIn], animations: ({
            if self.myPositionCircle_1 != nil {
                self.myPositionCircle_1.alpha = 0.0
                self.myPositionCircle_1.frame = CGRect(x: 0, y: 0, width: 120, height: 120)
            }
        }), completion: nil)
        
        UIView.animate(withDuration: 2.4, delay: 0.8, options: [.repeat, .curveEaseIn], animations: ({
            if self.myPositionCircle_2 != nil {
                self.myPositionCircle_2.alpha = 0.0
                self.myPositionCircle_2.frame = CGRect(x: 0, y: 0, width: 120, height: 120)
            }
        }), completion: nil)
        
        UIView.animate(withDuration: 2.4, delay: 1.6, options: [.repeat, .curveEaseIn], animations: ({
            if self.myPositionCircle_3 != nil {
                self.myPositionCircle_3.alpha = 0.0
                self.myPositionCircle_3.frame = CGRect(x: 0, y: 0, width: 120, height: 120)
            }
        }), completion: nil)
    }
    
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
            self.myPositionCircle_1.image = UIImage(named: "myPosition_outside")
            self.myPositionCircle_2.image = UIImage(named: "myPosition_outside")
            self.myPositionCircle_3.image = UIImage(named: "myPosition_outside")
            self.selfMarkerIcon.setImage(UIImage(named: "miniAvatar_\(userMiniAvatar+1)"), for: .normal)
        })
    }
}
