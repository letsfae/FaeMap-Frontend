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
    // Load comment pin detail window
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
        self.uiviewCommentPinDetail.center.y -= self.uiviewCommentPinDetail.frame.size.height
        
        // Line at y = 64
        self.uiviewCommentPinUnderLine01 = UIView(frame: CGRectMake(0, 64, self.screenWidth, 1))
        self.uiviewCommentPinUnderLine01.layer.borderWidth = screenWidth
        self.uiviewCommentPinUnderLine01.layer.borderColor = UIColor(red: 200/255, green: 199/255, blue: 204/255, alpha: 1.0).CGColor
        self.uiviewCommentPinDetail.addSubview(uiviewCommentPinUnderLine01)
        
        // Button 0: Back to Map
        self.buttonCommentPinBackToMap = UIButton()
        self.buttonCommentPinBackToMap.setImage(UIImage(named: "commentPinBackToMap"), forState: .Normal)
        self.buttonCommentPinBackToMap.addTarget(self, action: #selector(FaeMapViewController.actionBackToMap(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.uiviewCommentPinDetail.addSubview(buttonCommentPinBackToMap)
        self.uiviewCommentPinDetail.addConstraintsWithFormat("H:|-(-24)-[v0(101)]", options: [], views: buttonCommentPinBackToMap)
        self.uiviewCommentPinDetail.addConstraintsWithFormat("V:|-28-[v0(26)]", options: [], views: buttonCommentPinBackToMap)
        self.buttonCommentPinBackToMap.alpha = 0.0
        
        // Button 1: Back to Comment Pin List
        self.buttonBackToCommentPinLists = UIButton()
        self.buttonBackToCommentPinLists.setImage(UIImage(named: "commentPinBackToList"), forState: .Normal)
                self.buttonBackToCommentPinLists.addTarget(self, action: #selector(FaeMapViewController.actionBackToList(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.uiviewCommentPinDetail.addSubview(buttonBackToCommentPinLists)
        self.uiviewCommentPinDetail.addConstraintsWithFormat("H:|-(-24)-[v0(101)]", options: [], views: buttonBackToCommentPinLists)
        self.uiviewCommentPinDetail.addConstraintsWithFormat("V:|-32-[v0(18)]", options: [], views: buttonBackToCommentPinLists)
        
        // Button 2: Comment Pin Option
        self.buttonOptionOfCommentPin = UIButton()
        self.buttonOptionOfCommentPin.setImage(UIImage(named: "commentPinOption"), forState: .Normal)
        self.buttonOptionOfCommentPin.addTarget(self, action: #selector(FaeMapViewController.showCommentPinMoreButtonDetails(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.uiviewCommentPinDetail.addSubview(buttonOptionOfCommentPin)
        self.uiviewCommentPinDetail.addConstraintsWithFormat("H:[v0(27)]-15-|", options: [], views: buttonOptionOfCommentPin)
        self.uiviewCommentPinDetail.addConstraintsWithFormat("V:|-23-[v0(37)]", options: [], views: buttonOptionOfCommentPin)
        
        // ScrollView at 65
        self.commentDetailFullBoardScrollView = UIScrollView(frame: CGRectMake(0, 65, self.screenWidth, 228))
        self.uiviewCommentPinDetail.addSubview(self.commentDetailFullBoardScrollView)
        self.commentDetailFullBoardScrollView.scrollEnabled = false
        self.commentDetailFullBoardScrollView.contentSize.height = 228
        self.commentDetailFullBoardScrollView.showsVerticalScrollIndicator = false
        
        // Line at y = 292
        self.uiviewCommentPinUnderLine02 = UIView(frame: CGRectMake(0, 292, self.screenWidth, 1))
        self.uiviewCommentPinUnderLine02.backgroundColor = UIColor(red: 241/255, green: 241/255, blue: 241/255, alpha: 1.0)
        //red: 200/255, green: 199/255, blue: 204/255, alpha: 1.0
        self.commentDetailFullBoardScrollView.addSubview(uiviewCommentPinUnderLine02)
        self.commentDetailFullBoardScrollView.delaysContentTouches = false
        
        // Main buttons' container of comment pin detail
        self.uiviewCommentPinDetailMainButtons = UIView(frame: CGRectMake(0, 190, self.screenWidth, 22))
        self.commentDetailFullBoardScrollView.addSubview(uiviewCommentPinDetailMainButtons)
        
        // Table comments for comment
        self.tableCommentsForComment = UITableView(frame: CGRectMake(0, 353, self.screenWidth, 420))
        self.tableCommentsForComment.delegate = self
        self.tableCommentsForComment.dataSource = self
        self.tableCommentsForComment.allowsSelection = false
        self.tableCommentsForComment.delaysContentTouches = false
        self.tableCommentsForComment.registerClass(CommentPinCommentsCell.self, forCellReuseIdentifier: "commentPinCommentsCell")
        self.tableCommentsForComment.scrollEnabled = false
        self.commentDetailFullBoardScrollView.addSubview(tableCommentsForComment)
        
        // Textview width based on different resolutions
        var textViewWidth: CGFloat = 0
        if self.screenWidth == 414 { // 5.5
            textViewWidth = 360
        }
        else if self.screenWidth == 320 { // 4.0
            textViewWidth = 266
        }
        else if self.screenWidth == 375 { // 4.7
            textViewWidth = 321
        }
        
        // Textview of comment pin detail
        self.textviewCommentPinDetail = UITextView(frame: CGRectMake(27, 75, textViewWidth, 100))
        self.textviewCommentPinDetail.text = "Content"
        self.textviewCommentPinDetail.font = UIFont(name: "AvenirNext-Regular", size: 18)
        self.textviewCommentPinDetail.textColor = UIColor(red: 89/255, green: 89/255, blue: 89/255, alpha: 1.0)
        self.textviewCommentPinDetail.userInteractionEnabled = true
        self.textviewCommentPinDetail.editable = false
        self.textviewCommentPinDetail.textContainerInset = UIEdgeInsetsZero
        self.textviewCommentPinDetail.indicatorStyle = UIScrollViewIndicatorStyle.White
        self.commentDetailFullBoardScrollView.addSubview(textviewCommentPinDetail)
        
        // View to hold three buttons
        self.uiviewCommentDetailThreeButtons = UIView(frame: CGRectMake(0, 311, self.screenWidth, 42))
        self.commentDetailFullBoardScrollView.addSubview(uiviewCommentDetailThreeButtons)
        
        let widthOfThreeButtons = self.screenWidth / 3
        
        // Three buttons bottom gray line
        self.uiviewGrayBaseLine = UIView()
        self.uiviewGrayBaseLine.layer.borderWidth = 1.0
        self.uiviewGrayBaseLine.layer.borderColor = UIColor(red: 200/255, green: 199/255, blue: 204/255, alpha: 1.0).CGColor
        self.uiviewCommentDetailThreeButtons.addSubview(uiviewGrayBaseLine)
        self.uiviewCommentDetailThreeButtons.addConstraintsWithFormat("H:|-0-[v0(\(self.screenWidth))]", options: [], views: uiviewGrayBaseLine)
        self.uiviewCommentDetailThreeButtons.addConstraintsWithFormat("V:[v0(1)]-0-|", options: [], views: uiviewGrayBaseLine)
        
        // Three buttons bottom sliding red line
        self.uiviewRedSlidingLine = UIView(frame: CGRectMake(0, 40, widthOfThreeButtons, 2))
        self.uiviewRedSlidingLine.layer.borderWidth = 1.0
        self.uiviewRedSlidingLine.layer.borderColor = UIColor(red: 249/255, green: 90/255, blue: 90/255, alpha: 1.0).CGColor
        self.uiviewCommentDetailThreeButtons.addSubview(uiviewRedSlidingLine)
        
        // "Comments" of this uiview
        self.buttonCommentDetailViewComments = UIButton()
        self.buttonCommentDetailViewComments.setImage(UIImage(named: "commentDetailThreeButtonComments"), forState: .Normal)
        self.buttonCommentDetailViewComments.addTarget(self, action: #selector(FaeMapViewController.animationRedSlidingLine(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.uiviewCommentDetailThreeButtons.addSubview(buttonCommentDetailViewComments)
        self.buttonCommentDetailViewComments.tag = 1
        self.uiviewCommentDetailThreeButtons.addConstraintsWithFormat("V:|-0-[v0(42)]", options: [], views: buttonCommentDetailViewComments)
        
        // "Active" of this uiview
        self.buttonCommentDetailViewActive = UIButton()
        self.buttonCommentDetailViewActive.setImage(UIImage(named: "commentDetailThreeButtonActive"), forState: .Normal)
        self.buttonCommentDetailViewActive.addTarget(self, action: #selector(FaeMapViewController.animationRedSlidingLine(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.uiviewCommentDetailThreeButtons.addSubview(buttonCommentDetailViewActive)
        self.buttonCommentDetailViewActive.tag = 3
        self.uiviewCommentDetailThreeButtons.addConstraintsWithFormat("V:|-0-[v0(42)]", options: [], views: buttonCommentDetailViewActive)
        
        // "People" of this uiview
        self.buttonCommentDetailViewPeople = UIButton()
        self.buttonCommentDetailViewPeople.setImage(UIImage(named: "commentDetailThreeButtonPeople"), forState: .Normal)
        self.buttonCommentDetailViewPeople.addTarget(self, action: #selector(FaeMapViewController.animationRedSlidingLine(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.uiviewCommentDetailThreeButtons.addSubview(buttonCommentDetailViewPeople)
        self.buttonCommentDetailViewPeople.tag = 5
        self.uiviewCommentDetailThreeButtons.addConstraintsWithFormat("V:|-0-[v0(42)]", options: [], views: buttonCommentDetailViewPeople)
        
        self .uiviewCommentDetailThreeButtons.addConstraintsWithFormat("H:|-0-[v0(\(widthOfThreeButtons))]-0-[v1(\(widthOfThreeButtons))]-0-[v2(\(widthOfThreeButtons))]", options: [], views: buttonCommentDetailViewComments, buttonCommentDetailViewActive, buttonCommentDetailViewPeople)
        
        // Label of Vote Count
        self.labelCommentPinVoteCount = UILabel()
        self.labelCommentPinVoteCount.text = "0"
        self.labelCommentPinVoteCount.font = UIFont(name: "PingFang SC-Semibold", size: 15)
        self.labelCommentPinVoteCount.textColor = UIColor(red: 107/255, green: 105/255, blue: 105/255, alpha: 1.0)
        self.labelCommentPinVoteCount.textAlignment = .Center
        self.uiviewCommentPinDetailMainButtons.addSubview(labelCommentPinVoteCount)
        self.uiviewCommentPinDetailMainButtons.addConstraintsWithFormat("H:|-42-[v0(56)]", options: [], views: labelCommentPinVoteCount)
        self.uiviewCommentPinDetailMainButtons.addConstraintsWithFormat("V:[v0(22)]-0-|", options: [], views: labelCommentPinVoteCount)
        
        // Button 3: Comment Pin DownVote
        self.buttonCommentPinDownVote = UIButton()
        self.buttonCommentPinDownVote.setImage(UIImage(named: "commentPinDownVoteGray"), forState: .Normal)
                self.buttonCommentPinDownVote.addTarget(self, action: #selector(FaeMapViewController.actionDownVoteThisComment(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.uiviewCommentPinDetailMainButtons.addSubview(buttonCommentPinDownVote)
        self.uiviewCommentPinDetailMainButtons.addConstraintsWithFormat("H:|-0-[v0(53)]", options: [], views: buttonCommentPinDownVote)
        self.uiviewCommentPinDetailMainButtons.addConstraintsWithFormat("V:[v0(22)]-0-|", options: [], views: buttonCommentPinDownVote)
        
        // Button 4: Comment Pin UpVote
        self.buttonCommentPinUpVote = UIButton()
        self.buttonCommentPinUpVote.setImage(UIImage(named: "commentPinUpVoteGray"), forState: .Normal)
                self.buttonCommentPinUpVote.addTarget(self, action: #selector(FaeMapViewController.actionLikeThisComment(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.uiviewCommentPinDetailMainButtons.addSubview(buttonCommentPinUpVote)
        self.uiviewCommentPinDetailMainButtons.addConstraintsWithFormat("H:|-91-[v0(53)]", options: [], views: buttonCommentPinUpVote)
        self.uiviewCommentPinDetailMainButtons.addConstraintsWithFormat("V:[v0(22)]-0-|", options: [], views: buttonCommentPinUpVote)
        
        // Button 5: Comment Pin Like
        self.buttonCommentPinLike = UIButton()
        self.buttonCommentPinLike.setImage(UIImage(named: "commentPinLikeHollow"), forState: .Normal)
        self.buttonCommentPinLike.addTarget(self, action: #selector(FaeMapViewController.actionLikeThisComment(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.uiviewCommentPinDetailMainButtons.addSubview(buttonCommentPinLike)
        self.uiviewCommentPinDetailMainButtons.addConstraintsWithFormat("H:[v0(56)]-90-|", options: [], views: buttonCommentPinLike)
        self.uiviewCommentPinDetailMainButtons.addConstraintsWithFormat("V:[v0(22)]-0-|", options: [], views: buttonCommentPinLike)
        
        // Button 6: Add Comment
        self.buttonCommentPinAddComment = UIButton()
        self.buttonCommentPinAddComment.setImage(UIImage(named: "commentPinAddComment"), forState: .Normal)
                self.buttonCommentPinAddComment.addTarget(self, action: #selector(FaeMapViewController.actionReplyToThisComment(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.uiviewCommentPinDetailMainButtons.addSubview(buttonCommentPinAddComment)
        self.uiviewCommentPinDetailMainButtons.addConstraintsWithFormat("H:[v0(56)]-0-|", options: [], views: buttonCommentPinAddComment)
        self.uiviewCommentPinDetailMainButtons.addConstraintsWithFormat("V:[v0(22)]-0-|", options: [], views: buttonCommentPinAddComment)
        
        // Button 7: Drag to larger
        self.buttonCommentPinDetailDragToLargeSize = UIButton()
        self.buttonCommentPinDetailDragToLargeSize.backgroundColor = UIColor.whiteColor()
        self.buttonCommentPinDetailDragToLargeSize.setImage(UIImage(named: "commentPinDetailDragToLarge"), forState: .Normal)
        //        self.buttonCommentPinDetailDragToLargeSize.addTarget(self, action: #selector(FaeMapViewController.animationMapChatShow(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.uiviewCommentPinDetail.addSubview(buttonCommentPinDetailDragToLargeSize)
        self.uiviewCommentPinDetail.addConstraintsWithFormat("H:[v0(\(self.screenWidth))]", options: [], views: buttonCommentPinDetailDragToLargeSize)
        self.uiviewCommentPinDetail.addConstraintsWithFormat("V:[v0(26)]-0-|", options: [], views: buttonCommentPinDetailDragToLargeSize)
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
        
        // Comment Pin User Avatar
        self.imageCommentPinUserAvatar = UIImageView()
        self.imageCommentPinUserAvatar.image = UIImage(named: "commentPinSampleAvatar")
        self.commentDetailFullBoardScrollView.addSubview(imageCommentPinUserAvatar)
        self.commentDetailFullBoardScrollView.addConstraintsWithFormat("H:|-15-[v0(50)]", options: [], views: imageCommentPinUserAvatar)
        self.commentDetailFullBoardScrollView.addConstraintsWithFormat("V:|-15-[v0(50)]", options: [], views: imageCommentPinUserAvatar)
        
        // Comment Pin Username
        self.labelCommentPinUserName = UILabel()
        self.labelCommentPinUserName.text = "Username"
        self.labelCommentPinUserName.font = UIFont(name: "AvenirNext-Medium", size: 18)
        self.labelCommentPinUserName.textColor = UIColor(red: 89/255, green: 89/255, blue: 89/255, alpha: 1.0)
        self.labelCommentPinTitle.textAlignment = .Left
        self.commentDetailFullBoardScrollView.addSubview(labelCommentPinUserName)
        self.commentDetailFullBoardScrollView.addConstraintsWithFormat("H:|-80-[v0(250)]", options: [], views: labelCommentPinUserName)
        self.commentDetailFullBoardScrollView.addConstraintsWithFormat("V:|-19-[v0(25)]", options: [], views: labelCommentPinUserName)
        
        // Timestamp of comment pin detail
        self.labelCommentPinTimestamp = UILabel()
        self.labelCommentPinTimestamp.text = "Time"
        self.labelCommentPinTimestamp.font = UIFont(name: "AvenirNext-Medium", size: 13)
        self.labelCommentPinTimestamp.textColor = UIColor(red: 107/255, green: 105/255, blue: 105/255, alpha: 1.0)
        self.labelCommentPinTimestamp.textAlignment = .Left
        self.commentDetailFullBoardScrollView.addSubview(labelCommentPinTimestamp)
        self.commentDetailFullBoardScrollView.addConstraintsWithFormat("H:|-80-[v0(200)]", options: [], views: labelCommentPinTimestamp)
        self.commentDetailFullBoardScrollView.addConstraintsWithFormat("V:|-40-[v0(27)]", options: [], views: labelCommentPinTimestamp)
        
        // Cancel all the touch down delays for uibutton caused by tableview's subviews
        for view in self.tableCommentsForComment.subviews {
            if view is UIScrollView {
                (view as? UIScrollView)!.delaysContentTouches = false
                break
            }
        }
    }
    
    // Load comment pin list
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
        
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(FaeMapViewController.actionBackToCommentDetail(_:)))
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(FaeMapViewController.actionBackToList(_:)))
        let upSwipe = UISwipeGestureRecognizer(target: self, action: #selector(FaeMapViewController.shrinkCommentList))
        let downSwipe = UISwipeGestureRecognizer(target: self, action: #selector(FaeMapViewController.expandCommentList))
        
        leftSwipe.direction = .Left
        rightSwipe.direction = .Right
        upSwipe.direction = .Up
        downSwipe.direction = .Down
        
        self.uiviewCommentPinListBlank.addGestureRecognizer(leftSwipe)
        self.uiviewCommentPinListBlank.addGestureRecognizer(upSwipe)
        self.uiviewCommentPinListBlank.addGestureRecognizer(downSwipe)
        self.uiviewCommentPinDetail.addGestureRecognizer(rightSwipe)
        
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
    
    // Animation of the red sliding line
    func animationRedSlidingLine(sender: UIButton) {
        let tag = CGFloat(sender.tag)
        let centerAtOneThird = self.screenWidth / 6
        let targetCenter = CGFloat(tag * centerAtOneThird)
        print("animated red line")
        UIView.animateWithDuration(0.25, animations:({
            self.uiviewRedSlidingLine.center.x = targetCenter
        }), completion: { (done: Bool) in
            if done {
                
            }
        })
    }
    
    // Like and upvote comment pin
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
    
    // Down vote comment pin
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
    
    // Pan gesture for dragging comment pin list dragging button
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
    
    // Reset comment pin list window and remove all saved data
    func actionClearCommentPinList(sender: UIButton) {
        for cell in commentPinCellArray {
            cell.removeFromSuperview()
        }
        self.commentPinCellArray.removeAll()
        self.commentPinAvoidDic.removeAll()
        self.commentPinCellNumCount = 0
        self.disableTheButton(self.buttonBackToCommentPinDetail)
    }
    
    // Close more options button when it is open, the subview is under it
    func actionToCloseOtherViews(sender: UIButton) {
        if buttonMoreOnCommentCellExpanded == true {
            self.hideCommentPinMoreButtonDetails()
        }
    }
    
    // Back to comment pin list window when in detail window
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
    
    // Back to comment pin detail window when in pin list window
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
    
    // Show more options button in comment pin detail window
    func showCommentPinMoreButtonDetails(sender: UIButton!) {
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
    
    // When clicking share button in comment pin detail window's more options button
    func actionShareComment(sender: UIButton!) {
        print("Share Clicks!")
    }
    
    // Expand or shrink comment pin list
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
    
    // Shrink comment pin list
    func shrinkCommentList() {
        if self.commentListExpand {
            UIView.animateWithDuration(0.25, animations: ({
                self.uiviewCommentPinListBlank.frame.size.height = 320
                self.buttonCommentPinListDragToLargeSize.center.y = 306.5
                self.uiviewCommentPinListUnderLine02.center.y = 292.5
                self.commentListScrollView.frame.size.height = 228
            }))
            self.commentListExpand = false
        }
    }
    
    // Expand comment pin list
    func expandCommentList() {
        if self.commentListExpand == false {
            UIView.animateWithDuration(0.25, animations: ({
                self.buttonCommentPinListDragToLargeSize.center.y = self.screenHeight - 13.5
                self.uiviewCommentPinListBlank.frame.size.height = self.screenHeight
                self.uiviewCommentPinListUnderLine02.center.y = self.screenHeight - 27.5
                self.commentListScrollView.frame.size.height = self.screenHeight - 91
            }))
            self.commentListExpand = true
        }
    }
    
    // When clicking a cell in comment pin list, it jumps to its detail window
    func actionJumpToDetail(sender: UIButton!) {
        actionBackToCommentDetail(self.buttonBackToCommentPinDetail)
        let row = sender.tag
        self.labelCommentPinUserName.text = self.commentPinCellArray[row].userID
        self.labelCommentPinTimestamp.text = self.commentPinCellArray[row].time.text
        self.textviewCommentPinDetail.text = self.commentPinCellArray[row].content.text
    }
    
    // Hide comment pin more options' button
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
    
    // Add line number to comment pin list cell, make it trackable when deleting a cell
    func addTagCommentPinCell(cell: CommentPinListCell, commentID: Int) {
        cell.jumpToDetail.tag = self.commentPinCellNumCount
        cell.deleteButton.tag = self.commentPinCellNumCount
        cell.commentID = commentID
        self.commentPinAvoidDic[commentID] = self.commentPinCellNumCount
    }
    
    // Disable a button, make it unclickable
    func disableTheButton(button: UIButton) {
        let origImage = button.imageView?.image
        let tintedImage = origImage?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        button.setImage(tintedImage, forState: .Normal)
        button.tintColor = UIColor.lightGrayColor()
        button.userInteractionEnabled = false
    }
    
    // Delete comment pin list cell, ### still has bug ###
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

    }
    
    // Show comment pin detail window
    func showCommentPinDetail() {
        if self.uiviewCommentPinDetail != nil {
            self.uiviewCommentPinDetail.frame = CGRectMake(0, -320, self.screenWidth, 320)
            self.navigationController?.navigationBar.hidden = true
            UIView.animateWithDuration(0.25, animations: ({
                self.uiviewCommentPinDetail.center.y += self.uiviewCommentPinDetail.frame.size.height
            }), completion: { (done: Bool) in
                if done {
                    self.commentPinDetailShowed = true
                    self.commentListShowed = false
                }
            })
        }
    }
    
    // Hide comment pin detail window
    func hideCommentPinDetail() {
        if self.uiviewCommentPinDetail != nil {
            if self.commentPinDetailShowed {
                UIView.animateWithDuration(0.25, animations: ({
                    self.uiviewCommentPinDetail.center.y -= self.uiviewCommentPinDetail.frame.size.height
                }), completion: { (done: Bool) in
                    if done {
                        self.navigationController?.navigationBar.hidden = false
                        self.commentPinDetailShowed = false
                        self.commentListShowed = false
                    }
                })
            }
            if self.commentListShowed {
                UIView.animateWithDuration(0.25, animations: ({
                    self.uiviewCommentPinListBlank.center.y -= self.uiviewCommentPinListBlank.frame.size.height
                }), completion: { (done: Bool) in
                    if done {
                        self.navigationController?.navigationBar.hidden = false
                        self.commentPinDetailShowed = false
                        self.commentListShowed = false
                        self.uiviewCommentPinListBlank.frame = CGRectMake(-self.screenWidth, 0, self.screenWidth, 320)
                        self.uiviewCommentPinDetail.frame = CGRectMake(0, -320, self.screenWidth, 320)
                    }
                })
            }
        }
    }
    
    // When clicking reply button in comment pin detail window
    func actionReplyToThisComment(sender: UIButton) {
        
        let numLines = Int(self.textviewCommentPinDetail.contentSize.height / self.textviewCommentPinDetail.font!.lineHeight)
        let diffHeight: CGFloat = self.textviewCommentPinDetail.contentSize.height - self.textviewCommentPinDetail.frame.size.height
        self.textviewCommentPinDetail.scrollEnabled = false
        self.commentDetailFullBoardScrollView.scrollEnabled = true
        UIView.animateWithDuration(0.25, animations: ({
            self.buttonBackToCommentPinLists.alpha = 0.0
            self.buttonCommentPinBackToMap.alpha = 1.0
            self.uiviewCommentPinDetail.frame.size.height = self.screenHeight
            self.uiviewCommentPinUnderLine02.center.y = self.screenHeight - 28
            self.commentDetailFullBoardScrollView.frame.size.height = self.screenHeight - 155
            if numLines > 4 {
                self.uiviewCommentPinDetailMainButtons.center.y += diffHeight
                self.textviewCommentPinDetail.frame.size.height += diffHeight
                self.commentDetailFullBoardScrollView.contentSize.height = 420 + 281 + diffHeight // 420 is table height, 281 is fixed
            }
            else {
                self.commentDetailFullBoardScrollView.contentSize.height = 420 + 281 // 420 is table height, 281 is fixed
            }
        }), completion: { (done: Bool) in
            if done {
                
            }
        })
    }
    
    func actionBackToMap(sender: UIButton) {
        UIView.animateWithDuration(0.25, animations: ({
            self.uiviewCommentPinDetail.center.y -= self.screenHeight
            self.buttonBackToCommentPinLists.alpha = 1.0
            self.buttonCommentPinBackToMap.alpha = 0.0
        }), completion: { (done: Bool) in
            if done {
                self.commentPinDetailShowed = false
                self.textviewCommentPinDetail.scrollEnabled = true
                self.textviewCommentPinDetail.frame.size.height = 100
                self.uiviewCommentPinDetailMainButtons.frame.origin.y = 190
                self.commentDetailFullBoardScrollView.scrollEnabled = false
                self.uiviewCommentPinDetail.frame.size.height = 320
                self.commentDetailFullBoardScrollView.frame.size.height = 228
                self.commentDetailFullBoardScrollView.contentSize.height = 228
                
            }
        })
    }
}
