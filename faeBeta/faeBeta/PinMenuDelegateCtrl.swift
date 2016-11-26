//
//  PinMenuDelegateCtrl.swift
//  faeBeta
//
//  Created by Yue on 11/15/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

extension PinMenuViewController: CreateCommentPinDelegate, CreateMediaPinDelegate {
    // CCP
    func backFromCCP(back: Bool) {
        if back {
            UIView.animate(withDuration: 0.2, animations: {
                self.uiviewPinSelections.alpha = 1.0
            })
        }
    }
    // CCP
    func closePinMenu(close: Bool) {
        if close {
            self.dismiss(animated: false, completion: nil)
        }
    }
    // CCP
    func sendCommentGeoInfo(commentID: String, latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        self.dismiss(animated: false, completion: {
            self.delegate?.sendPinGeoInfo(commentID: commentID, latitude: latitude, longitude: longitude)
        })
    }
    // CMP
    func backFromCMP(back: Bool) {
        if back {
            UIView.animate(withDuration: 0.2, animations: {
                self.uiviewPinSelections.alpha = 1.0
            })
        }
    }
    // CMP
    func closePinMenuCMP(close: Bool) {
        if close {
            self.dismiss(animated: false, completion: nil)
        }
    }
    // CMP
    func sendMediaGeoInfo(mediaID: String, latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        self.dismiss(animated: false, completion: {
            self.delegate?.sendPinGeoInfo(commentID: mediaID, latitude: latitude, longitude: longitude)
        })
    }
}
