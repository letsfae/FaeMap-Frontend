//
//  PDTableViewCtrlFile.swift
//  faeBeta
//
//  Created by Yue on 12/2/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
import SwiftyJSON
import SDWebImage
import IDMPhotoBrowser

extension PinDetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    // MARK: UITableView Delegate and Datasource functions
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.pinComments.count == 0 {
            return 1
        } else {
            return pinComments.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.pinComments.count == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "pinEmptyCell", for: indexPath) as! PDEmptyCell
            cell.separatorInset = UIEdgeInsetsMake(0, 500, 0, 0)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "pinCommentsCell", for: indexPath) as! PinCommentsCell
            
            let comment = self.pinComments[indexPath.row]
            cell.delegate = self
            cell.pinID = self.pinIDPinDetailView
            cell.pinType = "\(self.pinTypeEnum)"
            cell.lblUsername.text = comment.displayName
            cell.pinCommentID = "\(comment.commentId)"
            cell.lblTime.text = comment.date
            cell.lblVoteCount.text = "\(comment.numVoteCount)"
            cell.voteType = comment.voteType
            cell.lblContent.attributedText = comment.attributedText
            cell.imgAvatar.image = comment.profileImage
//            getAvatarFromRealm(id: comment.userId, imgView: cell.imgAvatar)
            
            DispatchQueue.global(qos: .userInitiated).async {
                
                DispatchQueue.main.async {
                    
                }
            }
            return cell
        }
    }
    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        if self.pinCommentsCount == 0 {
//            return screenHeight - 436 * screenHeightFactor
//        } else {
//            return 140
//        }
//    }
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if tableView == self.tableCommentsForPin {
//            let cell = tableView.cellForRow(at: indexPath) as! PinCommentsCell
//            if let usernameInCell = cell.lblUsername.text {
//                self.actionShowActionSheet(usernameInCell)
//            }
//        }
//    }
    
    func showFullCellImage(_ image: UIImage) {
        let photos = IDMPhoto.photos(withImages: [image])
        let browser = IDMPhotoBrowser(photos: photos)
        self.present(browser!, animated: true, completion: nil)
    }
}

