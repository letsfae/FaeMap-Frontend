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
    
    func actionGotoPin(_ sender: UIButton) {
        if sender == buttonPrevPin {
            self.delegate?.goTo(nextPin: false)
        } else {
            self.delegate?.goTo(nextPin: true)
        }
        initPlaceBasicInfo()
        manageYelpData()
    }
    
    func actionDoAnony() {
        switchAnony.setOn(!switchAnony.isOn, animated: true)
    }

    // Animation of the red sliding line
    func animationRedSlidingLine(_ sender: UIButton) {
        if sender.tag == 1 {
            tableMode = .talktalk
        } else if sender.tag == 3 {
            tableMode = .feelings
        } else if sender.tag == 5 {
            tableMode = .people
        }
        endEdit()
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
        textViewInput.endEditing(true)
        textViewInput.resignFirstResponder()
        self.emojiView.tag = 0
        if buttonPinAddComment.tag == 1 || buttonPinDetailDragToLargeSize.tag == 1 {
            UIView.animate(withDuration: 0.3) {
                self.emojiView.frame.origin.y = screenHeight
                if self.uiviewAnonymous.isHidden {
                    if self.tableMode == .talktalk {
                        self.tableCommentsForPin.frame.size.height = screenHeight - 65 - self.uiviewToolBar.frame.size.height
                        self.draggingButtonSubview.frame.origin.y = screenHeight - self.uiviewToolBar.frame.size.height
                        self.uiviewToolBar.frame.origin.y = screenHeight - self.uiviewToolBar.frame.size.height
                        self.uiviewAnonymous.frame.origin.y = screenHeight - 51
                    } else {
                        self.tableCommentsForPin.frame.size.height = screenHeight - 65
                        self.draggingButtonSubview.frame.origin.y = screenHeight
                        self.uiviewToolBar.frame.origin.y = screenHeight
                        self.uiviewAnonymous.frame.origin.y = screenHeight
                    }
                    
                } else {
                    if self.tableMode == .talktalk {
                        self.tableCommentsForPin.frame.size.height = screenHeight - 65 - 51
                        self.draggingButtonSubview.frame.origin.y = screenHeight - 51
                        self.uiviewToolBar.frame.origin.y = screenHeight - self.uiviewToolBar.frame.size.height
                        self.uiviewAnonymous.frame.origin.y = screenHeight - 51
                    } else {
                        self.tableCommentsForPin.frame.size.height = screenHeight - 65
                        self.draggingButtonSubview.frame.origin.y = screenHeight
                        self.uiviewToolBar.frame.origin.y = screenHeight
                        self.uiviewAnonymous.frame.origin.y = screenHeight
                    }
                }
            }
        }
    }
    
    func tapOutsideToDismissKeyboard(_ sender: UITapGestureRecognizer) {
        endEdit()
    }
    
    func actionShowHideAnony(_ sender: UIButton) {
        if sender == btnCommentOption {
            self.tableCommentsForPin.frame.size.height = screenHeight - 65 - 51 - keyboardHeight
            self.draggingButtonSubview.frame.origin.y = screenHeight - 51 - keyboardHeight
            uiviewAnonymous.isHidden = false
            uiviewToolBar.isHidden = true
        } else if sender == btnHideAnony {
            self.tableCommentsForPin.frame.size.height = screenHeight - 65 - self.uiviewToolBar.frame.size.height - keyboardHeight
            self.draggingButtonSubview.frame.origin.y = screenHeight - self.uiviewToolBar.frame.size.height - keyboardHeight
            uiviewAnonymous.isHidden = true
            uiviewToolBar.isHidden = false
        }
    }
    
    func actionSwitchKeyboard(_ sender: UIButton) {
        if emojiView.tag == 1 {
            textViewInput.becomeFirstResponder()
            actionHideEmojiView()
        } else {
            textViewInput.resignFirstResponder()
            actionShowEmojiView()
        }
    }
    
    private func actionShowEmojiView() {
        buttonSticker.setImage(#imageLiteral(resourceName: "stickerChosen"), for: .normal)
        self.emojiView.tag = 1
        self.uiviewToolBar.frame.origin.y = screenHeight - self.uiviewToolBar.frame.size.height - 271
        UIView.animate(withDuration: 0.3) { 
            self.emojiView.frame.origin.y = screenHeight - 271
            self.tableCommentsForPin.frame.size.height = screenHeight - 65 - self.uiviewToolBar.frame.size.height - 271
            self.draggingButtonSubview.frame.origin.y = screenHeight - self.uiviewToolBar.frame.size.height - 271
        }
    }
    
    func actionHideEmojiView() {
        buttonSticker.setImage(#imageLiteral(resourceName: "sticker"), for: .normal)
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
        
        if sender.tag == 1 && PinDetailViewController.pinIDPinDetailView != "-999" {
            buttonPinLike.setImage(#imageLiteral(resourceName: "pinDetailLikeHeartHollowNew"), for: UIControlState())
            if animatingHeart != nil {
                animatingHeart.image = nil
            }
            unlikeThisPin("\(PinDetailViewController.pinTypeEnum)", pinID: PinDetailViewController.pinIDPinDetailView)
            print("debug animating sender.tag 1")
            print(sender.tag)
            sender.tag = 0
            return
        }
        
        if sender.tag == 0 && PinDetailViewController.pinIDPinDetailView != "-999" {
            buttonPinLike.setImage(#imageLiteral(resourceName: "pinDetailLikeHeartFull"), for: UIControlState())
            self.animateHeart()
            likeThisPin("\(PinDetailViewController.pinTypeEnum)", pinID: PinDetailViewController.pinIDPinDetailView)
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
        
        if PinDetailViewController.pinIDPinDetailView != "-999" {
            likeThisPin("\(PinDetailViewController.pinTypeEnum)", pinID: PinDetailViewController.pinIDPinDetailView)
        }
    }
    
    // Down vote comment pin
    func actionDownVoteThisComment(_ sender: UIButton) {
        buttonPinLike.setImage(#imageLiteral(resourceName: "pinDetailLikeHeartHollowNew"), for: UIControlState())
        if animatingHeart != nil {
            animatingHeart.image = #imageLiteral(resourceName: "pinDetailLikeHeartHollowNew")
        }
        if PinDetailViewController.pinIDPinDetailView != "-999" {
            unlikeThisPin("\(PinDetailViewController.pinTypeEnum)", pinID: PinDetailViewController.pinIDPinDetailView)
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
            buttonPrevPin.isHidden = true
            buttonNextPin.isHidden = true
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
            if PinDetailViewController.pinTypeEnum != .place {
                self.uiviewFeelingBar.alpha = 0
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
            buttonPinDetailDragToLargeSize.tag = 0
            buttonPinAddComment.tag = 0
            buttonPinBackToMap.tag = 1
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
                self.uiviewPinDetailMainButtons.frame.origin.y = 185
                self.uiviewPinDetailGrayBlock.frame.origin.y = 227
                self.uiviewPinDetailThreeButtons.frame.origin.y = 232
                self.uiviewToolBar.frame.origin.y = screenHeight
            }), completion: { (done: Bool) in
            })
            // deal with diff UI according to pinType
            if PinDetailViewController.pinTypeEnum == .media {
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
        sender.tag = 1
        let textViewHeight: CGFloat = textviewPinDetail.contentSize.height
        if buttonPinDetailDragToLargeSize.tag == 1 && sender == buttonPinAddComment {
            self.textViewInput.becomeFirstResponder()
            return
        }
        readThisPin("\(PinDetailViewController.pinTypeEnum)", pinID: PinDetailViewController.pinIDPinDetailView)
        textviewPinDetail.isScrollEnabled = false
        tableCommentsForPin.isScrollEnabled = true
        if PinDetailViewController.pinTypeEnum == .media {
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
        else if PinDetailViewController.pinTypeEnum == .comment {
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
            var toolbarHeight = self.uiviewToolBar.frame.size.height
            if PinDetailViewController.pinTypeEnum == .chat_room {
                toolbarHeight = 0
            }
            self.draggingButtonSubview.frame.origin.y = screenHeight - toolbarHeight
            self.tableCommentsForPin.frame.size.height = screenHeight - 65 - toolbarHeight
            self.subviewTable.frame.size.height = screenHeight - 65 - toolbarHeight
            self.uiviewToolBar.frame.origin.y = screenHeight - toolbarHeight
        }), completion: { (done: Bool) in
            if done {
                if PinDetailViewController.pinTypeEnum != .chat_room {
                    self.tableCommentsForPin.reloadData()
                    if sender == self.buttonPinAddComment {
                        self.textViewInput.becomeFirstResponder()
                    }
                }
            }
        })
    }
}
