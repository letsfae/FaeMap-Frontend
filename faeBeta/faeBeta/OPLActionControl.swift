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
                if OpenedPlaces.openedPlaces.count <= 3 {
                    self.tableOpenedPin.frame.size.height = CGFloat(OpenedPlaces.openedPlaces.count * 76)
                } else {
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
            self.tableOpenedPin.frame.size.height = screenHeight - 92
            self.subviewTable.frame.size.height = screenHeight - 65
        }), completion: { (done: Bool) in
            if done {
            }
        })
    }
    
    // Back to main map from opened pin list
    func actionBackToMap(_ sender: UIButton) {
        self.delegate?.directlyReturnToMap()
        UIView.animate(withDuration: 0.4, animations: ({
            self.subviewWhite.center.y -= screenHeight
            self.subviewTable.center.y -= screenHeight
        }), completion: { (done: Bool) in
            if done {
                self.dismiss(animated: false, completion: {
                    
                })
            }
        })
    }
    
    // Reset comment pin list window and remove all saved data
    func actionClearCommentPinList(_ sender: UIButton) {
        OpenedPlaces.openedPlaces.removeAll()
        self.tableOpenedPin.frame.size.height = 0
        self.tableOpenedPin.reloadData()
        actionBackToMap(buttonSubviewBackToMap)
    }
    
    func passCL2DLocationToOpenedPinList(_ coordinate: CLLocationCoordinate2D, index: Int) {
        self.dismiss(animated: false, completion: {
            self.delegate?.animateToCameraFromOpenedPinListView(coordinate, index: index)
        })
    }
    
    func deleteThisCellCalledFromDelegate(_ indexPath: IndexPath) {
        OpenedPlaces.openedPlaces.remove(at: indexPath.row)
        self.tableOpenedPin.deleteRows(at: [indexPath], with: .fade)
        if buttonCommentPinListDragToLargeSize.tag == 1 {
            self.tableOpenedPin.frame.size.height = screenHeight - 92
        } else if OpenedPlaces.openedPlaces.count <= 3 {
            self.tableOpenedPin.frame.size.height = CGFloat(OpenedPlaces.openedPlaces.count * 76)
        } else {
            self.tableOpenedPin.frame.size.height = CGFloat(228)
        }
        self.tableOpenedPin.reloadData()
        if OpenedPlaces.openedPlaces.count == 0 {
            self.delegate?.directlyReturnToMap()
            UIView.animate(withDuration: 0.4, animations: ({
                self.subviewWhite.center.y -= screenHeight
                self.subviewTable.center.y -= screenHeight
            }), completion: { (done: Bool) in
                if done {
                    self.dismiss(animated: false, completion: {
                        
                    })
                }
            })
        }
        
    }
}
