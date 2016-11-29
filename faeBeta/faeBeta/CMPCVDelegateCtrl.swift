//
//  CMPCVDelegateCtrl.swift
//  faeBeta
//
//  Created by Yue on 11/26/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
import IDMPhotoBrowser

extension CreateMomentPinViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedMediaArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == collectionViewMedia {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "selectedMedia", for: indexPath) as! CMPCollectionViewCell
            cell.media.image = selectedMediaArray[indexPath.row]
            cell.buttonShowFullImage.tag = indexPath.row
            cell.buttonShowFullImage.addTarget(self, action: #selector(self.showFullImage(_:)), for: .touchUpInside)
            return cell
        }
        else {
            let cell = UICollectionViewCell()
            return cell
        }
    }
    
    func showFullImage(_ sender: UIButton) {
        let photos = IDMPhoto.photos(withImages: [selectedMediaArray[sender.tag]])
        let browser = IDMPhotoBrowser(photos: photos)
        self.present(browser!, animated: true, completion: nil)
    }
}
