//
//  OpenedPinListActionControl.swift
//  faeBeta
//
//  Created by Yue on 11/3/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
import GoogleMaps

extension OpenedPinListViewController: OpenedPinTableCellDelegate {
    
    // When clicking dragging button in opened pin list window
    func actionDraggingThisList(_ sender: UIButton) {
        if sender.tag == 1 {
            sender.tag = 0
            UIView.animate(withDuration: 0.5, animations: ({
                self.draggingButtonSubview.frame.origin.y = 227
                self.subviewTable.frame.size.height = 256
                if self.openedPinListArray.count <= 3 {
                    self.tableOpenedPin.frame.size.height = CGFloat(self.openedPinListArray.count * 76)
                }else{
                    self.tableOpenedPin.frame.size.height = CGFloat(227)
                }
            }), completion: { (done: Bool) in
                if done {
                }
            })
            return
        }
        sender.tag = 1
        UIView.animate(withDuration: 0.5, animations: ({
            self.draggingButtonSubview.frame.origin.y = screenHeight - 93
            self.subviewTable.frame.size.height = screenHeight - 65
            self.tableOpenedPin.frame.size.height = CGFloat(self.openedPinListArray.count * 76)
        }), completion: { (done: Bool) in
            if done {
            }
        })
    }
    
    // Back to main map from opened pin list
    func actionBackToMap(_ sender: UIButton) {
        UIView.animate(withDuration: 0.5, animations: ({
            self.subviewWhite.center.y -= screenHeight
            self.subviewTable.center.y -= screenHeight
        }), completion: { (done: Bool) in
            if done {
                self.dismiss(animated: false, completion: {
                    self.delegate?.directlyReturnToMap()
                })
            }
        })
    }
    
    // Reset comment pin list window and remove all saved data
    func actionClearCommentPinList(_ sender: UIButton) {
        self.openedPinListArray.removeAll()
        self.storageForOpenedPinList.set(openedPinListArray, forKey: "openedPinList")
        self.tableOpenedPin.frame.size.height = 0
        self.tableOpenedPin.reloadData()
        actionBackToMap(buttonSubviewBackToMap)
    }
    
    func passCL2DLocationToOpenedPinList(_ coordinate: CLLocationCoordinate2D, pinID: String) {
        self.dismiss(animated: false, completion: {
            self.delegate?.animateToCameraFromOpenedPinListView(coordinate, pinID: pinID)
        })
    }
    
    func deleteThisCellCalledFromDelegate(_ indexPath: IndexPath) {
        self.openedPinListArray.remove(at: indexPath.row)
        self.storageForOpenedPinList.set(openedPinListArray, forKey: "openedPinList")
        self.tableOpenedPin.deleteRows(at: [indexPath], with: .fade)
        if self.openedPinListArray.count <= 3 {
            self.tableOpenedPin.frame.size.height = CGFloat(self.openedPinListArray.count * 76)
        }else{
            self.tableOpenedPin.frame.size.height = CGFloat(228)
        }
        self.tableOpenedPin.reloadData()
        if openedPinListArray.count == 0 {
            UIView.animate(withDuration: 0.5, animations: ({
                self.subviewWhite.center.y -= screenHeight
                self.subviewTable.center.y -= screenHeight
            }), completion: { (done: Bool) in
                if done {
                    self.dismiss(animated: false, completion: {
                        self.delegate?.directlyReturnToMap()
                    })
                }
            })
        }
        
    }
}
