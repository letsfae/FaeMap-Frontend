//
//  FMUpdateUserPins.swift
//  faeBeta
//
//  Created by Yue on 3/9/17.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit
import SwiftyJSON
import CCHMapClusterController

extension FaeMapViewController {
    
    func viewForUser(annotation: MKAnnotation, first: FaePinAnnotation) -> MKAnnotationView {
        let identifier = "user"
        var anView: UserPinAnnotationView
        if let dequeuedView = faeMapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? UserPinAnnotationView {
            dequeuedView.annotation = annotation
            anView = dequeuedView
        } else {
            anView = UserPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        }
        anView.assignImage(first.avatar)
        return anView
    }
    
    func tapUserPin(didSelect view: MKAnnotationView) {
        guard let clusterAnn = view.annotation as? CCHMapClusterAnnotation else { return }
        guard let firstAnn = clusterAnn.annotations.first as? FaePinAnnotation else { return }
        guard firstAnn.id != -1 else { return }
        boolCanUpdateUserPin = false
        boolCanOpenPin = false
        mapGesture(isOn: false)
        uiviewNameCard.userId = firstAnn.id
        uiviewNameCard.show(avatar: firstAnn.avatar) {
            self.boolCanOpenPin = true
        }
    }
    
    func updateTimerForUserPin() {
        guard !HIDE_AVATARS else { return }
        updateUserPins()
        timerUserPin?.invalidate()
        timerUserPin = nil
        timerUserPin = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(self.updateUserPins), userInfo: nil, repeats: true)
    }

    func updateUserPins() {
        guard !HIDE_AVATARS else { return }
        guard boolCanUpdateUserPin else { return }
        let coorDistance = cameraDiagonalDistance()
        boolCanUpdateUserPin = false
        renewSelfLocation()
        let mapCenter = CGPoint(x: screenWidth / 2, y: screenHeight / 2)
        let mapCenterCoordinate = faeMapView.convert(mapCenter, toCoordinateFrom: nil)
        let getMapUserInfo = FaeMap()
        getMapUserInfo.whereKey("geo_latitude", value: "\(mapCenterCoordinate.latitude)")
        getMapUserInfo.whereKey("geo_longitude", value: "\(mapCenterCoordinate.longitude)")
        getMapUserInfo.whereKey("radius", value: "\(coorDistance)")
        getMapUserInfo.whereKey("type", value: "user")
        getMapUserInfo.whereKey("max_count ", value: "100")
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
            var userPins = [FaePinAnnotation]()
            DispatchQueue.global(qos: .default).async {
                for userJson in mapUserJsonArray {
                    if userJson["user_id"].intValue == Key.shared.user_id {
                        continue
                    }
                    var user: FaePinAnnotation? = FaePinAnnotation(type: "user", cluster: self.mapClusterManager, json: userJson)
                    guard user != nil else { continue }
                    if self.faeUserPins.contains(user!) {
                        // joshprint("[updateUserPins] yes contains")
                        guard let index = self.faeUserPins.index(of: user!) else { continue }
                        self.faeUserPins[index].positions = (user?.positions)!
                        user = nil
                    } else {
                        // joshprint("[updateUserPins] no")
                        self.faeUserPins.append(user!)
                        userPins.append(user!)
                    }
                }
                guard userPins.count > 0 else {
                    self.boolCanUpdateUserPin = true
                    return
                }
                DispatchQueue.main.async {
                    self.mapClusterManager.addAnnotations(userPins, withCompletionHandler: nil)
                    for user in userPins {
                        user.isValid = true
                    }
                    self.boolCanUpdateUserPin = true
                }
            }
        }
    }
}
