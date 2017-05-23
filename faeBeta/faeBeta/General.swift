//
//  FaeAvatarGetter.swift
//  faeBeta
//
//  Created by Yue on 5/23/17.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit
import RealmSwift

class General: NSObject {
    
    static let shared = General()
    
    func avatar(userid: Int, completion:@escaping (UIImage) -> Void) {
        
        var image = UIImage()
        
        if userid == 0 {
            completion(image)
        }
        
        getImage(userID: userid, type: 2) { (status, etag, imageRawData) in
            let realm = try! Realm()
            if let avatarRealm = realm.objects(RealmUser.self).filter("userID == '\(userid)'").first {
                // 存在User，Etag没变
                if etag == avatarRealm.smallAvatarEtag {
                    image = UIImage.sd_image(with: avatarRealm.userSmallAvatar as Data!)
                    completion(image)
                }
                // 存在User，Etag改变
                else {
                    try! realm.write {
                        avatarRealm.smallAvatarEtag = etag
                        avatarRealm.userSmallAvatar = imageRawData as NSData?
                        avatarRealm.largeAvatarEtag = nil
                        avatarRealm.userLargeAvatar = nil
                    }
                    image = UIImage.sd_image(with: imageRawData)
                    completion(image)
                }
            } else {
                // 不存在User
                let avatarObj = RealmUser()
                avatarObj.userID = "\(userid)"
                avatarObj.smallAvatarEtag = etag
                avatarObj.userSmallAvatar = imageRawData as NSData?
                try! realm.write {
                    realm.add(avatarObj)
                }
                image = UIImage.sd_image(with: imageRawData)
                completion(image)
            }
        }
    }
}
