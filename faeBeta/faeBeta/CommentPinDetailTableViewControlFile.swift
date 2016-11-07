//
//  TableViewDelegateFile.swift
//  faeBeta
//
//  Created by Yue on 10/15/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
import SwiftyJSON

extension CommentPinViewController: UITableViewDelegate, UITableViewDataSource {
    
    // MARK: UITableView Delegate and Datasource functions
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == tableCommentsForComment {
            return dictCommentsOnCommentDetail.count
        }
        else{
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if tableView == self.tableCommentsForComment {
            let cell = tableView.dequeueReusableCellWithIdentifier("commentPinCommentsCell", forIndexPath: indexPath) as! CommentPinCommentsCell
            let dictCell = JSON(dictCommentsOnCommentDetail[indexPath.row])
            if let userID = dictCell["user_id"].int {
                let getUserName = FaeUser()
                getUserName.getOthersProfile("\(userID)") {(status, message) in
                    let userProfile = JSON(message!)
                    if let username = userProfile["user_name"].string {
                        cell.labelUsername.text = "\(username)"
                    }
                }
            }
            if let date = dictCell["date"].string {
                cell.labelTimestamp.text = date
            }
            if let content = dictCell["content"].string {
                cell.textViewComment.text = content
            }
            cell.imageViewAvatar.image = UIImage(named: "Eddie Gelfen")
            cell.separatorInset = UIEdgeInsetsZero
            cell.layoutMargins = UIEdgeInsetsZero
            return cell
        }
        else {
            return UITableViewCell()
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if tableView == self.tableCommentsForComment {
            return 140
        }
        else{
            return 0
        }
    }
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
}
