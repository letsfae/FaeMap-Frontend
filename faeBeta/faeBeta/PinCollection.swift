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
    let id: Int
    var name: String
    var desp: String
    let type: String
    var boolPri: Bool
    var time: String
    var itemsCount: Int = 0
    var pinIds = [Int]()
    var lastUpdate: String
    var creatorId: Int
    
    init(json: JSON) {
        id = json["collection_id"].intValue
        name = json["name"].stringValue
        desp = json["description"].stringValue
        type = json["type"].stringValue
        boolPri = json["is_private"].boolValue
        let time_raw = json["created_at"].stringValue
        let date = time_raw.split(separator: " ")[0].split(separator: "-")
        time = date[1] + "/" + date[0]
        itemsCount = json["count"].intValue
        let updateTime = json["last_updated_at"].stringValue
        let updateDate = updateTime.split(separator: " ")[0].split(separator: "-")
        lastUpdate = updateDate[1] + "/" + updateDate[0]
        let ids = json["pins"].arrayValue //.map({Int($0.stringValue)})
        if ids.count != 0 {
            for id in ids {
                pinIds.append(id["pin_id"].intValue)
            }
        }
        creatorId = json["user_id"].intValue
    }
}
