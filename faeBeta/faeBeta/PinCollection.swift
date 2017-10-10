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
    var colTime: String?
    var itemsCount: Int = 0
    
    init(json: JSON) {
        colId = json["collection_id"].intValue
        colName = json["name"].stringValue
        colDesp = json["description"].stringValue
        colType = json["type"].stringValue
        boolPri = json["is_private"].boolValue
//        colTime = json["created_at"]["date"].stringValue.formatNSDate()
    }
}

struct CollectionList {
    let colId: Int
    var colName: String
    var colDesp: String
    let colType: String
    var boolPri: Bool
    var pinIds = [Int]()
    var colTime: String?
    
    init(json: JSON) {
        colId = json["collection_id"].intValue
        colName = json["name"].stringValue
        colDesp = json["description"].stringValue
        colType = json["type"].stringValue
        boolPri = json["is_private"].boolValue
//        colTime = json["created_at"]["date"].stringValue.formatNSDate()
        let ids = json["pin_id"].arrayValue.map({Int($0.stringValue)})
        for id in ids {
            if id != nil {
                pinIds.append(id!)
            }
        }
    }
}
