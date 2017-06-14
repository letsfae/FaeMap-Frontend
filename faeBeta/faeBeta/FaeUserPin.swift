//
//  FaeUserPin.swift
//  faeBeta
//
//  Created by Yue on 4/28/17.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit
import GoogleMaps
import SwiftyJSON

class FaeUserPin: NSObject {
    
    var userId: Int = -1 // an unique user id
    var type: String = "" // type is "user"
    var miniAvatar: Int = -1 // an intValue indicates the map avatar showed on map
    var positions = [CLLocationCoordinate2D]() // five random coordinates from back-end, so the posArr should be an length of 5 array
    weak var marker: GMSMarker? // from GoogleMaps framework, a marker set on map
    var timer: Timer! // timer to change the marker location within the five markers
    let icon = UIImageView(frame: CGRect(x: 0, y: 0, width: 44, height: 44.7)) // user's map avatar view
    var iconImage = UIImage() // user's map avatar icon image
    var mapView: GMSMapView! // mapView assgined to user pin. marker.map, can be set to nil
    var index = 0 // index of five random coordinates of user pin
    var pause = false {
        didSet {
            // invalidate the timer when need to stop updating the random locations of user pin
            if pause {
                if self.timer != nil {
                    self.timer.invalidate()
                }
            } else {
                // timer interval is between 5s to 20s
                let time = Double.random(min: 5, max: 20)
                self.timer = Timer.scheduledTimer(timeInterval: time, target: self, selector: #selector(self.updatePositionAndTimer), userInfo: nil, repeats: false)
            }
        }
    }
    var valid = true {
        didSet {
            if valid {
                let time = Double.random(min: 5, max: 20)
                self.timer = Timer.scheduledTimer(timeInterval: time, target: self, selector: #selector(self.updatePositionAndTimer), userInfo: nil, repeats: false)
            } else {
                self.marker?.map = nil
                if self.timer != nil {
                    self.timer.invalidate()
                }
                marker?.iconView = icon
                marker?.icon = nil
                UIView.animate(withDuration: 0.3, delay: 0, animations: {
                    self.icon.alpha = 0
                }, completion: { _ in
                    self.marker?.map = nil
                    if self.timer != nil {
                        self.timer.invalidate()
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
        if let image = UIImage(named: "mapAvatar_\(miniAvatar + 1)") {
            self.iconImage = image
        }
        self.icon.image = iconImage
        self.icon.contentMode = .scaleAspectFit
        
        self.marker = GMSMarker()
        self.marker?.zIndex = 1 // map markers' overlapping level
    }
    
    // func will be called when init it outside not in this class
    func firstLoading() {
        self.marker?.userData = [1: self] // warning: if dealloc is not done properly, circular reference will occur. right way: using "weak"
        self.marker?.map = self.mapView
        self.marker?.position = self.positions[self.index]
        
//        self.marker?.icon = self.iconImage
        
        self.icon.alpha = 0
        self.marker?.iconView = icon
        self.marker?.icon = nil
        let delay = Double.random(min: 0, max: 1)
        UIView.animate(withDuration: 1, delay: delay, animations: {
            self.icon.alpha = 1
        }, completion: { _ in
            self.marker?.iconView = nil
            self.marker?.icon = self.iconImage
        })
        
        let time = Double.random(min: 5, max: 20)
        self.timer = Timer.scheduledTimer(timeInterval: time, target: self, selector: #selector(self.updatePositionAndTimer), userInfo: nil, repeats: false)
        
        self.index += 1
    }
    
    func updatePositionAndTimer() {

        self.marker?.iconView = icon
        self.marker?.icon = nil
        
        if self.index == 5 {
            self.index = 0
        }
        
        UIView.animate(withDuration: 0.3, delay: 0, animations: {
            self.icon.alpha = 0
        }, completion: { _ in
            if self.index >= self.positions.count {
                return
            }
            self.marker?.map = nil
            self.marker = nil
            self.marker = GMSMarker(position: self.positions[self.index])
            self.marker?.iconView = self.icon
            if self.valid {
                self.marker?.map = self.mapView
                UIView.animate(withDuration: 1, delay: 0.1, animations: {
                    self.icon.alpha = 1
                }, completion: { _ in
                    self.marker?.iconView = nil
                    self.marker?.icon = self.iconImage
                })
            } else {
                if self.timer != nil {
                    self.timer.invalidate()
                }
                return
            }
            self.index += 1
        })
        
        let time = Double.random(min: 5, max: 20)
        self.timer = Timer.scheduledTimer(timeInterval: time, target: self, selector: #selector(self.updatePositionAndTimer), userInfo: nil, repeats: false)
    }
}
