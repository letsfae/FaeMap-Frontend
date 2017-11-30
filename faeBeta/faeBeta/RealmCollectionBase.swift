//
//  RealmCollectionBase.swift
//  faeBeta
//
//  Created by Faevorite 2 on 2017-11-27.
//  Copyright © 2017 fae. All rights reserved.
//

import Foundation
import RealmSwift

class RealmCollection: Object {
    @objc dynamic var collection_id: Int = 0
    @objc dynamic var name: String = ""
    @objc dynamic var user_id: Int = 0
    @objc dynamic var descrip: String = ""
    @objc dynamic var type: String = ""
    @objc dynamic var is_private: Bool = false
    @objc dynamic var created_at: String = ""
    @objc dynamic var count: Int = 0
    @objc dynamic var last_updated_at: String = ""
    var pins = List<CollectedPin>()
    
    override static func primaryKey() -> String? {
        return "collection_id"
    }
    
    convenience init(collection_id: Int, name: String, user_id: Int, desp: String, type: String, is_private: Bool, created_at: String, count: Int, last_updated_at: String) {
        self.init()
        self.collection_id = collection_id
        self.name = name
        self.user_id = user_id
        self.descrip = desp
        self.type = type
        self.is_private = is_private
        self.created_at = created_at
        self.count = count
        self.last_updated_at = last_updated_at
    }

    static func filterCollectedTypes(type: String) -> Results<RealmCollection> {
        let realm = try! Realm()
        return realm.objects(RealmCollection.self).filter("type == %@", type).sorted(byKeyPath: "collection_id")
    }
    
    static func filterCollectedPin(collection_id: Int) -> RealmCollection? {
        let realm  = try! Realm()
        return realm.object(ofType: RealmCollection.self, forPrimaryKey: collection_id)
    }
    static func savePin(collection_id: Int, type: String, pin_id: Int) {
        let curtDate = Date()
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
        let added_at = dateformatter.string(from: curtDate)
        
        let pin = CollectedPin(pin_id: pin_id, added_at: added_at)
        pin.setPrimaryKeyInfo(pin_id, added_at)
        
        let realm  = try! Realm()
        guard let col = filterCollectedPin(collection_id: collection_id) else {
            return
        }

        try! realm.write{
            col.pins.append(pin)
            col.count += 1
            print("add pin")
        }
//        col.pins.sorted {$0.added_at > $1.added_at}
    }
    
    static func unsavePin(collection_id: Int, type: String, pin_id: Int) {
        let realm  = try! Realm()
        guard let col = filterCollectedPin(collection_id: collection_id) else {
            return
        }
        
        var idx = 0
        var pin: CollectedPin!
        for i in 0..<col.pins.count {
            if col.pins[i].pin_id == pin_id {
                idx = i
                pin = col.pins[i]
            }
        }
        
        try! realm.write {
            col.pins.remove(at: idx)
            col.count -= 1
            realm.delete(pin)
            print("remove pin")
        }
    }
}

class CollectedPin: Object {
    @objc dynamic var pin_id: Int = 0
    @objc dynamic var added_at: String = ""
    @objc dynamic var primary_key: String = ""
    
    convenience init(pin_id: Int, added_at: String) {
        self.init()
        self.pin_id = pin_id
        self.added_at = added_at
    }
    
    override static func primaryKey() -> String? {
        return "primary_key"
    }
    
    func setPrimaryKeyInfo(_ pin_id: Int, _ added_at: String) {
        self.pin_id = pin_id
        self.added_at = added_at
        self.primary_key = "\(pin_id)_\(added_at)"
    }
}

