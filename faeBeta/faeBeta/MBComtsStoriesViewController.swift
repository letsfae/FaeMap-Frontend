//
//  MBComtsStoriesViewController.swift
//  faeBeta
//
//  Created by vicky on 2017/6/15.
//  Copyright © 2017年 fae. All rights reserved.
//

import UIKit
import SwiftyJSON
// import PullToRefreshSwift

class MBComtsStoriesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, PinDetailCollectionsDelegate, MBComtsStoriesCellDelegate, UIScrollViewDelegate {
    
    var strNavBarTitle: String!
    var tblCommentStory: UITableView!
    var cellCurtIndex: IndexPath!
    var mbSocial = [MBSocialStruct]()
    var scrollViewMedia: UIScrollView!
    var strPinId: String!
    var type: String!
    
    var currentLatitude: CLLocationDegrees = 34.0205378 // location manage
    var currentLongitude: CLLocationDegrees = -118.2854081 // location manage
    
    enum EnterMode {
        case comment
        case media
    }
    
    var enterMode: EnterMode = .comment
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadNavBar()
        loadTable()
        
        getType()
        MBComtsStoriesCell.strPinType = type
        getMBSocialInfo(socialType: type, time: DispatchTime.now(), completion: nil)
        
        pullDownToRefresh()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        tblCommentStory.fixedPullToRefreshViewForDidScroll()
    }
    
    func pullDownToRefresh() {
        tblCommentStory.addPullRefresh() { [unowned self] in
            let timeNow = DispatchTime.now()
            self.getMBSocialInfo(socialType: self.type, time: timeNow, completion: { (timeDiff) in
                let delay = DispatchTime.now() + abs(Double(NSEC_PER_SEC) - timeDiff) / Double(NSEC_PER_SEC)
                print(abs(Double(NSEC_PER_SEC) - timeDiff) / Double(NSEC_PER_SEC))
                DispatchQueue.main.asyncAfter(deadline: delay) {
                    self.tblCommentStory.stopPullRefreshEver()
                }
            })
        }
        
        //        var pushOptions = PullToRefreshOption()
        //        pushOptions.indicatorColor = .blue
        //        self.tblCommentStory.addPushRefresh(options: pushOptions) { [weak self] in
        //            // some code
        //            sleep(1)
        //            self?.tblCommentStory.reloadData()
        //            self?.tblCommentStory.stopPushRefreshEver(true)
        //        }
    }
    
    func getType() {
        switch enterMode {
        case .comment:
            type = "comment"
            return
        case .media:
            type = "media"
            return
        }
    }
    
    func loadNavBar() {
        switch enterMode {
        case .comment:
            strNavBarTitle = "Comments"
            break
        case .media:
            strNavBarTitle = "Stories"
            break
        }
        
        let uiviewNavBar = FaeNavBar(frame: CGRect.zero)
        view.addSubview(uiviewNavBar)
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
        view.addSubview(tblCommentStory)
        
        tblCommentStory.register(MBComtsStoriesCell.self, forCellReuseIdentifier: "mbComtsStoriesCell")
        tblCommentStory.delegate = self
        tblCommentStory.dataSource = self
        
        switch enterMode {
        case .comment:
            tblCommentStory.estimatedRowHeight = 200
            break
        case .media:
            tblCommentStory.estimatedRowHeight = 400
            break
        }
    }
    
    func backToMapBoard(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return mbSocial.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "mbComtsStoriesCell", for: indexPath) as! MBComtsStoriesCell
        
        let social = mbSocial[indexPath.row]
        cell.indexForCurtCell = indexPath
        cell.setValueForCell(social: social)
        cell.delegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        let vcPinDetail = PinDetailViewController()
        let social = mbSocial[indexPath.row]
        vcPinDetail.modalPresentationStyle = .overCurrentContext
        vcPinDetail.colDelegate = self
        vcPinDetail.enterMode = .collections
        vcPinDetail.strPinId = String(social.pinId)
        vcPinDetail.strTextViewText = social.contentJson
        PinDetailViewController.selectedMarkerPosition = social.position
        PinDetailViewController.pinTypeEnum = enterMode == .comment ? .comment : .media
        PinDetailViewController.pinUserId = social.userId
        cellCurtIndex = indexPath
        
        navigationController?.pushViewController(vcPinDetail, animated: true)
        
    }
    
    func getMBSocialInfo(socialType: String, time: DispatchTime, completion: ((Double) -> ())?) {
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
            self.mbSocial.sort { $0.pinId > $1.pinId }
            //            print(self.mbSocial)
            self.tblCommentStory.reloadData()
            let timeDiff = DispatchTime.now().uptimeNanoseconds - time.uptimeNanoseconds
            completion?(Double(timeDiff))
//            let delay = DispatchTime.now() + 3
//            DispatchQueue.main.asyncAfter(deadline: delay) {
//                
//            }
        }
    }
    
    fileprivate func processMBInfo(results: [JSON], socialType: String) {
        for result in results {
            let mbSocialData = MBSocialStruct(json: result)
            if mbSocial.contains(mbSocialData) {
                if let idx = self.mbSocial.index(of: mbSocialData) {
                    if mbSocial[idx].likeCount != mbSocialData.likeCount {
                        mbSocial[idx].likeCount = mbSocialData.likeCount
                    }
                    if mbSocial[idx].commentCount != mbSocialData.commentCount {
                        mbSocial[idx].commentCount = mbSocialData.commentCount
                    }
                    if mbSocial[idx].feelingArray != mbSocialData.feelingArray {
                        mbSocial[idx].feelingArray = mbSocialData.feelingArray
                    }
                    if mbSocial[idx].attributedText != mbSocialData.attributedText {
                        mbSocial[idx].attributedText = mbSocialData.attributedText
                    }
                    if mbSocial[idx].fileIdArray != mbSocialData.fileIdArray {
                        mbSocial[idx].fileIdArray = mbSocialData.fileIdArray
                    }
                }
                continue
            } else {
                mbSocial.append(mbSocialData)
            }
        }
    }
    
    func likeThisPin() {
        if strPinId == "-1" {
            return
        }
        let likeThisPin = FaePinAction()
        likeThisPin.whereKey("", value: "")
        if strPinId != "-999" {
            likeThisPin.likeThisPin(type, pinID: strPinId) { (status: Int, _: Any?) in
                if status == 201 {
                    print("[likeThisPin] Successfully like this pin!")
                    self.updateLikeCount()
                    self.mbSocial[self.cellCurtIndex.row].isLiked = true
                } else {
                    print("Fail to like this pin!")
                }
            }
        }
    }
    
    func unlikeThisPin() {
        if strPinId == "-1" {
            return
        }
        let unlikeThisPin = FaePinAction()
        unlikeThisPin.whereKey("", value: "")
        unlikeThisPin.unlikeThisPin(type, pinID: strPinId) { (status: Int, _: Any?) in
            if status / 100 == 2 {
                print("Successfully unlike this pin!")
                self.updateLikeCount()
                self.mbSocial[self.cellCurtIndex.row].isLiked = false
            } else {
                print("Fail to unlike this pin!")
            }
        }
    }
    
    func updateLikeCount() {
        if strPinId == "-1" {
            return
        }
        
        let getPinAttr = FaePinAction()
        getPinAttr.getPinAttribute(type, pinID: strPinId) { (status: Int, message: Any?) in
            if status / 100 != 2 {
                return
            }
            let mapBoardJSON = JSON(message!)
            let likesCount = mapBoardJSON["likes"].intValue
            let commentsCount = mapBoardJSON["comments"].intValue
            
            let cellCurtSelect = self.tblCommentStory.cellForRow(at: self.cellCurtIndex) as! MBComtsStoriesCell
            
            cellCurtSelect.lblFavCount.text = "\(likesCount)"
            self.mbSocial[self.cellCurtIndex.row].likeCount = likesCount
            
            if likesCount >= 15 || commentsCount >= 10 {
                cellCurtSelect.imgHotPin.isHidden = false
                self.mbSocial[self.cellCurtIndex.row].status = "hot"
            } else {
                cellCurtSelect.imgHotPin.isHidden = true
            }
        }
    }
    
    // PinDetailCollectionsDelegate
    func backToCollections(likeCount: String, commentCount: String, pinLikeStatus: Bool, feelingArray: [Int]) {
        if likeCount == "" || commentCount == "" || cellCurtIndex == nil {
            return
        }
        
        let cellCurtSelect = tblCommentStory.cellForRow(at: cellCurtIndex) as! MBComtsStoriesCell
        cellCurtSelect.lblReplyCount.text = commentCount
        cellCurtSelect.lblFavCount.text = likeCount
        cellCurtSelect.btnFav.setImage(pinLikeStatus ? #imageLiteral(resourceName: "pinDetailLikeHeartFull") : #imageLiteral(resourceName: "pinDetailLikeHeartHollow"), for: .normal)
        
        if Int(likeCount)! >= 15 || Int(commentCount)! >= 10 {
            cellCurtSelect.imgHotPin.isHidden = false
            mbSocial[cellCurtIndex.row].status = "hot"
        } else {
            cellCurtSelect.imgHotPin.isHidden = true
        }
        
        let count = feelingArray.count <= 5 ? feelingArray.count : 5
        for i in 0..<count {
            cellCurtSelect.imgFeelings[i].image = feelingArray[i] >= 9 ?
                UIImage(named: "pdFeeling_\(feelingArray[i] + 1)-1") :
                UIImage(named: "pdFeeling_0\(feelingArray[i] + 1)-1")
        }
        for i in count..<5 {
            cellCurtSelect.imgFeelings[i].image = nil
        }
        
        mbSocial[cellCurtIndex.row].likeCount = Int(likeCount)!
        mbSocial[cellCurtIndex.row].commentCount = Int(commentCount)!
        mbSocial[cellCurtIndex.row].isLiked = pinLikeStatus
        mbSocial[cellCurtIndex.row].feelingArray = feelingArray
        print(feelingArray)
    }
    
    // MBComtsStoriesCellDelegate
    func replyToThisPin(indexPath: IndexPath, boolReply: Bool) {
        let vcPinDetail = PinDetailViewController()
        let social = mbSocial[indexPath.row]
        vcPinDetail.modalPresentationStyle = .overCurrentContext
        vcPinDetail.colDelegate = self
        vcPinDetail.enterMode = .collections
        vcPinDetail.strPinId = String(social.pinId)
        vcPinDetail.strTextViewText = social.contentJson
        PinDetailViewController.selectedMarkerPosition = social.position
        PinDetailViewController.pinTypeEnum = enterMode == .comment ? .comment : .media
        PinDetailViewController.pinUserId = social.userId
        cellCurtIndex = indexPath
        
        navigationController?.pushViewController(vcPinDetail, animated: true)
        
        vcPinDetail.boolFromMapBoard = boolReply
    }
    
    // MBComtsStoriesCellDelegate
    func likeThisPin(indexPath: IndexPath, strPinId: String) {
        let cell = tblCommentStory.cellForRow(at: indexPath) as! MBComtsStoriesCell
        
        if cell.btnFav.currentImage == #imageLiteral(resourceName: "pinDetailLikeHeartFull") {
            cell.btnFav.setImage(#imageLiteral(resourceName: "pinDetailLikeHeartHollow"), for: .normal)
            self.strPinId = strPinId
            
            unlikeThisPin()
        } else {
            cell.btnFav.setImage(#imageLiteral(resourceName: "pinDetailLikeHeartFull"), for: .normal)
            self.strPinId = strPinId
            
            likeThisPin()
        }
        cellCurtIndex = indexPath
    }
    
    //    func actionHoldingLikeButton(_ sender: UIButton) {
    //        sender.setImage(#imageLiteral(resourceName: "pinDetailLikeHeartFull"), for: UIControlState())
    //        animatingHeartTimer = Timer.scheduledTimer(timeInterval: 0.15, target: self, selector: #selector(self.animateHeart), userInfo: nil, repeats: true)
    //    }
    
    func animateHeart() {
    }
}
