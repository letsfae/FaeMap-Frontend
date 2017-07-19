//
//  SPLActions.swift
//  faeBeta
//
//  Created by Yue on 11/15/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

extension SelectLocationViewController {
    
    func actionCancelSelectLocation(_ sender: UIButton) {
        self.dismiss(animated: false, completion: nil)
    }
    
    func actionSetLocationForComment(_ sender: UIButton) {
        if let searchText = faeSearchController.faeSearchBar.text {
            let mapCenter = CGPoint(x: screenWidth/2, y: screenHeight/2)
            let mapCenterCoordinate = slMapView.convert(mapCenter, toCoordinateFrom: nil)
            Key.shared.selectedLoc = mapCenterCoordinate
            Key.shared.dblAltitude = slMapView.camera.altitude
            delegate?.sendAddress(searchText)
        }
        self.dismiss(animated: false, completion: nil)
    }
    
    func actionSelfPosition(_ sender: UIButton!) {
        let camera = slMapView.camera
        camera.centerCoordinate = LocManage.shared.curtLoc.coordinate
        slMapView.setCamera(camera, animated: false)
        
    }
    
    func actionClearSearchBar(_ sender: UIButton) {
        faeSearchController.faeSearchBar.text = nil
        self.placeholder.removeAll()
        searchBarTableHideAnimation()
        self.tblSearchResults.reloadData()
    }
}
