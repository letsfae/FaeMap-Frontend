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
    
    
    func actionBackToMap(_ sender: UIButton) {
        endEdit()
        if inputToolbar != nil {
            self.inputToolbar.isHidden = true
            self.subviewInputToolBar.isHidden = true
        }
        controlBoard.removeFromSuperview()
        self.delegate?.dismissMarkerShadow(true)
        UIView.animate(withDuration: 0.583, animations: ({
            self.subviewNavigation.center.y -= screenHeight
            self.tableCommentsForComment.center.y -= screenHeight
            self.subviewTable.center.y -= screenHeight
            self.draggingButtonSubview.center.y -= screenHeight
            self.grayBackButton.alpha = 0
            self.commentPinIcon.alpha = 0
            self.buttonPrevPin.alpha = 0
            self.buttonNextPin.alpha = 0
        }), completion: { (done: Bool) in
            if done {
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
            tableCommentsForComment.isScrollEnabled = false
            UIView.animate(withDuration: 0.583, animations: ({
                self.buttonBackToCommentPinLists.alpha = 1.0
                self.buttonCommentPinBackToMap.alpha = 0.0
                self.draggingButtonSubview.frame.origin.y = 292
                self.tableCommentsForComment.scrollToTop()
                self.tableCommentsForComment.frame.size.height = 255
                self.uiviewCommentPinDetail.frame.size.height = 281
                self.textviewCommentPinDetail.frame.size.height = 100
                self.uiviewCommentPinDetailMainButtons.frame.origin.y = 190
                self.uiviewCommentPinDetailGrayBlock.frame.origin.y = 227
                self.uiviewPinDetailThreeButtons.frame.origin.y = 239
            }), completion: { (done: Bool) in
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
        if inputToolbar != nil {
            self.inputToolbar.isHidden = false
            self.subviewInputToolBar.isHidden = false
        }
        let numLines = Int(textviewCommentPinDetail.contentSize.height / textviewCommentPinDetail.font!.lineHeight)
        let diffHeight: CGFloat = textviewCommentPinDetail.contentSize.height - textviewCommentPinDetail.frame.size.height
        textviewCommentPinDetail.isScrollEnabled = false
        tableCommentsForComment.isScrollEnabled = true
        UIView.animate(withDuration: 0.583, animations: ({
            self.buttonBackToCommentPinLists.alpha = 0.0
            self.buttonCommentPinBackToMap.alpha = 1.0
            self.draggingButtonSubview.frame.origin.y = screenHeight - 90
            self.tableCommentsForComment.frame.size.height = screenHeight - 65 - 90
            if numLines > 4 {
                self.uiviewCommentPinDetail.frame.size.height += diffHeight
                self.textviewCommentPinDetail.frame.size.height += diffHeight
                self.uiviewPinDetailThreeButtons.center.y += diffHeight
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
            tableCommentsForComment.isScrollEnabled = false
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
                self.uiviewPinDetailThreeButtons.frame.origin.y = 239
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
        tableCommentsForComment.isScrollEnabled = true
        UIView.animate(withDuration: 0.583, animations: ({
            self.buttonBackToCommentPinLists.alpha = 0.0
            self.buttonCommentPinBackToMap.alpha = 1.0
            self.draggingButtonSubview.frame.origin.y = screenHeight - 28
            self.tableCommentsForComment.frame.size.height = screenHeight - 93
            if numLines > 4 {
                self.uiviewCommentPinDetail.frame.size.height += diffHeight
                self.textviewCommentPinDetail.frame.size.height += diffHeight
                self.uiviewPinDetailThreeButtons.center.y += diffHeight
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
        menu.view.tintColor = UIColor.faeAppRedColor()
        let writeReply = UIAlertAction(title: "Write a Reply", style: .default) { (alert: UIAlertAction) in
            self.loadInputToolBar()
            self.inputToolbar.isHidden = false
            self.inputToolbar.contentView.textView.text = "@\(username) "
            self.inputToolbar.contentView.textView.becomeFirstResponder()
            self.lableTextViewPlaceholder.isHidden = true
        }
        let report = UIAlertAction(title: "Report", style: .default) { (alert: UIAlertAction) in
            self.actionReportThisPin(self.buttonReportOnPinDetail)
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
