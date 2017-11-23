//
//  ScrollingIndicatorChange.swift
//  FaeContacts
//
//  Created by Yue on 6/16/17.
//  Copyright © 2017 Yue. All rights reserved.
//

import UIKit

extension ContactsViewController: UIScrollViewDelegate {
    
    func setupScrollBar() {
        if tblContacts.contentSize.height - 74 < screenHeight - 114 - device_offset_top {
            return
        }
        let uiviewScrollZone = UIView(frame: CGRect(x: screenWidth - 23, y: 120 + device_offset_top, width: 23, height: screenHeight - 120 - device_offset_top - 6))
        uiviewScrollZone.backgroundColor = .clear
        view.addSubview(uiviewScrollZone)
        let longpressGestureZone = UILongPressGestureRecognizer(target: self, action: #selector(handleScrollZoneLongPress(_:)))
        uiviewScrollZone.addGestureRecognizer(longpressGestureZone)
        
        view.addSubview(btnIndicator)
        btnIndicator.addSubview(lblPrefix)
        lblPrefix.isHidden = true
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(longPressGestureRecognizer(_:)))
        let longpressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressGestureRecognizer(_:)))
        longpressGesture.minimumPressDuration = 0.3
        btnIndicator.addGestureRecognizer(panGesture)
        btnIndicator.addGestureRecognizer(longpressGesture)
    }
    
    /* Joshua 06/18/17
     Print debug info of the following functions to console,
     and see when the func will be called
     */
    
    // UIScrollViewDelegate
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        //felixprint("[scrollViewWillBeginDragging]")
        
        //animateIndicatorSize(type: 1)
        
        //indicatorState = .began
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //felixprint(scrollView.contentOffset.y)
        schbarContacts.txtSchField.resignFirstResponder()
        if scrollView.contentSize.height - 74 < screenHeight - 114 - device_offset_top {
            return
        }
        let currentOffset = scrollView.contentOffset.y
        let tableHeight = scrollView.frame.size.height
        let scrollHeight = scrollView.contentSize.height
        let percentage = currentOffset / (scrollHeight - tableHeight)
        //felixprint(percentage)
        
        if percentage <= 0 {
            btnIndicator.frame.origin.y = 120 + device_offset_top
        } else if percentage < 1 {
            btnIndicator.frame.origin.y = 120 + floatBtnRange * percentage + device_offset_top
        } else {
            btnIndicator.frame.origin.y = 120 + floatBtnRange + device_offset_top
        }
        let scrollVelocity = scrollView.panGestureRecognizer.velocity(in: scrollView)
        if fabs(scrollVelocity.y) > 300 && !scrollView.isAtTop && !scrollView.isAtBottom {
            animateIndicatorSize(type: 1)
        }
        let showIndex = scrollView.isAtTop ? 0 : 1
        let cell = (tblContacts.visibleCells[showIndex]) as? FaeContactsCell
        guard let prefix = cell?.lblUserName?.text else { return }
        lblPrefix.text = (prefix as NSString).substring(to: 1)
        //print(scrollVelocity)
        //animateIndicatorSize(type: 2)
        // scrollView's last subview is the scrolling indicator
        // this indicator exists when table is initialized
        /*guard let indicator = tblContacts.subviews.last as? UIImageView else { return }
        
        // clear the color of indicator
        indicator.backgroundColor = .clear
        
        // for first loading lblPrefix to show the initial letter
        if lblPrefix.tag == 0 {
            lblPrefix.tag = 1
            // customized indictor can only added to view once
            btnIndicator.addSubview(lblPrefix)
        }
        
        // get first visible label, which is the first cell of visible cells on the screen
        let cell = (tblContacts.visibleCells.first) as? FaeContactsCell
        guard let prefix = cell?.lblUserName?.text else { return }
        
        // get the first index of cell label and get the initial of the cell
        let index = prefix.index(prefix.startIndex, offsetBy: 1)
        lblPrefix.text = String(prefix[index...])
        
        // serveral times of adjustment, the following is the best match
        // every time scrolling, the custom indicator's position is set
        
        // indicator is the original one come with table view,
        // and its position goes with table view's content, not its frame
        // so here, I used an absolute value 'percentage' to get the percentage the indicator should be
        // since btnIndicator is added on view rather than table view (if on table view, the UI is weird)
        // btnIndicator's position.y is calculate by the percentage of the table view frame.size.height
        var percentage = (indicator.frame.origin.y) / tblContacts.contentSize.height
        // sometimes the percentage will pass beyond 1.0 or below 0.0, force it to be within 0.0-1.0
        if percentage > 1.0 { percentage = 1.0 }
        else if percentage < 0.0 { percentage = 0.0 }
        // 118.0 is the start point of the btnIndicator's origin.y
        // (for here, composes of 65 of navbar, 49 of schbar, and 4 of offset for aesthetic)
        btnIndicator.frame.origin.y = tblContacts.frame.size.height * percentage + 118.0
        // if btnIndicator is beyond the end of table view's frame, force it to be within table view
        // 30 is the btnIndicator's height, and 4 of offset for aesthetic
        if btnIndicator.frame.origin.y > screenHeight - 30 - 4 {
            btnIndicator.frame.origin.y = screenHeight - 30 - 4
        }*/
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        //felixprint("[scrollViewDidEndDragging]", decelerate)
        indicatorState = .end
        animateIndicatorSize(type: 2)
        // check if you can find when will "decelerate" be set to true or false
        /*if !decelerate {
            animateIndicatorSize(type: 2)
        }*/
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        // highly suggest to check the console to see this line of print when trigger srolling
        //felixprint("[scrollViewDidEndDecelerating]")
        animateIndicatorSize(type: 2)
        /*if indicatorState == .end {
            UIView.animate(withDuration: 0.2, animations: {
                self.btnIndicator.frame.size.width = 3
                self.btnIndicator.frame.origin.x = 406
            }) { _ in
                self.btnIndicator.layer.cornerRadius = 3
            }
        }*/
    }
    // End of UIScrollViewDelegate
    
    @objc func longPressGestureRecognizer(_ recognizer: UIGestureRecognizer) {
        let currentPos = recognizer.location(in: nil).y
        switch recognizer.state {
        case .began:
            animateIndicatorSize(type: 0)
            floatLongpressStart = currentPos
            floatFingerToBtnTop = currentPos - btnIndicator.frame.origin.y
            //felixprint(floatFingerToBtnTop)
            break
        case .changed:
            //animateIndicatorSize(type: 0)
            //felixprint(currentPos)
            if currentPos < 120 + floatFingerToBtnTop || currentPos > screenHeight - 6 - 30 + floatFingerToBtnTop {
                break
            }
            btnIndicator.frame.origin.y = currentPos - floatFingerToBtnTop
            var percentage = (btnIndicator.frame.origin.y - 120) / floatBtnRange
            let scrollRange = tblContacts.contentSize.height - tblContacts.frame.height
            if percentage > 0.995 {
                percentage = 1.0
            }
            if percentage < 0.005 {
                percentage = 0.0
            }
            tblContacts.setContentOffset(CGPoint(x: 0, y: scrollRange * percentage), animated: false)
            //felixprint(percentage)
            break
        case .ended:
            animateIndicatorSize(type: 2)
            break
        default:
            animateIndicatorSize(type: 2)
            break
        }
    }
    
    @objc func panGestureIndicator(_ pan: UIPanGestureRecognizer) {
        let currentPos = pan.location(in: nil).y
        switch pan.state {
        case .began:
            animateIndicatorSize(type: 0)
            floatFingerToBtnTop = currentPos - btnIndicator.frame.origin.y
            break
        case .changed:
            if currentPos < 120 + floatFingerToBtnTop || currentPos > screenHeight - 6 - 30 + floatFingerToBtnTop {
                break
            }
            btnIndicator.frame.origin.y = currentPos - floatFingerToBtnTop
            var percentage = (btnIndicator.frame.origin.y - 120) / floatBtnRange
            let scrollRange = tblContacts.contentSize.height - tblContacts.frame.height
            if percentage > 0.995 {
                percentage = 1.0
            }
            if percentage < 0.005 {
                percentage = 0.0
            }
            tblContacts.setContentOffset(CGPoint(x: 0, y: scrollRange * percentage), animated: false)
            break
        case .ended:
            animateIndicatorSize(type: 2)
            break
        default:
            animateIndicatorSize(type: 2)
            break
        }
        /*if pan.state == .began {
            animateIndicatorSize(type: 0)
            indicatorState = .scrolling
        } else if pan.state == .ended || pan.state == .failed || pan.state == .cancelled {
            indicatorState = .end
            animateIndicatorSize(type: 2)
            if btnIndicator.center.y >= screenHeight - 22 {
                tblContacts.scrollToRow(at: IndexPath(row: filtered.count - 1, section: 0), at: .bottom, animated: true)
            }
        } else {
            // when pan gesture recognized changing state
            
            // loc_y is the pan's y on view, the view of the viewController
            // here, for aesthetic, we use loc_y to control btnIndicator.center.y
            var loc_y = pan.location(in: view).y
            // why is 133 here?
            // 133 is 118 + 15, in func scrollViewDidScroll, we know about 118
            // and 15 is half of 30, the height of btnIndicator,
            // so 15 is the distance from origin.y to center.y
            if loc_y < 133 {
                loc_y = 133
            }
            // some thing here, we got 4 of offset for aesthetic at the bottom
            // and 15 for the bottom of btnIndicator to its center
            else if loc_y > screenHeight - 19 {
                loc_y = screenHeight - 19
            }
            
            // use loc_y to control btnIndicator.center.y
            btnIndicator.center.y = loc_y
            
            // reverse what we've got in func scrollViewDidScroll
            let percent = (btnIndicator.frame.origin.y - 118.0) / tblContacts.frame.size.height
            let indicator_y = tblContacts.contentSize.height * percent
            // why is 0.85?
            // by research on the relationship between scrollView's indicator and its contentOffset
            // we found a value varies from 0.83 to 0.87, I chose a mid one, 0.85
            // the value is indicator.center.y / table.contentOffset.y
            let point_y = 0.85 * indicator_y
            let point = CGPoint(x: 0, y: point_y)
            
            tblContacts.setContentOffset(point, animated: false)
        }*/
    }
    
    @objc func handleScrollZoneLongPress(_ recognizer: UILongPressGestureRecognizer) {
        let currentPos = recognizer.location(in: nil).y
        switch recognizer.state {
        case .began:
            floatFingerToBtnTop = 15.0
            if currentPos >= 120 && currentPos <= 120 + 30 {
                tblContacts.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
                UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseOut], animations: {
                    self.btnIndicator.frame.origin.y = 120 + device_offset_top
                })
            } else if currentPos >= screenHeight - 6 - 30 && currentPos <= screenHeight - 6 {
                tblContacts.setContentOffset(CGPoint(x: 0, y: tblContacts.contentSize.height - tblContacts.frame.height), animated: false)
                UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseOut], animations: {
                    self.btnIndicator.frame.origin.y = screenHeight - 6 - 30
                })
            } else {
                let percentage = (currentPos - 15 - 120) / floatBtnRange
                let scrollRange = tblContacts.contentSize.height - tblContacts.frame.height
                tblContacts.setContentOffset(CGPoint(x: 0, y: scrollRange * percentage), animated: false)
                UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseOut], animations: {
                    self.btnIndicator.frame.origin.y = currentPos - 15
                })
            }
            animateIndicatorSize(type: 0)
            //felixprint(floatFingerToBtnTop)
            break
        case .changed:
            //animateIndicatorSize(type: 0)
            //felixprint(currentPos)
            if currentPos < 120 + floatFingerToBtnTop || currentPos > screenHeight - 6 - 30 + floatFingerToBtnTop {
                break
            }
            btnIndicator.frame.origin.y = currentPos - floatFingerToBtnTop
            var percentage = (btnIndicator.frame.origin.y - 120) / floatBtnRange
            let scrollRange = tblContacts.contentSize.height - tblContacts.frame.height
            if percentage > 0.995 {
                percentage = 1.0
            }
            if percentage < 0.005 {
                percentage = 0.0
            }
            tblContacts.setContentOffset(CGPoint(x: 0, y: scrollRange * percentage), animated: false)
            //felixprint(percentage)
            break
        case .ended:
            animateIndicatorSize(type: 2)
            break
        default:
            animateIndicatorSize(type: 2)
            break
        }
    }
    
    func animateIndicatorSize(type: Int) {
        // cornerRadius is not animatable
        let uiviewBar = btnIndicator.subviews[0]
        switch type {
            
        // width = 90, height = 30
        case 0:
            //self.btnIndicator.layer.cornerRadius = 5
            uiviewBar.layer.cornerRadius = 5
            UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseOut], animations: {
                uiviewBar.frame.size.width = 90
                uiviewBar.frame.origin.x = 3 + 15 - 90
                self.lblPrefix.frame.origin.x = 3 + 15 - 90 + 6
                self.lblPrefix.isHidden = false
                //self.btnIndicator.frame.size.width = 90
                //self.btnIndicator.frame.origin.x = 319
            }, completion: nil)
            break
            
        // width = 60, height = 30
        case 1:
            //self.btnIndicator.layer.cornerRadius = 5
            uiviewBar.layer.cornerRadius = 5
            // this animation is only for dragging table cells
            // not for tapping or dragging the scrolling button
            UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseOut], animations: {
                uiviewBar.frame.size.width = 50
                uiviewBar.frame.origin.x = 3 + 15 - 50
                self.lblPrefix.frame.origin.x = 3 + 15 - 50 + 6
                self.lblPrefix.isHidden = false
                //self.btnIndicator.frame.size.width = 60
                //self.btnIndicator.frame.origin.x = 349
            })
            break
            
        // width = 3, height = 30
        case 2:
            lblPrefix.isHidden = true
            UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseIn], animations: {
                //self.btnIndicator.frame.size.width = 3
                //self.btnIndicator.frame.origin.x = screenWidth - 8
                uiviewBar.frame.size.width = 3
                uiviewBar.frame.origin.x = 15
            }) { _ in
                //self.btnIndicator.layer.cornerRadius = 3
                uiviewBar.layer.cornerRadius = 3
            }
            break
        default:
            break
        }
    }
}

extension UIScrollView {
    var isAtTop: Bool {
        return contentOffset.y <= verticalOffsetForTop
    }
    
    var isAtBottom: Bool {
        return contentOffset.y >= verticalOffsetForBottom
    }
    
    var verticalOffsetForTop: CGFloat {
        let topInset = contentInset.top
        return -topInset
    }
    
    var verticalOffsetForBottom: CGFloat {
        let scrollViewHeight = bounds.height
        let scrollContentSizeHeight = contentSize.height
        let bottomInset = contentInset.bottom
        let scrollViewBottomOffset = scrollContentSizeHeight + bottomInset - scrollViewHeight
        return scrollViewBottomOffset
    }
}
