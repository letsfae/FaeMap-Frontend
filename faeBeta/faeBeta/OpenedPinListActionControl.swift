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
        let emptyArrayList = [Int]()
        self.storageForOpenedPinList.setObject(emptyArrayList, forKey: "openedPinList")
        self.tableOpenedPin.frame.size.height = 0
        self.tableOpenedPin.reloadData()
    }
    
    func passCL2DLocationToOpenedPinList(coordinate: CLLocationCoordinate2D, commentID: Int) {
        self.dismissViewControllerAnimated(false, completion: {
            self.delegate?.animateToCameraFromOpenedPinListView(coordinate, commentID: commentID)
        })
    }
    
    func deleteThisCellCalledFromDelegate(indexPath: NSIndexPath) {
        self.openedPinListArray.removeAtIndex(indexPath.row)
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
