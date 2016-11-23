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

extension CommentPinDetailViewController {
    
    // Pan gesture for dragging comment pin detail dragging button
    func panActionCommentPinDetailDrag(_ pan: UIPanGestureRecognizer) {
        var resumeTime:Double = 0.583
        if pan.state == .began {
            if uiviewCommentPinDetail.frame.size.height == 255 {
                commentPinSizeFrom = 255
                commentPinSizeTo = screenHeight - 65
            }
            else {
                commentPinSizeFrom = screenHeight - 65
                commentPinSizeTo = 255
            }
        } else if pan.state == .ended || pan.state == .failed || pan.state == .cancelled {
            let location = pan.location(in: view)
            let velocity = pan.velocity(in: view)
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
                UIView.animate(withDuration: resumeTime, animations: {
                    self.draggingButtonSubview.frame.origin.y = self.commentPinSizeTo - 28
                    self.uiviewCommentPinDetail.frame.size.height = self.commentPinSizeTo
                })
            }
            else {
                UIView.animate(withDuration: resumeTime, animations: {
                    self.draggingButtonSubview.frame.origin.y = self.commentPinSizeFrom - 28
                    self.uiviewCommentPinDetail.frame.size.height = self.commentPinSizeFrom
                })
            }
            if uiviewCommentPinDetail.frame.size.height == 255 {
                textviewCommentPinDetail.isScrollEnabled = true
                buttonCommentPinDetailDragToLargeSize.tag = 0
            }
            if uiviewCommentPinDetail.frame.size.height == screenHeight - 65 {
                textviewCommentPinDetail.isScrollEnabled = false
                buttonCommentPinDetailDragToLargeSize.tag = 1
                let newHeight = CGFloat(140 * self.dictCommentsOnCommentDetail.count)
                self.tableCommentsForComment.frame.size.height = newHeight
            }
            
        } else {
            let location = pan.location(in: view)
            if location.y >= 306 {
                self.draggingButtonSubview.center.y = location.y - 65
                self.uiviewCommentPinDetail.frame.size.height = location.y + 14 - 65
            }
        }
    }
    
    // Close more options button when it is open, the subview is under it
    func actionToCloseOtherViews(_ sender: UIButton) {
        if buttonMoreOnCommentCellExpanded == true {
            hideCommentPinMoreButtonDetails()
        }
    }
    
    // Back to comment pin list window when in detail window
    func actionGoToList(_ sender: UIButton!) {
        endEdit()
        if backJustOnce == true {
            backJustOnce = false
            let openedPinListVC = OpenedPinListViewController()
            openedPinListVC.delegate = self
            openedPinListVC.modalPresentationStyle = .overCurrentContext
            self.present(openedPinListVC, animated: false, completion: {
                self.subviewNavigation.center.y -= self.subviewNavigation.frame.size.height
                self.tableCommentsForComment.center.y -= screenHeight
                self.draggingButtonSubview.center.y -= screenHeight
            })
        }
    }
    
    // Show more options button in comment pin detail window
    func showCommentPinMoreButtonDetails(_ sender: UIButton!) {
        endEdit()
        if buttonMoreOnCommentCellExpanded == false {
            buttonFakeTransparentClosingView = UIButton(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
            buttonFakeTransparentClosingView.layer.zPosition = 101
            self.view.addSubview(buttonFakeTransparentClosingView)
            buttonFakeTransparentClosingView.addTarget(self,
                                                       action: #selector(CommentPinDetailViewController.actionToCloseOtherViews(_:)),
                                                       for: .touchUpInside)
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
            
            moreButtonDetailSubview = UIImageView(frame: CGRect(x: subviewXBefore, y: subviewYBefore, width: 0, height: 0))
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
            //                                                 action: #selector(CommentPinDetailViewController.actionShareComment(_:)),
            //                                                 forControlEvents: .TouchUpInside)
            
            buttonEditOnCommentDetail = UIButton(frame: CGRect(x: subviewXBefore, y: subviewYBefore, width: 0, height: 0))
            buttonEditOnCommentDetail.setImage(UIImage(named: "buttonEditOnCommentDetail"), for: UIControlState())
            buttonEditOnCommentDetail.layer.zPosition = 103
            self.view.addSubview(buttonEditOnCommentDetail)
            buttonEditOnCommentDetail.clipsToBounds = true
            buttonEditOnCommentDetail.alpha = 0.0
            buttonEditOnCommentDetail.addTarget(self,
                                                action: #selector(CommentPinDetailViewController.actionEditComment(_:)),
                                                for: .touchUpInside)
            
            // --> Not for 11.01 Dev
            //            buttonSaveOnCommentDetail = UIButton(frame: CGRectMake(subviewXBefore, subviewYBefore, 0, 0))
            //            buttonSaveOnCommentDetail.setImage(UIImage(named: "buttonSaveOnCommentDetail"), forState: .Normal)
            //            buttonSaveOnCommentDetail.layer.zPosition = 103
            //            self.view.addSubview(buttonSaveOnCommentDetail)
            //            buttonSaveOnCommentDetail.clipsToBounds = true
            //            buttonSaveOnCommentDetail.alpha = 0.0
            //            buttonSaveOnCommentDetail.addTarget(self,
            //                                                action: #selector(CommentPinDetailViewController.actionSavedThisPin(_:)),
            //                                                forControlEvents: .TouchUpInside)
            
            buttonDeleteOnCommentDetail = UIButton(frame: CGRect(x: subviewXBefore, y: subviewYBefore, width: 0, height: 0))
            buttonDeleteOnCommentDetail.setImage(UIImage(named: "buttonDeleteOnCommentDetail"), for: UIControlState())
            buttonDeleteOnCommentDetail.layer.zPosition = 103
            self.view.addSubview(buttonDeleteOnCommentDetail)
            buttonDeleteOnCommentDetail.clipsToBounds = true
            buttonDeleteOnCommentDetail.alpha = 0.0
            buttonDeleteOnCommentDetail.addTarget(self,
                                                  action: #selector(CommentPinDetailViewController.actionDeleteThisPin(_:)),
                                                  for: .touchUpInside)
            
            buttonReportOnCommentDetail = UIButton(frame: CGRect(x: subviewXBefore, y: subviewYBefore, width: 0, height: 0))
            buttonReportOnCommentDetail.setImage(UIImage(named: "buttonReportOnCommentDetail"), for: UIControlState())
            buttonReportOnCommentDetail.layer.zPosition = 103
            self.view.addSubview(buttonReportOnCommentDetail)
            buttonReportOnCommentDetail.clipsToBounds = true
            buttonReportOnCommentDetail.alpha = 0.0
            buttonReportOnCommentDetail.addTarget(self,
                                                  action: #selector(CommentPinDetailViewController.actionReportThisPin(_:)),
                                                  for: .touchUpInside)
            
            
            UIView.animate(withDuration: 0.25, animations: ({
                self.moreButtonDetailSubview.frame = CGRect(x: subviewXAfter,
                    y: subviewYAfter,
                    width: subviewWidthAfter,
                    height: subviewHeightAfter)
                //                self.buttonShareOnCommentDetail.frame = CGRectMake(firstButtonX, buttonY, buttonWidth, buttonHeight)
                self.buttonEditOnCommentDetail.frame = CGRect(x: firstButtonX, y: buttonY, width: buttonWidth, height: buttonHeight)
                //                self.buttonSaveOnCommentDetail.frame = CGRectMake(secondButtonX, buttonY, buttonWidth, buttonHeight)
                self.buttonDeleteOnCommentDetail.frame = CGRect(x: secondButtonX, y: buttonY, width: buttonWidth, height: buttonHeight)
                self.buttonReportOnCommentDetail.frame = CGRect(x: thirdButtonX, y: buttonY, width: buttonWidth, height: buttonHeight)
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
    func actionShareComment(_ sender: UIButton!) {
        actionToCloseOtherViews(buttonFakeTransparentClosingView)
        print("Share Clicks!")
    }
    
    func actionEditComment(_ sender: UIButton!) {
        if commentIdSentBySegue == -999 {
            return
        }
        let editCommentPinVC = EditCommentPinViewController()
        editCommentPinVC.delegate = self
        editCommentPinVC.previousCommentContent = textviewCommentPinDetail.text
        editCommentPinVC.commentID = "\(commentIdSentBySegue)"
        self.present(editCommentPinVC, animated: true, completion: nil)
        actionToCloseOtherViews(buttonFakeTransparentClosingView)
    }
    
    func actionReportThisPin(_ sender: UIButton!) {
        let reportCommentPinVC = ReportCommentPinViewController()
        reportCommentPinVC.reportType = 0
        self.present(reportCommentPinVC, animated: true, completion: nil)
        actionToCloseOtherViews(buttonFakeTransparentClosingView)
    }
    
    func actionDeleteThisPin(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Delete Pin", message: "This Pin will be deleted from both the Map and Mapboards, no one can find it anymore. All the comments and replies will also be removed.", preferredStyle: UIAlertControllerStyle.alert)
        let deleteAction = UIAlertAction(title: "Delete", style: UIAlertActionStyle.destructive) { (result : UIAlertAction) -> Void in
            print("Delete")
            let deleteCommentPin = FaeMap()
            deleteCommentPin.deleteCommentById(self.commentIDCommentPinDetailView) {(status: Int, message: Any?) in
                if status / 100 == 2 {
                    print("Successfully delete comment")
                    UIView.animate(withDuration: 0.583, animations: ({
                        self.uiviewCommentPinDetail.center.y -= screenHeight
                    }), completion: { (done: Bool) in
                        if done {
                            self.delegate?.dismissMarkerShadow(false)
                            self.dismiss(animated: false, completion: nil)
                        }
                    })
                }
                else {
                    print("Fail to delete comment")
                }
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
            print("Cancel Deleting")
        }
        alertController.addAction(cancelAction)
        alertController.addAction(deleteAction)
        self.present(alertController, animated: true, completion: nil)
        actionToCloseOtherViews(buttonFakeTransparentClosingView)
    }
    
    // When clicking save button in comment pin detail window's more options button
    func actionSavedThisPin(_ sender: UIButton) {
        if commentIDCommentPinDetailView != "-999" {
            saveThisPin("comment", pinID: commentIDCommentPinDetailView)
        }
        actionToCloseOtherViews(buttonFakeTransparentClosingView)
        UIView.animate(withDuration: 0.5, animations: ({
            self.imageViewSaved.alpha = 1.0
        }), completion: { (done: Bool) in
            if done {
                UIView.animate(withDuration: 0.5, delay: 1.0, options: [], animations: {
                    self.imageViewSaved.alpha = 0.0
                    }, completion: { (done: Bool) in
                        if done {
                            
                        }
                })
            }
        })
    }
    
    func actionBackToMap(_ sender: UIButton) {
        endEdit()
        if inputToolbar != nil {
            self.inputToolbar.isHidden = true
            self.subviewInputToolBar.isHidden = true
        }
        controlBoard.removeFromSuperview()
        UIView.animate(withDuration: 0.583, animations: ({
            self.subviewNavigation.center.y -= self.subviewNavigation.frame.size.height
            self.tableCommentsForComment.center.y -= screenHeight
            self.draggingButtonSubview.center.y -= screenHeight
        }), completion: { (done: Bool) in
            if done {
                self.delegate?.dismissMarkerShadow(true)
                self.dismiss(animated: false, completion: nil)
            }
        })
    }
    
    // When clicking reply button in comment pin detail window
    func actionReplyToThisComment(_ sender: UIButton) {
        if sender.tag == 1 {
            endEdit()
            sender.tag = 0
            buttonCommentPinDetailDragToLargeSize.tag = 0
            if inputToolbar != nil {
                self.inputToolbar.isHidden = true
                self.subviewInputToolBar.isHidden = true
            }
            textviewCommentPinDetail.isScrollEnabled = true
            UIView.animate(withDuration: 0.583, animations: ({
                self.buttonBackToCommentPinLists.alpha = 1.0
                self.buttonCommentPinBackToMap.alpha = 0.0
                self.draggingButtonSubview.frame.origin.y = 292
                self.tableCommentsForComment.scrollToTop()
                self.tableCommentsForComment.frame.size.height = 227
                self.uiviewCommentPinDetail.frame.size.height = 281
                self.textviewCommentPinDetail.frame.size.height = 100
                self.uiviewCommentPinDetailMainButtons.frame.origin.y = 190
                self.uiviewCommentPinDetailGrayBlock.frame.origin.y = 227
                self.uiviewCommentDetailThreeButtons.frame.origin.y = 239
            }), completion: { (done: Bool) in
                if done {
                    
                }
            })
            return
        }
        sender.tag = 1
        if buttonCommentPinDetailDragToLargeSize.tag == 1 {
            if inputToolbar != nil {
                self.inputToolbar.isHidden = false
                self.subviewInputToolBar.isHidden = false
            }
            self.tableCommentsForComment.frame.size.height = screenHeight - 65 - 90
            self.draggingButtonSubview.frame.origin.y = screenHeight - 28
            return
        }
        let numLines = Int(textviewCommentPinDetail.contentSize.height / textviewCommentPinDetail.font!.lineHeight)
        let diffHeight: CGFloat = textviewCommentPinDetail.contentSize.height - textviewCommentPinDetail.frame.size.height
        textviewCommentPinDetail.isScrollEnabled = false
        if inputToolbar != nil {
            self.inputToolbar.isHidden = false
            self.subviewInputToolBar.isHidden = false
        }
        UIView.animate(withDuration: 0.583, animations: ({
            self.buttonBackToCommentPinLists.alpha = 0.0
            self.buttonCommentPinBackToMap.alpha = 1.0
            self.draggingButtonSubview.frame.origin.y = screenHeight - 90
            self.tableCommentsForComment.frame.size.height = screenHeight - 65 - 90
            if numLines > 4 {
                self.uiviewCommentPinDetail.frame.size.height += diffHeight
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
    
    // When clicking dragging button in comment pin detail window
    func actionDraggingThisComment(_ sender: UIButton) {
        if sender.tag == 1 {
            sender.tag = 0
            buttonCommentPinAddComment.tag = 0
            textviewCommentPinDetail.isScrollEnabled = true
            UIView.animate(withDuration: 0.583, animations: ({
                self.buttonBackToCommentPinLists.alpha = 1.0
                self.buttonCommentPinBackToMap.alpha = 0.0
                self.draggingButtonSubview.frame.origin.y = 292
                self.tableCommentsForComment.scrollToTop()
                self.tableCommentsForComment.frame.size.height = 227
                self.uiviewCommentPinDetail.frame.size.height = 281
                self.textviewCommentPinDetail.frame.size.height = 100
                self.uiviewCommentPinDetailMainButtons.frame.origin.y = 190
                self.uiviewCommentPinDetailGrayBlock.frame.origin.y = 227
                self.uiviewCommentDetailThreeButtons.frame.origin.y = 239
            }), completion: { (done: Bool) in
                if done {
                    
                }
            })
            return
        }
        sender.tag = 1
        let numLines = Int(textviewCommentPinDetail.contentSize.height / textviewCommentPinDetail.font!.lineHeight)
        let diffHeight: CGFloat = textviewCommentPinDetail.contentSize.height - textviewCommentPinDetail.frame.size.height
        textviewCommentPinDetail.isScrollEnabled = false
        UIView.animate(withDuration: 0.583, animations: ({
            self.buttonBackToCommentPinLists.alpha = 0.0
            self.buttonCommentPinBackToMap.alpha = 1.0
            self.draggingButtonSubview.frame.origin.y = screenHeight - 28
            self.tableCommentsForComment.frame.size.height = screenHeight - 93
            if numLines > 4 {
                self.uiviewCommentPinDetail.frame.size.height += diffHeight
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
    
    func actionShowActionSheet(_ username: String) {
        let menu = UIAlertController(title: nil, message: "Action", preferredStyle: .actionSheet)
        menu.view.tintColor = colorFae
        let writeReply = UIAlertAction(title: "Write a Reply", style: .default) { (alert: UIAlertAction) in
            self.loadInputToolBar()
            self.inputToolbar.isHidden = false
            self.inputToolbar.contentView.textView.text = "@\(username) "
            self.inputToolbar.contentView.textView.becomeFirstResponder()
            self.lableTextViewPlaceholder.isHidden = true
        }
        let report = UIAlertAction(title: "Report", style: .default) { (alert: UIAlertAction) in
            self.actionReportThisPin(self.buttonReportOnCommentDetail)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (alert: UIAlertAction) in
            
        }
        menu.addAction(writeReply)
        menu.addAction(report)
        menu.addAction(cancel)
        self.present(menu, animated: true, completion: nil)
    }
    
    func tapOutsideToDismissKeyboard(_ sender: UITapGestureRecognizer) {
        endEdit()
    }
}
