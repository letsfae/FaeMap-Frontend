//
//  MSVAddrAutoCompletion.swift
//  faeBeta
//
//  Created by Yue Shen on 10/29/17.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit
import SwiftyJSON

extension MapSearchViewController {
    
    // GMSLookUpPlaceForCoordinate
    func lookUpForCoordinate() {
//        General.shared.lookUpForCoordinate { (place) in
//            let region = MKCoordinateRegionMakeWithDistance(place.coordinate, 20000, 20000)
//            self.delegate?.jumpToLocation?(region: region)
//            self.navigationController?.popViewController(animated: false)
//        }
    }
    
    // GMSAutocompleteFilter
    func placeAutocomplete(_ searchText: String) {
        Key.shared.selectedSearchedCity = nil
        CitySearcher.shared.cityAutoComplete(searchText) { (status, result) in
            self.geobytesCityData.removeAll()
            guard status / 100 == 2 else {
                self.showOrHideViews(searchText: searchText)
                return
            }
            guard let result = result else {
                self.showOrHideViews(searchText: searchText)
                return
            }
            joshprint("got data from geobytes")
            let value = JSON(result)
            let citys = value.arrayValue
            for city in citys {
                if city.stringValue == "%s" || city.stringValue == "" {
                    break
                }
                self.geobytesCityData.append(city.stringValue)
                
            }
            self.showOrHideViews(searchText: searchText)
        }
    }
}
