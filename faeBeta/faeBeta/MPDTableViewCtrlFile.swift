//
//  MPDTableViewCtrlFile.swift
//  faeBeta
//
//  Created by Yue on 12/2/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
import SwiftyJSON

extension MomentPinDetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    // MARK: UITableView Delegate and Datasource functions
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == tableCommentsForPin {
            return dictCommentsOnPinDetail.count
        }
        else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.tableCommentsForPin {
            let cell = tableView.dequeueReusableCell(withIdentifier: "commentPinCommentsCell", for: indexPath) as! PinCommentsCell
            cell.delegate = self
            let dictCell = JSON(dictCommentsOnPinDetail[indexPath.row])
            if let pinID = dictCell["pin_comment_id"].int {
                print("[tableCommentsForPin] pinComment: \(pinID)")
                cell.pinID = pinID
            }
            if let voteType = dictCell["vote_type"].string {
                if voteType == "up" {
                    cell.voteType = .up
                    cell.buttonUpVote.setImage(#imageLiteral(resourceName: "commentPinUpVoteRed"), for: .normal)
                }
                else if voteType == "down" {
                    cell.voteType = .down
                    cell.buttonDownVote.setImage(#imageLiteral(resourceName: "commentPinDownVoteRed"), for: .normal)
                }
            }
            if let upVoteCount = dictCell["vote_up_count"].int {
                if let downVoteCount = dictCell["vote_down_count"].int {
                    cell.labelVoteCount.text = "\(upVoteCount-downVoteCount)"
                }
            }
            if let userID = dictCell["user_id"].int {
                let getUserName = FaeUser()
                getUserName.getOthersProfile("\(userID)") {(status, message) in
                    let userProfile = JSON(message!)
                    if let username = userProfile["user_name"].string {
                        cell.labelUsername.text = "\(username)"
                    }
                }
                let stringHeaderURL = "\(baseURL)/files/users/\(userID)/avatar"
                cell.imageViewAvatar.sd_setImage(with: URL(string: stringHeaderURL), placeholderImage: Key.sharedInstance.imageDefaultCover, options: .refreshCached)
            }
            if let date = dictCell["date"].string {
                cell.labelTimestamp.text = date
            }
            if let content = dictCell["content"].string {
                let attributedContent = content.formatPinCommentsContent()
                cell.textViewComment.attributedText = attributedContent
            }
            cell.separatorInset = UIEdgeInsets.zero
            cell.layoutMargins = UIEdgeInsets.zero
            return cell
        }
        else {
            let cell = UITableViewCell()
            cell.separatorInset = UIEdgeInsets.zero
            cell.layoutMargins = UIEdgeInsets.zero
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == self.tableCommentsForPin {
            return 140
        }
        else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == self.tableCommentsForPin {
            let cell = tableView.cellForRow(at: indexPath) as! PinCommentsCell
            if let usernameInCell = cell.labelUsername.text {
                self.actionShowActionSheet(usernameInCell)
            }
        }
    }
}

