//
//  SelectLocation.swift
//  faeBeta
//
//  Created by Yue on 10/19/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

extension CreatePinViewController: SelectLocationViewControllerDelegate {
    func actionSelectLocation(_ sender: UIButton) {
        let selectLocationVC = SelectLocationViewController()
        selectLocationVC.modalPresentationStyle = .overCurrentContext
        selectLocationVC.delegate = self
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
