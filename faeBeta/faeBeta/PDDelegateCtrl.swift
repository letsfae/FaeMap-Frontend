//
//  PDHandleDelegateFuncs.swift
//  faeBeta
//
//  Created by Yue on 12/2/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
import CoreLocation
import SwiftyJSON

extension PinDetailViewController: OpenedPinListViewControllerDelegate, PinCommentsCellDelegate, EditCommentPinViewControllerDelegate, SendStickerDelegate, PinFeelingCellDelegate {
    
    // PinFeelingCellDelegate
    func postFeelingFromFeelingCell(_ feeling: String) {
        let postFeeling = FaePinAction()
        postFeeling.whereKey("feeling", value: feeling)
        postFeeling.postFeelingToPin("\(self.pinTypeEnum)", pinID: pinIDPinDetailView) { (status, message) in
            if status / 100 != 2 {
                return
            }
            let getPinById = FaeMap()
            getPinById.getPin(type: "\(self.pinTypeEnum)", pinId: self.pinIDPinDetailView) {(status: Int, message: Any?) in
                let pinInfoJSON = JSON(message!)
                self.feelingArray.removeAll()
                let feelings = pinInfoJSON["feeling_count"].arrayValue.map({Int($0.stringValue)})
                for feeling in feelings {
                    if feeling != nil {
                        self.feelingArray.append(feeling!)
                    }
                }
                if self.tableMode == .feelings {
                    self.tableCommentsForPin.reloadData()
                    let indexPath = IndexPath(row: 0, section: 0)
                    self.tableCommentsForPin.scrollToRow(at: indexPath, at: .bottom, animated: false)
                }
                self.loadFeelingQuickView()
            }
        }
    }
    // PinFeelingCellDelegate
    func deleteFeelingFromFeelingCell() {
        deleteFeeling()
    }
    
    // SendStickerDelegate
    func sendStickerWithImageName(_ name : String) {
        print("[sendStickerWithImageName] name: \(name)")
        let stickerMessage = "<faeSticker>\(name)</faeSticker>"
        sendMessage(stickerMessage)
        buttonSend.isEnabled = false
        buttonSend.setImage(UIImage(named: "cannotSendMessage"), for: UIControlState())
        UIView.animate(withDuration: 0.3) {
            self.tableCommentsForPin.frame.size.height = screenHeight - 155
            self.draggingButtonSubview.frame.origin.y = screenHeight - 90
        }
        
    }
    func appendEmojiWithImageName(_ name: String) {
        self.textViewInput.text = self.textViewInput.text + "[\(name)]"
        self.textViewDidChange(textViewInput)
    }
    func deleteEmoji() {
        self.textViewInput.text = self.textViewInput.text.stringByDeletingLastEmoji()
        self.textViewDidChange(textViewInput)
    }
    
    func reloadCommentContent() {
        if pinIDPinDetailView != "-999" {
            getSeveralInfo()
        }
    }
    
    // OpenedPinListViewControllerDelegate
    func animateToCameraFromOpenedPinListView(_ coordinate: CLLocationCoordinate2D, pinID: String) {
        self.selectedMarkerPosition = coordinate
        self.delegate?.animateToCamera(coordinate, pinID: pinID)
        self.backJustOnce = true
        self.subviewNavigation.frame = CGRect(x: 0, y: 0, width: screenWidth, height: 65)
        self.tableCommentsForPin.center.y += screenHeight
        self.draggingButtonSubview.center.y += screenHeight
        self.pinIDPinDetailView = pinID
        if uiviewPlaceDetail == nil {
            loadPlaceDetail()
        }
        loadPlaceFromRealm(pinTypeId: "place\(pinID)")
        uiviewPlaceDetail.frame.origin.y = 0
        pinIcon.frame.size.width = 48
        pinIcon.center.x = screenWidth / 2
        pinIcon.center.y = 507 * screenHeightFactor
        UIApplication.shared.statusBarStyle = .lightContent
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
    
    func directReplyFromPinCell(_ username: String) {
        self.replyToUser = "<a>@\(username)</a> "
        self.lblTxtPlaceholder.text = "@\(username):"
        textViewInput.becomeFirstResponder()
    }
    
    func showActionSheetFromPinCell(_ username: String) {
        textViewInput.resignFirstResponder()
        if touchToReplyTimer != nil {
            touchToReplyTimer.invalidate()
        }
        touchToReplyTimer = Timer.scheduledTimer(timeInterval: 0.75, target: self, selector: #selector(self.showActionSheetWithTimer), userInfo: nil, repeats: false) 
    }
    
    func cancelTouchToReplyTimerFromPinCell() {
        textViewInput.resignFirstResponder()
        if touchToReplyTimer != nil {
            touchToReplyTimer.invalidate()
        }
    }
    
    func showActionSheetWithTimer() {
        self.replyToUser = "<a>@\(username)</a> "
        let menu = UIAlertController(title: nil, message: "Action", preferredStyle: .actionSheet)
        menu.view.tintColor = UIColor.faeAppRedColor()
        let writeReply = UIAlertAction(title: "Write a Reply", style: .default) { (alert: UIAlertAction) in
            self.lblTxtPlaceholder.text = "@\(username)"
            self.textViewInput.becomeFirstResponder()
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

