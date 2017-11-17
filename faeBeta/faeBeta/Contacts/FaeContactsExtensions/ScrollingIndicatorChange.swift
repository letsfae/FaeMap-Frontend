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
        view.addSubview(btnIndicator)
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureIndicator(_:)))
        btnIndicator.addGestureRecognizer(panGesture)
    }
    
    /* Joshua 06/18/17
     Print debug info of the following functions to console,
     and see when the func will be called
     */
    
    // UIScrollViewDelegate
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        felixprint("[scrollViewWillBeginDragging]")
        
        //animateIndicatorSize(type: 1)
        
        //indicatorState = .began
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //felixprint(scrollView.contentOffset.y)
        schbarContacts.txtSchField.resignFirstResponder()
        let currentOffset = scrollView.contentOffset.y
        let tableHeight = scrollView.frame.size.height
        let scrollHeight = scrollView.contentSize.height
        let percentage = currentOffset / (scrollHeight - tableHeight)
        //felixprint(percentage)
        let btnRange = screenHeight - 120 - 30 - 6
        if percentage <= 0 {
            btnIndicator.frame.origin.y = 120
        } else if percentage < 1 {
            btnIndicator.frame.origin.y = 120 + btnRange * percentage
        } else {
            btnIndicator.frame.origin.y = 120 + btnRange
        }
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
        felixprint("[scrollViewDidEndDragging]", decelerate)
        indicatorState = .end
        
        // check if you can find when will "decelerate" be set to true or false
        /*if !decelerate {
            animateIndicatorSize(type: 2)
        }*/
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        // highly suggest to check the console to see this line of print when trigger srolling
        felixprint("[scrollViewDidEndDecelerating]")
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
    
    @objc func panGestureIndicator(_ pan: UIPanGestureRecognizer) {
        if pan.state == .began {
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
        }
    }
    
    func animateIndicatorSize(type: Int) {
        // cornerRadius is not animatable
        
        switch type {
            
        // width = 90, height = 30
        case 0:
            self.btnIndicator.layer.cornerRadius = 5
            
            UIView.animate(withDuration: 0.2, animations: {
                self.btnIndicator.frame.size.width = 90
                self.btnIndicator.frame.origin.x = 319
            }, completion: nil)
            break
            
        // width = 60, height = 30
        case 1:
            self.btnIndicator.layer.cornerRadius = 5
            
            // this animation is only for dragging table cells
            // not for tapping or dragging the scrolling button
            UIView.animate(withDuration: 0.2, animations: {
                self.btnIndicator.frame.size.width = 60
                self.btnIndicator.frame.origin.x = 349
            })
            break
            
        // width = 3, height = 30
        case 2:
            UIView.animate(withDuration: 0.2, animations: {
                self.btnIndicator.frame.size.width = 3
                self.btnIndicator.frame.origin.x = 406
            }) { _ in
                self.btnIndicator.layer.cornerRadius = 3
            }
            break
        default:
            break
        }
    }
}
