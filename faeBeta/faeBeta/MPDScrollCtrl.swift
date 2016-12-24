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
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if scrollView == scrollViewMedia {
            
            print("[scrollViewWillBeginDragging] set start offset \(beforeScrollingOffset)")
        }
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        if scrollView == scrollViewMedia {
            
            print("[scrollViewWillBeginDecelerating] set start offset \(beforeScrollingOffset)")
        }
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        if scrollView == scrollViewMedia {
            
            print("[scrollViewDidEndScrollingAnimation] set start offset \(beforeScrollingOffset)")
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView == scrollViewMedia {
            
            print("[scrollViewDidEndDragging] set start offset \(beforeScrollingOffset)")
        }
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if scrollView == scrollViewMedia {
            
            print("[scrollViewWillEndDragging] set start offset \(beforeScrollingOffset)")
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
            if tableCommentsForPin.contentOffset.y >= 292 {
                if self.controlBoard != nil {
                    self.controlBoard.isHidden = false
                }
            }
            if tableCommentsForPin.contentOffset.y < 292 {
                if self.controlBoard != nil {
                    self.controlBoard.isHidden = true
                }
            }
        }
        if scrollView == scrollViewMedia {
            print(scrollViewMedia.contentOffset.x)
            if direction == .left && (self.lastContentOffset < scrollView.contentOffset.x) {
                UIView.animate(withDuration: 0.1, animations: {
                    self.scrollViewMedia.frame.origin.x = 0
                    self.scrollViewMedia.frame.size.width = screenWidth
                })
            }
            else if direction == .right && (self.lastContentOffset > scrollView.contentOffset.x) {
                UIView.animate(withDuration: 0.1, animations: {
                    if self.mediaMode == .small {
                        self.scrollViewMedia.frame.origin.x = 15
                        self.scrollViewMedia.frame.size.width = screenWidth - 15
                    }
                    else {
                        self.scrollViewMedia.frame.origin.x = 27
                        self.scrollViewMedia.frame.size.width = screenWidth - 27
                    }
                })
            }
            self.lastContentOffset = scrollView.contentOffset.x
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == scrollViewMedia {
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
