//
//  CMPCVDelegateCtrl.swift
//  faeBeta
//
//  Created by Yue on 11/26/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
import IDMPhotoBrowser

extension CreateMomentPinViewController: UICollectionViewDelegate, UICollectionViewDataSource, CMPCellDelegate,
                                         UIScrollViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedMediaArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == collectionViewMedia {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "selectedMedia", for: indexPath) as! CMPCollectionViewCell
            cell.media.image = selectedMediaArray[indexPath.row]
            cell.delegate = self
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
    
    func showFullImage(cell: CMPCollectionViewCell) {
        if let indexPath = collectionViewMedia.indexPath(for: cell) {
            let photos = IDMPhoto.photos(withImages: [selectedMediaArray[indexPath.row]])
            let browser = IDMPhotoBrowser(photos: photos)
            self.present(browser!, animated: true, completion: nil)
        }
    }
    
    func deleteCell(cell: CMPCollectionViewCell) {
        if let indexPath = collectionViewMedia.indexPath(for: cell) {
            selectedMediaArray.remove(at: indexPath.row)
            collectionViewMedia.deleteItems(at: [indexPath])
        }
        else {
            return
        }
        if selectedMediaArray.count == 0 {
            buttonTakeMedia.alpha = 1
            buttonSelectMedia.alpha = 1
            buttonAddMedia.alpha = 0
            collectionViewMedia.isHidden = true
        }
        else if selectedMediaArray.count == 1 {
            collectionViewMedia.frame.size.width = 200
            collectionViewMedia.frame.origin.x = 107
        }
    }
    
    func hideOtherCellOptions(cell: CMPCollectionViewCell) {
        let selectedIndexPath = collectionViewMedia.indexPath(for: cell)
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == collectionViewMedia {
            print(collectionViewMedia.contentOffset.x)
//            if direction == .right && (self.lastContentOffset > scrollView.contentOffset.x) {
//                UIView.animate(withDuration: 0.3, animations: {
//                    self.collectionViewMedia.frame.size.width = screenWidth
//                    if self.selectedMediaArray.count != 1 {
//                        self.buttonAddMedia.alpha = 0
//                    }
//                })
//            }
//            else if direction == .left && (self.lastContentOffset < scrollView.contentOffset.x) {
//                UIView.animate(withDuration: 0.2, animations: {
//                    self.collectionViewMedia.frame.size.width = 307
//                    self.buttonAddMedia.alpha = 1
//                })
//            }
//            self.lastContentOffset = scrollView.contentOffset.x
        }
    }
//
//    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//        if scrollView == collectionViewMedia {
//            if direction == .right {
//                print("[scrollViewDidEndDecelerating] direction: right")
//                direction = .left
//            }
//            else if direction == .left {
//                print("[scrollViewDidEndDecelerating] direction: left")
//                direction = .right
//            }
//        }
//    }
}
