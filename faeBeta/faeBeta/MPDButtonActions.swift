//
//  MPDButtonActions.swift
//  faeBeta
//
//  Created by Yue on 12/2/16.
//  Copyright © 2016 fae. All rights reserved.
//

import Foundation
import UIKit
import GoogleMaps
import SwiftyJSON

extension MomentPinDetailViewController {
    
    // Pan gesture for dragging pin detail dragging button
    func panActionPinDetailDrag(_ pan: UIPanGestureRecognizer) {
        var resumeTime:Double = 0.583
        if pan.state == .began {
            if uiviewPinDetail.frame.size.height == 255 {
                pinSizeFrom = 255
                pinSizeTo = screenHeight - 65
            }
            else {
                pinSizeFrom = screenHeight - 65
                pinSizeTo = 255
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
            if abs(location.y - pinSizeFrom) >= 80 {
                UIView.animate(withDuration: resumeTime, animations: {
                    self.draggingButtonSubview.frame.origin.y = self.pinSizeTo - 28
                    self.uiviewPinDetail.frame.size.height = self.pinSizeTo
                })
            }
            else {
                UIView.animate(withDuration: resumeTime, animations: {
                    self.draggingButtonSubview.frame.origin.y = self.pinSizeFrom - 28
                    self.uiviewPinDetail.frame.size.height = self.pinSizeFrom
                })
            }
            if uiviewPinDetail.frame.size.height == 255 {
                textviewPinDetail.isScrollEnabled = true
                buttonPinDetailDragToLargeSize.tag = 0
            }
            if uiviewPinDetail.frame.size.height == screenHeight - 65 {
                textviewPinDetail.isScrollEnabled = false
                buttonPinDetailDragToLargeSize.tag = 1
                let newHeight = CGFloat(140 * self.dictCommentsOnPinDetail.count)
                self.tableCommentsForPin.frame.size.height = newHeight
            }
            
        } else {
            let location = pan.location(in: view)
            if location.y >= 306 {
                self.draggingButtonSubview.center.y = location.y - 65
                self.uiviewPinDetail.frame.size.height = location.y + 14 - 65
            }
        }
    }
    
    // Close more options button when it is open, the subview is under it
    func actionToCloseOtherViews(_ sender: UIButton) {
        if buttonMoreOnPinCellExpanded == true {
            hidePinMoreButtonDetails()
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
                self.subviewNavigation.center.y -= self.subviewNavigation.frame.size.height
                self.tableCommentsForPin.center.y -= screenHeight
                self.draggingButtonSubview.center.y -= screenHeight
            })
        }
    }
    
    // Show more options button in pin detail window
    func showPinMoreButtonDetails(_ sender: UIButton!) {
        endEdit()
        if buttonMoreOnPinCellExpanded == false {
            buttonFakeTransparentClosingView = UIButton(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
            buttonFakeTransparentClosingView.layer.zPosition = 110
            self.view.addSubview(buttonFakeTransparentClosingView)
            buttonFakeTransparentClosingView.addTarget(self,
                                                       action: #selector(self.actionToCloseOtherViews(_:)),
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
            moreButtonDetailSubview.layer.zPosition = 111
            self.view.addSubview(moreButtonDetailSubview)
            
            // --> Not for 11.01 Dev
            //            buttonShareOnPinDetail = UIButton(frame: CGRectMake(subviewXBefore, subviewYBefore, 0, 0))
            //            buttonShareOnPinDetail.setImage(UIImage(named: "buttonShareOnPinDetail"), forState: .Normal)
            //            buttonShareOnPinDetail.layer.zPosition = 111
            //            self.view.addSubview(buttonShareOnPinDetail)
            //            buttonShareOnPinDetail.clipsToBounds = true
            //            buttonShareOnPinDetail.alpha = 0.0
            //            buttonShareOnPinDetail.addTarget(self,
            //                                                 action: #selector(self.actionSharePin(_:)),
            //                                                 forControlEvents: .TouchUpInside)
            
            buttonEditOnPinDetail = UIButton(frame: CGRect(x: subviewXBefore, y: subviewYBefore, width: 0, height: 0))
            buttonEditOnPinDetail.setImage(UIImage(named: "buttonEditOnPinDetail"), for: UIControlState())
            buttonEditOnPinDetail.layer.zPosition = 111
            self.view.addSubview(buttonEditOnPinDetail)
            buttonEditOnPinDetail.clipsToBounds = true
            buttonEditOnPinDetail.alpha = 0.0
            buttonEditOnPinDetail.addTarget(self,
                                            action: #selector(self.actionEditPin(_:)),
                                                for: .touchUpInside)
            
            // --> Not for 11.01 Dev
            //            buttonSaveOnPinDetail = UIButton(frame: CGRectMake(subviewXBefore, subviewYBefore, 0, 0))
            //            buttonSaveOnPinDetail.setImage(UIImage(named: "buttonSaveOnCommentDetail"), forState: .Normal)
            //            buttonSaveOnPinDetail.layer.zPosition = 111
            //            self.view.addSubview(buttonSaveOnPinDetail)
            //            buttonSaveOnPinDetail.clipsToBounds = true
            //            buttonSaveOnPinDetail.alpha = 0.0
            //            buttonSaveOnPinDetail.addTarget(self,
            //                                                action: #selector(self.actionSavedThisPin(_:)),
            //                                                forControlEvents: .TouchUpInside)
            
            buttonDeleteOnPinDetail = UIButton(frame: CGRect(x: subviewXBefore, y: subviewYBefore, width: 0, height: 0))
            buttonDeleteOnPinDetail.setImage(UIImage(named: "buttonDeleteOnCommentDetail"), for: UIControlState())
            buttonDeleteOnPinDetail.layer.zPosition = 111
            self.view.addSubview(buttonDeleteOnPinDetail)
            buttonDeleteOnPinDetail.clipsToBounds = true
            buttonDeleteOnPinDetail.alpha = 0.0
            buttonDeleteOnPinDetail.addTarget(self,
                                                  action: #selector(self.actionDeleteThisPin(_:)),
                                                  for: .touchUpInside)
            
            buttonReportOnPinDetail = UIButton(frame: CGRect(x: subviewXBefore, y: subviewYBefore, width: 0, height: 0))
            buttonReportOnPinDetail.setImage(UIImage(named: "buttonReportOnCommentDetail"), for: UIControlState())
            buttonReportOnPinDetail.layer.zPosition = 111
            self.view.addSubview(buttonReportOnPinDetail)
            buttonReportOnPinDetail.clipsToBounds = true
            buttonReportOnPinDetail.alpha = 0.0
            buttonReportOnPinDetail.addTarget(self,
                                                  action: #selector(self.actionReportThisPin(_:)),
                                                  for: .touchUpInside)
            
            
            UIView.animate(withDuration: 0.25, animations: ({
                self.moreButtonDetailSubview.frame = CGRect(x: subviewXAfter,
                                                            y: subviewYAfter,
                                                            width: subviewWidthAfter,
                                                            height: subviewHeightAfter)
                //                self.buttonShareOnPinDetail.frame = CGRectMake(firstButtonX, buttonY, buttonWidth, buttonHeight)
                self.buttonEditOnPinDetail.frame = CGRect(x: firstButtonX, y: buttonY, width: buttonWidth, height: buttonHeight)
                //                self.buttonSaveOnPinDetail.frame = CGRectMake(secondButtonX, buttonY, buttonWidth, buttonHeight)
                self.buttonDeleteOnPinDetail.frame = CGRect(x: secondButtonX, y: buttonY, width: buttonWidth, height: buttonHeight)
                self.buttonReportOnPinDetail.frame = CGRect(x: thirdButtonX, y: buttonY, width: buttonWidth, height: buttonHeight)
                //                self.buttonShareOnPinDetail.alpha = 1.0
                //                self.buttonSaveOnPinDetail.alpha = 1.0
                if self.thisIsMyPin == true {
                    self.buttonEditOnPinDetail.alpha = 1.0
                    self.buttonDeleteOnPinDetail.alpha = 1.0
                }
                self.buttonReportOnPinDetail.alpha = 1.0
            }))
            buttonMoreOnPinCellExpanded = true
        }
        else {
            hidePinMoreButtonDetails()
        }
    }
    
    // When clicking share button in pin detail window's more options button
    func actionSharePin(_ sender: UIButton!) {
        actionToCloseOtherViews(buttonFakeTransparentClosingView)
        print("Share Clicks!")
    }
    
    func actionEditPin(_ sender: UIButton!) {
        if pinIdSentBySegue == -999 {
            return
        }
        actionToCloseOtherViews(buttonFakeTransparentClosingView)
    }
    
    func actionReportThisPin(_ sender: UIButton!) {
        let reportPinVC = ReportCommentPinViewController()
        reportPinVC.reportType = 0
        self.present(reportPinVC, animated: true, completion: nil)
        actionToCloseOtherViews(buttonFakeTransparentClosingView)
    }
    
    func actionDeleteThisPin(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Delete Pin", message: "This Pin will be deleted from both the Map and Mapboards, no one can find it anymore. All the comments and replies will also be removed.", preferredStyle: UIAlertControllerStyle.alert)
        let deleteAction = UIAlertAction(title: "Delete", style: UIAlertActionStyle.destructive) { (result : UIAlertAction) -> Void in
            print("Delete")
            let deletePin = FaePinAction()
            deletePin.deletePinById(type: "media", pinId: self.pinIDPinDetailView) {(status: Int, message: Any?) in
                if status / 100 == 2 {
                    print("Successfully delete moment")
                    self.actionBackToMap(self.buttonPinBackToMap)
                    self.delegate?.dismissMarkerShadow(false)
                }
                else {
                    print("Fail to delete moment")
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
    
    // When clicking save button in pin detail window's more options button
    func actionSavedThisPin(_ sender: UIButton) {
        if pinIDPinDetailView != "-999" {
            saveThisPin("media", pinID: pinIDPinDetailView)
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
        self.delegate?.dismissMarkerShadow(true)
        UIView.animate(withDuration: 0.583, animations: ({
            self.subviewNavigation.center.y -= screenHeight
            self.tableCommentsForPin.center.y -= screenHeight
            self.draggingButtonSubview.center.y -= screenHeight
            self.grayBackButton.alpha = 0
            self.pinIcon.alpha = 0
            self.buttonPrevPin.alpha = 0
            self.buttonNextPin.alpha = 0
        }), completion: { (done: Bool) in
            if done {
                self.dismiss(animated: false, completion: nil)
            }
        })
    }
    
    // When clicking reply button in pin detail window
    func actionReplyToThisPin(_ sender: UIButton) {
        if sender.tag == 1 {
            endEdit()
            sender.tag = 0
            buttonPinDetailDragToLargeSize.tag = 0
            if inputToolbar != nil {
                self.inputToolbar.isHidden = true
                self.subviewInputToolBar.isHidden = true
            }
            textviewPinDetail.isScrollEnabled = true
            tableCommentsForPin.isScrollEnabled = false
            UIView.animate(withDuration: 0.583, animations: ({
                self.buttonBackToPinLists.alpha = 1.0
                self.buttonPinBackToMap.alpha = 0.0
                self.draggingButtonSubview.frame.origin.y = 292
                self.tableCommentsForPin.scrollToTop()
                self.tableCommentsForPin.frame.size.height = 227
                self.uiviewPinDetail.frame.size.height = 281
                self.textviewPinDetail.frame.size.height = 100
                self.uiviewPinDetailMainButtons.frame.origin.y = 190
                self.uiviewPinDetailGrayBlock.frame.origin.y = 227
                self.uiviewPinDetailThreeButtons.frame.origin.y = 239
            }), completion: { (done: Bool) in
                if done {
                    
                }
            })
            return
        }
        sender.tag = 1
        if buttonPinDetailDragToLargeSize.tag == 1 {
            if inputToolbar != nil {
                self.inputToolbar.isHidden = false
                self.subviewInputToolBar.isHidden = false
            }
            self.tableCommentsForPin.frame.size.height = screenHeight - 65 - 90
            self.draggingButtonSubview.frame.origin.y = screenHeight - 28
            return
        }
        let numLines = Int(textviewPinDetail.contentSize.height / textviewPinDetail.font!.lineHeight)
        let diffHeight: CGFloat = textviewPinDetail.contentSize.height - textviewPinDetail.frame.size.height
        textviewPinDetail.isScrollEnabled = false
        tableCommentsForPin.isScrollEnabled = true
        if inputToolbar != nil {
            self.inputToolbar.isHidden = false
            self.subviewInputToolBar.isHidden = false
        }
        UIView.animate(withDuration: 0.583, animations: ({
            self.buttonBackToPinLists.alpha = 0.0
            self.buttonPinBackToMap.alpha = 1.0
            self.draggingButtonSubview.frame.origin.y = screenHeight - 90
            self.tableCommentsForPin.frame.size.height = screenHeight - 65 - 90
            if numLines > 4 {
                self.uiviewPinDetail.frame.size.height += diffHeight
                self.textviewPinDetail.frame.size.height += diffHeight
                self.uiviewPinDetailThreeButtons.center.y += diffHeight
                self.uiviewPinDetailGrayBlock.center.y += diffHeight
                self.uiviewPinDetailMainButtons.center.y += diffHeight
            }
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
            mediaMode = .small
            zoomMedia(.small)
            UIView.animate(withDuration: 0.583, animations: ({
                self.buttonBackToPinLists.alpha = 1.0
                self.buttonPinBackToMap.alpha = 0.0
                self.draggingButtonSubview.frame.origin.y = 292
                self.tableCommentsForPin.scrollToTop()
                self.tableCommentsForPin.frame.size.height = 227
                self.uiviewPinDetail.frame.size.height = 281
                self.textviewPinDetail.frame.size.height = 100
                self.uiviewPinDetailMainButtons.frame.origin.y = 190
                self.uiviewPinDetailGrayBlock.frame.origin.y = 227
                self.uiviewPinDetailThreeButtons.frame.origin.y = 239
            }), completion: { (done: Bool) in
                if done {
                    
                }
            })
            return
        }
        sender.tag = 1
//        let numLines = Int(textviewPinDetail.contentSize.height / textviewPinDetail.font!.lineHeight)
//        let diffHeight: CGFloat = textviewPinDetail.contentSize.height - textviewPinDetail.frame.size.height
        textviewPinDetail.isScrollEnabled = false
        tableCommentsForPin.isScrollEnabled = true
        mediaMode = .large
        zoomMedia(.large)
        UIView.animate(withDuration: 0.583, animations: ({
            self.buttonBackToPinLists.alpha = 0.0
            self.buttonPinBackToMap.alpha = 1.0
            self.draggingButtonSubview.frame.origin.y = screenHeight - 28
            self.tableCommentsForPin.frame.size.height = screenHeight - 93
            self.uiviewPinDetail.frame.size.height += 65
            self.textviewPinDetail.frame.size.height += 65
            self.uiviewPinDetailThreeButtons.center.y += 65
            self.uiviewPinDetailGrayBlock.center.y += 65
            self.uiviewPinDetailMainButtons.center.y += 65
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
