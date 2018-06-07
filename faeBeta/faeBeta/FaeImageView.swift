//
//  FaeImageView.swift
//  faeBeta
//
//  Created by Yue on 5/30/17.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit
import RealmSwift

let faeImageCache = NSCache<AnyObject, AnyObject>()
let faeChatRoomImageCache = NSCache<AnyObject, AnyObject>()

class FaeImageView: UIImageView {
    
    public var fileID = -1
    private var isChatRoom = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.openThisMedia(_:)))
        self.addGestureRecognizer(tapRecognizer)
        self.isUserInteractionEnabled = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public func loadImage(id: Int, isChatRoom: Bool = false) {
        
        self.isChatRoom = isChatRoom
        
        self.image = nil
        
        func loadNormalCache() {
            if let imageFromCache = faeImageCache.object(forKey: id as AnyObject) as? UIImage {
                self.image = imageFromCache
                return
            }
        }
        
        func loadChatRoomCache() {
            if let imageFromCache = faeChatRoomImageCache.object(forKey: id as AnyObject) as? UIImage {
                self.image = imageFromCache
                return
            }
        }
        
        isChatRoom ? loadChatRoomCache() : loadNormalCache()
        
        getImage(fileID: fileID, type: 2, isChatRoom: isChatRoom) { (status, etag, imageRawData) in
            DispatchQueue.main.async(execute: {
                guard imageRawData != nil else { return }
                guard let imageToCache = UIImage(data: imageRawData!) else { return }
                
                if self.fileID == id {
                    self.image = imageToCache
                }
                
                isChatRoom ? faeChatRoomImageCache.setObject(imageToCache, forKey: id as AnyObject) : faeImageCache.setObject(imageToCache, forKey: id as AnyObject)
            })
        }
    }
    
    @objc private func openThisMedia(_ sender: UIGestureRecognizer) {
        let realm = try! Realm()
        // If previous avatar does exist in realm
        if let avatarRealm = realm.objects(UserImage.self).filter("user_id == @%", "\(fileID)").first {
            if avatarRealm.largeAvatarEtag == nil {
                // Get full size avatar if there is none of it, type => 0
                getImage(fileID: self.fileID, type: 0, isChatRoom: isChatRoom) { (status, etag, imageRawData) in
                    if status / 100 == 2 {
                        print("[FaeAvatarView] largeAvatarEtag == nil")
                        // Update realm with the same object
                        try! realm.write {
                            avatarRealm.largeAvatarEtag = etag
                            avatarRealm.userLargeAvatar = imageRawData as NSData?
                        }
                        guard imageRawData != nil else { return }
                        guard let image = UIImage(data: imageRawData!) else { return }
                        var images = [SKPhoto]()
                        let photo = SKPhoto.photoWithImage(image)
                        images.append(photo)
                        self.presentPhotoBrowser(photos: images)
                    } else {
                        // Otherwise use the current imageView.image
                        print("[FaeAvatarView] get large image fail")
                        let imageView = sender.view as! UIImageView
                        guard let image = imageView.image else { return }
                        var images = [SKPhoto]()
                        let photo = SKPhoto.photoWithImage(image)
                        images.append(photo)
                        self.presentPhotoBrowser(photos: images)
                    }
                }
            } else {
                // Otherwise use the large avatar stored in realm
                print("[FaeAvatarView] large image exists")
                guard let image = UIImage(data: (avatarRealm.userLargeAvatar as Data?)!) else { return }
                var images = [SKPhoto]()
                let photo = SKPhoto.photoWithImage(image)
                images.append(photo)
                self.presentPhotoBrowser(photos: images)
            }
        } else {
            // If no RealmUser obj found with userID
            print("[FaeAvatarView] get large image fail")
            let imageView = sender.view as! UIImageView
            guard let image = imageView.image else { return }
            var images = [SKPhoto]()
            let photo = SKPhoto.photoWithImage(image)
            images.append(photo)
            self.presentPhotoBrowser(photos: images)
        }
    }
    
    private func presentPhotoBrowser(photos: [SKPhotoProtocol]) {
        let browser = SKPhotoBrowser(photos: photos)
        browser.initializePageIndex(0)
        /*guard let browser = IDMPhotoBrowser(photos: photos) else {
            print("[FaeAvatarView - openThisMedia] Photo Browser doesn't exist!")
            return
        }*/
        //browser.displayDoneButton = false
        //browser.displayActionButton = false
        //browser.dismissOnTouch = true
        UIApplication.shared.keyWindow?.visibleViewController?.present(browser, animated: true, completion: nil)
    }
}
