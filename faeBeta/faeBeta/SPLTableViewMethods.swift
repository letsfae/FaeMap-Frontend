//
//  SPLTableViewMethods.swift
//  faeBeta
//
//  Created by Yue on 11/15/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces

extension SelectLocationViewController: UITableViewDelegate, UITableViewDataSource {
    
    // MARK: UITableView Delegate and Datasource functions
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return placeholder.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "faeCellForAddressSearch", for: indexPath) as! FaeCellForMainScreenSearch
        cell.labelTitle.text = placeholder[indexPath.row].attributedPrimaryText.string
        if let secondaryText = placeholder[indexPath.row].attributedSecondaryText {
            cell.labelSubTitle.text = secondaryText.string
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let placesClient = GMSPlacesClient()
        placesClient.lookUpPlaceID(placeholder[indexPath.row].placeID!, callback: {
            (place, error) -> Void in
            // Get place.coordinate
            GMSGeocoder().reverseGeocodeCoordinate(place!.coordinate, completionHandler: {
                (response, error) -> Void in
                if let selectedAddress = place?.coordinate {
                    let camera = GMSCameraPosition.camera(withTarget: selectedAddress, zoom: self.mapSelectLocation.camera.zoom)
                    self.mapSelectLocation.animate(to: camera)
                }
            })
        })
        self.faeSearchController.faeSearchBar.text = self.placeholder[indexPath.row].attributedFullText.string
        self.faeSearchController.faeSearchBar.resignFirstResponder()
        self.searchBarTableHideAnimation()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 61 * screenWidthFactor
    }
}
