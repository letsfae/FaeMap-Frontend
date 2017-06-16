////
////  MBStoriesViewController.swift
////  FaeMapBoard
////
////  Created by vicky on 4/12/17.
////  Copyright © 2017 Yue. All rights reserved.
////
//
//import UIKit
//
//class MBStoriesViewController: MBComtsStoriesViewController, UITableViewDelegate, UITableViewDataSource, PinDetailCollectionsDelegate {
//    var scrollViewMedia: UIScrollView!
//    
//    override func viewDidLoad() {
//        strNavBarTitle = "Stories"
//        getMBSocialInfo(socialType: "media")
//        super.viewDidLoad()
//    }
//    
//    override func loadTable() {
//        super.loadTable()
//        tblCommentStory.register(MBStoriesCell.self, forCellReuseIdentifier: "mbStoriesCell")
//        tblCommentStory.delegate = self
//        tblCommentStory.dataSource = self
//        
//        tblCommentStory.estimatedRowHeight = 400
//    }
//    
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return 1
//    }
//    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
////        return mbStories.count
//        return mbSocial.count
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "mbStoriesCell", for: indexPath) as! MBStoriesCell
////        let story = mbStories[indexPath.row]
//        let story = mbSocial[indexPath.row]
//        cell.lblTime.text = story.date
//        cell.lblContent.attributedText = story.attributedText
//        if story.anonymous || story.displayName == "" {
//            cell.lblUsrName.text = "Someone"
//            cell.imgAvatar.image = #imageLiteral(resourceName: "default_Avatar")
//        } else {
//            cell.lblUsrName.text = story.displayName
//            cell.setValueForCell(userId: story.userId)
//        }
//        
//        cell.setAddressForCell(position: story.position, id: story.pinId, type: story.type)
//        cell.lblLoc.text = story.address
//        cell.imgHotPin.isHidden = story.status != "hot"
//
//        cell.lblFavCount.text = String(story.likeCount)
//        cell.lblReplyCount.text = String(story.commentCount)
//        
//        cell.btnFav.setImage(story.isLiked ? #imageLiteral(resourceName: "pinDetailLikeHeartFull") : #imageLiteral(resourceName: "pinDetailLikeHeartHollow"), for: .normal)
//        cell.btnFav.addTarget(self, action: #selector(self.actionLikeThisPin(_:)), for: [.touchUpInside, .touchUpOutside])
//        //        cell.btnFav.addTarget(self, action: #selector(self.actionHoldingLikeButton(_:)), for: .touchDown)
//        cell.btnReply.addTarget(self, action: #selector(self.actionReplyToThisPin(_:)), for: .touchUpInside)
//        cell.btnFav.tag = 1
//        cell.btnFav.accessibilityHint = String(story.pinId)
//        cell.btnFav.indexPath = indexPath
//        cell.btnReply.indexPath = indexPath
//
//        
//        cell.imgMediaArr.removeAll()
//        for subview in cell.scrollViewMedia.subviews {
//            subview.removeFromSuperview()
//        }
//        
////        cell.scrollViewMedia.frame = CGRect(x: 0, y: 0, width: 105 * story.fileIdArray.count, height: 95)
////        cell.scrollViewMedia.frame.size = CGSize(width: 105 * story.fileIdArray.count, height: 95)
//        
//        for index in 0..<story.fileIdArray.count {
//            let imageView = FaeImageView(frame: CGRect(x: 105 * index, y: 0, width: 95, height: 95))
//            imageView.clipsToBounds = true
//            imageView.contentMode = .scaleAspectFill
//            imageView.layer.cornerRadius = 13.5
//            imageView.fileID = story.fileIdArray[index]
//            imageView.loadImage(id: story.fileIdArray[index])
//            cell.imgMediaArr.append(imageView)
//            cell.scrollViewMedia.addSubview(imageView)
//        }
//        // the tableView can't scroll up/down when finger is touched on the scrollView when height is 95
//        // Finally, I set the scrollView's height smaller than the height in storyboard => height: 90 instead of 95
//        cell.scrollViewMedia.contentSize = CGSize(width: story.fileIdArray.count * 105 - 10, height: 90)
//        
//        return cell
//    }
//    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: false)
//        
//        let vcPinDetail = PinDetailViewController()
////        let story = self.mbStories[indexPath.row]
//        let story = self.mbSocial[indexPath.row]
//        vcPinDetail.modalPresentationStyle = .overCurrentContext
//        vcPinDetail.colDelegate = self
//        vcPinDetail.enterMode = .collections
//        vcPinDetail.strPinId = String(story.pinId)
//        vcPinDetail.strTextViewText = story.contentJson
//        PinDetailViewController.selectedMarkerPosition = story.position
//        PinDetailViewController.pinTypeEnum = .media
//        PinDetailViewController.pinUserId = story.userId
//        self.cellCurtIndex = indexPath
//        
//        self.navigationController?.pushViewController(vcPinDetail, animated: true)
//    }
//    
//    // PinDetailCollectionsDelegate
//    func backToCollections(likeCount: String, commentCount: String, pinLikeStatus: Bool) {
//        if likeCount == "" || commentCount == "" || self.cellCurtIndex == nil {
//            return
//        }
//        
//        let cellCurtSelect = tblCommentStory.cellForRow(at: self.cellCurtIndex) as! MBStoriesCell
//        cellCurtSelect.lblReplyCount.text = commentCount
//        cellCurtSelect.lblFavCount.text = likeCount
//        cellCurtSelect.btnFav.setImage(pinLikeStatus ? #imageLiteral(resourceName: "pinDetailLikeHeartFull") : #imageLiteral(resourceName: "pinDetailLikeHeartHollow"), for: .normal)
//        
//        if Int(likeCount)! >= 15 || Int(commentCount)! >= 10 {
//            cellCurtSelect.imgHotPin.isHidden = false
//        } else {
//            cellCurtSelect.imgHotPin.isHidden = true
//        }
////        self.mbStories[cellCurtIndex.row].likeCount = Int(likeCount)!
////        self.mbStories[cellCurtIndex.row].commentCount = Int(commentCount)!
////        self.mbStories[cellCurtIndex.row].isLiked = pinLikeStatus
//        
//        self.mbSocial[cellCurtIndex.row].likeCount = Int(likeCount)!
//        self.mbSocial[cellCurtIndex.row].commentCount = Int(commentCount)!
//        self.mbSocial[cellCurtIndex.row].isLiked = pinLikeStatus
//    }
//    
//    func actionReplyToThisPin(_ sender: FavReplyButton) {
//        let indexPath: IndexPath = sender.indexPath
//        
//        let vcPinDetail = PinDetailViewController()
////        let story = self.mbStories[indexPath.row]
//        let story = self.mbSocial[indexPath.row]
//        vcPinDetail.modalPresentationStyle = .overCurrentContext
//        vcPinDetail.colDelegate = self
//        vcPinDetail.enterMode = .collections
//        vcPinDetail.strPinId = String(story.pinId)
//        vcPinDetail.strTextViewText = story.contentJson
//        PinDetailViewController.selectedMarkerPosition = story.position
//        PinDetailViewController.pinTypeEnum = .media
//        PinDetailViewController.pinUserId = story.userId
//        self.cellCurtIndex = indexPath
//        
//        self.navigationController?.pushViewController(vcPinDetail, animated: true)
//        vcPinDetail.boolFromMapBoard = true
//    }
//
//}
