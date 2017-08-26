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

let faeAvatarCache = NSCache<AnyObject, AnyObject>()

class FaeAvatarView: UIImageView {

    var userID = -1
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // add tapRecoginizer to open the bigger image of this view
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.openThisMedia(_:)))
        self.addGestureRecognizer(tapRecognizer)
        self.isUserInteractionEnabled = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func loadAvatar(id: Int) {
        
        self.image = nil
        
        if let imageFromCache = faeImageCache.object(forKey: id as AnyObject) as? UIImage {
//            joshprint("[getAvatar - \(id)] already in cache")
            self.image = imageFromCache
            return
        }
        
        getAvatar(userID: self.userID, type: 2) { (status, etag, imageRawData) in
            guard imageRawData != nil else {
//                print("[getAvatar] fail, imageRawData is nil")
                return
            }
            guard status / 100 == 2 || status / 100 == 3 else { return }
            DispatchQueue.main.async(execute: {
                guard let imageToCache = UIImage.sd_image(with: imageRawData) else { return }
                if self.userID == id {
                    self.image = imageToCache
                }
                faeImageCache.setObject(imageToCache, forKey: id as AnyObject)
            })
        }
    }

    func openThisMedia(_ sender: UIGestureRecognizer) {
        getAvatar(userID: self.userID, type: 0) { (status, etag, imageRawData) in
            guard imageRawData != nil else { return }
            guard status / 100 == 2 || status / 100 == 3 else { return }
            guard let image = UIImage.sd_image(with: imageRawData) else { return }
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
