//
//  LSMProfilePic.swift
//  faeBeta
//
//  Created by Yue Shen on 10/15/17.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit
import Photos
import RealmSwift

extension LeftSlidingMenuViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate, ChooseAvatarDelegate {
    
    // MARK: - ChooseAvatarDelegate
    func finishChoosingAvatar(with imageData: Data) {
        guard let image = UIImage(data: imageData) else { return } // TODO: failure
        SetAvatar.uploadUserImage(image: image, vc: self, type: "leftSlidingMenu") {
            self.imgAvatar.image = image
        }
    }
    
    // MARK: - UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            picker.dismiss(animated: true, completion: nil)
            SetAvatar.showAlert(title: "Taking Photo Failed", message: "please try again", vc: self)
            return
        }
        picker.dismiss(animated: true, completion: nil)
        SetAvatar.uploadUserImage(image: image, vc: self, type: "leftSliding") {
            self.imgAvatar.image = image
        }
    }
}
