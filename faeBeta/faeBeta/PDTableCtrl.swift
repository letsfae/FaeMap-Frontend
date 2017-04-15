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
        if self.pinComments.count == 0 && tableMode == .talktalk {
            return 1
        } else if self.pinComments.count > 0 && tableMode == .talktalk {
            return pinComments.count
        } else if tableMode == .feelings {
            return 1
        } else if tableMode == .people {
            return pinDetailUsers.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.pinComments.count == 0 && tableMode == .talktalk {
            let cell = tableView.dequeueReusableCell(withIdentifier: "pinEmptyCell", for: indexPath) as! PDEmptyCell
            return cell
        } else if self.pinComments.count > 0 && tableMode == .talktalk {
            let cell = tableView.dequeueReusableCell(withIdentifier: "pinCommentsCell", for: indexPath) as! PinCommentsCell
            let comment = self.pinComments[indexPath.row]
            cell.delegate = self
            cell.pinID = self.pinIDPinDetailView
            cell.pinType = "\(PinDetailViewController.pinTypeEnum)"
            if comment.anonymous {
                cell.lblUsername.text = "Anonymous"
                cell.imgAvatar.image = #imageLiteral(resourceName: "defaultMen")
            } else {
                cell.lblUsername.text = comment.displayName
                cell.imgAvatar.image = comment.profileImage
            }
            cell.pinCommentID = "\(comment.commentId)"
            cell.lblTime.text = comment.date
            cell.lblVoteCount.text = "\(comment.numVoteCount)"
            cell.voteType = comment.voteType
            switch comment.voteType {
            case "up":
                cell.btnUpVote.setImage(#imageLiteral(resourceName: "pinCommentUpVoteRed"), for: .normal)
                cell.btnDownVote.setImage(#imageLiteral(resourceName: "pinCommentDownVoteGray"), for: .normal)
                break
            case "down":
                cell.btnUpVote.setImage(#imageLiteral(resourceName: "pinCommentUpVoteGray"), for: .normal)
                cell.btnDownVote.setImage(#imageLiteral(resourceName: "pinCommentDownVoteRed"), for: .normal)
                break
            default:
                cell.btnUpVote.setImage(#imageLiteral(resourceName: "pinCommentUpVoteGray"), for: .normal)
                cell.btnDownVote.setImage(#imageLiteral(resourceName: "pinCommentDownVoteGray"), for: .normal)
                break
            }
            cell.lblContent.attributedText = comment.attributedText
            
            return cell
        } else if tableMode == .feelings {
            let cell = tableView.dequeueReusableCell(withIdentifier: "pdFeelingCell", for: indexPath) as! PDFeelingCell
            cell.delegate = self
            cell.img_01.label.text = "\(self.feelingArray[0])"
            cell.img_02.label.text = "\(self.feelingArray[1])"
            cell.img_03.label.text = "\(self.feelingArray[2])"
            cell.img_04.label.text = "\(self.feelingArray[3])"
            cell.img_05.label.text = "\(self.feelingArray[4])"
            cell.img_06.label.text = "\(self.feelingArray[5])"
            cell.img_07.label.text = "\(self.feelingArray[6])"
            cell.img_08.label.text = "\(self.feelingArray[7])"
            cell.img_09.label.text = "\(self.feelingArray[8])"
            cell.img_10.label.text = "\(self.feelingArray[9])"
            cell.img_11.label.text = "\(self.feelingArray[10])"
            return cell
        } else if tableMode == .people {
            let cell = tableView.dequeueReusableCell(withIdentifier: "pdUserInfoCell", for: indexPath) as! PDUserInfoCell
            let userInfo = self.pinDetailUsers[indexPath.row]
            cell.lblDisplayName.text = userInfo.displayName
            cell.lblUserName.text = "@"+userInfo.userName
            cell.lblUserAge.text = userInfo.age
            cell.imgAvatar.image = userInfo.profileImage
            cell.userId = userInfo.userId
            cell.updateAvatarUI(isPinOwner: userInfo.userId == PinDetailViewController.pinUserId)
            cell.updatePrivacyUI(showGender: userInfo.showGender,
                                 gender: userInfo.gender,
                                 showAge: userInfo.showAge,
                                 age: userInfo.age)
            switch userInfo.gender {
            case "male":
                cell.imgUserGender.image = #imageLiteral(resourceName: "userGenderMale")
                break
            case "female":
                cell.imgUserGender.image = #imageLiteral(resourceName: "userGenderFemale")
                break
            default:
                cell.imgUserGender.image = nil
                break
            }
            return cell
        } else {
            return UITableViewCell()
        }
    }
}

