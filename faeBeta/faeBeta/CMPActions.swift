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
import Photos

extension CreateMomentPinViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // MARK: - CAMERA & GALLERY NOT ALLOWING ACCESS - ALERT
    // Vicky 06/23/17
    fileprivate func alertToEncourageAccess(_ accessType: String) {
        // Camera or photo library not available - Alert
        var title: String!
        var message: String!
        if accessType == "camera" {
            title = "Cannot access camera"
            message = "Open System Settings -> Fae Map to turn on the camera access"
        } else {
            title = "Cannot access photo library"
            message = "Open System Settings -> Fae Map to turn on the photo library access"
        }
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let settingsAction = UIAlertAction(title: "Settings", style: .destructive) { (_) -> Void in
            let settingsUrl = NSURL(string: UIApplicationOpenSettingsURLString)
            if let url = settingsUrl {
                if accessType == "camera" {
                    DispatchQueue.main.async {
                        UIApplication.shared.openURL(url as URL)
                    }
                } else {
                    UIApplication.shared.openURL(url as URL)
                    // UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
                }
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        alertController.addAction(settingsAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }

    // Vicky 06/23/17 End
    
    func actionAddMedia(_ sender: UIButton) { // Add or Cancel Adding
        if sender.tag == 0 {
            let angle: CGFloat = (-45 * 3.14 / 180.0) as CGFloat
            sender.tag = 1
            UIView.animate(withDuration: 0.5) {
                self.btnAddMedia.transform = CGAffineTransform(rotationAngle: angle)
                self.collectionViewMedia.center.x -= 249
                self.btnTakeMedia.alpha = 1
                self.btnSelectMedia.alpha = 1
            }
        } else {
            sender.tag = 0
            UIView.animate(withDuration: 0.5) {
                self.btnAddMedia.transform = CGAffineTransform(rotationAngle: 0)
                self.collectionViewMedia.center.x += 249
                self.btnTakeMedia.alpha = 0
                self.btnSelectMedia.alpha = 0
            }
        }
    }
    
    fileprivate func checkCamera() {
        let cameraStatus = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
        switch cameraStatus {
        case .authorized:
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = .camera
            imagePicker.delegate = self
            self.present(imagePicker, animated: true, completion: nil)
        case .denied:
            self.alertToEncourageAccess("camera")
            return
        case .notDetermined:
            if AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo).count > 0 {
                AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo) { _ in
                    DispatchQueue.main.async() {
                        self.checkCamera()
                    }
                }
            }
            return
        case .restricted:
            self.showAlert(title: "Camera not allowed", message: "You're not allowed to capture camera devices")
            return
        }
    }
    
    func actionTakePhoto(_ sender: UIButton) {
        // Vicky 06/23/17
        self.checkCamera()
        // Vicky 06/23/17
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String: AnyObject]?) {
        
        selectedMediaArray.append(image)
        collectionViewMedia.isHidden = false
        collectionViewMedia.frame.origin.x = 0
        btnTakeMedia.alpha = 0
        btnSelectMedia.alpha = 0
        btnAddMedia.alpha = 1
        btnAddMedia.tag = 0
        btnAddMedia.transform = CGAffineTransform(rotationAngle: 0)
        collectionViewMedia.reloadData()
        collectionViewMedia.scrollToItem(at: IndexPath(row: selectedMediaArray.count - 1, section: 0),
                                         at: .right,
                                         animated: false)
        if !selectedMediaArray.isEmpty {
            collectionViewMedia.isScrollEnabled = true
            boolBtnSubmitEnabled = true
            setSubmitButton(withTitle: btnSubmit.currentTitle!, isEnabled: true)
        }
        if selectedMediaArray.count == 6 {
            btnAddMedia.alpha = 0
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
        var photoStatus = PHPhotoLibrary.authorizationStatus()
        if photoStatus != .authorized {
            PHPhotoLibrary.requestAuthorization({ status in
                photoStatus = status
                if photoStatus != .authorized {
                    self.alertToEncourageAccess("library")
                    return
                }
                let nav = UIStoryboard(name: "Chat", bundle: nil).instantiateViewController(withIdentifier: "FullAlbumNavigationController")
                let imagePicker = nav.childViewControllers.first as! FullAlbumCollectionViewController
                imagePicker.imageDelegate = self
                imagePicker.isCSP = false
                imagePicker._maximumSelectedPhotoNum = numMediaLeft
                self.present(nav, animated: true, completion: {
                    UIApplication.shared.statusBarStyle = .default
                })
            })
        } else {
            let nav = UIStoryboard(name: "Chat", bundle: nil).instantiateViewController(withIdentifier: "FullAlbumNavigationController")
            let imagePicker = nav.childViewControllers.first as! FullAlbumCollectionViewController
            imagePicker.imageDelegate = self
            imagePicker.isCSP = true
            imagePicker._maximumSelectedPhotoNum = numMediaLeft
            self.present(nav, animated: true, completion: {
                UIApplication.shared.statusBarStyle = .default
            })
        }
    }

    
    func uploadingFile(image: UIImage, count: Int, total: Int, fileIDs: String) {
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
                    } else {
                        file_IDs = "\(file_IDs);\(file_id)"
                    }
                } else {
                    print("[uploadingFile] Fail to process file_id")
                }
                if count + 1 >= total {
                    self.submitMediaPin(fileIDs: file_IDs)
                    return
                }
                self.uploadingFile(image: self.selectedMediaArray[count + 1],
                                   count: count + 1,
                                   total: total,
                                   fileIDs: file_IDs)
            } else {
                print("[uploadingFile] Fail to upload Image File")
            }
        }
    }
    
    fileprivate func submitMediaPin(fileIDs: String) {
        
        let mediaContent = textviewDescrip.text
        
        let postSingleMedia = FaeMap()
        
        var submitLatitude = self.selectedLatitude
        var submitLongitude = self.selectedLongitude
        
        if strSelectedLocation == nil || strSelectedLocation == "" {
            let defaultLoc = randomLocation()
            submitLatitude = "\(defaultLoc.latitude)"
            submitLongitude = "\(defaultLoc.longitude)"
        }
        
        postSingleMedia.whereKey("file_ids", value: fileIDs)
        postSingleMedia.whereKey("geo_latitude", value: submitLatitude)
        postSingleMedia.whereKey("geo_longitude", value: submitLongitude)
        if mediaContent != "" {
            postSingleMedia.whereKey("description", value: mediaContent)
        } else {
            
        }
        postSingleMedia.whereKey("interaction_radius", value: "99999999")
        postSingleMedia.whereKey("duration", value: "180")
        postSingleMedia.whereKey("anonymous", value: "\(switchAnony.isOn)")
        
        postSingleMedia.postPin(type: "media") { (status: Int, message: Any?) in
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
                getJustPostedMedia.getPin(type: "media", pinId: "\(mediaID)") { (_: Int, _: Any?) in
                    print("[submitMediaPin] get media_id: \(mediaID) of this posted comment")
                    let latDouble = Double(submitLatitude!)
                    let longDouble = Double(submitLongitude!)
                    let lat = CLLocationDegrees(latDouble!)
                    let long = CLLocationDegrees(longDouble!)
                    self.dismiss(animated: false, completion: {
                        self.activityIndicator.stopAnimating()
                        self.delegate?.sendGeoInfo(pinID: "\(mediaID)", type: "media", latitude: lat, longitude: long, zoom: Float(self.zoomLevelCallBack))
                    })
                }
            } else {
                self.btnSubmit.tag = 1
                self.activityIndicator.stopAnimating()
                print("[submitMediaPin] Cannot get media ID")
            }
        }
    }
}
