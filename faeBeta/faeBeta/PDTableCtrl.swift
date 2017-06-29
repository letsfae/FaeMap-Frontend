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
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 42
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if PinDetailViewController.pinTypeEnum == .chat_room {
            return nil
        }
        
        let uiview = UIView()
        uiview.backgroundColor = .white
        uiview.addSubview(uiviewTblCtrlBtnSub)
        
        return uiview
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return PinDetailViewController.pinTypeEnum == .chat_room ? 0 : 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.pinComments.count == 0 && tableMode == .talktalk {
            return 1
        } else if self.pinComments.count > 0 && tableMode == .talktalk {
            return pinComments.count
        } else if tableMode == .feelings {
            return 1
        } else if tableMode == .people {
            return arrNonDupUserId.count
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
            cell.pinCommentID = "\(comment.commentId)"
            cell.lblTime.text = comment.date
            cell.lblVoteCount.text = "\(comment.numVoteCount)"
            cell.voteType = comment.voteType
            cell.loadUserInfo(id: comment.userId, isAnony: comment.anonymous, anonyText: dictAnonymous[comment.userId])
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
                    cell.imgArray[i].avatar.image = self.imgCurUserAvatar
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
            let userId = self.arrNonDupUserId[indexPath.row]
            cell.userId = userId
            cell.updatePrivacyUI(id: userId)
            return cell
        } else {
            return UITableViewCell()
        }
    }
}

