//
//  PinCollection.swift
//  faeBeta
//
//  Created by Faevorite 2 on 2017-10-09.
//  Copyright © 2017 fae. All rights reserved.
//

import Foundation
import SwiftyJSON

struct PinCollection {
    let colId: Int
    var colName: String
    var colDesp: String
    let colType: String
    var boolPri: Bool
    var colTime: String
    var itemsCount: Int = 0
    
    init(json: JSON) {
        colId = json["collection_id"].intValue
        colName = json["name"].stringValue
        colDesp = json["description"].stringValue
        colType = json["type"].stringValue
        boolPri = json["is_private"].boolValue
        let time = json["created_at"].stringValue
        let date = time.split(separator: " ")[0].split(separator: "-")
        colTime = date[1] + "/" + date[0]
    }
}

struct CollectionList {
    let colId: Int
    var colName: String
    var colDesp: String
    let colType: String
    var boolPri: Bool
    var pinIds = [Int]()
    var colTime: String
    
    init(json: JSON) {
        colId = json["collection_id"].intValue
        colName = json["name"].stringValue
        colDesp = json["description"].stringValue
        colType = json["type"].stringValue
        boolPri = json["is_private"].boolValue
        let time = json["created_at"].stringValue
        let date = time.split(separator: " ")[0].split(separator: "-")
        colTime = date[1] + "/" + date[0]
        let ids = json["pin_id"].arrayValue//.map({Int($0.stringValue)})
        if ids.count != 0 {
            for id in ids {
                pinIds.append(id["pin_id"].intValue)
            }
        }
    }
}

struct SavedPin {
    let pinId: Int
    let pinType: String
    let pinName: String
    let pinAddr: String
    let pinBelongs: String
    var memo: String
    
    init(json: JSON) {
        pinId = json["pin_id"].intValue
        pinType = json["type"].stringValue
        if pinType == "place" {
            pinName = json["pin_object"]["name"].stringValue
            let addr1 = json["pin_object"]["address"].stringValue
            let addr2 = json["pin_object"]["city"].stringValue + ", " + json["pin_object"]["state"].stringValue + ", " + json["pin_object"]["country"].stringValue
            pinAddr = addr1 + ", " + addr2
        } else {
            pinName = json["pin_object"]["geolocation"]["latitude"].stringValue
            pinAddr = json["pin_object"]["geolocation"]["longitude"].stringValue
        }
        pinBelongs = json["saved_collections"].stringValue
        // 现在后端get不到memo内容
        memo = json["memo"].stringValue
    }
}
