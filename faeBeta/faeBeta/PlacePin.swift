//
//  PlacePin.swift
//  faeBeta
//
//  Created by Yue on 3/2/17.
//  Copyright © 2017 fae. All rights reserved.
//

import Foundation
import SwiftyJSON

struct PlacePin {
    let imageURL: String
    let address1: String
    let address2: String
    let name: String
    let position: CLLocationCoordinate2D
    var category = [String]()
    var primaryCate: String
    
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
        }
        else if tmp_cate.contains("pizza") {
            self.primaryCate = "pizza"
        }
        else if tmp_cate.contains("coffee") {
            self.primaryCate = "coffee"
        }
        else if tmp_cate.contains("desserts") {
            self.primaryCate = "desserts"
        }
        else if tmp_cate.contains("icecream") {
            self.primaryCate = "desserts"
        }
        else if tmp_cate.contains("movietheaters") {
            self.primaryCate = "movietheaters"
        }
        else if tmp_cate.contains("museums") {
            self.primaryCate = "museums"
        }
        else if tmp_cate.contains("galleries") {
            self.primaryCate = "museums"
        }
        else if tmp_cate.contains("beautysvc") {
            self.primaryCate = "beautysvc"
        }
        else if tmp_cate.contains("spas") {
            self.primaryCate = "beautysvc"
        }
        else if tmp_cate.contains("barbers") {
            self.primaryCate = "beautysvc"
        }
        else if tmp_cate.contains("skincare") {
            self.primaryCate = "beautysvc"
        }
        else if tmp_cate.contains("massage") {
            self.primaryCate = "beautysvc"
        }
        else if tmp_cate.contains("playgrounds") {
            self.primaryCate = "playgrounds"
        }
        else if tmp_cate.contains("countryclubs") {
            self.primaryCate = "playgrounds"
        }
        else if tmp_cate.contains("sports_clubs") {
            self.primaryCate = "playgrounds"
        }
        else if tmp_cate.contains("bubbletea") {
            self.primaryCate = "juicebars"
        }
        else if tmp_cate.contains("juicebars") {
            self.primaryCate = "juicebars"
        } else {
            self.primaryCate = ""
        }
    }
}
