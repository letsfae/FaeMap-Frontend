//
//  ScrollingIndicatorChange.swift
//  FaeContacts
//
//  Created by Yue on 6/16/17.
//  Copyright © 2017 Yue. All rights reserved.
//

import UIKit

extension ContactsViewController: UIScrollViewDelegate, FaeScrollBarDelegate {
    
    func setupScrollBar() {
        if tblContacts.contentSize.height < screenHeight - 114 - device_offset_top {
            faeScrollBar?.removeFromSuperview()
            return
        }
        faeScrollBar = FaeScrollBar(frame: CGRect(x: screenWidth - 23, y: 117 + device_offset_top, width: 23, height: screenHeight - 114 - device_offset_top - 6 - device_offset_bot), scrollRange: tblContacts.contentSize.height - tblContacts.frame.height + device_offset_bot)
        guard let faeScrollBar = faeScrollBar else { return }
        view.addSubview(faeScrollBar)
        faeScrollBar.delegate = self
    }
    
    // MARK: FaeScrollBarDelegate
    func setScrollViewContentOffset(_ position: CGPoint, animated: Bool) {
        tblContacts.setContentOffset(position, animated: animated)
    }
    
    // MARK: UIScrollViewDelegate
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //felixprint(scrollView.contentOffset.y)
        hideDropdowmMenu()
        schbarContacts.txtSchField.resignFirstResponder()
        guard let _ = faeScrollBar else { return }
        let currentOffset = scrollView.contentOffset.y
        let tableHeight = scrollView.frame.size.height
        let scrollHeight = scrollView.contentSize.height
        let percentage = currentOffset / (scrollHeight + device_offset_bot - tableHeight)
        //felixprint(percentage)
        
        if percentage <= 0 {
            faeScrollBar?.scrollToTop(animated: 0.0)
        } else if percentage < 1 {
            faeScrollBar?.setIndicatorPosition(floatBtnRange * percentage, animated: 0.0)
        } else {
            faeScrollBar?.scrollToBottom(animated: 0.0)
        }
        let scrollVelocity = scrollView.panGestureRecognizer.velocity(in: scrollView)
        if fabs(scrollVelocity.y) > 300 && !scrollView.isAtTop && !scrollView.isAtBottom {
            faeScrollBar?.animatedIndicator(type: .normal)
        }
        let showIndex = scrollView.isAtTop ? 0 : 1
        let cell = (tblContacts.visibleCells[showIndex]) as? FaeContactsCell
        guard let prefix = cell?.lblUserName?.text else { return }
        faeScrollBar?.setPrefixLable((prefix as NSString).substring(to: 1))
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        //felixprint("[scrollViewDidEndDragging]", decelerate)
        faeScrollBar?.animatedIndicator(type: .thin)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        //felixprint("[scrollViewDidEndDecelerating]")
        faeScrollBar?.animatedIndicator(type: .thin)
    }
}
