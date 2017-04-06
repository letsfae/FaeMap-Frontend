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

extension CreateMomentPinViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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
    
    func actionTakePhoto(_ sender: UIButton) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        
        selectedMediaArray.append(image)
        collectionViewMedia.isHidden = false
        collectionViewMedia.frame.origin.x = 0
        buttonTakeMedia.alpha = 0
        buttonSelectMedia.alpha = 0
        buttonAddMedia.alpha = 1
        buttonAddMedia.tag = 0
        buttonAddMedia.transform = CGAffineTransform(rotationAngle: 0)
        collectionViewMedia.reloadData()
        collectionViewMedia.scrollToItem(at: IndexPath(row: selectedMediaArray.count-1, section: 0),
                                         at: .right,
                                         animated: false)
        if !selectedMediaArray.isEmpty {
            collectionViewMedia.isScrollEnabled = true
            buttonMediaSubmit.isEnabled = true
            buttonMediaSubmit.backgroundColor = UIColor(red: 149/255, green: 207/255, blue: 246/255, alpha: 1.0)
            buttonMediaSubmit.setTitleColor(UIColor.white, for: UIControlState())
        }
        if selectedMediaArray.count == 6 {
            buttonAddMedia.alpha = 0
        }
        UIApplication.shared.statusBarStyle = .lightContent
        picker.dismiss(animated: true, completion: nil)
    }
    
    func actionTakeMedia(_ sender: UIButton) {
        let numMediaLeft = 6 - selectedMediaArray.count
        if numMediaLeft == 0 {
            self.showAlert(title: "You can only have up to 6 items for your story", message: "please try again")
            return
        }
        let nav = UIStoryboard(name: "Chat", bundle: nil).instantiateViewController(withIdentifier: "FullAlbumNavigationController")
        let imagePicker = nav.childViewControllers.first as! FullAlbumCollectionViewController
        imagePicker.imageDelegate = self
        imagePicker.isCSP = true
        imagePicker._maximumSelectedPhotoNum = numMediaLeft
        self.present(nav, animated: true, completion: {
            UIApplication.shared.statusBarStyle = .default
        })
    }
    
    func actionShowMoreOptions(_ sender: UIButton) {
        UIView.animate(withDuration: 0.4) {
            self.uiviewSelectLocation.alpha = 0
            self.uiviewMoreOptions.alpha = 0
            self.uiviewAddDescription.alpha = 0
            self.labelCreateMediaPinTitle.alpha = 0
            self.buttonMediaSubmit.alpha = 0
            self.collectionViewMedia.alpha = 0
            if !self.buttonSelectMedia.isHidden {
                self.buttonSelectMedia.alpha = 0
                self.buttonTakeMedia.alpha = 0
            }
            self.buttonAddMedia.alpha = 0
            self.labelMediaPinMoreOptions.alpha = 1
            self.tableMoreOptions.alpha = 1
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
            if !self.buttonSelectMedia.isHidden {
                self.buttonSelectMedia.alpha = 0
                self.buttonTakeMedia.alpha = 0
            }
            self.buttonAddMedia.alpha = 0
            self.labelMediaPinAddDes.alpha = 1
            self.buttonBack.alpha = 1
            self.textViewForMediaPin.alpha = 1
            self.textViewForMediaPin.becomeFirstResponder()
        }
        self.currentView = .moreOptionsTable
    }
    
    func actionBack(_ sender: UIButton) {
        if self.currentView == .moreOptionsTable {
            UIView.animate(withDuration: 0.4, animations: { void in
                self.uiviewSelectLocation.alpha = 1
                self.uiviewMoreOptions.alpha = 1
                self.uiviewAddDescription.alpha = 1
                self.labelCreateMediaPinTitle.alpha = 1
                self.buttonMediaSubmit.alpha = 1
                self.collectionViewMedia.alpha = 1
                if self.selectedMediaArray.count > 0 {
                    self.buttonAddMedia.alpha = 1
                    self.buttonSelectMedia.alpha = 0
                    self.buttonTakeMedia.alpha = 0
                }
                else if self.selectedMediaArray.count == 0 {
                    self.buttonSelectMedia.alpha = 1
                    self.buttonTakeMedia.alpha = 1
                    self.buttonAddMedia.alpha = 0
                }
                self.labelMediaPinMoreOptions.alpha = 0
                self.tableMoreOptions.alpha = 0
                self.buttonBack.alpha = 0
                self.textViewForMediaPin.alpha = 0
                self.labelMediaPinAddDes.alpha = 0
            }, completion: { complete in
                self.inputToolbar.mode = .emoji
            })
        }else if self.currentView == .addTags {
            self.tableMoreOptions.reloadData()
            UIView.animate(withDuration: 0.4, animations: {void in
                self.textAddTags.alpha = 0
                self.tableMoreOptions.alpha = 1
                self.labelMediaPinMoreOptions.text = "More Options"
            }, completion: {done in
                self.inputToolbar.mode = .emoji
                self.currentView = .moreOptionsTable
            })
        }
        if textViewForMediaPin.text != "" {
            labelAddDesContent.text = textViewForMediaPin.text
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
                self.delegate?.backFromPinCreating(back: true)
            }
        })
    }
    
    func actionCloseSubmitPins(_ sender: UIButton!) {
        self.dismiss(animated: false, completion: {
            self.delegate?.closePinMenu(close: true)
        })
    }
    
    func actionSubmitMedia(_ sender: UIButton) {
        if selectedMediaArray.count == 0 {
            showAlert(title: "Please add at least one image!", message: "")
            return
        }
        else if textViewForMediaPin.text == "" {
            showAlert(title: "Please add a description for your story!", message: "")
            return
        }
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
    
    func switchToAddTags() {
        self.currentView = .addTags
        if textAddTags == nil {
            textAddTags = CreatePinAddTagsTextView(frame: CGRect(x: (screenWidth - 290) / 2, y: 195, width: 290, height: 35), textContainer: nil)
            textAddTags.placeHolder = "Add Tags to promote your pin in searches..."
            textAddTags.observerDelegate = self
            self.view.addSubview(textAddTags)
        }
        textAddTags.alpha = 0
        inputToolbar.mode = .tag
        UIView.animate(withDuration: 0.3, animations: {
            Void in
            self.tableMoreOptions.alpha = 0
            self.labelMediaPinMoreOptions.text = "Add Description"
            self.textAddTags.alpha = 1
        }, completion:{
            Complete in
        })
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
        
        let postSingleMedia = FaeMap()
        
        var submitLatitude = selectedLatitude
        var submitLongitude = selectedLongitude
        
        if labelSelectLocationContent.text == "Choose Location" { //Changed by Yao cause the default text is "Choose Location"
            let defaultLoc = randomLocation()
            submitLatitude = "\(defaultLoc.latitude)"
            submitLongitude = "\(defaultLoc.longitude)"
        }
        
        postSingleMedia.whereKey("file_ids", value: fileIDs)
        postSingleMedia.whereKey("geo_latitude", value: submitLatitude)
        postSingleMedia.whereKey("geo_longitude", value: submitLongitude)
        if mediaContent != "" {
            postSingleMedia.whereKey("description", value: mediaContent)
        }
        else {
            
        }
        postSingleMedia.whereKey("interaction_radius", value: "99999999")
        postSingleMedia.whereKey("duration", value: "180")
        postSingleMedia.whereKey("anonymous", value: "\(switchAnony.isOn)")
        
        postSingleMedia.postPin(type: "media") {(status: Int, message: Any?) in
            let getMessage = JSON(message!)
            if status / 100 != 2 {
                self.showAlert(title: "Post Moment Failed", message: "Please try again")
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
                        self.delegate?.sendGeoInfo(pinID: "\(mediaID)", latitude: lat, longitude: long, zoom: self.zoomLevelCallBack)
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
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.destructive)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
}
