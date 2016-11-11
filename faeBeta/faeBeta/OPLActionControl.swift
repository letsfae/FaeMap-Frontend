//
//  OpenedPinListActionControl.swift
//  faeBeta
//
//  Created by Yue on 11/3/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
import GoogleMaps
import SwiftyJSON

extension OpenedPinListViewController: OpenedPinTableViewCellDelegate {
    
    // Pan gesture for dragging comment pin list dragging button
    func panActionCommentPinListDrag(pan: UIPanGestureRecognizer) {
        var resumeTime:Double = 0.583
        if pan.state == .Began {
            if subviewTable.frame.size.height == 256 {
                commentPinSizeFrom = 256
                commentPinSizeTo = screenHeight - 65
            }
            else {
                commentPinSizeFrom = screenHeight - 65
                commentPinSizeTo = 256
            }
        } else if pan.state == .Ended || pan.state == .Failed || pan.state == .Cancelled {
            let location = pan.locationInView(view)
            let velocity = pan.velocityInView(view)
            resumeTime = abs(Double(CGFloat(screenHeight - 256) / velocity.y))
            print("DEBUG: Velocity TESTing")
            print("Velocity in CGPoint.y")
            print(velocity.y)
            print("Resume Time")
            print(resumeTime)
            if resumeTime >= 0.583 {
                resumeTime = 0.583
            }
            if abs(location.y - commentPinSizeFrom) >= 80 {
                UIView.animateWithDuration(resumeTime, animations: {
                    self.draggingButtonSubview.frame.origin.y = self.commentPinSizeTo - 28
                    self.subviewTable.frame.size.height = self.commentPinSizeTo
                })
            }
            else {
                UIView.animateWithDuration(resumeTime, animations: {
                    self.draggingButtonSubview.frame.origin.y = self.commentPinSizeFrom - 28
                    self.subviewTable.frame.size.height = self.commentPinSizeFrom
                })
            }
            if subviewTable.frame.size.height == 256 {
                buttonCommentPinListDragToLargeSize.tag = 0
            }
            if subviewTable.frame.size.height == screenHeight - 65 {
                buttonCommentPinListDragToLargeSize.tag = 1
            }
        } else {
            let location = pan.locationInView(view)
            if location.y >= 307 {
                self.draggingButtonSubview.center.y = location.y - 65
                self.subviewTable.frame.size.height = location.y + 14 - 65
            }
        }
    }
    
    // When clicking dragging button in opened pin list window
    func actionDraggingThisList(sender: UIButton) {
        if sender.tag == 1 {
            sender.tag = 0
            UIView.animateWithDuration(0.583, animations: ({
                self.draggingButtonSubview.frame.origin.y = 228
                self.subviewTable.frame.size.height = 256
                self.tableOpenedPin.scrollToTop()
            }), completion: { (done: Bool) in
                if done {
                    
                }
            })
            return
        }
        sender.tag = 1
        UIView.animateWithDuration(0.583, animations: ({
            self.draggingButtonSubview.frame.origin.y = screenHeight - 93
            self.subviewTable.frame.size.height = screenHeight - 65
        }), completion: { (done: Bool) in
            if done {
                
            }
        })
    }
    
    // Back to main map from opened pin list
    func actionBackToMap(sender: UIButton) {
        UIView.animateWithDuration(0.583, animations: ({
            self.subviewWhite.center.y -= self.subviewWhite.frame.size.height
            self.subviewTable.center.y -= screenHeight
        }), completion: { (done: Bool) in
            if done {
                self.dismissViewControllerAnimated(false, completion: {
                    /**
                     * the first arg "false" means, back directly to map, however,
                     * this action should via comment pin detail view,
                     * it looks a direct transition, but in fact, it is not
                    **/
                    self.delegate?.backFromOpenedPinList(false)
                })
            }
        })
    }
    
    // Back to comment pin detail window when in pin list window
    func actionBackToCommentDetail(sender: UIButton!) {
        if backJustOnce == true {
            backJustOnce = false
            self.delegate?.backFromOpenedPinList(true)
            UIView.animateWithDuration(0.583, animations: ({
                self.subviewTable.center.y -= screenHeight
            }), completion: { (done: Bool) in
                if done {
                    self.dismissViewControllerAnimated(false, completion: nil)
                }
            })
        }
    }
    
    // Reset comment pin list window and remove all saved data
    func actionClearCommentPinList(sender: UIButton) {
        self.openedPinListArray.removeAll()
        self.storageForOpenedPinList.setObject(openedPinListArray, forKey: "openedPinList")
        self.tableOpenedPin.frame.size.height = 0
        self.tableOpenedPin.reloadData()
        actionBackToMap(buttonSubviewBackToMap)
    }
    
    func passCL2DLocationToOpenedPinList(coordinate: CLLocationCoordinate2D, commentID: Int) {
        self.dismissViewControllerAnimated(false, completion: {
            self.delegate?.animateToCameraFromOpenedPinListView(coordinate, commentID: commentID)
        })
    }
    
    func deleteThisCellCalledFromDelegate(indexPath: NSIndexPath) {
        self.openedPinListArray.removeAtIndex(indexPath.row)
        self.storageForOpenedPinList.setObject(openedPinListArray, forKey: "openedPinList")
        self.tableOpenedPin.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        var tableHeight: CGFloat = CGFloat(openedPinListArray.count * 76)
        var subviewTableHeight = tableHeight + 28
        if openedPinListArray.count <= 3 {
            subviewTableHeight = CGFloat(256)
        }
        else {
            tableHeight = CGFloat(228)
        }
        subviewTableHeight = CGFloat(256)
        self.tableOpenedPin.frame.size.height = tableHeight
        self.subviewTable.frame.size.height = subviewTableHeight
    }
    
    
}
