//
//  CMPSelectLocation.swift
//  faeBeta
//
//  Created by Yue on 11/24/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

extension CreateMomentPinViewController: SelectLocationViewControllerDelegate {
    func actionSelectLocation(_ sender: UIButton) {
        let selectLocationVC = SelectLocationViewController()
        selectLocationVC.modalPresentationStyle = .overCurrentContext
        selectLocationVC.delegate = self
        selectLocationVC.pinType = "moment" //Should it be changed to "media"
        selectLocationVC.currentLocation2D = self.currentLocation2D
        selectLocationVC.zoomLevel = self.zoomLevel
        self.present(selectLocationVC, animated: false, completion: nil)
    }
    
    func sendAddress(_ value: String) {
        labelSelectLocationContent.text = value
    }
    
    func sendGeoInfo(_ latitude: String, longitude: String) {
        selectedLatitude = latitude
        selectedLongitude = longitude
    }
}
