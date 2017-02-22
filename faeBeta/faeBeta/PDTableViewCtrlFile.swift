//
//  PDTableViewCtrlFile.swift
//  faeBeta
//
//  Created by Yue on 12/2/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
import SwiftyJSON

extension PinDetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    // MARK: UITableView Delegate and Datasource functions
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.pinCommentsCount == 0 {
            return 1
        } else {
            return dictCommentsOnPinDetail.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.pinCommentsCount == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "pinEmptyCell", for: indexPath) as! PDEmptyCell
            cell.separatorInset = UIEdgeInsets.zero
            cell.layoutMargins = UIEdgeInsets.zero
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "pinCommentsCell", for: indexPath) as! PinCommentsCell
            cell.delegate = self
            cell.pinID = pinIDPinDetailView
            cell.pinType = "\(self.pinTypeEnum)"
            let dictCell = JSON(dictCommentsOnPinDetail[indexPath.row])
            if let pinCommentID = dictCell["pin_comment_id"].int {
//                print("[tableCommentsForPin] pinComment: \(pinCommentID)")
                cell.pinCommentID = "\(pinCommentID)"
            }
            if let voteType = dictCell["vote_type"].string {
                if voteType == "up" {
                    cell.voteType = .up
                    cell.buttonUpVote.setImage(#imageLiteral(resourceName: "pinCommentUpVoteRed"), for: .normal)
                }
                else if voteType == "down" {
                    cell.voteType = .down
                    cell.buttonDownVote.setImage(#imageLiteral(resourceName: "pinCommentDownVoteRed"), for: .normal)
                }
            }
            if let upVoteCount = dictCell["vote_up_count"].int {
                if let downVoteCount = dictCell["vote_down_count"].int {
                    cell.labelVoteCount.text = "\(upVoteCount-downVoteCount)"
                }
            }
            if let userID = dictCell["user_id"].int {
                let getUserName = FaeUser()
                getUserName.getNamecardOfSpecificUser("\(userID)") {(status, message) in
                    let userProfile = JSON(message!)
                    if let displayName = userProfile["nick_name"].string {
                        cell.labelUsername.text = "\(displayName)"
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
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.pinCommentsCount == 0 {
            return screenHeight - 436
        } else {
            return 140
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

