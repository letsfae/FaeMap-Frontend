//
//  MPDLoadMedias.swift
//  faeBeta
//
//  Created by Yue on 12/13/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
import SwiftyJSON
import RealmSwift
import SDWebImage

extension MomentPinDetailViewController {
    func loadMedias() {
        for index in 0...fileIdArray.count-1 {
            let imageView = UIImageView(frame: CGRect(x: 105*index, y: 0, width: 95, height: 95))
            imageView.contentMode = .scaleAspectFill
            imageView.layer.cornerRadius = 13.5
            imageView.clipsToBounds = true
            imageViewMediaArray.append(imageView)
            scrollViewMedia.addSubview(imageView)
            let realm = try! Realm()
            let mediaRealm = realm.objects(Media.self).filter("fileId == \(self.fileIdArray[index]) AND picture != nil")
            if mediaRealm.count >= 1 {
                if let media = mediaRealm.first {
                    let picture = UIImage.sd_image(with: media.picture as Data!)
                    imageView.image = picture
                    self.displayMediaArray.append(picture!)
                    print("[cellForItemAt] \(index) read from Realm done!")
                }
            }
            else if mediaRealm.count == 0 {
                let fileURL = "\(baseURL)/files/\(self.fileIdArray[index])/data"
                imageView.sd_setImage(with: URL(string: fileURL), placeholderImage: nil, options: [.retryFailed, .refreshCached], completed: { (image, error, SDImageCacheType, imageURL) in
                    if image != nil {
                        let mediaImage = Media()
                        mediaImage.fileId = self.fileIdArray[index]
                        mediaImage.picture = UIImageJPEGRepresentation(image!, 1.0) as NSData?
                        try! realm.write {
                            realm.add(mediaImage)
                            print("[cellForItemAt] \(index) save in Realm done!")
                        }
                    }
                })
            }
        }
        self.scrollViewMedia.contentSize = CGSize(width: fileIdArray.count * 105 - 10, height: 95)
    }
    
    func zoomMedia(_ type: MediaMode) {
        var width = 95
        var space = 10
        var inset = 15
        if type == .large {
            width = 160
            space = 18
            inset = 27
        }
        for index in 0...imageViewMediaArray.count-1 {
            UIView.animate(withDuration: 0.583, animations: {
                self.imageViewMediaArray[index].frame.origin.x = CGFloat((width+space)*index)
                self.imageViewMediaArray[index].frame.size.width = CGFloat(width)
                self.imageViewMediaArray[index].frame.size.height = CGFloat(width)
                self.scrollViewMedia.frame.size.height = CGFloat(width)
            })
        }
        UIView.animate(withDuration: 0.583) { 
            self.scrollViewMedia.frame.origin.x = CGFloat(inset)
        }
        self.scrollViewMedia.contentSize = CGSize(width: CGFloat(fileIdArray.count * (width+space) - space), height: CGFloat(width))
    }
}
