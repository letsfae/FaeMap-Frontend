//
//  CMPImageDelegateCtrl.swift
//  faeBeta
//
//  Created by Yue on 11/24/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

extension CreateMomentPinViewController: SendMutipleImagesDelegate {
    
    func addNewMediaToSubmit(image: UIImage) {
        let newMedia = UIImageView(frame: CGRect(x:107, y: 200, width:200, height:200))
        newMedia.image = image
        newMedia.clipsToBounds = true
        newMedia.contentMode = .scaleAspectFill
        newMedia.center.x = screenWidth / 2
        newMedia.layer.cornerRadius = 20
        uiviewCreateMediaPin.addSubview(newMedia)
        selectedMediaArray.append(newMedia)
    }
    
    func reArrangePhotos() {
        
    }
    
    func sendImages(_ images: [UIImage]) {
        print("Debug sendImages")
        for image in images {
            addNewMediaToSubmit(image: image)
        }
    }
    
    func sendVideoData(_ video: Data, snapImage: UIImage, duration: Int) {
        print("Debug sendVideo")
    }
}
