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
    
    func loadSelfMarker() {
        if subviewSelfMarker != nil {
            myPositionCircle_1.removeFromSuperview()
            myPositionCircle_2.removeFromSuperview()
            myPositionCircle_3.removeFromSuperview()
            subviewSelfMarker.removeFromSuperview()
        }
        self.subviewSelfMarker = UIView(frame: CGRect(x: -200, y: -200, width: 120, height: 120))
        selfMarkerIcon = UIImageView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        selfMarkerIcon.contentMode = .scaleAspectFit
        let point = CGPoint(x: 60, y: 60)
        selfMarkerIcon.center = point
        
        myPositionCircle_1 = UIImageView(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        myPositionCircle_2 = UIImageView(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        myPositionCircle_3 = UIImageView(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        myPositionCircle_1.center = point
        myPositionCircle_2.center = point
        myPositionCircle_3.center = point
        
        self.subviewSelfMarker.addSubview(myPositionCircle_3)
        self.subviewSelfMarker.addSubview(myPositionCircle_2)
        self.subviewSelfMarker.addSubview(myPositionCircle_1)
        self.subviewSelfMarker.addSubview(selfMarkerIcon)
        
        let tapToOpenSelfNameCard = UITapGestureRecognizer(target: self, action: #selector(self.getSelfNameCard(_:)))
        selfMarkerIcon.addGestureRecognizer(tapToOpenSelfNameCard)
        
//        selfMarker.iconView = subviewSelfMarker
//        selfMarker.position.latitude = currentLatitude
//        selfMarker.position.longitude = currentLongitude
//        selfMarker.map = faeMapView
//        selfMarker.zIndex = 10
//        selfMarker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
        self.view.addSubview(self.subviewSelfMarker)
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
            if let firstName = selfUserInfoJSON["first_name"].string {
                userFirstname = firstName
            }
            if let lastName = selfUserInfoJSON["last_name"].string {
                userLastname = lastName
            }
            if let birthday = selfUserInfoJSON["birthday"].string {
                userBirthday = birthday
            }
            if let gender = selfUserInfoJSON["gender"].string {
                userUserGender = gender
            }
            if let userName = selfUserInfoJSON["user_name"].string {
                userUserName = userName
            }
            if let miniAvatar = selfUserInfoJSON["mini_avatar"].int {
                if userStatus == 5 {
                    return
                }
                userMiniAvatar = miniAvatar

                self.myPositionCircle_1.image = UIImage(named: "myPosition_outside")
                self.myPositionCircle_2.image = UIImage(named: "myPosition_outside")
                self.myPositionCircle_3.image = UIImage(named: "myPosition_outside")
                if let miniAvatar = userMiniAvatar {
                    self.selfMarkerIcon.image = UIImage(named: "miniAvatar_\(miniAvatar+1)")
                }
                else {
                    self.selfMarkerIcon.image = UIImage(named: "miniAvatar_\(miniAvatar+1)")
                }
            }
        })
    }
}
