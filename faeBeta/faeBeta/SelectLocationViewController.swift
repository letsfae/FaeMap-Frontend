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

protocol SelectLocationViewControllerDelegate {
    func sendAddress(_ value: String)
    func sendGeoInfo(_ latitude: String, longitude: String)
}

class SelectLocationViewController: UIViewController, CLLocationManagerDelegate {
    
    var delegate: SelectLocationViewControllerDelegate?
    
    let screenWidth = UIScreen.main.bounds.width
    let screenHeight = UIScreen.main.bounds.height
    let colorFae = UIColor(red: 249/255, green: 90/255, blue: 90/255, alpha: 1.0)
    
    var mapSelectLocation: GMSMapView!

    var imagePinOnMap: UIImageView!
    
    var currentLocation: CLLocation!
    let locManager = CLLocationManager()
    var currentLatitude: CLLocationDegrees = 34.0205378
    var currentLongitude: CLLocationDegrees = -118.2854081
    var latitudeForPin: CLLocationDegrees = 0
    var longitudeForPin: CLLocationDegrees = 0
    var willAppearFirstLoad = false
    
    var buttonCancelSelectLocation: UIButton!
    var buttonSelfPosition: UIButton!
    var buttonSetLocationOnMap: UIButton!
    
    // MARK: -- Search Bar
    var uiviewTableSubview: UIView!
    var tblSearchResults = UITableView()
    var dataArray = [String]()
    var filteredArray = [String]()
    var shouldShowSearchResults = false
    var searchController: UISearchController!
    var customSearchController: CustomSearchController!
    var searchBarSubview: UIView!
    var placeholder = [GMSAutocompletePrediction]()
    
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
        loadCustomSearchController()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        locManager.requestAlwaysAuthorization()        
        willAppearFirstLoad = true
    }
    
    

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if willAppearFirstLoad {
            currentLocation = locManager.location
            currentLatitude = currentLocation.coordinate.latitude
            currentLongitude = currentLocation.coordinate.longitude
            let camera = GMSCameraPosition.camera(withLatitude: currentLatitude, longitude: currentLongitude, zoom: 17)
            mapSelectLocation.camera = camera
            willAppearFirstLoad = false
        }
    }
    
    func searchBarTableHideAnimation() {
        UIView.animate(withDuration: 0.25, delay: 0, options: UIViewAnimationOptions.transitionFlipFromBottom, animations: ({
            self.tblSearchResults.frame = CGRect(x: 0, y: 0, width: self.resultTableWidth, height: 0)
            self.uiviewTableSubview.frame = CGRect(x: 8, y: 76, width: self.resultTableWidth, height: 0)
        }), completion: nil)
    }
    
    func searchBarTableShowAnimation() {
        UIView.animate(withDuration: 0.25, delay: 0, options: UIViewAnimationOptions.transitionFlipFromBottom, animations: ({
            self.tblSearchResults.frame = CGRect(x: 0, y: 0, width: self.resultTableWidth, height: 240)
            self.uiviewTableSubview.frame = CGRect(x: 8, y: 76, width: self.resultTableWidth, height: 240)
        }), completion: nil)
    }
}
