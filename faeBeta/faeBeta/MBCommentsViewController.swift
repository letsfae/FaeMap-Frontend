//
//  MBCommentsViewController.swift
//  FaeMapBoard
//
//  Created by vicky on 4/11/17.
//  Copyright © 2017 Yue. All rights reserved.
//

import UIKit
import GoogleMaps

class MBCommentsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, PinDetailCollectionsDelegate {
    var tableComments: UITableView!
    var mbComments = [MBSocialStruct]()
    var cellCurtIndex: IndexPath!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadNavBar()
        loadTable()
    }
    
    fileprivate func loadNavBar() {
        let uiviewNavBar = FaeNavBar(frame: CGRect.zero)
        self.view.addSubview(uiviewNavBar)
        uiviewNavBar.loadBtnConstraints()
        uiviewNavBar.leftBtn.addTarget(self, action: #selector(self.backToMapBoard(_:)), for: .touchUpInside)
        uiviewNavBar.rightBtn.isHidden = true
        
        uiviewNavBar.lblTitle.text = "Comments"
    }
    
    fileprivate func loadTable() {
        tableComments = UITableView(frame: CGRect(x: 0, y: 65, width: screenWidth, height: screenHeight - 65))
        tableComments.backgroundColor = .white
        tableComments.register(MBCommentsCell.self, forCellReuseIdentifier: "mbCommentsCell")
        tableComments.delegate = self
        tableComments.dataSource = self
        tableComments.separatorStyle = .none
        tableComments.rowHeight = UITableViewAutomaticDimension
        tableComments.estimatedRowHeight = 200
        //        tableComments.allowsSelection = false
        
        self.view.addSubview(tableComments)
    }
    
    func backToMapBoard(_ sender: UIButton) {
        //        self.dismiss(animated: false, completion: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    //    let imgAvatarArr: Array = ["default_Avatar", "default_Avatar", "default_Avatar"]
    //    let lblUsrNameTxt: Array = ["Holly Laura", "Anonymous", "Peach"]
    //    let lblTimeTxt: Array = ["Just Now", "Yesterday", "December 29, 2016"]
    //    let lblContTxt: Array = ["There's a party going on later near campus, anyone wanna go with me? Looking for around 3 more people!", "There's a party going on later near campus, anyone wanna go with me? Looking for around 3 more people! COMECOMECOME", "Wuts up?"]
    //    let lblComLocTxt: Array = ["Los Angeles CA, 2714 S. Hoover St.", "Los Angeles CA, 2714 S. Hooooooooooooooooooover St.", "Los Angeles CA, 2714 S. Hoover St."]
    //    let lblFavCountTxt: Array = [8, 7, 5]
    //    let lblReplyCountTxt: Array = [12, 5, 4]
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.mbComments.count
    }
    
    // Yue 06/11/17
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "mbCommentsCell", for: indexPath) as! MBCommentsCell
        
        let comment = self.mbComments[indexPath.row]
        cell.lblTime.text = comment.date
        cell.lblContent.attributedText = comment.attributedText
        if comment.anonymous || comment.displayName == "" {
            cell.lblUsrName.text = "Someone"
            cell.imgAvatar.image = #imageLiteral(resourceName: "default_Avatar")
        } else {
            cell.lblUsrName.text = comment.displayName
            cell.setValueForCell(userId: comment.userId)
        }
        
        cell.setAddressForCell(position: comment.position, id: comment.pinId, type: comment.type)
        cell.lblComLoc.text = comment.address
        cell.imgHotPin.isHidden = comment.status != "hot"
        cell.lblFavCount.text = String(comment.likeCount)
        cell.btnFav.setImage(comment.isLiked ? #imageLiteral(resourceName: "pinDetailLikeHeartFull") : #imageLiteral(resourceName: "pinDetailLikeHeartHollow"), for: .normal)
        cell.lblReplyCount.text = String(comment.commentCount)
        
        return cell
    }
    // Yue 06/11/17 End
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        let vcPinDetail = PinDetailViewController()
        let comment = self.mbComments[indexPath.row]
        vcPinDetail.modalPresentationStyle = .overCurrentContext
        vcPinDetail.colDelegate = self
        vcPinDetail.enterMode = .collections
        vcPinDetail.strPinId = String(comment.pinId)
        vcPinDetail.strTextViewText = comment.contentJson
        PinDetailViewController.selectedMarkerPosition = comment.position
        PinDetailViewController.pinTypeEnum = .comment
        PinDetailViewController.pinUserId = comment.userId
        self.cellCurtIndex = indexPath
        
        self.navigationController?.pushViewController(vcPinDetail, animated: true)
    }
    
    // PinDetailCollectionsDelegate
    func backToCollections(likeCount: String, commentCount: String, pinLikeStatus: Bool) {
        if likeCount == "" || commentCount == "" || self.cellCurtIndex == nil {
            return
        }
        
        let cellCurtSelect = tableComments.cellForRow(at: self.cellCurtIndex) as! MBCommentsCell
        cellCurtSelect.lblReplyCount.text = commentCount
        cellCurtSelect.lblFavCount.text = likeCount
        cellCurtSelect.btnFav.setImage(pinLikeStatus ? #imageLiteral(resourceName: "pinDetailLikeHeartFull") : #imageLiteral(resourceName: "pinDetailLikeHeartHollow"), for: .normal)
        
        if Int(likeCount)! >= 15 || Int(commentCount)! >= 10 {
            cellCurtSelect.imgHotPin.isHidden = false
        } else {
            cellCurtSelect.imgHotPin.isHidden = true
        }
        self.mbComments[cellCurtIndex.row].likeCount = Int(likeCount)!
        self.mbComments[cellCurtIndex.row].commentCount = Int(commentCount)!
        self.mbComments[cellCurtIndex.row].isLiked = pinLikeStatus
    }
}
