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
        else if tableView == tableViewPeople{
            return dictPeopleOfCommentDetail.count
        }
        else{
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if tableView == self.tableCommentsForComment {
            let cell = tableView.dequeueReusableCellWithIdentifier("commentPinCommentsCell", forIndexPath: indexPath) as! CPCommentsCell
            cell.delegate = self
            let dictCell = JSON(dictCommentsOnCommentDetail[indexPath.row])
            if let userID = dictCell["user_id"].int {
                self.getAndSetUserAvatar(cell.imageViewAvatar, userID: userID)
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
            cell.separatorInset = UIEdgeInsetsZero
            cell.layoutMargins = UIEdgeInsetsZero
            return cell
        }
        else if tableView == self.tableViewPeople {
            let cell = tableView.dequeueReusableCellWithIdentifier("commentPinPeopleCell", forIndexPath: indexPath) as! OPLTableViewCell
            let userID = Array(dictPeopleOfCommentDetail.keys)[indexPath.row]
            let latestDate = dictPeopleOfCommentDetail[userID]
            let getUserName = FaeUser()
            
            getUserName.getOthersProfile("\(userID)") {(status, message) in
                let userProfile = JSON(message!)
                if let username = userProfile["user_name"].string {
                    cell.content.text = "\(username)"
                    cell.time.text = latestDate
                }
            }
            
//            getAndSetUserAvatar(cell.imageViewAvatar, userID: userID)
//            cell.imageViewAvatar.image = UIImage(named: "Eddie Gelfen")
            cell.deleteButton.hidden = true
            cell.jumpToDetail.hidden = true
            cell.separatorInset = UIEdgeInsetsZero
            cell.layoutMargins = UIEdgeInsetsZero
            return cell
        }
        else {
            let cell = UITableViewCell()
            cell.separatorInset = UIEdgeInsetsZero
            cell.layoutMargins = UIEdgeInsetsZero
            return cell
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if tableView == self.tableCommentsForComment {
            return 140
        }
        if tableView == self.tableViewPeople {
            return 76
        }
        else{
            return 0
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if tableView == self.tableCommentsForComment {
            let cell = tableView.cellForRowAtIndexPath(indexPath) as! CPCommentsCell
            if let usernameInCell = cell.labelUsername.text {
                self.actionShowActionSheet(usernameInCell)
            }
        }
        if tableView == self.tableViewPeople {
            
        }
    }
}
