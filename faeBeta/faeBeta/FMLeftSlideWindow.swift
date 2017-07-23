//
//  LeftSlideWindow.swift
//  faeBeta
//
//  Created by Yue on 8/9/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
import SwiftyJSON

extension FaeMapViewController {
    
    func jumpToMyFaeMainPage() {
        let vc = MyFaeMainPageViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func getUserStatus() {
        let storageForUserStatus = LocalStorageManager()
        if let user_status = storageForUserStatus.readByKey("userStatus") {
            userStatus = user_status as! Int
        }
    }
    
    func updateSelfInfo() {
        DispatchQueue.global(qos: .utility).async {
            let updateNickName = FaeUser()
            updateNickName.getSelfNamecard(){(status:Int, message: Any?) in
                guard status / 100 == 2 else { return }
                let nickNameInfo = JSON(message!)
                if let str = nickNameInfo["nick_name"].string {
                    Key.shared.nickname = str
                }
            }
        }
    }
}
