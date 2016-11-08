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

extension CommentPinViewController: EditCommentPinViewControllerDelegate, OpenedPinListViewControllerDelegate, CommentPinCommentsCellDelegate {
    
    func reloadCommentContent() {
        if commentIDCommentPinDetailView != "-999" {
            getSeveralInfo()
        }
    }
    
    func animateToCameraFromOpenedPinListView(coordinate: CLLocationCoordinate2D, commentID: Int) {
        self.delegate?.animateToCameraFromCommentPinDetailView(coordinate, commentID: commentID)
        self.backJustOnce = true
        self.subviewWhite.frame = CGRectMake(0, 0, screenWidth, 65)
        self.uiviewCommentPinDetail.center.y += screenHeight
        self.commentIDCommentPinDetailView = "\(commentID)"
        if commentIDCommentPinDetailView != "-999" {
            getSeveralInfo()
        }
    }
    
    func backFromOpenedPinList(back: Bool) {
        if back {
            backJustOnce = true
            subviewWhite.frame = CGRectMake(0, 0, screenWidth, 65)
            UIView.animateWithDuration(0.583, animations:({
                self.uiviewCommentPinDetail.center.y += screenHeight
            }), completion: { (done: Bool) in
                if done {
                    
                }
            })
        }
        if !back {
            self.delegate?.dismissMarkerShadow(true)
            self.dismissViewControllerAnimated(false, completion: nil)
        }
    }
    
    func showActionSheetFromCommentPinCell(username: String) {
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
}
