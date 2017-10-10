//
//  FaeCollection.swift
//  faeBeta
//
//  Created by Faevorite 2 on 2017-10-09.
//  Copyright © 2017 fae. All rights reserved.
//

import Foundation

class FaeCollection : NSObject {
    
    var keyValue = [String:AnyObject]()
    
    func whereKey(_ key:String, value:String) -> Void {
        keyValue[key] = value as AnyObject?
    }
    
    func clearKeyValue()->Void{
        self.keyValue = [String: AnyObject]()
    }
    
    // Create collection
    func createCollection(_ completion: @escaping (Int, Any?) -> Void) {
        postToURL("collections", parameter: keyValue, authentication: headerAuthentication()) { (status:Int, message: Any?) in
            self.clearKeyValue()
            completion(status, message)
        }
    }
    
    // Get collections
    func getCollections(_ completion: @escaping (Int, Any?) -> Void) {
        getFromURL("collections", parameter: keyValue, authentication: headerAuthentication()) { (status:Int, message: Any?) in
            self.clearKeyValue()
            completion(status, message)
        }
    }
    
    // Edit one collection
    func editOneCollection(_ collectionID: String?, completion: @escaping (Int, Any?) -> Void) {
        if collectionID != nil {
            postToURL("collections/\(collectionID!)", parameter: keyValue, authentication: headerAuthentication()) { (status:Int, message: Any?) in
                self.clearKeyValue()
                completion(status, message)
            }
        }
    }
    
    // Get one collection
    func getOneCollection(_ collectionID: String?, completion: @escaping (Int, Any?) -> Void) {
        if collectionID != nil {
            getFromURL("collections/\(collectionID!)", parameter: keyValue, authentication: headerAuthentication()) { (status:Int, message: Any?) in
                self.clearKeyValue()
                completion(status, message)
            }
        }
    }
    
    // Delete one collection
    func deleteOneCollection(_ collectionID: String?, completion: @escaping (Int, Any?) -> Void) {
        if collectionID != nil {
            deleteFromURL("collections/\(collectionID!)", parameter: keyValue, authentication: headerAuthentication()) { (status:Int, message: Any?) in
                self.clearKeyValue()
                completion(status, message)
            }
        }
    }
    
    // Save place/location pin to collections
    func saveToCollection(_ type: String?, collectionID: String?, pinID: String?, completion: @escaping (Int, Any?) -> Void) {
        if type != nil && pinID != nil && collectionID != nil {
            postToURL("collections/\(collectionID!)/save/\(type!)/\(pinID!)", parameter: keyValue, authentication: headerAuthentication()) { (status:Int, message: Any?) in
                self.clearKeyValue()
                completion(status, message)
            }
        }
    }

    // Unsave place/location pin from collections
    func unsaveFromCollection(_ type: String?, collectionID: String?, pinID: String?, completion: @escaping (Int, Any?) -> Void) {
        if type != nil && pinID != nil && collectionID != nil {
            deleteFromURL("collections/\(collectionID!)/save/\(type!)/\(pinID!)", parameter: keyValue, authentication: headerAuthentication()) { (status:Int, message: Any?) in
                self.clearKeyValue()
                completion(status, message)
            }
        }
    }
    
    func createMemo(_ type: String?, pinID: String?, _ completion: @escaping (Int, Any?) -> Void) {
        postToURL("pins/\(type!)/\(pinID!)/memo", parameter: keyValue, authentication: headerAuthentication()) { (status:Int, message: Any?) in
            self.clearKeyValue()
            completion(status, message)
        }
    }
    
    func deleteMemo(_ type: String?, pinID: String?, _ completion: @escaping (Int, Any?) -> Void) {
        deleteFromURL("pins/\(type!)/\(pinID!)/memo", parameter: keyValue, authentication: headerAuthentication()) { (status:Int, message: Any?) in
            self.clearKeyValue()
            completion(status, message)
        }
    }
}
