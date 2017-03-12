//
//  PDButtonActions.swift
//  faeBeta
//
//  Created by Yue on 12/2/16.
//  Copyright © 2016 fae. All rights reserved.
//

import Foundation
import UIKit
import GoogleMaps
import SwiftyJSON

extension PinDetailViewController {

    // Animation of the red sliding line
    func animationRedSlidingLine(_ sender: UIButton) {
        endEdit()
        if sender.tag == 1 {
            tableMode = .talktalk
        } else if sender.tag == 3 {
            
        } else if sender.tag == 5 {
            tableMode = .people
        }
        tableCommentsForPin.reloadData()
        let tag = CGFloat(sender.tag)
        let centerAtOneSix = screenWidth / 6
        let targetCenter = CGFloat(tag * centerAtOneSix)
        UIView.animate(withDuration: 0.25, animations:({
            self.uiviewRedSlidingLine.center.x = targetCenter
            self.anotherRedSlidingLine.center.x = targetCenter
        }), completion: { (done: Bool) in
            if done {
                
            }
        })
    }
    
    func endEdit() {
        buttonKeyBoard.tag = 0
        buttonKeyBoard.isHidden = false
        buttonSticker.isHidden = true
        textViewInput.endEditing(true)
        textViewInput.resignFirstResponder()
        self.emojiView.tag = 0
        if buttonPinAddComment.tag == 1 {
            UIView.animate(withDuration: 0.3) {
                self.emojiView.frame.origin.y = screenHeight
                self.uiviewToolBar.frame.origin.y = screenHeight - self.uiviewToolBar.frame.size.height
                self.tableCommentsForPin.frame.size.height = screenHeight - 65 - self.uiviewToolBar.frame.size.height
                self.draggingButtonSubview.frame.origin.y = screenHeight - self.uiviewToolBar.frame.size.height
            }
        }
    }
    
    func tapOutsideToDismissKeyboard(_ sender: UITapGestureRecognizer) {
        endEdit()
    }
    
    func actionSwitchKeyboard(_ sender: UIButton) {
        if sender == buttonKeyBoard {
            textViewInput.becomeFirstResponder()
            actionHideEmojiView()
            buttonKeyBoard.isHidden = true
            buttonSticker.isHidden = false
        } else {
            textViewInput.resignFirstResponder()
            actionShowEmojiView()
            buttonKeyBoard.isHidden = false
            buttonSticker.isHidden = true
        }
    }
    
    private func actionShowEmojiView() {
        self.emojiView.tag = 1
        self.uiviewToolBar.frame.origin.y = screenHeight - self.uiviewToolBar.frame.size.height - 271
        UIView.animate(withDuration: 0.3) { 
            self.emojiView.frame.origin.y = screenHeight - 271
            self.tableCommentsForPin.frame.size.height = screenHeight - 65 - self.uiviewToolBar.frame.size.height - 271
            self.draggingButtonSubview.frame.origin.y = screenHeight - self.uiviewToolBar.frame.size.height - 271
        }
    }
    
    private func actionHideEmojiView() {
        self.emojiView.tag = 0
        UIView.animate(withDuration: 0.3) {
            self.emojiView.frame.origin.y = screenHeight
        }
    }
    
    // Like comment pin
    func actionLikeThisPin(_ sender: UIButton) {
        endEdit()
        
        if animatingHeartTimer != nil {
            animatingHeartTimer.invalidate()
        }
        
        if sender.tag == 1 && pinIDPinDetailView != "-999" {
            buttonPinLike.setImage(#imageLiteral(resourceName: "pinDetailLikeHeartHollowNew"), for: UIControlState())
            if animatingHeart != nil {
                animatingHeart.image = nil
            }
            unlikeThisPin("\(pinTypeEnum)", pinID: pinIDPinDetailView)
            print("debug animating sender.tag 1")
            print(sender.tag)
            sender.tag = 0
            return
        }
        
        if sender.tag == 0 && pinIDPinDetailView != "-999" {
            buttonPinLike.setImage(#imageLiteral(resourceName: "pinDetailLikeHeartFull"), for: UIControlState())
            self.animateHeart()
            likeThisPin("\(pinTypeEnum)", pinID: pinIDPinDetailView)
            print("debug animating sender.tag 0")
            print(sender.tag)
            sender.tag = 1
        }
    }
    
    func actionHoldingLikeButton(_ sender: UIButton) {
        endEdit()
        buttonPinLike.setImage(#imageLiteral(resourceName: "pinDetailLikeHeartFull"), for: UIControlState())
        animatingHeartTimer = Timer.scheduledTimer(timeInterval: 0.15, target: self, selector: #selector(self.animateHeart), userInfo: nil, repeats: true)
    }
    
    // Upvote comment pin
    func actionUpvoteThisComment(_ sender: UIButton) {
        if isUpVoting {
            return
        }
        
        buttonPinLike.setImage(#imageLiteral(resourceName: "pinDetailLikeHeartFull"), for: UIControlState())
        
        if animatingHeart != nil {
            animatingHeart.image = #imageLiteral(resourceName: "pinDetailLikeHeartFull")
        }
        
        if pinIDPinDetailView != "-999" {
            likeThisPin("\(pinTypeEnum)", pinID: pinIDPinDetailView)
        }
    }
    
    // Down vote comment pin
    func actionDownVoteThisComment(_ sender: UIButton) {
        buttonPinLike.setImage(#imageLiteral(resourceName: "pinDetailLikeHeartHollowNew"), for: UIControlState())
        if animatingHeart != nil {
            animatingHeart.image = #imageLiteral(resourceName: "pinDetailLikeHeartHollowNew")
        }
        if pinIDPinDetailView != "-999" {
            unlikeThisPin("\(pinTypeEnum)", pinID: pinIDPinDetailView)
        }
    }
    
    // Back to pin list window when in detail window
    func actionGoToList(_ sender: UIButton!) {
        endEdit()
        if backJustOnce == true {
            backJustOnce = false
            let openedPinListVC = OpenedPinListViewController()
            openedPinListVC.delegate = self
            openedPinListVC.modalPresentationStyle = .overCurrentContext
            self.present(openedPinListVC, animated: false, completion: {
                if self.uiviewPlaceDetail != nil {
                    self.uiviewPlaceDetail.center.y -= screenHeight
                }
                self.subviewNavigation.center.y -= self.subviewNavigation.frame.size.height
                self.tableCommentsForPin.center.y -= screenHeight
                self.draggingButtonSubview.center.y -= screenHeight
                self.subviewTable.center.y -= screenHeight
            })
        }
    }
    
    func actionBackToMap(_ sender: UIButton) {
        endEdit()
        controlBoard.removeFromSuperview()
        self.delegate?.dismissMarkerShadow(true)
        UIView.animate(withDuration: 0.5, animations: ({
            self.subviewNavigation.center.y -= screenHeight
            self.tableCommentsForPin.center.y -= screenHeight
            self.subviewTable.center.y -= screenHeight
            self.draggingButtonSubview.center.y -= screenHeight
            self.grayBackButton.alpha = 0
            self.pinIcon.alpha = 0
            self.buttonPrevPin.alpha = 0
            self.buttonNextPin.alpha = 0
            if self.uiviewPlaceDetail != nil {
                self.uiviewPlaceDetail.center.y -= screenHeight
            }
        }), completion: { (done: Bool) in
            if done {
                self.dismiss(animated: false, completion: nil)
            }
        })
    }
    
    // When clicking reply button in pin detail window
    func actionReplyToThisPin(_ sender: UIButton) {
        if sender.tag == 1 {
            replyToUser = ""
            lblTxtPlaceholder.text = "Write a Comment..."
            endEdit()
            sender.tag = 0
            buttonPinDetailDragToLargeSize.tag = 0
            buttonPinAddComment.tag = 0
            buttonPinBackToMap.tag = 1
            textviewPinDetail.isScrollEnabled = true
            tableCommentsForPin.isScrollEnabled = false
            buttonPinAddComment.setImage(#imageLiteral(resourceName: "pinDetailShowCommentsHollow"), for: .normal)
            UIView.animate(withDuration: 0.5, animations: ({
                self.buttonBackToPinLists.alpha = 1.0
                self.buttonPinBackToMap.alpha = 0.0
                self.draggingButtonSubview.frame.origin.y = 292
                self.tableCommentsForPin.scrollToTop(animated: true)
                self.tableCommentsForPin.frame.size.height = 227
                self.subviewTable.frame.size.height = 255
                self.uiviewPinDetail.frame.size.height = 281
                self.textviewPinDetail.frame.size.height = self.textViewOriginalHeight
                self.uiviewPinDetailMainButtons.frame.origin.y = 190
                self.uiviewPinDetailGrayBlock.frame.origin.y = 227
                self.uiviewPinDetailThreeButtons.frame.origin.y = 239
                self.uiviewToolBar.frame.origin.y = screenHeight
            }), completion: { (done: Bool) in
            })
            // deal with diff UI according to pinType
            if pinTypeEnum == .media {
                mediaMode = .small
                zoomMedia(.small)
                UIView.animate(withDuration: 0.5, animations: ({
                    self.scrollViewMedia.frame.origin.y = 80
                }), completion: { (done: Bool) in
                    if done {
                        self.textviewPinDetail.isHidden = true
                    }
                })
            }
//            toolBarExtendView.isHidden = true
            return
        }
        sender.tag = 1
        let textViewHeight: CGFloat = textviewPinDetail.contentSize.height
        buttonPinAddComment.setImage(#imageLiteral(resourceName: "pinDetailShowCommentsFull"), for: .normal)
        if buttonPinDetailDragToLargeSize.tag == 1 {
            UIView.animate(withDuration: 0.5, animations: ({
                let toolbarHeight = self.uiviewToolBar.frame.size.height
                self.draggingButtonSubview.frame.origin.y = screenHeight - toolbarHeight
                self.tableCommentsForPin.frame.size.height = screenHeight - 65 - toolbarHeight
                self.subviewTable.frame.size.height = screenHeight - 65 - toolbarHeight
                self.uiviewToolBar.frame.origin.y = screenHeight - toolbarHeight
            }), completion: { (done: Bool) in
            })
            return
        }
        readThisPin("\(pinTypeEnum)", pinID: pinIDPinDetailView)
        textviewPinDetail.isScrollEnabled = false
        tableCommentsForPin.isScrollEnabled = true
        if pinTypeEnum == .media {
            mediaMode = .large
            zoomMedia(.large)
            textviewPinDetail.frame.size.height = textViewOriginalHeight
            textviewPinDetail.isHidden = false
            UIView.animate(withDuration: 0.5, animations: ({
                self.uiviewPinDetail.frame.size.height += 65
                self.textviewPinDetail.frame.size.height += 65
                self.uiviewPinDetailThreeButtons.center.y += 65
                self.uiviewPinDetailGrayBlock.center.y += 65
                self.uiviewPinDetailMainButtons.center.y += 65
                if self.textviewPinDetail.text != "" {
                    self.uiviewPinDetail.frame.size.height += textViewHeight
                    self.textviewPinDetail.frame.size.height += textViewHeight
                    self.uiviewPinDetailThreeButtons.center.y += textViewHeight
                    self.uiviewPinDetailGrayBlock.center.y += textViewHeight
                    self.uiviewPinDetailMainButtons.center.y += textViewHeight
                    self.scrollViewMedia.frame.origin.y += textViewHeight
                }
            }), completion: nil)
            self.scrollViewMedia.scrollToLeft(animated: true)
        }
        else if pinTypeEnum == .comment {
            let numLines = Int(textviewPinDetail.contentSize.height / textviewPinDetail.font!.lineHeight)
            if numLines > 4 {
                let diffHeight: CGFloat = textviewPinDetail.contentSize.height - textviewPinDetail.frame.size.height
                UIView.animate(withDuration: 0.5, animations: ({
                    self.uiviewPinDetail.frame.size.height += diffHeight
                    self.textviewPinDetail.frame.size.height += diffHeight
                    self.uiviewPinDetailThreeButtons.center.y += diffHeight
                    self.uiviewPinDetailGrayBlock.center.y += diffHeight
                    self.uiviewPinDetailMainButtons.center.y += diffHeight
                }), completion: nil)
            }
            
        }
        UIView.animate(withDuration: 0.5, animations: ({
            let toolbarHeight = self.uiviewToolBar.frame.size.height
            self.buttonBackToPinLists.alpha = 0.0
            self.buttonPinBackToMap.alpha = 1.0
            self.draggingButtonSubview.frame.origin.y = screenHeight - toolbarHeight
            self.tableCommentsForPin.frame.size.height = screenHeight - 65 - toolbarHeight
            self.subviewTable.frame.size.height = screenHeight - 65 - toolbarHeight
            self.uiviewToolBar.frame.origin.y = screenHeight - toolbarHeight
        }), completion: { (done: Bool) in
            if done {
                self.tableCommentsForPin.reloadData()
            }
        })
    }
    
    // When clicking dragging button in pin detail window
    func actionDraggingThisPin(_ sender: UIButton) {
        if sender.tag == 1 {
            sender.tag = 0
            buttonPinAddComment.tag = 0
            textviewPinDetail.isScrollEnabled = true
            tableCommentsForPin.isScrollEnabled = false
            UIView.animate(withDuration: 0.5, animations: ({
                self.buttonBackToPinLists.alpha = 1.0
                self.buttonPinBackToMap.alpha = 0.0
                self.draggingButtonSubview.frame.origin.y = 292
                self.tableCommentsForPin.scrollToTop(animated: true)
                self.tableCommentsForPin.frame.size.height = 227
                self.subviewTable.frame.size.height = 255
                self.uiviewPinDetail.frame.size.height = 281
                self.textviewPinDetail.frame.size.height = self.textViewOriginalHeight
                self.uiviewPinDetailMainButtons.frame.origin.y = 190
                self.uiviewPinDetailGrayBlock.frame.origin.y = 227
                self.uiviewPinDetailThreeButtons.frame.origin.y = 239
            }), completion: { (done: Bool) in
            })
            if pinTypeEnum == .media {
                mediaMode = .small
                zoomMedia(.small)
                UIView.animate(withDuration: 0.5, animations: ({
                    self.scrollViewMedia.frame.origin.y = 80
                }), completion: { (done: Bool) in
                    if done {
                        self.textviewPinDetail.isHidden = true
                    }
                })
            }
            return
        }
        readThisPin("\(pinTypeEnum)", pinID: pinIDPinDetailView)
        sender.tag = 1
        let textViewHeight: CGFloat = textviewPinDetail.contentSize.height
        textviewPinDetail.isScrollEnabled = false
        tableCommentsForPin.isScrollEnabled = true
        if pinTypeEnum == .media {
            mediaMode = .large
            zoomMedia(.large)
            textviewPinDetail.frame.size.height = 0
            textviewPinDetail.isHidden = false
            UIView.animate(withDuration: 0.5, animations: ({
                self.uiviewPinDetail.frame.size.height += 65
                self.textviewPinDetail.frame.size.height += 65
                self.uiviewPinDetailThreeButtons.center.y += 65
                self.uiviewPinDetailGrayBlock.center.y += 65
                self.uiviewPinDetailMainButtons.center.y += 65
                if self.textviewPinDetail.text != "" {
                    self.uiviewPinDetail.frame.size.height += textViewHeight
                    self.textviewPinDetail.frame.size.height += textViewHeight
                    self.uiviewPinDetailThreeButtons.center.y += textViewHeight
                    self.uiviewPinDetailGrayBlock.center.y += textViewHeight
                    self.uiviewPinDetailMainButtons.center.y += textViewHeight
                    self.scrollViewMedia.frame.origin.y += textViewHeight
                }
            }), completion: nil)
            self.scrollViewMedia.scrollToLeft(animated: true)
        }
        else if pinTypeEnum == .comment {
            let numLines = Int(textviewPinDetail.contentSize.height / textviewPinDetail.font!.lineHeight)
            if numLines > 4 {
                let diffHeight: CGFloat = textviewPinDetail.contentSize.height - textviewPinDetail.frame.size.height
                UIView.animate(withDuration: 0.5, animations: ({
                    self.uiviewPinDetail.frame.size.height += diffHeight
                    self.textviewPinDetail.frame.size.height += diffHeight
                    self.uiviewPinDetailThreeButtons.center.y += diffHeight
                    self.uiviewPinDetailGrayBlock.center.y += diffHeight
                    self.uiviewPinDetailMainButtons.center.y += diffHeight
                }), completion: nil)
            }
            
        }
        UIView.animate(withDuration: 0.5, animations: ({
            self.buttonBackToPinLists.alpha = 0.0
            self.buttonPinBackToMap.alpha = 1.0
            self.draggingButtonSubview.frame.origin.y = screenHeight - 28
            self.tableCommentsForPin.frame.size.height = screenHeight - 93
            self.subviewTable.frame.size.height = screenHeight - 65
        }), completion: { (done: Bool) in
            if done {
                self.tableCommentsForPin.reloadData()
            }
        })
    }
    
    func actionShowActionSheet(_ username: String) {
        let menu = UIAlertController(title: nil, message: "Action", preferredStyle: .actionSheet)
        menu.view.tintColor = UIColor.faeAppRedColor()
        let writeReply = UIAlertAction(title: "Write a Reply", style: .default) { (alert: UIAlertAction) in
//            self.inputToolbar.contentView.textView.text = "@\(username) "
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
}
