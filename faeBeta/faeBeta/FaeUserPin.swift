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
    var userId: Int = -1
    var type: String = ""
    var miniAvatar: Int = -1
    var positions = [CLLocationCoordinate2D]()
    var marker = GMSMarker()
    var timer: Timer!
    let icon = UIImageView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
    var iconImage = UIImage()
    var mapView: GMSMapView!
    var index = 0
    var pause = false {
        didSet {
            if !pause {
                let time = Double.random(min: 5, max: 20)
                self.timer = Timer.scheduledTimer(timeInterval: time, target: self, selector: #selector(self.updatePositionAndTimer), userInfo: nil, repeats: false)
            } else {
                if self.timer != nil {
                    self.timer.invalidate()
                }
            }
        }
    }
    var valid = true {
        didSet {
            if valid {
                let time = Double.random(min: 5, max: 20)
                self.timer = Timer.scheduledTimer(timeInterval: time, target: self, selector: #selector(self.updatePositionAndTimer), userInfo: nil, repeats: false)
            } else {
                marker.iconView = icon
                marker.icon = nil
                UIView.animate(withDuration: 0.3, delay: 0, animations: {
                    self.icon.alpha = 0
                }, completion: {(_) in
                    self.marker.map = nil
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
        
        if let image = UIImage(named: "mapAvatar_\(miniAvatar+1)") {
            self.iconImage = image
        }
        
        icon.image = iconImage
        icon.contentMode = .scaleAspectFit
        
        marker.zIndex = 1
    }
    
    func firstLoading() {
        marker.userData = [1: self]
        marker.iconView = icon
        marker.icon = nil
        icon.alpha = 0
        self.marker.map = self.mapView
        self.marker.position = self.positions[self.index]
        let delay = Double.random(min: 0, max: 1)
        UIView.animate(withDuration: 1, delay: delay, animations: {
            self.icon.alpha = 1
        }, completion: {(_) in
            self.marker.iconView = nil
            self.marker.icon = self.iconImage
        })
        
        let time = Double.random(min: 5, max: 20)
        self.timer = Timer.scheduledTimer(timeInterval: time, target: self, selector: #selector(self.updatePositionAndTimer), userInfo: nil, repeats: false)
        
        self.index += 1
    }
    
    func updatePositionAndTimer() {
        marker.iconView = icon
        marker.icon = nil
        
        if index == 5 {
            index = 0
        }
        UIView.animate(withDuration: 0.3, delay: 0, animations: {
            self.icon.alpha = 0
        }, completion: {(_) in
            self.marker.position = self.positions[self.index]
            self.marker.map = nil
            if self.valid {
                self.marker.map = self.mapView
                UIView.animate(withDuration: 1, delay: 0.1, animations: {
                    self.icon.alpha = 1
                }, completion: {(_) in
                    self.marker.iconView = nil
                    self.marker.icon = self.iconImage
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
