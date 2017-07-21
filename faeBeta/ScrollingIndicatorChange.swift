//
//  ScrollingIndicatorChange.swift
//  FaeContacts
//
//  Created by Yue on 6/16/17.
//  Copyright © 2017 Yue. All rights reserved.
//

import UIKit

extension AddUsernameController: UIScrollViewDelegate {
    
    /* Joshua 06/18/17
     Print debug info of the following functions to console,
     and see when the func will be called
     */
    
    // UIScrollViewDelegate
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        print("[scrollViewWillBeginDragging]")
        
        animateIndicatorSize(type: 1)
        
        indicatorState = .began
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        // scrollView's last subview is the scrolling indicator
        // this indicator exists when table is initialized
        guard let indicator = tblUsernames.subviews.last as? UIImageView else { return }
        
        // clear the color of indicator
        indicator.backgroundColor = .clear
        
        // for first loading lblPrefix to show the initial letter
        if lblPrefix.tag == 0 {
            lblPrefix.tag = 1
            // customized indictor can only added to view once
            btnIndicator.addSubview(lblPrefix)
        }
        
        // get first visible label, which is the first cell of visible cells on the screen
        let cell = (tblUsernames.visibleCells.first) as? FaeAddUsernameCell
        guard let prefix = cell?.lblUserName?.text else { return }
        
        // get the first index of cell label and get the initial of the cell
        let index = prefix.index(prefix.startIndex, offsetBy: 1)
        lblPrefix.text = prefix.substring(to: index)
        
        // serveral times of adjustment, the following is the best match
        // every time scrolling, the custom indicator's position is set
        // mapping algorithm: Y = (X-A)/(B-A) * (D-C) + C
        btnIndicator.center.y = ((indicator.center.y)/(tblUsernames.contentSize.height + 115)) * (screenHeight-115) + 115
        
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        print("[scrollViewDidEndDragging]", decelerate)
        indicatorState = .end
        
        // check if you can find when will "decelerate" be set to true or false
        if !decelerate {
            animateIndicatorSize(type: 2)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        // highly suggest to check the console to see this line of print when trigger srolling
        print("[scrollViewDidEndDecelerating]")
        if indicatorState == .end {
            UIView.animate(withDuration: 0.2, animations: {
                self.btnIndicator.frame.size.width = 3
                self.btnIndicator.frame.origin.x = 406
            }) { _ in
                self.btnIndicator.layer.cornerRadius = 3
            }
        }
    }
    // End of UIScrollViewDelegate
    
    func panGestureIndicator(_ pan: UIPanGestureRecognizer) {
        if pan.state == .began {
            animateIndicatorSize(type: 0)
            indicatorState = .scrolling
        } else if pan.state == .ended || pan.state == .failed || pan.state == .cancelled {
            indicatorState = .end
            animateIndicatorSize(type: 2)
            if btnIndicator.center.y >= screenHeight - 22 {
                tblUsernames.scrollToRow(at: IndexPath(row: filtered.count - 1, section: 0), at: .bottom, animated: true)
            }
        } else {
            guard let indicator = tblUsernames.subviews.last as? UIImageView else { return }
            
            var loc_y = pan.location(in: view).y
            
            if loc_y < 115 {
                loc_y = 115
            } else if loc_y > screenHeight - 15 {
                loc_y = screenHeight - 15
            }
            
            var point_y: CGFloat = (((loc_y)) / (screenHeight)) * (tblUsernames.contentSize.height - 115) - 380
            print(point_y)
            
            if point_y < 0 {
                point_y = 0
            } else if point_y > tblUsernames.contentSize.height {
                point_y = tblUsernames.contentSize.height
            }
            
            let point = CGPoint(x: 0, y: point_y)
            tblUsernames.setContentOffset(point, animated: false)
            if ((indicator.center.y)/(tblUsernames.contentSize.height + 115)) * (screenHeight-115) + 115 > screenHeight {
                btnIndicator.center.y = screenHeight
            }
            else {
                btnIndicator.center.y = ((indicator.center.y)/(tblUsernames.contentSize.height + 115)) * (screenHeight-115) + 115
            }
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
