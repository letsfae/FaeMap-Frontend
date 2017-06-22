//
//  PDHandleDelegateFuncs.swift
//  faeBeta
//
//  Created by Yue on 12/2/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
import CoreLocation
import SwiftyJSON

extension PinDetailViewController: OpenedPinListViewControllerDelegate, PinTalkTalkCellDelegate, EditPinViewControllerDelegate, SendStickerDelegate, PinFeelingCellDelegate {
    
    // PinFeelingCellDelegate
    func postFeelingFromFeelingCell(_ feeling: Int) {
        let tmpBtn = UIButton()
        tmpBtn.tag = feeling
        self.postFeeling(tmpBtn)
    }
    // PinFeelingCellDelegate
    func deleteFeelingFromFeelingCell() {
        deleteFeeling()
    }
    
    // SendStickerDelegate
    func sendStickerWithImageName(_ name : String) {
        print("[sendStickerWithImageName] name: \(name)")
        let stickerMessage = "<faeSticker>\(name)</faeSticker>"
        sendMessage(stickerMessage)
        btnCommentSend.isEnabled = false
        btnCommentSend.setImage(UIImage(named: "cannotSendMessage"), for: UIControlState())
        UIView.animate(withDuration: 0.3) {
            self.tblMain.frame.size.height = screenHeight - 155
            self.uiviewToFullDragBtnSub.frame.origin.y = screenHeight - 90
        }
        
    }
    func appendEmojiWithImageName(_ name: String) {
        self.textViewInput.insertText("[\(name)]")
        let strLength: Int = self.textViewInput.text.characters.count
        self.textViewInput.scrollRangeToVisible(NSMakeRange(strLength-1, 0))
    }
    func deleteEmoji() {
        self.textViewInput.text = self.textViewInput.text.stringByDeletingLastEmoji()
        self.textViewDidChange(textViewInput)
    }
    
    // EditPinViewControllerDelegate
    func reloadPinContent(_ coordinate: CLLocationCoordinate2D, zoom: Float) {
        if self.strPinId != "-1" {
            getSeveralInfo()
            tblMain.contentOffset.y = 0
        }
        PinDetailViewController.selectedMarkerPosition = coordinate
        zoomLevel = zoom
        self.delegate?.reloadMapPins(PinDetailViewController.selectedMarkerPosition, zoom: zoom, pinID: self.strPinId, marker: PinDetailViewController.pinMarker)
    }
    
    // OpenedPinListViewControllerDelegate
    func animateToCameraFromOpenedPinListView(_ coordinate: CLLocationCoordinate2D, index: Int) {
        btnPrevPin.isHidden = false
        btnNextPin.isHidden = false
        imgPinIcon.isHidden = false
        btnGrayBackToMap.isHidden = false
        
        self.backJustOnce = true
        self.uiviewMain.frame.origin.y = 0
        self.uiviewNavBar.frame = CGRect(x: 0, y: 0, width: screenWidth, height: 65)
        self.tblMain.center.y += screenHeight
        self.uiviewToFullDragBtnSub.center.y += screenHeight
        
        PinDetailViewController.selectedMarkerPosition = coordinate
        PinDetailViewController.placeType = OpenedPlaces.openedPlaces[index].category
        PinDetailViewController.strPlaceTitle = OpenedPlaces.openedPlaces[index].title
        PinDetailViewController.strPlaceStreet = OpenedPlaces.openedPlaces[index].street
        PinDetailViewController.strPlaceCity = OpenedPlaces.openedPlaces[index].city
        PinDetailViewController.strPlaceImageURL = OpenedPlaces.openedPlaces[index].imageURL
        initPlaceBasicInfo()
        manageYelpData()
        
        self.delegate?.animateToCamera(coordinate, pinID: "ddd")
        UIApplication.shared.statusBarStyle = .lightContent
    }
    func directlyReturnToMap() {
        actionBackToMap(UIButton())
    }
    
    // OpenedPinListViewControllerDelegate
    func backFromOpenedPinList(pinType: String, pinID: String) {
        backJustOnce = true
        uiviewNavBar.frame = CGRect(x: 0, y: 0, width: screenWidth, height: 65)
    }
    
    func directReplyFromPinCell(_ username: String, index: IndexPath) {
        self.strReplyTo = "<a>@\(username)</a> "
        self.lblTxtPlaceholder.isHidden = true
        appendReplyDisplayName(displayName: "@\(username)  ")
        textViewInput.becomeFirstResponder()
        directReplyFromUser = true
        boolKeyboardShowed = true
        tblMain.scrollToRow(at: index, at: .bottom, animated: true)
    }
    
    func showActionSheetFromPinCell(_ username: String, userid: Int, index: IndexPath) {
        textViewInput.resignFirstResponder()
        if !boolKeyboardShowed && !boolStickerShowed {
            showActionSheet(name: username, userid: userid, index: index)
        }
        boolKeyboardShowed = false
    }
    
    func showActionSheet(name: String, userid: Int, index: IndexPath) {
        let menu = UIAlertController(title: nil, message: "Action", preferredStyle: .actionSheet)
        menu.view.tintColor = UIColor.faeAppRedColor()
        let writeReply = UIAlertAction(title: "Write a Reply", style: .default) { (alert: UIAlertAction) in
            self.strReplyTo = "<a>@\(name)</a> "
            self.lblTxtPlaceholder.isHidden = true
            self.appendReplyDisplayName(displayName: "@\(name)  ")
            self.textViewInput.becomeFirstResponder()
            self.directReplyFromUser = true
            self.boolKeyboardShowed = true
            self.tblMain.scrollToRow(at: index, at: .bottom, animated: true)
        }
        let report = UIAlertAction(title: "Report", style: .default) { (alert: UIAlertAction) in
            self.actionReportThisPin()
        }
        let delete = UIAlertAction(title: "Delete", style: .default) { (alert: UIAlertAction) in
            let deletePinComment = FaePinAction()
            let pinCommentID = self.pinComments[index.row].commentId
            deletePinComment.uncommentThisPin(pinCommentID: "\(pinCommentID)", completion: { (status, message) in
                if status / 100 == 2 {
                    print("[Delete Pin Comment] Success")
                    // Vicky 06/21/17
                    self.getPinAttributeNum()
                    // Vicky 06/21/17 End
                } else {
                    print ("[Delete Pin Comment] status: \(status), message: \(message!)")
                }
            })
            self.pinComments.remove(at: index.row)
            self.tblMain.reloadData()
            
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (alert: UIAlertAction) in
            self.strReplyTo = ""
            self.lblTxtPlaceholder.text = "Write a Comment..."
        }
        menu.addAction(writeReply)
        if user_id == userid {
            menu.addAction(delete)
        } else {
            menu.addAction(report)
        }
        menu.addAction(cancel)
        self.present(menu, animated: true, completion: nil)
    }
    
    // Vicky 06/21/17
    // PinTalkTalkCellDelegate
    func upVoteComment(index: IndexPath) {
        let cell = self.tblMain.cellForRow(at: index) as! PinTalkTalkCell

        if self.pinComments[index.row].voteType == "up" || cell.pinCommentID == "" {
            self.cancelVote(index: index)
            return
        }
        
        cell.btnUpVote.setImage(#imageLiteral(resourceName: "pinCommentUpVoteRed"), for: .normal)
        cell.btnDownVote.setImage(#imageLiteral(resourceName: "pinCommentDownVoteGray"), for: .normal)
        let upVote = FaePinAction()
        upVote.whereKey("vote", value: "up")
        upVote.votePinComments(pinID: "\(cell.pinCommentID)") { (status: Int, message: Any?) in
            print("[upVoteThisComment] pinCommentID: \(cell.pinCommentID)")
            if status / 100 == 2 {
                self.pinComments[index.row].voteType = "up"
                self.updateVoteCount(index: index)
                print("[upVoteThisComment] Successfully upvote this pin comment")
            }
            else if status == 400 {
                print("[upVoteThisComment] Already upvote this pin comment")
            }
            else {
                if self.pinComments[index.row].voteType == "down" {
                    cell.btnUpVote.setImage(#imageLiteral(resourceName: "pinCommentUpVoteGray"), for: .normal)
                    cell.btnDownVote.setImage(#imageLiteral(resourceName: "pinCommentDownVoteRed"), for: .normal)
                }
                else if self.pinComments[index.row].voteType == "" {
                    cell.btnUpVote.setImage(#imageLiteral(resourceName: "pinCommentUpVoteGray"), for: .normal)
                    cell.btnDownVote.setImage(#imageLiteral(resourceName: "pinCommentDownVoteGray"), for: .normal)
                }
                print("[upVoteThisComment] Fail to upvote this pin comment")
            }
        }
    }
    
    // PinTalkTalkCellDelegate
    func downVoteComment(index: IndexPath) {
        let cell = self.tblMain.cellForRow(at: index) as! PinTalkTalkCell

        if self.pinComments[index.row].voteType == "down" || cell.pinCommentID == "" {
            self.cancelVote(index: index)
            return
        }
        cell.btnUpVote.setImage(#imageLiteral(resourceName: "pinCommentUpVoteGray"), for: .normal)
        cell.btnDownVote.setImage(#imageLiteral(resourceName: "pinCommentDownVoteRed"), for: .normal)
        let downVote = FaePinAction()
        downVote.whereKey("vote", value: "down")
        downVote.votePinComments(pinID: "\(cell.pinCommentID)") { (status: Int, message: Any?) in
            if status / 100 == 2 {
                self.pinComments[index.row].voteType = "down"
                self.updateVoteCount(index: index)
                print("[upVoteThisComment] Successfully downvote this pin comment")
            }
            else if status == 400 {
                print("[upVoteThisComment] Already downvote this pin comment")
            }
            else {
                if self.pinComments[index.row].voteType == "up" {
                    cell.btnUpVote.setImage(#imageLiteral(resourceName: "pinCommentUpVoteRed"), for: .normal)
                    cell.btnDownVote.setImage(#imageLiteral(resourceName: "pinCommentDownVoteGray"), for: .normal)
                }
                else if self.pinComments[index.row].voteType == "" {
                    cell.btnUpVote.setImage(#imageLiteral(resourceName: "pinCommentUpVoteGray"), for: .normal)
                    cell.btnDownVote.setImage(#imageLiteral(resourceName: "pinCommentDownVoteGray"), for: .normal)
                }
                print("[upVoteThisComment] Fail to downvote this pin comment")
            }
        }
    }
    
    func cancelVote(index: IndexPath) {
        let cell = self.tblMain.cellForRow(at: index) as! PinTalkTalkCell
        
        let cancelVote = FaePinAction()
        cancelVote.cancelVotePinComments(pinId: "\(cell.pinCommentID)") { (status: Int, message: Any?) in
            if status / 100 == 2 {
                self.pinComments[index.row].voteType = ""
                cell.btnUpVote.setImage(#imageLiteral(resourceName: "pinCommentUpVoteGray"), for: .normal)
                cell.btnDownVote.setImage(#imageLiteral(resourceName: "pinCommentDownVoteGray"), for: .normal)
                self.updateVoteCount(index: index)
                print("[upVoteThisComment] Successfully cancel vote this pin comment")
            }
            else if status == 400 {
                print("[upVoteThisComment] Already cancel vote this pin comment")
            }
        }
    }
    
    func updateVoteCount(index: IndexPath) {
        let cell = self.tblMain.cellForRow(at: index) as! PinTalkTalkCell
        
        let getPinCommentsDetail = FaePinAction()
        getPinCommentsDetail.getPinComments("\(PinDetailViewController.pinTypeEnum)", pinID: self.strPinId) {(status: Int, message: Any?) in
            let commentsOfCommentJSON = JSON(message!)
            if commentsOfCommentJSON.count > 0 {
                for i in 0...(commentsOfCommentJSON.count-1) {
                    var upVote = -999
                    var downVote = -999
                    if let pin_comment_id = commentsOfCommentJSON[i]["pin_comment_id"].int {
                        if cell.pinCommentID != "\(pin_comment_id)" {
                            continue
                        }
                    }
                    if let vote_up_count = commentsOfCommentJSON[i]["vote_up_count"].int {
                        print("[getPinComments] upVoteCount: \(vote_up_count)")
                        upVote = vote_up_count
                    }
                    if let vote_down_count = commentsOfCommentJSON[i]["vote_down_count"].int {
                        print("[getPinComments] downVoteCount: \(vote_down_count)")
                        downVote = vote_down_count
                    }
                    if let _ = commentsOfCommentJSON[i]["pin_comment_operations"]["vote"].string {
                        
                    }
                    if upVote != -999 && downVote != -999 {
                        cell.lblVoteCount.text = "\(upVote - downVote)"
                        self.pinComments[index.row].numVoteCount = upVote - downVote
                    }
                }
            }
        }
    }
    
    // Vicky 06/21/17 End
}

