//
//  CommentPinDetailButtonActions.swift
//  faeBeta
//
//  Created by Yue on 11/6/16.
//  Copyright © 2016 fae. All rights reserved.
//

import Foundation
import UIKit
import GoogleMaps
import SwiftyJSON

extension CommentPinViewController {
    
    // Pan gesture for dragging comment pin detail dragging button
    func panActionCommentPinDetailDrag(pan: UIPanGestureRecognizer) {
        var resumeTime:Double = 0.583
        if pan.state == .Began {
            if uiviewCommentPinDetail.frame.size.height == 255 {
                commentPinSizeFrom = 255
                commentPinSizeTo = screenHeight - 65
            }
            else {
                commentPinSizeFrom = screenHeight - 65
                commentPinSizeTo = 255
            }
        } else if pan.state == .Ended || pan.state == .Failed || pan.state == .Cancelled {
            let location = pan.locationInView(view)
            let velocity = pan.velocityInView(view)
            resumeTime = abs(Double(CGFloat(screenHeight - 256) / velocity.y))
            print("DEBUG: Velocity TESTing")
            print("Velocity in CGPoint.y")
            print(velocity.y)
            print("Resume Time")
            print(resumeTime)
            if resumeTime >= 0.583 {
                resumeTime = 0.583
            }
            if abs(location.y - commentPinSizeFrom) >= 80 {
                UIView.animateWithDuration(resumeTime, animations: {
                    self.draggingButtonSubview.frame.origin.y = self.commentPinSizeTo - 28
                    self.uiviewCommentPinDetail.frame.size.height = self.commentPinSizeTo
                    self.commentDetailFullBoardScrollView.frame.size.height = self.commentPinSizeTo - 28
                })
            }
            else {
                UIView.animateWithDuration(resumeTime, animations: {
                    self.draggingButtonSubview.frame.origin.y = self.commentPinSizeFrom - 28
                    self.uiviewCommentPinDetail.frame.size.height = self.commentPinSizeFrom
                    self.commentDetailFullBoardScrollView.frame.size.height = self.commentPinSizeFrom - 28
                })
            }
            if uiviewCommentPinDetail.frame.size.height == 255 {
                textviewCommentPinDetail.scrollEnabled = true
                commentDetailFullBoardScrollView.scrollEnabled = false
                buttonCommentPinDetailDragToLargeSize.tag = 0
                commentDetailFullBoardScrollView.contentSize.height = 255
            }
            if uiviewCommentPinDetail.frame.size.height == screenHeight - 65 {
                textviewCommentPinDetail.scrollEnabled = false
                commentDetailFullBoardScrollView.scrollEnabled = true
                buttonCommentPinDetailDragToLargeSize.tag = 1
                let newHeight = CGFloat(140 * self.dictCommentsOnCommentDetail.count)
                self.commentDetailFullBoardScrollView.contentSize.height = newHeight + 281
                self.tableCommentsForComment.frame.size.height = newHeight
            }
            
        } else {
            let location = pan.locationInView(view)
            if location.y >= 306 {
                self.draggingButtonSubview.center.y = location.y - 65
                self.uiviewCommentPinDetail.frame.size.height = location.y + 14 - 65
                self.commentDetailFullBoardScrollView.frame.size.height = location.y + 14 - 65
            }
        }
    }
    
    // Close more options button when it is open, the subview is under it
    func actionToCloseOtherViews(sender: UIButton) {
        if buttonMoreOnCommentCellExpanded == true {
            hideCommentPinMoreButtonDetails()
        }
    }
    
    // Back to comment pin list window when in detail window
    func actionGoToList(sender: UIButton!) {
        endEdit()
        if backJustOnce == true {
            backJustOnce = false
            let openedPinListVC = OpenedPinListViewController()
            openedPinListVC.delegate = self
            openedPinListVC.modalPresentationStyle = .OverCurrentContext
            self.presentViewController(openedPinListVC, animated: false, completion: {
                self.subviewWhite.center.y -= self.subviewWhite.frame.size.height
                self.uiviewCommentPinDetail.center.y -= screenHeight
            })
        }
    }
    
    // Show more options button in comment pin detail window
    func showCommentPinMoreButtonDetails(sender: UIButton!) {
        endEdit()
        if buttonMoreOnCommentCellExpanded == false {
            buttonFakeTransparentClosingView = UIButton(frame: CGRectMake(0, 0, screenWidth, screenHeight))
            buttonFakeTransparentClosingView.layer.zPosition = 101
            self.view.addSubview(buttonFakeTransparentClosingView)
            buttonFakeTransparentClosingView.addTarget(self,
                                                       action: #selector(CommentPinViewController.actionToCloseOtherViews(_:)),
                                                       forControlEvents: .TouchUpInside)
            let subviewXBefore: CGFloat = 400 / 414 * screenWidth
            let subviewYBefore: CGFloat = 57 / 414 * screenWidth
            var subviewXAfter: CGFloat = 171 / 414 * screenWidth
            let subviewYAfter: CGFloat = 57 / 414 * screenWidth
            var subviewWidthAfter: CGFloat = 229 / 414 * screenWidth
            let subviewHeightAfter: CGFloat = 110 / 414 * screenWidth
            let firstButtonX: CGFloat = 192 / 414 * screenWidth
            let secondButtonX: CGFloat = 262 / 414 * screenWidth
            let thirdButtonX: CGFloat = 332 / 414 * screenWidth
            let buttonY: CGFloat = 97 / 414 * screenWidth
            let buttonWidth: CGFloat = 44 / 414 * screenWidth
            let buttonHeight: CGFloat = 51 / 414 * screenWidth
            
            var moreOptionBackgroundImage = "moreButtonDetailSubview"
            
            if thisIsMyPin == false {
                subviewXAfter = 308 / 414 * screenWidth
                subviewWidthAfter = 92 / 414 * screenWidth
                moreOptionBackgroundImage = "moreButtonDetailSubviewNotMyPin"
            }
            
            moreButtonDetailSubview = UIImageView(frame: CGRectMake(subviewXBefore, subviewYBefore, 0, 0))
            moreButtonDetailSubview.image = UIImage(named: moreOptionBackgroundImage)
            moreButtonDetailSubview.layer.zPosition = 102
            self.view.addSubview(moreButtonDetailSubview)
            
            // --> Not for 11.01 Dev
            //            buttonShareOnCommentDetail = UIButton(frame: CGRectMake(subviewXBefore, subviewYBefore, 0, 0))
            //            buttonShareOnCommentDetail.setImage(UIImage(named: "buttonShareOnCommentDetail"), forState: .Normal)
            //            buttonShareOnCommentDetail.layer.zPosition = 103
            //            self.view.addSubview(buttonShareOnCommentDetail)
            //            buttonShareOnCommentDetail.clipsToBounds = true
            //            buttonShareOnCommentDetail.alpha = 0.0
            //            buttonShareOnCommentDetail.addTarget(self,
            //                                                 action: #selector(CommentPinViewController.actionShareComment(_:)),
            //                                                 forControlEvents: .TouchUpInside)
            
            buttonEditOnCommentDetail = UIButton(frame: CGRectMake(subviewXBefore, subviewYBefore, 0, 0))
            buttonEditOnCommentDetail.setImage(UIImage(named: "buttonEditOnCommentDetail"), forState: .Normal)
            buttonEditOnCommentDetail.layer.zPosition = 103
            self.view.addSubview(buttonEditOnCommentDetail)
            buttonEditOnCommentDetail.clipsToBounds = true
            buttonEditOnCommentDetail.alpha = 0.0
            buttonEditOnCommentDetail.addTarget(self,
                                                action: #selector(CommentPinViewController.actionEditComment(_:)),
                                                forControlEvents: .TouchUpInside)
            
            // --> Not for 11.01 Dev
            //            buttonSaveOnCommentDetail = UIButton(frame: CGRectMake(subviewXBefore, subviewYBefore, 0, 0))
            //            buttonSaveOnCommentDetail.setImage(UIImage(named: "buttonSaveOnCommentDetail"), forState: .Normal)
            //            buttonSaveOnCommentDetail.layer.zPosition = 103
            //            self.view.addSubview(buttonSaveOnCommentDetail)
            //            buttonSaveOnCommentDetail.clipsToBounds = true
            //            buttonSaveOnCommentDetail.alpha = 0.0
            //            buttonSaveOnCommentDetail.addTarget(self,
            //                                                action: #selector(CommentPinViewController.actionSavedThisPin(_:)),
            //                                                forControlEvents: .TouchUpInside)
            
            buttonDeleteOnCommentDetail = UIButton(frame: CGRectMake(subviewXBefore, subviewYBefore, 0, 0))
            buttonDeleteOnCommentDetail.setImage(UIImage(named: "buttonDeleteOnCommentDetail"), forState: .Normal)
            buttonDeleteOnCommentDetail.layer.zPosition = 103
            self.view.addSubview(buttonDeleteOnCommentDetail)
            buttonDeleteOnCommentDetail.clipsToBounds = true
            buttonDeleteOnCommentDetail.alpha = 0.0
            buttonDeleteOnCommentDetail.addTarget(self,
                                                  action: #selector(CommentPinViewController.actionDeleteThisPin(_:)),
                                                  forControlEvents: .TouchUpInside)
            
            buttonReportOnCommentDetail = UIButton(frame: CGRectMake(subviewXBefore, subviewYBefore, 0, 0))
            buttonReportOnCommentDetail.setImage(UIImage(named: "buttonReportOnCommentDetail"), forState: .Normal)
            buttonReportOnCommentDetail.layer.zPosition = 103
            self.view.addSubview(buttonReportOnCommentDetail)
            buttonReportOnCommentDetail.clipsToBounds = true
            buttonReportOnCommentDetail.alpha = 0.0
            buttonReportOnCommentDetail.addTarget(self,
                                                  action: #selector(CommentPinViewController.actionReportThisPin(_:)),
                                                  forControlEvents: .TouchUpInside)
            
            
            UIView.animateWithDuration(0.25, animations: ({
                self.moreButtonDetailSubview.frame = CGRectMake(subviewXAfter,
                    subviewYAfter,
                    subviewWidthAfter,
                    subviewHeightAfter)
                //                self.buttonShareOnCommentDetail.frame = CGRectMake(firstButtonX, buttonY, buttonWidth, buttonHeight)
                self.buttonEditOnCommentDetail.frame = CGRectMake(firstButtonX, buttonY, buttonWidth, buttonHeight)
                //                self.buttonSaveOnCommentDetail.frame = CGRectMake(secondButtonX, buttonY, buttonWidth, buttonHeight)
                self.buttonDeleteOnCommentDetail.frame = CGRectMake(secondButtonX, buttonY, buttonWidth, buttonHeight)
                self.buttonReportOnCommentDetail.frame = CGRectMake(thirdButtonX, buttonY, buttonWidth, buttonHeight)
                //                self.buttonShareOnCommentDetail.alpha = 1.0
                //                self.buttonSaveOnCommentDetail.alpha = 1.0
                if self.thisIsMyPin == true {
                    self.buttonEditOnCommentDetail.alpha = 1.0
                    self.buttonDeleteOnCommentDetail.alpha = 1.0
                }
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
        actionToCloseOtherViews(buttonFakeTransparentClosingView)
        print("Share Clicks!")
    }
    
    func actionEditComment(sender: UIButton!) {
        if commentIdSentBySegue == -999 {
            return
        }
        let editCommentPinVC = EditCommentPinViewController()
        editCommentPinVC.delegate = self
        editCommentPinVC.previousCommentContent = textviewCommentPinDetail.text
        editCommentPinVC.commentID = "\(commentIdSentBySegue)"
        self.presentViewController(editCommentPinVC, animated: true, completion: nil)
        actionToCloseOtherViews(buttonFakeTransparentClosingView)
    }
    
    func actionReportThisPin(sender: UIButton!) {
        let reportCommentPinVC = ReportCommentPinViewController()
        self.presentViewController(reportCommentPinVC, animated: true, completion: nil)
        actionToCloseOtherViews(buttonFakeTransparentClosingView)
    }
    
    func actionDeleteThisPin(sender: UIButton) {
        let alertController = UIAlertController(title: "Delete Pin", message: "This Pin will be deleted from both the Map and Mapboards, no one can find it anymore. All the comments and replies will also be removed.", preferredStyle: UIAlertControllerStyle.Alert)
        let deleteAction = UIAlertAction(title: "Delete", style: UIAlertActionStyle.Destructive) { (result : UIAlertAction) -> Void in
            print("Delete")
            let deleteCommentPin = FaeMap()
            deleteCommentPin.deleteCommentById(self.commentIDCommentPinDetailView) {(status: Int, message: AnyObject?) in
                if status / 100 == 2 {
                    print("Successfully delete comment")
                    UIView.animateWithDuration(0.583, animations: ({
                        self.uiviewCommentPinDetail.center.y -= screenHeight
                    }), completion: { (done: Bool) in
                        if done {
                            self.delegate?.dismissMarkerShadow(false)
                            self.dismissViewControllerAnimated(false, completion: nil)
                        }
                    })
                }
                else {
                    print("Fail to delete comment")
                }
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default) { (result : UIAlertAction) -> Void in
            print("Cancel Deleting")
        }
        alertController.addAction(cancelAction)
        alertController.addAction(deleteAction)
        self.presentViewController(alertController, animated: true, completion: nil)
        actionToCloseOtherViews(buttonFakeTransparentClosingView)
    }
    
    // When clicking save button in comment pin detail window's more options button
    func actionSavedThisPin(sender: UIButton) {
        if commentIDCommentPinDetailView != "-999" {
            saveThisPin("comment", pinID: commentIDCommentPinDetailView)
        }
        actionToCloseOtherViews(buttonFakeTransparentClosingView)
        UIView.animateWithDuration(0.5, animations: ({
            self.imageViewSaved.alpha = 1.0
        }), completion: { (done: Bool) in
            if done {
                UIView.animateWithDuration(0.5, delay: 1.0, options: [], animations: {
                    self.imageViewSaved.alpha = 0.0
                    }, completion: { (done: Bool) in
                        if done {
                            
                        }
                })
            }
        })
    }
    
    func actionBackToMap(sender: UIButton) {
        endEdit()
        inputToolbar.hidden = true
        controlBoard.removeFromSuperview()
        UIView.animateWithDuration(0.583, animations: ({
            self.subviewWhite.center.y -= self.subviewWhite.frame.size.height
            self.uiviewCommentPinDetail.center.y -= screenHeight+150
        }), completion: { (done: Bool) in
            if done {
                self.delegate?.dismissMarkerShadow(true)
                self.dismissViewControllerAnimated(false, completion: nil)
            }
        })
    }
    
    // When clicking reply button in comment pin detail window
    func actionReplyToThisComment(sender: UIButton) {
        if sender.tag == 1 {
            endEdit()
            sender.tag = 0
            buttonCommentPinDetailDragToLargeSize.tag = 0
            self.inputToolbar.hidden = true
            textviewCommentPinDetail.scrollEnabled = true
            commentDetailFullBoardScrollView.scrollEnabled = false
            self.commentDetailFullBoardScrollView.frame.size.height = screenHeight - 65
            self.uiviewCommentPinDetail.frame.size.height = screenHeight - 65
            UIView.animateWithDuration(0.583, animations: ({
                self.buttonBackToCommentPinLists.alpha = 1.0
                self.buttonCommentPinBackToMap.alpha = 0.0
                self.draggingButtonSubview.frame.origin.y = 227
                self.commentDetailFullBoardScrollView.contentSize.height = 281
                self.commentDetailFullBoardScrollView.frame.size.height = 228
                self.commentDetailFullBoardScrollView.scrollToTop()
                self.uiviewCommentPinDetail.frame.size.height = 255
            }), completion: { (done: Bool) in
                if done {
                    
                }
            })
            return
        }
        sender.tag = 1
        if buttonCommentPinDetailDragToLargeSize.tag == 1 {
            self.inputToolbar.hidden = false
            self.commentDetailFullBoardScrollView.frame.size.height = screenHeight - 65 - 90
            self.uiviewCommentPinDetail.frame.size.height = screenHeight - 65
            self.draggingButtonSubview.frame.origin.y = screenHeight - 65
            return
        }
        let numLines = Int(textviewCommentPinDetail.contentSize.height / textviewCommentPinDetail.font!.lineHeight)
        let diffHeight: CGFloat = textviewCommentPinDetail.contentSize.height - textviewCommentPinDetail.frame.size.height
        let newHeightComments = CGFloat(140 * self.dictCommentsOnCommentDetail.count)
        let newHeightPeople = CGFloat(76 * self.dictPeopleOfCommentDetail.count)
        self.commentDetailFullBoardScrollView.contentSize.height = newHeightComments + 281
        self.tableCommentsForComment.frame.size.height = newHeightComments
        self.tableViewPeople.frame.size.height = newHeightPeople
        textviewCommentPinDetail.scrollEnabled = false
        commentDetailFullBoardScrollView.scrollEnabled = true
        UIView.animateWithDuration(0.583, animations: ({
            self.buttonBackToCommentPinLists.alpha = 0.0
            self.buttonCommentPinBackToMap.alpha = 1.0
            self.draggingButtonSubview.frame.origin.y = screenHeight - 65
            // -65 for header, -27 for dragging button
            self.commentDetailFullBoardScrollView.frame.size.height = screenHeight - 65
            self.uiviewCommentPinDetail.frame.size.height = screenHeight - 65
            if numLines > 4 {
                // 420 is table height, 281 is fixed
                self.commentDetailFullBoardScrollView.contentSize.height += diffHeight
                self.tableCommentsForComment.frame.size.height += diffHeight
                self.textviewCommentPinDetail.frame.size.height += diffHeight
                self.uiviewCommentDetailThreeButtons.center.y += diffHeight
                self.uiviewCommentPinDetailGrayBlock.center.y += diffHeight
                self.uiviewCommentPinDetailMainButtons.center.y += diffHeight
            }
        }), completion: { (done: Bool) in
            if done {
                self.inputToolbar.hidden = false
                self.commentDetailFullBoardScrollView.frame.size.height = screenHeight - 65 - 90
                self.uiviewCommentPinDetail.frame.size.height = screenHeight - 65
            }
        })
    }
    
    // When clicking dragging button in comment pin detail window
    func actionDraggingThisComment(sender: UIButton) {
        if sender.tag == 1 {
            sender.tag = 0
            buttonCommentPinAddComment.tag = 0
            textviewCommentPinDetail.scrollEnabled = true
            commentDetailFullBoardScrollView.scrollEnabled = false
            UIView.animateWithDuration(0.583, animations: ({
                self.buttonBackToCommentPinLists.alpha = 1.0
                self.buttonCommentPinBackToMap.alpha = 0.0
                self.draggingButtonSubview.frame.origin.y = 227
                self.commentDetailFullBoardScrollView.contentSize.height = 281
                self.commentDetailFullBoardScrollView.frame.size.height = 228
                self.commentDetailFullBoardScrollView.scrollToTop()
                self.uiviewCommentPinDetail.frame.size.height = 255
            }), completion: { (done: Bool) in
                if done {
                    
                }
            })
            return
        }
        sender.tag = 1
        let numLines = Int(textviewCommentPinDetail.contentSize.height / textviewCommentPinDetail.font!.lineHeight)
        let diffHeight: CGFloat = textviewCommentPinDetail.contentSize.height - textviewCommentPinDetail.frame.size.height
        let newHeightComments = CGFloat(140 * self.dictCommentsOnCommentDetail.count)
        let newHeightPeople = CGFloat(76 * self.dictPeopleOfCommentDetail.count)
        self.commentDetailFullBoardScrollView.contentSize.height = newHeightComments + 281
        self.tableCommentsForComment.frame.size.height = newHeightComments
        self.tableViewPeople.frame.size.height = newHeightPeople
        textviewCommentPinDetail.scrollEnabled = false
        commentDetailFullBoardScrollView.scrollEnabled = true
        UIView.animateWithDuration(0.583, animations: ({
            self.buttonBackToCommentPinLists.alpha = 0.0
            self.buttonCommentPinBackToMap.alpha = 1.0
            self.draggingButtonSubview.frame.origin.y = screenHeight - 93
            // -65 for header, -27 for dragging button
            self.commentDetailFullBoardScrollView.frame.size.height = screenHeight - 93
            self.uiviewCommentPinDetail.frame.size.height = screenHeight - 65
            if numLines > 4 {
                // 420 is table height, 281 is fixed
                self.commentDetailFullBoardScrollView.contentSize.height += diffHeight
                self.tableCommentsForComment.frame.size.height += diffHeight
                self.textviewCommentPinDetail.frame.size.height += diffHeight
                self.uiviewCommentDetailThreeButtons.center.y += diffHeight
                self.uiviewCommentPinDetailGrayBlock.center.y += diffHeight
                self.uiviewCommentPinDetailMainButtons.center.y += diffHeight
            }
        }), completion: { (done: Bool) in
            if done {
                
            }
        })
    }
    
    func actionShowActionSheet(username: String) {
        let menu = UIAlertController(title: nil, message: "Action", preferredStyle: .ActionSheet)
        menu.view.tintColor = colorFae
        let writeReply = UIAlertAction(title: "Write a Reply", style: .Default) { (alert: UIAlertAction) in
            self.inputToolbar.hidden = false
            self.inputToolbar.contentView.textView.text = "@\(username) "
            self.inputToolbar.contentView.textView.becomeFirstResponder()
            self.lableTextViewPlaceholder.hidden = true
        }
        let report = UIAlertAction(title: "Report", style: .Default) { (alert: UIAlertAction) in
            self.actionReportThisPin(self.buttonReportOnCommentDetail)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .Cancel) { (alert: UIAlertAction) in
            
        }
        menu.addAction(writeReply)
        menu.addAction(report)
        menu.addAction(cancel)
        self.presentViewController(menu, animated: true, completion: nil)
    }
    
    func tapOutsideToDismissKeyboard(sender: UITapGestureRecognizer) {
        endEdit()
    }
}
