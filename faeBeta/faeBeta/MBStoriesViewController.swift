//
//  MBStoriesViewController.swift
//  FaeMapBoard
//
//  Created by vicky on 4/12/17.
//  Copyright © 2017 Yue. All rights reserved.
//

import UIKit

class MBStoriesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, PinDetailCollectionsDelegate {
    var uiviewNaviBar: UIView!
    var tableStories: UITableView!
    
    var mbStories = [MBSocialStruct]()
    var scrollViewMedia: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadNavBar()
        loadTable()
    }
    
    fileprivate func loadNavBar() {
        let uiviewNavBar = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 65))
        uiviewNavBar.backgroundColor = .white
        view.addSubview(uiviewNavBar)
        
        let uiviewLine = UIView(frame: CGRect(x: 0, y: 64, width: screenWidth, height: 1))
        uiviewLine.backgroundColor = UIColor.faeAppNavBarBorderColor()
        uiviewNavBar.addSubview(uiviewLine)
        
        let lblTitle = UILabel(frame: CGRect(x: (screenWidth - 63) / 2, y: 28, width: 63, height: 27))
        lblTitle.text = "Stories"
        lblTitle.textColor = UIColor.faeAppInputTextGrayColor()
        lblTitle.font = UIFont(name: "AvenirNext-Medium", size: 20)
        lblTitle.textAlignment = NSTextAlignment.center
        uiviewNavBar.addSubview(lblTitle)
        
        let btnBackNavBar = UIButton(frame: CGRect(x: 0, y: 20, width: 40.5, height: 42))
        btnBackNavBar.setImage(#imageLiteral(resourceName: "mainScreenSearchToFaeMap"), for: .normal)
        btnBackNavBar.addTarget(self, action: #selector(self.backToMapBoard(_:)), for: .touchUpInside)
        uiviewNavBar.addSubview(btnBackNavBar)
    }
    
    fileprivate func loadTable() {
        tableStories = UITableView(frame: CGRect(x: 0, y: 65, width: screenWidth, height: screenHeight - 65))
        tableStories.backgroundColor = .white
        tableStories.register(MBStoriesCell.self, forCellReuseIdentifier: "mbStoriesCell")
        tableStories.delegate = self
        tableStories.dataSource = self
        tableStories.separatorStyle = .none
        tableStories.rowHeight = UITableViewAutomaticDimension
        tableStories.estimatedRowHeight = 400
//        tableStories.allowsSelection = false
        
        view.addSubview(tableStories)
    }
    
    func backToMapBoard(_ sender: UIButton) {
        //        self.dismiss(animated: false, completion: nil)
        navigationController?.popViewController(animated: true)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    //    let imgAvatarArr: Array = ["default_Avatar", "default_Avatar", "default_Avatar"]
    //    let lblUsrNameTxt: Array = ["Yuukipuasighastast", "Yuukipuasighastast", "Yuukipuasighastast"]
    //    let lblTimeTxt: Array = ["Just Now", "Yesterday", "December 29, 2016"]
    //    let lblContTxt: Array = ["Look at these cute puppies I saw at the park today! Too cute I want one!!!", "PLSPLSPLSPLS", "Wuts up?"]
    //    let imgMediaArray: Array = [["default_Pic", "default_Pic", "default_Pic", "default_Pic", "default_Pic"], ["default_Pic"], ["default_Pic"]]
    //    let lblStoryLocTxt: Array = ["Los Angeles CA, 2714 S. Hoover St.", "Los Angeles CA, 2714 S. Hooooooooooooooooooover St.", "Los Angeles CA, 2714 S. Hoover St."]
    //    let lblFavCountTxt: Array = [8, 7, 5]
    //    let lblReplyCountTxt: Array = [12, 5, 4]
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mbStories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "mbStoriesCell", for: indexPath) as! MBStoriesCell
        let story = mbStories[indexPath.row]
        cell.lblTime.text = story.date
        cell.lblContent.attributedText = story.attributedText
        if story.anonymous || story.displayName == "" {
            cell.lblUsrName.text = "Someone"
            cell.imgAvatar.image = #imageLiteral(resourceName: "default_Avatar")
        } else {
            cell.lblUsrName.text = story.displayName
            cell.setValueForCell(userId: story.userId)
        }
        
        cell.setAddressForCell(position: story.position, id: story.pinId, type: story.type)
        cell.lblStoryLoc.text = story.address
        cell.imgHotPin.isHidden = story.status != "hot"

        cell.lblFavCount.text = String(story.likeCount)
        cell.lblReplyCount.text = String(story.commentCount)
        
        cell.btnFav.setImage(story.isLiked ? #imageLiteral(resourceName: "mb_comment_heart_full") : #imageLiteral(resourceName: "mb_comment_heart_empty"), for: .normal)
        
        cell.imgMediaArr.removeAll()
        for subview in cell.scrollViewMedia.subviews {
            subview.removeFromSuperview()
        }
        
        for index in 0..<story.fileIdArray.count {
            let imageView = FaeImageView(frame: CGRect(x: 105 * index, y: 0, width: 95, height: 95))
            imageView.clipsToBounds = true
            imageView.contentMode = .scaleAspectFill
            imageView.layer.cornerRadius = 13.5
            imageView.fileID = story.fileIdArray[index]
            imageView.loadImage(id: story.fileIdArray[index])
            cell.imgMediaArr.append(imageView)
            cell.scrollViewMedia.addSubview(imageView)
        }
        // the tableView can't scroll up/down when finger is touched on the scrollView when height is 95
        // Finally, I set the scrollView's height smaller than the height in storyboard => height: 90 instead of 95
        cell.scrollViewMedia.contentSize = CGSize(width: story.fileIdArray.count * 105 - 10, height: 90)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        let vcPinDetail = PinDetailViewController()
        let story = self.mbStories[indexPath.row]
        vcPinDetail.modalPresentationStyle = .overCurrentContext
        vcPinDetail.colDelegate = self
        vcPinDetail.enterMode = .collections
        vcPinDetail.strPinId = String(story.pinId)
        vcPinDetail.strTextViewText = ""
        PinDetailViewController.selectedMarkerPosition = story.position
        PinDetailViewController.pinTypeEnum = .media
        PinDetailViewController.pinUserId = story.userId
        
        self.navigationController?.pushViewController(vcPinDetail, animated: true)
    }
    
    // PinDetailCollectionsDelegate
    func backToCollections(likeCount: String, commentCount: String) {
    }
}
