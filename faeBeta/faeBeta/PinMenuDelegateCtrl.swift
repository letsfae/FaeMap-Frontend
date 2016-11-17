//
//  PinMenuDelegateCtrl.swift
//  faeBeta
//
//  Created by Yue on 11/15/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

extension PinMenuViewController: CreateCommentPinDelegate {
    func backFromCCP(back: Bool) {
        if back {
            UIView.animate(withDuration: 0.2, animations: {
                self.uiviewPinSelections.alpha = 1.0
            })
        }
    }
    
    func closePinMenu(close: Bool) {
        if close {
            self.dismiss(animated: false, completion: nil)
        }
    }
    
    func sendCommentGeoInfo(commentID: String, latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        self.dismiss(animated: false, completion: {
            self.delegate?.sendPinGeoInfo(commentID: commentID, latitude: latitude, longitude: longitude)
        })
    }
}
