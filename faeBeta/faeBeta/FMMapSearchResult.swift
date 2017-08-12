//
//  FMMapSearchResult.swift
//  faeBeta
//
//  Created by Faevorite 2 on 2017-08-01.
//  Copyright © 2017 fae. All rights reserved.
//

extension FaeMapViewController: MapSearchDelegate {
    
    // MapSearchDelegate
    func jumpToOnePlace(searchText: String, place: PlacePin) {
        updateUI(searchText: searchText)
        placeResultBar.load(for: place)
        PLACE_ENABLE = false
        let camera = faeMapView.camera
        camera.centerCoordinate = place.coordinate
        faeMapView.setCamera(camera, animated: false)
        mapClusterManager.removeAnnotations(faePlacePins) {
            self.faePlacePins.removeAll()
            let pin = FaePinAnnotation(type: "place", cluster: self.mapClusterManager)
            pin.pinInfo = place as AnyObject
            pin.id = place.id
            pin.class_2_icon_id = place.class_2_icon_id
            pin.icon = UIImage(named: "place_map_\(place.class_2_icon_id)s") ?? #imageLiteral(resourceName: "place_map_48s")
            pin.coordinate = place.coordinate
            self.faePlacePins.append(pin)
            self.mapClusterManager.addAnnotations([pin], withCompletionHandler: nil)
        }
    }
    
    func jumpToPlaces(searchText: String, places: [PlacePin], selectedLoc: CLLocation) {
        updateUI(searchText: searchText)
        UIView.animate(withDuration: 0.3) {
            self.placeResultTbl.alpha = 1
        }
        placeResultTbl.arrPlaces = places
        placeResultTbl.tblResults.reloadData()
    }
    
    func backToMainMapFromMapSearch() {
        lblSearchContent.text = "Search Fae Map"
        lblSearchContent.textColor = UIColor._182182182()
        btnClearSearchRes.isHidden = true
    }
    // MapSearchDelegate End
    
    func updateUI(searchText: String) {
        btnClearSearchRes.isHidden = false
        lblSearchContent.text = searchText
        lblSearchContent.textColor = UIColor._898989()
    }
}
