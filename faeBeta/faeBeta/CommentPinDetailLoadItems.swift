//
//  CommentPinDetailLoadItems.swift
//  faeBeta
//
//  Created by Yue on 10/18/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
import SwiftyJSON

extension CommentPinViewController {
    // Load comment pin detail window
    func loadCommentPinDetailWindow() {
        // Header
        uiviewCommentPinDetail = UIView(frame: CGRectMake(0, 65, screenWidth, 255))
        uiviewCommentPinDetail.backgroundColor = UIColor.whiteColor()
        uiviewCommentPinDetail.layer.shadowColor = UIColor(red: 107/255, green: 105/255, blue: 105/255, alpha: 1.0).CGColor
        uiviewCommentPinDetail.layer.shadowOffset = CGSize(width: 0.0, height: 10.0)
        uiviewCommentPinDetail.layer.shadowOpacity = 0.3
        uiviewCommentPinDetail.layer.shadowRadius = 10.0
        uiviewCommentPinDetail.layer.zPosition = 100
        self.view.addSubview(uiviewCommentPinDetail)
        
        
        subviewWhite = UIView(frame: CGRectMake(0, 0, screenWidth, 65))
        subviewWhite.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(subviewWhite)
        subviewWhite.layer.zPosition = 101
        
        // Line at y = 64
        uiviewCommentPinUnderLine01 = UIView(frame: CGRectMake(0, 64, screenWidth, 1))
        uiviewCommentPinUnderLine01.layer.borderWidth = screenWidth
        uiviewCommentPinUnderLine01.layer.borderColor = UIColor(red: 200/255, green: 199/255, blue: 204/255, alpha: 1.0).CGColor
        subviewWhite.addSubview(uiviewCommentPinUnderLine01)
        
        // Line at y = 292
        uiviewCommentPinUnderLine02 = UIView(frame: CGRectMake(0, 227, screenWidth, 1))
        uiviewCommentPinUnderLine02.backgroundColor = UIColor(red: 200/255, green: 199/255, blue: 204/255, alpha: 1.0)
        uiviewCommentPinDetail.addSubview(uiviewCommentPinUnderLine02)
        
        // Button 0: Back to Map
        buttonCommentPinBackToMap = UIButton()
        buttonCommentPinBackToMap.setImage(UIImage(named: "commentPinBackToMap"), forState: .Normal)
        buttonCommentPinBackToMap.addTarget(self, action: #selector(CommentPinViewController.actionBackToMap(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        subviewWhite.addSubview(buttonCommentPinBackToMap)
        subviewWhite.addConstraintsWithFormat("H:|-(-24)-[v0(101)]", options: [], views: buttonCommentPinBackToMap)
        subviewWhite.addConstraintsWithFormat("V:|-28-[v0(26)]", options: [], views: buttonCommentPinBackToMap)
        buttonCommentPinBackToMap.alpha = 0.0
        
        // Button 1: Back to Comment Pin List
        buttonBackToCommentPinLists = UIButton()
        buttonBackToCommentPinLists.setImage(UIImage(named: "commentPinBackToList"), forState: .Normal)
        buttonBackToCommentPinLists.addTarget(self, action: #selector(CommentPinViewController.actionBackToList(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        subviewWhite.addSubview(buttonBackToCommentPinLists)
        subviewWhite.addConstraintsWithFormat("H:|-(-24)-[v0(101)]", options: [], views: buttonBackToCommentPinLists)
        subviewWhite.addConstraintsWithFormat("V:|-32-[v0(18)]", options: [], views: buttonBackToCommentPinLists)
        
        // Button 2: Comment Pin Option
        buttonOptionOfCommentPin = UIButton()
        buttonOptionOfCommentPin.setImage(UIImage(named: "commentPinOption"), forState: .Normal)
        buttonOptionOfCommentPin.addTarget(self, action: #selector(CommentPinViewController.showCommentPinMoreButtonDetails(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        subviewWhite.addSubview(buttonOptionOfCommentPin)
        subviewWhite.addConstraintsWithFormat("H:[v0(27)]-15-|", options: [], views: buttonOptionOfCommentPin)
        subviewWhite.addConstraintsWithFormat("V:|-23-[v0(37)]", options: [], views: buttonOptionOfCommentPin)
        
        // ScrollView at 65
        commentDetailFullBoardScrollView = UIScrollView(frame: CGRectMake(0, 0, screenWidth, 228))
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
//                tableCommentsForComment.layer.borderColor = UIColor.blackColor().CGColor
//                tableCommentsForComment.layer.borderWidth = 1.0
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
        buttonCommentDetailViewComments.addTarget(self, action: #selector(CommentPinViewController.animationRedSlidingLine(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        uiviewCommentDetailThreeButtons.addSubview(buttonCommentDetailViewComments)
        buttonCommentDetailViewComments.tag = 1
        uiviewCommentDetailThreeButtons.addConstraintsWithFormat("V:|-0-[v0(42)]", options: [], views: buttonCommentDetailViewComments)
        
        // "Active" of this uiview
        buttonCommentDetailViewActive = UIButton()
        buttonCommentDetailViewActive.setImage(UIImage(named: "commentDetailThreeButtonActive"), forState: .Normal)
        buttonCommentDetailViewActive.addTarget(self, action: #selector(CommentPinViewController.animationRedSlidingLine(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        uiviewCommentDetailThreeButtons.addSubview(buttonCommentDetailViewActive)
        buttonCommentDetailViewActive.tag = 3
        uiviewCommentDetailThreeButtons.addConstraintsWithFormat("V:|-0-[v0(42)]", options: [], views: buttonCommentDetailViewActive)
        
        // "People" of this uiview
        buttonCommentDetailViewPeople = UIButton()
        buttonCommentDetailViewPeople.setImage(UIImage(named: "commentDetailThreeButtonPeople"), forState: .Normal)
        buttonCommentDetailViewPeople.addTarget(self, action: #selector(CommentPinViewController.animationRedSlidingLine(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        uiviewCommentDetailThreeButtons.addSubview(buttonCommentDetailViewPeople)
        buttonCommentDetailViewPeople.tag = 5
        uiviewCommentDetailThreeButtons.addConstraintsWithFormat("V:|-0-[v0(42)]", options: [], views: buttonCommentDetailViewPeople)
        
        uiviewCommentDetailThreeButtons.addConstraintsWithFormat("H:|-0-[v0(\(widthOfThreeButtons))]-0-[v1(\(widthOfThreeButtons))]-0-[v2(\(widthOfThreeButtons))]", options: [], views: buttonCommentDetailViewComments, buttonCommentDetailViewActive, buttonCommentDetailViewPeople)
        
//        // Label of Vote Count
//        labelCommentPinVoteCount = UILabel()
//        labelCommentPinVoteCount.text = "0"
//        labelCommentPinVoteCount.font = UIFont(name: "PingFang SC-Semibold", size: 15)
//        labelCommentPinVoteCount.textColor = UIColor(red: 107/255, green: 105/255, blue: 105/255, alpha: 1.0)
//        labelCommentPinVoteCount.textAlignment = .Center
//        uiviewCommentPinDetailMainButtons.addSubview(labelCommentPinVoteCount)
//        uiviewCommentPinDetailMainButtons.addConstraintsWithFormat("H:|-42-[v0(56)]", options: [], views: labelCommentPinVoteCount)
//        uiviewCommentPinDetailMainButtons.addConstraintsWithFormat("V:[v0(22)]-0-|", options: [], views: labelCommentPinVoteCount)
        
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
        
//        // Button 3: Comment Pin DownVote
//        buttonCommentPinDownVote = UIButton()
//        buttonCommentPinDownVote.setImage(UIImage(named: "commentPinDownVoteGray"), forState: .Normal)
//        buttonCommentPinDownVote.addTarget(self, action: #selector(CommentPinViewController.actionDownVoteThisComment(_:)), forControlEvents: UIControlEvents.TouchUpInside)
//        uiviewCommentPinDetailMainButtons.addSubview(buttonCommentPinDownVote)
//        uiviewCommentPinDetailMainButtons.addConstraintsWithFormat("H:|-0-[v0(53)]", options: [], views: buttonCommentPinDownVote)
//        uiviewCommentPinDetailMainButtons.addConstraintsWithFormat("V:[v0(22)]-0-|", options: [], views: buttonCommentPinDownVote)
//        
//        // Button 4: Comment Pin UpVote
//        buttonCommentPinUpVote = UIButton()
//        buttonCommentPinUpVote.setImage(UIImage(named: "commentPinUpVoteGray"), forState: .Normal)
//        buttonCommentPinUpVote.addTarget(self, action: #selector(CommentPinViewController.actionUpvoteThisComment(_:)), forControlEvents: UIControlEvents.TouchUpInside)
//        uiviewCommentPinDetailMainButtons.addSubview(buttonCommentPinUpVote)
//        uiviewCommentPinDetailMainButtons.addConstraintsWithFormat("H:|-91-[v0(53)]", options: [], views: buttonCommentPinUpVote)
//        uiviewCommentPinDetailMainButtons.addConstraintsWithFormat("V:[v0(22)]-0-|", options: [], views: buttonCommentPinUpVote)
        
        // Button 5: Comment Pin Like
        buttonCommentPinLike = UIButton()
        buttonCommentPinLike.setImage(UIImage(named: "commentPinLikeHollow"), forState: .Normal)
        buttonCommentPinLike.addTarget(self, action: #selector(CommentPinViewController.actionLikeThisComment(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        uiviewCommentPinDetailMainButtons.addSubview(buttonCommentPinLike)
        uiviewCommentPinDetailMainButtons.addConstraintsWithFormat("H:[v0(56)]-90-|", options: [], views: buttonCommentPinLike)
        uiviewCommentPinDetailMainButtons.addConstraintsWithFormat("V:[v0(22)]-0-|", options: [], views: buttonCommentPinLike)
        
        // Button 6: Add Comment
        buttonCommentPinAddComment = UIButton()
        buttonCommentPinAddComment.setImage(UIImage(named: "commentPinAddComment"), forState: .Normal)
        buttonCommentPinAddComment.addTarget(self, action: #selector(CommentPinViewController.actionReplyToThisComment(_:)), forControlEvents: UIControlEvents.TouchUpInside)
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
        subviewWhite.addSubview(labelCommentPinTitle)
        subviewWhite.addConstraintsWithFormat("H:[v0(92)]", options: [], views: labelCommentPinTitle)
        subviewWhite.addConstraintsWithFormat("V:|-28-[v0(27)]", options: [], views: labelCommentPinTitle)
        NSLayoutConstraint(item: labelCommentPinTitle, attribute: .CenterX, relatedBy: .Equal, toItem: uiviewCommentPinDetail, attribute: .CenterX, multiplier: 1.0, constant: 0).active = true
        
        // Comment Pin User Avatar
        imageCommentPinUserAvatar = UIImageView()
        imageCommentPinUserAvatar.image = UIImage(named: "commentPinSampleAvatar")
        commentDetailFullBoardScrollView.addSubview(imageCommentPinUserAvatar)
        commentDetailFullBoardScrollView.addConstraintsWithFormat("H:|-15-[v0(50)]", options: [], views: imageCommentPinUserAvatar)
        commentDetailFullBoardScrollView.addConstraintsWithFormat("V:|-15-[v0(50)]", options: [], views: imageCommentPinUserAvatar)
        
        // Comment Pin Username
        labelCommentPinUserName = UILabel()
        labelCommentPinUserName.text = ""
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
        
        // image view appears when saved pin button pressed
        imageViewSaved = UIImageView()
        imageViewSaved.image = UIImage(named: "imageSavedThisPin")
        view.addSubview(imageViewSaved)
        view.addConstraintsWithFormat("H:[v0(182)]", options: [], views: imageViewSaved)
        view.addConstraintsWithFormat("V:|-107-[v0(58)]", options: [], views: imageViewSaved)
        NSLayoutConstraint(item: imageViewSaved, attribute: .CenterX, relatedBy: .Equal, toItem: self.view, attribute: .CenterX, multiplier: 1.0, constant: 0).active = true
        imageViewSaved.layer.zPosition = 104
        imageViewSaved.alpha = 0.0
    }
}
