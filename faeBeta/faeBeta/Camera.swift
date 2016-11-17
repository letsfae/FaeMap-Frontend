//
//  Camera.swift
//  quickChat
//
//  Created by User on 6/7/16.
//  Copyright © 2016 User. All rights reserved.
//

import Foundation
import MobileCoreServices


// this is a class to present imagePicker, pick image from camera and library
class Camera {
    
    weak var delegate : (UINavigationControllerDelegate & UIImagePickerControllerDelegate)?
    
    init(delegate_: (UINavigationControllerDelegate & UIImagePickerControllerDelegate)?) {
        delegate = delegate_
    }
    
//  View photo in system library
    //    func PresentPhotoLibrary(_ target : UIViewController, canEdit : Bool) {
//        if !UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary)
//            && !UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.savedPhotosAlbum) {
//            return
//        }
//        
//        let type = kUTTypeImage as String
//        let imagePicker = UIImagePickerController()
//        
//        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
//            imagePicker.sourceType = .photoLibrary
//            
//            if let availableTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary) {
//                
//                if (availableTypes as NSArray).contains(type) {
//                    
//                    imagePicker.mediaTypes = [type]
//                    imagePicker.allowsEditing = canEdit
//                }
//            }
//        } else if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
//            imagePicker.sourceType = .savedPhotosAlbum
//            if let availableTypes = UIImagePickerController.availableMediaTypes(for: .savedPhotosAlbum) {
//                if (availableTypes as NSArray).contains(type) {
//                    imagePicker.mediaTypes = [type]
//                }
//            }
//        } else {
//            return
//        }
//        imagePicker.allowsEditing = canEdit
//        imagePicker.delegate = delegate
//        target.present(imagePicker, animated: true, completion: nil)
//    }
    
    // for photo & video taking
    func presentPhotoCamera(_ target : UIViewController, canEdit : Bool) {
        if !UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            return
        }
        let type1 = kUTTypeImage as String // take photo
        let type2 = kUTTypeMovie as String // shoot video
        let imagePicker = UIImagePickerController()
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            if let availableTypes = UIImagePickerController.availableMediaTypes(for: .camera) {
                if (availableTypes as NSArray).contains(type1) && (availableTypes as NSArray).contains(type2) {
                    imagePicker.mediaTypes = [type1, type2]
                    imagePicker.sourceType = UIImagePickerControllerSourceType.camera
                }
            }
            
            if UIImagePickerController.isCameraDeviceAvailable(.rear) {
                imagePicker.cameraDevice = UIImagePickerControllerCameraDevice.rear
            } else if UIImagePickerController.isCameraDeviceAvailable(.front) {
                imagePicker.cameraDevice = UIImagePickerControllerCameraDevice.front
            }
        } else {
            // show alert no camera
            return
        }
        imagePicker.allowsEditing = canEdit
        imagePicker.showsCameraControls = true
        imagePicker.delegate = delegate
        target.present(imagePicker, animated: true, completion: nil)
    }
}
