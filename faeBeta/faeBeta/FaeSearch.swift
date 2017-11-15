//
//  FaeSearch.swift
//  faeBeta
//
//  Created by Yue Shen on 10/25/17.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit
import SwiftyJSON

class FaeSearch {
    
    static let shared = FaeSearch()
    
    var keyValue = [String: String]()
    func whereKey(_ key: String, value: String) {
        keyValue[key] = value
    }
    
    func clearKeyValue() {
        keyValue = [String: String]()
    }
    
    func search(_ completion: @escaping (Int, Any?) -> Void) {
        searchToURL(.search, parameter: keyValue) { (status: Int, message: Any?) in
            self.clearKeyValue()
            completion(status, message)
        }
    }
}
