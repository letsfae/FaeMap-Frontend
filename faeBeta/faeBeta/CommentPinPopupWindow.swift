//
//  CommentPinPopupWindow.swift
//  faeBeta
//
//  Created by Yue on 9/5/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
import GoogleMaps
import SwiftyJSON

extension FaeMapViewController {
    func loadCommentPinDetailWindow() {
        // Header
        self.uiviewCommentPinDetail = UIView(frame: CGRectMake(0, 0, self.screenWidth, 320))
        self.uiviewCommentPinDetail.layer.zPosition = 100
        self.uiviewCommentPinDetail.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(uiviewCommentPinDetail)
        self.uiviewCommentPinDetail.layer.shadowOpacity = 0.3
        self.uiviewCommentPinDetail.layer.shadowOffset = CGSize(width: 0.0, height: 10.0)
        self.uiviewCommentPinDetail.layer.shadowRadius = 10.0
        self.uiviewCommentPinDetail.layer.shadowColor = UIColor(red: 107/255, green: 105/255, blue: 105/255, alpha: 1.0).CGColor
        self.uiviewCommentPinDetail.center.y = self.uiviewCommentPinDetail.center.y - 320
        
        // Line at y = 64
        self.uiviewCommentPinUnderLine01 = UIView(frame: CGRectMake(0, 64, self.screenWidth, 1))
        self.uiviewCommentPinUnderLine01.layer.borderWidth = screenWidth
        self.uiviewCommentPinUnderLine01.layer.borderColor = UIColor(red: 200/255, green: 199/255, blue: 204/255, alpha: 1.0).CGColor
        self.uiviewCommentPinDetail.addSubview(uiviewCommentPinUnderLine01)
        
        // Line at y = 292
        self.uiviewCommentPinUnderLine02 = UIView(frame: CGRectMake(0, 292, self.screenWidth, 1))
        self.uiviewCommentPinUnderLine02.layer.borderWidth = screenWidth
        self.uiviewCommentPinUnderLine02.layer.borderColor = UIColor(red: 200/255, green: 199/255, blue: 204/255, alpha: 1.0).CGColor
        self.uiviewCommentPinDetail.addSubview(uiviewCommentPinUnderLine02)
        
        // Button 1: Back to Comment Pin List
        self.buttonBackToCommentPinLists = UIButton()
        self.buttonBackToCommentPinLists.setImage(UIImage(named: "commentPinBackToList"), forState: .Normal)
                self.buttonBackToCommentPinLists.addTarget(self, action: #selector(FaeMapViewController.actionBackToList(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.uiviewCommentPinDetail.addSubview(buttonBackToCommentPinLists)
        self.uiviewCommentPinDetail.addConstraintsWithFormat("H:|-(-24)-[v0(101)]", options: [], views: buttonBackToCommentPinLists)
        self.uiviewCommentPinDetail.addConstraintsWithFormat("V:|-33-[v0(17)]", options: [], views: buttonBackToCommentPinLists)
        
        // Button 2: Comment Pin Option
        self.buttonOptionOfCommentPin = UIButton()
        self.buttonOptionOfCommentPin.setImage(UIImage(named: "commentPinOption"), forState: .Normal)
        self.buttonOptionOfCommentPin.addTarget(self, action: #selector(FaeMapViewController.showCommentPinMoreButtonDetails(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.uiviewCommentPinDetail.addSubview(buttonOptionOfCommentPin)
        self.uiviewCommentPinDetail.addConstraintsWithFormat("H:[v0(27)]-15-|", options: [], views: buttonOptionOfCommentPin)
        self.uiviewCommentPinDetail.addConstraintsWithFormat("V:|-23-[v0(37)]", options: [], views: buttonOptionOfCommentPin)
        
        // Button 3: Comment Pin DownVote
        self.buttonCommentPinDownVote = UIButton()
        self.buttonCommentPinDownVote.setImage(UIImage(named: "commentPinDownVoteGray"), forState: .Normal)
                self.buttonCommentPinDownVote.addTarget(self, action: #selector(FaeMapViewController.actionDownVoteThisComment(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.uiviewCommentPinDetail.addSubview(buttonCommentPinDownVote)
        self.uiviewCommentPinDetail.addConstraintsWithFormat("H:|-15-[v0(25)]", options: [], views: buttonCommentPinDownVote)
        self.uiviewCommentPinDetail.addConstraintsWithFormat("V:[v0(13)]-43-|", options: [], views: buttonCommentPinDownVote)
        
        // Button 4: Comment Pin UpVote
        self.buttonCommentPinUpVote = UIButton()
        self.buttonCommentPinUpVote.setImage(UIImage(named: "commentPinUpVoteGray"), forState: .Normal)
                self.buttonCommentPinUpVote.addTarget(self, action: #selector(FaeMapViewController.actionLikeThisComment(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.uiviewCommentPinDetail.addSubview(buttonCommentPinUpVote)
        self.uiviewCommentPinDetail.addConstraintsWithFormat("H:|-116-[v0(25)]", options: [], views: buttonCommentPinUpVote)
        self.uiviewCommentPinDetail.addConstraintsWithFormat("V:[v0(13)]-43-|", options: [], views: buttonCommentPinUpVote)
        
        // Button 5: Comment Pin Like
        self.buttonCommentPinLike = UIButton()
        self.buttonCommentPinLike.setImage(UIImage(named: "commentPinLikeHollow"), forState: .Normal)
        self.buttonCommentPinLike.addTarget(self, action: #selector(FaeMapViewController.actionLikeThisComment(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.uiviewCommentPinDetail.addSubview(buttonCommentPinLike)
        self.uiviewCommentPinDetail.addConstraintsWithFormat("H:[v0(26)]-105-|", options: [], views: buttonCommentPinLike)
        self.uiviewCommentPinDetail.addConstraintsWithFormat("V:[v0(22)]-43-|", options: [], views: buttonCommentPinLike)
        
        // Button 6: Add Comment
        self.buttonCommentPinAddComment = UIButton()
        self.buttonCommentPinAddComment.setImage(UIImage(named: "commentPinAddComment"), forState: .Normal)
        //        self.buttonCommentPinAddComment.addTarget(self, action: #selector(FaeMapViewController.animationMapChatShow(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.uiviewCommentPinDetail.addSubview(buttonCommentPinAddComment)
        self.uiviewCommentPinDetail.addConstraintsWithFormat("H:[v0(26)]-14-|", options: [], views: buttonCommentPinAddComment)
        self.uiviewCommentPinDetail.addConstraintsWithFormat("V:[v0(22)]-43-|", options: [], views: buttonCommentPinAddComment)
        
        // Button 7: Drag to larger
        self.buttonCommentPinDetailDragToLargeSize = UIButton()
        self.buttonCommentPinDetailDragToLargeSize.setImage(UIImage(named: "commentPinDetailDragToLarge"), forState: .Normal)
        //        self.buttonCommentPinDetailDragToLargeSize.addTarget(self, action: #selector(FaeMapViewController.animationMapChatShow(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.uiviewCommentPinDetail.addSubview(buttonCommentPinDetailDragToLargeSize)
        self.uiviewCommentPinDetail.addConstraintsWithFormat("H:[v0(\(self.screenWidth))]", options: [], views: buttonCommentPinDetailDragToLargeSize)
        self.uiviewCommentPinDetail.addConstraintsWithFormat("V:[v0(17)]-4-|", options: [], views: buttonCommentPinDetailDragToLargeSize)
        NSLayoutConstraint(item: buttonCommentPinDetailDragToLargeSize, attribute: .CenterX, relatedBy: .Equal, toItem: self.uiviewCommentPinDetail, attribute: .CenterX, multiplier: 1.0, constant: 0).active = true
        
        // Label of Title
        self.labelCommentPinTitle = UILabel()
        self.labelCommentPinTitle.text = "Comment"
        self.labelCommentPinTitle.font = UIFont(name: "AvenirNext-Medium", size: 20)
        self.labelCommentPinTitle.textColor = UIColor(red: 89/255, green: 89/255, blue: 89/255, alpha: 1.0)
        self.labelCommentPinTitle.textAlignment = .Center
        self.uiviewCommentPinDetail.addSubview(labelCommentPinTitle)
        self.uiviewCommentPinDetail.addConstraintsWithFormat("H:[v0(92)]", options: [], views: labelCommentPinTitle)
        self.uiviewCommentPinDetail.addConstraintsWithFormat("V:|-28-[v0(27)]", options: [], views: labelCommentPinTitle)
        NSLayoutConstraint(item: labelCommentPinTitle, attribute: .CenterX, relatedBy: .Equal, toItem: self.uiviewCommentPinDetail, attribute: .CenterX, multiplier: 1.0, constant: 0).active = true
        
        // Label of Vote Count
        self.labelCommentPinVoteCount = UILabel()
        self.labelCommentPinVoteCount.text = "0"
        self.labelCommentPinVoteCount.font = UIFont(name: "PingFang SC-Semibold", size: 15)
        self.labelCommentPinVoteCount.textColor = UIColor(red: 107/255, green: 105/255, blue: 105/255, alpha: 1.0)
        self.labelCommentPinVoteCount.textAlignment = .Center
        self.uiviewCommentPinDetail.addSubview(labelCommentPinVoteCount)
        self.uiviewCommentPinDetail.addConstraintsWithFormat("H:|-48-[v0(56)]", options: [], views: labelCommentPinVoteCount)
        self.uiviewCommentPinDetail.addConstraintsWithFormat("V:[v0(21)]-40-|", options: [], views: labelCommentPinVoteCount)
        
        // Comment Pin User Avatar
        self.imageCommentPinUserAvatar = UIImageView()
        self.imageCommentPinUserAvatar.image = UIImage(named: "commentPinSampleAvatar")
        self.uiviewCommentPinDetail.addSubview(imageCommentPinUserAvatar)
        self.uiviewCommentPinDetail.addConstraintsWithFormat("H:|-15-[v0(50)]", options: [], views: imageCommentPinUserAvatar)
        self.uiviewCommentPinDetail.addConstraintsWithFormat("V:|-80-[v0(50)]", options: [], views: imageCommentPinUserAvatar)
        
        // Comment Pin Username
        self.labelCommentPinUserName = UILabel()
        self.labelCommentPinUserName.text = "Username"
        self.labelCommentPinUserName.font = UIFont(name: "AvenirNext-Medium", size: 18)
        self.labelCommentPinUserName.textColor = UIColor(red: 89/255, green: 89/255, blue: 89/255, alpha: 1.0)
        self.labelCommentPinTitle.textAlignment = .Left
        self.uiviewCommentPinDetail.addSubview(labelCommentPinUserName)
        self.uiviewCommentPinDetail.addConstraintsWithFormat("H:|-80-[v0(250)]", options: [], views: labelCommentPinUserName)
        self.uiviewCommentPinDetail.addConstraintsWithFormat("V:|-84-[v0(25)]", options: [], views: labelCommentPinUserName)
        
        // Comment Pin Timestamp
        self.labelCommentPinTimestamp = UILabel()
        self.labelCommentPinTimestamp.text = "Time"
        self.labelCommentPinTimestamp.font = UIFont(name: "AvenirNext-Medium", size: 13)
        self.labelCommentPinTimestamp.textColor = UIColor(red: 107/255, green: 105/255, blue: 105/255, alpha: 1.0)
        self.labelCommentPinTimestamp.textAlignment = .Left
        self.uiviewCommentPinDetail.addSubview(labelCommentPinTimestamp)
        self.uiviewCommentPinDetail.addConstraintsWithFormat("H:|-80-[v0(200)]", options: [], views: labelCommentPinTimestamp)
        self.uiviewCommentPinDetail.addConstraintsWithFormat("V:|-105-[v0(27)]", options: [], views: labelCommentPinTimestamp)
        
        // Comment Pin Content
        self.textviewCommentPinDetail = UITextView()
        self.textviewCommentPinDetail.text = "Content"
        self.textviewCommentPinDetail.font = UIFont(name: "AvenirNext-Regular", size: 18)
        self.textviewCommentPinDetail.textColor = UIColor(red: 89/255, green: 89/255, blue: 89/255, alpha: 1.0)
        self.textviewCommentPinDetail.userInteractionEnabled = true
        self.textviewCommentPinDetail.editable = false
        self.textviewCommentPinDetail.indicatorStyle = UIScrollViewIndicatorStyle.White
        self.uiviewCommentPinDetail.addSubview(textviewCommentPinDetail)
        self.uiviewCommentPinDetail.addConstraintsWithFormat("H:|-27-[v0(361)]", options: [], views: textviewCommentPinDetail)
        self.uiviewCommentPinDetail.addConstraintsWithFormat("V:|-140-[v0(100)]", options: [], views: textviewCommentPinDetail)
    }
    
    func loadCommentPinList() {
        self.uiviewCommentPinListBlank = UIView(frame: CGRectMake(0, 0, self.screenWidth, 320))
        self.uiviewCommentPinListBlank.layer.zPosition = 100
        self.uiviewCommentPinListBlank.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(uiviewCommentPinListBlank)
        self.uiviewCommentPinListBlank.layer.shadowOpacity = 0.3
        self.uiviewCommentPinListBlank.layer.shadowOffset = CGSize(width: 0.0, height: 10.0)
        self.uiviewCommentPinListBlank.layer.shadowRadius = 10.0
        self.uiviewCommentPinListBlank.layer.shadowColor = UIColor(red: 107/255, green: 105/255, blue: 105/255, alpha: 1.0).CGColor
        self.uiviewCommentPinListBlank.center.x -= self.screenWidth
        
        // Scrollview
        self.commentListScrollView = UIScrollView(frame: CGRectMake(0, 65, self.screenWidth, 228))
        self.uiviewCommentPinListBlank.addSubview(commentListScrollView)
        
        // Line at y = 64
        self.uiviewCommentPinListUnderLine01 = UIView(frame: CGRectMake(0, 64, self.screenWidth, 1))
        self.uiviewCommentPinListUnderLine01.layer.borderWidth = screenWidth
        self.uiviewCommentPinListUnderLine01.layer.borderColor = UIColor(red: 200/255, green: 199/255, blue: 204/255, alpha: 1.0).CGColor
        self.uiviewCommentPinListBlank.addSubview(uiviewCommentPinListUnderLine01)
        
        // Line at y = 292
        self.uiviewCommentPinListUnderLine02 = UIView(frame: CGRectMake(0, 292, self.screenWidth, 1))
        self.uiviewCommentPinListUnderLine02.layer.borderWidth = screenWidth
        self.uiviewCommentPinListUnderLine02.layer.borderColor = UIColor(red: 200/255, green: 199/255, blue: 204/255, alpha: 1.0).CGColor
        self.uiviewCommentPinListBlank.addSubview(uiviewCommentPinListUnderLine02)
        self.uiviewCommentPinListBlank.addConstraintsWithFormat("H:|-0-[v0(\(self.screenWidth))]", options: [], views: uiviewCommentPinListUnderLine02)
        self.uiviewCommentPinListBlank.addConstraintsWithFormat("V:[v0(1)]-27-|", options: [], views: uiviewCommentPinListUnderLine02)
        
        // Button: Back to Comment Detail
        self.buttonBackToCommentPinDetail = UIButton()
        self.buttonBackToCommentPinDetail.setImage(UIImage(named: "commentPinBackToCommentDetail"), forState: .Normal)
        self.buttonBackToCommentPinDetail.addTarget(self, action: #selector(FaeMapViewController.actionBackToCommentDetail(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.uiviewCommentPinListBlank.addSubview(buttonBackToCommentPinDetail)
        self.uiviewCommentPinListBlank.addConstraintsWithFormat("H:|-(-21)-[v0(101)]", options: [], views: buttonBackToCommentPinDetail)
        self.uiviewCommentPinListBlank.addConstraintsWithFormat("V:|-26-[v0(29)]", options: [], views: buttonBackToCommentPinDetail)
        
        // Button: Clear Comment Pin List
        self.buttonCommentPinListClear = UIButton()
        self.buttonCommentPinListClear.setImage(UIImage(named: "commentPinListClear"), forState: .Normal)
        self.buttonCommentPinListClear.addTarget(self, action: #selector(FaeMapViewController.actionClearCommentPinList(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.uiviewCommentPinListBlank.addSubview(buttonCommentPinListClear)
        self.uiviewCommentPinListBlank.addConstraintsWithFormat("H:[v0(42)]-15-|", options: [], views: buttonCommentPinListClear)
        self.uiviewCommentPinListBlank.addConstraintsWithFormat("V:|-30-[v0(25)]", options: [], views: buttonCommentPinListClear)
        
        // Button: Drag to larger
        self.buttonCommentPinListDragToLargeSize = UIButton(frame: CGRectMake(0, 293, self.screenWidth, 27))
        self.buttonCommentPinListDragToLargeSize.setImage(UIImage(named: "commentPinDetailDragToLarge"), forState: .Normal)
        self.buttonCommentPinListDragToLargeSize.addTarget(self, action: #selector(FaeMapViewController.actionListExpandShrink(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.uiviewCommentPinListBlank.addSubview(buttonCommentPinListDragToLargeSize)
        //self.uiviewCommentPinListBlank.addConstraintsWithFormat("H:[v0(\(self.screenWidth))]", options: [], views: buttonCommentPinListDragToLargeSize)
        //self.uiviewCommentPinListBlank.addConstraintsWithFormat("V:[v0(27)]-(-1)-|", options: [], views: buttonCommentPinListDragToLargeSize)
        //NSLayoutConstraint(item: buttonCommentPinListDragToLargeSize, attribute: .CenterX, relatedBy: .Equal, toItem: self.uiviewCommentPinListBlank, attribute: .CenterX, multiplier: 1.0, constant: 0).active = true
        let panCommentPinListDrag = UIPanGestureRecognizer(target: self, action: #selector(FaeMapViewController.panActionCommentPinListDrag(_:)))
        self.buttonCommentPinListDragToLargeSize.addGestureRecognizer(panCommentPinListDrag)
        
        // Label of Title
        self.labelCommentPinListTitle = UILabel()
        self.labelCommentPinListTitle.text = "Opened Pins"
        self.labelCommentPinListTitle.font = UIFont(name: "AvenirNext-Medium", size: 20)
        self.labelCommentPinListTitle.textColor = UIColor(red: 89/255, green: 89/255, blue: 89/255, alpha: 1.0)
        self.labelCommentPinListTitle.textAlignment = .Center
        self.uiviewCommentPinListBlank.addSubview(labelCommentPinListTitle)
        self.uiviewCommentPinListBlank.addConstraintsWithFormat("H:[v0(120)]", options: [], views: labelCommentPinListTitle)
        self.uiviewCommentPinListBlank.addConstraintsWithFormat("V:|-28-[v0(27)]", options: [], views: labelCommentPinListTitle)
        NSLayoutConstraint(item: labelCommentPinListTitle, attribute: .CenterX, relatedBy: .Equal, toItem: self.uiviewCommentPinListBlank, attribute: .CenterX, multiplier: 1.0, constant: 0).active = true
    }
    
    func actionLikeThisComment(sender: UIButton) {
        self.buttonCommentPinLike.setImage(UIImage(named: "commentPinLikeFull"), forState: .Normal)
        self.buttonCommentPinUpVote.setImage(UIImage(named: "commentPinUpVoteRed"), forState: .Normal)
        self.buttonCommentPinDownVote.setImage(UIImage(named: "commentPinDownVoteGray"), forState: .Normal)

        self.isUpVoting = true
        self.isDownVoting = false
        if let tempString = self.labelCommentPinVoteCount.text {
            self.commentPinLikeCount = Int(tempString)!
        }
    }
    
    func actionDownVoteThisComment(sender: UIButton) {
        self.buttonCommentPinLike.setImage(UIImage(named: "commentPinLikeHollow"), forState: .Normal)
        self.buttonCommentPinUpVote.setImage(UIImage(named: "commentPinUpVoteGray"), forState: .Normal)
        self.buttonCommentPinDownVote.setImage(UIImage(named: "commentPinDownVoteRed"), forState: .Normal)
        self.isUpVoting = false
        self.isDownVoting = true//test
        if let tempString = self.labelCommentPinVoteCount.text {
            self.commentPinLikeCount = Int(tempString)!
        }
    }
    
    func panActionCommentPinListDrag(pan: UIPanGestureRecognizer) {
        if pan.state == .Began {
            if self.uiviewCommentPinListBlank.frame.size.height == 320 {
                self.commentPinSizeFrom = 320
                self.commentPinSizeTo = self.screenHeight
            }
            else {
                self.commentPinSizeFrom = self.screenHeight
                self.commentPinSizeTo = 320
            }
        } else if pan.state == .Ended || pan.state == .Failed || pan.state == .Cancelled {
            let location = pan.locationInView(view)
            if abs(location.y - self.commentPinSizeFrom) >= 60 {
                UIView.animateWithDuration(0.2, animations: {
                    self.buttonCommentPinListDragToLargeSize.center.y = self.commentPinSizeTo - 13.5
                    self.uiviewCommentPinListBlank.frame.size.height = self.commentPinSizeTo
                    self.uiviewCommentPinListUnderLine02.center.y = self.commentPinSizeTo - 27.5
                    self.commentListScrollView.frame.size.height = self.commentPinSizeTo - 92
                })
            }
            else {
                UIView.animateWithDuration(0.1, animations: {
                    self.buttonCommentPinListDragToLargeSize.center.y = self.commentPinSizeFrom - 13.5
                    self.uiviewCommentPinListBlank.frame.size.height = self.commentPinSizeFrom
                    self.uiviewCommentPinListUnderLine02.center.y = self.commentPinSizeFrom - 27.5
                    self.commentListScrollView.frame.size.height = self.commentPinSizeFrom - 92
                })
            }
        } else {
            let location = pan.locationInView(view)
            if location.y >= 306.5 {
                self.buttonCommentPinListDragToLargeSize.center.y = location.y
                self.uiviewCommentPinListBlank.frame.size.height = location.y + 13.5
                self.commentListScrollView.frame.size.height = location.y - 78.5
            }
        }
    }
    
    func actionClearCommentPinList(sender: UIButton) {
        for cell in commentPinCellArray {
            cell.removeFromSuperview()
        }
        self.commentPinCellArray.removeAll()
        self.commentPinAvoidDic.removeAll()
        self.commentPinCellNumCount = 0
        self.disableTheButton(self.buttonBackToCommentPinDetail)
    }
    
    func actionToCloseOtherViews(sender: UIButton) {
        if buttonMoreOnCommentCellExpanded == true {
            self.hideCommentPinMoreButtonDetails()
        }
    }
    
    func actionBackToList(sender: UIButton!) {
        UIView.animateWithDuration(0.25, animations:({
            self.uiviewCommentPinListBlank.center.x += self.screenWidth
            self.uiviewCommentPinDetail.center.x += self.screenWidth
        }), completion: { (done: Bool) in
            if done {
                self.commentListShowed = true
                self.commentPinDetailShowed = false
            }
        })
    }
    
    func actionBackToCommentDetail(sender: UIButton!) {
        UIView.animateWithDuration(0.25, animations:({
            self.uiviewCommentPinListBlank.center.x -= self.screenWidth
            self.uiviewCommentPinDetail.center.x -= self.screenWidth
        }), completion: { (done: Bool) in
            if done {
                self.commentListShowed = false
                self.commentPinDetailShowed = true
            }
        })
    }
    
    func showCommentPinMoreButtonDetails(sender: UIButton!) {
        print("DEBUG: ")
        if buttonMoreOnCommentCellExpanded == false {
            self.buttonFakeTransparentClosingView = UIButton(frame: CGRectMake(0, 0, self.screenWidth, self.screenHeight))
            self.buttonFakeTransparentClosingView.layer.zPosition = 101
            self.view.addSubview(buttonFakeTransparentClosingView)
            self.buttonFakeTransparentClosingView.addTarget(self, action: #selector(FaeMapViewController.actionToCloseOtherViews(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            
            self.moreButtonDetailSubview = UIImageView(frame: CGRectMake(400, 57, 0, 0))
            self.moreButtonDetailSubview.image = UIImage(named: "moreButtonDetailSubview")
            self.moreButtonDetailSubview.layer.zPosition = 102
            self.view.addSubview(moreButtonDetailSubview)
            
            self.buttonShareOnCommentDetail = UIButton(frame: CGRectMake(400, 57, 0, 0))
            self.buttonShareOnCommentDetail.setImage(UIImage(named: "buttonShareOnCommentDetail"), forState: .Normal)
            self.buttonShareOnCommentDetail.layer.zPosition = 103
            self.view.addSubview(buttonShareOnCommentDetail)
            self.buttonShareOnCommentDetail.clipsToBounds = true
            self.buttonShareOnCommentDetail.alpha = 0.0
            self.buttonShareOnCommentDetail.addTarget(self, action: #selector(FaeMapViewController.actionShareComment(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            
            self.buttonSaveOnCommentDetail = UIButton(frame: CGRectMake(400, 57, 0, 0))
            self.buttonSaveOnCommentDetail.setImage(UIImage(named: "buttonSaveOnCommentDetail"), forState: .Normal)
            self.buttonSaveOnCommentDetail.layer.zPosition = 103
            self.view.addSubview(buttonSaveOnCommentDetail)
            self.buttonSaveOnCommentDetail.clipsToBounds = true
            self.buttonSaveOnCommentDetail.alpha = 0.0
            
            self.buttonReportOnCommentDetail = UIButton(frame: CGRectMake(400, 57, 0, 0))
            self.buttonReportOnCommentDetail.setImage(UIImage(named: "buttonReportOnCommentDetail"), forState: .Normal)
            self.buttonReportOnCommentDetail.layer.zPosition = 103
            self.view.addSubview(buttonReportOnCommentDetail)
            self.buttonReportOnCommentDetail.clipsToBounds = true
            self.buttonReportOnCommentDetail.alpha = 0.0
            
            
            UIView.animateWithDuration(0.25, animations: ({
                self.moreButtonDetailSubview.frame = CGRectMake(171, 57, 229, 110)
                self.buttonShareOnCommentDetail.frame = CGRectMake(192, 97, 44, 51)
                self.buttonSaveOnCommentDetail.frame = CGRectMake(262, 97, 44, 51)
                self.buttonReportOnCommentDetail.frame = CGRectMake(332, 97, 44, 51)
                self.buttonShareOnCommentDetail.alpha = 1.0
                self.buttonSaveOnCommentDetail.alpha = 1.0
                self.buttonReportOnCommentDetail.alpha = 1.0
            }))
            self.buttonMoreOnCommentCellExpanded = true
        }
        else {
            hideCommentPinMoreButtonDetails()
        }
    }
    
    func actionShareComment(sender: UIButton!) {
        print("Share Clicks!")
    }
    
    func actionListExpandShrink(sender: UIButton!) {
        if self.commentListExpand == false {
            UIView.animateWithDuration(0.25, animations: ({
                self.buttonCommentPinListDragToLargeSize.center.y = self.screenHeight - 13.5
                self.uiviewCommentPinListBlank.frame.size.height = self.screenHeight
                self.uiviewCommentPinListUnderLine02.center.y = self.screenHeight - 27.5
                self.commentListScrollView.frame.size.height = self.screenHeight - 91
            }))
            self.commentListExpand = true
        }
        else {
            UIView.animateWithDuration(0.25, animations: ({
                self.uiviewCommentPinListBlank.frame.size.height = 320
                self.buttonCommentPinListDragToLargeSize.center.y = 306.5
                self.uiviewCommentPinListUnderLine02.center.y = 292.5
                self.commentListScrollView.frame.size.height = 228
            }))
            self.commentListExpand = false
        }
    }
    
    func actionJumpToDetail(sender: UIButton!) {
        actionBackToCommentDetail(self.buttonBackToCommentPinDetail)
        let row = sender.tag
        self.labelCommentPinUserName.text = self.commentPinCellArray[row].userID
        self.labelCommentPinTimestamp.text = self.commentPinCellArray[row].time.text
        self.textviewCommentPinDetail.text = self.commentPinCellArray[row].content.text
    }
    
    func hideCommentPinMoreButtonDetails() {
        buttonMoreOnCommentCellExpanded = false
        UIView.animateWithDuration(0.25, animations: ({
            self.moreButtonDetailSubview.frame = CGRectMake(400, 57, 0, 0)
            self.buttonShareOnCommentDetail.frame = CGRectMake(400, 57, 0, 0)
            self.buttonSaveOnCommentDetail.frame = CGRectMake(400, 57, 0, 0)
            self.buttonReportOnCommentDetail.frame = CGRectMake(400, 57, 0, 0)
            self.buttonShareOnCommentDetail.alpha = 0.0
            self.buttonSaveOnCommentDetail.alpha = 0.0
            self.buttonReportOnCommentDetail.alpha = 0.0
        }))
        buttonFakeTransparentClosingView.removeFromSuperview()
    }
    
    func addTagCommentPinCell(cell: CommentPinListCell, commentID: Int) {
        cell.jumpToDetail.tag = self.commentPinCellNumCount
        cell.deleteButton.tag = self.commentPinCellNumCount
        cell.commentID = commentID
        self.commentPinAvoidDic[commentID] = self.commentPinCellNumCount
    }
    
    func disableTheButton(button: UIButton) {
        let origImage = button.imageView?.image
        let tintedImage = origImage?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        button.setImage(tintedImage, forState: .Normal)
        button.tintColor = UIColor.lightGrayColor()
        button.userInteractionEnabled = false
    }
    
    func deleteCommentPinCell(sender: UIButton!) {
        print("Avoid Dic before deleting: \(self.commentPinAvoidDic)")
        
        let commentID = self.commentPinCellArray[sender.tag].commentID
        print("Deleted sender tag: \(sender.tag)")
        
        let rowToDelete = sender.tag
        
        if self.commentPinCellNumCount == 1 {
            self.commentPinCellNumCount = 0
            self.disableTheButton(self.buttonBackToCommentPinDetail)
            UIView.animateWithDuration(0.25, animations: ({
                self.commentPinCellArray.first!.center.x -= self.screenWidth
                self.commentListScrollView.contentSize.height -= 76
            }), completion: {(done: Bool) in
                self.commentPinCellArray.first!.removeFromSuperview()
                self.commentPinCellArray.removeAll()
            })
        }
        
        else if self.commentPinCellNumCount >= 2 {
            self.commentPinCellNumCount -= 1
            UIView.animateWithDuration(0.25, animations: ({
                self.commentPinCellArray[rowToDelete].center.x -= self.screenWidth
                self.commentListScrollView.contentSize.height -= 76
            }), completion: {(done: Bool) in
                let m = rowToDelete + 1
                let n = self.commentPinCellArray.count - 1
                if m < n {
                    for i in m...n {
                        self.commentPinCellArray[i].jumpToDetail.tag -= 1
                        self.commentPinCellArray[i].deleteButton.tag -= 1
                        UIView.animateWithDuration(0.25, animations: ({
                            self.commentPinCellArray[i].center.y -= 76
                        }))
                    }
                }
                else if m == n {
                    self.commentPinCellArray[m].jumpToDetail.tag -= 1
                    self.commentPinCellArray[m].deleteButton.tag -= 1
                    UIView.animateWithDuration(0.25, animations: ({
                        self.commentPinCellArray[m].center.y -= 76
                    }))
                }
                self.commentPinCellArray[rowToDelete].removeFromSuperview()
                self.commentPinCellArray.removeAtIndex(rowToDelete)
            })
        }
        
        if let aDictionaryIndex = self.commentPinAvoidDic.indexForKey(commentID) {
            // This will remove the key/value pair from the dictionary and return it as a tuple pair.
            let (key, value) = self.commentPinAvoidDic.removeAtIndex(aDictionaryIndex)
            print("Deleted cell in avoid dic: [\(key): \(value)]")
        }
        
        print("Avoid Dic after deleting: \(self.commentPinAvoidDic)")
        
        //                let m = sender.tag + 1
        //                let n = self.commentPinCellArray.count - 1
        //                if m <= n {
        //                    for i in m...n {
        //                        self.commentPinCellArray[i].jumpToDetail.tag -= 1
        //                        self.commentPinCellArray[i].deleteButton.tag -= 1
        //                        UIView.animateWithDuration(0.25, animations: ({
        //                            self.commentPinCellArray[i].center.y -= 76
        //                        }))
        //                    }
        //                }
        //                UIView.animateWithDuration(0.25, animations: ({
        //                    if self.commentPinCellArray.count <= 3 {
        //                        self.commentListScrollView.frame.size.height = 228
        //                    }
        //                    else {
        //                        self.commentListScrollView.frame.size.height -= 76
        //                    }
        //                }), completion: {(done: Bool) in
        //
        //                })
        //                self.commentPinCellArray[sender.tag].removeFromSuperview()
        //                self.commentPinCellArray.removeAtIndex(sender.tag)

    }
}
