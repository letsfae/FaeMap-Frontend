//
//  MBComtsStoriesViewController.swift
//  faeBeta
//
//  Created by vicky on 2017/6/15.
//  Copyright © 2017年 fae. All rights reserved.
//

import UIKit
import SwiftyJSON

class MBComtsStoriesViewController: UIViewController {
    var strNavBarTitle: String!
    var tblCommentStory: UITableView!
    var strPinId: String!
    var cellCurtIndex: IndexPath!
    var mbComments = [MBSocialStruct]()
    var mbStories = [MBSocialStruct]()
    
    var currentLatitude: CLLocationDegrees = 34.0205378 // location manage
    var currentLongitude: CLLocationDegrees = -118.2854081 // location manage
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadNavBar()
        loadTable()
    }

    func loadNavBar() {
        let uiviewNavBar = FaeNavBar(frame: CGRect.zero)
        self.view.addSubview(uiviewNavBar)
        uiviewNavBar.loadBtnConstraints()
        uiviewNavBar.leftBtn.addTarget(self, action: #selector(self.backToMapBoard(_:)), for: .touchUpInside)
        uiviewNavBar.rightBtn.isHidden = true
        uiviewNavBar.lblTitle.text = strNavBarTitle
    }
    
    func loadTable() {
        tblCommentStory = UITableView(frame: CGRect(x: 0, y: 65, width: screenWidth, height: screenHeight - 65))
        tblCommentStory.backgroundColor = .white
        tblCommentStory.separatorStyle = .none
        tblCommentStory.rowHeight = UITableViewAutomaticDimension
        self.view.addSubview(tblCommentStory)
    }
    
    func backToMapBoard(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

    func actionLikeThisPin(_ sender: FavReplyButton) {
        let type: String = sender.tag == 0 ? "comment" : "media"
        print(type)
        if sender.currentImage == #imageLiteral(resourceName: "pinDetailLikeHeartFull") {
            sender.setImage(#imageLiteral(resourceName: "pinDetailLikeHeartHollow"), for: .normal)
            self.strPinId = sender.accessibilityHint

            unlikeThisPin(socialType: type)
        } else {
            sender.setImage(#imageLiteral(resourceName: "pinDetailLikeHeartFull"), for: .normal)
            self.strPinId = sender.accessibilityHint
            
            likeThisPin(socialType: type)
        }
        self.cellCurtIndex = sender.indexPath
    }
    
    //    func actionHoldingLikeButton(_ sender: UIButton) {
    //        sender.setImage(#imageLiteral(resourceName: "pinDetailLikeHeartFull"), for: UIControlState())
    //        animatingHeartTimer = Timer.scheduledTimer(timeInterval: 0.15, target: self, selector: #selector(self.animateHeart), userInfo: nil, repeats: true)
    //    }
    
    func animateHeart() {
    }
    
    func likeThisPin(socialType: String) {
        if strPinId == "-1" {
            return
        }
        let likeThisPin = FaePinAction()
        likeThisPin.whereKey("", value: "")
        if self.strPinId != "-999" {
            likeThisPin.likeThisPin("\(socialType)", pinID: self.strPinId) {(status: Int, message: Any?) in
                if status == 201 {
                    print("[likeThisPin] Successfully like this pin!")
                    self.updateLikeCount(socialType: socialType)
                    
                    if socialType == "comment" {
                        self.mbComments[self.cellCurtIndex.row].isLiked = true
                    } else {
                        self.mbStories[self.cellCurtIndex.row].isLiked = true
                    }
                }
                else {
                    print("Fail to like this pin!")
                }
            }
        }
    }
    
    func unlikeThisPin(socialType: String) {
        if self.strPinId == "-1" {
            return
        }
        let unlikeThisPin = FaePinAction()
        unlikeThisPin.whereKey("", value: "")
        unlikeThisPin.unlikeThisPin("\(socialType)" , pinID: self.strPinId) {(status: Int, message: Any?) in
            if status/100 == 2 {
                print("Successfully unlike this pin!")
                self.updateLikeCount(socialType: socialType)
                
                if socialType == "comment" {
                    self.mbComments[self.cellCurtIndex.row].isLiked = false
                } else {
                    self.mbStories[self.cellCurtIndex.row].isLiked = false
                }
            }
            else {
                print("Fail to unlike this pin!")
            }
        }
    }
    
    func updateLikeCount(socialType: String) {
        if strPinId == "-1" {
            return
        }
        print("updateLikeCount \(socialType)")
        let getPinAttr = FaePinAction()
        getPinAttr.getPinAttribute("\(socialType)", pinID: self.strPinId) {(status: Int, message: Any?) in
            if status / 100 != 2 {
                return
            }
            let mapBoardJSON = JSON(message!)
            let likesCount = mapBoardJSON["likes"].intValue
            let commentsCount = mapBoardJSON["comments"].intValue
            
            if socialType == "comment" {
                let cellCurtSelect = self.tblCommentStory.cellForRow(at: self.cellCurtIndex) as! MBCommentsCell
                cellCurtSelect.lblFavCount.text = "\(likesCount)"
                
                if likesCount >= 15 || commentsCount >= 10 {
                    cellCurtSelect.imgHotPin.isHidden = false
                    self.mbComments[self.cellCurtIndex.row].status = "hot"
                }
                else {
                    cellCurtSelect.imgHotPin.isHidden = true
                }
            } else if socialType == "media" {
                let cellCurtSelect = self.tblCommentStory.cellForRow(at: self.cellCurtIndex) as! MBStoriesCell
                cellCurtSelect.lblFavCount.text = "\(likesCount)"
                
                if likesCount >= 15 || commentsCount >= 10 {
                    cellCurtSelect.imgHotPin.isHidden = false
                    self.mbComments[self.cellCurtIndex.row].status = "hot"
                }
                else {
                    cellCurtSelect.imgHotPin.isHidden = true
                }
            }
        }
    }
    
    func getMBSocialInfo(socialType: String) {
        let mbSocialList = FaeMap()
        mbSocialList.whereKey("geo_latitude", value: "\(currentLatitude)")
        mbSocialList.whereKey("geo_longitude", value: "\(currentLongitude)")
        mbSocialList.whereKey("radius", value: "9999999")
        mbSocialList.whereKey("type", value: "\(socialType)")
        mbSocialList.whereKey("in_duration", value: "false")
        mbSocialList.whereKey("max_count", value: "100")
        mbSocialList.getMapInformation { (status: Int, message: Any?) in
            
            if status / 100 != 2 || message == nil {
                print("[loadMBSocialInfo] status/100 != 2")
                
                return
            }
            let socialInfoJSON = JSON(message!)
            guard let socialInfoJsonArray = socialInfoJSON.array else {
                print("[loadMBSocialInfo] fail to parse mapboard social info")
                
                return
            }
            if socialInfoJsonArray.count <= 0 {
                
                print("[loadMBSocialInfo] array is nil")
                return
            }
            
            self.processMBInfo(results: socialInfoJsonArray, socialType: socialType)
            
            self.mbComments.sort { $0.pinId > $1.pinId }
            self.mbStories.sort { $0.pinId > $1.pinId }
            
            self.tblCommentStory.reloadData()
        }
    }
    
    fileprivate func processMBInfo(results: [JSON], socialType: String) {
        for result in results {
            switch socialType {
            case "comment":
                let mbCommentData = MBSocialStruct(json: result)
                if self.mbComments.contains(mbCommentData) {
                    continue
                } else {
                    self.mbComments.append(mbCommentData)
                }
                break
            case "media":
                let mbStoryData = MBSocialStruct(json: result)
                if self.mbStories.contains(mbStoryData) {
                    continue
                } else {
                    self.mbStories.append(mbStoryData)
                }
                break
            default:
                break
            }
        }
    }
}

class FavReplyButton: UIButton {
    var indexPath: IndexPath!
}
