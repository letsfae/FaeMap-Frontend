//
//  CommentPinDetailHandleDelegateFuncs.swift
//  faeBeta
//
//  Created by Yue on 11/6/16.
//  Copyright © 2016 fae. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

extension CommentPinDetailViewController: EditCommentPinViewControllerDelegate, OpenedPinListViewControllerDelegate, CPCommentsCellDelegate {
    
    func reloadCommentContent() {
        if commentIDCommentPinDetailView != "-999" {
            getSeveralInfo()
        }
    }
    
    func animateToCameraFromOpenedPinListView(_ coordinate: CLLocationCoordinate2D, commentID: Int) {
        self.delegate?.animateToCameraFromCommentPinDetailView(coordinate, commentID: commentID)
        self.backJustOnce = true
        self.subviewNavigation.frame = CGRect(x: 0, y: 0, width: screenWidth, height: 65)
        self.tableCommentsForComment.center.y += screenHeight
        self.commentIDCommentPinDetailView = "\(commentID)"
        if commentIDCommentPinDetailView != "-999" {
            getSeveralInfo()
        }
    }
    
    func backFromOpenedPinList(_ back: Bool) {
        if back {
            backJustOnce = true
            subviewNavigation.frame = CGRect(x: 0, y: 0, width: screenWidth, height: 65)
            UIView.animate(withDuration: 0.583, animations:({
                self.uiviewCommentPinDetail.center.y += screenHeight
            }), completion: { (done: Bool) in
                if done {
                    
                }
            })
        }
        if !back {
            self.dismiss(animated: false, completion: nil)
        }
    }
    
    func showActionSheetFromCommentPinCell(_ username: String) {
        if inputToolbar != nil {
            self.inputToolbar.contentView.textView.resignFirstResponder()
        }
        let infoDict: [String: AnyObject] = ["argumentInt": username as AnyObject]
        touchToReplyTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(CommentPinDetailViewController.showActionSheetWithTimer), userInfo: infoDict, repeats: false)
    }
    
    func cancelTouchToReplyTimerFromCommentPinCell(_ cancel: Bool) {
        if touchToReplyTimer != nil {
            touchToReplyTimer.invalidate()
        }
    }
    
    func showActionSheetWithTimer(_ timer: Timer) {
        if let usernameInfo = timer.userInfo as? Dictionary<String, AnyObject> {
            let userN = usernameInfo["argumentInt"] as! String
            self.replyToUser = "<a>@\(userN)</a> "
            let menu = UIAlertController(title: nil, message: "Action", preferredStyle: .actionSheet)
            menu.view.tintColor = colorFae
            let writeReply = UIAlertAction(title: "Write a Reply", style: .default) { (alert: UIAlertAction) in
                self.loadInputToolBar()
                self.inputToolbar.isHidden = false
                self.subviewInputToolBar.isHidden = false
                self.inputToolbar.contentView.textView.text = ""
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
    }
}
