//
//  FMUpdateUserPins.swift
//  faeBeta
//
//  Created by Yue on 3/9/17.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit
import GoogleMaps
import SwiftyJSON
import RealmSwift

extension FaeMapViewController {
    func updateTimerForUserPin() {
        self.updateSelfLocation()
        if timerUpdateSelfLocation != nil {
            timerUpdateSelfLocation.invalidate()
        }
        timerUpdateSelfLocation = Timer.scheduledTimer(timeInterval: 20, target: self, selector: #selector(self.updateSelfLocation), userInfo: nil, repeats: true)
    }
    
    func updateSelfLocation() {
        if didLoadFirstLoad || !canDoNextUserUpdate {
            return
        }
        let coorDistance = cameraDiagonalDistance()
        userPins.removeAll()
        clearMap(type: "user", animated: true)
        canDoNextUserUpdate = false
        self.renewSelfLocation()
        let mapCenter = CGPoint(x: screenWidth/2, y: screenHeight/2)
        let mapCenterCoordinate = faeMapView.projection.coordinate(for: mapCenter)
        let getMapUserInfo = FaeMap()
        getMapUserInfo.whereKey("geo_latitude", value: "\(mapCenterCoordinate.latitude)")
        getMapUserInfo.whereKey("geo_longitude", value: "\(mapCenterCoordinate.longitude)")
        getMapUserInfo.whereKey("radius", value: "\(coorDistance)")
        getMapUserInfo.whereKey("type", value: "user")
        //        getMapUserInfo.whereKey("user_updated_in", value: "30")
        getMapUserInfo.getMapInformation {(status: Int, message: Any?) in
            if status/100 != 2 || message == nil {
                print("DEBUG: getMapUserInfo status/100 != 2")
                self.canDoNextUserUpdate = true
                return
            }
            let mapUserJSON = JSON(message!)
            guard let mapUserJsonArray = mapUserJSON.array else {
                print("[getMapUserInfo] fail to parse pin comments")
                self.canDoNextUserUpdate = true
                return
            }
            if mapUserJsonArray.count <= 0 {
                self.canDoNextUserUpdate = true
                return
            }
            self.userPins = mapUserJsonArray.map{UserPin(json: $0)}
            let mapUserInfoJSON = JSON(message!)
            if mapUserInfoJSON.count <= 0 {
                self.canDoNextUserUpdate = true
                return
            }
            var count = 0
            for userPin in self.userPins {
                if count > 5 {
                    break
                } else if userPin.userId == Int(user_id) {
                    continue
                }
                count += 1
                let pinUser = GMSMarker()
                pinUser.position = userPin.position
                let getMiniAvatar = FaeUser()
                getMiniAvatar.getOthersProfile("\(userPin.userId)") {(status, message) in
                    if status/100 != 2 || message == nil{
                        print("DEBUG: getOthersProfile status/100 != 2")
                        return
                    }
                    let userProfile = JSON(message!)
                    let miniAvatar = userProfile["mini_avatar"].intValue
                    self.mapUserPinsDic.append(pinUser)
                    pinUser.userData = [1: userPin]
                    let icon = UIImageView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
                    let iconImage = UIImage(named: "mapAvatar_\(miniAvatar+1)")
                    icon.image = iconImage
                    icon.contentMode = .scaleAspectFit
                    icon.alpha = 0
                    pinUser.iconView = icon
                    pinUser.zIndex = 1
                    pinUser.map = self.faeMapView
                    // Delay 0-1 seconds, randomly
                    let delay: Double = Double(arc4random_uniform(100)) / 100
                    UIView.animate(withDuration: 1, delay: delay, animations: {
                        icon.alpha = 1
                    }, completion: {(finished) in
                        pinUser.iconView = nil
                        pinUser.icon = iconImage
                    })
                }
            }
            self.canDoNextUserUpdate = true
        }
    }
}
