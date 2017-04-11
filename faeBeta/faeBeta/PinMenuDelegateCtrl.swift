//
//  PinMenuDelegateCtrl.swift
//  faeBeta
//
//  Created by Yue on 11/15/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

extension PinMenuViewController: CreatePinDelegate {
    // CreatePinDelegate
    func backFromPinCreating(back: Bool) {
        if back {
            UIView.animate(withDuration: 0.2, animations: {
                self.uiviewPinSelections.alpha = 1.0
            })
        }
    }
    // CreatePinDelegate
    func closePinMenu(close: Bool) {
        if close {
            self.dismiss(animated: false, completion: {
                self.delegate?.whenDismissPinMenu()
            })
        }
    }
    // CreatePinDelegate
    func sendGeoInfo(pinID: String, type: String, latitude: CLLocationDegrees, longitude: CLLocationDegrees, zoom: Float) {
        self.dismiss(animated: false, completion: {
            self.delegate?.sendPinGeoInfo(pinID: pinID, type: type, latitude: latitude, longitude: longitude, zoom: zoom)
        })
    }
}
