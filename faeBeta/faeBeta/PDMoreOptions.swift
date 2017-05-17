//
//  PDMoreOptions.swift
//  faeBeta
//
//  Created by Yue on 12/23/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

extension PinDetailViewController {
    // Close more options button when it is open, the subview is under it
    func actionToCloseOtherViews() {
        if boolOptionsExpanded == true {
            hidePinMoreButtonDetails()
        }
    }
    // Show more options button in comment pin detail window
    func showPinMoreButtonDetails(_ sender: UIButton!) {
        endEdit()
        if boolOptionsExpanded == false {
            
            btnTransparentClose = UIButton(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
            btnTransparentClose.layer.zPosition = 110
            view.addSubview(btnTransparentClose)
            btnTransparentClose.addTarget(self, action: #selector(self.actionToCloseOtherViews), for: .touchUpInside)
            
            let menuOffset: CGFloat = PinDetailViewController.pinTypeEnum == .place ? 148 : 0
            let buttonHeight: CGFloat = 51 * screenWidthFactor
            let buttonWidth: CGFloat = 50 * screenWidthFactor
            let buttonY: CGFloat = (97 + menuOffset) * screenWidthFactor
            let firstButtonX: CGFloat = 192 * screenWidthFactor
            let secondButtonX: CGFloat = 262 * screenWidthFactor
            let subviewHeightAfter: CGFloat = 110 * screenWidthFactor
            let subviewWidthAfter: CGFloat = 229 * screenWidthFactor
            let subviewXAfter: CGFloat = 171 * screenWidthFactor
            let subviewXBefore: CGFloat = 400 * screenWidthFactor
            let subviewYAfter: CGFloat = (57 + menuOffset) * screenWidthFactor
            let subviewYBefore: CGFloat = (57 + menuOffset) * screenWidthFactor
            let thirdButtonX: CGFloat = 332 * screenWidthFactor
            
            uiviewOptionsSub = UIImageView(frame: CGRect(x: subviewXBefore, y: subviewYBefore, width: 0, height: 0))
            uiviewOptionsSub.image = #imageLiteral(resourceName: "uiviewOptionsSub")
            uiviewOptionsSub.layer.zPosition = 111
            view.addSubview(uiviewOptionsSub)
            
            btnShare = UIButton(frame: CGRect(x: subviewXBefore, y: subviewYBefore, width: 0, height: 0))
            btnShare.setImage(#imageLiteral(resourceName: "pinDetailShare"), for: UIControlState())
            btnShare.layer.zPosition = 111
            view.addSubview(btnShare)
            btnShare.clipsToBounds = true
            btnShare.alpha = 0.0
            btnShare.addTarget(self, action: #selector(self.actionShareComment(_:)), for: .touchUpInside)
            
            btnOptionEdit = UIButton(frame: CGRect(x: subviewXBefore, y: subviewYBefore, width: 0, height: 0))
            btnOptionEdit.setImage(#imageLiteral(resourceName: "pinDetailEdit"), for: UIControlState())
            btnOptionEdit.layer.zPosition = 111
            view.addSubview(btnOptionEdit)
            btnOptionEdit.clipsToBounds = true
            btnOptionEdit.alpha = 0.0
            btnOptionEdit.addTarget(self, action: #selector(self.actionEditComment(_:)), for: .touchUpInside)
            
            btnCollect = UIButton(frame: CGRect(x: subviewXBefore, y: subviewYBefore, width: 0, height: 0))
            if isSavedByMe {
                btnCollect.setImage(#imageLiteral(resourceName: "pinDetailUnsave"), for: .normal)
            }
            else {
                btnCollect.setImage(#imageLiteral(resourceName: "pinDetailSave"), for: .normal)
            }
            btnCollect.layer.zPosition = 111
            view.addSubview(btnCollect)
            btnCollect.clipsToBounds = true
            btnCollect.alpha = 0.0
            btnCollect.addTarget(self, action: #selector(self.actionSaveThisPin(_:)), for: .touchUpInside)
            
            btnOptionDelete = UIButton(frame: CGRect(x: subviewXBefore, y: subviewYBefore, width: 0, height: 0))
            btnOptionDelete.setImage(#imageLiteral(resourceName: "pinDetailDelete"), for: UIControlState())
            btnOptionDelete.layer.zPosition = 111
            view.addSubview(btnOptionDelete)
            btnOptionDelete.clipsToBounds = true
            btnOptionDelete.alpha = 0.0
            btnOptionDelete.addTarget(self, action: #selector(self.actionDeleteThisPin(_:)), for: .touchUpInside)
            
            btnReport = UIButton(frame: CGRect(x: subviewXBefore, y: subviewYBefore, width: 0, height: 0))
            btnReport.setImage(#imageLiteral(resourceName: "pinDetailReport"), for: UIControlState())
            btnReport.layer.zPosition = 111
            view.addSubview(btnReport)
            btnReport.clipsToBounds = true
            btnReport.alpha = 0.0
            btnReport.addTarget(self, action: #selector(self.actionReportThisPin), for: .touchUpInside)
            
            
            UIView.animate(withDuration: 0.25, animations: ({
                self.uiviewOptionsSub.frame = CGRect(x: subviewXAfter, y: subviewYAfter, width: subviewWidthAfter, height: subviewHeightAfter)
                self.btnShare.frame = CGRect(x: firstButtonX, y: buttonY, width: buttonWidth, height: buttonHeight)
                self.btnOptionEdit.frame = CGRect(x: secondButtonX, y: buttonY, width: buttonWidth, height: buttonHeight)
                self.btnCollect.frame = CGRect(x: secondButtonX, y: buttonY, width: buttonWidth, height: buttonHeight)
                self.btnOptionDelete.frame = CGRect(x: thirdButtonX, y: buttonY, width: buttonWidth, height: buttonHeight)
                self.btnReport.frame = CGRect(x: thirdButtonX, y: buttonY, width: buttonWidth, height: buttonHeight)
                if self.boolMyPin == true {
                    self.btnOptionEdit.alpha = 1.0
                    self.btnOptionDelete.alpha = 1.0
                }
                else {
                    self.btnCollect.alpha = 1.0
                    self.btnReport.alpha = 1.0
                }
                self.btnShare.alpha = 1.0
            }))
            boolOptionsExpanded = true
        }
        else {
            hidePinMoreButtonDetails()
        }
    }
    
    // Hide comment pin more options' button
    fileprivate func hidePinMoreButtonDetails() {
        boolOptionsExpanded = false
        var menuOffset: CGFloat = 0
        if PinDetailViewController.pinTypeEnum == .place {
            menuOffset = 148
        }
        let subviewXBefore: CGFloat = 400 * screenWidthFactor
        let subviewYBefore: CGFloat = (57 + menuOffset) * screenWidthFactor
        UIView.animate(withDuration: 0.25, animations: ({
            self.uiviewOptionsSub.frame = CGRect(x: subviewXBefore, y: subviewYBefore, width: 0, height: 0)
            self.btnShare.frame = CGRect(x: subviewXBefore, y: subviewYBefore, width: 0, height: 0)
            self.btnOptionEdit.frame = CGRect(x: subviewXBefore, y: subviewYBefore, width: 0, height: 0)
            self.btnCollect.frame = CGRect(x: subviewXBefore, y: subviewYBefore, width: 0, height: 0)
            self.btnOptionDelete.frame = CGRect(x: subviewXBefore, y: subviewYBefore, width: 0, height: 0)
            self.btnReport.frame = CGRect(x: subviewXBefore, y: subviewYBefore, width: 0, height: 0)
            self.btnShare.alpha = 0.0
            self.btnOptionEdit.alpha = 0.0
            self.btnCollect.alpha = 0.0
            self.btnOptionDelete.alpha = 0.0
            self.btnReport.alpha = 0.0
        }))
        btnTransparentClose.removeFromSuperview()
    }
    
    // When clicking share button in comment pin detail window's more options button
    func actionShareComment(_ sender: UIButton) {
        actionToCloseOtherViews()
        print("Share Clicks!")
    }
    
    func actionEditComment(_ sender: UIButton) {
        if strPinId == "-1" {
            return
        }
        self.isKeyboardInThisView = false
        let vcEditPin = EditPinViewController()
        vcEditPin.zoomLevel = zoomLevel
        vcEditPin.delegate = self
        vcEditPin.previousCommentContent = self.strCurrentTxt
        vcEditPin.pinID = "\(self.strPinId)"
        vcEditPin.pinMediaImageArray = imgMediaArr
        vcEditPin.pinGeoLocation = CLLocationCoordinate2D(latitude: PinDetailViewController.selectedMarkerPosition.latitude, longitude: PinDetailViewController.selectedMarkerPosition.longitude)
        vcEditPin.editPinMode = PinDetailViewController.pinTypeEnum
        vcEditPin.pinType = "\(PinDetailViewController.pinTypeEnum)"
        vcEditPin.mediaIdArray = fileIdArray
        self.present(vcEditPin, animated: true, completion: nil)
        actionToCloseOtherViews()
    }
    
    func actionReportThisPin() {
        let reportPinVC = ReportCommentPinViewController()
        reportPinVC.reportType = 0
        self.isKeyboardInThisView = false
        self.present(reportPinVC, animated: true, completion: nil)
        actionToCloseOtherViews()
    }
    
    func actionDeleteThisPin(_ sender: UIButton) {
        if strPinId == "-1" {
            return
        }
        let alertController = UIAlertController(title: "Delete Pin", message: "This Pin will be deleted on the map and in mapboards. All the comments and replies will also be removed.", preferredStyle: .alert)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (result : UIAlertAction) -> Void in
            print("Delete")
            let deleteCommentPin = FaePinAction()
            deleteCommentPin.deletePinById(type: "\(PinDetailViewController.pinTypeEnum)", pinId: self.strPinId) {(status: Int, message: Any?) in
                if status / 100 == 2 {
                    print("Successfully delete pin")
                    self.actionBackToMap(self.uiviewNavBar.leftBtn)
                    self.delegate?.backToMainMap()
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
        actionToCloseOtherViews()
    }
    
    // When clicking save button in comment pin detail window's more options button
    func actionSaveThisPin(_ sender: UIButton) {
        if isSavedByMe {
            unsaveThisPin()
        }
        else {
            saveThisPin()
        }
        actionToCloseOtherViews()
    }
}
