//
//  SPLSearchBarMethods.swift
//  faeBeta
//
//  Created by Yue on 11/15/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import CoreLocation

extension SelectLocationViewController: UISearchResultsUpdating, UISearchBarDelegate, FaeSearchControllerDelegate {
    
    // MARK: UISearchResultsUpdating delegate function
    func updateSearchResults(for searchController: UISearchController) {
        tblSearchResults.reloadData()
    }
    
    // MARK: FaeSearchControllerDelegate functions
    func didStartSearching() {
        shouldShowSearchResults = true
        tblSearchResults.reloadData()
        faeSearchController.faeSearchBar.becomeFirstResponder()
    }
    
    func didTapOnSearchButton() {
        if !shouldShowSearchResults {
            shouldShowSearchResults = true
            tblSearchResults.reloadData()
        }
        
        if placeholder.count > 0 {
            let placesClient = GMSPlacesClient()
            placesClient.lookUpPlaceID(placeholder[0].placeID!, callback: {
                (place, error) -> Void in
                GMSGeocoder().reverseGeocodeCoordinate(place!.coordinate, completionHandler: {
                    (response, error) -> Void in
                    if let selectedAddress = place?.coordinate {
                        let camera = GMSCameraPosition.camera(withTarget: selectedAddress, zoom: self.mapSelectLocation.camera.zoom)
                        self.mapSelectLocation.animate(to: camera)
                    }
                })
            })
            self.faeSearchController.faeSearchBar.text = self.placeholder[0].attributedFullText.string
            self.faeSearchController.faeSearchBar.resignFirstResponder()
            self.searchBarTableHideAnimation()
        }
        
    }
    
    func didTapOnCancelButton() {
        shouldShowSearchResults = false
        tblSearchResults.reloadData()
    }
    
    func didChangeSearchText(_ searchText: String) {
        if searchText != ""  {
            let placeClient = GMSPlacesClient()
            placeClient.autocompleteQuery(searchText, bounds: nil, filter: nil) {
                (results: [GMSAutocompletePrediction]?, error : Error?) -> Void in
                if(error != nil) {
                    print(error ?? "error value unreadable")
                }
                self.placeholder.removeAll()
                if results == nil {
                    return
                } else {
                    for result in results! {
                        self.placeholder.append(result)
                    }
                    self.tblSearchResults.reloadData()
                }
                if self.placeholder.count > 0 {
                    self.searchBarTableShowAnimation()
                }
            }
        } else {
            self.placeholder.removeAll()
            searchBarTableHideAnimation()
            self.tblSearchResults.reloadData()
        }
    }
}
