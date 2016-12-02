//
//  CMPCVDelegateCtrl.swift
//  faeBeta
//
//  Created by Yue on 11/26/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
import IDMPhotoBrowser

extension CreateMomentPinViewController: UICollectionViewDelegate, UICollectionViewDataSource, CMPCellDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedMediaArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == collectionViewMedia {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "selectedMedia", for: indexPath) as! CMPCollectionViewCell
            cell.media.image = selectedMediaArray[indexPath.row]
            cell.delegate = self
            cell.buttonShowOptions.tag = indexPath.row
            cell.buttonShowFullImage.tag = indexPath.row
            cell.buttonShowFullImage.addTarget(self, action: #selector(self.showFullImage(_:)), for: .touchUpInside)
            cell.buttonDeleteImage.tag = indexPath.row
            cell.buttonDeleteImage.addTarget(self, action: #selector(self.deleteSelectedImage(_:)), for: .touchUpInside)
            if mediaEditMode == .delete {
                cell.uiviewOptions.isHidden = true
            }
            if !cell.uiviewOptions.isHidden {
                cell.uiviewOptions.isHidden = true
            }
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
    
    func deleteSelectedImage(_ sender: UIButton) {
        mediaEditMode = .delete
        selectedMediaArray.remove(at: sender.tag)
        collectionViewMedia.reloadData()
        if selectedMediaArray.count == 0 {
            buttonTakeMedia.isHidden = false
            buttonSelectMedia.isHidden = false
            collectionViewMedia.isHidden = true
        }
        else if selectedMediaArray.count == 1 {
            collectionViewMedia.frame.size.width = 200
            collectionViewMedia.frame.origin.x = 107
        }
    }
    
    func hideOtherCellOptions(tag: Int) {
        let selectedIndexPath = IndexPath(row: tag, section: 0)
        for indexPath in collectionViewMedia.indexPathsForVisibleItems {
            print("[hideOtherCellOptions] get diff index!")
            if indexPath == selectedIndexPath {
                print("[hideOtherCellOptions] get same index!")
                continue
            }
            let cell = collectionViewMedia.cellForItem(at: indexPath) as! CMPCollectionViewCell
            cell.uiviewOptions.isHidden = true
        }
    }
}
