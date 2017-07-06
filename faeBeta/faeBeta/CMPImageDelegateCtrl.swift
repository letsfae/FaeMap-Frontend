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
        self.view.addSubview(newMedia)
    }
    
    func sendImages(_ images: [UIImage]) {
        for image in images {
            selectedMediaArray.append(image)
        }
        collectionViewMedia.isHidden = false
        collectionViewMedia.frame.origin.x = 0
        btnTakeMedia.alpha = 0
        btnSelectMedia.alpha = 0
        btnAddMedia.alpha = 1
        btnAddMedia.tag = 0
        btnAddMedia.transform = CGAffineTransform(rotationAngle: 0)
        collectionViewMedia.reloadData()
        collectionViewMedia.scrollToItem(at: IndexPath(row: selectedMediaArray.count-1, section: 0),
                                          at: .right,
                                          animated: false)
        if !selectedMediaArray.isEmpty {
            collectionViewMedia.isScrollEnabled = true
            self.boolBtnSubmitEnabled = true
            setSubmitButton(withTitle: btnSubmit.currentTitle!, isEnabled: true)
        }
        if selectedMediaArray.count == 6 {
            btnAddMedia.alpha = 0
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
