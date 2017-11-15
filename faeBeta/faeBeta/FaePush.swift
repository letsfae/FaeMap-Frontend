//
//  FaePush.swift
//  faeBeta
//
//  Created by blesssecret on 11/5/16.
//  Copyright © 2016 fae. All rights reserved.
//

import Foundation

class FaePush: NSObject {
    
    static let shared = FaePush()
    
    var keyValue = [String: AnyObject]()
    
    override init () {

    }
    
    func whereKey(_ key: String, value: String) -> Void {
        keyValue[key] = value as AnyObject?
    }
    
    func clearKeyValue() -> Void {
        self.keyValue = [String: AnyObject]()
    }

    func getSync(_ completion:@escaping (Int, Any?) -> Void) {
        getFromURL("sync", parameter: nil, authentication: Key.shared.headerAuthentication()) {(status: Int, message: Any?) in
            completion(status, message)
        }
    }
}
