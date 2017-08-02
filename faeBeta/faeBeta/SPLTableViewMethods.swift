//
//  SPLTableViewMethods.swift
//  faeBeta
//
//  Created by Yue on 11/15/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

extension SelectLocationViewController: UITableViewDelegate, UITableViewDataSource {
    
    // MARK: UITableView Delegate and Datasource functions
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "faeCellForAddressSearch", for: indexPath) as! FaeCellForMainScreenSearch
        cell.labelTitle.text = searchResults[indexPath.row].title
        cell.labelSubTitle.text = searchResults[indexPath.row].subtitle
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let address = searchResults[indexPath.row].title + searchResults[indexPath.row].subtitle
        General.shared.getLocation(address: address) { (coordinate) in
            if let coor = coordinate {
                let camera = self.slMapView.camera
                camera.centerCoordinate = coor
                self.slMapView.setCamera(camera, animated: true)
            }
        }
        
        faeSearchController.faeSearchBar.text = address
        faeSearchController.faeSearchBar.resignFirstResponder()
        searchBarTableHideAnimation()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 61 * screenWidthFactor
    }
}
