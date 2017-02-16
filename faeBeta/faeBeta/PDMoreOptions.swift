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
    func actionToCloseOtherViews(_ sender: UIButton) {
        if buttonMoreOnPinCellExpanded == true {
            hidePinMoreButtonDetails()
        }
    }
    // Show more options button in comment pin detail window
    func showPinMoreButtonDetails(_ sender: UIButton!) {
        endEdit()
        if buttonMoreOnPinCellExpanded == false {
            var menuOffset: CGFloat = 0
            if pinTypeEnum == .place {
                menuOffset = 148
            }
            buttonFakeTransparentClosingView = UIButton(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
            buttonFakeTransparentClosingView.layer.zPosition = 110
            self.view.addSubview(buttonFakeTransparentClosingView)
            buttonFakeTransparentClosingView.addTarget(self,
                                                       action: #selector(self.actionToCloseOtherViews(_:)),
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
            let buttonWidth: CGFloat = 44 * screenWidthFactor
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
            
            buttonEditOnPinDetail = UIButton(frame: CGRect(x: subviewXBefore, y: subviewYBefore, width: 0, height: 0))
            buttonEditOnPinDetail.setImage(#imageLiteral(resourceName: "pinDetailEdit"), for: UIControlState())
            buttonEditOnPinDetail.layer.zPosition = 111
            self.view.addSubview(buttonEditOnPinDetail)
            buttonEditOnPinDetail.clipsToBounds = true
            buttonEditOnPinDetail.alpha = 0.0
            buttonEditOnPinDetail.addTarget(self,
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
            
            buttonDeleteOnPinDetail = UIButton(frame: CGRect(x: subviewXBefore, y: subviewYBefore, width: 0, height: 0))
            buttonDeleteOnPinDetail.setImage(#imageLiteral(resourceName: "pinDetailDelete"), for: UIControlState())
            buttonDeleteOnPinDetail.layer.zPosition = 111
            self.view.addSubview(buttonDeleteOnPinDetail)
            buttonDeleteOnPinDetail.clipsToBounds = true
            buttonDeleteOnPinDetail.alpha = 0.0
            buttonDeleteOnPinDetail.addTarget(self,
                                              action: #selector(self.actionDeleteThisPin(_:)),
                                              for: .touchUpInside)
            
            buttonReportOnPinDetail = UIButton(frame: CGRect(x: subviewXBefore, y: subviewYBefore, width: 0, height: 0))
            buttonReportOnPinDetail.setImage(#imageLiteral(resourceName: "pinDetailReport"), for: UIControlState())
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
                self.buttonShareOnPinDetail.frame = CGRect(x: firstButtonX, y: buttonY, width: buttonWidth, height: buttonHeight)
                self.buttonEditOnPinDetail.frame = CGRect(x: secondButtonX, y: buttonY, width: buttonWidth, height: buttonHeight)
                self.buttonSaveOnPinDetail.frame = CGRect(x: secondButtonX, y: buttonY, width: buttonWidth, height: buttonHeight)
                self.buttonDeleteOnPinDetail.frame = CGRect(x: thirdButtonX, y: buttonY, width: buttonWidth, height: buttonHeight)
                self.buttonReportOnPinDetail.frame = CGRect(x: thirdButtonX, y: buttonY, width: buttonWidth, height: buttonHeight)
                if self.thisIsMyPin == true {
                    self.buttonEditOnPinDetail.alpha = 1.0
                    self.buttonDeleteOnPinDetail.alpha = 1.0
                }
                else {
                    self.buttonSaveOnPinDetail.alpha = 1.0
                    self.buttonReportOnPinDetail.alpha = 1.0
                }
                self.buttonShareOnPinDetail.alpha = 1.0
            }))
            buttonMoreOnPinCellExpanded = true
        }
        else {
            hidePinMoreButtonDetails()
        }
    }
    
    // Hide comment pin more options' button
    func hidePinMoreButtonDetails() {
        buttonMoreOnPinCellExpanded = false
        var menuOffset: CGFloat = 0
        if pinTypeEnum == .place {
            menuOffset = 148
        }
        let subviewXBefore: CGFloat = 400 * screenWidthFactor
        let subviewYBefore: CGFloat = (57 + menuOffset) * screenWidthFactor
        UIView.animate(withDuration: 0.25, animations: ({
            self.moreButtonDetailSubview.frame = CGRect(x: subviewXBefore, y: subviewYBefore, width: 0, height: 0)
            self.buttonShareOnPinDetail.frame = CGRect(x: subviewXBefore, y: subviewYBefore, width: 0, height: 0)
            self.buttonEditOnPinDetail.frame = CGRect(x: subviewXBefore, y: subviewYBefore, width: 0, height: 0)
            self.buttonSaveOnPinDetail.frame = CGRect(x: subviewXBefore, y: subviewYBefore, width: 0, height: 0)
            self.buttonDeleteOnPinDetail.frame = CGRect(x: subviewXBefore, y: subviewYBefore, width: 0, height: 0)
            self.buttonReportOnPinDetail.frame = CGRect(x: subviewXBefore, y: subviewYBefore, width: 0, height: 0)
            self.buttonShareOnPinDetail.alpha = 0.0
            self.buttonEditOnPinDetail.alpha = 0.0
            self.buttonSaveOnPinDetail.alpha = 0.0
            self.buttonDeleteOnPinDetail.alpha = 0.0
            self.buttonReportOnPinDetail.alpha = 0.0
        }))
        buttonFakeTransparentClosingView.removeFromSuperview()
    }
    
    // When clicking share button in comment pin detail window's more options button
    func actionShareComment(_ sender: UIButton) {
        actionToCloseOtherViews(buttonFakeTransparentClosingView)
        print("Share Clicks!")
    }
    
    func actionEditComment(_ sender: UIButton) {
        if pinIdSentBySegue == "-999" {
            return
        }
        self.isKeyboardInThisView = false
        let editMomentPinVC = EditCommentPinViewController()
        editMomentPinVC.delegate = self
        editMomentPinVC.previousCommentContent = self.stringPlainTextViewTxt
        editMomentPinVC.pinID = "\(pinIdSentBySegue)"
        editMomentPinVC.pinMediaImageArray = imageViewMediaArray
        editMomentPinVC.pinGeoLocation = CLLocationCoordinate2D(latitude: selectedMarkerPosition.latitude, longitude: selectedMarkerPosition.longitude)
        editMomentPinVC.editPinMode = self.pinTypeEnum
        editMomentPinVC.pinType = "\(self.pinTypeEnum)"
        editMomentPinVC.mediaIdArray = fileIdArray
        self.present(editMomentPinVC, animated: true, completion: nil)
        actionToCloseOtherViews(buttonFakeTransparentClosingView)
    }
    
    func actionReportThisPin(_ sender: UIButton) {
        let reportPinVC = ReportCommentPinViewController()
        reportPinVC.reportType = 0
        if pinTypeEnum == .place {
            reportPinVC.isPlacePin = true
        }
        self.isKeyboardInThisView = false
        self.present(reportPinVC, animated: true, completion: nil)
        actionToCloseOtherViews(buttonFakeTransparentClosingView)
    }
    
    func actionDeleteThisPin(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Delete Pin", message: "This Pin will be deleted on the map and in mapboards. All the comments and replies will also be removed.", preferredStyle: .alert)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (result : UIAlertAction) -> Void in
            print("Delete")
            let deleteCommentPin = FaePinAction()
            deleteCommentPin.deletePinById(type: "\(self.pinTypeEnum)", pinId: self.pinIDPinDetailView) {(status: Int, message: Any?) in
                if status / 100 == 2 {
                    print("Successfully delete pin")
                    self.actionBackToMap(self.buttonPinBackToMap)
                    self.delegate?.dismissMarkerShadow(false)
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
        actionToCloseOtherViews(buttonFakeTransparentClosingView)
    }
    
    // When clicking save button in comment pin detail window's more options button
    func actionSaveThisPin(_ sender: UIButton) {
        if pinIDPinDetailView != "-999" {
            if isSavedByMe {
                self.unsaveThisPin("\(self.pinTypeEnum)", pinID: pinIDPinDetailView)
            }
            else {
                self.saveThisPin("\(self.pinTypeEnum)", pinID: pinIDPinDetailView)
            }
        }
        actionToCloseOtherViews(buttonFakeTransparentClosingView)
    }
}
