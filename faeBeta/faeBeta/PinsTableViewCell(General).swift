//
//  PinsTableViewCell.swift
//  faeBeta
//
//  Created by Shiqi Wei on 4/17/17.
//  Edited by Sophie Wang
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
import SwiftyJSON
import RealmSwift

// A protocol that the TableViewCell uses to inform its delegate of state change
protocol PinTableViewCellDelegate: class {
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
    
    var arrImages = [FaeImageView]()
    
    var boolIsCellSWiped = false
    var boolIsHot = false
    var boolShowOnDragRelease = false
    
    var finishedPositionX: CGFloat = 0
    var imgComment: UIImageView!
    var imgHot: UIImageView!
    var imgLike: UIImageView!
    var imgPinTab: UIImageView!
    
    var indexForCurrentCell = 0
    var intPinId = 0
    
    var lblCommentCount: UILabel!
    var lblContent: UILabel!
    var lblDate: UILabel!
    var lblLikeCount: UILabel!
    var lblPics3Plus: UILabel!
    
    var pointOriginalCenter = CGPoint()
    var strPinType = ""
    var uiviewCellView: UIView! // this view contains view for pin and view for buttons when swiped
    var uiviewPinView: UIView!
    var uiviewSwipedBtnsView: UIView!
    var uiviewStoryImages: UIView!
    
    var imgChatRoom: FaeImageView!
    var lblChatTitle: UILabel!
    var lblChatDesc: UILabel!
    
    weak var delegate: PinTableViewCellDelegate?
    
    internal var imageContraint = [NSLayoutConstraint]() {
        didSet {
            if oldValue.count != 0 {
                uiviewPinView.removeConstraints(oldValue)
            }
            if imageContraint.count != 0 {
                uiviewPinView.addConstraints(imageContraint)
            }
        }
    }
    
    internal var hotContraint = [NSLayoutConstraint]() {
        didSet {
            if oldValue.count != 0 {
                uiviewPinView.removeConstraints(oldValue)
            }
            if hotContraint.count != 0 {
                uiviewPinView.addConstraints(hotContraint)
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setUpUI()
        
        separatorInset = UIEdgeInsetsMake(0, 1000, 0, 0)
        backgroundColor = .clear
        selectionStyle = .none
        
        let recognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        recognizer.delegate = self
        uiviewPinView.addGestureRecognizer(recognizer)
    }
    
    func setUpUI() {
        // The cell is an uiviewCellView which consists of uiviewPinView and uiviewSwipedBtnsView
        uiviewCellView = UIView()
        uiviewCellView.backgroundColor = .clear
        addSubview(uiviewCellView)
        addConstraintsWithFormat("H:|-(-\(screenWidth))-[v0]-0-|", options: [], views: uiviewCellView)
        addConstraintsWithFormat("V:|-0-[v0]-0-|", options: [], views: uiviewCellView)
        
        // The uiview is for pin contents
        uiviewPinView = UIView()
        uiviewPinView.backgroundColor = .white
        uiviewPinView.layer.cornerRadius = 10.0
        uiviewCellView.addSubview(uiviewPinView)
        
        // The uiview is for buttons when swiped
        uiviewSwipedBtnsView = UIView()
        uiviewSwipedBtnsView.backgroundColor = .clear
        uiviewCellView.addSubview(uiviewSwipedBtnsView)
        
        uiviewCellView.addConstraintsWithFormat("H:|-0-[v0(\(screenWidth))]-9-[v1]-9-|", options: [], views: uiviewSwipedBtnsView, uiviewPinView)
        uiviewCellView.addConstraintsWithFormat("V:|-0-[v0]-0-|", options: [], views: uiviewPinView)
        uiviewCellView.addConstraintsWithFormat("V:|-0-[v0]-0-|", options: [], views: uiviewSwipedBtnsView)
        
        lblDate = UILabel()
        lblDate.font = UIFont(name: "AvenirNext-Medium", size: 13)
        lblDate.textAlignment = .left
        lblDate.textColor = UIColor._107107107()
        uiviewPinView.addSubview(lblDate)
        // lblDate's horizontal constraint will be set in each child class
        uiviewPinView.addConstraintsWithFormat("V:|-12-[v0(18)]", options: [], views: lblDate)
        
        lblContent = UILabel()
        lblContent.lineBreakMode = NSLineBreakMode.byTruncatingTail
        lblContent.numberOfLines = 3
        lblContent.font = UIFont(name: "AvenirNext-Regular", size: 18)
        lblContent.textAlignment = .left
        lblContent.textColor = UIColor._898989()
        uiviewPinView.addSubview(lblContent)
        uiviewPinView.addConstraintsWithFormat("H:|-20-[v0]-20-|", options: [], views: lblContent)
        
        lblLikeCount = UILabel()
        lblLikeCount.font = UIFont(name: "AvenirNext-Medium", size: 10)
        lblLikeCount.textAlignment = .right
        lblLikeCount.textColor = UIColor._107107107()
        uiviewPinView.addSubview(lblLikeCount)
        uiviewPinView.addConstraintsWithFormat("H:[v0(27)]-95-|", options: [], views: lblLikeCount)
        uiviewPinView.addConstraintsWithFormat("V:[v0(14)]-11-|", options: [], views: lblLikeCount)
        
        imgLike = UIImageView()
        imgLike.image = #imageLiteral(resourceName: "pinDetailLikeHeartHollow")
        imgLike.contentMode = .scaleAspectFit
        uiviewPinView.addSubview(imgLike)
        uiviewPinView.addConstraintsWithFormat("H:[v0(18)]-73-|", options: [], views: imgLike)
        uiviewPinView.addConstraintsWithFormat("V:[v0(15)]-12-|", options: [], views: imgLike)
        
        lblCommentCount = UILabel()
        lblCommentCount.font = UIFont(name: "AvenirNext-Medium", size: 10)
        lblCommentCount.textAlignment = .right
        lblCommentCount.textColor = UIColor._107107107()
        uiviewPinView.addSubview(lblCommentCount)
        uiviewPinView.addConstraintsWithFormat("H:[v0(27)]-34-|", options: [], views: lblCommentCount)
        uiviewPinView.addConstraintsWithFormat("V:[v0(14)]-11-|", options: [], views: lblCommentCount)
        
        imgComment = UIImageView()
        imgComment.image = #imageLiteral(resourceName: "pinDetailShowCommentsHollow")
        uiviewPinView.addSubview(imgComment)
        uiviewPinView.addConstraintsWithFormat("H:[v0(18)]-13-|", options: [], views: imgComment)
        uiviewPinView.addConstraintsWithFormat("V:[v0(15)]-12-|", options: [], views: imgComment)
        
        imgPinTab = UIImageView()
        uiviewPinView.addSubview(imgPinTab!)
        uiviewPinView.addConstraintsWithFormat("H:|-0-[v0(20)]|", options: [], views: imgPinTab)
        uiviewPinView.addConstraintsWithFormat("V:[v0(11)]-14-|", options: [], views: imgPinTab)
        
        imgHot = UIImageView()
        imgHot.image = #imageLiteral(resourceName: "pinDetailHotPin")
        uiviewPinView.addSubview(imgHot)
        imgHot.isHidden = false
        uiviewPinView.addConstraintsWithFormat("V:[v0(20)]-10-|", options: [], views: imgHot)
        
        loadStoryItems()
        loadChatItems()
    }
    
    fileprivate func loadChatItems() {
        imgChatRoom = FaeImageView(frame: CGRect.zero)
        imgChatRoom.layer.cornerRadius = 31
        imgChatRoom.clipsToBounds = true
        uiviewPinView.addSubview(imgChatRoom)
        uiviewPinView.addConstraintsWithFormat("H:|-20-[v0(62)]", options: [], views: imgChatRoom)
        
        lblChatTitle = UILabel()
        lblChatTitle.font = UIFont(name: "AvenirNext-Regular", size: 18)
        lblChatTitle.textAlignment = .left
        lblChatTitle.numberOfLines = 1
        lblChatTitle.textColor = UIColor._107107107()
        uiviewPinView.addSubview(lblChatTitle)
        uiviewPinView.addConstraintsWithFormat("H:|-96-[v0]-40-|", options: [], views: lblChatTitle)
        uiviewPinView.addConstraintsWithFormat("V:|-44-[v0(25)]", options: [], views: lblChatTitle)
        
        // reason to use CGRect to layout lblChatDesc is content of lblChatDesc should be sizeToFit() for better display
        lblChatDesc = UILabel(frame: CGRect(x: 96, y: 70, width: screenWidth - 145, height: 36))
        lblChatDesc.font = UIFont(name: "AvenirNext-Regular", size: 13)
        lblChatDesc.textAlignment = .left
        lblChatDesc.textColor = UIColor(r: 115, g: 115, b: 115, alpha: 100)
        uiviewPinView.addSubview(lblChatDesc)
        lblChatDesc.numberOfLines = 2
    }
    
    func setImageConstraint() {
        if strPinType == "comment" {
            imageContraint = returnConstraintsWithFormat("V:|-39-[v0]-42-|", options: [], views: lblContent)
            hotContraint = returnConstraintsWithFormat("H:[v0(18)]-134-|", options: [], views: imgHot)
        } else if strPinType == "media" {
            imageContraint = returnConstraintsWithFormat("V:|-39-[v0]-12-[v1(95)]-42-|", options: [], views: lblContent, uiviewStoryImages)
            hotContraint = returnConstraintsWithFormat("H:[v0(18)]-134-|", options: [], views: imgHot)
        } else if strPinType == "chat_room" {
            imageContraint = returnConstraintsWithFormat("V:|-44-[v0(62)]-39-|", options: [], views: imgChatRoom)
            hotContraint = returnConstraintsWithFormat("H:[v0(18)]-13-|", options: [], views: imgHot)
        }
    }
    
    // call this fuction when reuse cell, set value to the cell and rebuild the layout
    func setValueForCell(_ pin: MapPinCollections) {
        
        strPinType = pin.type
        intPinId = pin.pinId
        lblDate.text = pin.date.formatFaeDate()
        lblLikeCount.text = "\(pin.likeCount)"
        lblCommentCount.text = "\(pin.commentCount)"
        lblChatTitle.text = pin.chatTitle
        lblChatDesc.text = pin.content
        lblContent.attributedText = pin.content.convertStringWithEmoji()
        imgLike.image = pin.isLiked ? #imageLiteral(resourceName: "pinDetailLikeHeartFull") : #imageLiteral(resourceName: "pinDetailLikeHeartHollow")
        
        imgHot.isHidden = pin.likeCount >= 15 || pin.commentCount >= 10
        imgChatRoom.isHidden = strPinType != "chat_room"
        imgComment.isHidden = strPinType == "chat_room"
        imgLike.isHidden = strPinType == "chat_room"
        lblLikeCount.isHidden = strPinType == "chat_room"
        lblCommentCount.isHidden = strPinType == "chat_room"
        lblChatDesc.isHidden = strPinType != "chat_room"
        lblChatTitle.isHidden = strPinType != "chat_room"
        lblContent.isHidden = strPinType == "chat_room"
        uiviewStoryImages.isHidden = strPinType != "media"
        
        imgPinTab.image = UIImage(named: "tab_\(strPinType)")
        if strPinType == "media" {
            if pin.fileIds.indices.contains(0) {
                arrImages[0].backgroundColor = UIColor(r: 214, g: 214, b: 214, alpha: 60)
                arrImages[0].fileID = pin.fileIds[0]
                arrImages[0].loadImage(id: pin.fileIds[0])
            }
            if pin.fileIds.indices.contains(1) {
                arrImages[1].backgroundColor = UIColor(r: 214, g: 214, b: 214, alpha: 60)
                arrImages[1].fileID = pin.fileIds[1]
                arrImages[1].loadImage(id: pin.fileIds[1])
            }
            if pin.fileIds.indices.contains(2) {
                arrImages[2].backgroundColor = UIColor(r: 214, g: 214, b: 214, alpha: 60)
                arrImages[2].fileID = pin.fileIds[2]
                arrImages[2].loadImage(id: pin.fileIds[2])
            }
        } else if strPinType == "comment" {
            
        } else if strPinType == "chat_room" {
            imgChatRoom.fileID = pin.pinId
            imgChatRoom.loadImage(id: pin.pinId, isChatRoom: true)
        }
    }
    
    fileprivate func loadStoryItems() {
        // set the "3+" label
        lblPics3Plus = UILabel()
        lblPics3Plus.text = "3+"
        lblPics3Plus.font = UIFont(name: "AvenirNext-Medium", size: 18)
        lblPics3Plus.textColor = UIColor._155155155()
        lblPics3Plus.isHidden = true
        uiviewPinView.addSubview(lblPics3Plus)
        
        uiviewStoryImages = UIView()
        uiviewPinView.addSubview(uiviewStoryImages)
        uiviewPinView.addConstraintsWithFormat("H:|-20-[v0(305)]", options: [], views: uiviewStoryImages)
        let image_0 = FaeImageView(frame: CGRect.zero)
        image_0.contentMode = .scaleAspectFill
        image_0.layer.cornerRadius = 13.5
        image_0.clipsToBounds = true
        image_0.isUserInteractionEnabled = false
        uiviewStoryImages.addSubview(image_0)
        arrImages.append(image_0)
        
        let image_1 = FaeImageView(frame: CGRect.zero)
        image_1.contentMode = .scaleAspectFill
        image_1.layer.cornerRadius = 13.5
        image_1.clipsToBounds = true
        image_1.isUserInteractionEnabled = false
        uiviewStoryImages.addSubview(image_1)
        arrImages.append(image_1)
        
        let image_2 = FaeImageView(frame: CGRect.zero)
        image_2.contentMode = .scaleAspectFill
        image_2.layer.cornerRadius = 13.5
        image_2.clipsToBounds = true
        image_2.isUserInteractionEnabled = false
        uiviewStoryImages.addSubview(image_2)
        arrImages.append(image_2)
        
        uiviewStoryImages.addConstraintsWithFormat("V:[v0(95)]-0-|", options: [], views: arrImages[0])
        uiviewStoryImages.addConstraintsWithFormat("V:[v0(95)]-0-|", options: [], views: arrImages[1])
        uiviewStoryImages.addConstraintsWithFormat("V:[v0(95)]-0-|", options: [], views: arrImages[2])
        uiviewStoryImages.addConstraintsWithFormat("H:|-0-[v0(95)]-10-[v1(95)]-10-[v2(95)]", options: [], views: arrImages[0], arrImages[1], arrImages[2])
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
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    // Interface - Initialize the position of swiped buttons
    func verticalCenterButtons() {
        
    }
    
    // handle function of pan gesture
    func handlePan(recognizer: UIPanGestureRecognizer) {
        // when the gesture begins, record the current center location
        if recognizer.state == .began {
            pointOriginalCenter = uiviewCellView.center
            verticalCenterButtons()
            // if the cell is already swiped or not
            if uiviewCellView.center.x > 150 {
                boolIsCellSWiped = true
            }
            else {
                boolIsCellSWiped = false
            }
        }
        
        // has the user dragged the item far enough?
        if recognizer.state == .changed {
            let translation = recognizer.translation(in: self)
            boolShowOnDragRelease = uiviewCellView.center.x > 70 && !boolIsCellSWiped
            if uiviewCellView.center.x <= -9 {
                // don't remove when the left side of the cell reaches -8
                uiviewCellView.center = CGPoint(x: -10, y: uiviewCellView.center.y)
            }
            else {
                uiviewCellView.center = CGPoint(x: pointOriginalCenter.x + translation.x, y:pointOriginalCenter.y)
            }
        }
        
        // the gesture ends
        if recognizer.state == .ended || recognizer.state == .failed || recognizer.state == .cancelled {
            let frameCellView = uiviewCellView.frame
            // the frame this cell had before user dragged it
            let frameOriginal = CGRect(x: -screenWidth, y: frameCellView.origin.y,
                                       width: frameCellView.width, height: frameCellView.height)
            // the frame this cell will be after user dragged it
            let frameFinish = CGRect(x: -screenWidth + finishedPositionX, y: frameCellView.origin.y,
                                     width: frameCellView.width, height: frameCellView.height)
            // the frame this cell will bounce to after user dragged it from right to left
            let frameBounce = CGRect(x: -screenWidth + 35, y: frameCellView.origin.y,
                                     width: frameCellView.width, height: frameCellView.height)
            if !boolShowOnDragRelease {
                if uiviewCellView.center.x < 0 {
                    // if the item is being swiped from right to left, bonuce back to the original location
                    UIView.animate(withDuration: 0.3, animations: {
                       self.uiviewCellView.frame = frameBounce
                    }, completion: { (finished) -> Void in
                        UIView.animate(withDuration: 0.3, animations: {self.uiviewCellView.frame = frameOriginal})
                    })
                }
                else {
                    // if the item is not being swiped enough, snap back to the original location
                    UIView.animate(withDuration: 0.3, animations: {self.uiviewCellView.frame = frameOriginal})
                }
            }
            else {
                UIView.animate(withDuration: 0.3, animations: {self.uiviewCellView.frame = frameFinish}, completion: { (finished) -> Void in
                    self.delegate?.itemSwiped(indexCell: self.indexForCurrentCell)
                })
            }
        }
    }
}
