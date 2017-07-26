//
//  FaeUserPin.swift
//  faeBeta
//
//  Created by Yue on 4/28/17.
//  Copyright © 2017 fae. All rights reserved.
//

/*
import UIKit
import GoogleMaps
import SwiftyJSON

class FaeUserPin: NSObject {
    
//    static var arrAntiColliCoor = [CLLocationCoordinate2D](repeating: CLLocationCoordinate2DMake(0, 0), count: 5)
    
    var userIndex = -1
    
    var userId: Int = -1 // an unique user id
    var type: String = "" // type is "user"
    var miniAvatar: Int = -1 // an intValue indicates the map avatar showed on map
    var positions = [CLLocationCoordinate2D]() // five random coordinates from back-end, so the posArr should be an length of 5 array
    var marker: GMSMarker? // from GoogleMaps framework, a marker set on map
    var timer: Timer? // timer to change the marker location within the five markers
    let icon = UIImageView(frame: CGRect(x: 0, y: 0, width: 44, height: 44.7)) // user's map avatar view
    var iconImage = UIImage() // user's map avatar icon image
    var mapView: GMSMapView! // mapView assgined to user pin. marker.map, can be set to nil
    var index = 0 // index of five random coordinates of user pin
    
    var position = CLLocationCoordinate2DMake(0, 0) {
        didSet {
//            guard self.marker != nil else { return }
//            if self.mapView.projection.contains(self.position) {
//                self.marker?.position = self.position
//            } else {
//
//            }
        }
    }
    
    var pause = false {
        didSet {
            // invalidate the timer when need to stop updating the random locations of user pin
            if pause {
                if self.timer != nil {
                    self.timer?.invalidate()
                    self.timer = nil
                }
            } else {
                // timer interval is between 5s to 20s
                let time = Double.random(min: 5, max: 20)
//                self.timer = Timer.scheduledTimer(timeInterval: time, target: self, selector: #selector(self.updatePositionAndTimer), userInfo: nil, repeats: false)
                DispatchQueue.main.asyncAfter(deadline: .now() + time, execute: {
                    self.updatePositionAndTimer()
                })
            }
        }
    }
    var valid = true {
        didSet {
            if valid {
                let time = Double.random(min: 5, max: 20)
//                self.timer = Timer.scheduledTimer(timeInterval: time, target: self, selector: #selector(self.updatePositionAndTimer), userInfo: nil, repeats: false)
                DispatchQueue.main.asyncAfter(deadline: .now() + time, execute: {
                    self.updatePositionAndTimer()
                })
            } else {
                self.marker?.map = nil
                if self.timer != nil {
                    self.timer?.invalidate()
                    self.timer = nil
                }
                marker?.iconView = icon
                UIView.animate(withDuration: 0.3, delay: 0, animations: {
                    self.icon.alpha = 0
                }, completion: { _ in
                    self.marker?.map = nil
                    if self.timer != nil {
                        self.timer?.invalidate()
                        self.timer = nil
                    }
                })
            }
        }
    }
    
    init(json: JSON) {
        
        self.type = json["type"].stringValue
        self.userId = json["user_id"].intValue
        self.miniAvatar = json["mini_avatar"].intValue
        
        guard let posArr = json["geolocation"].array else { return }
        for pos in posArr {
            let pos_i = CLLocationCoordinate2DMake(pos["latitude"].doubleValue, pos["longitude"].doubleValue)
            self.positions.append(pos_i)
        }
        
        // user's map avatar, index starts from 1
//        if let image = UIImage(named: "mapAvatar_\(miniAvatar + 1)") {
//            self.iconImage = image
//        }
        guard Mood.avatars[miniAvatar] != nil else {
            print("[init] map avatar image is nil")
            return
        }
        self.icon.image = Mood.avatars[miniAvatar]
        self.icon.contentMode = .scaleAspectFit
        
        self.marker = GMSMarker()
        self.marker?.zIndex = 1 // map markers' overlapping level
        
    }
    
    // func will be called when init it outside not in this class
    func firstLoading() {
        self.marker?.userData = [1: self] // warning: if dealloc is not done properly, circular reference will occur. right way: using "weak"
        
        self.position = self.positions[self.index]
        self.marker?.map = self.mapView
        self.marker?.position = self.position
        self.icon.alpha = 0
        self.marker?.iconView = icon
        
        let delay = Double.random(min: 0, max: 1)
        
        self.marker?.tracksViewChanges = true
        UIView.animate(withDuration: 1, delay: delay, animations: {
            self.icon.alpha = 1
        }, completion: { _ in
            guard Mood.avatars[self.miniAvatar] != nil else {
                print("[firstLoading] map avatar image is nil")
                return
            }
            self.marker?.iconView = nil
            self.marker?.icon = Mood.avatars[self.miniAvatar]
            self.marker?.tracksViewChanges = false
        })
        
        let time = Double.random(min: 5, max: 20)
//                self.timer = Timer.scheduledTimer(timeInterval: time, target: self, selector: #selector(self.updatePositionAndTimer), userInfo: nil, repeats: false)
        DispatchQueue.main.asyncAfter(deadline: .now() + time, execute: {
            self.updatePositionAndTimer()
        })
        
        self.index += 1
    }
    
    func updatePositionAndTimer() {
        
        self.marker?.iconView = icon
        
        if self.index == 5 {
            self.index = 0
        }
        
        self.marker?.tracksViewChanges = true
        
        UIView.animate(withDuration: 0.3, delay: 0, animations: {
            self.icon.alpha = 0
        }, completion: { _ in
            if self.index >= self.positions.count {
                return
            }
            self.marker?.map = nil
            self.marker = nil
            self.marker = GMSMarker()
            self.position = self.positions[self.index]
            self.marker?.position = self.position
            self.marker?.userData = [1: self]
            self.marker?.iconView = self.icon
            if self.valid {
                guard self.mapView != nil else { return }
                guard self.mapView.projection.contains(self.position) else {
                    print("[updatePositionAndTimer] user: \(self.userId) not in camera")
                    return
                }
                self.marker?.map = self.mapView
                UIView.animate(withDuration: 1, delay: 0.1, animations: {
                    self.icon.alpha = 1
                }, completion: { _ in
                    self.marker?.tracksViewChanges = false
                    self.marker?.iconView = nil
                    guard Mood.avatars[self.miniAvatar] != nil else {
                        print("[firstLoading] map avatar image is nil")
                        return
                    }
                    self.marker?.icon = Mood.avatars[self.miniAvatar]
                })
            } else {
                if self.timer != nil {
                    self.timer?.invalidate()
                    self.timer = nil
                }
                return
            }
            self.index += 1
        })
        
        if !pause || valid {
            let time = Double.random(min: 5, max: 20)
            DispatchQueue.main.asyncAfter(deadline: .now() + time, execute: {
                self.updatePositionAndTimer()
            })
//            self.timer = Timer.scheduledTimer(timeInterval: time, target: self, selector: #selector(self.updatePositionAndTimer), userInfo: nil, repeats: false)
        }
    }
}
 
 */
