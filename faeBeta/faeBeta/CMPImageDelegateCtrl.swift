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
    }
    
    func reArrangePhotos() {
        
    }
    
    func sendImages(_ images: [UIImage]) {
        for image in images {
            selectedMediaArray.append(image)
        }
        collectionViewMedia.isHidden = false
        if selectedMediaArray.count == 1 {
            collectionViewMedia.frame.origin.x = 107
            collectionViewMedia.frame.size.width = 200
        }
        else {
            collectionViewMedia.frame.origin.x = 0
            collectionViewMedia.frame.size.width = 307
        }
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
            buttonMediaSubmit.isEnabled = true
            buttonMediaSubmit.backgroundColor = UIColor(red: 149/255, green: 207/255, blue: 246/255, alpha: 1.0)
            buttonMediaSubmit.setTitleColor(UIColor.white, for: UIControlState())
        }
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    func sendVideoData(_ video: Data, snapImage: UIImage, duration: Int) {
        print("Debug sendVideo")
    }
    
    func cancel() {
        UIApplication.shared.statusBarStyle = .lightContent
    }
}
