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
        uiviewCommentPinDetail = UIView(frame: CGRectMake(0, 0, screenWidth, 320))
        uiviewCommentPinDetail.backgroundColor = UIColor.whiteColor()
        uiviewCommentPinDetail.center.y -= uiviewCommentPinDetail.frame.size.height
        uiviewCommentPinDetail.layer.shadowColor = UIColor(red: 107/255, green: 105/255, blue: 105/255, alpha: 1.0).CGColor
        uiviewCommentPinDetail.layer.shadowOffset = CGSize(width: 0.0, height: 10.0)
        uiviewCommentPinDetail.layer.shadowOpacity = 0.3
        uiviewCommentPinDetail.layer.shadowRadius = 10.0
        uiviewCommentPinDetail.layer.zPosition = 100
        self.view.addSubview(uiviewCommentPinDetail)
        
        // Line at y = 64
        uiviewCommentPinUnderLine01 = UIView(frame: CGRectMake(0, 64, screenWidth, 1))
        uiviewCommentPinUnderLine01.layer.borderWidth = screenWidth
        uiviewCommentPinUnderLine01.layer.borderColor = UIColor(red: 200/255, green: 199/255, blue: 204/255, alpha: 1.0).CGColor
        uiviewCommentPinDetail.addSubview(uiviewCommentPinUnderLine01)
        
        // Line at y = 292
        uiviewCommentPinUnderLine02 = UIView(frame: CGRectMake(0, 292, screenWidth, 1))
        uiviewCommentPinUnderLine02.backgroundColor = UIColor(red: 200/255, green: 199/255, blue: 204/255, alpha: 1.0)
        uiviewCommentPinDetail.addSubview(uiviewCommentPinUnderLine02)
        
        // Button 0: Back to Map
        buttonCommentPinBackToMap = UIButton()
        buttonCommentPinBackToMap.setImage(UIImage(named: "commentPinBackToMap"), forState: .Normal)
        buttonCommentPinBackToMap.addTarget(self, action: #selector(FaeMapViewController.actionBackToMap(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        uiviewCommentPinDetail.addSubview(buttonCommentPinBackToMap)
        uiviewCommentPinDetail.addConstraintsWithFormat("H:|-(-24)-[v0(101)]", options: [], views: buttonCommentPinBackToMap)
        uiviewCommentPinDetail.addConstraintsWithFormat("V:|-28-[v0(26)]", options: [], views: buttonCommentPinBackToMap)
        buttonCommentPinBackToMap.alpha = 0.0
        
        // Button 1: Back to Comment Pin List
        buttonBackToCommentPinLists = UIButton()
        buttonBackToCommentPinLists.setImage(UIImage(named: "commentPinBackToList"), forState: .Normal)
                buttonBackToCommentPinLists.addTarget(self, action: #selector(FaeMapViewController.actionBackToList(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        uiviewCommentPinDetail.addSubview(buttonBackToCommentPinLists)
        uiviewCommentPinDetail.addConstraintsWithFormat("H:|-(-24)-[v0(101)]", options: [], views: buttonBackToCommentPinLists)
        uiviewCommentPinDetail.addConstraintsWithFormat("V:|-32-[v0(18)]", options: [], views: buttonBackToCommentPinLists)
        
        // Button 2: Comment Pin Option
        buttonOptionOfCommentPin = UIButton()
        buttonOptionOfCommentPin.setImage(UIImage(named: "commentPinOption"), forState: .Normal)
        buttonOptionOfCommentPin.addTarget(self, action: #selector(FaeMapViewController.showCommentPinMoreButtonDetails(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        uiviewCommentPinDetail.addSubview(buttonOptionOfCommentPin)
        uiviewCommentPinDetail.addConstraintsWithFormat("H:[v0(27)]-15-|", options: [], views: buttonOptionOfCommentPin)
        uiviewCommentPinDetail.addConstraintsWithFormat("V:|-23-[v0(37)]", options: [], views: buttonOptionOfCommentPin)
        
        // ScrollView at 65
        commentDetailFullBoardScrollView = UIScrollView(frame: CGRectMake(0, 65, screenWidth, 228))
        uiviewCommentPinDetail.addSubview(commentDetailFullBoardScrollView)
        commentDetailFullBoardScrollView.scrollEnabled = false
        commentDetailFullBoardScrollView.contentSize.height = 228
        commentDetailFullBoardScrollView.showsVerticalScrollIndicator = false
        commentDetailFullBoardScrollView.delaysContentTouches = false
        
        // Textview width based on different resolutions
        var textViewWidth: CGFloat = 0
        if screenWidth == 414 { // 5.5
            textViewWidth = 360
        }
        else if screenWidth == 320 { // 4.0
            textViewWidth = 266
        }
        else if screenWidth == 375 { // 4.7
            textViewWidth = 321
        }
        
        // Textview of comment pin detail
        textviewCommentPinDetail = UITextView(frame: CGRectMake(27, 75, textViewWidth, 100))
        textviewCommentPinDetail.text = "Content"
        textviewCommentPinDetail.font = UIFont(name: "AvenirNext-Regular", size: 18)
        textviewCommentPinDetail.textColor = UIColor(red: 89/255, green: 89/255, blue: 89/255, alpha: 1.0)
        textviewCommentPinDetail.userInteractionEnabled = true
        textviewCommentPinDetail.editable = false
        textviewCommentPinDetail.textContainerInset = UIEdgeInsetsZero
        textviewCommentPinDetail.indicatorStyle = UIScrollViewIndicatorStyle.White
        commentDetailFullBoardScrollView.addSubview(textviewCommentPinDetail)
        
        // Main buttons' container of comment pin detail
        uiviewCommentPinDetailMainButtons = UIView(frame: CGRectMake(0, 190, screenWidth, 22))
        commentDetailFullBoardScrollView.addSubview(uiviewCommentPinDetailMainButtons)
        
        // Gray Block
        uiviewCommentPinDetailGrayBlock = UIView(frame: CGRectMake(0, 227, screenWidth, 12))
        uiviewCommentPinDetailGrayBlock.backgroundColor = UIColor(red: 244/255, green: 244/255, blue: 244/255, alpha: 1.0)
        commentDetailFullBoardScrollView.addSubview(uiviewCommentPinDetailGrayBlock)
        
        // View to hold three buttons
        uiviewCommentDetailThreeButtons = UIView(frame: CGRectMake(0, 239, screenWidth, 42))
        commentDetailFullBoardScrollView.addSubview(uiviewCommentDetailThreeButtons)
        
        let widthOfThreeButtons = screenWidth / 3
        
        // Table comments for comment
        tableCommentsForComment = UITableView(frame: CGRectMake(0, 281, screenWidth, 0))
        tableCommentsForComment.delegate = self
        tableCommentsForComment.dataSource = self
        tableCommentsForComment.allowsSelection = false
        tableCommentsForComment.delaysContentTouches = false
        tableCommentsForComment.registerClass(CommentPinCommentsCell.self, forCellReuseIdentifier: "commentPinCommentsCell")
        tableCommentsForComment.scrollEnabled = false
//        tableCommentsForComment.layer.borderColor = UIColor.blackColor().CGColor
//        tableCommentsForComment.layer.borderWidth = 1.0
        commentDetailFullBoardScrollView.addSubview(tableCommentsForComment)
        
        // Three buttons bottom gray line
        uiviewGrayBaseLine = UIView()
        uiviewGrayBaseLine.layer.borderWidth = 1.0
        uiviewGrayBaseLine.layer.borderColor = UIColor(red: 200/255, green: 199/255, blue: 204/255, alpha: 1.0).CGColor
        uiviewCommentDetailThreeButtons.addSubview(uiviewGrayBaseLine)
        uiviewCommentDetailThreeButtons.addConstraintsWithFormat("H:|-0-[v0(\(screenWidth))]", options: [], views: uiviewGrayBaseLine)
        uiviewCommentDetailThreeButtons.addConstraintsWithFormat("V:[v0(1)]-0-|", options: [], views: uiviewGrayBaseLine)
        
        // Three buttons bottom sliding red line
        uiviewRedSlidingLine = UIView(frame: CGRectMake(0, 40, widthOfThreeButtons, 2))
        uiviewRedSlidingLine.layer.borderWidth = 1.0
        uiviewRedSlidingLine.layer.borderColor = UIColor(red: 249/255, green: 90/255, blue: 90/255, alpha: 1.0).CGColor
        uiviewCommentDetailThreeButtons.addSubview(uiviewRedSlidingLine)
        
        // "Comments" of this uiview
        buttonCommentDetailViewComments = UIButton()
        buttonCommentDetailViewComments.setImage(UIImage(named: "commentDetailThreeButtonComments"), forState: .Normal)
        buttonCommentDetailViewComments.addTarget(self, action: #selector(FaeMapViewController.animationRedSlidingLine(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        uiviewCommentDetailThreeButtons.addSubview(buttonCommentDetailViewComments)
        buttonCommentDetailViewComments.tag = 1
        uiviewCommentDetailThreeButtons.addConstraintsWithFormat("V:|-0-[v0(42)]", options: [], views: buttonCommentDetailViewComments)
        
        // "Active" of this uiview
        buttonCommentDetailViewActive = UIButton()
        buttonCommentDetailViewActive.setImage(UIImage(named: "commentDetailThreeButtonActive"), forState: .Normal)
        buttonCommentDetailViewActive.addTarget(self, action: #selector(FaeMapViewController.animationRedSlidingLine(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        uiviewCommentDetailThreeButtons.addSubview(buttonCommentDetailViewActive)
        buttonCommentDetailViewActive.tag = 3
        uiviewCommentDetailThreeButtons.addConstraintsWithFormat("V:|-0-[v0(42)]", options: [], views: buttonCommentDetailViewActive)
        
        // "People" of this uiview
        buttonCommentDetailViewPeople = UIButton()
        buttonCommentDetailViewPeople.setImage(UIImage(named: "commentDetailThreeButtonPeople"), forState: .Normal)
        buttonCommentDetailViewPeople.addTarget(self, action: #selector(FaeMapViewController.animationRedSlidingLine(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        uiviewCommentDetailThreeButtons.addSubview(buttonCommentDetailViewPeople)
        buttonCommentDetailViewPeople.tag = 5
        uiviewCommentDetailThreeButtons.addConstraintsWithFormat("V:|-0-[v0(42)]", options: [], views: buttonCommentDetailViewPeople)
        
        uiviewCommentDetailThreeButtons.addConstraintsWithFormat("H:|-0-[v0(\(widthOfThreeButtons))]-0-[v1(\(widthOfThreeButtons))]-0-[v2(\(widthOfThreeButtons))]", options: [], views: buttonCommentDetailViewComments, buttonCommentDetailViewActive, buttonCommentDetailViewPeople)
        
        // Label of Vote Count
        labelCommentPinVoteCount = UILabel()
        labelCommentPinVoteCount.text = "0"
        labelCommentPinVoteCount.font = UIFont(name: "PingFang SC-Semibold", size: 15)
        labelCommentPinVoteCount.textColor = UIColor(red: 107/255, green: 105/255, blue: 105/255, alpha: 1.0)
        labelCommentPinVoteCount.textAlignment = .Center
        uiviewCommentPinDetailMainButtons.addSubview(labelCommentPinVoteCount)
        uiviewCommentPinDetailMainButtons.addConstraintsWithFormat("H:|-42-[v0(56)]", options: [], views: labelCommentPinVoteCount)
        uiviewCommentPinDetailMainButtons.addConstraintsWithFormat("V:[v0(22)]-0-|", options: [], views: labelCommentPinVoteCount)
        
        // Label of Like Count
        labelCommentPinLikeCount = UILabel()
        labelCommentPinLikeCount.text = "0"
        labelCommentPinLikeCount.font = UIFont(name: "PingFang SC-Semibold", size: 15)
        labelCommentPinLikeCount.textColor = UIColor(red: 107/255, green: 105/255, blue: 105/255, alpha: 1.0)
        labelCommentPinLikeCount.textAlignment = .Right
        uiviewCommentPinDetailMainButtons.addSubview(labelCommentPinLikeCount)
        uiviewCommentPinDetailMainButtons.addConstraintsWithFormat("H:[v0(41)]-141-|", options: [], views: labelCommentPinLikeCount)
        uiviewCommentPinDetailMainButtons.addConstraintsWithFormat("V:[v0(22)]-0-|", options: [], views: labelCommentPinLikeCount)
        
        // Label of Comments of Coment Pin Count
        labelCommentPinCommentsCount = UILabel()
        labelCommentPinCommentsCount.text = "3"
        labelCommentPinCommentsCount.font = UIFont(name: "PingFang SC-Semibold", size: 15)
        labelCommentPinCommentsCount.textColor = UIColor(red: 107/255, green: 105/255, blue: 105/255, alpha: 1.0)
        labelCommentPinCommentsCount.textAlignment = .Right
        uiviewCommentPinDetailMainButtons.addSubview(labelCommentPinCommentsCount)
        uiviewCommentPinDetailMainButtons.addConstraintsWithFormat("H:[v0(41)]-49-|", options: [], views: labelCommentPinCommentsCount)
        uiviewCommentPinDetailMainButtons.addConstraintsWithFormat("V:[v0(22)]-0-|", options: [], views: labelCommentPinCommentsCount)
        
        // Button 3: Comment Pin DownVote
        buttonCommentPinDownVote = UIButton()
        buttonCommentPinDownVote.setImage(UIImage(named: "commentPinDownVoteGray"), forState: .Normal)
                buttonCommentPinDownVote.addTarget(self, action: #selector(FaeMapViewController.actionDownVoteThisComment(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        uiviewCommentPinDetailMainButtons.addSubview(buttonCommentPinDownVote)
        uiviewCommentPinDetailMainButtons.addConstraintsWithFormat("H:|-0-[v0(53)]", options: [], views: buttonCommentPinDownVote)
        uiviewCommentPinDetailMainButtons.addConstraintsWithFormat("V:[v0(22)]-0-|", options: [], views: buttonCommentPinDownVote)
        
        // Button 4: Comment Pin UpVote
        buttonCommentPinUpVote = UIButton()
        buttonCommentPinUpVote.setImage(UIImage(named: "commentPinUpVoteGray"), forState: .Normal)
                buttonCommentPinUpVote.addTarget(self, action: #selector(FaeMapViewController.actionLikeThisComment(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        uiviewCommentPinDetailMainButtons.addSubview(buttonCommentPinUpVote)
        uiviewCommentPinDetailMainButtons.addConstraintsWithFormat("H:|-91-[v0(53)]", options: [], views: buttonCommentPinUpVote)
        uiviewCommentPinDetailMainButtons.addConstraintsWithFormat("V:[v0(22)]-0-|", options: [], views: buttonCommentPinUpVote)
        
        // Button 5: Comment Pin Like
        buttonCommentPinLike = UIButton()
        buttonCommentPinLike.setImage(UIImage(named: "commentPinLikeHollow"), forState: .Normal)
        buttonCommentPinLike.addTarget(self, action: #selector(FaeMapViewController.actionLikeThisComment(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        uiviewCommentPinDetailMainButtons.addSubview(buttonCommentPinLike)
        uiviewCommentPinDetailMainButtons.addConstraintsWithFormat("H:[v0(56)]-90-|", options: [], views: buttonCommentPinLike)
        uiviewCommentPinDetailMainButtons.addConstraintsWithFormat("V:[v0(22)]-0-|", options: [], views: buttonCommentPinLike)
        
        // Button 6: Add Comment
        buttonCommentPinAddComment = UIButton()
        buttonCommentPinAddComment.setImage(UIImage(named: "commentPinAddComment"), forState: .Normal)
                buttonCommentPinAddComment.addTarget(self, action: #selector(FaeMapViewController.actionReplyToThisComment(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        uiviewCommentPinDetailMainButtons.addSubview(buttonCommentPinAddComment)
        uiviewCommentPinDetailMainButtons.addConstraintsWithFormat("H:[v0(56)]-0-|", options: [], views: buttonCommentPinAddComment)
        uiviewCommentPinDetailMainButtons.addConstraintsWithFormat("V:[v0(22)]-0-|", options: [], views: buttonCommentPinAddComment)
        
        // Button 7: Drag to larger
        buttonCommentPinDetailDragToLargeSize = UIButton()
        buttonCommentPinDetailDragToLargeSize.backgroundColor = UIColor.whiteColor()
        buttonCommentPinDetailDragToLargeSize.setImage(UIImage(named: "commentPinDetailDragToLarge"), forState: .Normal)
        //        buttonCommentPinDetailDragToLargeSize.addTarget(self, action: #selector(FaeMapViewController.animationMapChatShow(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        uiviewCommentPinDetail.addSubview(buttonCommentPinDetailDragToLargeSize)
        uiviewCommentPinDetail.addConstraintsWithFormat("H:[v0(\(screenWidth))]", options: [], views: buttonCommentPinDetailDragToLargeSize)
        uiviewCommentPinDetail.addConstraintsWithFormat("V:[v0(26)]-0-|", options: [], views: buttonCommentPinDetailDragToLargeSize)
        NSLayoutConstraint(item: buttonCommentPinDetailDragToLargeSize, attribute: .CenterX, relatedBy: .Equal, toItem: uiviewCommentPinDetail, attribute: .CenterX, multiplier: 1.0, constant: 0).active = true
        
        // Label of Title
        labelCommentPinTitle = UILabel()
        labelCommentPinTitle.text = "Comment"
        labelCommentPinTitle.font = UIFont(name: "AvenirNext-Medium", size: 20)
        labelCommentPinTitle.textColor = UIColor(red: 89/255, green: 89/255, blue: 89/255, alpha: 1.0)
        labelCommentPinTitle.textAlignment = .Center
        uiviewCommentPinDetail.addSubview(labelCommentPinTitle)
        uiviewCommentPinDetail.addConstraintsWithFormat("H:[v0(92)]", options: [], views: labelCommentPinTitle)
        uiviewCommentPinDetail.addConstraintsWithFormat("V:|-28-[v0(27)]", options: [], views: labelCommentPinTitle)
        NSLayoutConstraint(item: labelCommentPinTitle, attribute: .CenterX, relatedBy: .Equal, toItem: uiviewCommentPinDetail, attribute: .CenterX, multiplier: 1.0, constant: 0).active = true
        
        // Comment Pin User Avatar
        imageCommentPinUserAvatar = UIImageView()
        imageCommentPinUserAvatar.image = UIImage(named: "commentPinSampleAvatar")
        commentDetailFullBoardScrollView.addSubview(imageCommentPinUserAvatar)
        commentDetailFullBoardScrollView.addConstraintsWithFormat("H:|-15-[v0(50)]", options: [], views: imageCommentPinUserAvatar)
        commentDetailFullBoardScrollView.addConstraintsWithFormat("V:|-15-[v0(50)]", options: [], views: imageCommentPinUserAvatar)
        
        // Comment Pin Username
        labelCommentPinUserName = UILabel()
        labelCommentPinUserName.text = "Username"
        labelCommentPinUserName.font = UIFont(name: "AvenirNext-Medium", size: 18)
        labelCommentPinUserName.textColor = UIColor(red: 89/255, green: 89/255, blue: 89/255, alpha: 1.0)
        labelCommentPinTitle.textAlignment = .Left
        commentDetailFullBoardScrollView.addSubview(labelCommentPinUserName)
        commentDetailFullBoardScrollView.addConstraintsWithFormat("H:|-80-[v0(250)]", options: [], views: labelCommentPinUserName)
        commentDetailFullBoardScrollView.addConstraintsWithFormat("V:|-19-[v0(25)]", options: [], views: labelCommentPinUserName)
        
        // Timestamp of comment pin detail
        labelCommentPinTimestamp = UILabel()
        labelCommentPinTimestamp.text = "Time"
        labelCommentPinTimestamp.font = UIFont(name: "AvenirNext-Medium", size: 13)
        labelCommentPinTimestamp.textColor = UIColor(red: 107/255, green: 105/255, blue: 105/255, alpha: 1.0)
        labelCommentPinTimestamp.textAlignment = .Left
        commentDetailFullBoardScrollView.addSubview(labelCommentPinTimestamp)
        commentDetailFullBoardScrollView.addConstraintsWithFormat("H:|-80-[v0(200)]", options: [], views: labelCommentPinTimestamp)
        commentDetailFullBoardScrollView.addConstraintsWithFormat("V:|-40-[v0(27)]", options: [], views: labelCommentPinTimestamp)
        
        // Cancel all the touch down delays for uibutton caused by tableview's subviews
        for view in tableCommentsForComment.subviews {
            if view is UIScrollView {
                (view as? UIScrollView)!.delaysContentTouches = false
                break
            }
        }
    }
    
    // Load comment pin list
    func loadCommentPinList() {
        uiviewCommentPinListBlank = UIView(frame: CGRectMake(0, 0, screenWidth, 320))
        uiviewCommentPinListBlank.layer.zPosition = 100
        uiviewCommentPinListBlank.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(uiviewCommentPinListBlank)
        uiviewCommentPinListBlank.layer.shadowOpacity = 0.3
        uiviewCommentPinListBlank.layer.shadowOffset = CGSize(width: 0.0, height: 10.0)
        uiviewCommentPinListBlank.layer.shadowRadius = 10.0
        uiviewCommentPinListBlank.layer.shadowColor = UIColor(red: 107/255, green: 105/255, blue: 105/255, alpha: 1.0).CGColor
        uiviewCommentPinListBlank.center.x -= screenWidth
        
        let leftSwipe = UISwipeGestureRecognizer(target: self,
                                                 action: #selector(FaeMapViewController.actionBackToCommentDetail(_:)))
        let rightSwipe = UISwipeGestureRecognizer(target: self,
                                                  action: #selector(FaeMapViewController.actionBackToList(_:)))
        let upSwipe = UISwipeGestureRecognizer(target: self,
                                               action: #selector(FaeMapViewController.shrinkCommentList))
        let downSwipe = UISwipeGestureRecognizer(target: self,
                                                 action: #selector(FaeMapViewController.expandCommentList))
        
        leftSwipe.direction = .Left
        rightSwipe.direction = .Right
        upSwipe.direction = .Up
        downSwipe.direction = .Down
        
        uiviewCommentPinListBlank.addGestureRecognizer(leftSwipe)
        uiviewCommentPinListBlank.addGestureRecognizer(upSwipe)
        uiviewCommentPinListBlank.addGestureRecognizer(downSwipe)
        uiviewCommentPinDetail.addGestureRecognizer(rightSwipe)
        
        // Scrollview
        commentListScrollView = UIScrollView(frame: CGRectMake(0, 65, screenWidth, 228))
        uiviewCommentPinListBlank.addSubview(commentListScrollView)
        
        // Line at y = 64
        uiviewCommentPinListUnderLine01 = UIView(frame: CGRectMake(0, 64, screenWidth, 1))
        uiviewCommentPinListUnderLine01.layer.borderWidth = screenWidth
        uiviewCommentPinListUnderLine01.layer.borderColor = UIColor(red: 200/255, green: 199/255, blue: 204/255, alpha: 1.0).CGColor
        uiviewCommentPinListBlank.addSubview(uiviewCommentPinListUnderLine01)
        
        // Line at y = 292
        uiviewCommentPinListUnderLine02 = UIView(frame: CGRectMake(0, 292, screenWidth, 1))
        uiviewCommentPinListUnderLine02.layer.borderWidth = screenWidth
        uiviewCommentPinListUnderLine02.layer.borderColor = UIColor(red: 200/255, green: 199/255, blue: 204/255, alpha: 1.0).CGColor
        uiviewCommentPinListBlank.addSubview(uiviewCommentPinListUnderLine02)
        uiviewCommentPinListBlank.addConstraintsWithFormat("H:|-0-[v0(\(screenWidth))]", options: [], views: uiviewCommentPinListUnderLine02)
        uiviewCommentPinListBlank.addConstraintsWithFormat("V:[v0(1)]-27-|", options: [], views: uiviewCommentPinListUnderLine02)
        
        // Button: Back to Comment Detail
        buttonBackToCommentPinDetail = UIButton()
        buttonBackToCommentPinDetail.setImage(UIImage(named: "commentPinBackToCommentDetail"), forState: .Normal)
        buttonBackToCommentPinDetail.addTarget(self, action: #selector(FaeMapViewController.actionBackToCommentDetail(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        uiviewCommentPinListBlank.addSubview(buttonBackToCommentPinDetail)
        uiviewCommentPinListBlank.addConstraintsWithFormat("H:|-(-21)-[v0(101)]", options: [], views: buttonBackToCommentPinDetail)
        uiviewCommentPinListBlank.addConstraintsWithFormat("V:|-26-[v0(29)]", options: [], views: buttonBackToCommentPinDetail)
        
        // Button: Clear Comment Pin List
        buttonCommentPinListClear = UIButton()
        buttonCommentPinListClear.setImage(UIImage(named: "commentPinListClear"), forState: .Normal)
        buttonCommentPinListClear.addTarget(self, action: #selector(FaeMapViewController.actionClearCommentPinList(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        uiviewCommentPinListBlank.addSubview(buttonCommentPinListClear)
        uiviewCommentPinListBlank.addConstraintsWithFormat("H:[v0(42)]-15-|", options: [], views: buttonCommentPinListClear)
        uiviewCommentPinListBlank.addConstraintsWithFormat("V:|-30-[v0(25)]", options: [], views: buttonCommentPinListClear)
        
        // Button: Drag to larger
        buttonCommentPinListDragToLargeSize = UIButton(frame: CGRectMake(0, 293, screenWidth, 27))
        buttonCommentPinListDragToLargeSize.setImage(UIImage(named: "commentPinDetailDragToLarge"), forState: .Normal)
        buttonCommentPinListDragToLargeSize.addTarget(self, action: #selector(FaeMapViewController.actionListExpandShrink(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        uiviewCommentPinListBlank.addSubview(buttonCommentPinListDragToLargeSize)
        let panCommentPinListDrag = UIPanGestureRecognizer(target: self, action: #selector(FaeMapViewController.panActionCommentPinListDrag(_:)))
        buttonCommentPinListDragToLargeSize.addGestureRecognizer(panCommentPinListDrag)
        
        // Label of Title
        labelCommentPinListTitle = UILabel()
        labelCommentPinListTitle.text = "Opened Pins"
        labelCommentPinListTitle.font = UIFont(name: "AvenirNext-Medium", size: 20)
        labelCommentPinListTitle.textColor = UIColor(red: 89/255, green: 89/255, blue: 89/255, alpha: 1.0)
        labelCommentPinListTitle.textAlignment = .Center
        uiviewCommentPinListBlank.addSubview(labelCommentPinListTitle)
        uiviewCommentPinListBlank.addConstraintsWithFormat("H:[v0(120)]", options: [], views: labelCommentPinListTitle)
        uiviewCommentPinListBlank.addConstraintsWithFormat("V:|-28-[v0(27)]", options: [], views: labelCommentPinListTitle)
        NSLayoutConstraint(item: labelCommentPinListTitle, attribute: .CenterX, relatedBy: .Equal, toItem: uiviewCommentPinListBlank, attribute: .CenterX, multiplier: 1.0, constant: 0).active = true
    }
    
    // Animation of the red sliding line
    func animationRedSlidingLine(sender: UIButton) {
        let tag = CGFloat(sender.tag)
        let centerAtOneThird = screenWidth / 6
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
        buttonCommentPinLike.setImage(UIImage(named: "commentPinLikeFull"), forState: .Normal)
        buttonCommentPinUpVote.setImage(UIImage(named: "commentPinUpVoteRed"), forState: .Normal)
        buttonCommentPinDownVote.setImage(UIImage(named: "commentPinDownVoteGray"), forState: .Normal)

        isUpVoting = true
        isDownVoting = false
//        if let tempString = labelCommentPinVoteCount.text {
//            commentPinLikeCount = Int(tempString)!
//        }
        animateHeart()
        if commentIDCommentPinDetailView != "-999" {
            likeThisPin("comment", pinID: commentIDCommentPinDetailView)
            getPinAttributeNum("comment", pinID: commentIDCommentPinDetailView)
        }
    }
    
    // Down vote comment pin
    func actionDownVoteThisComment(sender: UIButton) {
        buttonCommentPinLike.setImage(UIImage(named: "commentPinLikeHollow"), forState: .Normal)
        buttonCommentPinUpVote.setImage(UIImage(named: "commentPinUpVoteGray"), forState: .Normal)
        buttonCommentPinDownVote.setImage(UIImage(named: "commentPinDownVoteRed"), forState: .Normal)
        isUpVoting = false
        isDownVoting = true//test
        if let tempString = labelCommentPinVoteCount.text {
            commentPinLikeCount = Int(tempString)!
        }
    }
    
    // Pan gesture for dragging comment pin list dragging button
    func panActionCommentPinListDrag(pan: UIPanGestureRecognizer) {
        if pan.state == .Began {
            if uiviewCommentPinListBlank.frame.size.height == 320 {
                commentPinSizeFrom = 320
                commentPinSizeTo = screenHeight
            }
            else {
                commentPinSizeFrom = screenHeight
                commentPinSizeTo = 320
            }
        } else if pan.state == .Ended || pan.state == .Failed || pan.state == .Cancelled {
            let location = pan.locationInView(view)
            if abs(location.y - commentPinSizeFrom) >= 60 {
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
                buttonCommentPinListDragToLargeSize.center.y = location.y
                uiviewCommentPinListBlank.frame.size.height = location.y + 13.5
                commentListScrollView.frame.size.height = location.y - 78.5
            }
        }
    }
    
    // Reset comment pin list window and remove all saved data
    func actionClearCommentPinList(sender: UIButton) {
        for cell in commentPinCellArray {
            cell.removeFromSuperview()
        }
        commentPinCellArray.removeAll()
        commentPinAvoidDic.removeAll()
        commentPinCellNumCount = 0
        disableTheButton(buttonBackToCommentPinDetail)
    }
    
    // Close more options button when it is open, the subview is under it
    func actionToCloseOtherViews(sender: UIButton) {
        if buttonMoreOnCommentCellExpanded == true {
            hideCommentPinMoreButtonDetails()
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
            buttonFakeTransparentClosingView = UIButton(frame: CGRectMake(0, 0, screenWidth, screenHeight))
            buttonFakeTransparentClosingView.layer.zPosition = 101
            self.view.addSubview(buttonFakeTransparentClosingView)
            buttonFakeTransparentClosingView.addTarget(self, action: #selector(FaeMapViewController.actionToCloseOtherViews(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            
            moreButtonDetailSubview = UIImageView(frame: CGRectMake(400, 57, 0, 0))
            moreButtonDetailSubview.image = UIImage(named: "moreButtonDetailSubview")
            moreButtonDetailSubview.layer.zPosition = 102
            self.view.addSubview(moreButtonDetailSubview)
            
            buttonShareOnCommentDetail = UIButton(frame: CGRectMake(400, 57, 0, 0))
            buttonShareOnCommentDetail.setImage(UIImage(named: "buttonShareOnCommentDetail"), forState: .Normal)
            buttonShareOnCommentDetail.layer.zPosition = 103
            self.view.addSubview(buttonShareOnCommentDetail)
            buttonShareOnCommentDetail.clipsToBounds = true
            buttonShareOnCommentDetail.alpha = 0.0
            buttonShareOnCommentDetail.addTarget(self, action: #selector(FaeMapViewController.actionShareComment(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            
            buttonSaveOnCommentDetail = UIButton(frame: CGRectMake(400, 57, 0, 0))
            buttonSaveOnCommentDetail.setImage(UIImage(named: "buttonSaveOnCommentDetail"), forState: .Normal)
            buttonSaveOnCommentDetail.layer.zPosition = 103
            self.view.addSubview(buttonSaveOnCommentDetail)
            buttonSaveOnCommentDetail.clipsToBounds = true
            buttonSaveOnCommentDetail.alpha = 0.0
            
            buttonReportOnCommentDetail = UIButton(frame: CGRectMake(400, 57, 0, 0))
            buttonReportOnCommentDetail.setImage(UIImage(named: "buttonReportOnCommentDetail"), forState: .Normal)
            buttonReportOnCommentDetail.layer.zPosition = 103
            self.view.addSubview(buttonReportOnCommentDetail)
            buttonReportOnCommentDetail.clipsToBounds = true
            buttonReportOnCommentDetail.alpha = 0.0
            
            
            UIView.animateWithDuration(0.25, animations: ({
                self.moreButtonDetailSubview.frame = CGRectMake(171, 57, 229, 110)
                self.buttonShareOnCommentDetail.frame = CGRectMake(192, 97, 44, 51)
                self.buttonSaveOnCommentDetail.frame = CGRectMake(262, 97, 44, 51)
                self.buttonReportOnCommentDetail.frame = CGRectMake(332, 97, 44, 51)
                self.buttonShareOnCommentDetail.alpha = 1.0
                self.buttonSaveOnCommentDetail.alpha = 1.0
                self.buttonReportOnCommentDetail.alpha = 1.0
            }))
            buttonMoreOnCommentCellExpanded = true
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
        if commentListExpand == false {
            UIView.animateWithDuration(0.25, animations: ({
                self.buttonCommentPinListDragToLargeSize.center.y = self.screenHeight - 13.5
                self.uiviewCommentPinListBlank.frame.size.height = self.screenHeight
                self.uiviewCommentPinListUnderLine02.center.y = self.screenHeight - 27.5
                self.commentListScrollView.frame.size.height = self.screenHeight - 91
            }))
            commentListExpand = true
        }
        else {
            UIView.animateWithDuration(0.25, animations: ({
                self.uiviewCommentPinListBlank.frame.size.height = 320
                self.buttonCommentPinListDragToLargeSize.center.y = 306.5
                self.uiviewCommentPinListUnderLine02.center.y = 292.5
                self.commentListScrollView.frame.size.height = 228
            }))
            commentListExpand = false
        }
    }
    
    // Shrink comment pin list
    func shrinkCommentList() {
        if commentListExpand {
            UIView.animateWithDuration(0.25, animations: ({
                self.uiviewCommentPinListBlank.frame.size.height = 320
                self.buttonCommentPinListDragToLargeSize.center.y = 306.5
                self.uiviewCommentPinListUnderLine02.center.y = 292.5
                self.commentListScrollView.frame.size.height = 228
            }))
            commentListExpand = false
        }
    }
    
    // Expand comment pin list
    func expandCommentList() {
        if commentListExpand == false {
            UIView.animateWithDuration(0.25, animations: ({
                self.buttonCommentPinListDragToLargeSize.center.y = self.screenHeight - 13.5
                self.uiviewCommentPinListBlank.frame.size.height = self.screenHeight
                self.uiviewCommentPinListUnderLine02.center.y = self.screenHeight - 27.5
                self.commentListScrollView.frame.size.height = self.screenHeight - 91
            }))
            commentListExpand = true
        }
    }
    
    // When clicking a cell in comment pin list, it jumps to its detail window
    func actionJumpToDetail(sender: UIButton!) {
        actionBackToCommentDetail(buttonBackToCommentPinDetail)
        let row = sender.tag
        labelCommentPinUserName.text = commentPinCellArray[row].userID
        labelCommentPinTimestamp.text = commentPinCellArray[row].time.text
        textviewCommentPinDetail.text = commentPinCellArray[row].content.text
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
        cell.jumpToDetail.tag = commentPinCellNumCount
        cell.deleteButton.tag = commentPinCellNumCount
        cell.commentID = commentID
        commentPinAvoidDic[commentID] = commentPinCellNumCount
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
        
        print("DEBUG - DELETE: sender.tag: \(sender.tag)")
        
//        print("Avoid Dic before deleting: \(commentPinAvoidDic)")
        
        let commentID = commentPinCellArray[sender.tag].commentID
        let rowToDelete = sender.tag
        
        if commentPinCellNumCount == 1 {
            commentPinCellNumCount = 0
            disableTheButton(buttonBackToCommentPinDetail)
            commentListScrollView.contentSize.height -= 76
            commentPinCellArray.first!.removeFromSuperview()
            commentPinCellArray.removeAll()
        }
        
        else if commentPinCellNumCount >= 2 {
            commentPinCellNumCount -= 1
            commentPinCellArray[rowToDelete].removeFromSuperview()
            commentPinCellArray.removeAtIndex(rowToDelete)
            commentListScrollView.contentSize.height -= 76
            for (index, cell) in commentPinCellArray.enumerate() {
                if index >= rowToDelete {
                    cell.jumpToDetail.tag -= 1
                    cell.deleteButton.tag -= 1
                    cell.center.y -= 76
                }
            }
        }
        
        if let aDictionaryIndex = commentPinAvoidDic.indexForKey(commentID) {
            // This will remove the key/value pair from the dictionary and return it as a tuple pair.
            let (_, _) = commentPinAvoidDic.removeAtIndex(aDictionaryIndex)
        }
    }
    
    // Show comment pin detail window
    func showCommentPinDetail() {
        if uiviewCommentPinDetail != nil {
            uiviewCommentPinDetail.frame = CGRectMake(0, -320, screenWidth, 320)
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
        if uiviewCommentPinDetail != nil {
            if commentPinDetailShowed {
                actionBackToMap(self.buttonCommentPinBackToMap)
                UIView.animateWithDuration(0.25, animations: ({
                    
                }), completion: { (done: Bool) in
                    if done {
                        self.navigationController?.navigationBar.hidden = false
                        self.commentPinDetailShowed = false
                        self.commentListShowed = false
                    }
                })
            }
            if commentListShowed {
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
        if commentIDCommentPinDetailView != "-999" {
            getPinAttributeCommentsNum("comment", pinID: commentIDCommentPinDetailView)
        }
        let numLines = Int(textviewCommentPinDetail.contentSize.height / textviewCommentPinDetail.font!.lineHeight)
        let diffHeight: CGFloat = textviewCommentPinDetail.contentSize.height - textviewCommentPinDetail.frame.size.height
        let newHeight = CGFloat(140 * self.numberOfCommentTableCells)
        textviewCommentPinDetail.scrollEnabled = false
        commentDetailFullBoardScrollView.scrollEnabled = true
        UIView.animateWithDuration(0.25, animations: ({
            self.buttonBackToCommentPinLists.alpha = 0.0
            self.buttonCommentPinBackToMap.alpha = 1.0
            self.uiviewCommentPinDetail.frame.size.height = self.screenHeight + 26
            self.uiviewCommentPinUnderLine02.frame.origin.y = self.screenHeight
            self.commentDetailFullBoardScrollView.frame.size.height = self.screenHeight - 155
            self.tableCommentsForComment.frame = CGRectMake(0, 281, self.screenWidth, newHeight)
            if numLines > 4 {
                // 420 is table height, 281 is fixed
                self.commentDetailFullBoardScrollView.contentSize.height = newHeight + 281 + diffHeight
                self.tableCommentsForComment.center.y += diffHeight
                self.textviewCommentPinDetail.frame.size.height += diffHeight
                self.uiviewCommentDetailThreeButtons.center.y += diffHeight
                self.uiviewCommentPinDetailGrayBlock.center.y += diffHeight
                self.uiviewCommentPinDetailMainButtons.center.y += diffHeight
            }
            else {
                // 420 is table height, 281 is fixed
                self.commentDetailFullBoardScrollView.contentSize.height = newHeight + 281
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
                self.commentDetailFullBoardScrollView.contentSize.height = 228
                self.commentDetailFullBoardScrollView.frame.size.height = 228
                self.commentDetailFullBoardScrollView.scrollEnabled = false
                self.commentPinDetailShowed = false
                self.tableCommentsForComment.frame.origin.y = 281
                self.textviewCommentPinDetail.frame.size.height = 100
                self.textviewCommentPinDetail.scrollEnabled = true
                self.uiviewCommentDetailThreeButtons.frame.origin.y = 239
                self.uiviewCommentPinDetailGrayBlock.frame.origin.y = 227
                self.uiviewCommentPinDetail.frame.size.height = 320
                self.uiviewCommentPinDetailMainButtons.frame.origin.y = 190
                self.uiviewCommentPinUnderLine02.frame.origin.y = 292
            }
        })
    }
    
    func animateHeart() {
        animatingHeart = UIImageView(frame: CGRectMake(0, 0, 26, 22))
        animatingHeart.image = UIImage(named: "commentPinLikeFull")
        uiviewCommentPinDetailMainButtons.addSubview(animatingHeart)
        
        //创建用于转移坐标的Transform，这样我们不用按照实际显示做坐标计算
        let randomX = CGFloat(arc4random_uniform(150))
        let randomY = CGFloat(arc4random_uniform(50) + 100)
        let randomSize: CGFloat = (CGFloat(arc4random_uniform(40)) - 20) / 100 + 1
        
        var transform: CGAffineTransform = CGAffineTransformMakeTranslation(buttonCommentPinLike.center.x, buttonCommentPinLike.center.y)
        let path =  CGPathCreateMutable()
        CGPathMoveToPoint(path, &transform, 0, 0)
        CGPathAddLineToPoint(path, &transform, randomX-75, -randomY)
        
        let scaleAnimation = CAKeyframeAnimation(keyPath: "transform")
        scaleAnimation.values = [NSValue(CATransform3D: CATransform3DMakeScale(1, 1, 1)), NSValue(CATransform3D: CATransform3DMakeScale(randomSize, randomSize, 1))]
        scaleAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        scaleAnimation.duration = 1
        
        let fadeAnimation = CABasicAnimation(keyPath: "opacity")
        fadeAnimation.fromValue = 1.0
        fadeAnimation.toValue = 0.0
        fadeAnimation.duration = 1
        
        let orbit = CAKeyframeAnimation(keyPath: "position")
        orbit.duration = 1
        orbit.path = path
        orbit.calculationMode = kCAAnimationPaced
        animatingHeart.layer.addAnimation(orbit, forKey:"Move")
        animatingHeart.layer.addAnimation(fadeAnimation, forKey: "Opacity")
        animatingHeart.layer.addAnimation(scaleAnimation, forKey: "Scale")
        animatingHeart.layer.position = CGPointMake(buttonCommentPinLike.center.x, buttonCommentPinLike.center.y)
    }
    
    func likeThisPin(type: String, pinID: String) {
        let likeThisPin = FaePinAction()
        likeThisPin.whereKey("", value: "")
        if commentIDCommentPinDetailView != "-999" {
            print("DEBUG: Like This Pin")
            likeThisPin.likeThisPin(type , commentId: pinID) {(status: Int, message: AnyObject?) in
                if status == 201 {
                    print("Successfully like this comment pin!")
                }
            }
        }
    }
    
    func getPinAttributeNum(type: String, pinID: String) {
        let getPinAttr = FaePinAction()
        getPinAttr.getPinAttribute(type, commentId: pinID) {(status: Int, message: AnyObject?) in
            print(status)
            print(message)
            let mapInfoJSON = JSON(message!)
            
            if let likes = mapInfoJSON["likes"].int {
                self.labelCommentPinLikeCount.text = "\(likes)"
                self.labelCommentPinVoteCount.text = "\(likes)"
            }
            if let _ = mapInfoJSON["saves"].int {
                
            }
            if let _ = mapInfoJSON["type"].string {
            
            }
            if let _ = mapInfoJSON["pin_id"].string {
            
            }
            if let comments = mapInfoJSON["comments"].int {
                self.labelCommentPinCommentsCount.text = "\(comments)"
            }
        }
    }
    
    func getPinAttributeCommentsNum(type: String, pinID: String) {
        let getPinAttr = FaePinAction()
        getPinAttr.getPinAttribute(type, commentId: pinID) {(status: Int, message: AnyObject?) in
            print(status)
            print(message)
            let mapInfoJSON = JSON(message!)
            if let comments = mapInfoJSON["comments"].int {
                self.labelCommentPinCommentsCount.text = "\(comments)"
                self.numberOfCommentTableCells = comments
                self.tableCommentsForComment.reloadData()
            }
        }
    }
    
    func getPinCommentsDetail(type: String, pinID: String) {
        dictCommentsOnCommentDetail.removeAll()
        let getPinCommentsDetail = FaePinAction()
        getPinCommentsDetail.getPinComments(type, commentId: pinID) {(status: Int, message: AnyObject?) in
            print(status)
            print(message)
            let commentsOfCommentJSON = JSON(message!)
            if commentsOfCommentJSON.count > 0 {
                for i in 0...(commentsOfCommentJSON.count-1) {
                    var dicCell = [String: AnyObject]()
                    if let pin_comment_id = commentsOfCommentJSON[i]["pin_comment_id"].string {
                        print(pin_comment_id)
                        dicCell["pin_comment_id"] = pin_comment_id
                    }
                    if let user_id = commentsOfCommentJSON[i]["user_id"].int {
                        print(user_id)
                        dicCell["user_id"] = user_id
                    }
                    if let content = commentsOfCommentJSON[i]["content"].string {
                        print(content)
                        dicCell["content"] = content
                    }
                    if let date = commentsOfCommentJSON[i]["created_at"]["date"].string {
                        print(date)
                        dicCell["date"] = date
                    }
                    if let timezone_type = commentsOfCommentJSON[i]["created_at"]["timezone_type"].int {
                        print(timezone_type)
                        dicCell["timezone_type"] = timezone_type
                    }
                    if let timezone = commentsOfCommentJSON[i]["created_at"]["timezone"].string {
                        print(timezone)
                        dicCell["timezone"] = timezone
                    }
                    self.dictCommentsOnCommentDetail.append(dicCell)
                    print("===分割线===")
                }
            }
        }
    }
}
