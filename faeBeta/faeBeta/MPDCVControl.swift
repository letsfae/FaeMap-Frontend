//
//  MPDCVControl.swift
//  faeBeta
//
//  Created by Yue on 12/3/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
import SDWebImage
import RealmSwift

extension MomentPinDetailViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.fileIdArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == collectionViewMedia {
            NSLog("[cellForItemAt] \(indexPath.row)")
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "mediaCell", for: indexPath) as! MPDCollectionViewCell
            
            Realm.Configuration.defaultConfiguration = Realm.Configuration(
                schemaVersion: 1,
                migrationBlock: { migration, oldSchemaVersion in
                    if (oldSchemaVersion < 1) {
                        // The enumerateObjects(ofType:_:) method iterates
                        // over every Person object stored in the Realm file
                        migration.enumerateObjects(ofType: Media.className()) { oldObject, newObject in
                            newObject!["fileId"] = oldObject!["fildId"] as! Int
                        }
                    }
            })
            
            let realm = try! Realm()
            let mediaRealm = realm.objects(Media.self).filter("fileId == \(self.fileIdArray[indexPath.row])")
            if mediaRealm.count >= 1 {
                if let media = mediaRealm.first {
                    let picture = UIImage.sd_image(with: media.picture as Data!)
                    cell.media.image = picture
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
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cell.alpha = 0
        UIView.animate(withDuration: 0.3) {
            cell.alpha = 1
        }
    }
}
