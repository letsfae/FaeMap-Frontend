//
//  PlacePin.swift
//  faeBeta
//
//  Created by Yue on 3/2/17.
//  Copyright © 2017 fae. All rights reserved.
//

import Foundation
import SwiftyJSON
import CoreLocation

extension PlacePin: Equatable {
    static func ==(lhs: PlacePin, rhs: PlacePin) -> Bool {
        return lhs.name == rhs.name
    }
}

struct PlacePin {
    let imageURL: String
    let address1: String
    let address2: String
    let name: String
    let position: CLLocationCoordinate2D
    var category = [String]()
    var primaryCate: String
    var markerAvatar: UIImage
    
    init(json: JSON) {
        var tmp_cate = [String]()
        for alias in json["categories"].arrayValue {
            tmp_cate.append(alias["alias"].stringValue)
        }
        // Modified by Yue Shen - 02.07.17
        self.imageURL = json["image_url"].stringValue
        self.address1 = json["location"]["address1"].stringValue
        self.address2 = json["location"]["city"].stringValue + ", " + json["location"]["state"].stringValue + ", " + json["location"]["country"].stringValue
        self.name = json["name"].stringValue
        self.position = CLLocationCoordinate2D(latitude: json["coordinates"]["latitude"].doubleValue,
                                               longitude: json["coordinates"]["longitude"].doubleValue)
        self.category = tmp_cate
        if tmp_cate.contains("burgers") {
            self.primaryCate = "burgers"
            self.markerAvatar = #imageLiteral(resourceName: "placePinBurger")
        }
        else if tmp_cate.contains("pizza") {
            self.primaryCate = "pizza"
            self.markerAvatar = #imageLiteral(resourceName: "placePinPizza")
        }
        else if tmp_cate.contains("coffee") {
            self.primaryCate = "coffee"
            self.markerAvatar = #imageLiteral(resourceName: "placePinCoffee")
        }
        else if tmp_cate.contains("desserts") {
            self.primaryCate = "desserts"
            self.markerAvatar = #imageLiteral(resourceName: "placePinDesert")
        }
        else if tmp_cate.contains("icecream") {
            self.primaryCate = "desserts"
            self.markerAvatar = #imageLiteral(resourceName: "placePinDesert")
        }
        else if tmp_cate.contains("movietheaters") {
            self.primaryCate = "movietheaters"
            self.markerAvatar = #imageLiteral(resourceName: "placePinCinema")
        }
        else if tmp_cate.contains("museums") {
            self.primaryCate = "museums"
            self.markerAvatar = #imageLiteral(resourceName: "placePinArt")
        }
        else if tmp_cate.contains("galleries") {
            self.primaryCate = "museums"
            self.markerAvatar = #imageLiteral(resourceName: "placePinArt")
        }
        else if tmp_cate.contains("beautysvc") {
            self.primaryCate = "beautysvc"
            self.markerAvatar = #imageLiteral(resourceName: "placePinBoutique")
        }
        else if tmp_cate.contains("spas") {
            self.primaryCate = "beautysvc"
            self.markerAvatar = #imageLiteral(resourceName: "placePinBoutique")
        }
        else if tmp_cate.contains("barbers") {
            self.primaryCate = "beautysvc"
            self.markerAvatar = #imageLiteral(resourceName: "placePinBoutique")
        }
        else if tmp_cate.contains("skincare") {
            self.primaryCate = "beautysvc"
            self.markerAvatar = #imageLiteral(resourceName: "placePinBoutique")
        }
        else if tmp_cate.contains("massage") {
            self.primaryCate = "beautysvc"
            self.markerAvatar = #imageLiteral(resourceName: "placePinBoutique")
        }
        else if tmp_cate.contains("playgrounds") {
            self.primaryCate = "playgrounds"
            self.markerAvatar = #imageLiteral(resourceName: "placePinSport")
        }
        else if tmp_cate.contains("countryclubs") {
            self.primaryCate = "playgrounds"
            self.markerAvatar = #imageLiteral(resourceName: "placePinSport")
        }
        else if tmp_cate.contains("sports_clubs") {
            self.primaryCate = "playgrounds"
            self.markerAvatar = #imageLiteral(resourceName: "placePinSport")
        }
        else if tmp_cate.contains("bubbletea") {
            self.primaryCate = "juicebars"
            self.markerAvatar = #imageLiteral(resourceName: "placePinBoba")
        }
        else if tmp_cate.contains("juicebars") {
            self.primaryCate = "juicebars"
            self.markerAvatar = #imageLiteral(resourceName: "placePinBoba")
        } else {
            self.primaryCate = ""
            self.markerAvatar = UIImage()
        }
    }
}
