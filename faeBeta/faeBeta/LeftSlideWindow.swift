//
//  LeftSlideWindow.swift
//  faeBeta
//
//  Created by Yue on 8/9/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
import SwiftyJSON
import SDWebImage
import RealmSwift

//MARK: show left slide window
extension FaeMapViewController {
    
    func jumpToMyFaeMainPage() {
        let vc = UIStoryboard(name: "Main", bundle: nil) .instantiateViewController(withIdentifier: "MyFaeMainPageViewController") as! MyFaeMainPageViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func getUserStatus() {
        let storageForUserStatus = LocalStorageManager()
        if let user_status = storageForUserStatus.readByKey("userStatus") {
            userStatus = user_status as! Int
        }
    }
    
    func updateSelfInfo() {
        let updateNickName = FaeUser()
        updateNickName.getSelfNamecard(){(status:Int, message: Any?) in
            if status / 100 == 2 {
                let nickNameInfo = JSON(message!)
                if let str = nickNameInfo["nick_name"].string {
                    nickname = str
                }
            }
        }
        
        if user_id != -1 {
            let realm = try! Realm()
            let selfInfoRealm = realm.objects(SelfInformation.self).filter("currentUserID == \(user_id) AND avatar != nil")
            if selfInfoRealm.count == 0 {
                let imageViewAvatarMore = UIImageView()
                let urlStringHeader = "\(baseURL)/files/users/\(user_id)/avatar"
                imageViewAvatarMore.sd_setImage(with: URL(string: urlStringHeader), placeholderImage: Key.sharedInstance.imageDefaultMale, options: [.retryFailed, .refreshCached], completed: { (image, error, SDImageCacheType, imageURL) in
                    if image != nil {
                        let selfInfoRealm = SelfInformation()
                        selfInfoRealm.currentUserID = Int(user_id)
                        selfInfoRealm.avatar = UIImageJPEGRepresentation(image!, 1.0) as NSData?
                        try! realm.write {
                            realm.add(selfInfoRealm)
                        }
                    }
                })
            }
        }
    }
}
