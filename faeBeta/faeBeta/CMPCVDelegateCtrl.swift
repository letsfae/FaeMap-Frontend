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
    
    override func viewDidLayoutSubviews() {
        print("[viewDidLayoutSubviews]")
        super.viewDidLayoutSubviews()
        var insets = self.collectionViewMedia.contentInset
        insets.left = (screenWidth - 200) / 2
        insets.right = (screenWidth - 200) / 2
        self.collectionViewMedia.contentInset = insets
        self.collectionViewMedia.decelerationRate = UIScrollViewDecelerationRateFast
    }
    
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
            if selectedMediaArray.count < 6 && indexPath.row <= selectedMediaArray.count - 1 {
                buttonAddMedia.alpha = 1
            }
        }
        else {
            return
        }
        if selectedMediaArray.count == 0 {
            buttonTakeMedia.alpha = 1
            buttonSelectMedia.alpha = 1
            buttonAddMedia.alpha = 0
            collectionViewMedia.isHidden = true
            buttonMediaSubmit.isEnabled = false
            buttonMediaSubmit.backgroundColor = UIColor(red: 149/255, green: 207/255, blue: 246/255, alpha: 0.65)
            buttonMediaSubmit.setTitleColor(UIColor(red: 1, green: 1, blue: 1, alpha: 0.65), for: UIControlState())
            buttonMediaSubmit.setTitleColor(UIColor.lightGray, for: .highlighted)
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
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        print("[scrollViewWillEndDragging] \(targetContentOffset.pointee.x) : \(Int((targetContentOffset.pointee.x + 107) / 249))")
        let index = Int((targetContentOffset.pointee.x + 107) / 249)
        if index == selectedMediaArray.count - 1 {
            buttonAddMedia.isEnabled = true
            UIView.animate(withDuration: 0.4) {
                if self.selectedMediaArray.count != 6 {
                    self.buttonAddMedia.alpha = 1
                }
            }
        }
        else {
            buttonAddMedia.isEnabled = false
            UIView.animate(withDuration: 0.4) {
                self.buttonAddMedia.alpha = 0
            }
        }
    }
    /*
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == collectionViewMedia {
            print("[scrollViewDidScroll] offset: \(scrollView.contentOffset.x)")
            if self.lastContentOffset < scrollView.contentOffset.x && scrollView.contentOffset.x > 0 {
                print("[scrollViewDidScroll] left")
//                if scrollView.contentOffset.x > 
//                UIView.animate(withDuration: 0.3, animations: {
//                    self.buttonAddMedia.alpha = 1
//                })
            }
            /*
            else if self.lastContentOffset > scrollView.contentOffset.x && self.lastContentOffset < (scrollView.contentSize.width - scrollView.frame.width) {
                print("[scrollViewDidScroll] right")
                if scrollView.contentOffset.x <= 0 {
                    UIView.animate(withDuration: 0.5, animations: {
                        if self.selectedMediaArray.count != 1 {
                            self.buttonAddMedia.alpha = 0
                        }
                    })
                }
                else {
                    UIView.animate(withDuration: 0.3, animations: {
                        self.collectionViewMedia.frame.size.width = screenWidth
                        self.collectionViewMedia.frame.origin.x = 0
                        if self.selectedMediaArray.count != 1 {
                            self.buttonAddMedia.alpha = 0
                        }
                    })
                }
            }
            */
            self.lastContentOffset = scrollView.contentOffset.x
        }
    }
     */
 
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

class CenterCellCollectionViewFlowLayout: UICollectionViewFlowLayout {
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        
        if let cv = self.collectionView {
            
            let cvBounds = cv.bounds
            let halfWidth = cvBounds.size.width * 0.5;
            let proposedContentOffsetCenterX = proposedContentOffset.x + halfWidth;
            
            if let attributesForVisibleCells = self.layoutAttributesForElements(in: cvBounds) {
                
                var candidateAttributes : UICollectionViewLayoutAttributes?
                for attributes in attributesForVisibleCells {
                    
                    // == Skip comparison with non-cell items (headers and footers) == //
                    if attributes.representedElementCategory != UICollectionElementCategory.cell {
                        continue
                    }
                    
                    if (attributes.center.x == 0) || (attributes.center.x > (cv.contentOffset.x + halfWidth) && velocity.x < 0) {
                        continue
                    }
                    
                    // == First time in the loop == //
                    guard let candAttrs = candidateAttributes else {
                        candidateAttributes = attributes
                        continue
                    }
                    
                    let a = attributes.center.x - proposedContentOffsetCenterX
                    let b = candAttrs.center.x - proposedContentOffsetCenterX
                    
                    if fabsf(Float(a)) < fabsf(Float(b)) {
                        candidateAttributes = attributes;
                    }
                }
                
                // Beautification step , I don't know why it works!
                if(proposedContentOffset.x == -(cv.contentInset.left)) {
                    return proposedContentOffset
                }
                
                return CGPoint(x: floor(candidateAttributes!.center.x - halfWidth), y: proposedContentOffset.y)
            }
        }
        
        // fallback
        return super.targetContentOffset(forProposedContentOffset: proposedContentOffset)
    }
    
}
