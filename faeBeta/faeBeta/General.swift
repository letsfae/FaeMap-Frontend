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
        
        if userid <= 0 {
            completion(UIImage())
        }
        
        if let imageFromCache = faeImageCache.object(forKey: userid as AnyObject) as? UIImage {
            print("[getAvatar - \(userid)] already in cache")
            completion(imageFromCache)
            return
        }
        
        getAvatar(userID: userid, type: 2) { (status, etag, imageRawData) in
            guard imageRawData != nil else {
                print("[getAvatar] fail, imageRawData is nil")
                return
            }
            guard status / 100 == 2 || status / 100 == 3 else { return }
            DispatchQueue.main.async(execute: {
                guard let imageToCache = UIImage.sd_image(with: imageRawData) else { return }
                faeImageCache.setObject(imageToCache, forKey: userid as AnyObject)
                completion(imageToCache)
            })
        }
    }
}
