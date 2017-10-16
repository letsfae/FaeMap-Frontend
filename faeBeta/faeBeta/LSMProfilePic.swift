//
//  LSMProfilePic.swift
//  faeBeta
//
//  Created by Yue Shen on 10/15/17.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit
import Photos

extension LeftSlidingMenuViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate, SendMutipleImagesDelegate {
    
    // SendMutipleImagesDelegate
    func sendImages(_ images: [UIImage]) {
        print("send image for avatar")
        if let image = images.first {
            uploadProfileAvatar(image: image)
        }   
    }
    
    func uploadProfileAvatar(image: UIImage) {
        view.isUserInteractionEnabled = false
        activityIndicator.startAnimating()
        let avatar = FaeImage()
        avatar.image = image
        avatar.faeUploadProfilePic { (code: Int, message: Any?) in
            self.activityIndicator.stopAnimating()
            self.view.isUserInteractionEnabled = true
            if code / 100 == 2 {
                self.imgAvatar.image = image
                print("[uploadProfileAvatar] succeed")
            }
            else {
                print("[uploadProfileAvatar] fail")
                self.showAlert(title: "Upload Profile Avatar Failed", message: "please try again")
                return
            }
        }
    }
    
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.destructive)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func addProfileAvatar() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        //imagePicker.sourceType = .camera
        imagePicker.sourceType = .photoLibrary // prevent simulator crashing
        let menu = UIAlertController(title: nil, message: "Choose image", preferredStyle: .actionSheet)
        menu.view.tintColor = UIColor._2499090()
        let showLibrary = UIAlertAction(title: "Choose from library", style: .default) { (alert: UIAlertAction) in
            var photoStatus = PHPhotoLibrary.authorizationStatus()
            if photoStatus != .authorized {
                PHPhotoLibrary.requestAuthorization({ (status) in
                    photoStatus = status
                    if photoStatus != .authorized {
                        self.showAlert(title: "Cannot access photo library", message: "Open System Setting -> Fae Map to turn on the camera access")
                        return
                    }
                    let imagePicker = FullAlbumCollectionViewController(collectionViewLayout: UICollectionViewFlowLayout())
                    imagePicker.imageDelegate = self
                    imagePicker.boolCreateStoryPin = false
                    imagePicker._maximumSelectedPhotoNum = 1
                    self.present(imagePicker, animated: true, completion: nil)
                })
            } else {
                let albumPicker = FullAlbumCollectionViewController(collectionViewLayout: UICollectionViewFlowLayout())
                albumPicker.imageDelegate = self
                albumPicker.boolCreateStoryPin = false
                albumPicker._maximumSelectedPhotoNum = 1
                self.present(albumPicker, animated: true, completion: nil)
            }
        }
        let showCamera = UIAlertAction(title: "Take photos", style: .default) { (alert: UIAlertAction) in
            var photoStatus = PHPhotoLibrary.authorizationStatus()
            if photoStatus != .authorized {
                PHPhotoLibrary.requestAuthorization({ (status) in
                    photoStatus = status
                    if photoStatus != .authorized {
                        self.showAlert(title: "Cannot access photo library", message: "Open System Setting -> Fae Map to turn on the camera access")
                        return
                    }
                    menu.removeFromParentViewController()
                    self.present(imagePicker, animated: true, completion: nil)
                })
            } else {
                menu.removeFromParentViewController()
                self.present(imagePicker, animated: true, completion: nil)
            }
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (alert: UIAlertAction) in
            
        }
        menu.addAction(showLibrary)
        menu.addAction(showCamera)
        menu.addAction(cancel)
        self.present(menu, animated: true, completion: nil)
    }
}
