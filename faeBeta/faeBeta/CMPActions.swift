//
//  CMPActions.swift
//  faeBeta
//
//  Created by Yue on 11/24/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
import SwiftyJSON
import CoreLocation

extension CreateMomentPinViewController {
    
    func actionAddMedia(_ sender: UIButton) { // Add or Cancel Adding
        if sender.tag == 0 {
            let angle: CGFloat = (-45 * 3.14 / 180.0) as CGFloat
            sender.tag = 1
            UIView.animate(withDuration: 0.5) {
                self.buttonAddMedia.transform = CGAffineTransform(rotationAngle: angle)
                self.collectionViewMedia.center.x -= 249
                self.buttonTakeMedia.alpha = 1
                self.buttonSelectMedia.alpha = 1
            }
        }
        else {
            sender.tag = 0
            UIView.animate(withDuration: 0.5) {
                self.buttonAddMedia.transform = CGAffineTransform(rotationAngle: 0)
                self.collectionViewMedia.center.x += 249
                self.buttonTakeMedia.alpha = 0
                self.buttonSelectMedia.alpha = 0
            }
        }
    }
    
    func actionAnonymous(_ sender: UIButton) {
        if sender.tag == 0 {
            sender.tag = 1
            sender.setImage(UIImage(named: "anonymousClicked"), for: UIControlState())
            anonymous = true
        }
        else {
            sender.tag = 0
            sender.setImage(UIImage(named: "anonymousUnclicked"), for: UIControlState())
            anonymous = false
        }
    }
    
    func actionTakeMedia(_ sender: UIButton) {
        if sender.tag == 0 {
            
        }
        else {
            let nav = UIStoryboard(name: "Chat", bundle: nil).instantiateViewController(withIdentifier: "FullAlbumNavigationController")
            let imagePicker = nav.childViewControllers.first as! FullAlbumCollectionViewController
            imagePicker.imageDelegate = self
            self.present(nav, animated: true, completion: {
                UIApplication.shared.statusBarStyle = .default
            })
        }
    }
    
    func actionShowMoreOptions(_ sender: UIButton) {
        UIView.animate(withDuration: 0.4) {
            self.uiviewSelectLocation.alpha = 0
            self.uiviewMoreOptions.alpha = 0
            self.uiviewAddDescription.alpha = 0
            self.labelCreateMediaPinTitle.alpha = 0
            self.buttonMediaSubmit.alpha = 0
            self.collectionViewMedia.alpha = 0
            self.buttonAnonymous.alpha = 0
            if !self.buttonSelectMedia.isHidden {
                self.buttonSelectMedia.alpha = 0
                self.buttonTakeMedia.alpha = 0
            }
            
            self.labelMediaPinMoreOptions.alpha = 1
            self.uiviewDuration.alpha = 1
            self.uiviewInterRadius.alpha = 1
            self.uiviewPinPromot.alpha = 1
            self.buttonBack.alpha = 1
        }
    }
    
    func actionShowAddDes(_ sender: UIButton) {
        UIView.animate(withDuration: 0.4) {
            self.uiviewSelectLocation.alpha = 0
            self.uiviewMoreOptions.alpha = 0
            self.uiviewAddDescription.alpha = 0
            self.labelCreateMediaPinTitle.alpha = 0
            self.buttonMediaSubmit.alpha = 0
            self.collectionViewMedia.alpha = 0
            self.buttonAnonymous.alpha = 0
            if !self.buttonSelectMedia.isHidden {
                self.buttonSelectMedia.alpha = 0
                self.buttonTakeMedia.alpha = 0
            }
            
            self.labelMediaPinAddDes.alpha = 1
            self.buttonBack.alpha = 1
            self.textViewForMediaPin.alpha = 1
        }
    }
    
    func actionBack(_ sender: UIButton) {
        UIView.animate(withDuration: 0.4) {
            self.uiviewSelectLocation.alpha = 1
            self.uiviewMoreOptions.alpha = 1
            self.uiviewAddDescription.alpha = 1
            self.labelCreateMediaPinTitle.alpha = 1
            self.buttonMediaSubmit.alpha = 1
            self.collectionViewMedia.alpha = 1
            self.buttonAnonymous.alpha = 1
            if !self.buttonSelectMedia.isHidden {
                self.buttonSelectMedia.alpha = 1
                self.buttonTakeMedia.alpha = 1
            }
            
            self.labelMediaPinMoreOptions.alpha = 0
            self.uiviewDuration.alpha = 0
            self.uiviewInterRadius.alpha = 0
            self.uiviewPinPromot.alpha = 0
            self.buttonBack.alpha = 0
            self.textViewForMediaPin.alpha = 0
            self.labelMediaPinAddDes.alpha = 0
        }
    }
    
    func actionFinishEditing(_ sender: UIButton) {
        textViewForMediaPin.endEditing(true)
        textViewForMediaPin.resignFirstResponder()
    }
    
    func actionBackToPinSelections(_ sender: UIButton) {
        UIView.animate(withDuration: 0.2, delay: 0, options: .transitionFlipFromBottom, animations: ({
            self.uiviewCreateMediaPin.alpha = 0.0
        }), completion: { (done: Bool) in
            if done {
                self.dismiss(animated: false, completion: nil)
                self.delegate?.backFromCMP(back: true)
            }
        })
    }
    
    func actionCloseSubmitPins(_ sender: UIButton!) {
        self.dismiss(animated: false, completion: {
            self.delegate?.closePinMenuCMP(close: true)
        })
    }
    
    func actionSubmitMedia(_ sender: UIButton) {
        if sender.tag == 0 {
            return
        }
        sender.tag = 0
        activityIndicator = UIActivityIndicatorView()
        activityIndicator.activityIndicatorViewStyle = .whiteLarge
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = UIColor(red: 149/255, green: 207/255, blue: 246/255, alpha: 1.0)
        uiviewCreateMediaPin.addSubview(activityIndicator)
        uiviewCreateMediaPin.bringSubview(toFront: activityIndicator)
        activityIndicator.startAnimating()
        uploadingFile(image: selectedMediaArray[0],
                      count: 0,
                      total: selectedMediaArray.count,
                      fileIDs: "")
    }
    
    private func uploadingFile(image: UIImage, count: Int, total: Int, fileIDs: String) {
        let mediaImage = FaeImage()
        mediaImage.type = "image"
        mediaImage.image = image
        mediaImage.faeUploadFile { (status: Int, message: Any?) in
            if status / 100 == 2 {
                print("[uploadingFile] Successfully upload Image File")
                let fileIDJSON = JSON(message!)
                var file_IDs = fileIDs
                if let file_id = fileIDJSON["file_id"].int {
                    if fileIDs == "" {
                        file_IDs = "\(file_id)"
                    }
                    else {
                        file_IDs = "\(file_IDs);\(file_id)"
                    }
                }
                else {
                    print("[uploadingFile] Fail to process file_id")
                }
                if count + 1 >= total {
                    self.submitMediaPin(fileIDs: file_IDs)
                    return
                }
                self.uploadingFile(image: self.selectedMediaArray[count+1],
                                   count: count+1,
                                   total: total,
                                   fileIDs: file_IDs)
            } else {
                print("[uploadingFile] Fail to upload Image File")
            }
        }
    }
    
    private func submitMediaPin(fileIDs: String) {
        
        let mediaContent = textViewForMediaPin.text
        if mediaContent == "" {
            showAlert(title: "Add Description", message: "")
            return
        }
        
        let postSingleMedia = FaeMap()
        
        var submitLatitude = selectedLatitude
        var submitLongitude = selectedLongitude
        
        if labelSelectLocationContent.text == "Current Location" {
            submitLatitude = "\(currentLatitude)"
            submitLongitude = "\(currentLongitude)"
        }
        
        postSingleMedia.whereKey("file_ids", value: fileIDs)
        postSingleMedia.whereKey("geo_latitude", value: submitLatitude)
        postSingleMedia.whereKey("geo_longitude", value: submitLongitude)
        postSingleMedia.whereKey("description", value: mediaContent)
        postSingleMedia.whereKey("interaction_radius", value: "99999999")
        postSingleMedia.whereKey("duration", value: "180")
        postSingleMedia.whereKey("anonymous", value: "\(anonymous)")
        
        postSingleMedia.postPin(type: "media") {(status: Int, message: Any?) in
            let getMessage = JSON(message!)
            if status / 100 != 2 {
                self.showAlert(title: "Post Moment Failed", message: "Please try agian")
                self.activityIndicator.stopAnimating()
                print("[submitMediaPin] status is not 2XX")
                return
            }
            if let mediaID = getMessage["media_id"].int {
                print("Have Post Media")
                let getJustPostedMedia = FaeMap()
                getJustPostedMedia.getPin(type: "media", pinId: "\(mediaID)"){(status: Int, message: Any?) in
                    print("[submitMediaPin] get media_id: \(mediaID) of this posted comment")
                    let latDouble = Double(submitLatitude!)
                    let longDouble = Double(submitLongitude!)
                    let lat = CLLocationDegrees(latDouble!)
                    let long = CLLocationDegrees(longDouble!)
                    self.dismiss(animated: false, completion: {
                        self.activityIndicator.stopAnimating()
                        self.delegate?.sendMediaGeoInfo(mediaID: "\(mediaID)", latitude: lat, longitude: long)
                    })
                }
            }
            else {
                self.buttonMediaSubmit.tag = 1
                self.activityIndicator.stopAnimating()
                print("[submitMediaPin] Cannot get media ID")
            }
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: "Add Description", message: message, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.destructive)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
}