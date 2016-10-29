//
//  SelectLocation.swift
//  faeBeta
//
//  Created by Yue on 10/19/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

extension CreatePinViewController: SelectLocationViewControllerDelegate {
    func actionSelectLocation(sender: UIButton) {
        let selectLocationVC = SelectLocationViewController()
        selectLocationVC.modalPresentationStyle = .OverCurrentContext
        selectLocationVC.delegate = self
        self.presentViewController(selectLocationVC, animated: false, completion: nil)
    }
    
    func sendAddress(value: String) {
        labelSelectLocationContent.text = value
    }
    
    func sendGeoInfo(latitude: String, longitude: String) {
        selectedLatitude = latitude
        selectedLongitude = longitude
    }
}
