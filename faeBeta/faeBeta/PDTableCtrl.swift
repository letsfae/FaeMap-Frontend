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
            let cell = tableView.dequeueReusableCell(withIdentifier: "pinCommentsCell", for: indexPath) as! PinTalkTalkCell
            let comment = self.pinComments[indexPath.row]
            cell.delegate = self
            cell.pinID = self.strPinId
            cell.pinType = "\(PinDetailViewController.pinTypeEnum)"
            cell.userID = comment.userId
            cell.cellIndex = indexPath
            if comment.anonymous {
                cell.lblUsername.text = self.dictAnonymous[comment.userId]
                if comment.userId == user_id {
                    let attri_0 = [NSForegroundColorAttributeName: UIColor.faeAppInputTextGrayColor(),
                                   NSFontAttributeName: UIFont(name: "AvenirNext-Medium", size: 16)!]
                    let attri_1 = [NSForegroundColorAttributeName: UIColor(r: 146, g: 146, b: 146, alpha: 100),
                                   NSFontAttributeName: UIFont(name: "AvenirNext-Medium", size: 15)!]
                    let strAnony = self.dictAnonymous[comment.userId] ?? "Anonymous"
                    let attr_0 = NSMutableAttributedString(string: strAnony + " ", attributes: attri_0)
                    let attr_1 = NSMutableAttributedString(string: "(me)", attributes: attri_1)
                    let attr = NSMutableAttributedString(string:"")
                    attr.append(attr_0)
                    attr.append(attr_1)
                    cell.lblUsername.attributedText = attr
                }
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
            for i in 0..<11 {
                cell.imgArray[i].label.text = "\(self.feelingArray[i])"
                if i == self.intChosenFeeling {
                    cell.imgArray[i].avatar.isHidden = false
                    cell.imgArray[i].avatar.frame = CGRect(x: 40.5, y: 37.5, width: 0, height: 0)
                    UIView.animate(withDuration: 0.2, animations: { 
                        cell.imgArray[i].avatar.frame = CGRect(x: 27, y: 25, width: 20, height: 20)
                    })
                    cell.imgArray[i].avatar.image = self.imgCurUserAvatar.image
                } else {
                    if !cell.imgArray[i].avatar.isHidden {
                        UIView.animate(withDuration: 0.2, animations: {
                            cell.imgArray[i].avatar.frame = CGRect(x: 40.5, y: 37.5, width: 0, height: 0)
                        }, completion: {(finished) in
                            cell.imgArray[i].avatar.isHidden = true
                        })
                    }
                }
            }
            return cell
        } else if tableMode == .people {
            let cell = tableView.dequeueReusableCell(withIdentifier: "pdUserInfoCell", for: indexPath) as! PDPeopleCell
            let userInfo = self.pinDetailUsers[indexPath.row]
            cell.lblDisplayName.text = userInfo.displayName
            cell.lblUserName.text = "@"+userInfo.userName
            cell.lblUserAge.text = userInfo.age
            cell.imgAvatar.image = userInfo.profileImage
            cell.userId = userInfo.userId
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

