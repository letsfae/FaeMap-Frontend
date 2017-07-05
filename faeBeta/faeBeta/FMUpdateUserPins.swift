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
        timerUpdateSelfLocation = Timer.scheduledTimer(timeInterval: 120, target: self, selector: #selector(self.updateSelfLocation), userInfo: nil, repeats: true)
    }

    func updateSelfLocation() {
        if boolIsFirstLoad || !boolCanUpdateUserPin {
            return
        }
        let coorDistance = cameraDiagonalDistance()
        for i in 0..<faeUserPins.count {
            faeUserPins[i]?.valid = false
            faeUserPins[i] = nil
        }
        faeUserPins.removeAll(keepingCapacity: false)
        boolCanUpdateUserPin = false
        self.renewSelfLocation()
        let mapCenter = CGPoint(x: screenWidth / 2, y: screenHeight / 2)
        let mapCenterCoordinate = faeMapView.projection.coordinate(for: mapCenter)
        let getMapUserInfo = FaeMap()
        getMapUserInfo.whereKey("geo_latitude", value: "\(mapCenterCoordinate.latitude)")
        getMapUserInfo.whereKey("geo_longitude", value: "\(mapCenterCoordinate.longitude)")
        getMapUserInfo.whereKey("radius", value: "\(coorDistance)")
        getMapUserInfo.whereKey("type", value: "user")
        getMapUserInfo.whereKey("max_count ", value: "5")
        //        getMapUserInfo.whereKey("user_updated_in", value: "30")
        getMapUserInfo.getMapInformation { (status: Int, message: Any?) in
            if status / 100 != 2 || message == nil {
                print("DEBUG: getMapUserInfo status/100 != 2")
                self.boolCanUpdateUserPin = true
                return
            }
            let mapUserJSON = JSON(message!)
            guard let mapUserJsonArray = mapUserJSON.array else {
                print("[getMapUserInfo] fail to parse pin comments")
                self.boolCanUpdateUserPin = true
                return
            }
            if mapUserJsonArray.count <= 0 {
                self.boolCanUpdateUserPin = true
                return
            }
            self.faeUserPins = mapUserJsonArray.map { FaeUserPin(json: $0) }
            if mapUserJSON.count <= 0 {
                self.boolCanUpdateUserPin = true
                return
            }
            var count = 0
            for faeUserPin in self.faeUserPins {
                if count > 5 {
                    break
                } else {
                    if faeUserPin?.userId == user_id {
                        continue
                    }
                }
                faeUserPin?.userIndex = count
                count += 1
                faeUserPin?.mapView = self.faeMapView
                faeUserPin?.firstLoading()
            }
            self.boolCanUpdateUserPin = true
        }
    }
}
