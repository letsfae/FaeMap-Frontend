//
//  Camera.swift
//  quickChat
//
//  Created by User on 6/7/16.
//  Copyright © 2016 User. All rights reserved.
//

import Foundation
import MobileCoreServices

class Camera {
    
    weak var delegate : (UINavigationControllerDelegate & UIImagePickerControllerDelegate)?
    
    init(delegate_: (UINavigationControllerDelegate & UIImagePickerControllerDelegate)?) {
        delegate = delegate_
    }
    
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
        imagePicker.videoMaximumDuration = 10
        imagePicker.videoQuality = .typeIFrame960x540
        imagePicker.delegate = delegate
        //let rootViewController: UIViewController = UIApplication.shared.windows.last!.rootViewController!
        //rootViewController.present(imagePicker, animated: true, completion: nil)
        target.present(imagePicker, animated: true, completion: nil)
    }
}
