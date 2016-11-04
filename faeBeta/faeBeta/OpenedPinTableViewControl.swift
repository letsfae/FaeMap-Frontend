//
//  OpenedPinTableViewControl.swift
//  faeBeta
//
//  Created by Yue on 11/3/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
import GoogleMaps
import SwiftyJSON
import CoreLocation

extension OpenedPinListViewController: UITableViewDelegate, UITableViewDataSource, OpenedPinTableViewCellDelegate {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == tableOpenedPin {
            return self.openedPinListArray.count
        }
        else{
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if tableView == self.tableOpenedPin {
            let cell = tableView.dequeueReusableCellWithIdentifier("openedPinCell", forIndexPath: indexPath) as! OpenedPinTableViewCell
            cell.delegate = self
            let commentID = openedPinListArray[indexPath.row]
            cell.commentID = commentID
            let getCommentById = FaeMap()
            getCommentById.getComment("\(commentID)") {(status: Int, message: AnyObject?) in
                let commentInfoJSON = JSON(message!)
                //                if let userid = commentInfoJSON["user_id"].int {
                //                    print(userid)
                // Next, to get user avatar
                //                }
                print(commentInfoJSON)
                if let time = commentInfoJSON["created_at"].string {
                    cell.time.text = time.formatFaeDate()
                }
                if let content = commentInfoJSON["content"].string {
                    cell.content.text = "\(content)"
                }
                if let latitudeInfo = commentInfoJSON["geolocation"]["latitude"].double {
                    if let longitudeInfo = commentInfoJSON["geolocation"]["longitude"].double {
                        cell.location = CLLocationCoordinate2DMake(latitudeInfo+0.001, longitudeInfo)
                    }
                }
                cell.deleteButton.enabled = true
                cell.jumpToDetail.enabled = true
            }
            cell.separatorInset = UIEdgeInsetsZero
            cell.layoutMargins = UIEdgeInsetsZero
            return cell
        }
        else {
            return UITableViewCell()
        }
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.alpha = 0
        UIView.animateWithDuration(0.583, animations: ({
            cell.alpha = 1
        }))
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if tableView == self.tableOpenedPin {
            return 76
        }
        else{
            return 0
        }
    }
}
