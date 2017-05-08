//
//  FaeUserAvatar.swift
//  faeBeta
//
//  Created by Yue on 5/6/17.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit
import RealmSwift
import IDMPhotoBrowser

class FaeAvatarView: UIImageView {

    var userID = -1
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.openThisMedia(_:)))
        self.addGestureRecognizer(tapRecognizer)
        self.isUserInteractionEnabled = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func openThisMedia(_ sender: UIGestureRecognizer) {
        let realm = try! Realm()
        if let avatarRealm = realm.objects(RealmUser.self).filter("userID == '\(self.userID)'").first {
            if avatarRealm.largeAvatarEtag == nil {
                getImage(userID: self.userID, type: 0) { (status, etag, imageRawData) in
                    if status / 100 == 2 {
                        print("[FaeAvatarView] largeAvatarEtag == nil")
                        try! realm.write {
                            avatarRealm.largeAvatarEtag = etag
                            avatarRealm.userLargeAvatar = imageRawData as NSData?
                        }
                        guard let image = UIImage.sd_image(with: imageRawData) else { return }
                        let photos = IDMPhoto.photos(withImages: [image])
                        self.presentPhotoBrowser(photos: photos)
                    } else {
                        print("[FaeAvatarView] get large image fail")
                        let imageView = sender.view as! UIImageView
                        guard let image = imageView.image else { return }
                        let photos = IDMPhoto.photos(withImages: [image])
                        self.presentPhotoBrowser(photos: photos)
                    }
                }
            } else {
                print("[FaeAvatarView] large image exists")
                guard let image = UIImage.sd_image(with: avatarRealm.userLargeAvatar as Data!) else { return }
                let photos = IDMPhoto.photos(withImages: [image])
                self.presentPhotoBrowser(photos: photos)
            }
        } else {
            print("[FaeAvatarView] get large image fail")
            let imageView = sender.view as! UIImageView
            guard let image = imageView.image else { return }
            let photos = IDMPhoto.photos(withImages: [image])
            self.presentPhotoBrowser(photos: photos)
        }
    }
    
    fileprivate func presentPhotoBrowser(photos: [Any]?) {
        guard let browser = IDMPhotoBrowser(photos: photos) else {
            print("[FaeAvatarView - openThisMedia] Photo Browser doesn't exist!")
            return
        }
        browser.displayDoneButton = false
        browser.displayActionButton = false
        browser.dismissOnTouch = true
        UIApplication.shared.keyWindow?.visibleViewController?.present(browser, animated: true, completion: nil)
    }
}
