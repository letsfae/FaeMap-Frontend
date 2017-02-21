//
//  PDHandleDelegateFuncs.swift
//  faeBeta
//
//  Created by Yue on 12/2/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
import CoreLocation

extension PinDetailViewController: OpenedPinListViewControllerDelegate, PinCommentsCellDelegate, EditCommentPinViewControllerDelegate {
    
    func reloadCommentContent() {
        if pinIDPinDetailView != "-999" {
            getSeveralInfo()
        }
    }
    // OpenedPinListViewControllerDelegate
    func animateToCameraFromOpenedPinListView(_ coordinate: CLLocationCoordinate2D, pinID: String, pinType: PinDetailViewController.PinType) {
        self.pinTypeEnum = pinType
        self.selectedMarkerPosition = coordinate
        self.delegate?.animateToCamera(coordinate, pinID: pinID)
        self.backJustOnce = true
        self.subviewNavigation.frame = CGRect(x: 0, y: 0, width: screenWidth, height: 65)
        self.tableCommentsForPin.center.y += screenHeight
        self.draggingButtonSubview.center.y += screenHeight
        self.pinIDPinDetailView = pinID
        self.delegate?.disableSelfMarker(yes: false)
        if pinType == .place {
            if uiviewPlaceDetail == nil {
                loadPlaceDetail()
            }
            loadPlaceFromRealm(pinTypeId: "place\(pinID)")
            uiviewPlaceDetail.frame.origin.y = 0
            pinIcon.frame.size.width = 48
            pinIcon.center.x = screenWidth / 2
            pinIcon.center.y = 507 * screenHeightFactor
            UIApplication.shared.statusBarStyle = .lightContent
        } else {
            if uiviewPlaceDetail != nil {
                uiviewPlaceDetail.center.y -= screenHeight
            }
            if inputToolbar == nil {
                self.loadInputToolBar()
                self.loadExtendView() // call func for loading extend view (mingjie jin)
            }
            if pinIDPinDetailView != "-999" {
                getSeveralInfo()
            }
            self.initPinBasicInfo()
            pinIcon.frame.size.width = 60
            pinIcon.center.x = screenWidth / 2
            pinIcon.center.y = 510 * screenHeightFactor
            UIApplication.shared.statusBarStyle = .default
        }
    }
    
    // OpenedPinListViewControllerDelegate
    func directlyReturnToMap() {
        actionBackToMap(UIButton())
    }
    
    // OpenedPinListViewControllerDelegate
    func backFromOpenedPinList(pinType: String, pinID: String) {
        backJustOnce = true
        subviewNavigation.frame = CGRect(x: 0, y: 0, width: screenWidth, height: 65)
    }
    
    func showActionSheetFromPinCell(_ username: String) {
        if inputToolbar != nil {
            self.inputToolbar.contentView.textView.resignFirstResponder()
        }
        let infoDict: [String: AnyObject] = ["argumentInt": username as AnyObject]
        touchToReplyTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(PinDetailViewController.showActionSheetWithTimer), userInfo: infoDict, repeats: false)
    }
    
    func cancelTouchToReplyTimerFromPinCell(_ cancel: Bool) {
        if touchToReplyTimer != nil {
            touchToReplyTimer.invalidate()
        }
    }
    
    func showActionSheetWithTimer(_ timer: Timer) {
        if let usernameInfo = timer.userInfo as? Dictionary<String, AnyObject> {
            let userN = usernameInfo["argumentInt"] as! String
            self.replyToUser = "<a>@\(userN)</a> "
            let menu = UIAlertController(title: nil, message: "Action", preferredStyle: .actionSheet)
            menu.view.tintColor = UIColor.faeAppRedColor()
            let writeReply = UIAlertAction(title: "Write a Reply", style: .default) { (alert: UIAlertAction) in
                self.loadInputToolBar()
                self.inputToolbar.isHidden = false
                self.subviewInputToolBar.isHidden = false
                self.inputToolbar.contentView.textView.text = ""
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
    }
}

