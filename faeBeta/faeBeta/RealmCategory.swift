//
//  RealmCategoryCount.swift
//  faeBeta
//
//  Created by Faevorite 2 on 2018-06-29.
//  Copyright © 2018 fae. All rights reserved.
//

import Foundation
import RealmSwift

class RealmCategory: Object {
    @objc dynamic var primary_key: String = ""
    @objc dynamic var user_id: Int = 0
    @objc dynamic var name: String = ""
    @objc dynamic var weight: Double = 0.0
    
    override static func primaryKey() -> String {
        return "primary_key"
    }
}

extension Realm {
    func filterMyCatDict() -> Results<RealmCategory> {
        return self.objects(RealmCategory.self).filter("user_id == %@", Key.shared.user_id).sorted(byKeyPath: "weight", ascending: false)
    }
    
    func filterCategory(primary_key: String) -> RealmCategory? {
        return self.object(ofType: RealmCategory.self, forPrimaryKey: primary_key)
    }
}
