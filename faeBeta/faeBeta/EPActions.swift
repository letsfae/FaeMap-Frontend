//
//  ECPActions.swift
//  faeBeta
//
//  Created by Jacky on 1/11/17.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit

extension EditPinViewController {
    func actionCancelCommentPinEditing(_ sender: UIButton) {
        textViewUpdateComment.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }
    
    func actionUpdateCommentPinEditing(_ sender: UIButton) {
        let updateComment = FaeMap()
        print("[updatePin] \(pinGeoLocation.latitude), \(pinGeoLocation.longitude)")
        updateComment.whereKey("geo_latitude", value: "\(pinGeoLocation.latitude)")
        updateComment.whereKey("geo_longitude", value: "\(pinGeoLocation.longitude)")
        if pinType == "comment" {
            updateComment.whereKey("content", value: textViewUpdateComment.text) //content or description
        } else if pinType == "media" {
            updateComment.whereKey("description", value: textViewUpdateComment.text)
            var fileIdString = ""
            for ID in mediaIdArray {
                if fileIdString == "" {
                    fileIdString = "\(ID)"
                }else {
                    fileIdString = "\(fileIdString);\(ID)"
                }
            }
            updateComment.whereKey("file_ids", value: fileIdString)
            print("newAddedFileIDs: \(fileIdString)")
        } else if pinType == "chat_room"{
            
        }
        updateComment.updatePin(pinType, pinId: pinID) {(status: Int, message: Any?) in
            if status / 100 == 2 {
                print("Success -> Update \(self.pinType)")
                self.delegate?.reloadPinContent(self.pinGeoLocation, zoom: self.zoomLevelCallBack)
                self.textViewUpdateComment.endEditing(true)
                self.dismiss(animated: true, completion: nil)
            }
            else {
                print("Fail -> Update \(self.pinType)")
            }
        }
    }
    func moreOptions(_ sender: UIButton) {
        let editMoreOptions = EditMoreOptionsViewController()
        editMoreOptions.delegate = self
        editMoreOptions.pinID = pinID
        editMoreOptions.pinType = pinType
        editMoreOptions.zoomLevel = zoomLevel
        editMoreOptions.pinGeoLocation = pinGeoLocation
        self.present(editMoreOptions, animated: true, completion: nil)
    }
}
