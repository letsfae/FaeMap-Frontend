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

extension MomentPinDetailViewController: UIScrollViewDelegate {
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
//        if scrollView == scrollViewMedia {
//            print(collectionViewMedia.contentOffset.x)
//            if direction == .left && (self.lastContentOffset < scrollView.contentOffset.x) {
//                UIView.animate(withDuration: 0.1, animations: {
//                    self.collectionViewMedia.frame.origin.x = 0
//                    self.collectionViewMedia.frame.size.width = screenWidth
//                })
//            }
//            else if direction == .right && (self.lastContentOffset > scrollView.contentOffset.x) {
//                UIView.animate(withDuration: 0.1, animations: {
//                    if self.mediaMode == .small {
//                        self.collectionViewMedia.frame.origin.x = 15
//                        self.collectionViewMedia.frame.size.width = screenWidth - 15
//                    }
//                    else {
//                        self.collectionViewMedia.frame.origin.x = 27
//                        self.collectionViewMedia.frame.size.width = screenWidth - 27
//                    }
//                })
//            }
//            self.lastContentOffset = scrollView.contentOffset.x
//        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
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
    }
}
