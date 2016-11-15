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

class SelectLocationViewController: UIViewController, GMSMapViewDelegate, CLLocationManagerDelegate, UISearchResultsUpdating, UISearchBarDelegate, CustomSearchControllerDelegate, UITableViewDelegate, UITableViewDataSource {
    
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
    
    func loadMapView() {
        let camera = GMSCameraPosition.camera(withLatitude: currentLatitude, longitude: currentLongitude, zoom: 17)
        self.mapSelectLocation = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        mapSelectLocation.isMyLocationEnabled = true
        mapSelectLocation.delegate = self
        self.view = mapSelectLocation
        locManager.delegate = self
        locManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locManager.startUpdatingLocation()
        
        imagePinOnMap = UIImageView(frame: CGRect(x: screenWidth/2-25, y: screenHeight/2-54, width: 50, height: 54))
        imagePinOnMap.image = UIImage(named: "commentMarkerWhenCreated")
        self.view.addSubview(imagePinOnMap)
        // Default is true, if true, panGesture could not be detected
        self.mapSelectLocation.settings.consumesGesturesInView = false
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
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        let mapCenter = CGPoint(x: screenWidth/2, y: screenHeight/2)
        let mapCenterCoordinate = mapView.projection.coordinate(for: mapCenter)
        GMSGeocoder().reverseGeocodeCoordinate(mapCenterCoordinate, completionHandler: {
            (response, error) -> Void in
            if let fullAddress = response?.firstResult()?.lines {
                var addressToSearchBar = ""
                for line in fullAddress {
                    if line == "" {
                        continue
                    }
                    else if fullAddress.index(of: line) == fullAddress.count-1 {
                        addressToSearchBar += line + ""
                    }
                    else {
                        addressToSearchBar += line + ", "
                    }
                }
                self.customSearchController.customSearchBar.text = addressToSearchBar
            }
            self.latitudeForPin = mapCenterCoordinate.latitude
            self.longitudeForPin = mapCenterCoordinate.longitude
        })
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        customSearchController.customSearchBar.endEditing(true)
    }
    
    func loadButtons() {
        buttonCancelSelectLocation = UIButton(frame: CGRect(x: 0, y: 0, width: 59, height: 59))
        buttonCancelSelectLocation.setImage(UIImage(named: "cancelSelectLocation"), for: UIControlState())
        self.view.addSubview(buttonCancelSelectLocation)
        buttonCancelSelectLocation.addTarget(self, action: #selector(SelectLocationViewController.actionCancelSelectLocation(_:)), for: .touchUpInside)
        self.view.addConstraintsWithFormat("H:|-18-[v0(59)]", options: [], views: buttonCancelSelectLocation)
        self.view.addConstraintsWithFormat("V:[v0(59)]-77-|", options: [], views: buttonCancelSelectLocation)
        
        buttonSelfPosition = UIButton()
        self.view.addSubview(buttonSelfPosition)
        buttonSelfPosition.setImage(UIImage(named: "self_position"), for: UIControlState())
        buttonSelfPosition.addTarget(self, action: #selector(SelectLocationViewController.actionSelfPosition(_:)), for: .touchUpInside)
        self.view.addConstraintsWithFormat("H:[v0(59)]-18-|", options: [], views: buttonSelfPosition)
        self.view.addConstraintsWithFormat("V:[v0(59)]-77-|", options: [], views: buttonSelfPosition)
        
        buttonSetLocationOnMap = UIButton()
        buttonSetLocationOnMap.setTitle("Set Location", for: UIControlState())
        buttonSetLocationOnMap.setTitle("Set Location", for: .highlighted)
        buttonSetLocationOnMap.setTitleColor(colorFae, for: UIControlState())
        buttonSetLocationOnMap.setTitleColor(UIColor.lightGray, for: .highlighted)
        buttonSetLocationOnMap.titleLabel?.font = UIFont(name: "AvenirNext-Bold", size: 22)
        buttonSetLocationOnMap.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.9)
        self.view.addSubview(buttonSetLocationOnMap)
        buttonSetLocationOnMap.addTarget(self, action: #selector(SelectLocationViewController.actionSetLocationForComment(_:)), for: .touchUpInside)
        self.view.addConstraintsWithFormat("H:|-0-[v0]-0-|", options: [], views: buttonSetLocationOnMap)
        self.view.addConstraintsWithFormat("V:[v0(65)]-0-|", options: [], views: buttonSetLocationOnMap)
    }
    
    func actionCancelSelectLocation(_ sender: UIButton) {
        self.dismiss(animated: false, completion: nil)
    }
    
    func actionSetLocationForComment(_ sender: UIButton) {
        if let searchText = customSearchController.customSearchBar.text {
            let mapCenter = CGPoint(x: screenWidth/2, y: screenHeight/2)
            let mapCenterCoordinate = mapSelectLocation.projection.coordinate(for: mapCenter)
            delegate?.sendAddress(searchText)
            delegate?.sendGeoInfo("\(mapCenterCoordinate.latitude)", longitude: "\(mapCenterCoordinate.longitude)")
        }
        self.dismiss(animated: false, completion: nil)
    }
    
    func actionSelfPosition(_ sender: UIButton!) {
        if(CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways){
            currentLocation = locManager.location
        }
        currentLatitude = currentLocation.coordinate.latitude
        currentLongitude = currentLocation.coordinate.longitude
        let camera = GMSCameraPosition.camera(withLatitude: currentLatitude, longitude: currentLongitude, zoom: 17)
        mapSelectLocation.camera = camera
    }
    
    func loadCustomSearchController() {
        let searchBarSubview = UIView(frame: CGRect(x: 8, y: 23, width: resultTableWidth, height: 48.0))
        
        customSearchController = CustomSearchController(searchResultsController: self, searchBarFrame: CGRect(x: 0, y: 5, width: resultTableWidth, height: 38.0), searchBarFont: UIFont(name: "AvenirNext-Medium", size: 18.0)!, searchBarTextColor: colorFae, searchBarTintColor: UIColor.white)
        customSearchController.customSearchBar.placeholder = "Search Address or Place                                  "
        customSearchController.customDelegate = self
        customSearchController.customSearchBar.layer.borderWidth = 2.0
        customSearchController.customSearchBar.layer.borderColor = UIColor.white.cgColor
        
        searchBarSubview.addSubview(customSearchController.customSearchBar)
        searchBarSubview.backgroundColor = UIColor.white
        self.view.addSubview(searchBarSubview)
        
        searchBarSubview.layer.borderColor = UIColor.white.cgColor
        searchBarSubview.layer.borderWidth = 1.0
        searchBarSubview.layer.cornerRadius = 2.0
        searchBarSubview.layer.shadowOpacity = 0.5
        searchBarSubview.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        searchBarSubview.layer.shadowRadius = 5.0
        searchBarSubview.layer.shadowColor = UIColor.black.cgColor
    }
    
    // MARK: UISearchResultsUpdating delegate function
    func updateSearchResults(for searchController: UISearchController) {
        tblSearchResults.reloadData()
    }
    
    // MARK: CustomSearchControllerDelegate functions
    func didStartSearching() {
        shouldShowSearchResults = true
        tblSearchResults.reloadData()
        customSearchController.customSearchBar.becomeFirstResponder()
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
            self.customSearchController.customSearchBar.text = self.placeholder[0].attributedFullText.string
            self.customSearchController.customSearchBar.resignFirstResponder()
            self.searchBarTableHideAnimation()
        }
        
    }
    
    func didTapOnCancelButton() {
        shouldShowSearchResults = false
        tblSearchResults.reloadData()
    }
    
    func didChangeSearchText(_ searchText: String) {
        if(searchText != "") {
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
        }
        else {
            self.placeholder.removeAll()
            searchBarTableHideAnimation()
            self.tblSearchResults.reloadData()
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
    
    // MARK: TableView Initialize
    
    func loadTableView() {
        uiviewTableSubview = UIView(frame: CGRect(x: 8, y: 78, width: resultTableWidth, height: 0))
        tblSearchResults = UITableView(frame: self.uiviewTableSubview.bounds)
        tblSearchResults.delegate = self
        tblSearchResults.dataSource = self
        tblSearchResults.register(CustomCellForAddressSearch.self, forCellReuseIdentifier: "customCellForAddressSearch")
        tblSearchResults.isScrollEnabled = false
        tblSearchResults.layer.masksToBounds = true
        tblSearchResults.separatorInset = UIEdgeInsets.zero
        tblSearchResults.layoutMargins = UIEdgeInsets.zero
        uiviewTableSubview.layer.borderColor = UIColor.white.cgColor
        uiviewTableSubview.layer.borderWidth = 1.0
        uiviewTableSubview.layer.cornerRadius = 2.0
        uiviewTableSubview.layer.shadowOpacity = 0.5
        uiviewTableSubview.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        uiviewTableSubview.layer.shadowRadius = 5.0
        uiviewTableSubview.layer.shadowColor = UIColor.black.cgColor
        uiviewTableSubview.addSubview(tblSearchResults)
        self.view.addSubview(uiviewTableSubview)
    }
    
    
    // MARK: UITableView Delegate and Datasource functions
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(tableView == self.tblSearchResults) {
            return placeholder.count
        }
        else {
            return 0
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.tblSearchResults {
            let cell = tableView.dequeueReusableCell(withIdentifier: "customCellForAddressSearch", for: indexPath) as! CustomCellForAddressSearch
            cell.labelCellContent.text = placeholder[indexPath.row].attributedFullText.string
            cell.separatorInset = UIEdgeInsets.zero
            cell.layoutMargins = UIEdgeInsets.zero
            return cell
        }
        else {
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(tableView == self.tblSearchResults) {
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
            self.customSearchController.customSearchBar.text = self.placeholder[indexPath.row].attributedFullText.string
            self.customSearchController.customSearchBar.resignFirstResponder()
            self.searchBarTableHideAnimation()
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(tableView == self.tblSearchResults) {
            return 48.0
        }
        else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
    }
}
