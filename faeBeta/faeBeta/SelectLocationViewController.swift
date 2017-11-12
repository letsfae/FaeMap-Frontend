//
//  SelectLocationViewController.swift
//  faeBeta
//
//  Created by Yue on 10/19/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import SwiftyJSON
import CCHMapClusterController

// An enum type to return different geo -> address
enum SelectLoctionMode {
    case full
    case part
}

class SelectLocationViewController: UIViewController, MKMapViewDelegate, CCHMapClusterControllerDelegate, CCHMapAnimator, CCHMapClusterer, PlaceViewDelegate {
    
    // MARK: - Variables Declarations
    
    weak var delegate: BoardsSearchDelegate?
    
    // Screen Buttons
    var faeMapView: FaeMapView!
    var btnLocat: FMLocateSelf!
    var btnZoom: FMZoomButton!
    var btnSelect: FMDistIndicator!
    
    // Address parsing & display
    var lblSearchContent: UILabel!
    var routeAddress: RouteAddress!
    var mode: SelectLoctionMode = .full
    
    // Place pins data management
    var placeClusterManager: CCHMapClusterController!
    var faePlacePins = [FaePinAnnotation]()
    var setPlacePins = Set<Int>()
    var arrPlaceData = [PlacePin]()
    var selectedPlaceView: PlacePinAnnotationView?
    var selectedPlace: FaePinAnnotation?
    var uiviewPlaceBar = FMPlaceInfoBar()
    
    // Boolean values
    var fullyLoaded = false // if all ui components are fully loaded
    var boolFromBoard = false // if called from BoardSearchViewController
    
    // Location Pin Control
    var selectedLocation: FaePinAnnotation?
    var uiviewLocationBar: FMLocationInfoBar!
    var locAnnoView: LocPinAnnotationView?
    var activityIndicator: UIActivityIndicatorView!
    var locationPinClusterManager: CCHMapClusterController!
    var createLocation: CreateLocation = .cancel {
        didSet {
            guard fullyLoaded else { return }
            if createLocation == .cancel {
                uiviewLocationBar.hide()
                activityIndicator.stopAnimating()
                if selectedLocation != nil {
                    locationPinClusterManager.removeAnnotations([selectedLocation!], withCompletionHandler: nil)
                    if locAnnoView != nil {
                        locAnnoView?.hideButtons()
                        locAnnoView?.optionsReady = false
                        locAnnoView?.optionsOpened = false
                        locAnnoView?.optionsOpeing = false
                    }
                    selectedLocation = nil
                }
            }
        }
    }
    
    // MARK: - Life Cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadMapView()
        loadSearchBar()
        loadButtons()
        loadLocationView()
        loadPlaceInfoBar()
        fullyLoaded = true
//        let line = UIView(frame: CGRect(x: 0, y: screenHeight - 35 - 13, width: screenWidth, height: 1))
//        line.layer.borderColor = UIColor.black.cgColor
//        line.layer.borderWidth = 1
//        view.addSubview(line)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updatePlacePins()
    }
    
    // MARK: - Loading Parts
    
    func loadMapView() {
        faeMapView = FaeMapView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
        faeMapView.showsUserLocation = true
        faeMapView.delegate = self
        faeMapView.showsPointsOfInterest = false
        faeMapView.showsCompass = true
        faeMapView.tintColor = UIColor._2499090()
        faeMapView.slcMapCtrler = self
        view.addSubview(faeMapView)
        
        placeClusterManager = CCHMapClusterController(mapView: faeMapView)
        placeClusterManager.delegate = self
        placeClusterManager.cellSize = 100
        placeClusterManager.minUniqueLocationsForClustering = 3
        placeClusterManager.clusterer = self
        placeClusterManager.animator = self
        
        locationPinClusterManager = CCHMapClusterController(mapView: faeMapView)
        locationPinClusterManager.delegate = self
        locationPinClusterManager.cellSize = 200
        locationPinClusterManager.animator = self
        
        let camera = faeMapView.camera
        camera.centerCoordinate = Key.shared.selectedLoc
        // if mode == .part { camera.altitude = 35000 }
        // faeMapView.setCamera(camera, animated: false)
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(camera.centerCoordinate, 800, 800)
        faeMapView.setRegion(coordinateRegion, animated: false)
    }
    
    func loadSearchBar() {
        let imgSchbarShadow = UIImageView()
        imgSchbarShadow.frame = CGRect(x: 2, y: 17 + device_offset_top, width: 410 * screenWidthFactor, height: 60)
        imgSchbarShadow.image = #imageLiteral(resourceName: "mapSearchBar")
        view.addSubview(imgSchbarShadow)
        imgSchbarShadow.layer.zPosition = 500
        imgSchbarShadow.isUserInteractionEnabled = true
        
        // Left window on main map to open account system
        let btnLeftWindow = UIButton()
        btnLeftWindow.setImage(#imageLiteral(resourceName: "mainScreenSearchToFaeMap"), for: .normal)
        imgSchbarShadow.addSubview(btnLeftWindow)
        btnLeftWindow.addTarget(self, action: #selector(actionBack(_:)), for: .touchUpInside)
        imgSchbarShadow.addConstraintsWithFormat("H:|-6-[v0(40.5)]", options: [], views: btnLeftWindow)
        imgSchbarShadow.addConstraintsWithFormat("V:|-6-[v0(48)]", options: [], views: btnLeftWindow)
        btnLeftWindow.adjustsImageWhenDisabled = false
        
        let imgSearchIcon = UIImageView()
        imgSearchIcon.image = #imageLiteral(resourceName: "mapSearchCurrentLocation")
        imgSchbarShadow.addSubview(imgSearchIcon)
        imgSchbarShadow.addConstraintsWithFormat("H:|-54-[v0(15)]", options: [], views: imgSearchIcon)
        imgSchbarShadow.addConstraintsWithFormat("V:|-23-[v0(15)]", options: [], views: imgSearchIcon)
        
        lblSearchContent = UILabel()
        lblSearchContent.textAlignment = .left
        lblSearchContent.lineBreakMode = .byTruncatingTail
        lblSearchContent.font = UIFont(name: "AvenirNext-Medium", size: 18)
        lblSearchContent.textColor = UIColor._898989()
        imgSchbarShadow.addSubview(lblSearchContent)
        imgSchbarShadow.addConstraintsWithFormat("H:|-78-[v0]-60-|", options: [], views: lblSearchContent)
        imgSchbarShadow.addConstraintsWithFormat("V:|-18.5-[v0(25)]", options: [], views: lblSearchContent)
    }
    
    func loadButtons() {
        btnLocat = FMLocateSelf()
        btnLocat.removeTarget(nil, action: nil, for: .touchUpInside)
        btnLocat.addTarget(self, action: #selector(self.actionSelfPosition(_:)), for: .touchUpInside)
        view.addSubview(btnLocat)
        view.addConstraintsWithFormat("H:|-21-[v0(60)]", options: [], views: btnLocat)
        view.addConstraintsWithFormat("V:[v0(60)]-\(13+device_offset_bot)-|", options: [], views: btnLocat)
        
        btnSelect = FMDistIndicator()
        btnSelect.frame.origin.y = screenHeight - 74 - device_offset_bot
        btnSelect.lblDistance.text = "Select"
        btnSelect.lblDistance.textColor = UIColor._255160160()
        btnSelect.isUserInteractionEnabled = false
        view.addSubview(btnSelect)
        
        btnZoom = FMZoomButton()
        btnZoom.frame.origin.y = screenHeight - 60 - device_offset_bot - 13
        btnZoom.mapView = faeMapView
        view.addSubview(btnZoom)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        btnSelect.addGestureRecognizer(tapGesture)
        
        faeMapView.cgfloatCompassOffset = 134
        faeMapView.layoutSubviews()
    }
    
    func loadLocationView() {
        uiviewLocationBar = FMLocationInfoBar()
        view.addSubview(uiviewLocationBar)
        uiviewLocationBar.alpha = 0
        loadActivityIndicator()
    }
    
    func loadActivityIndicator() {
        activityIndicator = UIActivityIndicatorView()
        activityIndicator.activityIndicatorViewStyle = .gray
        activityIndicator.center = CGPoint(x: screenWidth / 2, y: 110)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = UIColor._2499090()
        view.addSubview(activityIndicator)
    }
    
    func loadPlaceInfoBar() {
        view.addSubview(uiviewPlaceBar)
        uiviewPlaceBar.delegate = self
        uiviewPlaceBar.boolDisableSwipe = true
    }
    
    // MARK: - MKMapDelegate
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            let identifier = "self_selected_mode"
            var anView: SelfAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? SelfAnnotationView {
                dequeuedView.annotation = annotation
                anView = dequeuedView
            } else {
                anView = SelfAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            }
            return anView
        } else if annotation is CCHMapClusterAnnotation {
            guard let clusterAnn = annotation as? CCHMapClusterAnnotation else { return nil }
            guard let firstAnn = clusterAnn.annotations.first as? FaePinAnnotation else { return nil }
            if firstAnn.type == "place" {
                return viewForPlace(annotation: annotation, first: firstAnn)
            } else if firstAnn.type == "location" {
                return viewForLocation(annotation: annotation, first: firstAnn)
            }
        }
        return nil
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        if uiviewPlaceBar.tag > 0 { uiviewPlaceBar.annotations = visiblePlaces() }
        
        let mapCenter = CGPoint(x: screenWidth / 2, y: screenHeight / 2)
        let mapCenterCoordinate = mapView.convert(mapCenter, toCoordinateFrom: nil)
        let location = CLLocation(latitude: mapCenterCoordinate.latitude, longitude: mapCenterCoordinate.longitude)
        if mode == .full {
            General.shared.getAddress(location: location) { address in
                guard let addr = address as? String else { return }
                DispatchQueue.main.async {
                    self.lblSearchContent.text = addr
                    self.routeAddress = RouteAddress(name: addr, coordinate: location.coordinate)
                }
            }
        } else {
            General.shared.getAddress(location: location, full: false) { address in
                guard let addr = address as? String else { return }
                DispatchQueue.main.async {
                    self.lblSearchContent.text = addr
                }
            }
        }
    }
    
    // MARK: - CCHMapClusterDelegate
    
    func mapClusterController(_ mapClusterController: CCHMapClusterController!, didAddAnnotationViews annotationViews: [Any]!) {
        for annotationView in annotationViews {
            if let anView = annotationView as? PlacePinAnnotationView {
                anView.alpha = 0
                anView.imgIcon.frame = CGRect(x: 28, y: 56, width: 0, height: 0)
                let delay: Double = Double(arc4random_uniform(100)) / 100 // Delay 0-1 seconds, randomly
                DispatchQueue.main.async {
                    UIView.animate(withDuration: 0.6, delay: delay, usingSpringWithDamping: 0.4, initialSpringVelocity: 0, options: .curveLinear, animations: {
                        anView.imgIcon.frame = CGRect(x: 0, y: 0, width: 56, height: 56)
                        anView.alpha = 1
                    }, completion: nil)
                }
            } else if let anView = annotationView as? LocPinAnnotationView {
                anView.alpha = 0
                DispatchQueue.main.async {
                    UIView.animate(withDuration: 0.2, animations: {
                        anView.alpha = 1
                    })
                }
            } else if let anView = annotationView as? MKAnnotationView {
                anView.alpha = 0
                DispatchQueue.main.async {
                    UIView.animate(withDuration: 0.4, animations: {
                        anView.alpha = 1
                    })
                }
            }
        }
    }
    
    func mapClusterController(_ mapClusterController: CCHMapClusterController!, willRemoveAnnotations annotations: [Any]!, withCompletionHandler completionHandler: (() -> Void)!) {
        
        UIView.animate(withDuration: 0.4, animations: {
            for annotation in annotations {
                if let anno = annotation as? MKAnnotation {
                    if let anView = self.faeMapView.view(for: anno) {
                        anView.alpha = 0
                    }
                }
            }
        }) { _ in
            if completionHandler != nil { completionHandler() }
        }
    }
    
    func mapClusterController(_ mapClusterController: CCHMapClusterController!, willReuse mapClusterAnnotation: CCHMapClusterAnnotation!) {
        let firstAnn = mapClusterAnnotation.annotations.first as! FaePinAnnotation
        if firstAnn.type == "place" {
            if let anView = faeMapView.view(for: mapClusterAnnotation) as? PlacePinAnnotationView {
                anView.assignImage(firstAnn.icon)
            }
        } else if firstAnn.type == "location" {
            if let anView = faeMapView.view(for: mapClusterAnnotation) as? LocPinAnnotationView {
                anView.assignImage(firstAnn.icon)
            }
        } else {
            if let anView = faeMapView.view(for: mapClusterAnnotation) as? SocialPinAnnotationView {
                anView.assignImage(firstAnn.icon)
            }
        }
    }
    
    func mapClusterController(_ mapClusterController: CCHMapClusterController!, coordinateForAnnotations annotations: Set<AnyHashable>!, in mapRect: MKMapRect) -> CLLocationCoordinate2D {
        guard let firstAnn = annotations.first as? FaePinAnnotation else {
            return CLLocationCoordinate2DMake(0, 0)
        }
        return firstAnn.coordinate
    }
    
    // MARK: - Place & Location Managements
    
    func viewForPlace(annotation: MKAnnotation, first: FaePinAnnotation) -> MKAnnotationView {
        let identifier = "place"
        var anView: PlacePinAnnotationView
        if let dequeuedView = faeMapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? PlacePinAnnotationView {
            dequeuedView.annotation = annotation
            anView = dequeuedView
        } else {
            anView = PlacePinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        }
        anView.assignImage(first.icon)
        return anView
    }
    
    func tapPlacePin(didSelect view: MKAnnotationView) {
        guard let cluster = view.annotation as? CCHMapClusterAnnotation else { return }
        guard let firstAnn = cluster.annotations.first as? FaePinAnnotation else { return }
        guard let anView = view as? PlacePinAnnotationView else { return }
        anView.layer.zPosition = 2
        anView.imgIcon.layer.zPosition = 2
        let idx = firstAnn.class_2_icon_id
        firstAnn.icon = UIImage(named: "place_map_\(idx)s") ?? #imageLiteral(resourceName: "place_map_48")
        anView.assignImage(firstAnn.icon)
        selectedPlace = firstAnn
        selectedPlaceView = anView
        selectedPlaceView?.tag = Int(selectedPlaceView?.layer.zPosition ?? 2)
        selectedPlaceView?.layer.zPosition = 1001
        guard firstAnn.type == "place" else { return }
        uiviewPlaceBar.show()
        uiviewPlaceBar.resetSubviews()
        uiviewPlaceBar.tag = 1
        mapView(faeMapView, regionDidChangeAnimated: false)
        uiviewPlaceBar.loadingData(current: cluster)
        btnSelect.lblDistance.textColor = UIColor._2499090()
        btnSelect.isUserInteractionEnabled = true
        if selectedLocation != nil { // TODO:
            selectedLocation = nil
        }
    }
    
    func updatePlacePins() {
        let coorDistance = cameraDiagonalDistance()
        refreshPlacePins(radius: coorDistance)
    }
    
    func refreshPlacePins(radius: Int) {
        if boolFromBoard { return }
        func getDelay(prevTime: DispatchTime) -> Double {
            let standardInterval: Double = 1
            let nowTime = DispatchTime.now()
            let timeDiff = Double(nowTime.uptimeNanoseconds - prevTime.uptimeNanoseconds)
            var delay: Double = 0
            if timeDiff / Double(NSEC_PER_SEC) < standardInterval {
                delay = standardInterval - timeDiff / Double(NSEC_PER_SEC)
            } else {
                delay = timeDiff / Double(NSEC_PER_SEC) - standardInterval
            }
            return delay
        }
        
        let mapCenter = CGPoint(x: screenWidth / 2, y: screenHeight / 2)
        let mapCenterCoordinate = faeMapView.convert(mapCenter, toCoordinateFrom: nil)
        let getPlaceInfo = FaeMap()
        getPlaceInfo.whereKey("geo_latitude", value: "\(mapCenterCoordinate.latitude)")
        getPlaceInfo.whereKey("geo_longitude", value: "\(mapCenterCoordinate.longitude)")
        getPlaceInfo.whereKey("radius", value: "500000")
        getPlaceInfo.whereKey("type", value: "place")
        getPlaceInfo.whereKey("max_count", value: "100")
        getPlaceInfo.getMapInformation { (status: Int, message: Any?) in
            guard status / 100 == 2 && message != nil else {
                return
            }
            let mapPlaceJSON = JSON(message!)
            guard let mapPlaceJsonArray = mapPlaceJSON.array else {
                return
            }
            guard mapPlaceJsonArray.count > 0 else {
                return
            }
            var placePins = [FaePinAnnotation]()
            var serialQueue = DispatchQueue(label: "appendPlaces")
            if #available(iOS 10.0, *) {
                serialQueue = DispatchQueue(label: "appendPlaces", qos: .userInteractive, attributes: [], autoreleaseFrequency: .workItem, target: nil)
            } else {
                // Fallback on earlier versions
            }
            serialQueue.async {
                var i = 0
                for placeJson in mapPlaceJsonArray {
                    let placeData = PlacePin(json: placeJson)
                    let place = FaePinAnnotation(type: "place", cluster: self.placeClusterManager, data: placeData)
                    if self.setPlacePins.contains(placeJson["place_id"].intValue) {
                        //                        joshprint(i, "inserted fail")
                    } else {
                        self.setPlacePins.insert(placeJson["place_id"].intValue)
                        placePins.append(place)
                        self.faePlacePins.append(place)
                    }
                    i += 1
                }
                //                joshprint(" ")
                guard placePins.count > 0 else { return }
                //                joshprint(self.faePlacePins.count)
                DispatchQueue.main.async {
                    self.placeClusterManager.addAnnotations(placePins, withCompletionHandler: nil)
                }
            }
        }
    }
    
    // MARK: - Location Pin Managements
    
    func viewForLocation(annotation: MKAnnotation, first: FaePinAnnotation) -> MKAnnotationView {
        let identifier = "location"
        var anView: LocPinAnnotationView
        if let dequeuedView = faeMapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? LocPinAnnotationView {
            dequeuedView.annotation = annotation
            anView = dequeuedView
        } else {
            anView = LocPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        }
        locAnnoView = anView
        anView.assignImage(first.icon)
        anView.imgIcon.frame = CGRect(x: 0, y: 0, width: 56, height: 56)
        anView.alpha = 1
        anView.optionsReady = true
        return anView
    }
    
    func createLocationPin(point: CGPoint) {
        createLocation = .create
        let coordinate = faeMapView.convert(point, toCoordinateFrom: faeMapView)
        let cllocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        if selectedLocation != nil {
            locationPinClusterManager.removeAnnotations([selectedLocation!], withCompletionHandler: nil)
            selectedLocation = nil
        }
        uiviewPlaceBar.hide()
        locAnnoView?.hideButtons()
        locAnnoView?.optionsReady = false
        locAnnoView?.optionsOpened = false
        locAnnoView?.optionsOpeing = false
        deselectAllAnnotations()
        let pinData = LocationPin(position: coordinate)
        pinData.optionsReady = true
        selectedLocation = FaePinAnnotation(type: "location", data: pinData as AnyObject)
        locationPinClusterManager.addAnnotations([selectedLocation!], withCompletionHandler: nil)
        uiviewLocationBar.show()
        view.bringSubview(toFront: activityIndicator)
        activityIndicator.startAnimating()
        General.shared.getAddress(location: cllocation, full: false) { address in
            guard let addr = address as? String else { return }
            DispatchQueue.main.async {
                self.routeAddress = RouteAddress(name: addr, coordinate: cllocation.coordinate)
            }
        }
        General.shared.getAddress(location: cllocation, original: true) { original in
            guard let first = original as? CLPlacemark else { return }
            
            var name = ""
            var subThoroughfare = ""
            var thoroughfare = ""
            
            var address_1 = ""
            var address_2 = ""
            
            if let n = first.name {
                name = n
                address_1 += n
            }
            if let s = first.subThoroughfare {
                subThoroughfare = s
                if address_1 != "" {
                    address_1 += ", "
                }
                address_1 += s
            }
            if let t = first.thoroughfare {
                thoroughfare = t
                if address_1 != "" {
                    address_1 += ", "
                }
                address_1 += t
            }
            
            if name == subThoroughfare + " " + thoroughfare {
                address_1 = name
            }
            
            if let l = first.locality {
                address_2 += l
            }
            if let a = first.administrativeArea {
                if address_2 != "" {
                    address_2 += ", "
                }
                address_2 += a
            }
            if let p = first.postalCode {
                address_2 += " " + p
            }
            if let c = first.country {
                if address_2 != "" {
                    address_2 += ", "
                }
                address_2 += c
            }
            
            self.selectedLocation?.address_1 = address_1
            self.selectedLocation?.address_2 = address_2
            DispatchQueue.main.async {
                self.uiviewLocationBar.updateLocationBar(name: address_1, address: address_2)
                self.activityIndicator.stopAnimating()
                self.btnSelect.lblDistance.textColor = UIColor._2499090()
                self.btnSelect.isUserInteractionEnabled = true
            }
        }
    }
    
    // MARK: - Actions in Controller
    
    @objc func handleTap(_ tap: UITapGestureRecognizer) {
        /* guard routeAddress != nil else { return }
         navigationController?.popViewController(animated: false)
         delegate?.sendLocationBack?(address: routeAddress) */
        if boolFromBoard {
            if selectedLocation != nil {
                delegate?.jumpToLocationSearchResult?(icon: #imageLiteral(resourceName: "mb_iconBeforeCurtLoc"), searchText: "\(selectedLocation!.address_1), \(selectedLocation!.address_2)", location: CLLocation(latitude: selectedLocation!.coordinate.latitude, longitude: selectedLocation!.coordinate.longitude))
                navigationController?.popViewController(animated: true)
            }
        } else {
            if selectedLocation != nil {
                let address = RouteAddress(name: selectedLocation!.address_1, coordinate: selectedLocation!.coordinate)
                navigationController?.popViewController(animated: false)
                delegate?.sendLocationBack?(address: address)
            }
            if selectedPlace != nil {
                guard let placeData = selectedPlace?.pinInfo as? PlacePin else { return }
                navigationController?.popViewController(animated: false)
                delegate?.sendPlaceBack?(placeData: placeData)
            }
        }
    }
    
    @objc func actionBack(_ sender: UIButton) {
        navigationController?.popViewController(animated: false)
    }
    
    @objc func actionSelfPosition(_ sender: UIButton!) {
        let camera = faeMapView.camera
        camera.centerCoordinate = LocManager.shared.curtLoc.coordinate
        faeMapView.setCamera(camera, animated: false)
    }
    
    // MARK: - PlaceViewDelegate
    
    func goTo(annotation: CCHMapClusterAnnotation?, place: PlacePin?) {
        deselectAllAnnotations()
        if let anno = annotation {
            faeMapView.selectAnnotation(anno, animated: false)
        }
        if let placePin = place {
            var desiredAnno: CCHMapClusterAnnotation!
            for anno in faeMapView.annotations {
                guard let cluster = anno as? CCHMapClusterAnnotation else { continue }
                guard let firstAnn = cluster.annotations.first as? FaePinAnnotation else { continue }
                guard let placeInfo = firstAnn.pinInfo as? PlacePin else { continue }
                if placeInfo == placePin {
                    desiredAnno = cluster
                    break
                }
            }
            if desiredAnno != nil {
                faeMapView.selectAnnotation(desiredAnno, animated: false)
            }
        }
    }
    
    // MARK: - Auxiliary Map Functions
    
    func deselectAllAnnotations() {
        if let idx = selectedPlace?.class_2_icon_id {
            selectedPlace?.icon = UIImage(named: "place_map_\(idx)") ?? #imageLiteral(resourceName: "place_map_48")
            guard let img = selectedPlace?.icon else { return }
            selectedPlaceView?.layer.zPosition = CGFloat(selectedPlaceView?.tag ?? 2)
            selectedPlaceView?.assignImage(img)
            selectedPlaceView?.hideButtons()
            selectedPlaceView?.optionsReady = false
            selectedPlaceView?.optionsOpened = false
            selectedPlaceView = nil
        }
        btnSelect.lblDistance.textColor = UIColor._255160160()
        btnSelect.isUserInteractionEnabled = false
    }
    
    func visiblePlaces() -> [CCHMapClusterAnnotation] {
        var mapRect = faeMapView.visibleMapRect
        mapRect.origin.y += mapRect.size.height * 0.3
        mapRect.size.height = mapRect.size.height * 0.7
        let visibleAnnos = faeMapView.annotations(in: mapRect)
        var places = [CCHMapClusterAnnotation]()
        for anno in visibleAnnos {
            if anno is CCHMapClusterAnnotation {
                guard let place = anno as? CCHMapClusterAnnotation else { continue }
                guard let firstAnn = place.annotations.first as? FaePinAnnotation else { continue }
                guard faeMapView.view(for: place) is PlacePinAnnotationView else { continue }
                guard firstAnn.type == "place" else { continue }
                places.append(place)
            } else {
                continue
            }
        }
        return places
    }
    
    func cameraDiagonalDistance() -> Int {
        guard faeMapView != nil else { return 8000 }
        let centerCoor: CLLocationCoordinate2D = getCenterCoordinate()
        // init center location from center coordinate
        let centerLocation = CLLocation(latitude: centerCoor.latitude, longitude: centerCoor.longitude)
        let topCenterCoor: CLLocationCoordinate2D = getTopCenterCoordinate()
        let topCenterLocation = CLLocation(latitude: topCenterCoor.latitude, longitude: topCenterCoor.longitude)
        let radius: CLLocationDistance = centerLocation.distance(from: topCenterLocation)
        return Int(radius * 4)
    }
    
    func getCenterCoordinate() -> CLLocationCoordinate2D {
        return faeMapView.centerCoordinate
    }
    
    func getTopCenterCoordinate() -> CLLocationCoordinate2D {
        // to get coordinate from CGPoint of your map
        return faeMapView.convert(CGPoint(x: screenWidth / 2, y: 0), toCoordinateFrom: nil)
    }
}
