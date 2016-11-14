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
        uiviewCommentPinDetail = UIView(frame: CGRect(x: 0, y: 65, width: screenWidth, height: 255))
        uiviewCommentPinDetail.backgroundColor = UIColor.white
        uiviewCommentPinDetail.layer.shadowColor = UIColor(red: 107/255, green: 105/255, blue: 105/255, alpha: 1.0).cgColor
        uiviewCommentPinDetail.layer.shadowOffset = CGSize(width: 0.0, height: 10.0)
        uiviewCommentPinDetail.layer.shadowOpacity = 0.3
        uiviewCommentPinDetail.layer.shadowRadius = 10.0
        uiviewCommentPinDetail.layer.zPosition = 100
        self.view.addSubview(uiviewCommentPinDetail)
        let tapToDismissKeyboard = UITapGestureRecognizer(target: self, action: #selector(CommentPinViewController.tapOutsideToDismissKeyboard(_:)))
        uiviewCommentPinDetail.addGestureRecognizer(tapToDismissKeyboard)
        
        subviewWhite = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 65))
        subviewWhite.backgroundColor = UIColor.white
        self.view.addSubview(subviewWhite)
        subviewWhite.layer.zPosition = 101
        
        // Line at y = 64
        uiviewCommentPinUnderLine01 = UIView(frame: CGRect(x: 0, y: 64, width: screenWidth, height: 1))
        uiviewCommentPinUnderLine01.layer.borderWidth = screenWidth
        uiviewCommentPinUnderLine01.layer.borderColor = UIColor(red: 200/255, green: 199/255, blue: 204/255, alpha: 1.0).cgColor
        subviewWhite.addSubview(uiviewCommentPinUnderLine01)
        
        // Button 0: Back to Map
        buttonCommentPinBackToMap = UIButton()
        buttonCommentPinBackToMap.setImage(UIImage(named: "commentPinBackToMap"), for: UIControlState())
        buttonCommentPinBackToMap.addTarget(self, action: #selector(CommentPinViewController.actionBackToMap(_:)), for: UIControlEvents.touchUpInside)
        subviewWhite.addSubview(buttonCommentPinBackToMap)
        subviewWhite.addConstraintsWithFormat("H:|-(-24)-[v0(101)]", options: [], views: buttonCommentPinBackToMap)
        subviewWhite.addConstraintsWithFormat("V:|-22-[v0(38)]", options: [], views: buttonCommentPinBackToMap)
        buttonCommentPinBackToMap.alpha = 0.0
        
        // Button 1: Back to Comment Pin List
        buttonBackToCommentPinLists = UIButton()
        buttonBackToCommentPinLists.setImage(UIImage(named: "commentPinBackToList"), for: UIControlState())
        buttonBackToCommentPinLists.addTarget(self, action: #selector(CommentPinViewController.actionGoToList(_:)), for: UIControlEvents.touchUpInside)
        subviewWhite.addSubview(buttonBackToCommentPinLists)
        subviewWhite.addConstraintsWithFormat("H:|-(-24)-[v0(101)]", options: [], views: buttonBackToCommentPinLists)
        subviewWhite.addConstraintsWithFormat("V:|-22-[v0(38)]", options: [], views: buttonBackToCommentPinLists)

        // Button 2: Comment Pin Option
        buttonOptionOfCommentPin = UIButton()
        buttonOptionOfCommentPin.setImage(UIImage(named: "commentPinOption"), for: UIControlState())
        buttonOptionOfCommentPin.addTarget(self, action: #selector(CommentPinViewController.showCommentPinMoreButtonDetails(_:)), for: UIControlEvents.touchUpInside)
        subviewWhite.addSubview(buttonOptionOfCommentPin)
        subviewWhite.addConstraintsWithFormat("H:[v0(101)]-(-22)-|", options: [], views: buttonOptionOfCommentPin)
        subviewWhite.addConstraintsWithFormat("V:|-23-[v0(37)]", options: [], views: buttonOptionOfCommentPin)
        
        // ScrollView at 65
        commentDetailFullBoardScrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 228))
        uiviewCommentPinDetail.addSubview(commentDetailFullBoardScrollView)
        commentDetailFullBoardScrollView.isScrollEnabled = false
        commentDetailFullBoardScrollView.contentSize.height = 228
        commentDetailFullBoardScrollView.showsVerticalScrollIndicator = false
        commentDetailFullBoardScrollView.delaysContentTouches = false
        commentDetailFullBoardScrollView.delegate = self
        
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
        textviewCommentPinDetail = UITextView(frame: CGRect(x: 27, y: 75, width: textViewWidth, height: 100))
        textviewCommentPinDetail.text = ""
        textviewCommentPinDetail.font = UIFont(name: "AvenirNext-Regular", size: 18)
        textviewCommentPinDetail.textColor = UIColor(red: 89/255, green: 89/255, blue: 89/255, alpha: 1.0)
        textviewCommentPinDetail.isUserInteractionEnabled = true
        textviewCommentPinDetail.isEditable = false
        textviewCommentPinDetail.textContainerInset = UIEdgeInsets.zero
        textviewCommentPinDetail.indicatorStyle = UIScrollViewIndicatorStyle.white
        commentDetailFullBoardScrollView.addSubview(textviewCommentPinDetail)
        
        // Main buttons' container of comment pin detail
        uiviewCommentPinDetailMainButtons = UIView(frame: CGRect(x: 0, y: 190, width: screenWidth, height: 22))
        commentDetailFullBoardScrollView.addSubview(uiviewCommentPinDetailMainButtons)
        
        // Gray Block
        uiviewCommentPinDetailGrayBlock = UIView(frame: CGRect(x: 0, y: 227, width: screenWidth, height: 12))
        uiviewCommentPinDetailGrayBlock.backgroundColor = UIColor(red: 244/255, green: 244/255, blue: 244/255, alpha: 1.0)
        commentDetailFullBoardScrollView.addSubview(uiviewCommentPinDetailGrayBlock)
        
        // View to hold three buttons
        uiviewCommentDetailThreeButtons = UIView(frame: CGRect(x: 0, y: 239, width: screenWidth, height: 42))
        commentDetailFullBoardScrollView.addSubview(uiviewCommentDetailThreeButtons)
        
        // Table comments for comment
        tableCommentsForComment = UITableView(frame: CGRect(x: 0, y: 281, width: screenWidth, height: 0))
        tableCommentsForComment.delegate = self
        tableCommentsForComment.dataSource = self
        tableCommentsForComment.allowsSelection = false
        tableCommentsForComment.delaysContentTouches = true
        tableCommentsForComment.register(CPCommentsCell.self, forCellReuseIdentifier: "commentPinCommentsCell")
        tableCommentsForComment.isScrollEnabled = false
//                tableCommentsForComment.layer.borderColor = UIColor.blackColor().CGColor
//                tableCommentsForComment.layer.borderWidth = 1.0
        commentDetailFullBoardScrollView.addSubview(tableCommentsForComment)
        
        // Three buttons bottom gray line
        uiviewGrayBaseLine = UIView()
        uiviewGrayBaseLine.layer.borderWidth = 1.0
        uiviewGrayBaseLine.layer.borderColor = UIColor(red: 200/255, green: 199/255, blue: 204/255, alpha: 1.0).cgColor
        uiviewCommentDetailThreeButtons.addSubview(uiviewGrayBaseLine)
        uiviewCommentDetailThreeButtons.addConstraintsWithFormat("H:|-0-[v0(\(screenWidth))]", options: [], views: uiviewGrayBaseLine)
        uiviewCommentDetailThreeButtons.addConstraintsWithFormat("V:[v0(1)]-0-|", options: [], views: uiviewGrayBaseLine)
        
        let widthOfThreeButtons = screenWidth / 2
        
        // Three buttons bottom sliding red line
        uiviewRedSlidingLine = UIView(frame: CGRect(x: 0, y: 40, width: widthOfThreeButtons, height: 2))
        uiviewRedSlidingLine.layer.borderWidth = 1.0
        uiviewRedSlidingLine.layer.borderColor = UIColor(red: 249/255, green: 90/255, blue: 90/255, alpha: 1.0).cgColor
        uiviewCommentDetailThreeButtons.addSubview(uiviewRedSlidingLine)
        
        // "Comments" of this uiview
        buttonCommentDetailViewComments = UIButton()
        buttonCommentDetailViewComments.setImage(UIImage(named: "commentDetailThreeButtonComments"), for: UIControlState())
        buttonCommentDetailViewComments.addTarget(self, action: #selector(CommentPinViewController.animationRedSlidingLine(_:)), for: UIControlEvents.touchUpInside)
        uiviewCommentDetailThreeButtons.addSubview(buttonCommentDetailViewComments)
        buttonCommentDetailViewComments.tag = 1
        uiviewCommentDetailThreeButtons.addConstraintsWithFormat("V:|-0-[v0(42)]", options: [], views: buttonCommentDetailViewComments)
        
        /*
        // "Active" of this uiview
        buttonCommentDetailViewActive = UIButton()
        buttonCommentDetailViewActive.setImage(UIImage(named: "commentDetailThreeButtonActive"), forState: .Normal)
        buttonCommentDetailViewActive.addTarget(self, action: #selector(CommentPinViewController.animationRedSlidingLine(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        uiviewCommentDetailThreeButtons.addSubview(buttonCommentDetailViewActive)
        buttonCommentDetailViewActive.tag = 3
        uiviewCommentDetailThreeButtons.addConstraintsWithFormat("V:|-0-[v0(42)]", options: [], views: buttonCommentDetailViewActive)
        */
        
        // "People" of this uiview
        buttonCommentDetailViewPeople = UIButton()
//        buttonCommentDetailViewPeople.setImage(UIImage(named: "commentDetailThreeButtonPeople"), forState: .Normal)
//        buttonCommentDetailViewPeople.addTarget(self, action: #selector(CommentPinViewController.animationRedSlidingLine(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        uiviewCommentDetailThreeButtons.addSubview(buttonCommentDetailViewPeople)
        buttonCommentDetailViewPeople.tag = 3
        uiviewCommentDetailThreeButtons.addConstraintsWithFormat("V:|-0-[v0(42)]", options: [], views: buttonCommentDetailViewPeople)
        
        uiviewCommentDetailThreeButtons.addConstraintsWithFormat("H:|-0-[v0(\(widthOfThreeButtons))]-0-[v1(\(widthOfThreeButtons))]", options: [], views: buttonCommentDetailViewComments, buttonCommentDetailViewPeople)
        
        /*
        // Label of Vote Count
        labelCommentPinVoteCount = UILabel()
        labelCommentPinVoteCount.text = ""
        labelCommentPinVoteCount.font = UIFont(name: "PingFang SC-Semibold", size: 15)
        labelCommentPinVoteCount.textColor = UIColor(red: 107/255, green: 105/255, blue: 105/255, alpha: 1.0)
        labelCommentPinVoteCount.textAlignment = .Center
        uiviewCommentPinDetailMainButtons.addSubview(labelCommentPinVoteCount)
        uiviewCommentPinDetailMainButtons.addConstraintsWithFormat("H:|-42-[v0(56)]", options: [], views: labelCommentPinVoteCount)
        uiviewCommentPinDetailMainButtons.addConstraintsWithFormat("V:[v0(22)]-0-|", options: [], views: labelCommentPinVoteCount)
        */
        
        // Label of Like Count
        labelCommentPinLikeCount = UILabel()
        labelCommentPinLikeCount.text = ""
        labelCommentPinLikeCount.font = UIFont(name: "PingFang SC-Semibold", size: 15)
        labelCommentPinLikeCount.textColor = UIColor(red: 107/255, green: 105/255, blue: 105/255, alpha: 1.0)
        labelCommentPinLikeCount.textAlignment = .right
        uiviewCommentPinDetailMainButtons.addSubview(labelCommentPinLikeCount)
        uiviewCommentPinDetailMainButtons.addConstraintsWithFormat("H:[v0(41)]-141-|", options: [], views: labelCommentPinLikeCount)
        uiviewCommentPinDetailMainButtons.addConstraintsWithFormat("V:[v0(22)]-0-|", options: [], views: labelCommentPinLikeCount)
        
        // Label of Comments of Coment Pin Count
        labelCommentPinCommentsCount = UILabel()
        labelCommentPinCommentsCount.text = ""
        labelCommentPinCommentsCount.font = UIFont(name: "PingFang SC-Semibold", size: 15)
        labelCommentPinCommentsCount.textColor = UIColor(red: 107/255, green: 105/255, blue: 105/255, alpha: 1.0)
        labelCommentPinCommentsCount.textAlignment = .right
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
        buttonCommentPinLike.setImage(UIImage(named: "commentPinLikeHollow"), for: UIControlState())
        buttonCommentPinLike.addTarget(self, action: #selector(CommentPinViewController.actionLikeThisComment(_:)), for: [.touchUpInside, .touchUpOutside])
        buttonCommentPinLike.addTarget(self, action: #selector(CommentPinViewController.actionHoldingLikeButton(_:)), for: .touchDown)
        uiviewCommentPinDetailMainButtons.addSubview(buttonCommentPinLike)
        uiviewCommentPinDetailMainButtons.addConstraintsWithFormat("H:[v0(56)]-90-|", options: [], views: buttonCommentPinLike)
        uiviewCommentPinDetailMainButtons.addConstraintsWithFormat("V:[v0(22)]-0-|", options: [], views: buttonCommentPinLike)
        buttonCommentPinLike.tag = 0
        buttonCommentPinLike.layer.zPosition = 109
        
        // Button 6: Add Comment
        buttonCommentPinAddComment = UIButton()
        buttonCommentPinAddComment.setImage(UIImage(named: "commentPinAddComment"), for: UIControlState())
        buttonCommentPinAddComment.addTarget(self, action: #selector(CommentPinViewController.actionReplyToThisComment(_:)), for: .touchUpInside)
        buttonCommentPinAddComment.tag = 0
        uiviewCommentPinDetailMainButtons.addSubview(buttonCommentPinAddComment)
        uiviewCommentPinDetailMainButtons.addConstraintsWithFormat("H:[v0(56)]-0-|", options: [], views: buttonCommentPinAddComment)
        uiviewCommentPinDetailMainButtons.addConstraintsWithFormat("V:[v0(22)]-0-|", options: [], views: buttonCommentPinAddComment)
        
        draggingButtonSubview = UIView(frame: CGRect(x: 0, y: 227, width: screenWidth, height: 28))
        draggingButtonSubview.backgroundColor = UIColor.white
        self.uiviewCommentPinDetail.addSubview(draggingButtonSubview)
        draggingButtonSubview.layer.zPosition = 109
        
        // Line at y = 292
        uiviewCommentPinUnderLine02 = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 1))
        uiviewCommentPinUnderLine02.backgroundColor = UIColor(red: 200/255, green: 199/255, blue: 204/255, alpha: 1.0)
        self.draggingButtonSubview.addSubview(uiviewCommentPinUnderLine02)
//        uiviewCommentPinUnderLine02.layer.zPosition = 109
        
        // Button 7: Drag to larger
        buttonCommentPinDetailDragToLargeSize = UIButton(frame: CGRect(x: 0, y: 1, width: screenWidth, height: 27))
        buttonCommentPinDetailDragToLargeSize.backgroundColor = UIColor.white
        buttonCommentPinDetailDragToLargeSize.setImage(UIImage(named: "commentPinDetailDragToLarge"), for: UIControlState())
                buttonCommentPinDetailDragToLargeSize.addTarget(self, action: #selector(CommentPinViewController.actionDraggingThisComment(_:)), for: .touchUpInside)
        self.draggingButtonSubview.addSubview(buttonCommentPinDetailDragToLargeSize)
        buttonCommentPinDetailDragToLargeSize.center.x = screenWidth/2
//        buttonCommentPinDetailDragToLargeSize.layer.zPosition = 109
        buttonCommentPinDetailDragToLargeSize.tag = 0
//        let draggingGesture = UIPanGestureRecognizer(target: self, action: #selector(CommentPinViewController.panActionCommentPinDetailDrag(_:)))
//        buttonCommentPinDetailDragToLargeSize.addGestureRecognizer(draggingGesture)
        
        // Label of Title
        labelCommentPinTitle = UILabel()
        labelCommentPinTitle.text = "Comment"
        labelCommentPinTitle.font = UIFont(name: "AvenirNext-Medium", size: 20)
        labelCommentPinTitle.textColor = UIColor(red: 89/255, green: 89/255, blue: 89/255, alpha: 1.0)
        labelCommentPinTitle.textAlignment = .center
        subviewWhite.addSubview(labelCommentPinTitle)
        subviewWhite.addConstraintsWithFormat("H:[v0(92)]", options: [], views: labelCommentPinTitle)
        subviewWhite.addConstraintsWithFormat("V:|-28-[v0(27)]", options: [], views: labelCommentPinTitle)
        NSLayoutConstraint(item: labelCommentPinTitle, attribute: .centerX, relatedBy: .equal, toItem: uiviewCommentPinDetail, attribute: .centerX, multiplier: 1.0, constant: 0).isActive = true
        
        // Comment Pin User Avatar
        imageCommentPinUserAvatar = UIImageView()
        imageCommentPinUserAvatar.image = UIImage(named: "defaultMan")
        imageCommentPinUserAvatar.layer.cornerRadius = 25
        imageCommentPinUserAvatar.clipsToBounds = true
        imageCommentPinUserAvatar.contentMode = .scaleAspectFill
        commentDetailFullBoardScrollView.addSubview(imageCommentPinUserAvatar)
        commentDetailFullBoardScrollView.addConstraintsWithFormat("H:|-15-[v0(50)]", options: [], views: imageCommentPinUserAvatar)
        commentDetailFullBoardScrollView.addConstraintsWithFormat("V:|-15-[v0(50)]", options: [], views: imageCommentPinUserAvatar)
        
        // Comment Pin Username
        labelCommentPinUserName = UILabel()
        labelCommentPinUserName.text = ""
        labelCommentPinUserName.font = UIFont(name: "AvenirNext-Medium", size: 18)
        labelCommentPinUserName.textColor = UIColor(red: 89/255, green: 89/255, blue: 89/255, alpha: 1.0)
        labelCommentPinTitle.textAlignment = .left
        commentDetailFullBoardScrollView.addSubview(labelCommentPinUserName)
        commentDetailFullBoardScrollView.addConstraintsWithFormat("H:|-80-[v0(250)]", options: [], views: labelCommentPinUserName)
        commentDetailFullBoardScrollView.addConstraintsWithFormat("V:|-19-[v0(25)]", options: [], views: labelCommentPinUserName)
        
        // Timestamp of comment pin detail
        labelCommentPinTimestamp = UILabel()
        labelCommentPinTimestamp.text = ""
        labelCommentPinTimestamp.font = UIFont(name: "AvenirNext-Medium", size: 13)
        labelCommentPinTimestamp.textColor = UIColor(red: 107/255, green: 105/255, blue: 105/255, alpha: 1.0)
        labelCommentPinTimestamp.textAlignment = .left
        commentDetailFullBoardScrollView.addSubview(labelCommentPinTimestamp)
        commentDetailFullBoardScrollView.addConstraintsWithFormat("H:|-80-[v0(200)]", options: [], views: labelCommentPinTimestamp)
        commentDetailFullBoardScrollView.addConstraintsWithFormat("V:|-40-[v0(27)]", options: [], views: labelCommentPinTimestamp)
        
        // Cancel all the touch down delays for uibutton caused by tableview's subviews
//        for view in self.tableCommentsForComment.subviews {
//            if view is UIScrollView {
//                (view as? UIScrollView)!.delaysContentTouches = false
//                break
//            }
//        }
        
        // image view appears when saved pin button pressed
        imageViewSaved = UIImageView()
        imageViewSaved.image = UIImage(named: "imageSavedThisPin")
        view.addSubview(imageViewSaved)
        view.addConstraintsWithFormat("H:[v0(182)]", options: [], views: imageViewSaved)
        view.addConstraintsWithFormat("V:|-107-[v0(58)]", options: [], views: imageViewSaved)
        NSLayoutConstraint(item: imageViewSaved, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1.0, constant: 0).isActive = true
        imageViewSaved.layer.zPosition = 104
        imageViewSaved.alpha = 0.0
        
        loadAnotherToolbar()
        loadPeopleTable()
    }
    
    func loadPeopleTable() {
        tableViewPeople = UITableView(frame: CGRect(x: 0, y: 281, width: screenWidth, height: 0))
        tableViewPeople.delegate = self
        tableViewPeople.dataSource = self
        tableViewPeople.allowsSelection = false
        tableViewPeople.delaysContentTouches = false
        tableViewPeople.register(OPLTableViewCell.self, forCellReuseIdentifier: "commentPinPeopleCell")
        tableViewPeople.isScrollEnabled = false
        //                tableCommentsForComment.layer.borderColor = UIColor.blackColor().CGColor
        //                tableCommentsForComment.layer.borderWidth = 1.0
        commentDetailFullBoardScrollView.addSubview(tableViewPeople)
        tableViewPeople.isHidden = true
    }
    
    func loadAnotherToolbar() {
        // Gray Block
        controlBoard = UIView(frame: CGRect(x: 0, y: 64, width: screenWidth, height: 54))
        controlBoard.backgroundColor = UIColor.white
        self.view.addSubview(controlBoard)
        self.controlBoard.isHidden = true
        controlBoard.layer.zPosition = 110
        
        let anotherGrayBlock = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 12))
        anotherGrayBlock.backgroundColor = UIColor(red: 244/255, green: 244/255, blue: 244/255, alpha: 1.0)
        self.controlBoard.addSubview(anotherGrayBlock)
        
        // Three buttons bottom gray line
        let grayBaseLine = UIView()
        grayBaseLine.layer.borderWidth = 1.0
        grayBaseLine.layer.borderColor = UIColor(red: 200/255, green: 199/255, blue: 204/255, alpha: 1.0).cgColor
        self.controlBoard.addSubview(grayBaseLine)
        self.controlBoard.addConstraintsWithFormat("H:|-0-[v0(\(screenWidth))]", options: [], views: grayBaseLine)
        self.controlBoard.addConstraintsWithFormat("V:[v0(1)]-0-|", options: [], views: grayBaseLine)
        
        // View to hold three buttons
        let threeButtonsContainer = UIView(frame: CGRect(x: 0, y: 12, width: screenWidth, height: 42))
        self.controlBoard.addSubview(threeButtonsContainer)
        
        let widthOfThreeButtons = screenWidth / 2
        
        // Three buttons bottom sliding red line
        anotherRedSlidingLine = UIView(frame: CGRect(x: 0, y: 52, width: widthOfThreeButtons, height: 2))
        anotherRedSlidingLine.layer.borderWidth = 1.0
        anotherRedSlidingLine.layer.borderColor = UIColor(red: 249/255, green: 90/255, blue: 90/255, alpha: 1.0).cgColor
        self.controlBoard.addSubview(anotherRedSlidingLine)
        
        // "Comments" of this uiview
        let comments = UIButton()
        comments.setImage(UIImage(named: "commentDetailThreeButtonComments"), for: UIControlState())
        comments.addTarget(self, action: #selector(CommentPinViewController.animationRedSlidingLine(_:)), for: .touchUpInside)
        threeButtonsContainer.addSubview(comments)
        comments.tag = 1
        threeButtonsContainer.addConstraintsWithFormat("V:|-0-[v0(42)]", options: [], views: comments)
        
        
        // "People" of this uiview
        let people = UIButton()
//        people.setImage(UIImage(named: "commentDetailThreeButtonPeople"), forState: .Normal)
//        people.addTarget(self, action: #selector(CommentPinViewController.animationRedSlidingLine(_:)), forControlEvents: .TouchUpInside)
        threeButtonsContainer.addSubview(people)
        people.tag = 3
        threeButtonsContainer.addConstraintsWithFormat("V:|-0-[v0(42)]", options: [], views: people)
        
        threeButtonsContainer.addConstraintsWithFormat("H:|-0-[v0(\(widthOfThreeButtons))]-0-[v1(\(widthOfThreeButtons))]", options: [], views: comments, people)
        
    }
}
