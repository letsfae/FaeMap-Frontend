//
//  EditOptionButtonActions.swift
//  faeBeta
//
//  Created by Jacky on 1/8/17.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit

extension EditMoreOptionsViewController {
    
    func actionCancel(_ sender: UIButton){
        self.dismiss(animated: true, completion: nil)
    }
    
    func actionSave(_ sender: UIButton){
        self.dismiss(animated: true, completion: nil)
        
//        let updateComment = FaeMap()
//        print("[updatePin] \(pinGeoLocation.latitude), \(pinGeoLocation.longitude)")
//        updateComment.whereKey("geo_latitude", value: "\(pinGeoLocation.latitude)")
//        updateComment.whereKey("geo_longitude", value: "\(pinGeoLocation.longitude)")
//        if pinType == "comment" {
//           
//        }else if pinType == "media" {
//
//        }else if pinType == "chat_room"{
//            
//        }
//        updateComment.updatePin(pinType, pinId: pinID) {(status: Int, message: Any?) in
//            if status / 100 == 2 {
//                print("Success -> Update \(self.pinType)")
//                self.dismiss(animated: true, completion: nil)
//            }
//            else {
//                print("Fail -> Update \(self.pinType)")
//            }
//        }
    }
    func actionSelectLocation() {
        let selectLocationVC = SelectLocationViewController()
        selectLocationVC.modalPresentationStyle = .overCurrentContext
        selectLocationVC.delegate = self
        selectLocationVC.isCreatingMode = false
        selectLocationVC.zoomLevel = zoomLevel
        selectLocationVC.currentLocation2D = pinGeoLocation
        if pinType == "media"{
            selectLocationVC.pinType = "moment"
        }else {
            selectLocationVC.pinType = pinType
        }
        self.present(selectLocationVC, animated: false, completion: nil)
    }
}
