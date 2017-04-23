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
        if optionsExpanded == true {
            hidePinMoreButtonDetails()
        }
    }
    // Show more options button in comment pin detail window
    func showPinMoreButtonDetails(_ sender: UIButton!) {
        endEdit()
        if optionsExpanded == false {
            var menuOffset: CGFloat = 0
            if PinDetailViewController.pinTypeEnum == .place {
                menuOffset = 148
            }
            btnTransparentClose = UIButton(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
            btnTransparentClose.layer.zPosition = 110
            self.view.addSubview(btnTransparentClose)
            btnTransparentClose.addTarget(self,
                                                       action: #selector(self.actionToCloseOtherViews),
                                                       for: .touchUpInside)
            let subviewXBefore: CGFloat = 400 * screenWidthFactor
            let subviewYBefore: CGFloat = (57 + menuOffset) * screenWidthFactor
            let subviewXAfter: CGFloat = 171 * screenWidthFactor
            let subviewYAfter: CGFloat = (57 + menuOffset) * screenWidthFactor
            let subviewWidthAfter: CGFloat = 229 * screenWidthFactor
            let subviewHeightAfter: CGFloat = 110 * screenWidthFactor
            let firstButtonX: CGFloat = 192 * screenWidthFactor
            let secondButtonX: CGFloat = 262 * screenWidthFactor
            let thirdButtonX: CGFloat = 332 * screenWidthFactor
            let buttonY: CGFloat = (97 + menuOffset) * screenWidthFactor
            let buttonWidth: CGFloat = 50 * screenWidthFactor
            let buttonHeight: CGFloat = 51 * screenWidthFactor
            
            moreButtonDetailSubview = UIImageView(frame: CGRect(x: subviewXBefore, y: subviewYBefore, width: 0, height: 0))
            moreButtonDetailSubview.image = #imageLiteral(resourceName: "moreButtonDetailSubview")
            moreButtonDetailSubview.layer.zPosition = 111
            self.view.addSubview(moreButtonDetailSubview)
            
            buttonShareOnPinDetail = UIButton(frame: CGRect(x: subviewXBefore, y: subviewYBefore, width: 0, height: 0))
            buttonShareOnPinDetail.setImage(#imageLiteral(resourceName: "pinDetailShare"), for: UIControlState())
            buttonShareOnPinDetail.layer.zPosition = 111
            self.view.addSubview(buttonShareOnPinDetail)
            buttonShareOnPinDetail.clipsToBounds = true
            buttonShareOnPinDetail.alpha = 0.0
            buttonShareOnPinDetail.addTarget(self,
                                             action: #selector(self.actionShareComment(_:)),
                                             for: .touchUpInside)
            
            btnOptionEdit = UIButton(frame: CGRect(x: subviewXBefore, y: subviewYBefore, width: 0, height: 0))
            btnOptionEdit.setImage(#imageLiteral(resourceName: "pinDetailEdit"), for: UIControlState())
            btnOptionEdit.layer.zPosition = 111
            self.view.addSubview(btnOptionEdit)
            btnOptionEdit.clipsToBounds = true
            btnOptionEdit.alpha = 0.0
            btnOptionEdit.addTarget(self,
                                            action: #selector(self.actionEditComment(_:)),
                                            for: .touchUpInside)
            
            buttonSaveOnPinDetail = UIButton(frame: CGRect(x: subviewXBefore, y: subviewYBefore, width: 0, height: 0))
            if isSavedByMe {
                buttonSaveOnPinDetail.setImage(#imageLiteral(resourceName: "pinDetailUnsave"), for: .normal)
            }
            else {
                buttonSaveOnPinDetail.setImage(#imageLiteral(resourceName: "pinDetailSave"), for: UIControlState())
            }
            buttonSaveOnPinDetail.layer.zPosition = 111
            self.view.addSubview(buttonSaveOnPinDetail)
            buttonSaveOnPinDetail.clipsToBounds = true
            buttonSaveOnPinDetail.alpha = 0.0
            buttonSaveOnPinDetail.addTarget(self,
                                            action: #selector(self.actionSaveThisPin(_:)),
                                            for: .touchUpInside)
            
            btnOptionDelete = UIButton(frame: CGRect(x: subviewXBefore, y: subviewYBefore, width: 0, height: 0))
            btnOptionDelete.setImage(#imageLiteral(resourceName: "pinDetailDelete"), for: UIControlState())
            btnOptionDelete.layer.zPosition = 111
            self.view.addSubview(btnOptionDelete)
            btnOptionDelete.clipsToBounds = true
            btnOptionDelete.alpha = 0.0
            btnOptionDelete.addTarget(self,
                                              action: #selector(self.actionDeleteThisPin(_:)),
                                              for: .touchUpInside)
            
            buttonReportOnPinDetail = UIButton(frame: CGRect(x: subviewXBefore, y: subviewYBefore, width: 0, height: 0))
            buttonReportOnPinDetail.setImage(#imageLiteral(resourceName: "pinDetailReport"), for: UIControlState())
            buttonReportOnPinDetail.layer.zPosition = 111
            self.view.addSubview(buttonReportOnPinDetail)
            buttonReportOnPinDetail.clipsToBounds = true
            buttonReportOnPinDetail.alpha = 0.0
            buttonReportOnPinDetail.addTarget(self,
                                              action: #selector(self.actionReportThisPin),
                                              for: .touchUpInside)
            
            
            UIView.animate(withDuration: 0.25, animations: ({
                self.moreButtonDetailSubview.frame = CGRect(x: subviewXAfter,
                                                            y: subviewYAfter,
                                                            width: subviewWidthAfter,
                                                            height: subviewHeightAfter)
                self.buttonShareOnPinDetail.frame = CGRect(x: firstButtonX, y: buttonY, width: buttonWidth, height: buttonHeight)
                self.btnOptionEdit.frame = CGRect(x: secondButtonX, y: buttonY, width: buttonWidth, height: buttonHeight)
                self.buttonSaveOnPinDetail.frame = CGRect(x: secondButtonX, y: buttonY, width: buttonWidth, height: buttonHeight)
                self.btnOptionDelete.frame = CGRect(x: thirdButtonX, y: buttonY, width: buttonWidth, height: buttonHeight)
                self.buttonReportOnPinDetail.frame = CGRect(x: thirdButtonX, y: buttonY, width: buttonWidth, height: buttonHeight)
                if self.thisIsMyPin == true {
                    self.btnOptionEdit.alpha = 1.0
                    self.btnOptionDelete.alpha = 1.0
                }
                else {
                    self.buttonSaveOnPinDetail.alpha = 1.0
                    self.buttonReportOnPinDetail.alpha = 1.0
                }
                self.buttonShareOnPinDetail.alpha = 1.0
            }))
            optionsExpanded = true
        }
        else {
            hidePinMoreButtonDetails()
        }
    }
    
    // Hide comment pin more options' button
    func hidePinMoreButtonDetails() {
        optionsExpanded = false
        var menuOffset: CGFloat = 0
        if PinDetailViewController.pinTypeEnum == .place {
            menuOffset = 148
        }
        let subviewXBefore: CGFloat = 400 * screenWidthFactor
        let subviewYBefore: CGFloat = (57 + menuOffset) * screenWidthFactor
        UIView.animate(withDuration: 0.25, animations: ({
            self.moreButtonDetailSubview.frame = CGRect(x: subviewXBefore, y: subviewYBefore, width: 0, height: 0)
            self.buttonShareOnPinDetail.frame = CGRect(x: subviewXBefore, y: subviewYBefore, width: 0, height: 0)
            self.btnOptionEdit.frame = CGRect(x: subviewXBefore, y: subviewYBefore, width: 0, height: 0)
            self.buttonSaveOnPinDetail.frame = CGRect(x: subviewXBefore, y: subviewYBefore, width: 0, height: 0)
            self.btnOptionDelete.frame = CGRect(x: subviewXBefore, y: subviewYBefore, width: 0, height: 0)
            self.buttonReportOnPinDetail.frame = CGRect(x: subviewXBefore, y: subviewYBefore, width: 0, height: 0)
            self.buttonShareOnPinDetail.alpha = 0.0
            self.btnOptionEdit.alpha = 0.0
            self.buttonSaveOnPinDetail.alpha = 0.0
            self.btnOptionDelete.alpha = 0.0
            self.buttonReportOnPinDetail.alpha = 0.0
        }))
        btnTransparentClose.removeFromSuperview()
    }
    
    // When clicking share button in comment pin detail window's more options button
    func actionShareComment(_ sender: UIButton) {
        actionToCloseOtherViews()
        print("Share Clicks!")
    }
    
    func actionEditComment(_ sender: UIButton) {
        if self.pinIDPinDetailView == "-999" {
            return
        }
        self.isKeyboardInThisView = false
        let editPinVC = EditPinViewController()
        editPinVC.zoomLevel = zoomLevel
        editPinVC.delegate = self
        editPinVC.previousCommentContent = self.stringPlainTextViewTxt
        editPinVC.pinID = "\(self.pinIDPinDetailView)"
        editPinVC.pinMediaImageArray = imageViewMediaArray
        editPinVC.pinGeoLocation = CLLocationCoordinate2D(latitude: PinDetailViewController.selectedMarkerPosition.latitude, longitude: PinDetailViewController.selectedMarkerPosition.longitude)
        editPinVC.editPinMode = PinDetailViewController.pinTypeEnum
        editPinVC.pinType = "\(PinDetailViewController.pinTypeEnum)"
        editPinVC.mediaIdArray = fileIdArray
        self.present(editPinVC, animated: true, completion: nil)
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
        let alertController = UIAlertController(title: "Delete Pin", message: "This Pin will be deleted on the map and in mapboards. All the comments and replies will also be removed.", preferredStyle: .alert)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (result : UIAlertAction) -> Void in
            print("Delete")
            let deleteCommentPin = FaePinAction()
            deleteCommentPin.deletePinById(type: "\(PinDetailViewController.pinTypeEnum)", pinId: self.pinIDPinDetailView) {(status: Int, message: Any?) in
                if status / 100 == 2 {
                    print("Successfully delete pin")
                    self.actionBackToMap(self.buttonPinBackToMap)
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
        if self.pinIDPinDetailView != "-999" {
            if isSavedByMe {
                self.unsaveThisPin("\(PinDetailViewController.pinTypeEnum)", pinID: self.pinIDPinDetailView)
            }
            else {
                self.saveThisPin("\(PinDetailViewController.pinTypeEnum)", pinID: self.pinIDPinDetailView)
            }
        }
        actionToCloseOtherViews()
    }
}
