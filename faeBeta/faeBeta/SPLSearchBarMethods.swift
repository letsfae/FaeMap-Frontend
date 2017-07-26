//
//  SPLSearchBarMethods.swift
//  faeBeta
//
//  Created by Yue on 11/15/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
import CoreLocation

extension SelectLocationViewController: UISearchResultsUpdating, UISearchBarDelegate, FaeSearchControllerDelegate {
    
    // MKLocalSearchCompleterDelegate
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchResults = completer.results
        self.tblSearchResults.reloadData()
        if self.searchResults.count > 0 {
            self.searchBarTableShowAnimation()
        }
    }
    
    // MKLocalSearchCompleterDelegate
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        // handle error
    }
    
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
        
        if searchResults.count > 0 {
            let address = searchResults[0].title + searchResults[0].subtitle
            General.shared.getLocation(address: address) { (coordinate) in
                if let coor = coordinate {
                    let camera = self.slMapView.camera
                    camera.centerCoordinate = coor
                    self.slMapView.setCamera(camera, animated: true)
                }
            }
            faeSearchController.faeSearchBar.text = address
            faeSearchController.faeSearchBar.resignFirstResponder()
            self.searchBarTableHideAnimation()
        }
    }
    
    func didTapOnCancelButton() {
        shouldShowSearchResults = false
        tblSearchResults.reloadData()
    }
    
    func didChangeSearchText(_ searchText: String) {
        if searchText != "" {
            searchCompleter.queryFragment = searchText
        } else {
            searchResults.removeAll()
            searchBarTableHideAnimation()
            tblSearchResults.reloadData()
        }
    }
}
