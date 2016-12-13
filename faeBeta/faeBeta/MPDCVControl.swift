//
//  MPDCVControl.swift
//  faeBeta
//
//  Created by Yue on 12/3/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
import SDWebImage
import IDMPhotoBrowser
import RealmSwift

extension MomentPinDetailViewController: UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.fileIdArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == collectionViewMedia {
            print("[cellForItemAt]")
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "mediaCell", for: indexPath) as! MPDCollectionViewCell
            if mediaMode == .small {
                UIView.animate(withDuration: 0.5, animations: {
                    cell.media.frame.size.width = 95
                    cell.media.frame.size.height = 95
                })
            }
            else {
                UIView.animate(withDuration: 0.7, animations: {
                    cell.media.frame.size.width = 160
                    cell.media.frame.size.height = 160
                })
            }
            let realm = try! Realm()
            let mediaRealm = realm.objects(Media.self).filter("fileId == \(self.fileIdArray[indexPath.row]) AND picture != nil")
            if mediaRealm.count >= 1 {
                if let media = mediaRealm.first {
                    let picture = UIImage.sd_image(with: media.picture as Data!)
                    cell.media.image = picture
                    self.displayMediaArray.append(picture!)
                    print("[cellForItemAt] \(indexPath.row) read from Realm done!")
                }
            }
            else if mediaRealm.count == 0 {
                let fileURL = "\(baseURL)/files/\(self.fileIdArray[indexPath.row])/data"
                cell.media.sd_setImage(with: URL(string: fileURL), placeholderImage: nil, options: [.retryFailed, .refreshCached], completed: { (image, error, SDImageCacheType, imageURL) in
                    if image != nil {
                        let mediaImage = Media()
                        mediaImage.fileId = self.fileIdArray[indexPath.row]
                        mediaImage.picture = UIImageJPEGRepresentation(image!, 1.0) as NSData?
                        try! realm.write {
                            realm.add(mediaImage)
                            print("[cellForItemAt] \(indexPath.row) save in Realm done!")
                        }
                    }
                })
            }
            return cell
        }
        else {
            let cell = UICollectionViewCell()
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == collectionViewMedia {
            let photos = IDMPhoto.photos(withImages: [displayMediaArray[indexPath.row]])
            let browser = IDMPhotoBrowser(photos: photos)
            self.present(browser!, animated: true, completion: nil)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == tableCommentsForPin {
            if inputToolbar != nil {
                self.inputToolbar.contentView.textView.resignFirstResponder()
            }
            if touchToReplyTimer != nil {
                touchToReplyTimer.invalidate()
            }
            if tableCommentsForPin.contentOffset.y >= 227 {
                if self.controlBoard != nil {
                    self.controlBoard.isHidden = false
                }
            }
            if tableCommentsForPin.contentOffset.y < 227 {
                if self.controlBoard != nil {
                    self.controlBoard.isHidden = true
                }
            }
        }
        if scrollView == collectionViewMedia {
            print(collectionViewMedia.contentOffset.x)
            if direction == .left && (self.lastContentOffset < scrollView.contentOffset.x) {
                UIView.animate(withDuration: 0.1, animations: {
                    self.collectionViewMedia.frame.origin.x = 0
                    self.collectionViewMedia.frame.size.width = screenWidth
                })
            }
            else if direction == .right && (self.lastContentOffset > scrollView.contentOffset.x) {
                UIView.animate(withDuration: 0.1, animations: {
                    if self.mediaMode == .small {
                        self.collectionViewMedia.frame.origin.x = 15
                        self.collectionViewMedia.frame.size.width = screenWidth - 15
                    }
                    else {
                        self.collectionViewMedia.frame.origin.x = 27
                        self.collectionViewMedia.frame.size.width = screenWidth - 27
                    }
                })
            }
            self.lastContentOffset = scrollView.contentOffset.x
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == collectionViewMedia {
            if direction == .right {
                print("[scrollViewDidEndDecelerating] direction: right")
                direction = .left
            }
            else if direction == .left {
                print("[scrollViewDidEndDecelerating] direction: left")
                direction = .right
            }
        }
    }
}
