//
//  PinsTableViewCell.swift
//  faeBeta
//
//  Created by Shiqi Wei on 4/17/17.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
import SwiftyJSON
import RealmSwift

// A protocol that the TableViewCell uses to inform its delegate of state change
protocol PinTableViewCellDelegate {
    // indicates that the given item has been deleted
    func itemSwiped(indexCell: Int)
    func toDoItemShared(indexCell: Int, pinId: Int, pinType: String)
    func toDoItemLocated(indexCell: Int, pinId: Int, pinType: String)
    func toDoItemUnsaved(indexCell: Int, pinId: Int, pinType: String)
    func toDoItemRemoved(indexCell: Int, pinId: Int, pinType: String)
    func toDoItemEdit(indexCell: Int, pinId: Int, pinType: String)
    func toDoItemVisible(indexCell: Int, pinId: Int, pinType: String) 
}

class PinsTableViewCell: UITableViewCell {
    
    var labelDate : UILabel!
    var labelDescription : UILabel!
    var labelLike : UILabel!
    var labelComment : UILabel!
    var imgPinPic01 : UIImageView!
    var imgPinPic02 : UIImageView!
    var imgPinPic03 : UIImageView!
    var labelPics3Plus : UILabel!
    var imgLike : UIImageView!
    var imgComment : UIImageView!
    var imgPinTab : UIImageView!
    var imgHot : UIImageView!
    var strHotStatus: String!
    var originalCenter = CGPoint()
    var swipedBtnsShowOnDragRelease = false
    var uiviewPinView : UIView! // this view is for pin
    var uiviewSwipedBtnsView : UIView! // this view is for buttons when swiped
    var uiviewCellView : UIView! // this view contains view for pin and view for buttons when swiped
    
    // The object that acts as delegate for this cell.
    var delegate: PinTableViewCellDelegate?
    var isCellSWiped = false
    var indexForCurrentCell = 0
    var pinId = 0
    var pinType = ""
    var finishedPositionX : CGFloat = 0
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setUpUI()
        // add a pan recognizer
        let recognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        recognizer.delegate = self
        uiviewPinView.addGestureRecognizer(recognizer)
    }
    
    // Interface - Initialize the position of swiped buttons
    func verticalCenterButtons(){
    
    }
    
    // handle function of pan gesture
    func handlePan(recognizer: UIPanGestureRecognizer) {
        // when the gesture begins, record the current center location
        if recognizer.state == .began {
            originalCenter = uiviewCellView.center
            verticalCenterButtons()
            // if the cell is already swiped or not
            if(uiviewCellView.center.x > 150){
                isCellSWiped = true
            }else{
                isCellSWiped = false
            }
        }
        
        // has the user dragged the item far enough?
        if recognizer.state == .changed {
            let translation = recognizer.translation(in: self)
            swipedBtnsShowOnDragRelease = uiviewCellView.center.x > 70 && !isCellSWiped
            if(uiviewCellView.center.x <= -9){
                // don't remove when the left side of the cell reaches -8
                uiviewCellView.center = CGPoint(x: -10, y:uiviewCellView.center.y)
            }else{
                uiviewCellView.center = CGPoint(x: originalCenter.x + translation.x, y:originalCenter.y)
            }
        }
        
        // the gesture ends
        if recognizer.state == .ended || recognizer.state == .failed || recognizer.state == .cancelled{
            let cellViewframe = uiviewCellView.frame
            // the frame this cell had before user dragged it
            let originalFrame = CGRect(x: -screenWidth, y: cellViewframe.origin.y,
                                       width: cellViewframe.width, height: cellViewframe.height)
            // the frame this cell will be after user dragged it
            let finishFrame = CGRect(x: -screenWidth + finishedPositionX, y: cellViewframe.origin.y,
                                     width: cellViewframe.width, height: cellViewframe.height)
            // the frame this cell will bounce to after user dragged it from right to left
            let bounceFrame = CGRect(x: -screenWidth + 35, y: cellViewframe.origin.y,
                                     width: cellViewframe.width, height: cellViewframe.height)
            if !swipedBtnsShowOnDragRelease {
                if uiviewCellView.center.x < 0 {
                    // if the item is being swiped from right to left, bonuce back to the original location
                    UIView.animate(withDuration: 0.3,
                                   animations: {
                                    self.uiviewCellView.frame = bounceFrame
                    }, completion: { (finished) -> Void in
                        
                        UIView.animate(withDuration: 0.3, animations: {self.uiviewCellView.frame = originalFrame})
                        
                    })
                }else{
                    // if the item is not being swiped enough, snap back to the original location
                    UIView.animate(withDuration: 0.3, animations: {self.uiviewCellView.frame = originalFrame})
                }
            }
            else{
                UIView.animate(withDuration: 0.3, animations: {self.uiviewCellView.frame = finishFrame}, completion: { (finished) -> Void in
                    self.delegate?.itemSwiped(indexCell: self.indexForCurrentCell)
                })
            }
        }
    }
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer {
            let translation = panGestureRecognizer.translation(in: superview!)
            if fabs(translation.x) > fabs(translation.y) {
                return true
            }
            return false
        }
        return false
    }
    
    
    // Setup the cell when creat it
    func setUpUI() {
        // The cell is an uiviewCellView which consists of uiviewPinView and uiviewSwipedBtnsView
        uiviewCellView = UIView()
        uiviewCellView.backgroundColor = .clear
        self.addSubview(uiviewCellView)
        
        // The uiview is for pin contents
        uiviewPinView = UIView()
        uiviewPinView.backgroundColor = .white
        uiviewPinView.layer.cornerRadius = 10.0
        uiviewCellView.addSubview(uiviewPinView)
        
        // The uiview is for buttons when swiped
        uiviewSwipedBtnsView = UIView()
        uiviewSwipedBtnsView.backgroundColor = .clear
        uiviewCellView.addSubview(uiviewSwipedBtnsView)
        
        //set the date
        labelDate = UILabel()
        labelDate.font = UIFont(name: "AvenirNext-Medium",size: 13)
        uiviewPinView.addSubview(labelDate)
        
        // set description
        labelDescription = UILabel()
        labelDescription.lineBreakMode = NSLineBreakMode.byTruncatingTail
        labelDescription.numberOfLines = 3
        labelDescription.font = UIFont(name: "AvenirNext-Regular",size: 18)
        labelDescription.textAlignment = NSTextAlignment.left
        labelDescription.textColor = UIColor.faeAppInputTextGrayColor()
        uiviewPinView.addSubview(labelDescription)
        
        // set like number
        labelLike = UILabel()
        labelLike.font = UIFont(name: "AvenirNext-Medium",size: 10)
        labelLike.textAlignment = NSTextAlignment.right
        labelLike.textColor = UIColor.faeAppTimeTextBlackColor()
        uiviewPinView.addSubview(labelLike)
        
        // set like
        imgLike = UIImageView()
        imgLike.image = #imageLiteral(resourceName: "like")
        uiviewPinView.addSubview(imgLike)
        
        // set comment number
        labelComment = UILabel()
        labelComment.font = UIFont(name: "AvenirNext-Medium",size: 10)
        labelComment.textAlignment = NSTextAlignment.right
        labelComment.textColor = UIColor.faeAppTimeTextBlackColor()
        uiviewPinView.addSubview(labelComment)
        
        // set comment button
        imgComment = UIImageView()
        imgComment.image = #imageLiteral(resourceName: "comment")
        uiviewPinView.addSubview(imgComment)
        
        // set tab
        imgPinTab = UIImageView()
        uiviewPinView.addSubview(imgPinTab!)
        
        // set hot
        imgHot = UIImageView()
        uiviewPinView.addSubview(imgHot!)
        
        //set pics
        imgPinPic01 = UIImageView()
        uiviewPinView.addSubview(imgPinPic01!)
        
        imgPinPic02 = UIImageView()
        uiviewPinView.addSubview(imgPinPic02!)
        
        imgPinPic03 = UIImageView()
        uiviewPinView.addSubview(imgPinPic03!)
        
        labelPics3Plus = UILabel()
        labelPics3Plus.text = "3+"
        labelPics3Plus.font = UIFont(name: "AvenirNext-Medium",size: 18)
        labelPics3Plus.textColor = UIColor.faeAppInputPlaceholderGrayColor()
        uiviewPinView.addSubview(labelPics3Plus)
        
        //Add the constraints of uiviewPinView & uiviewSwipedBtnsView in the uiviewCellView
        uiviewCellView.addConstraintsWithFormat("H:|-0-[v0(\(screenWidth))]-9-[v1]-9-|", options: [], views: uiviewSwipedBtnsView, uiviewPinView)
        uiviewCellView.addConstraintsWithFormat("V:|-0-[v0]-0-|", options: [], views: uiviewPinView)
        uiviewCellView.addConstraintsWithFormat("V:|-0-[v0]-0-|", options: [], views: uiviewSwipedBtnsView)
        
        //Add the constraints of uiviewCellView in the cell self
        self.addConstraintsWithFormat("H:|-(-\(screenWidth))-[v0]-0-|", options: [], views: uiviewCellView)
        self.addConstraintsWithFormat("V:|-0-[v0]-0-|", options: [], views: uiviewCellView)
 
    }
    
    // call this fuction when reuse cell, set value to the cell and rebuild the layout
    func setValueForCell(_ pin: [String: AnyObject]) {
        
        //The cell is reuseable, so clear the constrains in uiviewPinView when reuse the cell
        uiviewPinView.removeConstraints(uiviewPinView.constraints)
        
        imgPinPic01.isHidden = true
        imgPinPic02.isHidden = true
        imgPinPic03.isHidden = true
        labelPics3Plus.isHidden = true
        
        // set the value to those data
        if let type = pin["type"]{
            pinType = type as! String
        }
        if let id = pin["pin_id"]{
            pinId = id as! Int
        }
        
        if let createat = pin["created_at"]{
            labelDate.text = (createat as! String).formatNSDate()
//            labelTime.text = ((createat as! String).formatFaeDate()) + " on Map"
        }
        
        strHotStatus = ""
        if let likeCount = pin["liked_count"] as! Int? {
            labelLike.text = String(likeCount)
            if likeCount >= 15 {
                strHotStatus = "hot"
            }
        }
        if let commentCount = pin["comment_count"]as! Int?  {
            labelComment.text = String(commentCount)
            if commentCount >= 10 {
                strHotStatus = "hot"
            }
        }
        
        //Add the constraints in uiviewPinView
        uiviewPinView.addConstraintsWithFormat("V:|-12-[v0(18)]", options: [], views: labelDate)
        
        uiviewPinView.addConstraintsWithFormat("H:|-20-[v0]-20-|", options: [], views: labelDescription)
        
        uiviewPinView.addConstraintsWithFormat("H:[v0(27)]-95-|", options: [], views: labelLike)
        uiviewPinView.addConstraintsWithFormat("V:[v0(14)]-11-|", options: [], views: labelLike)
        
        uiviewPinView.addConstraintsWithFormat("H:[v0(18)]-73-|", options: [], views: imgLike)
        uiviewPinView.addConstraintsWithFormat("V:[v0(15)]-12-|", options: [], views: imgLike)
        
        uiviewPinView.addConstraintsWithFormat("H:[v0(27)]-34-|", options: [], views: labelComment)
        uiviewPinView.addConstraintsWithFormat("V:[v0(14)]-11-|", options: [], views: labelComment)
        
        uiviewPinView.addConstraintsWithFormat("H:[v0(18)]-13-|", options: [], views: imgComment)
        uiviewPinView.addConstraintsWithFormat("V:[v0(15)]-12-|", options: [], views: imgComment)
        
        uiviewPinView.addConstraintsWithFormat("H:|-0-[v0(20)]|", options: [], views: imgPinTab)
        uiviewPinView.addConstraintsWithFormat("V:[v0(11)]-14-|", options: [], views: imgPinTab)
        
        uiviewPinView.addConstraintsWithFormat("H:[v0(18)]-134-|", options: [], views: imgHot)
        uiviewPinView.addConstraintsWithFormat("V:[v0(20)]-10-|", options: [], views: imgHot)
        
        // hot or not
        if strHotStatus == "hot" {
            imgHot.image = UIImage(named: "hot")
        }else{
            imgHot.image = UIImage()
        }
        
        // for media pin
        if pinType == "media" {
            if let descContent = pin["description"] as? String{
                labelDescription.attributedText = descContent.convertStringWithEmoji()
            }
            imgPinTab.image = UIImage(named: "tab_comment")
            
            if let imgArr = pin["file_ids"] as? [Int] { // changed by Yue Shen to get compiled
                
                let count = imgArr.count
                // no pic
                if count == 0 {
                    uiviewPinView.addConstraintsWithFormat("V:|-39-[v0]-42-|", options: [], views: labelDescription)
                }
                // the first image
                if(count>0){
                    imgFirstPic.isHidden = false
                    
                    let imgId = imgArr[0]// changed by Yue Shen to get compiled
                    let fileURL = "https://dev.letsfae.com/files/\(imgId)/data"
                    
                    uiviewPinView.addConstraintsWithFormat("H:|-20-[v0(95)]", options: [], views: imgFirstPic)
                    imgFirstPic.contentMode = .scaleAspectFill
                    imgFirstPic.layer.cornerRadius = 13.5
                    imgFirstPic.clipsToBounds = true
                    imgFirstPic.isUserInteractionEnabled = true
                    imgFirstPic.sd_setImage(with: URL(string: fileURL), placeholderImage: nil, options: [.retryFailed, .refreshCached], completed: { (image, error, SDImageCacheType, imageURL) in
                        if image != nil {
                        }
                    })
                    uiviewPinView.addConstraintsWithFormat("V:|-39-[v0]-12-[v1(95)]-42-|", options: [], views: labelDescription,imgFirstPic)
                }
                
                // the second image
                if(count>1){
                    imgSecondPic.isHidden = false
                    let imgId = imgArr[1]// changed by Yue Shen to get compiled
                    let fileURL = "https://dev.letsfae.com/files/\(imgId)/data"
                    uiviewPinView.addConstraintsWithFormat("H:[v0]-10-[v1(95)]", options: [], views: imgFirstPic,imgSecondPic)
                    imgSecondPic.contentMode = .scaleAspectFill
                    imgSecondPic.layer.cornerRadius = 13.5
                    imgSecondPic.clipsToBounds = true
                    imgSecondPic.isUserInteractionEnabled = true
                    imgSecondPic.sd_setImage(with: URL(string: fileURL), placeholderImage: nil, options: [.retryFailed, .refreshCached], completed: { (image, error, SDImageCacheType, imageURL) in
                        if image != nil {
                        }
                    })
                    uiviewPinView.addConstraintsWithFormat("V:[v0]-12-[v1(95)]-42-|", options: [], views: labelDescription,imgSecondPic)
                }
                
                //the third image
                if(count>2){
                    imgThirdPic.isHidden = false
                    let imgId = imgArr[2]// changed by Yue Shen to get compiled
                    let fileURL = "https://dev.letsfae.com/files/\(imgId)/data"
                    uiviewPinView.addConstraintsWithFormat("H:[v0]-10-[v1(95)]", options: [], views: imgSecondPic,imgThirdPic)
                    imgThirdPic.contentMode = .scaleAspectFill
                    imgThirdPic.layer.cornerRadius = 13.5
                    imgThirdPic.clipsToBounds = true
                    imgThirdPic.isUserInteractionEnabled = true
                    imgThirdPic.sd_setImage(with: URL(string: fileURL), placeholderImage: nil, options: [.retryFailed, .refreshCached], completed: { (image, error, SDImageCacheType, imageURL) in
                        if image != nil {
                        }
                    })
                    uiviewPinView.addConstraintsWithFormat("V:[v0]-12-[v1(95)]-42-|", options: [], views: labelDescription,imgThirdPic)
                }
                // more than 3 pics
                if(count>3){
                    labelMoreThanThreePics.isHidden = false
                    uiviewPinView.addConstraintsWithFormat("V:[v0]-47-[v1(25)]", options: [], views: labelDescription,labelMoreThanThreePics)
                    uiviewPinView.addConstraintsWithFormat("H:[v0]-18-[v1(23)]", options: [], views: imgThirdPic,labelMoreThanThreePics)
                }
            }
            
        }
        //For comment pin
        if pinType == "comment"{
            if let descContent = pin["content"] as? String{
                labelDescription.attributedText = descContent.convertStringWithEmoji()
            }
            imgPinTab.image = UIImage(named: "tab_story")
            uiviewPinView.addConstraintsWithFormat("V:|-39-[v0]-42-|", options: [], views: labelDescription)
        }
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
}
