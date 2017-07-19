//
//  SelectLocationViewController.swift
//  faeBeta
//
//  Created by Yue on 10/19/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import CoreLocation

protocol SelectLocationViewControllerDelegate: class {
    func sendAddress(_ value: String)
    func sendGeoInfo(_ latitude: String, longitude: String, zoom: Float)
}

class SelectLocationViewController: UIViewController {
    
    weak var delegate: SelectLocationViewControllerDelegate?
    
    var mapSelectLocation: GMSMapView!

    var imagePinOnMap: UIImageView!
    
//    var currentLocation: CLLocation!
//    let locManager = CLLocationManager()
//    var currentLatitude: CLLocationDegrees = 34.0205378
//    var currentLongitude: CLLocationDegrees = -118.2854081
    var currentLocation2D = CLLocationCoordinate2DMake(34.0205378, -118.2854081)
    var zoomLevel: Double = 13.8
    var latitudeForPin: CLLocationDegrees = 0
    var longitudeForPin: CLLocationDegrees = 0
    var willAppearFirstLoad = false
    
    var buttonCancelSelectLocation: UIButton!
    var btnSelfLocation: UIButton!
    var buttonSetLocationOnMap: UIButton!
    
    // MARK: -- Search Bar
    var uiviewTableSubview: UIView!
    var tblSearchResults = UITableView()
    var dataArray = [String]()
    var filteredArray = [String]()
    var shouldShowSearchResults = false
    var searchController: UISearchController!
    var faeSearchController: FaeSearchController!
    var searchBarSubview: UIView!
    var placeholder = [GMSAutocompletePrediction]()
    var pinType = "comment"
    var isCreatingMode = true
    
    var resultTableWidth: CGFloat {
        if UIScreen.main.bounds.width == 414 { // 5.5
            return 398
        }
        else if UIScreen.main.bounds.width == 320 { // 4.0
            return 308
        }
        else if UIScreen.main.bounds.width == 375 { // 4.7
            return 360.5
        }
        return 308
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadMapView()
        loadButtons()
        loadTableView()
        loadFaeSearchController()
        UIApplication.shared.statusBarStyle = .default
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if isCreatingMode {
            UIApplication.shared.statusBarStyle = .lightContent
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {   
        willAppearFirstLoad = true
    }
    
    func searchBarTableHideAnimation() {
        UIView.animate(withDuration: 0.25, delay: 0, options: UIViewAnimationOptions.transitionFlipFromBottom, animations: ({
            self.tblSearchResults.frame = CGRect(x: 0, y: 0, width: self.resultTableWidth, height: 0)
            self.uiviewTableSubview.frame = CGRect(x: 8, y: 76, width: self.resultTableWidth, height: 0)
        }), completion: nil)
    }
    
    func searchBarTableShowAnimation() {
        UIView.animate(withDuration: 0.25, delay: 0, options: UIViewAnimationOptions.transitionFlipFromBottom, animations: ({
            self.tblSearchResults.frame = CGRect(x: 0, y: 0, width: self.resultTableWidth, height: 305*screenHeightFactor)
            self.uiviewTableSubview.frame = CGRect(x: 8, y: 76, width: self.resultTableWidth, height: 305*screenHeightFactor)
        }), completion: nil)
    }
}
