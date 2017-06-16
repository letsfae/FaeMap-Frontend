////
////  MBCommentsViewController.swift
////  FaeMapBoard
////
////  Created by vicky on 4/11/17.
////  Copyright © 2017 Yue. All rights reserved.
////
//
//import UIKit
//import GoogleMaps
//import SwiftyJSON
//
//class MBCommentsViewController: MBComtsStoriesViewController, UITableViewDataSource, UITableViewDelegate, PinDetailCollectionsDelegate {
//    
//    override func viewDidLoad() {
//        strNavBarTitle = "Comments"
//        getMBSocialInfo(socialType: "comment")
//        super.viewDidLoad()
//    }
//    
//    override func loadTable() {
//        super.loadTable()
//        tblCommentStory.register(MBCommentsCell.self, forCellReuseIdentifier: "mbCommentsCell")
//        tblCommentStory.delegate = self
//        tblCommentStory.dataSource = self
//        
//        tblCommentStory.estimatedRowHeight = 200
//    }
//    
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return 1
//    }
//    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
////        return mbComments.count
//        return mbSocial.count
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "mbCommentsCell", for: indexPath) as! MBCommentsCell
//        
////        let comment = self.mbComments[indexPath.row]
//        let comment = self.mbSocial[indexPath.row]
//        cell.lblTime.text = comment.date
//        cell.lblContent.attributedText = comment.attributedText
//        if comment.anonymous || comment.displayName == "" {
//            cell.lblUsrName.text = "Someone"
//            cell.imgAvatar.image = #imageLiteral(resourceName: "default_Avatar")
//        } else {
//            cell.lblUsrName.text = comment.displayName
//            cell.setValueForCell(userId: comment.userId)
//        }
//        
//        cell.setAddressForCell(position: comment.position, id: comment.pinId, type: comment.type)
//        cell.lblLoc.text = comment.address
//        cell.imgHotPin.isHidden = comment.status != "hot"
//        cell.lblFavCount.text = String(comment.likeCount)
//        cell.btnFav.setImage(comment.isLiked ? #imageLiteral(resourceName: "pinDetailLikeHeartFull") : #imageLiteral(resourceName: "pinDetailLikeHeartHollow"), for: .normal)
//        cell.lblReplyCount.text = String(comment.commentCount)
//        
//        cell.btnFav.addTarget(self, action: #selector(self.actionLikeThisPin(_:)), for: [.touchUpInside, .touchUpOutside])
////        cell.btnFav.addTarget(self, action: #selector(self.actionHoldingLikeButton(_:)), for: .touchDown)
//        cell.btnReply.addTarget(self, action: #selector(self.actionReplyToThisPin(_:)), for: .touchUpInside)
//        cell.btnFav.tag = 0
//        
////        cell.btnReply.accessibilityHint = String(indexPath.row)
//        
//        cell.btnFav.accessibilityHint = String(comment.pinId)
//        cell.btnFav.indexPath = indexPath
//        cell.btnReply.indexPath = indexPath
//        
//        return cell
//    }
//    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: false)
//        
//        let vcPinDetail = PinDetailViewController()
////        let comment = self.mbComments[indexPath.row]
//        let comment = self.mbSocial[indexPath.row]
//        vcPinDetail.modalPresentationStyle = .overCurrentContext
//        vcPinDetail.colDelegate = self
//        vcPinDetail.enterMode = .collections
//        vcPinDetail.strPinId = String(comment.pinId)
//        vcPinDetail.strTextViewText = comment.contentJson
//        PinDetailViewController.selectedMarkerPosition = comment.position
//        PinDetailViewController.pinTypeEnum = .comment
//        PinDetailViewController.pinUserId = comment.userId
//        self.cellCurtIndex = indexPath
//
//        self.navigationController?.pushViewController(vcPinDetail, animated: true)
//        
//    }
//    
//    // PinDetailCollectionsDelegate
//    func backToCollections(likeCount: String, commentCount: String, pinLikeStatus: Bool) {
//        if likeCount == "" || commentCount == "" || self.cellCurtIndex == nil {
//            return
//        }
//        
//        let cellCurtSelect = tblCommentStory.cellForRow(at: self.cellCurtIndex) as! MBCommentsCell
//        cellCurtSelect.lblReplyCount.text = commentCount
//        cellCurtSelect.lblFavCount.text = likeCount
//        cellCurtSelect.btnFav.setImage(pinLikeStatus ? #imageLiteral(resourceName: "pinDetailLikeHeartFull") : #imageLiteral(resourceName: "pinDetailLikeHeartHollow"), for: .normal)
//        
//        if Int(likeCount)! >= 15 || Int(commentCount)! >= 10 {
//            cellCurtSelect.imgHotPin.isHidden = false
////            self.mbComments[cellCurtIndex.row].status = "hot"
//            self.mbSocial[cellCurtIndex.row].status = "hot"
//        } else {
//            cellCurtSelect.imgHotPin.isHidden = true
//        }
////        self.mbComments[cellCurtIndex.row].likeCount = Int(likeCount)!
////        self.mbComments[cellCurtIndex.row].commentCount = Int(commentCount)!
////        self.mbComments[cellCurtIndex.row].isLiked = pinLikeStatus
//        self.mbSocial[cellCurtIndex.row].likeCount = Int(likeCount)!
//        self.mbSocial[cellCurtIndex.row].commentCount = Int(commentCount)!
//        self.mbSocial[cellCurtIndex.row].isLiked = pinLikeStatus
//    }
//
//    func actionReplyToThisPin(_ sender: FavReplyButton) {
////        let row = Int(sender.accessibilityHint!)!
//        
//        let indexPath: IndexPath = sender.indexPath
//        
//        let vcPinDetail = PinDetailViewController()
////        let comment = self.mbComments[indexPath.row]
//        let comment = self.mbSocial[indexPath.row]
//        vcPinDetail.modalPresentationStyle = .overCurrentContext
//        vcPinDetail.colDelegate = self
//        vcPinDetail.enterMode = .collections
//        vcPinDetail.strPinId = String(comment.pinId)
//        vcPinDetail.strTextViewText = comment.contentJson
//        PinDetailViewController.selectedMarkerPosition = comment.position
//        PinDetailViewController.pinTypeEnum = .comment
//        PinDetailViewController.pinUserId = comment.userId
//        self.cellCurtIndex = indexPath//IndexPath(row: row, section: 0)
//
//        self.navigationController?.pushViewController(vcPinDetail, animated: true)
//        vcPinDetail.boolFromMapBoard = true
//    }
//}
